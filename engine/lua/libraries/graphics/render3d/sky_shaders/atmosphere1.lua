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