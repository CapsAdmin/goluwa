local table_insert = table.insert

function utilities.ParseObj(data, generate_normals)
	
	local positions = {}
	local texcoords = {}
	local normals = {}
	
	local output = {}
	
	local lines = {}
	
	for i in data:gmatch("(.-)\n") do
		local parts = i:gsub("%s+", " "):trim():explode(" ")

		table_insert(lines, parts)
	end
		
	for _, parts in pairs(lines) do		
		if parts[1] == "v" and #parts >= 4 then
			table_insert(positions, Vec3(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])))
		elseif parts[1] == "vt" and #parts >= 3 then
			table_insert(texcoords, Vec2(tonumber(parts[2]), tonumber(1 - parts[3])))
		elseif not generate_normals and parts[1] == "vn" and #parts >= 4 then
			table_insert(normals, Vec3(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])):GetNormalized())
		end
	end
		
	for _, parts in pairs(lines) do
		if parts[1] == "f" and #parts > 3 then
			local first, previous

			for i = 2, #parts do
				local current = parts[i]:explode("/")

				if i == 2 then
					first = current
				end
				
				if i >= 4 then
					local v1, v2, v3 = {}, {}, {}

					v1.pos_index = tonumber(first[1])
					v2.pos_index = tonumber(current[1])
					v3.pos_index = tonumber(previous[1])
					
					v1.pos = positions[tonumber(first[1])]
					v2.pos = positions[tonumber(current[1])]
					v3.pos = positions[tonumber(previous[1])]
					
					if #texcoords > 0 then
						v1.uv = texcoords[tonumber(first[2])]
						v2.uv = texcoords[tonumber(current[2])]
						v3.uv = texcoords[tonumber(previous[2])]
					end
					
					if #normals > 0 then
						v1.normal = normals[tonumber(first[3])]
						v2.normal = normals[tonumber(current[3])]
						v3.normal = normals[tonumber(previous[3])]
					end				
					
					table_insert(output, v1)
					table_insert(output, v2)
					table_insert(output, v3)
				end

				previous = current
			end
		end
	end
	
	if generate_normals then
		local vertex_normals = {}

		for i = 1, #output/3 do
			local a, b, c = output[1+(i-1)*3+0], output[1+(i-1)*3+1], output[1+(i-1)*3+2] 
			local normal = (c.pos - a.pos):Cross(b.pos - a.pos):GetNormalized()

			vertex_normals[a.pos_index] = vertex_normals[a.pos_index] or Vec3()
			vertex_normals[a.pos_index] = (vertex_normals[a.pos_index] + normal)

			vertex_normals[b.pos_index] = vertex_normals[b.pos_index] or Vec3()
			vertex_normals[b.pos_index] = (vertex_normals[b.pos_index] + normal)

			vertex_normals[c.pos_index] = vertex_normals[c.pos_index] or Vec3()
			vertex_normals[c.pos_index] = (vertex_normals[c.pos_index] + normal)
		end

		local default_normal = Vec3(0, 0, -1)

		for i = 1, #output do
			local n = vertex_normals[output[i].pos_index] or default_normal
			n:Normalize()
			normals[i] = n
			output[i].normal = n
		end
	end
	
	return output
end

local cache = {}

function Mesh(data, ...)
	check(data, "string", "table")
	
	local vbo = cache[data]
	
	if vbo then 
		return vbo
	else
		local tbl = type(data) == "string" and utilities.ParseObj(data, ...) or tbl
	
		vbo = render.CreateVBO(tbl)
		
		local mesh = {
			Draw = function() 
				render.DrawVBO(vbo) 
			end, 
			
			GetVertexBuffer = function() 
				return vbo
			end
		}
		
		cache[data] = mesh
		
		return mesh
	end
end