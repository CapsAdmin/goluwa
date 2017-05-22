local shader = render.CreateShader({
	name = "shader_test",
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
		},
		-- g_projection_view_world_2d comes from render2d.PushMatrix, render2d.Translate, etc
		source = "gl_Position = g_projection_view_world_2d * vec4(pos, 1);"
	},
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		source = [[
			out vec4 frag_color;
			void main()
			{
				frag_color = vec4(1,0,1,1);
			}
		]],
	},
})

local screen_rect = render.CreateVertexBuffer(shader:GetMeshLayout(), {
	{pos = {0, 1, 0}, uv = {0, 0}},
	{pos = {0, 0, 0}, uv = {0, 1}},
	{pos = {1, 1, 0}, uv = {1, 0}},
	{pos = {1, 0, 0}, uv = {1, 1}},
	{pos = {1, 1, 0}, uv = {1, 0}},
	{pos = {0, 0, 0}, uv = {0, 1}},
})
screen_rect:SetDrawHint("static")

if menu then
	menu.Close()
end

event.AddListener("Update", "lol", function()
	render.GetScreenFrameBuffer():Begin()
		render.SetPresetBlendMode("alpha")
		render.SetCullMode("none")
		render.SetDepth(false)

		render2d.PushMatrix(0,0,render2d.GetSize())
			shader:Bind()
			screen_rect:Draw()
		render2d.PopMatrix()
	render.GetScreenFrameBuffer():End()
end)