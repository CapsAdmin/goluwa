render.AddGlobalShaderCode([[
vec3 gbuffer_compute_sky(vec3 ray, float depth)
{
	return vec3(1);
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

	return pow(clamp(distance, 0, 1), 0.5);
}
]])

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_specular(vec3 l, vec3 v, vec3 n, float attenuation, vec3 light_color)
{
	return attenuation*light_color;
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
			vec3 specular = get_specular(uv);

			out_color = albedo * max(specular, vec3(0.25));
		}
	]]
})

render.AddGBufferShader(PASS)

if RELOAD then
	RELOAD = nil
	render.InitializeGBuffer()
end