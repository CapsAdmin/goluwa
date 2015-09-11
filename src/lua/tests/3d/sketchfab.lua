local id = "e8eabe00779a4f5bb8ca8a4c7190f436"
local output_folder = "downloads/models/sketchfab/" .. id .. "/"

local function parse_scene(id)

	local tbl = serializer.ReadFile("json", output_folder .. "file.osgjs")

	local function huh(node, parent)
		if node["osg.Node"] then
			for i, v in ipairs(node["osg.Node"].Children) do
				huh(v, node["osg.Node"])
			end
		end
		
		if node["osg.Geometry"] then 
			for name, info in pairs(node["osg.Geometry"].VertexAttributeList) do
				if info.Array then
					local t, info = next(info.Array)
					if info then
						if name == "Vertex" then
							local file = vfs.Open(output_folder .. info.File:match("(.+)%.gz"))
							local ints = {}
							
							for i = 1, math.huge do
								ints[i] = (file:ReadVarInt()-(0xFFFF/2))/32000
								if file:GetPosition() >= file:GetSize() then break end
							end
							
							--if true then
								local vertices = {}
								
								--[[for i = 1, math.huge do
									vertices[i] = Vec3(file:ReadVarInt(), file:ReadVarInt(), file:ReadVarInt())
									if file:GetPosition() >= info.Offset + info.Size then
										break
									end
								end]]
								
								local asdf = 1
								for i = 0, info.Size, 3 do
									vertices[asdf] = Vec3(ints[info.Offset + i + 1], ints[info.Offset + i + 2], ints[info.Offset + i + 3])
									asdf = asdf + 1
								end
								
								table.print(vertices)
							--end
						
							if false then	
								local t, info = next(node["osg.Geometry"].PrimitiveSetList[1].DrawElementsUInt.Indices.Array)
								
								local indices = {}
								
								file:SetPosition(info.Offset) 
								
								--[[for i = 1, math.huge do
									indices[i] = file:ReadVarInt()
									if file:GetPosition() >= info.Offset + info.Size then
										break
									end
								end]]
								for i = 1, info.Size do
									indices[i] = file:ReadVarInt()
								end
								--header_callback
								--table.print(indices)
							end
							--do return end
							local mesh = render.CreateMeshBuilder()
							for _, pos in ipairs(vertices) do
								mesh:AddVertex({pos = pos})
							end
							--for _, index in ipairs(indices) do
								--print(vertices[index], index)
								--mesh:AddVertex({pos = vertices[index]})
						--	end
							
							mesh:Upload()
							
							prototype.SafeRemove(TEST)
							
							local model = entities.CreateEntity("visual")
							model:AddMesh(mesh)
							
							TEST = model
						end
					end
				end
			end
		end 
	end
	
	huh(tbl)
end


sockets.Download("https://sketchfab.com/models/" .. id .. "/embed", function(str)
	local tbl = serializer.Decode("json", str:match('prefetchedData%[ "/i/models/' .. id .. '" %] = (%b{})'))
	local url = tbl.files.polygon.url
	
	print(url)
			
	sockets.Download(url, function(str)
		str = serializer.Decode("gunzip", str)
		local tbl = serializer.Decode("json", str)
				
		vfs.CreateFolders("os", output_folder)
		vfs.Write(output_folder .. "file.osgjs", str)
		
		local downloaded = {}
			
		for path in str:gmatch('"File": "(.-)"') do
			if not downloaded[path] then
				print(url:match("(.+/)") .. path)
				sockets.Download(url:match("(.+/)") .. path, function(str)
					str = serializer.Decode("gunzip", str)
					vfs.Write(output_folder .. path:match("(.+)%.gz"), str)
					downloaded[path] = nil
					if table.count(downloaded) == 1 then
						--parse_scene(id)
					end
				end)
				downloaded[path] = true
			end
		end
	end)
	
	local tbl = serializer.Decode("json", str:match('prefetchedData%[ "/i/models/' .. id .. '/textures" %] = (%b{})'))

	for i,v in ipairs(tbl.results) do
		sockets.Download(v.images[1].url, function(str)
			vfs.Write(output_folder .. v.name, str)
		end)
	end
end)