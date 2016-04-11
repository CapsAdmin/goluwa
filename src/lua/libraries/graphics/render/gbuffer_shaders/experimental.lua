render.AddGlobalShaderCode([[
float compute_light_attenuation(vec3 pos, vec3 light_pos, float radius, vec3 normal)
{
	float cutoff = 0.175;

	// calculate normalized light vector and distance to sphere light surface
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