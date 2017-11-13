local render3d = (...) or _G.render3d

render3d.scene = render3d.scene or {}
local scene_keyval = {}

render3d.scene_dist = render3d.scene_dist or {}
local scene_keyval_dist = {}

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
		scene_keyval[model] = nil
		needs_sorting = true
	end
	if scene_keyval_dist[model] then
		table.removevalue(render3d.scene_dist, model)
		scene_keyval_dist[model] = nil
	end
end

function render3d.SortScene()
	table.sort(render3d.scene, function(a, b)
		return tostring(a.sub_models[1].sub_meshes[1].data) > tostring(b.sub_models[1].sub_meshes[1].data)
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

local DISABLE_CULLING = _G.DISABLE_CULLING
local next_visible = {}
local framebuffers = {}

function render3d.DrawScene(what)
	event.Call("DrawScene")

	if not DISABLE_CULLING and (not next_visible[what] or next_visible[what] < system.GetElapsedTime()) then

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
					occlusion_shader.model = model.tr.FinalMatrix -- don't call model:GetMatrix() as it migth rebuild, it's not that important
					occlusion_shader:Bind()

					model.occluders[what]:Begin()
					-- TODO: simple geometry
					--for _, data in ipairs(model.sub_meshes) do
					for i = 1, model.sub_meshes_length do
						model.sub_meshes[i].model:Draw(model.sub_meshes[i].i)
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


commands.Add("scene_info", function()
	logf("%s models\n", #render3d.scene)

	local model_count = 0
	for _, model in ipairs(render3d.scene) do
		for _, sub_model in ipairs(model:GetSubModels()) do
			model_count = model_count + #sub_model:GetSubMeshes()
		end
	end

	logf("%s sub models (index buffers)\n", model_count)

	local light_count = 0
	for _, ent in ipairs(entities.GetAll()) do
		if ent.SetShadow then
			light_count = light_count + 1
		end
	end
	logf("%s lights\n", light_count)

	logf("%s maximum draw calls\n", model_count + light_count)

	local total_visible = 0
	local vis = {}
	for _, model in ipairs(render3d.scene) do
		for key, is_visible in pairs(model.visible) do
			local visible = is_visible and 1 or 0
			vis[key] = (vis[key] or 0) + visible
			total_visible = total_visible + visible
		end
	end

	logf("%s current draw calls with shadows\n", total_visible)

	local temp = {}
	for id, count in pairs(vis) do table.insert(temp, {id = id, count = count}) end
	table.sort(temp, function(a, b) return a.id < b.id end)
	for _, v in ipairs(temp) do
		logf("\t%s visible in %s\n", v.count, v.id)
	end

	local mat_count = {}
	local tex_count = {}
	for _, model in ipairs(render3d.scene) do
		for _, mesh in ipairs(model.sub_models) do
			if mesh.material then
				mat_count[mesh.material] = true
				for key, val in pairs(mesh.material) do
					if typex(val) == "texture" then
						tex_count[val] = true
					end
				end
			end
		end
	end
	mat_count = table.count(mat_count)
	tex_count = table.count(tex_count)

	logf("%s materials\n", mat_count)
	logf("%s textures\n", tex_count)
end)