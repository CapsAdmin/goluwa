render.AddGlobalShaderCode([[
vec3 gbuffer_compute_sky(vec3 ray, float depth)
{
	return vec3(0.4,0.8,1);
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
	distance = distance / radius / 9;
	distance = -distance + 2;

	return pow(clamp(distance, 0, 1), 0.5);
}
]])

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_specular(vec3 l, vec3 v, vec3 n, float attenuation, vec3 light_color)
{
	vec2 uv = get_screen_uv();
	n = -n;

	float diffuse = max(dot(n, l), 0.0);
	float specular = max(pow(dot((2.0 * n * dot(n, l)) - l, v), 2/get_roughness(uv)), 0.0);

	return vec3(diffuse + specular)*attenuation*light_color;
}]])

local PASS = {}

PASS.Name = "template"
PASS.Source = {}

table.insert(PASS.Source, {
	source =  [[
		out vec3 out_color;

		void main()
		{
			vec3 env = get_env_color();

			vec3 albedo = get_albedo(uv);
			float metallic = get_metallic(uv);
			float shadow = get_shadow(uv) > 0.00025 ? 0.25 : 1;
			vec3 specular = get_specular(uv);

			vec3 color = albedo;

			color *= (specular+albedo)*shadow;
			color *= env;

			if (texture(tex_depth, uv).r == 1)
				color = env;

			out_color = color;
		}
	]]
})

render.AddGBufferShader(PASS)

if RELOAD then
	RELOAD = nil
	render.InitializeGBuffer()
end