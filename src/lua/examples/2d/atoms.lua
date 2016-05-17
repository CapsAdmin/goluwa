local iterations = 10

local fb = render.CreateFrameBuffer(window.GetSize(), {
	internal_format = "r8",
	filter = "linear",
})

local shader = render.CreateShader({
	name = "test",
	fragment = {
		variables = {
			texture_size = {vec2 = function() return fb:GetTexture():GetSize() end},
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


				float neighbours = 0;
				float val = texture(self, uv).r;
				float prev = texture(self, uv).r;

				vec2 uv_unit = (1 + cos(val)) / texture_size * 1.2;

				for (float y = -1; y <= 1; y++)
				{
					for (float x = -1; x <= 1; x++)
					{
						neighbours += texture(self, uv + (uv_unit * vec2(x, y))).r;
					}
				}

				neighbours /= 9;

				val = sin(pow(neighbours, 1.57) * 3.14) / val * 2;

				//out_val = clamp((prev + (1-val)), 0, 1);
				out_val = val;
			}
		]]
	}
})

event.AddListener("Draw2D", "fb", function()
	render.camera_2d:SetPosition(Vec3(-0.1,0.1,0))
	render.camera_2d:SetAngles(Ang3(0,math.rad(180 + 0.025),0))

	for i = 1, iterations do

		fb:Begin()
			--render.SetBlendMode()
			render.SetBlendMode("src_color", "one_minus_dst_color", "add")

			surface.PushMatrix(0, 0, fb:GetTexture():GetSize():Unpack())
				render.SetShaderOverride(shader)
				surface.rect_mesh:Draw()
				render.SetShaderOverride()
			surface.PopMatrix()
		fb:End()

		render.camera_2d:SetPosition(Vec3(-0.1,0.1,0))
		render.camera_2d:SetAngles(Ang3(0,math.rad(180 + 0.025),0))

		surface.SetColor(1,1,1, 1)
		surface.SetTexture(fb:GetTexture())
		surface.DrawRect(0, 0, surface.GetSize())
	end

	shader.generate_random = 0
end)