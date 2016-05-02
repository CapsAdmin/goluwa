local render = ... or _G.render

render.model_cache = {}

local assimp = desire("libassimp") -- model decoder

local cb = utility.CreateCallbackThing(render.model_cache)

render.model_loader_cb = cb

function render.LoadModel(path, callback, callback2, on_fail)
	if cb:check(path, callback, {mesh = callback2, on_fail = on_fail}) then return true end

	steam.MountGamesFromPath(path)

	local data = cb:get(path)

	if data then
		if callback2 then
			for _, mesh in ipairs(data) do
				callback2(mesh)
			end
		end
		callback(data)
		return true
	end

	if not vfs.Exists(path) and vfs.Exists(path .. ".mdl") then
		path = path .. ".mdl"
	end

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
				local flags = bit.bor(assimp.e.TargetRealtime_Quality, assimp.e.ConvertToLeftHanded)
				--[[
					bit.bor(
						assimp.e.CalcTangentSpace,
						assimp.e.GenSmoothNormals,
						assimp.e.Triangulate,
						assimp.e.JoinIdenticalVertices
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
							material:SetAlbedoTexture(render.CreateTextureFromPath(diffuse_path))

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
								material["Set"..method .. "Texture"](material, render.CreateTextureFromPath(texture_path, false))
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