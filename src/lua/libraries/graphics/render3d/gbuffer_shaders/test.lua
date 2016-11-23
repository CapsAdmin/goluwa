include("lua/libraries/graphics/render3d/sky_shaders/atmosphere2.lua")

render.AddGlobalShaderCode([[
float gbuffer_compute_light_attenuation(vec3 pos, vec3 light_pos, float radius, vec3 normal)
{
	float cutoff = 0.175;

	// calculate normalized light vector and distance to sphere light render2d
	float r = radius/10;
	vec3 L = light_pos - pos;
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
	float subrender2d,
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
		mix(Fd, ss, subrender2d)*Cdlin + Fsheen) *
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
	float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;

	float D = alphaSqr/(PI * denom * denom);
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
vec3 gbuffer_compute_specular(vec3 light_dir, vec3 view_dir, vec3 normal, float attenuation, vec3 light_color)
{
	vec2 uv = get_screen_uv();

	{
		return vec3(compute_specular(
			normal,
			-view_dir,
			-light_dir,
			get_roughness(uv),
			1
		))*attenuation*light_color*5;
	}
	return compute_specular2(
		light_dir,
		-view_dir,
		normal,

		normal,
		normal,


		get_albedo(uv), // albedo
		get_metallic(uv), // metallic
		1, // subrender2d
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

local PASS = {}

PASS.Position = -1
PASS.Name = "test"
PASS.Default = true

PASS.Source = {}

table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			size_divider = 1,
			internal_format = "r11f_g11f_b10f",
		},
		source = [[
		out vec3 out_color;

		void main()
		{

			vec2 coords = g_raycast(uv, 0.01, 30);

			vec3 sky = texture(lua[sky_tex = render3d.GetSkyTexture()], -reflect(get_camera_dir(uv), get_world_normal(uv))).rgb;

			if (coords.x <= 0 || coords.y <= 0 || coords.x >= 1 || coords.y >= 1)
			{
				out_color = sky;
			}
			else
			{
				vec3 light = get_albedo(coords) * (sky + get_specular(uv));
				light += texture(lua[(sampler2D)render3d.GetFinalGBufferTexture], coords).rgb/5;

				//vec2 dCoords = abs(vec2(0.5, 0.5) - coords);
				//float fade = clamp(1.0 - (dCoords.x + dCoords.y), 0.0, 1.0);

				//out_color = mix(sky, light, fade);

				out_color = light;
			}
		}
	]]
})

render3d.AddBilateralBlurPass(PASS, "pow(get_roughness(uv)*0.12, 1.5)", 0.98, "r11f_g11f_b10f", 1)

table.insert(PASS.Source, {
	source =  [[
		out vec3 out_color;

		void main()
		{
			vec3 reflection = texture(tex_stage_]]..(#PASS.Source-1)..[[, uv).rgb*2;
			if (texture(tex_depth, uv).r == 1)
			{
				out_color = gbuffer_compute_sky(get_camera_dir(uv), 1);
				return;
			}

			float roughness = get_roughness(uv);
			float shadow = texture(tex_stage_]]..(#PASS.Source)..[[, uv).r;
			vec3 albedo = get_albedo(uv);

			vec3 specular = get_specular(uv)*g_ssao(uv);

			reflection += 0.5 * reflection * pow(1.0 - -min(dot(get_view_normal(uv), normalize(get_view_pos(uv))), 0.0), 2.0);
			//reflection *= -roughness+1;


			vec3 light = specular;
			//light += shadow;
			light += (reflection)*albedo;

			vec3 fog = gbuffer_compute_sky(get_view_pos(uv), get_linearized_depth(uv));

			out_color = albedo * light + fog;
			out_color *= 5;
		}
	]]
})

render3d.AddGBufferShader(PASS)

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end