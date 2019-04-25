commands.Add("export_map", function()
	if not steam.bsp_world then error("no bsp map loaded") end

	local export_dir = "data/exported_maps/" .. steam.bsp_world:GetName()

	local function store_file(relative_path, ext, get_data)
		local path = vfs.RemoveExtensionFromPath(export_dir .. "/" .. relative_path) .. (extra_name and extra_name or "") .. "." .. ext

		if not vfs.IsFile(path) then
			llog("writing ", ext, ": ", path)
			vfs.Write(path, get_data())
		end
	end

	store_file("map", "txt", function()
		local data = {}

		for i, ent in ipairs(entities.GetAll()) do
			data[i] = ent:GetStorableTable()
			if ent.transform then
				data[i].self.world_matrix = {ent:GetMatrix():Unpack()}
			end
		end

		return serializer.Encode("luadata", data)
	end)

	for _, ent in ipairs(entities.GetAll()) do
		if ent.model then
			store_file(ent.model:GetModelPath(), "obj", function() return ent.model:ToOBJ() end)

			for _, mesh in pairs(ent.model.sub_models) do
				local mat = mesh.material
				if mat then
					local tbl = mat:GetStorableTable()
					for k, v in pairs(tbl) do
						if typex(v) == "texture" then
							local full_path = v:GetPath()
							local path = vfs.RemoveExtensionFromPath(full_path)

							if full_path:endswith(".vtf") then
								tbl[k] = path:match("^.+(materials/.+)$") .. ".tga"
							else
								tbl[k] = path .. ".tga"
							end

							local pixel_callback

							if k == "NormalTexture" then
								local BumpBasis = {
									{(2 ^ 0.5) / (3 ^ 0.5), 0, 1 / (3 ^ 0.5)},
									{-1 / (6 ^ 0.5), 1 / (2 ^ 0.5), 1 / (3 ^ 0.5)},
									{-1 / (6 ^ 0.5), -1 / (2 ^ 0.5), 1 / (3 ^ 0.5)},
								}

								pixel_callback = function(_,_,_, x, y, z, _)
									if tbl.SSBump then
										x = x / 255
										y = y / 255
										z = z / 255

										x = math.clamp(BumpBasis[1][1] * x + BumpBasis[2][1] * y + BumpBasis[3][1] * z, -1.0, 1.0)
										y = math.clamp(BumpBasis[1][2] * x + BumpBasis[2][2] * y + BumpBasis[3][2] * z, -1.0, 1.0)
										z = math.clamp(BumpBasis[1][3] * x + BumpBasis[2][3] * y + BumpBasis[3][3] * z, -1.0, 1.0)

										local length = (x * x + y * y + z * z) ^ 0.5

										if length > 0 then
											x = x / length
											y = y / length
											z = z / length
										end

										x = x * 0.5 + 0.5
										y = y * 0.5 + 0.5
										z = z * 0.5 + 0.5

										x = math.round(x * 255)
										y = math.round(y * 255)
										z = math.round(z * 255)
									end

									if tbl.FlipYNormal then
										y = 255 - y
									end

									if tbl.FlipXNormal then
										x = 255 - x
									end

									--Make it Y up.
									y = 255 - y

									return x, y, z, 255
								end

								if tbl.NormalAlphaMetallic then
									local callback = function(_,_,_, r,g,b,a)
										return a,a,a,255
									end

									tbl.MetallicTexture = tbl[k]:gsub("(.+)(%..-)$", "%1_metallic%2")
									store_file(tbl.MetallicTexture, "tga", function() return v:ToTGA(callback) end)
								end
							elseif k == "AlbedoTexture" then
								if tbl.AlbedoPhongMask then
									pixel_callback = function(_,_,_, r,g,b,a)
										return r,g,b,255
									end

									local callback = function(_,_,_, r,g,b,a)
										a = a / 255
										a = (1 - a) ^ 2
										a = math.clamp(0, 1)
										a = a * 255
										return a,a,a,a
									end

									tbl.RoughnessTexture = tbl[k]:gsub("(.+)(%..-)$", "%1_roughness%2")
									store_file(tbl.RoughnessTexture, "tga", function() return v:ToTGA(callback) end)
								end
							end

							-- these keys are not needed as they are baked into the texture or made as new textures
							tbl.GUID = nil
							tbl.FlipXNormal = nil
							tbl.FlipYNormal = nil
							tbl.SSBump = nil
							tbl.NormalAlphaMetallic = nil
							tbl.AlbedoPhongMask = nil

							store_file(tbl[k], "tga", function() return v:ToTGA(pixel_callback) end)
						end
					end

					tbl.vmt = mat.vmt

					store_file(vfs.RemoveExtensionFromPath(mat:GetName()), "mat", function() return serializer.Encode("luadata", tbl) end)
				end
			end
		end
	end

	llog("finished exporting")
end)