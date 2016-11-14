
render.AddGlobalShaderCode([[
#define iSteps 16
#define jSteps 1

float rsi(vec3 r0, vec3 rd, float sr) {
    // Simplified ray-sphere intersection that assumes
    // the ray starts inside the sphere and that the
    // sphere is centered at the origin. Always intersects.
    float a = dot(rd, rd);
    float b = 2.0 * abs(dot(rd, r0));
    float c = dot(r0, r0) - (sr * sr);
    return (-b + sqrt((b*b) - 4.0*a*c))/(2.0*a);
}

vec3 atmosphere(vec3 r, vec3 r0, vec3 pSun, float iSun, float rPlanet, float rAtmos, vec3 kRlh, float kMie, float shRlh, float shMie, float g) {
    // Normalize the sun and view directions.
    pSun = normalize(pSun);
    r = normalize(r);

    // Calculate the step size of the primary ray.
    float iStepSize = rsi(r0, r, rAtmos) / float(iSteps);

    // Initialize the primary ray time.
    float iTime = 0.0;

    // Initialize accumulators for Rayleigh and Mie scattering.
    vec3 totalRlh = vec3(0,0,0);
    vec3 totalMie = vec3(0,0,0);

    // Initialize optical depth accumulators for the primary ray.
    float iOdRlh = 0.0;
    float iOdMie = 0.0;

    // Calculate the Rayleigh and Mie phases.
    float mu = dot(r, pSun);
    float mumu = mu * mu;
    float gg = g * g;
    float pRlh = 3.0 / (16.0 * PI) * (1.0 + mumu);
    float pMie = 3.0 / (8.0 * PI) * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

    // Sample the primary ray.
    for (int i = 0; i < iSteps; i++) {

        // Calculate the primary ray sample position.
        vec3 iPos = r0 + r * (iTime + iStepSize * 0.5);

        // Calculate the height of the sample.
        float iHeight = length(iPos) - rPlanet;

        // Calculate the optical depth of the Rayleigh and Mie scattering for this step.
        float odStepRlh = exp(-iHeight / shRlh) * iStepSize;
        float odStepMie = exp(-iHeight / shMie) * iStepSize;

        // Accumulate optical depth.
        iOdRlh += odStepRlh;
        iOdMie += odStepMie;

        // Calculate the step size of the secondary ray.
        float jStepSize = rsi(iPos, pSun, rAtmos) / float(jSteps);

        // Initialize the secondary ray time.
        float jTime = 0.0;

        // Initialize optical depth accumulators for the secondary ray.
        float jOdRlh = 0.0;
        float jOdMie = 0.0;

        // Sample the secondary ray.
        for (int j = 0; j < jSteps; j++) {

            // Calculate the secondary ray sample position.
            vec3 jPos = iPos + pSun * (jTime + jStepSize * 0.5);

            // Calculate the height of the sample.
            float jHeight = length(jPos) - rPlanet;

            // Accumulate the optical depth.
            jOdRlh += exp(-jHeight / shRlh) * jStepSize;
            jOdMie += exp(-jHeight / shMie) * jStepSize;

            // Increment the secondary ray time.
            jTime += jStepSize;
        }

        // Calculate attenuation.
        vec3 attn = exp(-(kMie * (iOdMie + jOdMie) + kRlh * (iOdRlh + jOdRlh)));

        // Accumulate scattering.
        totalRlh += odStepRlh * attn;
        totalMie += odStepMie * attn;

        // Increment the primary ray time.
        iTime += iStepSize;

    }
	vec3 influence = texture(lua[sky_tex = steam.GetSkyTexture()], r).rgb;

    // Calculate and return the final color.
    return iSun * (pRlh * influence * kRlh * totalRlh + pMie * kMie * totalMie);
}

vec3 gbuffer_compute_sky(vec3 ray, float depth)
{

	vec3 sun_direction = lua[(vec3)render3d.GetShaderSunDirection];
	float intensity = lua[world_sun_intensity = 1];

	vec3 stars = textureLatLon(lua[nightsky_tex = render.CreateTextureFromPath("textures/skybox/milkyway.jpg")], reflect(ray, sun_direction)).rgb;
	stars += pow(stars*1.25, vec3(1.5));
	stars *= depth * 0.005;

	return depth*max(atmosphere(
		normalize(ray),         		// normalized ray direction
        g_cam_pos.xzy + vec3(0,6372e3,0),               // ray origin
        vec3(sun_direction.x, sun_direction.y, sun_direction.z),					// position of the sun
		15.0*intensity,                           // intensity of the sun
        6371e3,                         // radius of the planet in meters
        6471e3,                         // radius of the atmosphere in meters
        vec3(5.5e-6, 13.0e-6, 22.4e-6), // Rayleigh scattering coefficient
        21e-6,                          // Mie scattering coefficient
        8e3,                            // Rayleigh scale height
        1.2e3,                          // Mie scale height
        0.758                           // Mie preferred scattering direction
	), vec3(0))+stars;
}]])


render.AddGlobalShaderCode([[
vec3 gbuffer_compute_tonemap(vec3 color, vec3 bloom)
{
	float gamma = 1.1;
	float exposure = 1.1;
	float bloom_factor = 0.0005;
	float brightMax = 1;

	color = color + bloom * bloom_factor;

	color = pow(color, vec3(1. / gamma));
	color = clamp(exposure * color, 0., 1.);

	//color = max(vec3(0.), color - vec3(0.004));
	color = exp( -1.0 / ( 2.72*color + 0.15 ) );
	color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);

	return color;
}
]])

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

			vec3 sky = texture(lua[sky_tex = render3d.GetSkyTexture()], -reflect(get_camera_dir(uv), get_world_normal(uv)).yzx).rgb;

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
				out_color = gbuffer_compute_sky(-get_camera_dir(uv).xzy*vec3(1,1,-1), 1);
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

			vec3 fog = gbuffer_compute_sky(-get_view_pos(uv).xzy, get_linearized_depth(uv));

			out_color = albedo * light + fog;
			out_color *= 2;
		}
	]]
})

render3d.AddGBufferShader(PASS)

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end