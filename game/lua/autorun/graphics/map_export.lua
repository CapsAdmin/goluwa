local export_dir

local BumpBasis = {
	{(2 ^ 0.5) / (3 ^ 0.5), 0, 1 / (3 ^ 0.5)},
	{-1 / (6 ^ 0.5), 1 / (2 ^ 0.5), 1 / (3 ^ 0.5)},
	{-1 / (6 ^ 0.5), -1 / (2 ^ 0.5), 1 / (3 ^ 0.5)},
}

local ffi = require("ffi")

local function ConvertTextureToString(Material, Texture, VMT, StorableTable, Type)
	if Type == "Normal" then
		return Texture:ToTGA(function(x,y,i, Normal_X, Normal_Y, Normal_Z,a)
			if StorableTable.SSBump then
				Normal_X, Normal_Y, Normal_Z = (Normal_X / 255), (Normal_Y / 255), (Normal_Z / 255)

				Normal_X = math.clamp(BumpBasis[1][1] * Normal_X + BumpBasis[2][1] * Normal_Y + BumpBasis[3][1] * Normal_Z, -1.0, 1.0)
				Normal_Y = math.clamp(BumpBasis[1][2] * Normal_X + BumpBasis[2][2] * Normal_Y + BumpBasis[3][2] * Normal_Z, -1.0, 1.0)
				Normal_Z = math.clamp(BumpBasis[1][3] * Normal_X + BumpBasis[2][3] * Normal_Y + BumpBasis[3][3] * Normal_Z, -1.0, 1.0)

				local Length = ((Normal_X * Normal_X + Normal_Y * Normal_Y + Normal_Z * Normal_Z) ^ 0.5)

				if Length > 0 then
					Normal_X, Normal_Y, Normal_Z = Normal_X / Length, Normal_Y / Length, Normal_Z / Length
				end

				if not StorableTable.FlipYNormal then
					Normal_Y = -Normal_Y
				end

				if StorableTable.FlipXNormal then
					Normal_X = -Normal_X
				end

				--Make it Y up.
				Normal_Y = -Normal_Y

				Normal_X, Normal_Y, Normal_Z = Normal_X * 0.5 + 0.5, Normal_Y * 0.5 + 0.5, Normal_Z * 0.5 + 0.5
				Normal_X, Normal_Y, Normal_Z = math.round(Normal_X * 255), math.round(Normal_Y * 255), math.round(Normal_Z * 255)
			else
				if StorableTable.FlipYNormal then
					Normal_Y = 255 - Normal_Y
				end

				if StorableTable.FlipXNormal then
					Normal_X = 255 - Normal_X
				end

				--Make it Y up.
				Normal_Y = 255 - Normal_Y
			end

			return Normal_X, Normal_Y, Normal_Z
		end)
	end

	return Texture:ToTGA()
end

local function ConvertReflectionMap(Texture, VMT, StorableTable, Type)
	if VMT.basemapalphaphongmask then
		return Texture:ToTGA(function(x,y,i, r,g,b,a)
			a = math.clamp((1 - (a / 255)) ^ 2, 0, 1) * 255
			return a,a,a,a
		end)
	else
		return Texture:ToTGA(function(x,y,i, r,g,b,a)
			return a,a,a,a
		end)
	end
end

local function ConvertTexture(Material, Texture, VMT, StorableTable, Type, Path2)
	local Path = VMT.fullpath
	local PathNoExt = ""
	local SRGB = Texture.SRGB and "srgb" or "rgba8"

	if Path:find("materials/") and Texture.Path:find("materials/") then
		if not Path2 then
			Path = vfs.RemoveExtensionFromPath(Path:sub(select(1, Path:find("materials/"), #Path)))
			PathNoExt = Path

			Path = "data/" .. export_dir .. "/" .. Path

			if VMT.basealphaenvmapmask and Type == "Albedo" and not vfs.Exists(Path .. "_REFLECT.tga") then
				print("Storing texture data in " .. Path .. "_REFLECT.tga")
				vfs.Write(Path .. "_REFLECT.tga", ConvertReflectionMap(Texture, VMT, StorableTable, Type))
			end

			if VMT.basemapalphaphongmask and Type == "Albedo" then
				print("Storing texture data in " .. Path .. "_ROUGH.tga")
				vfs.Write(Path .. "_ROUGH.tga", ConvertReflectionMap(Texture, VMT, StorableTable, Type))
			end

			if VMT.blendtintbybasealpha and Type == "Albedo" and not vfs.Exists(Path .. "_TINT.tga") then
				print("Storing texture data in " .. Path .. "_TINT.tga")
				vfs.Write(Path .. "_TINT.tga", ConvertReflectionMap(Texture, VMT, StorableTable, Type))
			end

			if not vfs.Exists(Path .. ".tga") then
				print("Storing texture data in " .. Path .. ".tga")
				vfs.Write(Path .. ".tga", ConvertTextureToString(Material, Texture, VMT, StorableTable, Type))
			end
		else
			PathNoExt = Path2

			Path = "data/" .. export_dir .. "/" .. Path2

			local OriginalPath = Path:sub(1, #Path - 4)
			if VMT.normalmapalphaenvmapmask and Type == "Normal" and not vfs.Exists(OriginalPath .. "_REFLECT.tga") then
				print("Storing texture data in " .. OriginalPath .. "_REFLECT.tga")
				vfs.Write(OriginalPath .. "_REFLECT.tga", ConvertReflectionMap(Texture, VMT, StorableTable, Type))
			end

			if not vfs.Exists(Path .. ".tga") then
				print("Storing texture data in " .. Path .. ".tga")

				if Type ~= "Metallic" then
					vfs.Write(Path .. ".tga", ConvertTextureToString(Material, Texture, VMT, StorableTable, Type))
				else
					local StringData = ConvertTextureToString(Material, Texture, VMT, StorableTable, Type)
					vfs.Write(Path .. ".tga", StringData)

					local OriginalPath = Path:sub(1, #Path - 5)
					if not vfs.Exists(OriginalPath .. "_REFLECT.tga") then
						print("Storing texture data in " .. OriginalPath .. "_REFLECT.tga")
						vfs.Write(OriginalPath .. "_REFLECT.tga", StringData)
					end
				end
			end
		end
	end

	return PathNoExt
end

local function GenerateReflection(SpecularTexture, VMT, StorableTable, Type, Path2)
	local Path = "data/" .. export_dir .. "/" .. Path2

	if not vfs.Exists(Path) then
		return SpecularTexture:ToTGA(function(x,y,i, r,g,b,a)
			return 0,0,0,0
		end)
	end
end

local function GenerateRoughness(SpecularTexture, VMT, StorableTable, Type, Path2)
	local Path = "data/" .. export_dir .. "/" .. Path2

	if SpecularTexture and SpecularTexture.Path:find("materials/") then
		return SpecularTexture:ToTGA(function(x,y,i, r,g,b,a)
			return 255, 255, 255, 255
		end)
	else
		if Type == "Roughness" and not vfs.Exists(Path .. ".tga") then
			return SpecularTexture:ToTGA(function(x,y,i, r,g,b,a)
				return 255, 255, 255, 255
			end)
		end
	end
end

local function ConvertModel(Model)
	local Path = Model.ModelPath

	local IsMap = false
	local IsModel = false

	if Path:find("models/") then
		IsModel = true
	end

	if Path:find("maps/") then
		IsMap = true
	end

	if IsModel or IsMap then
		if IsModel then
			Path = vfs.RemoveExtensionFromPath(Path:sub(select(1, Path:find("models/"), #Path)))
		end

		if IsMap then
			Path = "models/" .. vfs.GetFileNameFromPath(vfs.RemoveExtensionFromPath(Path:sub(select(1, Path:find("maps/"), #Path))))
		end

		Path = "data/" .. export_dir .. "/" .. Path .. ".obj"

		if not vfs.Exists(Path) then
			print("Storing vertex data in " .. Path)

			vfs.Write(Path, Model:ToOBJ())
		end
	end
end

local function WriteMapData()
	local MapData = {}

	local SunDirection = entities.GetWorld():GetSunAngles()

	MapData[1] = {
		AngleX = SunDirection.x,
		AngleY = SunDirection.y,
		AngleZ = SunDirection.z
	}

	local MapPath = ""
	for Key, Entity in pairs(entities.active_entities) do
		if Entity.model then
			local Path = Entity.model.ModelPath

			local IsMap = false
			local IsModel = false

			if Path:find("models/") then
				IsModel = true
			end

			if Path:find("maps/") then
				MapPath = vfs.RemoveExtensionFromPath(Path)
				IsMap = true
			end

			if IsMap or IsModel then
				local EntityData = {}

				local Color = Entity:GetColor()

				EntityData.ColorR = Color.r
				EntityData.ColorG = Color.g
				EntityData.ColorB = Color.b

				local Position = Entity:GetPosition()

				EntityData.PositionX = Position.x
				EntityData.PositionY = Position.y
				EntityData.PositionZ = Position.z

				local Angle = Entity:GetAngles()

				if Angle.x == Angle.x then
					EntityData.AngleX = Angle.x
				else
					EntityData.AngleX = 0
				end

				if Angle.y == Angle.y then
					EntityData.AngleY = Angle.y
				else
					EntityData.AngleY = 0
				end

				if Angle.z == Angle.z then
					EntityData.AngleZ = Angle.z
				else
					EntityData.AngleZ = 0
				end

				local Size = Entity:GetSize()

				EntityData.ScaleX = Size
				EntityData.ScaleY = Size
				EntityData.ScaleZ = Size

				local Quaternion = Entity:GetRotation()

				EntityData.QuaternionX = Quaternion.x
				EntityData.QuaternionY = Quaternion.y
				EntityData.QuaternionZ = Quaternion.z
				EntityData.QuaternionW = Quaternion.w

				if IsModel then
					Path = vfs.RemoveExtensionFromPath(Path:sub(select(1, Path:find("models/"), #Path)))
				end

				if IsMap then
					Path = "models/" .. vfs.GetFileNameFromPath(vfs.RemoveExtensionFromPath(Path:sub(select(1, Path:find("maps/"), #Path))))
				end

				EntityData.Model = Path

				local FoundAttributes = Entity and Entity.model and Entity.model.sub_meshes[1] and Entity.model.sub_meshes[1].vertex_buffer and Entity.model.sub_meshes[1].vertex_buffer.DrawHint

				if FoundAttributes then
					if Entity.model.sub_meshes[1].vertex_buffer.DrawHint then
						EntityData.Type = Entity.model.sub_meshes[1].vertex_buffer.DrawHint
					else
						EntityData.Type = "static"
					end

					MapData[#MapData + 1] = EntityData
				end
			end
		end
	end

	if not vfs.Exists("data/" .. export_dir .. "/" .. MapPath .. ".txt") then
		print("Storing map data in data/" .. export_dir .. "/" .. MapPath .. ".txt")
		serializer.WriteFile("json", "data/" .. export_dir .. "/" .. MapPath .. ".txt", MapData)
	end
end

commands.Add("export_level", function()
	if not steam.bsp_world then error("no bsp map loaded") end

	export_dir = "exported_levels/" .. steam.bsp_world:GetName()

	for Key, Entity in pairs(entities.active_entities) do
		if Entity.model then
			ConvertModel(Entity.model)
			for Key, SubModel in pairs(Entity.model.sub_meshes) do
				if SubModel.material.AlbedoTexture then
					local VMT = SubModel.material.vmt

					if VMT then
						if VMT.basetexture2 and not SubModel.material.Albedo2Texture then
							if vfs.Exists("materials/" .. VMT.basetexture2:lower() .. ".vtf") then
								print("Adding Albedo2Texture materials/" .. VMT.basetexture2:lower() .. ".vtf")
								SubModel.material.Albedo2Texture = Texture("materials/" .. VMT.basetexture2:lower() .. ".vtf")
							end
						end

						local StorableTable = SubModel.material:GetStorableTable()
						local PathNoExt = ConvertTexture(SubModel.material, SubModel.material.AlbedoTexture, VMT, StorableTable, "Albedo")

						if not VMT.basemapalphaphongmask then
							if SubModel.material.RoughnessTexture and  SubModel.material.RoughnessTexture.Path:find("materials/") then
								ConvertTexture(SubModel.material, SubModel.material.RoughnessTexture, VMT, StorableTable, "Roughness", PathNoExt .. "_ROUGH")
							else
								GenerateRoughness(SubModel.material.MetallicTexture, VMT, StorableTable, "Roughness", PathNoExt .. "_ROUGH")
							end
						end

						if SubModel.material.NormalTexture then
							ConvertTexture(SubModel.material, SubModel.material.NormalTexture, VMT, StorableTable, "Normal", PathNoExt .. "_NRM")
						end

						if SubModel.material.SkyTexture then
							ConvertTexture(SubModel.material, SubModel.material.SkyTexture, VMT, StorableTable, "Sky", PathNoExt .. "_SKY")
						end

						if SubModel.material.MetallicTexture and not VMT.basemapalphaphongmask then
							if SubModel.material.RoughnessTexture.Path:find("materials/") then
								ConvertTexture(SubModel.material, SubModel.material.MetallicTexture, VMT, StorableTable, "Metallic", PathNoExt .. "_REFLECT")
							else
								GenerateReflection(SubModel.material.MetallicTexture, VMT, StorableTable, "Metallic", PathNoExt .. "_REFLECT")
							end
						end
					end
				end
			end
		end

		WriteMapData()
	end
end)