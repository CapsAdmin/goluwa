local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")
PASS.Default = true

PASS.Source = {}

table.insert(PASS.Source, {
	buffer = {
		size_divider = 5,
		internal_format = "rgb16f",
	},
	source = [[
		out vec3 out_color;

		void main()
		{
			out_color = max(pow(texture(self, uv).rgb*6, vec3(3)), vec3(0));
		}
	]]
})

local AUTOMATE_ME = {
	[-7] = 0.0044299121055113265,
	[-6] = 0.00895781211794,
	[-5] = 0.0215963866053,
	[-4] = 0.0443683338718,
	[-3] = 0.0776744219933,
	[-2] = 0.115876621105,
	[-1] = 0.147308056121,
	[1] = 0.147308056121,
	[2] = 0.115876621105,
	[3] = 0.0776744219933,
	[4] = 0.0443683338718,
	[5] = 0.0215963866053,
	[6] = 0.00895781211794,
	[7] = 0.0044299121055113265,
}

	for _ = 0,1  do
	for x = 0, 1 do
	for y = 0, 1 do
	if (x == 0 and y == 0) or y == x then goto continue end

	local str = [[
out vec3 out_color;
void main()
{
	vec3 normal = normalize(get_view_normal(uv));
	const float discard_threshold = 0.6;

	out_color = texture(tex_stage_]]..#PASS.Source..[[, uv).rgb*0.159576912161;

]]

	for i = -7, 7 do
		if i ~= 0 then
			local weight = i * 4 / 800
			local offset = "uv + vec2("..(x*weight)..", "..(y*weight)..") * 1"
			local fade = AUTOMATE_ME[i]

			str = str .. "\t\tout_color += texture(tex_stage_"..#PASS.Source..", "..offset.." * vec2(g_screen_size.y / g_screen_size.x, 1)).rgb *"..fade..";\n"
		end
	end

	str = str .. "}"

	table.insert(PASS.Source, {
		buffer = {
			size_divider = 5,
			internal_format = "rgb16f",
		},
		source = str,
	})

	::continue::
	end
	end
	end

table.insert(PASS.Source, {
	source = [[
		out vec3 out_color;

		float gamma = 1.3;
		float exposure = 1.6;
		float bloom_factor = 0.0015;
		float brightMax = 1;

		void main()
		{

			vec3 color = texture(self, uv).rgb;

			vec3 bloom = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;

			color = color + bloom * bloom_factor;

			color = pow(color, vec3(1. / gamma));
			color = clamp(exposure * color, 0., 1.);

			//color = max(vec3(0.), color - vec3(0.004));
			color = exp( -1.0 / ( 2.72*color + 0.15 ) );
			color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);

			out_color = color;
		}
	]]
})

render.AddGBufferShader(PASS)