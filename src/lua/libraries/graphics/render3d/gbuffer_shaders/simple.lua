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
		out vec3 out_color;

		void main()
		{
			vec3 env = get_env_color();

			vec3 albedo = get_albedo(uv);
			vec3 specular = max(get_specular(uv), vec3(0))+(env*0.25);
			float metallic = get_metallic(uv);

			out_color = mix(albedo, env*albedo, metallic) * specular * vec3(g_ssao(uv));
			out_color += gbuffer_compute_sky(-get_camera_dir(uv).yzx, get_linearized_depth(uv));
		}
	]]
})

render3d.AddGBufferShader(PASS)

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end