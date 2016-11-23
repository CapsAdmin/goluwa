local REFLECTIONS_ONLY = false

include("lua/libraries/graphics/render3d/sky_shaders/atmosphere1.lua")

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_specular(vec3 L, vec3 V, vec3 N, float attenuation, vec3 light_color)
{
	vec2 uv = get_screen_uv();
	L = -L;
	V = -V;
	float F0 = 0.25;
	float roughness = get_roughness(uv);
	float alpha = roughness*roughness;
	vec3 H = normalize(V+L);
	float dotNL = clamp(dot(N,L), 0, 1);
	float dotLH = clamp(dot(L,H), 0, 1);
	float dotNH = clamp(dot(N,H), 0, 1);
	float F, D, vis;
	// D
	float alphaSqr = alpha*alpha;
	float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;
	D = alphaSqr/(PI * denom * denom);
	// F
	float dotLH5 = pow(1.0f-dotLH,5);
	F = F0 + (1.0-F0)*(dotLH5);
	// V
	float k = alpha/2.0f;
	float k2 = k*k;
	float invK2 = 1.0f-k2;
	vis = (dotLH*dotLH*invK2 + k2);

	vec3 atn = light_color * attenuation;

	return vec3(dotNL * D * F * vis) * atn*30;
}
]])

do
	local PASS = {}

	PASS.Position = 1
	PASS.Name = "complex"

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
				light += texture(lua[(sampler2D)render3d.GetFinalGBufferTexture], coords).rgb/2;

				//vec2 dCoords = abs(vec2(0.5, 0.5) - coords);
				//float fade = clamp(1.0 - (dCoords.x + dCoords.y), 0.0, 1.0);

				//out_color = mix(sky, light, fade);

				out_color = light;
			}
		}
	]]
	})

	if REFLECTIONS_ONLY then
		render3d.AddGBufferShader(PASS)

		if RELOAD then
			RELOAD = nil
			render3d.Initialize()
		end
		return
	end

	render3d.AddBilateralBlurPass(PASS, "pow(get_roughness(uv)*0.12, 1.5)", 0.98, "r11f_g11f_b10f", 1)
	--, 0.001) -- depth testing is more accurate but much slower

	table.insert(PASS.Source, {
		source = [[
			out vec3 out_color;

			void main()
			{
				vec3 reflection = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;
				float metallic = get_metallic(uv);
				vec3 albedo = get_albedo(uv);

				vec3 specular = get_specular(uv)*g_ssao(uv);
				specular = mix(specular, reflection, pow(metallic, 0.5));

				out_color = albedo * specular;
				out_color += gbuffer_compute_sky(get_camera_dir(uv), get_linearized_depth(uv));

				out_color *= 3;
			}
		]]
	})

	render3d.AddGBufferShader(PASS)
end

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end