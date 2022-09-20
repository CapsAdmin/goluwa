--print(entities.active_entities[129].model.sub_meshes[1].vertex_buffer.Vertices[1].pos[1])
--entities.active_entities[129].model.sub_meshes[1].material.AlbedoTexture:Download()
--render3d.scene[1].sub_meshes[1].material.AlbedoTexture:Download()
--include("C:\\Users\\Leandro\\Desktop\\GoluwaExportingTools\\exporting_tools.lua")
--local JSON = include("F:\\Backup Outubro 2017\\GoluwaExportingTools\\DKJSON.lua")
local AbsolutePath = vfs.GetAbsolutePath("")
local BumpBasis = {
	{(
		2 ^ 0.5
	) / (
		3 ^ 0.5
	), 0, 1 / (
		3 ^ 0.5
	)},
	{-1 / (
		6 ^ 0.5
	), 1 / (
		2 ^ 0.5
	), 1 / (
		3 ^ 0.5
	)},
	{-1 / (
		6 ^ 0.5
	), -1 / (
		2 ^ 0.5
	), 1 / (
		3 ^ 0.5
	)},
}

local function Mix(X, Y, A)
	return X * (1 - A) + Y * A
end

local FFI = require("ffi")
local BIT = require("bit")
local Floor = math.floor
local Absolute = math.abs
local Maximum = math.max
local Minimum = math.min
local Format = string.format
local Vertex = FFI.typeof([[
	struct {
		float position[3];
		float color[3];
		float texcoord[2];
		float normal[3];
		float tangent[3];
	}
]])
local Vertices = FFI.typeof("$[?]", Vertex)
local Pixel = FFI.typeof([[
	struct {
		uint8_t color[4];
	}
]])
local Pixels = FFI.typeof("$[?]", Pixel)

local function RemoveExtension(Path)
	for I = #Path, 1, -1 do
		if Path:sub(I, I) == "." then return Path:sub(1, I - 1) end
	end

	return Path
end

local function GetFileName(Path)
	for I = #Path, 1, -1 do
		if Path:sub(I, I) == "\\" or Path:sub(I, I) == "/" or I == 1 then
			return Path:sub(I + 1, #Path)
		end
	end

	return Path
end

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
	]] local Channels = #Texture.format
	local IsGreyscale = Channels == 1
	local HasAlpha = Channels == 4
	local Header = {
		0,
		0,
		IsGreyscale and
		3 or
		2,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		BIT.band(Texture.width, 0xff),
		BIT.band((BIT.rshift(Texture.width, 8)), 0xff),
		BIT.band(Texture.height, 0xff),
		BIT.band((BIT.rshift(Texture.height, 8)), 0xff),
		8 * Channels,
		HasAlpha and
		8 or
		0,
	}
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
		]] --print("SSBump: " .. tostring(StorableTable.SSBump) .. " FlipXNormal: " .. tostring(StorableTable.FlipXNormal) .. " FlipYNormal: " .. tostring(StorableTable.FlipYNormal))
		for I = 0, Texture.size / Channels do
			local Normal_X, Normal_Y, Normal_Z = Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b

			if StorableTable.SSBump then
				Normal_X, Normal_Y, Normal_Z = (Normal_X / 255), (Normal_Y / 255), (Normal_Z / 255)
				Normal_X = Maximum(
					Minimum(BumpBasis[1][1] * Normal_X + BumpBasis[2][1] * Normal_Y + BumpBasis[3][1] * Normal_Z, 1.0),
					-1.0
				)
				Normal_Y = Maximum(
					Minimum(BumpBasis[1][2] * Normal_X + BumpBasis[2][2] * Normal_Y + BumpBasis[3][2] * Normal_Z, 1.0),
					-1.0
				)
				Normal_Z = Maximum(
					Minimum(BumpBasis[1][3] * Normal_X + BumpBasis[2][3] * Normal_Y + BumpBasis[3][3] * Normal_Z, 1.0),
					-1.0
				)
				local Length = ((Normal_X * Normal_X + Normal_Y * Normal_Y + Normal_Z * Normal_Z) ^ 0.5)

				if Length > 0 then
					Normal_X, Normal_Y, Normal_Z = Normal_X / Length, Normal_Y / Length, Normal_Z / Length
				end

				if not StorableTable.FlipYNormal then Normal_Y = -Normal_Y end

				if StorableTable.FlipXNormal then Normal_X = -Normal_X end

				--Make it Y up.
				Normal_Y = -Normal_Y
				Normal_X, Normal_Y, Normal_Z = Normal_X * 0.5 + 0.5, Normal_Y * 0.5 + 0.5, Normal_Z * 0.5 + 0.5
				Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b = Floor(Normal_X * 255 + 0.5),
				Floor(Normal_Y * 255 + 0.5),
				Floor(Normal_Z * 255 + 0.5)
			else
				if StorableTable.FlipYNormal then Normal_Y = 255 - Normal_Y end

				if StorableTable.FlipXNormal then Normal_X = 255 - Normal_X end

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

			Color_R, Color_G, Color_B = Mix(Color_R, 144 / 255, Tint), Mix(Color_G, 126 / 255, Tint), Mix(Color_B, 94 / 255, Tint)

			Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b, Texture.buffer[I].a = Floor(Color_R * 255 + 0.5), Floor(Color_G * 255 + 0.5), Floor(Color_B * 255 + 0.5), 255
		end
	]] end

	if VMT.basetexture2 or Material.Albedo2Texture then
		local Texture2
		local Pass = false

		if
			MergeMaterial and
			(
				MergeMaterial[Type .. "Texture"].Path and
				MergeMaterial[Type .. "Texture"].Path:find("materials/")
			)
		then
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
							local I2 = Floor((Y / Texture.height) * Texture2.height) * Texture2.height + Floor((X / Texture.width) * Texture2.width)
							local Color_R, Color_G, Color_B, Merge = Texture.buffer[I].r / 255,
							Texture.buffer[I].g / 255,
							Texture.buffer[I].b / 255,
							Texture.buffer[I].a / 255
							local Color_R2, Color_G2, Color_B2 = Texture2.buffer[I2].r / 255, Texture2.buffer[I2].g / 255, Texture2.buffer[I2].b / 255
							Color_R, Color_G, Color_B = Mix(Color_R2, Color_R, Merge),
							Mix(Color_G2, Color_G, Merge),
							Mix(Color_B2, Color_B, Merge)
							Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b, Texture.buffer[I].a = Floor(Color_R * 255 + 0.5),
							Floor(Color_G * 255 + 0.5),
							Floor(Color_B * 255 + 0.5),
							255
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
							local I2 = Floor((Y / Texture.height) * Texture2.height) * Texture2.height + Floor((X / Texture.width) * Texture2.width)
							local I3 = Floor((Y / Texture.height) * MergeMap.height) * MergeMap.height + Floor((X / Texture.width) * MergeMap.width)
							local Color_R, Color_G, Color_B, Merge = Texture.buffer[I].r / 255,
							Texture.buffer[I].g / 255,
							Texture.buffer[I].b / 255,
							MergeMap.buffer[I3].a / 255
							local Color_R2, Color_G2, Color_B2 = Texture2.buffer[I2].r / 255, Texture2.buffer[I2].g / 255, Texture2.buffer[I2].b / 255
							Color_R, Color_G, Color_B = Mix(Color_R2, Color_R, Merge),
							Mix(Color_G2, Color_G, Merge),
							Mix(Color_B2, Color_B, Merge)
							Texture.buffer[I].r, Texture.buffer[I].g, Texture.buffer[I].b = Floor(Color_R * 255 + 0.5),
							Floor(Color_G * 255 + 0.5),
							Floor(Color_B * 255 + 0.5)
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

	return StringHeader .. FFI.string(Texture.buffer, Texture.size)
end

local function ConvertReflectionMap(Texture, VMT, StorableTable, Type)
	local Channels = 1
	local IsGreyscale = Channels == 1
	local HasAlpha = Channels == 4
	local Header = {
		0,
		0,
		IsGreyscale and
		3 or
		2,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		BIT.band(Texture.width, 0xff),
		BIT.band((BIT.rshift(Texture.width, 8)), 0xff),
		BIT.band(Texture.height, 0xff),
		BIT.band((BIT.rshift(Texture.height, 8)), 0xff),
		8 * Channels,
		HasAlpha and
		8 or
		0,
	}
	local StringHeader = ""

	for Key, Char in ipairs(Header) do
		StringHeader = StringHeader .. string.char(Char)
	end

	local ArraySize = Texture.size / #Texture.format
	local Buffer = FFI.new("uint8_t[?]", ArraySize)

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
				Buffer[I] = Maximum(Minimum((1 - (Texture.buffer[I].a / 255)) ^ 2, 1), 0) * 255
				Texture.buffer[I].a = 255
			end
		else
			for I = 0, ArraySize - 1 do
				Buffer[I] = 0
			end
		end
	end

	return StringHeader .. FFI.string(Buffer, ArraySize)
end

local function ConvertTexture(Material, Texture, VMT, StorableTable, Type, Path2)
	local Path = VMT.fullpath
	local PathNoExt = ""

	if Path then
		local SRGB = Texture.SRGB and "srgb" or "rgba8"

		if Path:find("materials/") and Texture.Path:find("materials/") then
			if not Path2 then
				Path = RemoveExtension(Path:sub(select(1, Path:find("materials/"), #Path)))
				PathNoExt = Path
				local Texture = Texture:Download()
				Path = "data/asset_export/" .. Path

				if
					VMT.basealphaenvmapmask and
					Type == "Albedo" and
					not vfs.Exists(Path .. "_REFLECT.tga")
				then
					print("Storing texture data in " .. Path .. "_REFLECT.tga")
					vfs.Write(Path .. "_REFLECT.tga", ConvertReflectionMap(Texture, VMT, StorableTable, Type))
				end

				if VMT.basemapalphaphongmask and Type == "Albedo" then
					print("Storing texture data in " .. Path .. "_ROUGH.tga")
					vfs.Write(Path .. "_ROUGH.tga", ConvertReflectionMap(Texture, VMT, StorableTable, Type))
				end

				if
					VMT.blendtintbybasealpha and
					Type == "Albedo" and
					not vfs.Exists(Path .. "_TINT.tga")
				then
					print("Storing texture data in " .. Path .. "_TINT.tga")
					vfs.Write(Path .. "_TINT.tga", ConvertReflectionMap(Texture, VMT, StorableTable, Type))
				end

				if not vfs.Exists(Path .. ".tga") then
					print("Storing texture data in " .. Path .. ".tga")
					vfs.Write(
						Path .. ".tga",
						ConvertTextureToString(Material, Texture, VMT, StorableTable, Type)
					)
				end
			else
				PathNoExt = Path2
				local Texture = Texture:Download()
				Path = "data/asset_export/" .. Path2
				local OriginalPath = Path:sub(1, #Path - 4)

				if
					VMT.normalmapalphaenvmapmask and
					Type == "Normal" and
					not vfs.Exists(OriginalPath .. "_REFLECT.tga")
				then
					print("Storing texture data in " .. OriginalPath .. "_REFLECT.tga")
					vfs.Write(
						OriginalPath .. "_REFLECT.tga",
						ConvertReflectionMap(Texture, VMT, StorableTable, Type)
					)
				end

				if not vfs.Exists(Path .. ".tga") then
					print("Storing texture data in " .. Path .. ".tga")

					if Type ~= "Metallic" then
						vfs.Write(
							Path .. ".tga",
							ConvertTextureToString(Material, Texture, VMT, StorableTable, Type)
						)
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
	end

	return PathNoExt
end

function GenerateReflection(SpecularTexture, VMT, StorableTable, Type, Path2)
	local Path = "data/asset_export/" .. Path2

	if not vfs.Exists(Path) then
		local Channels = 1
		local IsGreyscale = Channels == 1
		local HasAlpha = Channels == 4
		local Header = {
			0,
			0,
			IsGreyscale and
			3 or
			2,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			BIT.band(1, 0xff),
			BIT.band((BIT.rshift(1, 8)), 0xff),
			BIT.band(1, 0xff),
			BIT.band((BIT.rshift(1, 8)), 0xff),
			8 * Channels,
			HasAlpha and
			8 or
			0,
		}
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

function GenerateRoughness(SpecularTexture, VMT, StorableTable, Type, Path2)
	local Path = "data/asset_export/" .. Path2

	if SpecularTexture and SpecularTexture.Path:find("materials/") then
		SpecularTexture = SpecularTexture:Download()
		local Channels = 1
		local IsGreyscale = Channels == 1
		local HasAlpha = Channels == 4
		local Header = {
			0,
			0,
			IsGreyscale and
			3 or
			2,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			BIT.band(SpecularTexture.width, 0xff),
			BIT.band((BIT.rshift(SpecularTexture.width, 8)), 0xff),
			BIT.band(SpecularTexture.height, 0xff),
			BIT.band((BIT.rshift(SpecularTexture.height, 8)), 0xff),
			8 * Channels,
			HasAlpha and
			8 or
			0,
		}
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
			local Header = {
				0,
				0,
				IsGreyscale and
				3 or
				2,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				BIT.band(1, 0xff),
				BIT.band((BIT.rshift(1, 8)), 0xff),
				BIT.band(1, 0xff),
				BIT.band((BIT.rshift(1, 8)), 0xff),
				8 * Channels,
				HasAlpha and
				8 or
				0,
			}
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

----------------------------------------------------------------------------------
-- Transforma uma tabela em uma string.
-- @param #table
-- @return #string
function table.tostring(Object, Index)
	Index = Index or 0
	local Tabbing = ""
	local Output = ""

	if Index > 0 then
		Tabbing = Tabbing .. ("\t"):rep(Index)

		if table.count(Object) == 0 then
			Output = Format("\n%s{", Tabbing)
		else
			Output = Format("\n%s", Tabbing)
		end
	end

	for Key, Value in pairs(Object) do
		if type(Value) == "table" then
			if type(Key) == "number" then
				Output = Format(
					"%s\n%s\t[%s] = %s, ",
					Output,
					Tabbing,
					tostring(Key),
					table.tostring(Value, Index + 1)
				)
			else
				Output = Format(
					"%s\n%s\t['%s'] = %s, ",
					Output,
					Tabbing,
					tostring(Key):replace("\\", "\\\\"):replace("'", "\\'"):replace("\"", "\\\""),
					table.tostring(Value, Index + 1)
				)
			end
		else
			if type(Value) == "number" or type(Value) == "boolean" then
				if type(Key) == "number" or type(Key) == "boolean" then
					Output = Format("%s\n%s\t[%s] = %s, ", Output, Tabbing, tostring(Key), tostring(Value))
				elseif type(Key) == "string" then
					Output = Format(
						"%s\n%s\t['%s'] = %s, ",
						Output,
						Tabbing,
						tostring(Key):replace("\\", "\\\\"):replace("'", "\\'"):replace("\"", "\\\""),
						tostring(Value)
					)
				else
					Output = Format("%s\n%t\t%s = %s, ", Output, Tabbing, tostring(Key), tostring(Value))
				end
			else
				if type(Key) == "number" or type(Key) == "boolean" then
					local Value = tostring(Value)

					if Value:find("\n") or Value:find("\r") then
						Output = Format(
							"%s\n%s\t[%s] = [=[%s]=], ",
							Output,
							Tabbing,
							tostring(Key),
							Value:replace("=", "\\61")
						)
					else
						Output = Format(
							"%s\n%s\t[%s] = '%s', ",
							Output,
							Tabbing,
							tostring(Key),
							Value:replace("\\", "\\\\"):replace("'", "\\'"):replace("\"", "\\\"")
						)
					end
				elseif type(Key) == "string" then
					local Value = tostring(Value)

					if Value:find("\n") or Value:find("\r") then
						Output = Format(
							"%s\n%s\t['%s'] = [=[%s]=], ",
							Output,
							Tabbing,
							tostring(Key):replace("\\", "\\\\"):replace("'", "\\'"):replace("\"", "\\\""),
							Value:replace("=", "\\61")
						)
					else
						Output = Format(
							"%s\n%s\t['%s'] = '%s', ",
							Output,
							Tabbing,
							tostring(Key):replace("\\", "\\\\"):replace("'", "\\'"):replace("\"", "\\\""),
							Value:replace("'", "\\'"):replace("\"", "\\\"")
						)
					end
				else
					local Value = tostring(Value)

					if Value:find("\n") or Value:find("\r") then
						Output = Format(
							"%s\n%s\t%s = [=[%s]=]",
							Output,
							Tabbing,
							tostring(Key),
							Value:replace("=", "\\61")
						)
					else
						Output = Format(
							"%s\n%s\t%s = '%s', ",
							Output,
							Tabbing,
							tostring(Key),
							Value:replace("\\", "\\\\"):replace("'", "\\'"):replace("\"", "\\\"")
						)
					end
				end
			end
		end
	end

	Output = Format("{%s\n%s}", string.sub(Output, 0, #Output - 1), Tabbing)
	return Output
end

local function ConvertModel(Model)
	local Path = Model.ModelPath
	local IsMap = false
	local IsModel = false

	if Path:find("models/") then IsModel = true end

	if Path:find("maps/") then IsMap = true end

	if IsModel or IsMap then
		if IsModel then
			Path = RemoveExtension(Path:sub(select(1, Path:find("models/"), #Path)))
		end

		if IsMap then
			Path = "models/" .. GetFileName(RemoveExtension(Path:sub(select(1, Path:find("maps/"), #Path))))
		end

		local Path2 = "asset_export/" .. Path .. ".obj"
		Path = "data/asset_export/" .. Path .. ".obj"

		--print(table.tostring(Model.sub_meshes))
		if not vfs.Exists(Path) then vfs.Write(Path, Model:ToOBJ()) end
	end
end

function ExportLevel()
	local MapData = {}
	local SunDirection = entities.GetWorld():GetSunAngles()
	MapData[1] = {
		AngleX = SunDirection.x,
		AngleY = SunDirection.y,
		AngleZ = SunDirection.z,
	}
	local MapPath = ""

	for Key, Entity in ipairs(entities.GetAll()) do
		if Entity.model then
			local Path = Entity.model.ModelPath
			local IsMap = false
			local IsModel = false

			if Path:find("models/") then IsModel = true end

			if Path:find("maps/") then
				MapPath = RemoveExtension(Path)
				IsMap = true
			end

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

			if IsModel then
				Path = RemoveExtension(Path:sub(select(1, Path:find("models/"), #Path))) .. ".obj"
			end

			if IsMap then
				Path = "models/" .. GetFileName(RemoveExtension(Path:sub(select(1, Path:find("maps/"), #Path)))) .. ".obj"
			end

			EntityData.Model = Path
			EntityData.Materials = {}

			for Key, SubModel in pairs(Entity.model.sub_meshes) do
				local MaterialOrData = SubModel.material or SubModel.data

				if MaterialOrData then
					local MaterialStorage = MaterialOrData:GetStorableTable()

					if MaterialStorage.AlbedoTexture then
						local Material = {}
						local VMT = MaterialOrData.vmt

						if VMT then
							if VMT.basetexture2 and not MaterialStorage.Albedo2Texture then
								if vfs.Exists("materials/" .. VMT.basetexture2:lower() .. ".vtf") then
									print("Adding Albedo2Texture materials/" .. VMT.basetexture2:lower() .. ".vtf")
									MaterialStorage.Albedo2Texture = Texture("materials/" .. VMT.basetexture2:lower() .. ".vtf")
								end
							end

							local PathNoExt = ConvertTexture(MaterialStorage, MaterialStorage.AlbedoTexture, VMT, MaterialStorage, "Albedo")
							Material.Albedo = PathNoExt .. ".tga"

							if not VMT.basemapalphaphongmask then
								if
									MaterialStorage.RoughnessTexture and
									MaterialStorage.RoughnessTexture.Path:find("materials/")
								then
									ConvertTexture(
										MaterialStorage,
										MaterialStorage.RoughnessTexture,
										VMT,
										MaterialStorage,
										"Roughness",
										PathNoExt .. "_ROUGH"
									)
								else
									GenerateRoughness(MaterialStorage.MetallicTexture, VMT, MaterialStorage, "Roughness", PathNoExt .. "_ROUGH")
								end

								Material.Roughness = PathNoExt .. "_ROUGH.tga"
							end

							if MaterialStorage.NormalTexture then
								ConvertTexture(
									MaterialStorage,
									MaterialStorage.NormalTexture,
									VMT,
									MaterialStorage,
									"Normal",
									PathNoExt .. "_NRM"
								)
								Material.Normal = PathNoExt .. "_NRM.tga"
							end

							if MaterialStorage.SkyTexture then
								ConvertTexture(
									MaterialStorage,
									MaterialStorage.SkyTexture,
									VMT,
									MaterialStorage,
									"Sky",
									PathNoExt .. "_SKY"
								)
								Material.Sky = PathNoExt .. "_SKY.tga"
							end

							if MaterialStorage.MetallicTexture and not VMT.basemapalphaphongmask then
								if MaterialStorage.RoughnessTexture.Path:find("materials/") then
									ConvertTexture(
										MaterialStorage,
										MaterialStorage.MetallicTexture,
										VMT,
										MaterialStorage,
										"Metallic",
										PathNoExt .. "_SPEC"
									)
								else
									GenerateReflection(MaterialStorage.MetallicTexture, VMT, MaterialStorage, "Metallic", PathNoExt .. "_SPEC")
								end

								Material.Specular = PathNoExt .. "_SPEC.tga"
							end
						end

						EntityData.Materials[#EntityData.Materials + 1] = Material
					end
				end
			end

			MapData[#MapData + 1] = EntityData
			pcall(ConvertModel, Entity.model)
		end
	end

	if not vfs.Exists("data/asset_export/" .. MapPath .. ".txt") then
		print("Storing map data in data/asset_export/" .. MapPath .. ".txt")
		--serializer.WriteFile("json", "data/asset_export/" .. MapPath .. ".txt", MapData)
		vfs.Write("data/asset_export/" .. MapPath .. ".txt", serializer.Encode("json", MapData))
	end
end

print("Export level loaded")