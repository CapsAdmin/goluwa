local render = (...) or _G.render

render.scene_3d = render.scene_3d or {}

local needs_sorting = false

function render.Add3DModel(obj)
	table.insert(render.scene_3d, obj)
	needs_sorting = true
end

function render.Remove3DModel(obj)
	table.removevalue(render.scene_3d, obj)
	needs_sorting = true
end

function render.Sort3DScene()
	table.sort(render.scene_3d, function(a, b)
		local sub_models_a = a.sub_models
		local sub_models_b = b.sub_models

		if sub_models_a[1] and sub_models_b[1] then
			-- how to do this without tostring?
			return tostring(sub_models_a[1].material) > tostring(sub_models_b[1].material)
		end
	end)
end

function render.Draw3DScene(what, dist)
	if needs_sorting then
		render.Sort3DScene()
		needs_sorting = false
	end

	for _, model in ipairs(render.scene_3d) do
		model:Draw(what, dist)
	end
end