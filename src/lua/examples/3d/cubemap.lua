steam.MountSourceGame("csgo")

local tex = render.CreateTexture("cube_map")
tex:SetMinFilter("linear")
tex:SetMagFilter("linear")
tex:SetWrapS("clamp_to_edge")
tex:SetWrapT("clamp_to_edge")
tex:SetWrapR("clamp_to_edge")
tex:SetSeamlessCubemap(true)
tex:SetSize(Vec2(512,512)) -- skyboxes have varying size for some reason, but this is wrong
tex:LoadCubemap("materials/skybox/sky_cs15_daylight02_hdr.vmt")

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
				out_color = texture(cubemap, -get_camera_dir(uv).xzy);
			}
		]],
	},
})

function goluwa.PreDrawGUI()
	render.SetPresetBlendMode("none")

	render2d.PushMatrix(0, 0, render2d.GetSize())
		shader:Bind()
		render2d.rectangle:Draw()
	render2d.PopMatrix()
end

if menu then
	menu.Close()
end