render.AddGlobalShaderCode([[
vec3 gbuffer_compute_sky(vec3 ray, float depth)
{
	vec3 dir = lua[(vec3)render3d.GetShaderSunDirection].xyz;
	vec3 color = texture(lua[sky_tex = steam.GetSkyTexture()], ray).rgb*depth;

	color = hsv2rgb(rgb2hsv(color) * vec3(1, max(dir.y, 0.85), max(dir.y, 0.01)));

	return color*1.5;
}]])


render.AddGlobalShaderCode([[
vec3 gbuffer_compute_tonemap(vec3 color, vec3 bloom)
{
	const float bloom_factor = 0.05;
	const float exposure = 1;

	color = 1 - exp2(-((color*1.75) + (bloom_factor * bloom*1.75)) * exposure);
	color *= (-bloom_factor+1)*1.75;

	return color;
}
]])

render.AddGlobalShaderCode([[
float gbuffer_compute_light_attenuation(vec3 pos, vec3 light_pos, float radius, vec3 normal)
{
	float distance = length(light_pos - pos);
	distance = distance / radius * 9;
	distance = -distance + 2;

	return pow(clamp(distance, 0, 1), 4);
}
]])

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_specular(vec3 l, vec3 v, vec3 n, float attenuation, vec3 light_color)
{
	n = -n;
	vec2 uv = get_screen_uv();

	float diffuseTerm = clamp(dot(n, l), 0, 1);
	float specularTerm = 0;

	if(dot(n, l) > 0)
	{
		vec3 h = normalize(l + v);
		specularTerm = pow(dot(n, h), pow(1/get_roughness(uv), 5));
	}

	return (diffuseTerm + specularTerm) * attenuation * light_color;
}]])

local PASS = {}

PASS.Name = "simple"
PASS.Source = {}

table.insert(PASS.Source, {
	source =  [[
		const vec2 KERNEL[16] = vec2[](vec2(0.53812504, 0.18565957), vec2(0.13790712, 0.24864247), vec2(0.33715037, 0.56794053), vec2(-0.6999805, -0.04511441), vec2(0.06896307, -0.15983082), vec2(0.056099437, 0.006954967), vec2(-0.014653638, 0.14027752), vec2(0.010019933, -0.1924225), vec2(-0.35775623, -0.5301969), vec2(-0.3169221, 0.106360726), vec2(0.010350345, -0.58698344), vec2(-0.08972908, -0.49408212), vec2(0.7119986, -0.0154690035), vec2(-0.053382345, 0.059675813), vec2(0.035267662, -0.063188605), vec2(-0.47761092, 0.2847911));
		const float SAMPLE_RAD = 2;
		const float INTENSITY = 4;
		const int ITERATIONS = 16;

		float ssao()
		{
			vec3 p = get_view_pos(uv);
			vec3 n = get_view_normal(uv);
			vec2 rand = normalize(get_noise(uv).xy*2-1);

			float occlusion = 0.0;

			for(int j = 0; j < ITERATIONS; ++j)
			{
				vec2 offset = uv + (reflect(KERNEL[j], rand) / (get_linearized_depth(uv)) / g_cam_farz * SAMPLE_RAD);

				vec3 diff = get_view_pos(offset) - p;
				float d = length(diff);

				//if (d < 1)
				{
					occlusion += max(0.0, dot(n, normalize(diff))) * (INTENSITY / (1.0 + d));
				}
			}

			return 1.0 - occlusion / ITERATIONS;
		}

		out vec3 out_color;

		void main()
		{
			vec3 env = get_env_color();

			vec3 albedo = get_albedo(uv);
			vec3 specular = max(get_specular(uv), vec3(0))+(env*0.25);
			float metallic = get_metallic(uv);

			out_color = mix(albedo, env*albedo, metallic) * specular * vec3(ssao());
			out_color += gbuffer_compute_sky(-get_camera_dir(uv).yzx, get_linearized_depth(uv));
		}
	]]
})

render3d.AddGBufferShader(PASS)

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end