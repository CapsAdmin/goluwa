steam.MountSourceGame("csgo")

local tex = render.CreateTexture("cube_map")
tex:SetSize(Vec2() + 1024)
tex:SetMinFilter("linear")
tex:SetMagFilter("linear")
tex:SetWrapS("clamp_to_edge")
tex:SetWrapT("clamp_to_edge")
tex:SetWrapR("clamp_to_edge")
tex:SetSeamlessCubemap(true)
tex:SetupStorage()
tex:LoadCubemap("materials/skybox/vietnam.vtf")

local shader = render.CreateShader({
	name = "cubemap",
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
				out_color = texture(cubemap, get_camera_dir(uv));
			}
		]],
	},
})

event.AddListener("PreDrawGUI", "lol", function()
	render.SetBlendMode()

	render2d.PushMatrix(0, 0, render2d.GetSize())
		shader:Bind()
		render2d.rectangle:Draw()
	render2d.PopMatrix()
end)

if menu then
	menu.Close()
end