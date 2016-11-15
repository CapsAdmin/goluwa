include("lua/libraries/graphics/render3d/sky_shaders/atmosphere1.lua")

do
	render.SetGlobalShaderVariable("g_time", function() return system.GetElapsedTime() end, "float")

	render.AddGlobalShaderCode([[
	float random(vec2 co)
	{
		return fract(sin(dot(co.xy * g_time, vec2(12.9898, 78.233))) * 43758.5453);
	}]])

	render.AddGlobalShaderCode([[
	vec2 get_noise2(vec2 uv)
	{
		float x = random(uv * g_time);
		float y = random(uv * x);

		return vec2(x, y) * 2 - 1;
	}]])

	render.AddGlobalShaderCode([[
	vec3 get_noise3(vec2 uv)
	{
		float x = random(uv * g_time);
		float y = random(uv * x);
		float z = random(uv * y);

		return vec3(x, y, z) * 2 - 1;
	}]])
end

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

	return vec3(dotNL * D * F * vis) * atn * 10;
}
]])


local PASS = {}

PASS.Position = -1
PASS.Name = "temporal"
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

			out_color = mix(texture(self, uv).rgb, light, 0.25);
		}
	}
]]
})

table.insert(PASS.Source, {
	buffer = {
		--max_size = Vec2() + 512,
		internal_format = "r8",
	},
	source =  [[
		out float out_color;

		void main()
		{
			out_color = mix(texture(self, uv).r, g_ssao(uv), 0.6);
		}
	]]
})

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
			vec3 reflection = texture(tex_stage_]]..(#PASS.Source-1)..[[, uv).rgb;
			float metallic = get_metallic(uv);
			vec3 albedo = get_albedo(uv);

			vec3 specular = get_specular(uv) * texture(tex_stage_]]..(#PASS.Source)..[[, uv).r;
			specular = mix(specular, reflection, pow(metallic, 0.5));

			out_color = albedo * specular;
			out_color += gbuffer_compute_sky(get_camera_dir(uv), get_linearized_depth(uv));
			out_color *= pow(random(uv), 0.4);

			out_color *= 15;

			out_color = mix(texture(self, uv).rgb, out_color, 0.1);
		}
	]]
})


function PASS:Update()
	local view = camera.camera_3d:GetViewport()
	local t = system.GetElapsedTime()*100
	local r = 0.01
	view.x = math.sin(t)*r*math.random()
	view.y = math.cos(t)*r*math.random()
	camera.camera_3d:SetViewport(view)
end

render3d.AddGBufferShader(PASS)

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end