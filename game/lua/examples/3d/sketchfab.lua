local id = "e8eabe00779a4f5bb8ca8a4c7190f436"
local output_folder = "data/downloads/models/sketchfab/" .. id .. "/"

local function parse_scene(id)

	local tbl = serializer.ReadFile("json", output_folder .. "file.osgjs")

	local function huh(node, parent)
		if node["osg.Node"] then
			for i, v in ipairs(node["osg.Node"].Children) do
				huh(v, node["osg.Node"])
			end
		end

		if node["osg.Geometry"] and node["osg.Geometry"].UserDataContainer.Values[1].Name ~= "wireframe" then
			local function swap_endian(num, size)
				local result = 0
				for shift = 0, size - 8, 8 do
					result = bit.bor(bit.lshift(result, 8),
							bit.band(bit.rshift(num, shift), 0xff))
				end
				return result
			end

			local indices = {}
			local vertices = {}

			for _, info in pairs(node["osg.Geometry"].PrimitiveSetList) do
				if info.DrawElementsUInt and info.DrawElementsUInt.Indices.Type == "ELEMENT_ARRAY_BUFFER" then
					local item_size = info.DrawElementsUInt.Indices.ItemSize
					local t, info = next(info.DrawElementsUInt.Indices.Array)
					local file = vfs.Open(output_folder .. info.File:match("(.+)%.gz"))
					file:SetPosition(info.Offset)

					for i = 1, info.Size do
						table.insert(indices, file:ReadUnsignedInt())
					end

					local type_size = require("ffi").sizeof(info.Encoding == "varint" and "uint8_t" or t:lower():gsub("Array", "_t"))
					file:SetPosition(info.Offset)
					print("indices",t,info.Encoding, ":")
					print(file:ReadBytes(info.Size * (type_size * item_size)):dumphex())
				end
			end

			for name, info in pairs(node["osg.Geometry"].VertexAttributeList) do
				local item_size = info.ItemSize
				if info.Array then
					local t, info = next(info.Array)
					if info then
						if name == "Vertex" then
							local file = vfs.Open(output_folder .. info.File:match("(.+)%.gz"))
							file:SetPosition(info.Offset)
							for i = 1, info.Size do
								vertices[i] = vertices[i] or {}
								vertices[i].pos = Vec3(file:ReadByte(), file:ReadByte(), file:ReadByte())
							end

							local type_size = require("ffi").sizeof(info.Encoding == "varint" and "uint8_t" or t:lower():gsub("Array", "_t"))
							file:SetPosition(info.Offset)
							print("vertices", t,info.Encoding, ":")
							print(file:ReadBytes(info.Size * (type_size * item_size)):dumphex())
						end

						if name == "Normal" then
							local file = vfs.Open(output_folder .. info.File:match("(.+)%.gz"))
							file:SetPosition(info.Offset)
							for i = 1, info.Size do
								vertices[i] = vertices[i] or {}
								vertices[i].normal = Vec3(file:ReadByte(), file:ReadByte(), file:ReadByte()) / 255
							end

							local type_size = require("ffi").sizeof(info.Encoding == "varint" and "uint8_t" or t:lower():gsub("Array", "_t"))
							file:SetPosition(info.Offset)
							print("normals", t,info.Encoding, ":")
							print(file:ReadBytes(info.Size * (type_size * item_size)):dumphex())
						end
					end
				end
			end

			if render3d.IsGBufferReady() then
				local mesh = gfx.CreatePolygon3D()
				mesh:SetVertices(vertices)
				mesh:AddSubModel(vertices)
				mesh:Upload()

				prototype.SafeRemove(TEST)
				local model = entities.CreateEntity("visual")
				model:AddSubModel(mesh)
				TEST = model
			end
		end
	end

	huh(tbl)
end

if vfs.IsFile(output_folder .. "file.osgjs") then
	parse_scene(id)
	return
end

local function temp_ssl_download(url, callback)
	local p = io.popen("wget -O - -o /dev/null " .. url)
	local str = p:read("*all")
	p:close()
	callback(str)
end

sockets.Download("https://sketchfab.com/models/" .. id .. "/embed", function(str)
	str = str:match('prefetchedData%[ "/i/models/' .. id .. '" %] = (%b{})')
	str = str:gsub("\r", "\n")
	str = str:gsub("\n.*\n", "")

	local tbl = serializer.Decode("json", str)
	local url = tbl.files[1].osgjsUrl

	--sockets.Download(url, function(str)
	temp_ssl_download(url, function(str)
		str = serializer.Decode("gunzip", str)
		local tbl = serializer.Decode("json", str)

		vfs.CreateDirectory("os:" .. output_folder)
		vfs.Write(output_folder .. "file.osgjs", str)

		local downloaded = {}

		for path in str:gmatch('"File": "(.-)"') do
			if not downloaded[path] then
				downloaded[path] = true
				temp_ssl_download(url:match("(.+/)") .. path, function(str)
					str = serializer.Decode("gunzip", str)
					vfs.CreateDirectoriesFromPath("os:" .. output_folder .. path:match("(.+)%.gz"))
					vfs.Write(output_folder .. path:match("(.+)%.gz"), str)
					downloaded[path] = nil
					if table.count(downloaded) == 1 then
						parse_scene(id)
					end
				end)
			end
		end
	end)
do return end
	local tbl = serializer.Decode("json", str:match('prefetchedData%[ "/i/models/' .. id .. '/textures" %] = (%b{})'))

	for i,v in ipairs(tbl.results) do
		sockets.Download(v.images[1].url, function(str)
			vfs.Write(output_folder .. v.name, str)
		end)
	end
end)