local render3d = (...) or _G.render3d

render3d.scene = render3d.scene or {}
local scene_keyval = utility.CreateWeakTable()

local needs_sorting = true

function render3d.AddModel(obj)
	if not scene_keyval[obj] then
		table.insert(render3d.scene, obj)
		needs_sorting = true
		scene_keyval[obj] = obj
	end
end

function render3d.RemoveModel(obj)
	if scene_keyval[obj] then
		table.removevalue(render3d.scene, obj)
		needs_sorting = true
	end
end

function render3d.SortScene()
	table.sort(render3d.scene, function(a, b)
		local sub_models_a = a.sub_models
		local sub_models_b = b.sub_models

		if sub_models_a[1] and sub_models_b[1] then
			-- how to do this without tostring?
			return tostring(sub_models_a[1].material) > tostring(sub_models_b[1].material)
		end
	end)
end

function render3d.DrawScene(what, dist)
	event.Call("DrawScene")

	if needs_sorting then
		render3d.SortScene()
		needs_sorting = false
	end

	if SSBO then
		render.update_globals()
	end

	for _, model in ipairs(render3d.scene) do
		model:Draw(what, dist)
	end
end