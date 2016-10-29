local fps = 0

fps = 1/fps

if fps == math.huge then
	fps = 0
end

local fb = render.CreateFrameBuffer(window.GetSize(), {
	internal_format = "r32f",
	--filter = "nearest",
})

local W, H = fb:GetTexture():GetSize():Unpack()

local shader = render.CreateShader({
	name = "test",
	fragment = {
		variables = {
			size = {vec2 = function() return fb:GetTexture():GetSize() end},
			self = {texture = function() return fb:GetTexture() end},
			generate_random = 1,
		},
		mesh_layout = {
			{uv = "vec2"},
		},
		source = [[
			out float out_val;

			void main()
			{
				if (generate_random == 1)
				{
					out_val = random(uv);

					return;
				}


				float rot = radians(0.25);

				vec2 offset = uv;
				offset -= 0.5;
				offset *= mat2(cos(rot), -sin(rot), sin(rot), cos(rot)) * 1.0002;
				offset += 0.5;

				float neighbours = 0;
				float val = texture(self, offset).r;
				float prev = texture(self, uv).r;

				for (float y = -4; y <= 4; y++)
				{
					for (float x = -4; x <= 4; x++)
					{
						neighbours += texture(self, uv + vec2(x, y)/size).r;
					}
				}

				val = neighbours / val / 10;

				out_val = clamp((prev*val + (1-val)), 0, 1);
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

event.Timer("fb_update", fps, 0, function()

	fb:Begin()
		--render.SetBlendMode("src_color", "one_minus_dst_color", "add")
		render.SetBlendMode()

		render2d.PushMatrix(0, 0, W, H)
			shader:Bind()
			render2d.rectangle:Draw()
		render2d.PopMatrix()

		if input.IsMouseDown("button_1") or input.IsMouseDown("button_2") then
			if input.IsMouseDown("button_1") then
				render.SetBlendMode("multiplicative")
				render2d.SetColor(1,1,1,1)
			else
				render.SetBlendMode("src_color","one_minus_src_color","sub")
				render2d.SetColor(1,1,1,1)
			end
			render2d.SetTexture(brush)
			local x,y = gfx.GetMousePosition()
			render2d.DrawRect(x, y, brush:GetSize().x*brush_size, brush:GetSize().y*brush_size, 0, brush:GetSize().x/2*brush_size, brush:GetSize().y/2*brush_size)
		end
	fb:End()

	shader.generate_random = 0
end)

event.AddListener("PreDrawGUI", "fb", function()
	render2d.SetColor(0,0,0, 1)

	render2d.SetTexture()
	render2d.DrawRect(0, 0, render2d.GetSize())


	render2d.SetColor(1,1,1, 1)
	render2d.SetTexture(fb:GetTexture())
	render2d.DrawRect(0, 0, render2d.GetSize())
end)