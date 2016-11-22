--https://github.com/TReed0803/QtOpenGL/blob/master/resources/shaders/lighting/Physical.glsl

render.AddGlobalShaderCode([[
float handle_roughness(float x)
{
	return max(x*x, 0.0025);
}]])

render.AddGlobalShaderCode([[
float handle_metallic(float x)
{
	return max(x*2, 0.00025);
}]])

render.AddGlobalShaderCode([[
vec3 Reinhard(vec3 color)
{
  return color / (color + vec3(1.0));
}

vec3 HejlDawson(vec3 color)
{
  vec3 x = max(vec3(0.0),color-vec3(0.004));
  return (x*(6.2*x+.5))/(x*(6.2*x+1.7)+0.06);
}

vec3 _Uncharted(vec3 x)
{
  const float A = 0.15;
  const float B = 0.50;
  const float C = 0.10;
  const float D = 0.20;
  const float E = 0.02;
  const float F = 0.30;
  const float W = 11.2;
  return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

vec3 Uncharted(vec3 color)
{
  const float W = 11.2;
  const float ExposureBias = 2.0f;
  return _Uncharted(ExposureBias*color) / _Uncharted(vec3(W));
}

vec3 gbuffer_compute_tonemap(vec3 color, vec3 bloom)
{
	return HejlDawson(color);
}]])
include("lua/libraries/graphics/render3d/sky_shaders/atmosphere1.lua")
--[==[render.AddGlobalShaderCode([[
vec3 gbuffer_compute_sky(vec3 ray, float depth)
{
	depth = depth < 1 ? 0 : 1;
	vec3 res = textureLatLon(lua[nightsky_tex = render.CreateTextureFromPath("textures/skybox/hdr/power_plant.hdr")], ray.xzy * vec3(1,-1,1)).rgb*depth;

	res = pow(res, vec3(0.75))*3;
//	res += res*vec3(length(pow(res, vec3(5))));

	return res;
}]])]==]

render.AddGlobalShaderCode([[
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
	return max(Brdf(get_albedo(get_screen_uv()), light_color*attenuation, l,v,-n), vec3(0));
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
vec3 DGSmpl(vec2 random)
{
  return DGgxSample(random);
}]])

render.AddGlobalShaderCode([[
float Fd90(float NoL)
{
  return 2.0 * NoL * get_roughness(get_screen_uv()) + 0.4;
}

float KDisney(float NoL, float NoV)
{
  return (1.0 + Fd90(NoL) * pow(1.0 - NoL, 5.0)) *
         (1.0 + Fd90(NoV) * pow(1.0 - NoV, 5.0));
}
// Note: For some reason, possibly a driver error, I cannot create a subroutine
//       for this term. Hopefully after an update I will be able to do so.
float K(float NoL, float NoV)
{
  return KDisney(NoL, NoV);
}]])

render.AddGlobalShaderCode([[
float Pdf(float NoL, float NoV)
{
  return (4.0 * NoL * NoV);
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
	float scRange = smoothstep(0.25, 0.45, get_metallic(get_screen_uv()));
	vec3  dielectric = BlendDielectric(Kdiff, Kspec, Kbase);
	vec3  metal = BlendMetal(Kdiff, Kspec, Kbase);
	return mix(dielectric, metal, scRange);
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
		out vec3 out_color;

		#define XAxis vec3(1.0, 0.0, 0.0)
		#define YAxis vec3(0.0, 1.0, 0.0)
		#define ZAxis vec3(0.0, 0.0, 1.0)
		#define KWhite vec3(1.0, 1.0, 1.0)

		float compute_lod(samplerCube tex, uint NumSamples, float NoH)
		{
			vec2 Dimensions = textureSize(tex, 0);
			return 0.5 * (log2(float(Dimensions.x * Dimensions.y) / NumSamples) - log2(Distribution(NoH)));
		}

		vec3 radiance(samplerCube environment, vec3 N, vec3 V)
		{
		  // Precalculate rotation for +Z Hemisphere to microfacet normal.
		  vec3 UpVector = abs(N.z) < 0.999 ? ZAxis : XAxis;
		  vec3 TangentX = normalize(cross( UpVector, N ));
		  vec3 TangentY = cross(N, TangentX);

		  // Note: I ended up using abs() for situations where the normal is
		  // facing a little away from the view to still accept the approximation.
		  // I believe this is due to a separate issue with normal storage, so
		  // you may only need to saturate() each dot value instead of abs().
		  float NoV = abs(dot(N, V));

		  // Approximate the integral for lighting contribution.
		  vec3 fColor = vec3(0.0);
		  const uint NumSamples = 20;
		  for (uint i = 0; i < NumSamples; ++i)
		  {
			vec2 Xi = hammersley_2d(i, NumSamples);
			vec3 Li = DGSmpl(Xi); // Defined elsewhere as subroutine
			vec3 H  = normalize(Li.x * TangentX + Li.y * TangentY + Li.z * N);
			vec3 L  = normalize(-reflect(V, H));

			// Calculate dot products for BRDF
			float NoL = abs(dot(N, L));
			float NoH = abs(dot(N, H));
			float VoH = abs(dot(V, H));
			float lod = compute_lod(environment, NumSamples, NoH);

			float F_ = Fresnel(VoH); // Defined elsewhere as subroutine
			float G_ = Geometry(NoL, NoV, NoH, VoH); // Defined elsewhere as subroutine

			vec3 LColor = textureLod(environment, L.xzy*vec3(1,-1,1), lod).rgb;

			// Since the sample is skewed towards the Distribution, we don't need
			// to evaluate all of the factors for the lighting equation. Also note
			// that this function is calculating the specular portion, so we absolutely
			// do not add any more diffuse here.
			fColor += F_ * G_ * LColor * VoH / (NoH * NoV);
		  }

		  // Average the results
		  return fColor / float(NumSamples);
		}

		void main()
		{
			if (get_depth(uv) == 1) {return;}

			samplerCube tex_env = lua[tex_sky = render3d.GetSkyTexture()];
			vec3 V = get_camera_dir(uv);
			vec3 N = get_world_normal(uv);
			vec3 L = reflect(V, N);

			float NoV = saturate(dot(N, V));
			float NoL = saturate(dot(N, L));

			vec3 irrMap = textureLod(tex_env, reflect(N, L).xzy*vec3(1,-1,1), 100).rgb;
			vec3 Kdiff = irrMap * get_albedo(uv) / PI;
			vec3 Kspec = radiance(tex_env, N, V);

			out_color = BlendMaterial(Kdiff, Kspec);
		}
	]]
	})

	table.insert(PASS.Source, {
		source = [[
			out vec3 out_color;

			void main()
			{
				vec3 reflection = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;

				out_color = reflection+get_specular(uv)*g_ssao(uv);
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