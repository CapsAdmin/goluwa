local shader = {
	name = "forward_flat",
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
		},
		variables = {
			world = {mat4 = function() return render3d.camera:GetWorld() end},
		},
		source = [[
			void main()
			{
				gl_Position = _G.projection_view * world * vec4(pos, 1);
			}
		]]
	},
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		variables = {
			tex = {sampler2D = function() return render.GetMaterial().AlbedoTexture or render.GetErrorTexture() end},
		},
		source = [[
			out vec4 color;
			void main()
			{
				color = texture(tex, uv);
				color.a = 1;
			}
		]]
	}
}

render3d.shader = render.CreateShader(shader)

event.AddListener("Draw3D", "render3d", function()
	if render3d.DrawScene then
		--
		render.GetScreenFrameBuffer():ClearAll()
		--gfx.DrawRect(0,0,1500,1500, nil, 0,0,0,1)

		--render3d.camera:Rebuild()


		render.SetPresetBlendMode("none")

		--render.SetDepth(true)

		render3d.DrawScene("models")
		--render.SetDepth(false)
	end
end)

event.RemoveListener("PreDrawGUI", "render3d")