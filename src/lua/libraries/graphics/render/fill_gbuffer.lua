local render = ... or _G.render

local reflection_res_divider = 1

local PASS = {}

PASS.Buffers = {
	{
		name = "model",
		write = "all",
		layout =
		{
			{
				format = "rgba16f",

				albedo = "rgb",
				roughness = "a",
			},
			{
				format = "rgba16f",

				view_normal = "rgb",
				metallic = "a",
			},
		}
	},
	{
		name = "light",
		write = "self",
		layout =
		{
			{
				format = "rgba16f",

				specular = "rgb",
				shadow = "a",
			}
		},
	}
}

render.AddGlobalShaderCode([[
#extension GL_ARB_texture_query_levels: enable

vec3 MMAL(samplerCube tex, vec3 normal, vec3 reflected, float roughness)
{
	vec2 size = textureSize(tex, 0);
	float levels = textureQueryLevels(tex) - 1;
	float mx = log2(roughness * size.x + 1) / log2(size.y);

	return textureLod(tex, normalize(mix(reflected, normal, roughness)), mx * levels).rgb;
}

vec3 get_env_color()
{
	float roughness = get_roughness(uv);
	float metallic = get_metallic(uv);

	vec3 cam_dir = -get_camera_dir(uv);
	vec3 sky_normal = get_world_normal(uv);
	vec3 sky_reflect = reflect(cam_dir, sky_normal).xyz;

	vec3 irradiance = MMAL(lua[tex_sky = render.GetSkyTexture()], sky_normal, sky_reflect, -metallic+1);
	vec3 reflection = MMAL(lua[tex_sky = render.GetSkyTexture()], sky_normal, sky_reflect, roughness);

	return mix((irradiance+reflection), reflection, metallic);
}
]], "get_env_color")

render.AddGlobalShaderCode([[
float compute_light_attenuation(vec3 pos, vec3 normal, float cutoff)
{
	// calculate normalized light vector and distance to sphere light surface
	float r = lua[light_radius = 1000]/10;
	vec3 L = light_view_pos - pos;
	float distance = length(L);
	float d = max(distance - r, 0);
	L /= distance;

	float attenuation = 1;

	float denom = d/r + 1;
	attenuation = 1 / (denom*denom);

	// scale and bias attenuation such that:
	//   attenuation == 0 at extent of max influence
	//   attenuation == 1 when d == 0
	attenuation = (attenuation - cutoff) / (1 - cutoff);
	attenuation = max(attenuation, 0);

	float dot = max(dot(L, normal), 0);
	attenuation *= dot;

	return attenuation;
}
]])

render.AddGlobalShaderCode([[
const float PI = 3.14159265358979323846;

float sqr(float x) { return x*x; }

float SchlickFresnel(float u)
{
    float m = clamp(1-u, 0, 1);
    float m2 = m*m;
    return m2*m2*m; // pow(m,5)
}

float GTR1(float NdotH, float a)
{
    if (a >= 1) return 1/PI;
    float a2 = a*a;
    float t = 1 + (a2-1)*NdotH*NdotH;
    return (a2-1) / (PI*log(a2)*t);
}

float GTR2(float NdotH, float a)
{
    float a2 = a*a;
    float t = 1 + (a2-1)*NdotH*NdotH;
    return a2 / (PI * t*t);
}

float GTR2_aniso(float NdotH, float HdotX, float HdotY, float ax, float ay)
{
    return 1 / ( PI * ax*ay * sqr( sqr(HdotX/ax) + sqr(HdotY/ay) + NdotH*NdotH ));
}

float smithG_GGX(float Ndotv, float alphaG)
{
    float a = alphaG*alphaG;
    float b = Ndotv*Ndotv;
    return 1/(Ndotv + sqrt(a + b - a*b));
}

vec3 mon2lin(vec3 x)
{
    return vec3(pow(x[0], 2.2), pow(x[1], 2.2), pow(x[2], 2.2));
}


vec3 compute_specular2(
	vec3 L,
	vec3 V,
	vec3 N,
	vec3 X,
	vec3 Y,
	vec3 baseColor,
	float metallic,
	float subsurface,
	float specular,
	float roughness,
	float specularTint,
	float anisotropic,
	float sheen,
	float sheenTint,
	float clearcoat,
	float clearcoatGloss
)
{
    float NdotL = dot(N,L);
    float NdotV = dot(N,V);
   // if (NdotL < 0 || NdotV < 0) return vec3(0);

    vec3 H = normalize(L+V);
    float NdotH = dot(N,H);
    float LdotH = dot(L,H);

    vec3 Cdlin = mon2lin(baseColor);
    float Cdlum = .3*Cdlin[0] + .6*Cdlin[1]  + .1*Cdlin[2]; // luminance approx.

    vec3 Ctint = Cdlum > 0 ? Cdlin/Cdlum : vec3(1); // normalize lum. to isolate hue+sat
    vec3 Cspec0 = mix(specular*.08*mix(vec3(1), Ctint, specularTint), Cdlin, metallic);
    vec3 Csheen = mix(vec3(1), Ctint, sheenTint);

    // Diffuse fresnel - go from 1 at normal incidence to .5 at grazing
    // and mix in diffuse retro-reflection based on roughness
    float FL = SchlickFresnel(NdotL), FV = SchlickFresnel(NdotV);
    float Fd90 = 0.5 + 2 * LdotH*LdotH * roughness;
    float Fd = mix(1, Fd90, FL) * mix(1, Fd90, FV);

    // Based on Hanrahan-Krueger brdf approximation of isotropic bssrdf
    // 1.25 scale is used to (roughly) preserve albedo
    // Fss90 used to "flatten" retroreflection based on roughness
    float Fss90 = LdotH*LdotH*roughness;
    float Fss = mix(1, Fss90, FL) * mix(1, Fss90, FV);
    float ss = 1.25 * (Fss * (1 / (NdotL + NdotV) - .5) + .5);

    // specular
    float aspect = sqrt(1-anisotropic*.9);
    float ax = max(.001, sqr(roughness)/aspect);
    float ay = max(.001, sqr(roughness)*aspect);
    float Ds = GTR2_aniso(NdotH, dot(H, X), dot(H, Y), ax, ay);
    float FH = SchlickFresnel(LdotH);
    vec3 Fs = mix(Cspec0, vec3(1), FH);
    float roughg = sqr(roughness*.5+.5);
    float Gs = smithG_GGX(NdotL, roughg) * smithG_GGX(NdotV, roughg);

    // sheen
    vec3 Fsheen = FH * sheen * Csheen;

    // clearcoat (ior = 1.5 -> F0 = 0.04)
    float Dr = GTR1(NdotH, mix(.1,.001,clearcoatGloss));
    float Fr = mix(.04, 1, FH);
    float Gr = smithG_GGX(NdotL, .25) * smithG_GGX(NdotV, .25);

    return
		((1/PI) *
		mix(Fd, ss, subsurface)*Cdlin + Fsheen) *
		(1-metallic) +
		Gs*Fs/*Ds*/ +
		.25*clearcoat*Gr*Fr*Dr;
}
]], "compute_specular2")
render.AddGlobalShaderCode([[
float LightingFuncGGX_D(float dotNH, float roughness)
{
	float alpha = roughness*roughness;
	float alphaSqr = alpha*alpha;
	float pi = 3.14159f;
	float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;

	float D = alphaSqr/(pi * denom * denom);
	return D;
}

vec2 LightingFuncGGX_FV(float dotLH, float roughness)
{
	float alpha = roughness*roughness;

	// F
	float F_a, F_b;
	float dotLH5 = pow(1.0f-dotLH,5);
	F_a = 1.0f;
	F_b = dotLH5;

	// V
	float vis;
	float k = alpha/2.0f;
	float k2 = k*k;
	float invK2 = 1.0f-k2;
	vis = /*rcp*/(dotLH*dotLH*invK2 + k2);

	return vec2(F_a*vis,F_b*vis);
}

float compute_specular(vec3 N, vec3 V, vec3 L, float roughness, float F0)
{
	vec3 H = normalize(V+L);

	float dotNL = clamp(dot(N,L), 0, 1);
	float dotLH = clamp(dot(L,H), 0, 1);
	float dotNH = clamp(dot(N,H), 0, 1);

	float D = LightingFuncGGX_D(dotNH,roughness);
	vec2 FV_helper = LightingFuncGGX_FV(dotLH,roughness);

	float FV = F0*FV_helper.x + (1.0f-F0)*FV_helper.y;
	float specular = dotNL * D * FV;

	return specular;
}
]], "compute_specular")
render.AddGlobalShaderCode([[
vec3 compute_brdf(vec2 uv, vec3 light_dir, vec3 view_dir, vec3 normal)
{
	{
		return vec3(compute_specular(
			normal,
			-view_dir,
			-light_dir,
			get_roughness(uv),
			1
		));
	}
	return compute_specular2(
		light_dir,
		-view_dir,
		normal,

		normal,
		normal,


		get_albedo(uv), // albedo
		get_metallic(uv), // metallic
		1, // subsurface
		0.5, //specular

		get_roughness(uv), //roughness
		0, //specular tint

		0, //anisotropic

		0, // sheen
		0.5, // sheen tint

		0, // clearcoat
		1 // clearcoat gloss

	) * max(dot(-light_dir, normal), 0);
}]])

render.AddGlobalShaderCode([[
vec3 get_view_pos(vec2 uv)
{
	vec4 pos = g_projection_inverse * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
	return pos.xyz / pos.w;
}]])

render.AddGlobalShaderCode([[
vec3 get_world_pos(vec2 uv)
{
	vec4 pos = g_view_inverse * g_projection_inverse * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
	return pos.xyz / pos.w;
}]])

render.AddGlobalShaderCode([[
vec3 get_view_normal_from_depth(vec2 uv)
{
	const vec2 offset1 = vec2(0.0,0.001);
	const vec2 offset2 = vec2(0.001,0.0);

	float depth = texture(tex_depth, uv).r;
	float depth1 = texture(tex_depth, uv + offset1).r;
	float depth2 = texture(tex_depth, uv + offset2).r;

	vec3 p1 = vec3(offset1, depth1 - depth);
	vec3 p2 = vec3(offset2, depth2 - depth);

	vec3 normal = cross(p1, p2);
	normal.z = -normal.z;

	return normalize(normal);
}]])

render.AddGlobalShaderCode([[
vec3 get_world_normal(vec2 uv)
{
	return (-get_view_normal(uv) * mat3(g_view));
}]])

render.AddGlobalShaderCode([[
vec3 get_view_tangent(vec2 uv)
{
	vec3 norm = get_view_normal(uv);
	vec3 tang = abs(norm.x) < 0.999 ? vec3(1,0,0) : vec3(0,1,0);
	return normalize(cross(norm, tang));
}]])

render.AddGlobalShaderCode([[
vec3 get_world_tangent(vec2 uv)
{
	return normalize(-get_view_tangent(uv) * mat3(g_view));
}]])

render.AddGlobalShaderCode([[
vec3 get_view_bitangent(vec2 uv)
{
	return normalize(cross(get_view_normal(uv), get_view_tangent(uv)));
}]])

render.AddGlobalShaderCode([[
vec3 get_world_bitangent(vec2 uv)
{
	return normalize(-get_view_bitangent(uv) * mat3(g_view));
}]])

render.AddGlobalShaderCode([[
// http://www.geeks3d.com/20130122/normal-mapping-without-precomputed-tangent-space-vectors/
mat3 get_view_tbn(vec2 uv)
{
	vec3 N = (get_view_normal(uv));
	vec3 p = normalize(get_view_pos(uv));

	// get edge vectors of the pixel triangle
	vec3 dp1 = dFdx( p );
	vec3 dp2 = dFdy( p );
	vec2 duv1 = dFdx( uv );
	vec2 duv2 = dFdy( uv );

	// solve the linear system
	vec3 dp2perp = cross( dp2, N );
	vec3 dp1perp = cross( N, dp1 );
	vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
	vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;

	// construct a scale-invariant frame
	float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
	return mat3( T * invmax, B * invmax, N );
}]])

render.AddGlobalShaderCode([[
mat3 get_world_tbn(vec2 uv)
{
	mat3 tbn = get_view_tbn(uv);
	tbn[0] *= -mat3(g_view);
	tbn[1] *= -mat3(g_view);
	tbn[2] *= -mat3(g_view);
	return tbn;
}]])



--render.AddGlobalShaderCode("brdfs/disney.brdf")

function PASS:Initialize()
	local META = self.model_shader:CreateMaterialTemplate(PASS.Name)

	function META:OnBind()
		if self.NoCull or self.Translucent then
			render.SetCullMode("none")
		else
			render.SetCullMode("front")
		end
		self.SkyTexture = render.GetSkyTexture()
		self.EnvironmentProbeTexture = render.GetEnvironmentProbeTexture()
		--self.EnvironmentProbePosition = render.GetEnvironmentProbeTexture().probe:GetPosition()
	end

	META:Register()
end

function PASS:Draw3D(what, dist)
	render.UpdateSky()

	render.SetBlendMode()
	render.SetDepth(true)
	self:BeginPass("model")
		event.Call("PreGBufferModelPass")
			render.Draw3DScene(what or "models", dist)
		event.Call("PostGBufferModelPass")
	self:EndPass()

	render.SetDepth(false)
	self:BeginPass("light")
		render.SetCullMode("back")
			event.Call("Draw3DLights")
		render.SetCullMode("front")
	self:EndPass()
end

function PASS:DrawDebug(i,x,y,w,h,size)
	for name, map in pairs(prototype.GetCreated(true, "shadow_map")) do
		local tex = map:GetTexture("depth")

		surface.SetWhiteTexture()
		surface.SetColor(1, 1, 1, 1)
		surface.DrawRect(x, y, w, h)

		surface.SetColor(1,1,1,1)
		surface.SetTexture(tex)
		surface.DrawRect(x, y, w, h)

		surface.SetTextPosition(x, y + 5)
		surface.DrawText(tostring(name))

		if i%size == 0 then
			y = y + h
			x = 0
		else
			x = x + w
		end

		i = i + 1
	end

	return i,x,y,w,h
end

PASS.Stages = {
	{
		name = "model",
		vertex = {
			mesh_layout = {
				{pos = "vec3"},
				{uv = "vec2"},
				{normal = "vec3"},
				--{tangent = "vec3"},
				{texture_blend = "float"},
			},
			source = [[
				#define GENERATE_TANGENT 1

				out vec3 view_pos;

				#ifdef GENERATE_TANGENT
					out vec3 vertex_view_normal;
				#else
					out mat3 tangent_space;
				#endif

				void main()
				{
					vec4 temp = g_view_world * vec4(pos, 1.0);
					view_pos = temp.xyz;
					gl_Position = g_projection * temp;


					#ifdef GENERATE_TANGENT
						vertex_view_normal = mat3(g_normal_matrix) * normal;
					#else
						vec3 view_normal = mat3(g_normal_matrix) * normal;
						vec3 view_tangent = mat3(g_normal_matrix) * tangent;
						vec3 view_bitangent = cross(view_tangent, view_normal);

						tangent_space = mat3(view_tangent, view_bitangent, view_normal);
					#endif
				}
			]]
		},
		fragment = {
			variables = {
				NoCull = false,
			},
			mesh_layout = {
				{uv = "vec2"},
				{texture_blend = "float"},
			},
			source = [[

				#define GENERATE_TANGENT 1
				//#define DEBUG_NORMALS 1

				in vec3 view_pos;

				#ifdef GENERATE_TANGENT
					in vec3 vertex_view_normal;
					#define tangent_space cotangent_frame(vertex_view_normal, view_pos, uv)
				#else
					in mat3 tangent_space;
					#define vertex_view_normal tangent_space[2]
				#endif

				// https://www.shadertoy.com/view/MslGR8
				bool dither(vec2 uv, float alpha)
				{
					if (lua[AlphaTest = false])
					{
						return alpha*alpha < (-gl_FragDepth+1)/20;
					}

					const vec3 magic = vec3( 0.06711056, 0.00583715, 52.9829189 );
					float lol = fract( magic.z * fract( dot( gl_FragCoord.xy, magic.xy ) ) );

					return (alpha + lol) < 1;
				}

				// http://www.geeks3d.com/20130122/normal-mapping-without-precomputed-tangent-space-vectors/
				mat3 cotangent_frame(vec3 N, vec3 p, vec2 uv)
				{
					// get edge vectors of the pixel triangle
					vec3 dp1 = dFdx( p );
					vec3 dp2 = dFdy( p );
					vec2 duv1 = dFdx( uv );
					vec2 duv2 = dFdy( uv );

					// solve the linear system
					vec3 dp2perp = cross( dp2, N );
					vec3 dp1perp = cross( N, dp1 );
					vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
					vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;

					// construct a scale-invariant frame
					float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
					return mat3( T * invmax, B * invmax, N );
				}

				void main()
				{
					//{albedo = vertex_view_normal; return;}

					// albedo
					vec4 color = texture(lua[AlbedoTexture = render.GetErrorTexture()], uv);

					if (texture_blend != 0)
						color = mix(color, texture(lua[Albedo2Texture = "texture"], uv), texture_blend);

					color *= lua[Color = Color(1,1,1,1)];

					albedo = color.rgb;

					if (lua[Translucent = false])
					{
						if (dither(uv, color.a))
						{
							discard;
						}
					}



					// normals
					vec4 normal_map = texture(lua[NormalTexture = render.GetBlackTexture()], uv);

					if (normal_map.xyz != vec3(0))
					{
						if (texture_blend != 0)
						{
							normal_map = mix(normal_map, texture(lua[Normal2Texture = "texture"], uv), texture_blend);
						}

						if (lua[SSBump = false])
						{
							// this is so wrong
							normal_map.xyz = normalize(pow((normal_map.xyz*0.1 + vec3(0,0,1)), vec3(0.1)));
						}

						if (lua[FlipYNormal = false])
						{
							normal_map.rgb = normal_map.rgb * vec3(1, -1, 1) + vec3(0, 1, 0);
						}

						if (lua[FlipXNormal = false])
						{
							normal_map.rgb = normal_map.rgb * vec3(-1, 1, 1) + vec3(1, 0, 0);
						}

						normal_map.xyz = /*normalize*/(normal_map.xyz * 2 - 1).xyz;

						view_normal = tangent_space * normal_map.xyz;
					}
					else
					{
						view_normal = vertex_view_normal;
					}

					view_normal = normalize(view_normal);

					// metallic
					if (lua[NormalAlphaMetallic = false])
					{
						metallic = normal_map.a;
					}
					else if (lua[AlbedoAlphaMetallic = false])
					{
						metallic = -color.a+1;
					}
					else
					{
						metallic = texture(lua[MetallicTexture = render.GetBlackTexture()], uv).r;
					}



					// roughness
					roughness = texture(lua[RoughnessTexture = render.GetBlackTexture()], uv).r;


					//generate roughness and metallic they're zero
					if (roughness == 0)
					{
						if (metallic != 0)
						{
							roughness = pow(-metallic+1, 0.25)/1.5;
						}
						else
						{
							roughness = 0.98;//max(pow((-(length(albedo)/3) + 1), 5), 0.9);
							//albedo *= pow(roughness, 0.5);
						}

						if (metallic == 0)
						{
							metallic = min((-roughness+1)/1.5, 0.075);
						}
					}


					metallic *= lua[MetallicMultiplier = 1];
					roughness *= lua[RoughnessMultiplier = 1];
					specular = vec3(0,0,0);
				}
			]]
		}
	},
	{
		name = "light",
		vertex = {
			mesh_layout = {
				{pos = "vec3"},
			},
			source = "gl_Position = g_projection_view_world * vec4(pos*0.5, 1);"
		},
		fragment = {
			variables = {
				light_view_pos = Vec3(0,0,0),
				light_color = Color(1,1,1,1),
				light_intensity = 0.5,
			},
			source = [[
				vec2 uv = get_screen_uv();

				float get_shadow_(vec2 uv)
				{
					float visibility = 0;

					if (lua[light_point_shadow = false])
					{
						vec3 light_dir = (get_view_pos(uv)*0.5+0.5) - (light_view_pos*0.5+0.5);
						vec3 dir = normalize(light_dir) * mat3(g_view);
						dir.z = -dir.z;


						float shadow_view = texture(lua[tex_shadow_map_cube = render.GetSkyTexture()], dir.xzy).r;

						visibility = shadow_view;
					}
					else
					{
						vec4 proj_inv = g_projection_view_inverse * vec4(uv * 2 - 1, texture(tex_depth, uv).r * 2 - 1, 1.0);

							]] .. (function()
								local code = ""
								for i = 1, render.csm_count do
									local str = [[
									{
										vec4 temp = light_projection_view * proj_inv;
										vec3 shadow_coord = temp.xyz / temp.w;

										if (
											shadow_coord.x >= -0.9 &&
											shadow_coord.x <= 0.9 &&
											shadow_coord.y >= -0.9 &&
											shadow_coord.y <= 0.9 &&
											shadow_coord.z >= -0.9 &&
											shadow_coord.z <= 0.9
										)
										{
											shadow_coord = 0.5 * shadow_coord + 0.5;

											visibility = (shadow_coord.z - texture(tex_shadow_map, shadow_coord.xy).r);
										}
										]]..(function()
											if i == 1 then
												return [[else if(lua[project_from_camera = false])
												{
													visibility = 0;
												}]]
											end
											return ""
										end)()..[[
									}
									]]
									str = str:gsub("tex_shadow_map", "lua[tex_shadow_map_" .. i .." = \"sampler2D\"]")
									str = str:gsub("light_projection_view", "lua[light_projection_view_" .. i .. " = \"mat4\"]")
									code = code .. str
								end
								return code
							end)() .. [[
					}

					return visibility;
				}

				void main()
				{

					vec3 pos = get_view_pos(uv);
					vec3 normal = get_view_normal(uv);

					float attenuation = 1;

					if (!lua[project_from_camera = false])
					{
						attenuation = compute_light_attenuation(pos, normal, 0.175);
					}

					specular = compute_brdf(
						uv,
						normalize(pos - light_view_pos),
						normalize(pos),
						normal
					)*attenuation*light_intensity*light_color.rgb*5;

					if (lua[light_shadow = false])
					{
						shadow = get_shadow_(uv);
					}
				}
			]]
		}
	},
}

local TESSELLATION = false

if TESSELLATION then
	PASS.Stages[1].vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{normal = "vec3"},
			--{tangent = "vec3"},
			{texture_blend = "float"},
		},
		source = [[
			#version 420
			out vec3 vPosition;
			out vec2 vTexCoord;
			out vec3 vNormal;
			out float vTextureBlend;

			void main() {
				vPosition = pos;
				vTexCoord = uv;
				vNormal = normal;
				vTextureBlend = texture_blend;
			}
		]]
	}
	PASS.Stages[1].tess_control = {
		source = [[
			#version 420
			layout(vertices = 3) out;

			in vec3 vPosition[];
			in vec2 vTexCoord[];
			in vec3 vNormal[];
			in float vTextureBlend[];

			out vec2 tcTexCoord[];
			out vec3 tcPosition[];
			out vec3 tcNormal[];
			out float tcTextureBlend[];

			void main()
			{
				tcTexCoord[gl_InvocationID] = vTexCoord[gl_InvocationID];
				tcPosition[gl_InvocationID] = vPosition[gl_InvocationID];
				tcNormal[gl_InvocationID] = vNormal[gl_InvocationID];
				tcTextureBlend[gl_InvocationID] = tcTextureBlend[gl_InvocationID];

				if(gl_InvocationID == 0)
				{
					float inTess  = lua[innerTessLevel = 10];
					float outTess = lua[outerTessLevel = 10];

					inTess = 16;
					outTess = 16;

					gl_TessLevelInner[0] = inTess;
					gl_TessLevelInner[1] = inTess;
					gl_TessLevelOuter[0] = outTess;
					gl_TessLevelOuter[1] = outTess;
					gl_TessLevelOuter[2] = outTess;
					gl_TessLevelOuter[3] = outTess;
				}
			}
		]],
	}
	PASS.Stages[1].tess_evaluation = {
		source = [[
			#version 420
			layout(triangles, equal_spacing, ccw) in;

			in vec3 tcPosition[];
			in vec2 tcTexCoord[];
			in vec3 tcNormal[];
			in float tcTextureBlend[];

			out vec3 tePosition;
			out vec2 teTexCoord;
			out vec3 teNormal;
			out float teTextureBlend;

			void main()
			{
				vec3 p0 = gl_TessCoord.x * tcPosition[0];
				vec3 p1 = gl_TessCoord.y * tcPosition[1];
				vec3 p2 = gl_TessCoord.z * tcPosition[2];
				vec3 pos = p0 + p1 + p2;

				vec2 tc0 = gl_TessCoord.x * tcTexCoord[0];
				vec2 tc1 = gl_TessCoord.y * tcTexCoord[1];
				vec2 tc2 = gl_TessCoord.z * tcTexCoord[2];
				teTexCoord = tc0 + tc1 + tc2;

				vec3 n0 = gl_TessCoord.x * tcNormal[0];
				vec3 n1 = gl_TessCoord.y * tcNormal[1];
				vec3 n2 = gl_TessCoord.z * tcNormal[2];
				vec3 normal = normalize(n0 + n1 + n2);
				teNormal = mat3(g_normal_matrix) * normal;

				teTextureBlend = (tcTextureBlend[0] + tcTextureBlend[1] + tcTextureBlend[2]) / 3;

				float height = texture(lua[HeightTexture = render.CreateTextureFromPath("https://upload.wikimedia.org/wikipedia/commons/5/57/Heightmap.png")], teTexCoord).x;
				pos += normal * (height * 0.5f);

				vec4 temp = g_view_world * vec4(pos, 1.0);
				tePosition = temp.xyz;
				gl_Position = g_projection * temp;

			}
		]],
	}
	PASS.Stages[1].geometry = {
		source = [[
			#version 420
			layout (triangles) in;
			layout (triangle_strip) out;
			layout (max_vertices = 3) out;

			in vec3 tePosition[3];
			in vec2 teTexCoord[3];
			in vec3 teNormal[3];
			in float teTextureBlend[3];

			out vec2 gTexCoord;
			out float gTextureBlend;

			out vec3 gPosition;
			out vec3 gFacetNormal;

			void main()
			{
				for ( int i = 0; i < gl_in.length(); i++)
				{
					gTexCoord = teTexCoord[i];
					gPosition = tePosition[i];
					gFacetNormal = vec3(1,0,0);//teNormal[i];
					gTextureBlend = teTextureBlend[i];
					gl_Position = gl_in[i].gl_Position;
					EmitVertex();
				}

				EndPrimitive();
			}
		]],
	}

	PASS.Stages[1].fragment.mesh_layout = nil

	PASS.Stages[1].fragment.source = [[
		#version 420
		//in vec3 pos;
		in vec2 uv;
		//in vec3 normal;
		//in vec3 tangent;
		in float texture_blend;
	]]
	.. PASS.Stages[1].fragment.source

	if RELOAD then
		for mesh in pairs(prototype.GetCreated()) do
			if mesh.Type == "mesh_builder" then
				mesh.mesh:SetMode("patches")
			end
		end
	end
elseif RELOAD then
	for mesh in pairs(prototype.GetCreated()) do
		if mesh.Type == "mesh_builder" then
			mesh.mesh:SetMode("triangles")
		end
	end
end

render.gbuffer_fill = PASS
if RELOAD then
	render.InitializeGBuffer()
end

do
	local PASS = {}

	PASS.Position = -1
	PASS.Name = "reflection_merge"
	PASS.Default = true

	PASS.Source = {}

	table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			size_divider = reflection_res_divider,
			internal_format = "rgb16f",
			mip_maps = 0,
		},
		source = [[
		#extension GL_ARB_texture_query_levels: enable
		out vec3 out_color;

		vec3 project(vec3 coord)
		{
			vec4 res = g_projection * vec4(coord, 1.0);
			return (res.xyz / res.w) * 0.5 + 0.5;
		}

		void main()
		{
			if (texture(tex_depth, uv).r == 1)
			{
				return;
			}

			out_color.rgb = get_env_color();

			vec3 view_pos = get_view_pos(uv);
			vec3 normal = get_view_normal(uv);

			vec3 view_dir = normalize(view_pos);
			vec3 view_reflect = reflect(view_dir, normal);
			vec3 screen_pos = project(view_pos);
			vec3 screen_reflect = normalize(project(view_pos + view_reflect) - screen_pos);
			screen_reflect *= 0.005;

			vec3 old_pos = screen_pos + screen_reflect;
			vec3 cur_pos = old_pos + screen_reflect;

			float refinements = 0;

			for (float i = 0; i < 100; i++)
			{
				if(
					cur_pos.x < 0 || cur_pos.x > 1 ||
					cur_pos.y < 0 || cur_pos.y > 1 ||
					cur_pos.z < 0 || cur_pos.z > 1
				)
				break;

				float diff = cur_pos.z - texture(tex_depth, cur_pos.xy).x;

				if(diff > 0.000025 && diff < 0.00025)
				{
					if(refinements >= 2)
					{
						vec2 device_coord = abs(vec2(0.5, 0.5) - cur_pos.xy);
						float fade = clamp(1.0 - (device_coord.x + device_coord.y) * 1.8, 0.0, 1.0);

						out_color.rgb = texture(lua[(sampler2D)render.GetFinalGBufferTexture], cur_pos.xy).rgb;
						//out_color.rgb = get_albedo(cur_pos.xy);
						break;
					}

					screen_reflect *= 0.75;
					cur_pos = old_pos;
					refinements++;
				}

				old_pos = cur_pos;
				cur_pos += screen_reflect;
			}

		}
	]]})

	local function blur(source, format, discard, divider)
		local AUTOMATE_ME = {
			[-7] = 0.0044299121055113265,
			[-6] = 0.00895781211794,
			[-5] = 0.0215963866053,
			[-4] = 0.0443683338718,
			[-3] = 0.0776744219933,
			[-2] = 0.115876621105,
			[-1] = 0.147308056121,
			[1] = 0.147308056121,
			[2] = 0.115876621105,
			[3] = 0.0776744219933,
			[4] = 0.0443683338718,
			[5] = 0.0215963866053,
			[6] = 0.00895781211794,
			[7] = 0.0044299121055113265,
		}

		local discard_threshold = discard

		for i = 0, 1 do
			local x = i == 0 and 0 or 1
			local y = i == 0 and 1 or 0
			local stage = #PASS.Source

			local str = [[
				out vec3 out_color;
				void main()
				{
					float amount = ]]..source..[[ / get_depth(uv) / length(g_gbuffer_size) * 1;
					//amount = min(amount, 0.25);
					amount += random(uv)*0.5*amount;

					vec3 normal = normalize(get_view_normal(uv));

					float total_weight = 0;
					out_color = texture(tex_stage_]]..stage..[[, uv).rgb*0.159576912161;
			]]

			for i = -7, 7 do
				if i ~= 0 then
					local weight = i * 4 / 1000
					local offset = "uv + vec2("..(x*weight)..", "..(y*weight)..") * amount"
					local fade = AUTOMATE_ME[i]

					str = str .. "\tif(dot(normalize(get_view_normal("..offset..")), normal) > "..discard_threshold..")\n"
					str = str .. "\t{\n"
					str = str .. "\t\tout_color += texture(tex_stage_"..stage..", "..offset..").rgb *"..fade..";\n"
					str = str .. "\t}else{total_weight += "..(fade)..";}\n"
				end
			end

			str = str .. "\tout_color += texture(tex_stage_"..stage..", uv).rgb*total_weight;\n"
			str = str .. "}"

			table.insert(PASS.Source, {
				buffer = {
					size_divider = divider or reflection_res_divider,
					internal_format = format or "rgb16f",
				},
				source = str,
			})

			::continue::
		end
	end

	blur("get_roughness(uv)*20", "rgb16f", 0.95)
	blur("get_roughness(uv)*15", "rgb16f", 0.95)
	blur("get_roughness(uv)*10", "rgb16f", 0.95)
	blur("get_roughness(uv)", "rgb16f", 0.95)

	table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			internal_format = "r16f",
		},
		source =  [[
			const vec2 KERNEL[16] = vec2[](vec2(0.53812504, 0.18565957), vec2(0.13790712, 0.24864247), vec2(0.33715037, 0.56794053), vec2(-0.6999805, -0.04511441), vec2(0.06896307, -0.15983082), vec2(0.056099437, 0.006954967), vec2(-0.014653638, 0.14027752), vec2(0.010019933, -0.1924225), vec2(-0.35775623, -0.5301969), vec2(-0.3169221, 0.106360726), vec2(0.010350345, -0.58698344), vec2(-0.08972908, -0.49408212), vec2(0.7119986, -0.0154690035), vec2(-0.053382345, 0.059675813), vec2(0.035267662, -0.063188605), vec2(-0.47761092, 0.2847911));
			const float SAMPLE_RAD = 0.4;
			const float INTENSITY = 0.25;
			const float ITERATIONS = 32;

			float ssao(void)
			{
				vec3 p = get_view_pos(uv)*0.995;
				vec3 n = (get_view_normal(uv));
				vec2 rand = get_noise(uv).xy;

				float occlusion = 0.0;
				float depth = get_depth(uv);

				for(float j = 0; j < ITERATIONS; ++j)
				{
					vec2 offset = uv + (reflect(KERNEL[int(j)], rand) / depth / g_cam_farz * SAMPLE_RAD);

					vec3 diff = get_view_pos(offset) - p;
					float d = length(diff);
					float a = dot(n, diff);

					if (d < 1 && a > 0)
					{
						occlusion += a+d;
					}
				}

				return 1-clamp(occlusion*INTENSITY, 0, 1);
			}

			out float out_color;

			void main()
			{
				float shadow = get_shadow(uv) > 0.00025 ? 0.25 : 1;

				out_color = shadow * (min(ssao() + 0.25, 1));
				//out_color = pow(mix(1, out_color, pow(get_roughness(uv), 0.25)), 2);
			}
		]]
	})

	blur("get_shadow(uv)*2", "r16f", 0.9, 1)

	table.insert(PASS.Source, {
		source =  [[
			out vec3 out_color;

			void main()
			{
				vec3 reflection = texture(tex_stage_]]..(#PASS.Source-3)..[[, uv).rgb;
				if (texture(tex_depth, uv).r == 1)
				{
					out_color = get_sky(-get_camera_dir(uv).xzy*vec3(1,1,-1), 1);
					return;
				}

				float roughness = get_roughness(uv);
				float shadow = texture(tex_stage_]]..(#PASS.Source)..[[, uv).r;
				vec3 albedo = get_albedo(uv);

				vec3 specular = get_specular(uv);

				reflection += 0.5 * reflection * pow(1.0 - -min(dot(get_view_normal(uv), normalize(get_view_pos(uv))), 0.0), 2.0);
//				reflection *= -roughness+1;


				vec3 light = specular;
				light *= shadow;
				light += reflection*albedo;

				vec3 fog = get_sky(-get_view_pos(uv).xzy, get_depth(uv));

				out_color = albedo * light + fog;

			}
		]]
	})

	render.AddGBufferShader(PASS)

	if RELOAD then
		PASS:__init()
	end

	function render.GetFinalGBufferTexture()
		return render.gbuffer_mixer_buffer:GetTexture()
	end
end

if RELOAD then
	collectgarbage()
end