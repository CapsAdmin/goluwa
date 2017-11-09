local export_dir

local BumpBasis = {
	{(2 ^ 0.5) / (3 ^ 0.5), 0, 1 / (3 ^ 0.5)},
	{-1 / (6 ^ 0.5), 1 / (2 ^ 0.5), 1 / (3 ^ 0.5)},
	{-1 / (6 ^ 0.5), -1 / (2 ^ 0.5), 1 / (3 ^ 0.5)},
}

local ffi = require("ffi")

local Vertex = ffi.typeof([[
	struct {
		float position[3];
		float color[3];
		float texcoord[2];
		float normal[3];
		float tangent[3];
	}
]])
local Vertices = ffi.typeof("$[?]", Vertex)

local Pixel = ffi.typeof([[
	struct {
		uint8_t color[4];
	}
]])
local Pixels = ffi.typeof("$[?]", Pixel)

local function ConvertTextureToString(Material, Texture, VMT, StorableTable, Type)
	local MergeMaterial = nil
	--[[
	if VMT.basetexture2 then
		if vfs.Exists("materials/" .. VMT.basetexture2:lower() .. ".vmt") then
			print("materials/" .. VMT.basetexture2:lower() .. ".vmt")
			local Material = render.CreateMaterial("model")

			steam.LoadMaterial("materials/" .. VMT.basetexture2:lower() .. ".vmt", Material)
			MergeMaterial = Material
		elseif vfs.Exists("materials/" .. VMT.basetexture2:lower() .. ".vtf") then
			print("materials/" .. VMT.basetexture2:lower() .. ".vtf")
		else
			print("materials/" .. VMT.basetexture2:lower() .. " not found.")
		end
	end
	]]

	local Channels = #Texture.format
	local IsGreyscale = Channels == 1
	local HasAlpha = Channels == 4
	local Header = { 0, 0, IsGreyscale and 3 or 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, bit.band(Texture.width, 0xff), bit.band((bit.rshift(Texture.width, 8)), 0xff), bit.band(Texture.height, 0xff), bit.band((bit.rshift(Texture.height, 8)), 0xff), 8 * Channels, HasAlpha and 8 or 0 }
	local StringHeader = ""

	for Key, Char in ipairs(Header) do
		StringHeader = StringHeader .. string.char(Char)
	end

	--if VMT then
	--	for k, v in pairs(VMT) do
	--		print(tostring(k), tostring(v))
	--	end
	--end

	if Type == "Normal" then

		--[[
		local Average = 0

		for I = 0, Texture.size / Channels do
			if Texture.buffer[I].r > 127 - 16 and Texture.buffer[I].r < 127 + 16 and Texture.buffer[I].g > 127 - 16 and Texture.buffer[I].g < 127 + 16 and Texture.buffer[I].b > 255 - 16 then
				Average = 0
				print("ASSUMING")
				break
			end

			local Normal_X, Normal_Y, Normal_Z = (Texture.buffer[I].r / 255), (Texture.buffer[I].g / 255), (Texture.buffer[I].b / 255)

			local Length = ((Normal_X * Normal_X + Normal_Y * Normal_Y + Normal_Z * Normal_Z) ^ 0.5)

			if Length > 0 then
				Normal_X, Normal_Y, Normal_Z = Normal_X / Length, Normal_Y / Length, Normal_Z / Length
			end

			Normal_X, Normal_Y, Normal_Z = Normal_X * 0.5 + 0.5, Normal_Y * 0.5 + 0.5, Normal_Z * 0.5 + 0.5

			Average = (Average + ((Absolute(Texture.buffer[I].r - Normal_X * 255) + Absolute(Texture.buffer[I].g - Normal_Y * 255) + Absolute(Texture.buffer[I].b - Normal_Z * 255)) / 3)) / 2
		end

		if Average > 86 then
			IsSSBUMP = true
			print("IS SSBUMP! Average: " .. Average)
		end
		]]

		--print("SSBump: " .. tostring(StorableTable.SSBump) .. " FlipXNormal: " .. tostring(StorableTable.FlipXNormal) .. " FlipYNormal: " .. tostring(StorableTable.FlipYNormal))

		for I = 0, Texture.size / Channels do
			local Normal_X, Normal_Y, Normal_Z = Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b

			if StorableTable.SSBump then
				Normal_X, Normal_Y, Normal_Z = (Normal_X / 255), (Normal_Y / 255), (Normal_Z / 255)

				Normal_X = math.max(math.min(BumpBasis[1][1] * Normal_X + BumpBasis[2][1] * Normal_Y + BumpBasis[3][1] * Normal_Z, 1.0), -1.0)
				Normal_Y = math.max(math.min(BumpBasis[1][2] * Normal_X + BumpBasis[2][2] * Normal_Y + BumpBasis[3][2] * Normal_Z, 1.0), -1.0)
				Normal_Z = math.max(math.min(BumpBasis[1][3] * Normal_X + BumpBasis[2][3] * Normal_Y + BumpBasis[3][3] * Normal_Z, 1.0), -1.0)

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

				Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b = math.floor(Normal_X * 255 + 0.5), math.floor(Normal_Y * 255 + 0.5), math.floor(Normal_Z * 255 + 0.5)
			else
				if StorableTable.FlipYNormal then
					Normal_Y = 255 - Normal_Y
				end

				if StorableTable.FlipXNormal then
					Normal_X = 255 - Normal_X
				end

				--Make it Y up.
				Normal_Y = 255 - Normal_Y

				Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b = Normal_X, Normal_Y, Normal_Z
			end
		end
	--[[
	elseif Type == "Albedo" and VMT.blendtintbybasealpha then
		print("Tinting found.")
		for I = 0, Texture.size / Channels do
			local Color_R, Color_G, Color_B, Tint = Texture.buffer[I].r / 255, Texture.buffer[I].g / 255, Texture.buffer[I].b / 255, Texture.buffer[I].a / 255

			Color_R, Color_G, Color_B = math.lerp(Tint, Color_R, 144 / 255), math.lerp(Tint, Color_G, 126 / 255), math.lerp(Tint, Color_B, 94 / 255)

			Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b, Texture.buffer[I].a = Floor(Color_R * 255 + 0.5), Floor(Color_G * 255 + 0.5), Floor(Color_B * 255 + 0.5), 255
		end
	]]
	end

	if VMT.basetexture2 or Material.Albedo2Texture then
		local Texture2
		local Pass = false

		if MergeMaterial and MergeMaterial[Type .. "Texture"].Path:find("materials/") then
			Texture2 = MergeMaterial[Type .. "Texture"]:Download()
			Pass = true
		elseif Type == "Albedo" and Material.Albedo2Texture then
			Texture2 = Material.Albedo2Texture:Download()
			Pass = true
		end

		if Pass then
			if MergeMaterial then
				if #Texture2.format == Channels then
					for Y = 0, Texture.height - 1 do
						for X = 0, Texture.width - 1 do
							local I = Y * Texture.height + X
							local I2 = math.floor((Y / Texture.height) * Texture2.height) * Texture2.height + math.floor((X / Texture.width) * Texture2.width)
							local Color_R, Color_G, Color_B, Merge = Texture.buffer[I].r / 255, Texture.buffer[I].g / 255, Texture.buffer[I].b / 255, Texture.buffer[I].a / 255
							local Color_R2, Color_G2, Color_B2 = Texture2.buffer[I2].r / 255, Texture2.buffer[I2].g / 255, Texture2.buffer[I2].b / 255

							Color_R, Color_G, Color_B = math.lerp(Merge, Color_R2, Color_R), math.lerp(Merge, Color_G2, Color_G), math.lerp(Merge, Color_B2, Color_B)

							Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b, Texture.buffer[I].a = math.floor(Color_R * 255 + 0.5), math.floor(Color_G * 255 + 0.5), math.floor(Color_B * 255 + 0.5), 255
						end
					end
				else
					print("Warning: Could not merge texture. Different format.")
				end
			elseif Material.Albedo2Texture then
				print("Merge case: albedo only")
				local MergeMap = Material.NormalTexture:Download()

				if #Texture2.format == Channels then
					for Y = 0, Texture.height - 1 do
						for X = 0, Texture.width - 1 do
							local I = Y * Texture.height + X
							local I2 = math.floor((Y / Texture.height) * Texture2.height) * Texture2.height + math.floor((X / Texture.width) * Texture2.width)
							local I3 = math.floor((Y / Texture.height) * MergeMap.height) * MergeMap.height + math.floor((X / Texture.width) * MergeMap.width)
							local Color_R, Color_G, Color_B, Merge = Texture.buffer[I].r / 255, Texture.buffer[I].g / 255, Texture.buffer[I].b / 255, MergeMap.buffer[I3].a / 255
							local Color_R2, Color_G2, Color_B2 = Texture2.buffer[I2].r / 255, Texture2.buffer[I2].g / 255, Texture2.buffer[I2].b / 255

							Color_R, Color_G, Color_B = math.lerp(Merge, Color_R2, Color_R), math.lerp(Merge, Color_G2, Color_G), math.lerp(Merge, Color_B2, Color_B)

							Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b = math.floor(Color_R * 255 + 0.5), math.floor(Color_G * 255 + 0.5), math.floor(Color_B * 255 + 0.5)
						end
					end
				else
					print("Warning: Could not merge texture. Different format.")
				end
			end
		else
			print("Warning: Merging failed, merge target has no mapping for '" .. Type .. "'")
		end
	end

	local SwapValue = 0

	if Channels >= 3 then
		if not Texture.swapped then
			for I = 0, Texture.size / Channels do
				SwapValue = Texture.buffer[I].r
				Texture.buffer[I].r = Texture.buffer[I].b
				Texture.buffer[I].b = SwapValue
			end

			Texture.swapped = true
		end
	end

	return StringHeader .. ffi.string(Texture.buffer, Texture.size)
end

local function ConvertReflectionMap(Texture, VMT, StorableTable, Type)
	local Channels = 1
	local IsGreyscale = Channels == 1
	local HasAlpha = Channels == 4
	local Header = { 0, 0, IsGreyscale and 3 or 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, bit.band(Texture.width, 0xff), bit.band((bit.rshift(Texture.width, 8)), 0xff), bit.band(Texture.height, 0xff), bit.band((bit.rshift(Texture.height, 8)), 0xff), 8 * Channels, HasAlpha and 8 or 0 }
	local StringHeader = ""

	for Key, Char in ipairs(Header) do
		StringHeader = StringHeader .. string.char(Char)
	end

	local ArraySize = Texture.size / #Texture.format
	local Buffer = ffi.new("uint8_t[?]", ArraySize)

	if not VMT.basemapalphaphongmask then
		if #Texture.format == 4 then
			for I = 0, ArraySize - 1 do
				Buffer[I] = Texture.buffer[I].a
				Texture.buffer[I].a = 255
			end
		else
			for I = 0, ArraySize - 1 do
				Buffer[I] = 255
			end
		end
	else
		if #Texture.format == 4 then
			for I = 0, ArraySize - 1 do
				Buffer[I] = math.max(math.min((1 - (Texture.buffer[I].a / 255)) ^ 2, 1), 0) * 255
				Texture.buffer[I].a = 255
			end
		else
			for I = 0, ArraySize - 1 do
				Buffer[I] = 0
			end
		end
	end

	return StringHeader .. ffi.string(Buffer, ArraySize)
end

local function ConvertTexture(Material, Texture, VMT, StorableTable, Type, Path2)
	local Path = VMT.fullpath
	local PathNoExt = ""
	local SRGB = Texture.SRGB and "srgb" or "rgba8"

	if Path:find("materials/") and Texture.Path:find("materials/") then
		if not Path2 then
			Path = vfs.RemoveExtensionFromPath(Path:sub(select(1, Path:find("materials/"), #Path)))
			PathNoExt = Path

			local Texture = Texture:Download()
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

			local Texture = Texture:Download()
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
		local Channels = 1
		local IsGreyscale = Channels == 1
		local HasAlpha = Channels == 4
		local Header = { 0, 0, IsGreyscale and 3 or 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, bit.band(1, 0xff), bit.band((bit.rshift(1, 8)), 0xff), bit.band(1, 0xff), bit.band((bit.rshift(1, 8)), 0xff), 8 * Channels, HasAlpha and 8 or 0 }
		local StringHeader = ""

		for Key, Char in ipairs(Header) do
			StringHeader = StringHeader .. string.char(Char)
		end

		if not vfs.Exists(Path .. ".tga") then
			print("Storing texture data in " .. Path .. ".tga")
			vfs.Write(Path .. ".tga", StringHeader .. string.char(0))
		end
	end
end

local function GenerateRoughness(SpecularTexture, VMT, StorableTable, Type, Path2)
	local Path = "data/" .. export_dir .. "/" .. Path2

	if SpecularTexture and SpecularTexture.Path:find("materials/") then
		SpecularTexture = SpecularTexture:Download()
		local Channels = 1
		local IsGreyscale = Channels == 1
		local HasAlpha = Channels == 4
		local Header = { 0, 0, IsGreyscale and 3 or 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, bit.band(SpecularTexture.width, 0xff), bit.band((bit.rshift(SpecularTexture.width, 8)), 0xff), bit.band(SpecularTexture.height, 0xff), bit.band((bit.rshift(SpecularTexture.height, 8)), 0xff), 8 * Channels, HasAlpha and 8 or 0 }
		local StringHeader = ""

		for Key, Char in ipairs(Header) do
			StringHeader = StringHeader .. string.char(Char)
		end

		local ArraySize = SpecularTexture.width * SpecularTexture.height

		if not vfs.Exists(Path .. ".tga") then
			print("Storing texture data in " .. Path .. ".tga")
			vfs.Write(Path .. ".tga", StringHeader .. string.char(255):rep(ArraySize))
		end
	else
		if Type == "Roughness" and not vfs.Exists(Path .. ".tga") then
			local Channels = 1
			local IsGreyscale = Channels == 1
			local HasAlpha = Channels == 4
			local Header = { 0, 0, IsGreyscale and 3 or 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, bit.band(1, 0xff), bit.band((bit.rshift(1, 8)), 0xff), bit.band(1, 0xff), bit.band((bit.rshift(1, 8)), 0xff), 8 * Channels, HasAlpha and 8 or 0 }
			local StringHeader = ""

			for Key, Char in ipairs(Header) do
				StringHeader = StringHeader .. string.char(Char)
			end

			if not vfs.Exists(Path .. ".tga") then
				print("Storing texture data in " .. Path .. ".tga")
				vfs.Write(Path .. ".tga", StringHeader .. string.char(255))
			end
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

			vfs.Write(Path, "") --Ugly hack, it creates the folder and a empty file for path.

			local File = vfs.Open(Path, "write")

			local UsedMaterials = {}
			local SubmeshCount = 0
			local Count = 0
			for Key, SubModel in ipairs(Model.sub_meshes) do
				print("Map: ", Key, SubModel)
				if SubModel.material.vmt then
					local MaterialNameRaw = SubModel.material.vmt.fullpath
					local MaterialName = SubModel.material.vmt.fullpath


					if MaterialName:find("materials/") then
						MaterialName = vfs.RemoveExtensionFromPath(MaterialName:sub(select(1, MaterialName:find("materials/"), #MaterialName)))
					end

					if not UsedMaterials[MaterialName] then
						SubmeshCount = SubmeshCount + 1
						UsedMaterials[MaterialName] = true

						File:Write("o " .. MaterialName .. "\n")

						for Key, SubModel in ipairs(Model.sub_meshes) do
							if SubModel.material.vmt and SubModel.material.vmt.fullpath == MaterialNameRaw then
								local Mesh = SubModel.vertex_buffer
								for I = 0, Mesh.indices_length - 1, 3 do
									Count = Count + 1
									local Index = Mesh.Indices[I]
									local Vertex = string.format("v %.6f %.6f %.6f\n", Mesh.Vertices[Index].pos[0], Mesh.Vertices[Index].pos[1], Mesh.Vertices[Index].pos[2])
									Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", Mesh.Vertices[Index].normal[0], Mesh.Vertices[Index].normal[1], Mesh.Vertices[Index].normal[2])
									--Make vertex coordinate Y up.
									Vertex = Vertex .. string.format("vt %.6f %.6f\n", Mesh.Vertices[Index].uv[0], 1.0 - Mesh.Vertices[Index].uv[1])
									Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

									Count = Count + 1
									Index = Mesh.Indices[I + 1]
									Vertex = Vertex .. string.format("v %.6f %.6f %.6f\n", Mesh.Vertices[Index].pos[0], Mesh.Vertices[Index].pos[1], Mesh.Vertices[Index].pos[2])
									Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", Mesh.Vertices[Index].normal[0], Mesh.Vertices[Index].normal[1], Mesh.Vertices[Index].normal[2])
									--Make vertex coordinate Y up.
									Vertex = Vertex .. string.format("vt %.6f %.6f\n", Mesh.Vertices[Index].uv[0], 1.0 - Mesh.Vertices[Index].uv[1])
									Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

									Count = Count + 1
									Index = Mesh.Indices[I + 2]
									Vertex = Vertex .. string.format("v %.6f %.6f %.6f\n", Mesh.Vertices[Index].pos[0], Mesh.Vertices[Index].pos[1], Mesh.Vertices[Index].pos[2])
									Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", Mesh.Vertices[Index].normal[0], Mesh.Vertices[Index].normal[1], Mesh.Vertices[Index].normal[2])
									--Make vertex coordinate Y up.
									Vertex = Vertex .. string.format("vt %.6f %.6f\n", Mesh.Vertices[Index].uv[0], 1.0 - Mesh.Vertices[Index].uv[1])
									Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

									Vertex = Vertex .. string.format("f %i/%i/%i %i/%i/%i %i/%i/%i\n", Count - 2, Count - 2, Count - 2, Count - 1, Count - 1, Count - 1, Count, Count, Count)
									File:Write(Vertex)
								end
							end
						end
					end
				else
					SubmeshCount = SubmeshCount + 1

					File:Write("o error\n")

					local Mesh = SubModel.vertex_buffer
					for I = 0, Mesh.indices_length - 1, 3 do
						Count = Count + 1
						local Index = Mesh.Indices[I]
						local Vertex = string.format("v %.6f %.6f %.6f\n", Mesh.Vertices[Index].pos[0], Mesh.Vertices[Index].pos[1], Mesh.Vertices[Index].pos[2])
						Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", Mesh.Vertices[Index].normal[0], Mesh.Vertices[Index].normal[1], Mesh.Vertices[Index].normal[2])
						--Make vertex coordinate Y up.
						Vertex = Vertex .. string.format("vt %.6f %.6f\n", Mesh.Vertices[Index].uv[0], 1.0 - Mesh.Vertices[Index].uv[1])
						Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

						Count = Count + 1
						Index = Mesh.Indices[I + 1]
						Vertex = Vertex .. string.format("v %.6f %.6f %.6f\n", Mesh.Vertices[Index].pos[0], Mesh.Vertices[Index].pos[1], Mesh.Vertices[Index].pos[2])
						Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", Mesh.Vertices[Index].normal[0], Mesh.Vertices[Index].normal[1], Mesh.Vertices[Index].normal[2])
						--Make vertex coordinate Y up.
						Vertex = Vertex .. string.format("vt %.6f %.6f\n", Mesh.Vertices[Index].uv[0], 1.0 - Mesh.Vertices[Index].uv[1])
						Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

						Count = Count + 1
						Index = Mesh.Indices[I + 2]
						Vertex = Vertex .. string.format("v %.6f %.6f %.6f\n", Mesh.Vertices[Index].pos[0], Mesh.Vertices[Index].pos[1], Mesh.Vertices[Index].pos[2])
						Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", Mesh.Vertices[Index].normal[0], Mesh.Vertices[Index].normal[1], Mesh.Vertices[Index].normal[2])
						--Make vertex coordinate Y up.
						Vertex = Vertex .. string.format("vt %.6f %.6f\n", Mesh.Vertices[Index].uv[0], 1.0 - Mesh.Vertices[Index].uv[1])
						Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

						Vertex = Vertex .. string.format("f %i/%i/%i %i/%i/%i %i/%i/%i\n", Count - 2, Count - 2, Count - 2, Count - 1, Count - 1, Count - 1, Count, Count, Count)
						File:Write(Vertex)
					end
				end
			end

			File:Close()
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