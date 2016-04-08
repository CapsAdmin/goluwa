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
vec3 compute_brdf(vec2 uv, vec3 l, vec3 v, vec3 n)
{
	n = -n;
	//l = -l;
	//v = -v;

	float diffuse = max(dot(n, l), 0.0);
	float specular = max(pow(dot((2.0 * n * dot(n, l)) - l, v), 2/get_roughness(uv)), 0.0);

	return vec3(diffuse + specular)*0.05;
}]])

local PASS = {}

PASS.Name = "temaplate"
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
			color *= 10;

			if (texture(tex_depth, uv).r == 1)
				color = env;

			out_color = color;
		}
	]]
})

render.AddGBufferShader(PASS)

if RELOAD then
	RELOAD = nil
	include("lua/libraries/graphics/render/gbuffer.lua")
end