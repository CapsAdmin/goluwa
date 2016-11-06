local render3d = (...) or _G.render3d

render3d.scene = render3d.scene or {}
local scene_keyval = utility.CreateWeakTable()

render3d.scene_dist = render3d.scene_dist or {}
local scene_keyval_dist = utility.CreateWeakTable()

local needs_sorting = true

function render3d.AddModel(model)
	if not scene_keyval[model] then
		table.insert(render3d.scene, model)
		needs_sorting = true
		scene_keyval[model] = model
	end
	if not scene_keyval_dist[model] then
		table.insert(render3d.scene_dist, model)
		scene_keyval_dist[model] = model
	end
end

function render3d.RemoveModel(model)
	if scene_keyval[model] then
		table.removevalue(render3d.scene, model)
		needs_sorting = true
	end
	if scene_keyval_dist[model] then
		table.removevalue(render3d.scene_dist, model)
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

function render3d.SortDistanceScene(reverse)
	if reverse then
		table.sort(render3d.scene_dist, function(a, b)
			return a.tr:GetCameraDistance() > b.tr:GetCameraDistance()
		end)
	else
		table.sort(render3d.scene_dist, function(a, b)
			return a.tr:GetCameraDistance() < b.tr:GetCameraDistance()
		end)
	end
end

local occlusion_shader = render.CreateShader({
	name = "occlusion_query",
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
		},
		variables = {
			size = 1,
			model = "mat4",
		},
		source = [[
			void main()
			{
				gl_Position = g_projection_view * model * vec4(pos, 1);
			}
		]],
	},
	fragment = {
		source = [[
			void main()
			{

			}
		]],
	},
})

local next_visible = {}
local framebuffers = {}

function render3d.DrawScene(what)
	event.Call("DrawScene")

	if not next_visible[what] or next_visible[what] < system.GetElapsedTime() then

		if not framebuffers[what] then
			local fb = render.CreateFrameBuffer()
			local size = Vec2() + 512

			fb:SetTexture("depth", {
				size = size,
				internal_format = "depth_component16",
			})

			fb:SetSize(size)
			framebuffers[what] = fb
		end

		local scene = render3d.GetDistanceSortedScene()

		if scene[1] then
			render3d.SortDistanceScene()

			framebuffers[what]:Begin()
			framebuffers[what]:ClearDepth(1)
			render.PushDepth(true)
			render.SetColorMask(0,0,0,0)
			render.PushCullMode("none")

			for _, model in ipairs(scene) do
				model.occluders[what] = model.occluders[what] or render.CreateQuery("any_samples_passed_conservative")
				if model:IsVisible(what) and not model:IsTranslucent() then
					--model.is_visible = model.occluders[what]:GetResult()

					-- TODO: upload aabb only
					occlusion_shader.model = model.tr.TRMatrix -- don't call model:GetMatrix() as it migth rebuild, it's not that important
					occlusion_shader:Bind()

					model.occluders[what]:Begin()
					-- TODO: simple geometry
					for _, mesh in ipairs(model.sub_meshes) do
						mesh.vertex_buffer:Draw()
					end
					model.occluders[what]:End()
				end
			end

			render.PopCullMode()
			render.SetColorMask(1,1,1,1)
			render.PopDepth()
			framebuffers[what]:End()
		end

		next_visible[what] = system.GetElapsedTime() + 1/5
	end

	if needs_sorting then
		render3d.SortScene()
		needs_sorting = false
	end

	for _, model in ipairs(render3d.scene) do
		model:Draw(what)
	end
end

function render3d.GetScene()
	return render3d.scene
end

function render3d.GetDistanceSortedScene()
	return render3d.scene_dist
end