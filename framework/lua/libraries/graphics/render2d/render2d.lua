local render2d = _G.render2d or {}

runfile("shader.lua", render2d)
runfile("rectangle.lua", render2d)
runfile("camera.lua", render2d)
runfile("stencil.lua", render2d)
runfile("effects.lua", render2d)

function render2d.Initialize()
	if VULKAN then return end
	render2d.shader = render.CreateShader(render2d.shader_data)

	render2d.rectangle_indices = render.CreateIndexBuffer()
	render2d.rectangle_indices:SetDrawHint("dynamic")
	render2d.rectangle_indices:SetIndicesType("uint16_t")
	render2d.rectangle_indices:LoadIndices(render2d.rectangle_mesh_data)

	render2d.rectangle = render2d.CreateMesh()
	render2d.rectangle:SetDrawHint("dynamic")
	render2d.rectangle:LoadVertices(render2d.rectangle_mesh_data)

	render2d.SetTexture()

	render2d.ready = true
end

function render2d.IsReady()
	return render2d.ready == true
end

if RELOAD then
	render2d.Initialize()
end

return render2d