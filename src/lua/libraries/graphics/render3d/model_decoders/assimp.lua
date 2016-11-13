local render3d = ... or _G.render3d

local assimp = desire("assimp") -- model decoder

if not assimp then return end

render3d.AddModelDecoder("assimp", function(path, full_path, mesh_callback)

	local flags = bit.bor(tonumber(assimp.e.TargetRealtime_Quality), tonumber(assimp.e.ConvertToLeftHanded))

	assimp.ImportFileEx(full_path, flags, function(model_data, i, total_meshes)
		if render3d.debug then llog("%s loading %q %s\n", full_path, model_data.name, i .. "/" .. total_meshes) end

		local mesh = gfx.CreatePolygon3D()

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

		if model_data.name then mesh:SetName(model_data.name) end
		mesh:SetVertices(model_data.vertices)
		mesh:SetIndices(model_data.indices)
		mesh:BuildBoundingBox()

		mesh:BuildNormals()
		mesh:SmoothNormals()
		mesh:BuildTangents()

		mesh:Upload()

		mesh_callback(mesh)

	end, not vfs.IsFile("os:"..path))
end, false)