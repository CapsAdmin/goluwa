local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")
PASS.Default = true

PASS.Source = {}

table.insert(PASS.Source, {
	buffer = {
		max_size = Vec2() + 512,
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

for x = -1, 1 do
	for y = -1, 1 do
		if x == 0 or y == 0 then goto continue end

		local weights = {}

		for i,v in ipairs({-0.028, -0.024, -0.020, -0.016, -0.012, -0.008, -0.004, 0.004, 0.008, 0.012, 0.016, 0.020, 0.024, 0.028}) do
			weights[i] = Vec2(v*x, v*y) * 0.75
		end

		table.insert(PASS.Source, {
			buffer = {
				max_size = Vec2() + 512,
				internal_format = "rgb16f",
			},
			source = [[
				out vec3 out_color;

				void main()
				{
					out_color = vec3(0.0);
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[1].x..[[,]]..weights[1].y..[[)).rgb*0.0044299121055113265;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[2].x..[[,]]..weights[2].y..[[)).rgb*0.00895781211794;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[3].x..[[,]]..weights[3].y..[[)).rgb*0.0215963866053;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[4].x..[[,]]..weights[4].y..[[)).rgb*0.0443683338718;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[5].x..[[,]]..weights[5].y..[[)).rgb*0.0776744219933;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[6].x..[[,]]..weights[6].y..[[)).rgb*0.115876621105;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[7].x..[[,]]..weights[7].y..[[)).rgb*0.147308056121;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv).rgb*0.159576912161;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[8].x..[[,]]..weights[8].y..[[)).rgb*0.147308056121;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[9].x..[[,]]..weights[9].y..[[)).rgb*0.115876621105;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[10].x..[[,]]..weights[10].y..[[)).rgb*0.0776744219933;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[11].x..[[,]]..weights[11].y..[[)).rgb*0.0443683338718;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[12].x..[[,]]..weights[12].y..[[)).rgb*0.0215963866053;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[13].x..[[,]]..weights[13].y..[[)).rgb*0.00895781211794;
					out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[14].x..[[,]]..weights[14].y..[[)).rgb*0.0044299121055113265;
				}
			]]
		})
		::continue::
	end
end

table.insert(PASS.Source, {
	source = [[
		out vec3 out_color;

		float gamma = 1;
		float exposure = 1.5;
		float bloomFactor = 0.0005;
		float brightMax = 1;

		void main()
		{

			vec3 original_image = texture(self, uv).rgb;
			vec3 downsampled_extracted_bloom = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;

			vec3 color = original_image + downsampled_extracted_bloom * bloomFactor;

			color = pow(color, vec3(1. / gamma));
			color = clamp(exposure * color, 0., 1.);

			color = max(vec3(0.), color - vec3(0.004));
			//color = exp( -1.0 / ( 2.72*color + 0.15 ) );
			color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);

			out_color = color;
		}
	]]
})

render.AddGBufferShader(PASS)