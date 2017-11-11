local tex = render.CreateTexture("cube_map")
tex:SetInternalFormat("r11f_g11f_b10f")
tex:SetSize(Vec2() + 256)
tex:SetupStorage()

local fb = render.CreateFrameBuffer()
fb:SetTexture(1, tex, "write", nil, 1)
fb:WriteThese(1)

local shader_view = render.CreateShader({
	name = "test_view",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		variables = {
			cubemap = tex,
		},
		source = [[
			out vec4 out_color;
			void main()
			{
				out_color = texture(cubemap, -get_camera_dir(uv).xzy);
			}
		]],
	},
})

local shader_fill = render.CreateShader({
	name = "test_fill",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		variables = {
			cubemap = tex,
		},
		source = [[
			out vec4 out_color;
			void main()
			{
				out_color = vec4(uv.x*5,uv.y,uv.x, 1);
			}
		]],
	},
})
function goluwa.PreDrawGUI()
	render.SetPresetBlendMode("none")

	fb:Begin()
		for i = 1, 6 do
			fb:SetTextureLayer(1, tex, i)
			fb:ClearTexture(1, ColorHSV(i/6,1,1):Unpack())

			render2d.PushMatrix(0, 0, tex:GetSize():Unpack())
				shader_fill:Bind()
				render2d.rectangle:Draw(render2d.rectangle_indices)
			render2d.PopMatrix()
		end
	fb:End()

	render2d.PushMatrix(0, 0, render2d.GetSize())
		shader_view:Bind()
		render2d.rectangle:Draw(render2d.rectangle_indices)
	render2d.PopMatrix()
end

if menu then
	menu.Close()
end