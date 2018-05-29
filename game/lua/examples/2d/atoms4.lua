local fb = render.CreateFrameBuffer(window.GetSize(), {
	internal_format = "rgba32f",
	filter = "linear",
})
fb:GetTexture():SetWrapS("repeat")
fb:GetTexture():SetWrapT("repeat")
local shader = render.CreateShader({
	name = "test",
	fragment = {
		variables = {
			texture_size = {vec2 = function() return fb:GetTexture():GetSize() end},
			self = {texture = function() return fb:GetTexture() end},
			i = 0,
			generate_random = 1,
		},
		mesh_layout = {
			{uv = "vec2"},
		},
		source = [[
			out vec4 out_val;

			float get_average(vec2 uv, float unit)
			{
				const float points = 14.0;
				const float Start = 2.0 / points;
				vec2 scale = 5 / texture_size;

				float res = texture(self, uv).r;

				for (float point = 0; point < points; point++)
				{
					float r = (PI * 2.0 * (1.0 / points)) * (point + Start);
					res += texture(self, uv + vec2(sin(r), cos(r)) * scale).r;
				}

				res /= points;

				return res;
			}

			void main()
			{
				if (generate_random == 1)
				{
					out_val = get_noise(uv);
					return;
				}

				vec2 uv = uv;

				vec4 c = texture(self, uv);
				float avg = get_average(uv, 1);
				out_val.r = sin(avg * 4) + sin(c.r);

				out_val.g = out_val.r*0.5+0.5 * 1.5;
				out_val.b = c.r/10;
				out_val.a = 1;
			}
		]]
	}
})

local brush = render.CreateBlankTexture(Vec2() + 128):Fill(function(x, y)
	x = x / 128
	y = y / 128

	x = x - 1
	y = y - 1.5

	x = x * math.pi
	y = y * math.pi

	local a = math.sin(x) * math.cos(y)

	a = a ^ 32

	return a * 128
end)

local brush_size = 4

function goluwa.PreDrawGUI()

	if true or wait(1/5) then
		fb:Begin()

			if input.IsMouseDown("button_1") or input.IsMouseDown("button_2") then
				if input.IsMouseDown("button_1") then
					render.SetPresetBlendMode("additive")
					render2d.SetColor(1,1,1,1)
				else
					render.SetBlendMode("src_color","one_minus_src_color","sub")
					render2d.SetColor(1,1,1,1)
				end
				render2d.SetTexture(brush)
				local x,y = gfx.GetMousePosition()
				render2d.DrawRect(x, y, brush:GetSize().x*brush_size, brush:GetSize().y*brush_size, 0, brush:GetSize().x/2*brush_size, brush:GetSize().y/2*brush_size)
			end



			render.SetBlendMode("src_color", "one_minus_dst_color", "add", "src_color")
			render.SetPresetBlendMode("none")

			render2d.PushMatrix(0, 0, fb:GetTexture():GetSize():Unpack())
				shader.i = ((shader.i or 0) + 1)%2
				shader:Bind()
				render2d.rectangle:Draw(render2d.rectangle_indices)
			render2d.PopMatrix()

		fb:End()
		shader.generate_random = 0
	end

	render.GetScreenFrameBuffer():ClearAll()

	render.SetPresetBlendMode("alpha")

	render2d.SetColor(1,1,1, 1)
	render2d.SetTexture(fb:GetTexture())
	local w,h = render2d.GetSize()
	render2d.SetRectUV(0,0,w,h,w,h)
	render2d.DrawRect(0, 0, w,h)
end