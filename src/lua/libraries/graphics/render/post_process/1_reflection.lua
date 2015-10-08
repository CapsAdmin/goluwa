local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")
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
	const float rayStep = 0.005;
	const float minRayStep = 20;
	const float maxSteps = 50;

	vec2 project(vec3 coord)
	{
		vec4 res = g_projection * vec4(coord, 1.0);
		return (res.xy / res.w) * 0.5 + 0.5;
	}

	vec2 ray_cast(vec3 dir, vec3 hitCoord)
	{
		dir *= rayStep;

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
		vec3 viewNormal = (get_view_normal(uv));
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
		vec3 diffuse = get_diffuse(coords.xy);
		vec3 light = diffuse * (length(sky) + get_light(uv)) + (diffuse * diffuse * diffuse * get_self_illumination(coords.xy));

		vec2 dCoords = abs(vec2(0.5, 0.5) - coords.xy);
		float fade = clamp(1.0 - (dCoords.x + dCoords.y)*1.5, 0.0, 1.0);
		fade -= pow(fade, 1.5)/1.75;
		fade *= 2;

		out_color =	mix(sky, light, fade);
	}
]]
})

if true then
	for x = -1, 1 do
		for y = -1, 1 do
			if x == y or (y == 0 and x == 0) then goto continue end

			local samples = 16
			local total_weight = 0
			local weights = {}

			for i = 1, samples do
				local theta = (i / samples) * math.pi * 2
				local weight = math.lerp(math.sin((i / samples) * math.pi), 0, 0.25)
				total_weight = total_weight + weight
				weights[i] = {
					dir = ("vec2(%s, %s)"):format(math.sin(theta), math.cos(theta)),
					weight = weight,
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

					vec3 blur()
					{
						float amount = get_roughness(uv);
						amount = min(pow(amount*3, 2.5) / get_depth(uv) / g_cam_farz / 20, 0.1);

						vec3 normal = normalize(get_view_normal(uv));
						float total_weight = ]]..total_weight..[[;
						vec3 res = vec3(0);
						vec2 offset;

						]] ..(function()
							local str = ""
							for i, weight in ipairs(weights) do
								str = str .. "offset = (" ..weight.dir.." * amount);\n"
								str = str .. "if( dot(normalize(get_view_normal(uv + offset)), normal) < discard_threshold) {\n"
								str = str .."total_weight -= "..weight.weight..";\n"
								str = str .. "} else {\n"
								str = str .. "res += texture(tex_stage_"..#PASS.Source..", uv + offset).rgb * "..weight.weight.."; }\n"
							end
							return str
						end)()..[[

						res /= total_weight;

						return res;
					}

					void main()
					{
						out_color = blur();
					}
				]]
			})
			::continue::
		end
	end
end

if true then
	table.insert(PASS.Source, {
		buffer = {
			size_divider = 1,
			internal_format = "rgb16f",
		},
		source = [[
			const vec2 KERNEL[16] = vec2[](vec2(0.53812504, 0.18565957), vec2(0.13790712, 0.24864247), vec2(0.33715037, 0.56794053), vec2(-0.6999805, -0.04511441), vec2(0.06896307, -0.15983082), vec2(0.056099437, 0.006954967), vec2(-0.014653638, 0.14027752), vec2(0.010019933, -0.1924225), vec2(-0.35775623, -0.5301969), vec2(-0.3169221, 0.106360726), vec2(0.010350345, -0.58698344), vec2(-0.08972908, -0.49408212), vec2(0.7119986, -0.0154690035), vec2(-0.053382345, 0.059675813), vec2(0.035267662, -0.063188605), vec2(-0.47761092, 0.2847911));
			const float SAMPLE_RAD = 1.25;  /// Used in main
			const float INTENSITY = 1.25; /// Used in doAmbientOcclusion

			float ssao(void)
			{
				vec3 p = get_view_pos(uv)*0.996;
				vec3 n = normalize(get_view_normal(uv));
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
				float occlusion = ssao();
				//out_color = pow(color*3, vec3(occlusion*3)) * pow(occlusion, 5)/3;
				out_color = color * pow(occlusion, 5);
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
			out_color = color;
		}
	]]
})


render.AddGBufferShader(PASS)