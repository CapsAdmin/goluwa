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
vec3 get_sky(vec3 ray, float depth)
{
	ray = ray.xzy * vec3(-1, -1, 1);

	vec3 sun_direction = lua[(vec3)render.GetShaderSunDirection].xyz;
	float intensity = lua[world_sun_intensity = 1];
	vec3 sky_color = lua[world_sky_color = Vec3(0.18867780436772762, 0.4978442963618773, 0.6616065586417131)];

	const float surface_height = 0.95;
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
	vec3 noise = get_noise((ray.xz+sun_direction.xy)/5).xyz;
	vec3 hsv = rgb2hsv(noise);
	hsv.y = 0.25;
	hsv.z = pow(hsv.z, 75)*5;
	noise = hsv2rgb(hsv);
	vec3 stars = noise * sky_mult;
	vec3 eye_position = min(vec3(0,surface_height,0) + (vec3(-g_cam_pos.x, g_cam_pos.z, g_cam_pos.y) / 100010000), vec3(0.999999));
	float eye_depth = sky_atmospheric_depth(eye_position, ray, depth);
	float step_length = eye_depth/float(step_count);
	vec3 rayleigh_collected = vec3(0.0, 0.0, 0.0);
	vec3 mie_collected = vec3(0.0, 0.0, 0.0);
	for(int i=0; i < step_count; i++)
	{
		float sample_distance = step_length * float(i);
		vec3 position = eye_position + ray * sample_distance;
		float extinction = sky_horizon_extinction(position, ldir, surface_height - 0.2);
		float sample_depth = sky_atmospheric_depth(position, ray, depth);
		vec3 influx = sky_absorb(sky_color, sample_depth, vec3(intensity * 5), scatter_strength) * extinction;
		rayleigh_collected += sky_absorb(sky_color, sqrt(sample_distance), sky_color * influx, rayleigh_strength);
		mie_collected += sky_absorb(sky_color, sample_distance, influx, mie_strength);
	}
	rayleigh_collected = rayleigh_collected * pow(eye_depth, rayleigh_collection_power) / float(step_count);
	mie_collected = (mie_collected * pow(eye_depth, mie_collection_power)) / float(step_count);
	return stars + vec3(spot) + clamp(vec3(spot * mie_collected + mie_factor * mie_collected + rayleigh_factor * rayleigh_collected), vec3(0), vec3(1));
}]], "get_sky")


render.AddGlobalShaderCode([[
vec3 tonemap(vec3 color, vec3 bloom)
{
	const float gamma = 1.1;
	const float exposure = 0.9;
	const float bloomFactor = 0.0005;
	const float brightMax = 1;

	color = color + bloom * bloomFactor;
	color *= exposure * (exposure + 1.0);
	color = exp( -1.0 / ( 2.72*color + 0.15 ) );
	color = pow(color, vec3(1. / gamma));
	color = max(vec3(0.), color - vec3(0.004));
	color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);
	return color;
}]])


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
vec3 compute_light_specular(vec2 uv, vec3 L, vec3 V, vec3 N, float attenuation, vec3 light_color)
{
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
	float pi = 3.14159f;
	float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;
	D = alphaSqr/(pi * denom * denom);
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

do
	local PASS = {}

	PASS.Position = 1
	PASS.Name = "reflection"
	PASS.Default = true

	PASS.Source = {}

	local FAST_BLUR = false

	table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			size_divider = 2,
			internal_format = "rgb16f",
		},
		source = [[
		const float rayStep = 0.002;
		const float minRayStep = 50;
		const float maxSteps = 50;

		vec2 project(vec3 coord)
		{
			vec4 res = g_projection * vec4(coord, 1.0);
			return (res.xy / res.w) * 0.5 + 0.5;
		}

		vec2 ray_cast(vec3 dir, vec3 hitCoord)
		{
			dir *= rayStep + get_depth(uv);

			for(int i = 0; i < maxSteps; i++)
			{
				hitCoord += dir;

				float depth = hitCoord.z - get_view_pos(project(hitCoord)).z;

				if(depth < 0.0 && depth > -0.3)
				{
					return project(hitCoord).xy;
				}
			}

			return vec2(0.0, 0.0);
		}

		out vec3 out_color;

		void main()
		{
			vec3 viewNormal = get_view_normal(uv);
			vec3 viewPos = get_view_pos(uv);
			vec3 reflected = normalize(reflect(normalize(viewPos), normalize(viewNormal)));

			vec3 hitPos = viewPos;
			vec2 coords = ray_cast(reflected * max(minRayStep, viewPos.z), hitPos);

			vec3 sky = texture(lua[sky_tex = render.GetSkyTexture()], -reflect(get_camera_dir(uv), get_world_normal(uv)).yzx).rgb;

			if (coords == vec2(0.0))
			{
				out_color = sky;
				return;
			}

			//vec3 probe = texture(lua[probe_tex = render.GetEnvironmentProbeTexture()], -reflect(get_camera_dir(uv), get_world_normal(uv)).yzx).rgb;
			vec3 diffuse = get_albedo(coords.xy);
			vec3 light = diffuse * (sky + get_specular(uv));

			vec2 dCoords = abs(vec2(0.5, 0.5) - coords.xy);
			float fade = clamp(1.0 - (dCoords.x + dCoords.y)*1.5, 0.0, 1.0);
			fade -= pow(fade, 1.5)/1.75;
			fade *= 2;

			out_color =	mix(sky, light, fade);
		}
	]]
	})

	for x = -1, 1 do
		for y = -1, 1 do
			if x == y or (y == 0 and x == 0) then goto continue end

			local weights = {
				Vec2(0.53812504, 0.18565957),
				Vec2(0.13790712, 0.24864247),
				Vec2(0.33715037, 0.56794053),
				Vec2(-0.6999805, -0.04511441),
				Vec2(0.06896307, -0.15983082),
				Vec2(0.056099437, 0.006954967),
				Vec2(-0.014653638, 0.14027752),
				Vec2(0.010019933, -0.1924225),
				Vec2(-0.35775623, -0.5301969),
				Vec2(-0.3169221, 0.106360726),
				Vec2(0.010350345, -0.58698344),
				Vec2(-0.08972908, -0.49408212),
				Vec2(0.7119986, -0.0154690035),
				Vec2(-0.053382345, 0.059675813),
				Vec2(0.035267662, -0.063188605),
				Vec2(-0.47761092, 0.2847911)
			}

			for i,v in ipairs(weights) do
				weights[i] = {
					dir = ("vec2(%s, %s)"):format(v.x, v.y),
					weight = math.lerp(math.sin((i / #weights) * math.pi), 0, 0.25),
				}
			end

			table.insert(PASS.Source, {
				buffer = {
					size_divider = 2,
					internal_format = "rgb16f",
				},
				source = [[
					out vec3 out_color;

					const float discard_threshold = 0.5;

					vec3 blur(vec2 dir, float amount)
					{

						amount = pow(amount*2, 2.5) / get_depth(uv) / g_cam_farz;

						vec2 step = dir * amount;
						vec3 normal = normalize(get_view_normal(uv));
						float total_weight = 3;
						vec3 res = vec3(0);
						vec2 offset;

						]] ..(function()
							local str = ""
							for i, weight in ipairs(weights) do
								str = str .. "offset = uv + " ..weight.dir.." * step;\n"
								str = str .. "if( dot(normalize(get_view_normal(offset)), normal) < discard_threshold) {\n"
								str = str .."total_weight -= "..weight.weight..";\n"
								str = str .. "} else {\n"
								str = str .. "res += texture(tex_stage_"..#PASS.Source..", offset).rgb * "..weight.weight.."; }\n"
							end
							return str
						end)()..[[

						res /= total_weight;

						return res;
					}

					void main()
					{
						out_color = blur(vec2(]]..x..","..y..[[), get_roughness(uv));
					}
				]]
			})
			::continue::
		end
	end

	do
		table.insert(PASS.Source, {
			buffer = {
				size_divider = 2,
				internal_format = "rgb8",
			},
			source = [[
				const vec2 KERNEL[16] = vec2[](vec2(0.53812504, 0.18565957), vec2(0.13790712, 0.24864247), vec2(0.33715037, 0.56794053), vec2(-0.6999805, -0.04511441), vec2(0.06896307, -0.15983082), vec2(0.056099437, 0.006954967), vec2(-0.014653638, 0.14027752), vec2(0.010019933, -0.1924225), vec2(-0.35775623, -0.5301969), vec2(-0.3169221, 0.106360726), vec2(0.010350345, -0.58698344), vec2(-0.08972908, -0.49408212), vec2(0.7119986, -0.0154690035), vec2(-0.053382345, 0.059675813), vec2(0.035267662, -0.063188605), vec2(-0.47761092, 0.2847911));
				const float SAMPLE_RAD = 0.75;  /// Used in main
				const float INTENSITY = 0.5; /// Used in doAmbientOcclusion

				float ssao(void)
				{
					vec3 p = get_view_pos(uv);
					vec3 n = get_view_normal(uv);
					vec2 rand = normalize(get_noise(uv).xy*2-1);

					float occlusion = 0.0;

					const int ITERATIONS = 16;
					for(int j = 0; j < ITERATIONS; ++j)
					{
						vec2 offset = uv + (reflect(KERNEL[j], rand) / (get_depth(uv)) / g_cam_farz * SAMPLE_RAD);

						vec3 diff = get_view_pos(offset) - p;
						float d = length(diff);

						if (d < 1)
						{
							occlusion += max(0.0, dot(n, normalize(diff))) * (INTENSITY / (1.0 + d));
						}
					}

					return 1.0 - occlusion / ITERATIONS;
				}
				out vec3 out_color;

				void main()
				{
					vec3 color = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;
					out_color = color * pow(ssao(), 5);
				}
			]]
		})
	end

	table.insert(PASS.Source, {
		source = [[
			out vec3 out_color;

			void main()
			{
				vec3 color = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;
				out_color = color*3;
			}
		]]
	})


	render.AddGBufferShader(PASS)
end

do
	local PASS = {}

	PASS.Name = "template"
	PASS.Source = {}

	table.insert(PASS.Source, {
		source =  [[
			out vec3 out_color;

			void main()
			{
				vec3 reflection = texture(self, uv).rgb;
				vec3 diffuse = get_albedo(uv);
				vec3 specular = get_specular(uv)*2;
				float shadow = get_shadow(uv) > 0.00025 ? 0.25 : 1;

				specular *= shadow;

				float metallic = get_metallic(uv);
				specular = mix(specular, reflection, pow(metallic, 0.5));
				out_color = diffuse * specular;
				out_color += get_sky(get_camera_dir(uv), get_depth(uv))*0.5;
				//out_color = reflection;
			}
		]]
	})

	render.AddGBufferShader(PASS)
end

if RELOAD then
	RELOAD = nil
	render.InitializeGBuffer()
end