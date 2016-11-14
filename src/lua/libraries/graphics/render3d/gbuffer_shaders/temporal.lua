render.SetGlobalShaderVariable("iGlobalTime", function() return system.GetElapsedTime() end, "float")

render.AddGlobalShaderCode([[
float random(vec2 co)
{
	return fract(sin(dot(co.xy * iGlobalTime,vec2(12.9898,78.233))) * 43758.5453);
}]])

render.AddGlobalShaderCode([[
vec2 get_noise2(vec2 uv)
{
	float x = random(uv * iGlobalTime);
	float y = random(uv*x);

	return vec2(x,y) * 2 - 1;
}]])

render.AddGlobalShaderCode([[
vec3 get_noise3(vec2 uv)
{
	float x = random(uv * iGlobalTime);
	float y = random(uv*x);
	float z = random(uv*y);

	return vec3(x,y,z) * 2 - 1;
}]])

render.AddGlobalShaderCode([[
float sky_atmospheric_depth(vec3 position, vec3 dir, float depth)
{
	float a = dot(dir, dir);
	float b = 2.0*dot(dir, position);
	float c = dot(position, position)-1.0;
	float det = b*b-4.0*a*c;
	float detSqrt = sqrt(det);
	float q = (-b - detSqrt)/2.0;
	float t1 = c/q;
	return t1 * pow(depth, 2.5) / 7;
}
float sky_phase(float alpha, float g)
{
	float a = 3.0*(1.0-g*g);
	float b = 2.0*(2.0+g*g);
	float c = 1.0+alpha*alpha;
	float d = pow(1.0+g*g-2.0*g*alpha, 1.5);
	d = max(d, 0.00001);
	return (a/b)*(c/d);
}
float sky_horizon_extinction(vec3 position, vec3 dir, float radius)
{
	float u = dot(dir, -position);
	if(u<0.0)
	{
		return 1.0;
	}
	vec3 near = position + u*dir;
	if(length(near) < radius)
	{
		return 0.0;
	}
	else if (length(near) >= radius)
	{
		vec3 v2 = normalize(near)*radius - position;
		float diff = acos(dot(normalize(v2), dir));
		return smoothstep(0.0, 1.0, pow(diff*2.0, 3.0));
	}
	else
		return 1.0;
}
vec3 sky_absorb(vec3 sky_color, float dist, vec3 color, float factor)
{
	return color-color*pow(sky_color, vec3(factor/dist));
}
vec3 gbuffer_compute_sky(vec3 ray, float depth)
{
	//{return pow(ray*2, vec3(1000));}
	ray = ray.xzy * vec3(-1, -1, 1);

	vec3 sun_direction = lua[(vec3)render3d.GetShaderSunDirection].xyz;
	float intensity = lua[world_sun_intensity = 1];
	vec3 sky_color = lua[world_sky_color = Vec3(0.18867780436772762, 0.4978442963618773, 0.6616065586417131)];

	vec3 influence = texture(lua[sky_tex = steam.GetSkyTexture()], ray).rgb*depth;
	if (influence != vec3(0))
		sky_color *= influence;

	const float render2d_height = 0.95;
	const int step_count = 8;
	const float rayleigh_brightness = 2;
	const float mie_brightness = 0.99;
	float spot_brightness = intensity;
	const float scatter_strength = 0.1;
	const float rayleigh_strength = 0.839;
	const float mie_strength = 0.964;
	const float rayleigh_collection_power = 0.65;
	const float mie_collection_power = 0.8;
	const float mie_distribution = 0.26;

	vec3 ldir = sun_direction;
	float alpha = dot(ray, ldir);
	float rayleigh_factor = sky_phase(alpha, -0.01) * rayleigh_brightness * ldir.y;
	float mie_factor = sky_phase(alpha - 0.5, mie_distribution) * mie_brightness * (1.0 - ldir.y);
	float sky_mult = pow(depth, 100);
	float spot = smoothstep(0.0, 100.0, sky_phase(alpha, 0.9995)) * spot_brightness * sky_mult;

	vec3 stars = textureLatLon(lua[nightsky_tex = render.CreateTextureFromPath("textures/skybox/milkyway.jpg")], reflect(ray, sun_direction)).rgb;
	stars += pow(stars*1.25, vec3(1.5));
	stars *= depth > 0.5 ? 1 : 0;
	stars *= 0.01;

	vec3 eye_position = min(vec3(0,render2d_height,0) + (vec3(-g_cam_pos.x, g_cam_pos.z, g_cam_pos.y) / 100010000), vec3(0.999999));
	float eye_depth = sky_atmospheric_depth(eye_position, ray, depth);
	float step_length = eye_depth/float(step_count);
	vec3 rayleigh_collected = vec3(0.0, 0.0, 0.0);
	vec3 mie_collected = vec3(0.0, 0.0, 0.0);
	for(int i=0; i < step_count; i++)
	{
		float sample_distance = step_length * float(i);
		vec3 position = eye_position + ray * sample_distance;
		float extinction = sky_horizon_extinction(position, ldir, render2d_height - 0.2);
		float sample_depth = sky_atmospheric_depth(position, ray, depth);
		vec3 influx = sky_absorb(sky_color, sample_depth, vec3(intensity * 5), scatter_strength) * extinction;
		rayleigh_collected += sky_absorb(sky_color, sqrt(sample_distance), sky_color * influx, rayleigh_strength);
		mie_collected += sky_absorb(sky_color, sample_distance, influx, mie_strength);
	}
	rayleigh_collected = rayleigh_collected * pow(eye_depth, rayleigh_collection_power) / float(step_count);
	mie_collected = (mie_collected * pow(eye_depth, mie_collection_power)) / float(step_count);
	vec3 total = stars + vec3(spot) + clamp(vec3(spot * mie_collected + mie_factor * mie_collected + rayleigh_factor * rayleigh_collected), vec3(0), vec3(1));

	total *= 3;

	return total;
}]])

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_tonemap(vec3 color, vec3 bloom)
{
	const float gamma = 1.2;
	const float exposure = 0.2;
	const float bloomFactor = 0.03;

	color = color + bloom * bloomFactor;
	color *= exposure * (exposure + 1.0);
	color = exp( -1.0 / ( 2.72*color + 0.15 ) );
	color = pow(color, vec3(1. / gamma));
	color = max(vec3(0.), color - vec3(0.004));
	color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);

	return color;
}]])

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