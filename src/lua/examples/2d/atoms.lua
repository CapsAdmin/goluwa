local fps = 0

fps = 1/fps

if fps == math.huge then
	fps = 0
end

local fb = render.CreateFrameBuffer(window.GetSize(), {
	internal_format = "RGBA8",
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
			out vec4 frag_color;

			float pi = 3.14159265358979323846264338327950288419716939937510582097494459230781640;
			float pi2 = pi/2;

			void main()
			{
				if (generate_random == 1)
				{

					frag_color.rgb = vec3(1, 1, 1);
					frag_color.a = random(uv);
					//pow(frag_color.a, 1);

					return;
				}

				float neighbours = 0;
				float color = texture(self, uv).r;

				vec2 uv_unit = (1 + cos(color)) / size;

				for (float y = -1; y <= 1; y++)
				{
					for (float x = -1; x <= 1; x++)
					{
						neighbours += texture(self, uv + (uv_unit * vec2(x, y))).r;
					}
				}

				neighbours /= 9;

				color = sin(pow(neighbours, pi2) * pi) / color * 2;

				frag_color = vec4(color);
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

	return 255, 255, 255, a * 128
end)

local brush_size = 4

event.Timer("fb_update", fps, 0, function()

	fb:Begin()
		render.SetBlendMode("src_color", "one_minus_dst_alpha", "add")

		surface.PushMatrix(0, 0, W, H)
			render.SetShaderOverride(shader)
			surface.rect_mesh:Draw()
			render.SetShaderOverride()
		surface.PopMatrix()

		if input.IsMouseDown("button_1") or input.IsMouseDown("button_2") then
			if input.IsMouseDown("button_1") then
				render.SetBlendMode()
				surface.SetColor(1,1,1,1)
			else
				render.SetBlendMode(nil,nil,nil, "src_alpha","one_minus_src_alpha","sub")
				surface.SetColor(1,1,1,0)
			end
			surface.SetTexture(brush)
			local x,y = surface.GetMousePosition()
			surface.DrawRect(x, y, brush:GetSize().x*brush_size, brush:GetSize().y*brush_size, 0, brush:GetSize().x/2*brush_size, brush:GetSize().y/2*brush_size)
		end
	fb:End()

	shader.generate_random = 0
end)

event.AddListener("Draw2D", "fb", function()
	surface.SetColor(0,0,0, 1)

	surface.SetWhiteTexture()
	surface.DrawRect(0, 0, surface.GetSize())


	surface.SetColor(1,1,1, 1)
	surface.SetTexture(fb:GetTexture())
	surface.DrawRect(0, 0, surface.GetSize())
end)