local render2d = _G.render2d or {}

include("shader.lua", render2d)
include("rectangle.lua", render2d)
include("camera.lua", render2d)
include("stencil.lua", render2d)
include("effects.lua", render2d)

function render2d.Initialize()
	render2d.shader = render.CreateShader(render2d.shader_data)

	render2d.rectangle = render2d.CreateMesh()
	render2d.rectangle:SetDrawHint("dynamic")
	render2d.rectangle:SetIndicesType("uint16_t")
	render2d.rectangle:SetBuffersFromTables(render.rectangle_mesh_data)
	render2d.rectangle:SetUpdateIndices(false)


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