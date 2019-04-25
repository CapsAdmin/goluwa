--https://github.com/TReed0803/QtOpenGL/blob/master/resources/shaders/lighting/Physical.glsl

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_sky(vec3 ray, float depth)
{
	depth = depth < 1 ? 0 : 1;

	vec3 sun_direction = lua[(vec3)render3d.GetShaderSunDirection].xyz;
	vec3 dir = ray.xzy * vec3(1,-1,1);
	dir = reflect(-dir, sun_direction);

	vec3 res = textureLatLon(lua[nightsky_tex = render.CreateTextureFromPath("textures/skybox/hdr/desert_highway.hdr")], -dir.xzy).rgb*depth;

	//res = pow(res, vec3(0.5));
	//res += res*vec3(length(pow(res, vec3(5))));

	return res;
}]])
--runfile("lua/libraries/graphics/render3d/sky_shaders/atmosphere2.lua")
render.AddGlobalShaderCode([[
float handle_roughness(float x)
{
	return clamp(pow(x, 2.5), 0.0025, 1.0);
}]])

render.AddGlobalShaderCode([[
float handle_metallic(float x)
{
	return clamp(x, 0.00025, 1.0);
}]])

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_tonemap(vec3 color, vec3 bloom)
{
	float gamma = 2.2;
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	float exposure = 2.0;
	color *= exposure;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
	color = pow(color, vec3(1. / gamma));

	return color;
}]])

render.AddGlobalShaderCode([[
float Pdf(float NoL, float NoV)
{
  return (4.0 * NoL * NoV);
}
float Specular(float NoL, float NoV, float NoH, float VoH)
{
  return Fresnel(VoH) * Geometry(NoL, NoV, NoH, VoH) * Distribution(NoH) / Pdf(NoL, NoV);
}

vec3 Brdf(vec3 Kd, float NoL, float NoV, float NoH, float VoH)
{
  vec3  Kdiff  = Kd / PI;
  float Kspec = Specular(NoL, NoV, NoH, VoH);
  return BlendMaterial(Kdiff, vec3(Kspec));
}

vec3 Brdf(vec3 Kd, vec3 Li, vec3 L, vec3 V, vec3 N)
{
  vec3    H = normalize(L + V);
  float NoL = saturate(dot(N, L));
  float NoV = saturate(dot(N, V));
  float NoH = saturate(dot(N, H));
  float VoH = saturate(dot(V, H));
  return Brdf(Kd, NoL, NoV, NoH, VoH) * Li * NoL;
}

vec3 gbuffer_compute_specular(vec3 l, vec3 v, vec3 n, float attenuation, vec3 light_color)
{
	return max(Brdf(get_albedo(get_screen_uv()), light_color*attenuation*4, l,v,-n), vec3(0));
}]])


render.AddGlobalShaderCode([[
float FSchlick(float VoH)
{
  float Kmetallic = get_metallic(get_screen_uv());
  return Kmetallic + (1.0 - Kmetallic) * pow(1.0 - VoH, 5.0);
}
float Fresnel(float NoL)
{
  return FSchlick(NoL);
}
]])

render.AddGlobalShaderCode([[
float GSmithSchlickBeckmann_(float NoV)
{
  float k = get_roughness(get_screen_uv()) * get_roughness(get_screen_uv()) * sqrt(TAU);
  return NoV / (NoV * (1.0 - k) + k);
}

float GSmithSchlickBeckmann(float NoL, float NoV, float NoH, float VoH)
{
  return GSmithSchlickBeckmann_(NoL) * GSmithSchlickBeckmann_(NoV);
}
float Geometry(float NoL, float NoV, float NoH, float VoH)
{
  return GSmithSchlickBeckmann(NoL, NoV, NoH, VoH);
}]])

render.AddGlobalShaderCode([[
float DGgx(float NoH)
{
  // Note: Generally sin2 + cos2 = 1
  // Also: Dgtr = c / (a * cos2 + sin2)
  // So...
  float Krough2 = get_roughness(get_screen_uv()) * get_roughness(get_screen_uv());
  float NoH2 = NoH * NoH;
  float denom = 1.0 + NoH2 * (Krough2 - 1.0);
  return Krough2 / (PI * denom * denom);
}
float Distribution(float NoH)
{
  return DGgx(NoH);
}]])


render.AddGlobalShaderCode([[
vec3 MakeSample(float Theta, float Phi)
{
  Phi += random_angle();
  float SineTheta = sin(Theta);

  float x = cos(Phi) * SineTheta;
  float y = sin(Phi) * SineTheta;
  float z = cos(Theta);

  return vec3(x, y, z);
}

vec3 DGgxSample(vec2 E)
{
  float a = get_roughness(get_screen_uv()) * get_roughness(get_screen_uv());
  float Theta = atan(sqrt((a * E.x) / (1.0 - E.x)));
  float Phi = TAU * E.y;
  return MakeSample(Theta, Phi);
}
vec3 CDFSample(vec2 random)
{
  return DGgxSample(random);
}]])

render.AddGlobalShaderCode([[
vec3 BlendDielectric(vec3 Kdiff, vec3 Kspec, vec3 Kbase)
{
  return Kdiff + Kspec;
}
vec3 BlendMetal(vec3 Kdiff, vec3 Kspec, vec3 Kbase)
{
  return Kspec * Kbase;
}
vec3 BlendMaterial(vec3 Kdiff, vec3 Kspec)
{
	vec3  Kbase = get_albedo(get_screen_uv());
	vec3  dielectric = BlendDielectric(Kdiff, Kspec, Kbase);
	vec3  metal = BlendMetal(Kdiff, Kspec, Kbase);
	return mix(dielectric, metal, get_metallic(get_screen_uv()));
}
]])

do
	local PASS = {}

	PASS.Position = 1
	PASS.Name = "importance_sampling"

	PASS.Source = {}

	table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			size_divider = 1,
			internal_format = "r11f_g11f_b10f",
		},
		source = [[
		#extension GL_ARB_gpu_shader5 : enable

		vec2 _raycast_project(vec3 coord)
		{
			vec4 res = _G.projection * vec4(coord, 1.0);
			return (res.xy / res.w) * 0.5 + 0.5;
		}

		vec2 raycast(vec3 viewPos, vec3 normal, vec2 seed)
		{
			const float step_size = 0.01;
			const float max_steps = 5;

			vec3 dir = reflect(normalize(viewPos), normal) * 125;
			dir *= step_size + get_linearized_depth(uv);

			for(int i = 0; i < max_steps; i++)
			{
				viewPos += dir;
				viewPos += get_noise3(viewPos.xy+seed).xyz * get_roughness(uv);

				float depth = viewPos.z - get_view_pos(_raycast_project(viewPos)).z;

				if(depth > -5 && depth < 0)
				{
					return _raycast_project(viewPos).xy;
				}
			}

			return vec2(0.0, 0.0);
		}


		#define XAxis vec3(1.0, 0.0, 0.0)
		#define YAxis vec3(0.0, 1.0, 0.0)
		#define ZAxis vec3(0.0, 0.0, 1.0)
		#define KWhite vec3(1.0, 1.0, 1.0)

		float compute_lod(samplerCube tex, uint NumSamples, float NoH)
		{
			vec2 Dimensions = textureSize(tex, 0);
			return 0.5 * (log2(float(Dimensions.x * Dimensions.y) / NumSamples) - log2(Distribution(NoH)));
		}

		vec3 sample_tex(samplerCube tex, vec3 dir, float blur, float samples)
		{
			//textureLod(tex, dir, blur).rgb;
			vec3 res = vec3(0);
			for (float i = 0; i < samples; ++i)
			{
				res += texture(tex, dir + (get_noise3(uv+vec2(i))*blur*0.5)).rgb;
			}
			return res / samples;
		}

		vec3 radiance(samplerCube environment, vec3 N, vec3 V)
		{
		  // Precalculate rotation for +Z Hemisphere to microfacet normal.
		  vec3 UpVector = abs(N.z) < 0.999 ? ZAxis : XAxis;
		  vec3 TangentX = normalize(cross( UpVector, N ));
		  vec3 TangentY = cross(N, TangentX);

		vec3 view_pos = get_view_pos(uv);

		  // Note: I ended up using abs() for situations where the normal is
		  // facing a little away from the view to still accept the approximation.
		  // I believe this is due to a separate issue with normal storage, so
		  // you may only need to saturate() each dot value instead of abs().
		  float NoV = abs(dot(N, V));

		  // Approximate the integral for lighting contribution.
		  vec3 fColor = vec3(0.0);
		  const uint NumSamples = 20;
		  for (uint i = 1; i < NumSamples; ++i)
		  {
			vec2 Xi = hammersley_2d(i, NumSamples);
			vec3 Li = CDFSample(Xi);
			vec3 H  = normalize(Li.x * TangentX + Li.y * TangentY + Li.z * N);
			vec3 L  = normalize(-reflect(V, H));

			// Calculate dot products for BRDF
			float NoL = abs(dot(N, L));
			float NoH = abs(dot(N, H));
			float VoH = abs(dot(V, H));
			//float lod = compute_lod(environment, NumSamples, NoH);

			float F_ = Fresnel(VoH); // Defined elsewhere as subroutine
			float G_ = Geometry(NoL, NoV, NoH, VoH); // Defined elsewhere as subroutine

			vec3 LColor = texture(environment, L).rgb;


			/*vec2 coords = raycast(view_pos, get_view_normal(uv), Xi);
			if (coords.x <= 0 || coords.y <= 0 || coords.x >= 1 || coords.y >= 1) {} else
			{

				//vec3 light = get_albedo(coords);
				vec3 light = fColor + get_specular(coords);
				//vec3 light = texture(lua[(sampler2D)render3d.GetFinalGBufferTexture], coords).rgb;

				fColor = light;
			}*/


			// Since the sample is skewed towards the Distribution, we don't need
			// to evaluate all of the factors for the lighting equation. Also note
			// that this function is calculating the specular portion, so we absolutely
			// do not add any more diffuse here.
			fColor += F_ * G_ * LColor * VoH / (NoH * NoV);
		  }

		  // Average the results
		  return fColor / float(NumSamples);
		}

		vec3 environment()
		{
			if (get_depth(uv) == 1) {return vec3(0,0,0);}

			samplerCube tex_env = lua[tex_sky = render3d.GetSkyTexture()];
			vec3 V = get_camera_dir(uv);
			vec3 N = get_world_normal(uv);
			vec3 L = reflect(V, N);

			float NoV = saturate(dot(N, V));
			float NoL = saturate(dot(N, L));

			vec3 color = get_albedo(uv) / PI;
			vec3 irrMap = sample_tex(tex_env, -reflect(V, N), 1, 8).rgb;
			vec3 Kdiff = irrMap * color;
			vec3 Kspec = radiance(tex_env, N, V);

			return BlendMaterial(Kdiff, Kspec) * color;

			//return irrMap;
		}

		out vec3 out_color;

		void main()
		{
			out_color = environment();
		}
	]]
	})

	table.insert(PASS.Source, {
		source = [[
			out vec3 out_color;

			void main()
			{
				vec3 reflection = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;

				out_color = reflection;
				out_color += get_specular(uv);
				//out_color += reflection; // no idea if this is correct but it looks more correct..
				//out_color *= g_ssao2(uv);

				out_color += gbuffer_compute_sky(get_camera_dir(uv), get_linearized_depth(uv));
			}
		]]
	})

	render3d.AddGBufferShader(PASS)
end

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end