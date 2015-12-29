local render = ... or _G.render

local assimp = desire("ffi.assimp")
local cb_render

local mount_info = {
	["gm_.+"] = {"garry's mod", "tf2", "css"},
	["ep1_.+"] = {"half-life 2: episode one"},
	["ep2_.+"] = {"half-life 2: episode two"},
	["trade_.+"] = {"half-life 2", "team fortress 2"},
	["d%d_.+"] = {"half-life 2"},
	["dm_.*"] = {"half-life 2: deathmatch"},
	["c%dm%d_.+"] = {"left 4 dead 2"},

	["esther"] = {"dear esther"},
	["jakobson"] = {"dear esther"},
	["donnelley"] = {"dear esther"},
	["paul"] = {"dear esther"},
	["aramaki_4d"] = {"team fortress 2", "garry's mod"},
	["de_overpass"] = {"counter-strike: global offensive"},
	["sp_a4_finale1"] = {"portal 2"},
	["c3m1_plankcountry"] = {"left 4 dead 2"},
	["achievement_apg_r11b"] = {"half-life 2", "team fortress 2"},
}

render.model_cache = {}

local assimp = desire("ffi.assimp") -- model decoder

local cb = utility.CreateCallbackThing(render.model_cache)

render.model_loader_cb = cb

function render.LoadModel(path, callback, callback2, on_fail)
	check(path, "string")

	if cb:check(path, callback, {mesh = callback2, on_fail = on_fail}) then return true end

	steam.MountGamesFromPath(path)

	local data = cb:get(path)

	if data then
		if callback2 then
			for i, mesh in ipairs(data) do
				callback2(mesh)
			end
		end
		callback(data)
		return true
	end

	if not vfs.Exists(path) and vfs.Exists(path .. ".mdl") then
		path = path .. ".mdl"
	end

	local dir = path:match("(.+/)")

	cb:start(path, callback, {mesh = callback2, on_fail = on_fail})

	resource.Download(path, function(full_path)
		local out = {}

		local thread = tasks.CreateTask()
		thread.debug = true

		function thread:OnStart()
			if steam.LoadModel and full_path:endswith(".mdl") then
				steam.LoadModel(full_path, function(mesh)
					cb:callextra(path, "mesh", mesh)
					table.insert(out, mesh)
				end)
			elseif steam.LoadMap and full_path:endswith(".bsp") then
				for _, mesh in ipairs(steam.LoadMap(full_path).render_meshes) do
					cb:callextra(path, "mesh", mesh)
					table.insert(out, mesh)
				end
			elseif assimp then
				local flags = bit.bor(assimp.e.aiProcessPreset_TargetRealtime_Quality, assimp.e.aiProcess_ConvertToLeftHanded)
				--[[
					bit.bor(
						assimp.e.aiProcess_CalcTangentSpace,
						assimp.e.aiProcess_GenSmoothNormals,
						assimp.e.aiProcess_Triangulate,
						assimp.e.aiProcess_JoinIdenticalVertices
					)
				]]

				assimp.ImportFileEx(full_path, flags, function(model_data, i, total_meshes)
					if render.debug then logf("[render] %s loading %q %s\n", full_path, model_data.name, i .. "/" .. total_meshes) end

					local mesh = render.CreateMeshBuilder()

					if model_data.material then
						local material = render.CreateMaterial("model")

						mesh.material = material

						local diffuse_path = model_data.material.diffuse
						local normal_path = model_data.material.normal
						local metallic_path = model_data.material.metallic
						local roughness_path = model_data.material.roughness

						local potentially_ue4 = false

						local function find(path)
							local tries = {path, full_path:match("(.+/)") .. path}

							-- ue4
							if model_data.material.name:startswith("/") then
								table.insert(tries, 1, full_path:match("(.+)/") .. model_data.material.name:match("(.+/)") .. path)
								potentially_ue4 = true
							end

							for _, path in ipairs(tries) do
								if vfs.IsFile(path) then
									return path
								end
							end
							return path
						end

						if diffuse_path then
							diffuse_path = find(diffuse_path)
							material:SetAlbedoTexture(Texture(diffuse_path))

							if potentially_ue4 and material:GetAlbedoTexture():GetSize() == Vec2(1, 1) then
								material:Remove()
								mesh:Remove()
								return
							end
						end

						local function try_set(method, texture_path, ...)
							if not texture_path then
								texture_path = utility.FindTextureFromSuffix(path, ...)
							end

							if texture_path then
								texture_path = find(texture_path)
								material["Set"..method .. "Texture"](material, Texture(texture_path, false))
							end
						end

						try_set("Normal", normal_path, "_n", "_ddn", "_nrm", "_Normal")
						try_set("Roughness", roughness_path, "_s", "_spec", "_Rougness")
						try_set("Metallic", metallic_path, "_m", "_Metallic")
					end

					mesh:SetName(model_data.name)
					mesh:SetVertices(model_data.vertices)
					mesh:SetIndices(model_data.indices)
					mesh:BuildBoundingBox()

					mesh:Upload()
					cb:callextra(path, "mesh", mesh)
					table.insert(out, mesh)
				end, not vfs.IsFile("os:"..path))
			else
				cb:callextra(path, "on_fail", "unknown format " .. path)
			end

			cb:stop(path, out)
		end

		thread:Start()
	end, function(reason)
		cb:callextra(path, "on_fail", reason)
	end)

	return true
end