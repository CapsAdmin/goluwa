local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = false

PASS.Source = {}

local radius = 0.25
local samples = 32
local sub_samples = 1
local blur = 5

table.insert(PASS.Source, {
	buffer = {
		size_divider = 4,
		internal_format = "r8",
	},
	source = [[
		const float uAngleBias = 0.5;
		const vec2 uNoiseScale = vec2(0);

		out float out_color;

		void main()
		{
			const float PI = 3.14159265359;

			vec3 originVS = get_view_pos(uv)*0.996;

			vec3 normalVS = get_view_normal(uv);
			float occlusion = 0;

			float oldAngle = uAngleBias;

			]]..(function()
				local loop = ""
				for i = 1, samples do
					for fade = 1, sub_samples do
						local fade = (fade/sub_samples) / 1

						local str = [[
						{
							vec2 offset = vec2(%s, %s) * %s * ]]..fade..[[ / originVS.z;

							offset += (random(uv)*2-1) / 500;

							vec2 sampleUV = uv + offset;
							vec3 sampleVS = get_view_pos(sampleUV);
							vec3 sampleDirVS = (sampleVS - originVS);

							if (sampleDirVS.z < ]]..(radius*4)..[[)
							{
								// angle between fragment tangent and the sample
								float gamma = (PI / 1.8) - acos(dot(normalVS, normalize(sampleDirVS)));

								if (gamma > oldAngle)
								{
									occlusion += sin(gamma) - sin(oldAngle);
									oldAngle = gamma;
								}
							}
						}]]

						local theta = (i / samples) * math.pi * 2
						str = str:format(math.sin(theta), math.cos(theta), radius)

						loop = loop .. str
					end
				end

				loop = loop .. "occlusion = 1 - occlusion / 2;\n"

				return loop
			end)()..[[

		out_color = occlusion;
	}]]
})

if blur then

	for x = -1, 1 do
		for y = -1, 1 do
			if x == 0 and y == 0 then goto continue end
			table.insert(PASS.Source, {
				buffer = {
					size_divider = 1,
					internal_format = "r8",
				},
				source = [[
					out vec3 out_color;

					vec3 blur(vec2 tex, vec2 dir)
					{
						if (get_view_normal(tex) == vec3(0,0,0))
							return vec3(1);

						float weights[9] =
						{
							0.013519569015984728,
							0.047662179108871855,
							0.11723004402070096,
							0.20116755999375591,
							0.240841295721373,
							0.20116755999375591,
							0.11723004402070096,
							0.047662179108871855,
							0.013519569015984728
						};

						const float indices[9] = {-4, -3, -2, -1, 0, +1, +2, +3, +4};

						vec2 step = dir/g_screen_size.xy;

						vec3 normal[9];

						]] ..(function()
							local str = ""
							for i = 0, 8 do
								str = str .. "normal["..i.."] = get_view_normal(tex + indices["..i.."]*step).xyz;\n"
							end
							return str
						end)()..[[

						float total_weight = 1.0;
						float discard_threshold = 0.85;

						int i;

						for( i=0; i<9; ++i )
						{
							if( dot(normal[i].xyz, normal[4].xyz) < discard_threshold/* || abs(normal[i].w - normal[4].w) > 0.0001*/ )
							{
								total_weight -= weights[i];
								weights[i] = 0;
							}
						}

						//

						vec3 res = vec3(0);

						for( i=0; i<9; ++i )
						{
							res += texture(tex_stage_]]..#PASS.Source..[[, tex + indices[i]*step).rgb * weights[i];
						}

						res /= total_weight;

						return res;
					}

					void main()
					{
						out_color = blur(uv, vec2(]]..(x*blur)..","..(y*blur)..[[));
					}
				]]
			})
			::continue::
		end
	end
end

table.insert(PASS.Source, {
	source = [[
		out vec3 out_color;

		void main()
		{
			vec3 color = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rrr;

			out_color =
				texture(self, uv).rgb *
				color*color*color*color;
		}
	]]
})

 render.AddGBufferShader(PASS)