local render3d = (...) or _G.render3d

render3d.cull_rate = 1/20

render3d.scene = render3d.scene or {}
local scene_keyval = {}

render3d.scene_dist = {}

local needs_sorting = true

function render3d.AddModel(model)
	if
		not model.sub_models[1] or
		not model.sub_models[1].sub_meshes[1] or
		not model.sub_models[1].sub_meshes[1].data
	then
		debug.trace()
		print("bad model")
	end

	if not scene_keyval[model] then
		table.insert(render3d.scene, model)
		needs_sorting = true
		scene_keyval[model] = model
	end
end

function render3d.RemoveModel(model)
	if scene_keyval[model] then
		table.removevalue(render3d.scene, model)
		scene_keyval[model] = nil
		needs_sorting = true
	end
end

function render3d.SortScene()
	table.sort(render3d.scene, function(a, b)
		return tostring(a.sub_models[1].sub_meshes[1].data) > tostring(b.sub_models[1].sub_meshes[1].data)
	end)
end

do
	local function sort(a, b) return a.dist < b.dist end

	function render3d.SortDistanceScene(what)
		local i2 = 0

		--table.clear(render3d.scene_dist)
		local count = #render3d.scene

		for i = 1, count do
			local model = render3d.scene[i]
			if model:IsVisible(what) then
				i2 = i2 + 1
				model.dist = render3d.scene[i].tr:GetCameraDistance()
				render3d.scene_dist[i2] = model
			end
		end

		for i = i2 + 1, count do render3d.scene_dist[i] = nil end

		table.sort(render3d.scene_dist, sort)

		return i2
	end
end

local occlusion_shader = render.CreateShader({
	name = "occlusion_query",
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
		},
		variables = {
			model = "mat4",
		},
		source = [[
			void main()
			{
				gl_Position = _G.projection_view * model * vec4(pos, 1);
			}
		]],
	},
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		source = [[
			void main()
			{
				if (!lua[AlbedoAlphaMetallic = false])
				{
					float alpha = texture(lua[AlbedoTexture = "sampler2D"], uv).a * lua[Alpha = 1];

					if (alpha_discard(uv, alpha))
					{
						discard;
					}
				}
			}
		]],
	},
})

local next_visible = {}
local framebuffers = {}

function render3d.DrawScene(what)
	event.Call("DrawScene")

	if not render3d.scene[1] then return end

	if not render3d.noculling then
		if (not next_visible[what] or next_visible[what] < system.GetElapsedTime()) then

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

			render3d.cull_rate = math.clamp(system.GetFrameTime()*10, 1/20, 1/5)

			framebuffers[what]:Begin()
			framebuffers[what]:ClearDepth(1)
			render.PushDepth(true)
			render.SetColorMask(0,0,0,0)
			render.PushCullMode("none")

			--for _, model in ipairs(scene) do
			for i = 1, render3d.SortDistanceScene(what) do
				local model = render3d.scene_dist[i]
				model.occluders[what] = model.occluders[what] or render.CreateQuery("any_samples_passed_conservative")

				-- TODO: upload aabb only
				occlusion_shader.model = model.tr.FinalMatrix -- don't call model:GetMatrix() as it migth rebuild, it's not that important


				model.occluders[what]:Begin()

				if model.MaterialOverride then
					for i = 1, model.sub_meshes_length do
						occlusion_shader.AlbedoAlphaMetallic = model.MaterialOverride.AlbedoAlphaMetallic
						occlusion_shader.AlbedoTexture = model.MaterialOverride.AlbedoTexture
						occlusion_shader.Translucent = model.MaterialOverride.Translucent
						occlusion_shader.AlphaTest = model.MaterialOverride.AlphaTest
						occlusion_shader.Alpha = model.MaterialOverride.Color.a
						occlusion_shader:Bind()
						model.sub_meshes[i].model:Draw(model.sub_meshes[i].i)
					end
				else

					-- TODO: simple geometry
					--for _, data in ipairs(model.sub_meshes) do
					for i = 1, model.sub_meshes_length do
						occlusion_shader.AlbedoAlphaMetallic = model.sub_meshes[i].data.AlbedoAlphaMetallic
						occlusion_shader.AlbedoTexture = model.sub_meshes[i].data.AlbedoTexture
						occlusion_shader.Translucent = model.sub_meshes[i].data.Translucent
						occlusion_shader.AlphaTest = model.sub_meshes[i].data.AlphaTest
						occlusion_shader.Alpha = model.sub_meshes[i].data.Color.a
						occlusion_shader:Bind()
						model.sub_meshes[i].model:Draw(model.sub_meshes[i].i)
					end
				end
				model.occluders[what]:End()
			end

			render.PopCullMode()
			render.SetColorMask(1,1,1,1)
			render.PopDepth()
			framebuffers[what]:End()

			next_visible[what] = system.GetElapsedTime() + render3d.cull_rate
		end
	end

	if needs_sorting then
		render3d.SortScene()
		needs_sorting = false
	end

	for i = 1, #render3d.scene do
		render3d.scene[i]:Draw(what)
	end
end

function render3d.GetScene()
	return render3d.scene
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