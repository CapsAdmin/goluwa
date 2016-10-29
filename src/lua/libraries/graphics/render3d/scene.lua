local render3d = (...) or _G.render3d

render3d.scene = render3d.scene or {}
local scene_keyval = utility.CreateWeakTable()

local needs_sorting = true

function render3d.AddModel(model)
	if not scene_keyval[model] then
		table.insert(render3d.scene, model)
		needs_sorting = true
		scene_keyval[model] = model
	end
end

function render3d.RemoveModel(model)
	if scene_keyval[model] then
		table.removevalue(render3d.scene, model)
		needs_sorting = true
	end
end

function render3d.SortScene()
	table.sort(render3d.scene, function(a, b)
		local sub_meshes_a = a.sub_meshes
		local sub_meshes_b = b.sub_meshes

		if sub_meshes_a[1] and sub_meshes_b[1] then
			-- how to do this without tostring?
			return tostring(sub_meshes_a[1].material) > tostring(sub_meshes_b[1].material)
		end
	end)
end

function render3d.DrawScene(what)
	event.Call("DrawScene")

	if needs_sorting then
		render3d.SortScene()
		needs_sorting = false
	end

	for _, model in ipairs(render3d.scene) do
		model:Draw(what)
	end
end