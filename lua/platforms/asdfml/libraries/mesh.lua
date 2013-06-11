local table_insert = table.insert

function utilities.ParseObj(data, callback, generate_normals)
	local co = coroutine.create(function()
		
		local positions = {}
		local texcoords = {}
		local normals = {}
		
		local output = {}
		
		local lines = {}
		
		local i = 1
		for line in data:gmatch("(.-)\n") do
			local parts = line:gsub("%s+", " "):trim():explode(" ")

			table_insert(lines, parts)
			coroutine.yield(false, "inserting lines", i)
			i = i + 1
		end
	
		local vert_count = #lines
	
		for i, parts in pairs(lines) do		
			if parts[1] == "v" and #parts >= 4 then
				table_insert(positions, Vec3(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])))
			elseif parts[1] == "vt" and #parts >= 3 then
				table_insert(texcoords, Vec2(tonumber(parts[2]), tonumber(1 - parts[3])))
			elseif not generate_normals and parts[1] == "vn" and #parts >= 4 then
				table_insert(normals, Vec3(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])):GetNormalized())
			end
			
			coroutine.yield(false, "parsing lines", (i/vert_count))
		end
				
		for i, parts in pairs(lines) do
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
			
			coroutine.yield(false, "solving indices", i/vert_count)
		end
		
		if generate_normals then
			local vertex_normals = {}
			local count = #output/3
			for i = 1, count do
				local a, b, c = output[1+(i-1)*3+0], output[1+(i-1)*3+1], output[1+(i-1)*3+2] 
				local normal = (c.pos - a.pos):Cross(b.pos - a.pos):GetNormalized()

				vertex_normals[a.pos_index] = vertex_normals[a.pos_index] or Vec3()
				vertex_normals[a.pos_index] = (vertex_normals[a.pos_index] + normal)

				vertex_normals[b.pos_index] = vertex_normals[b.pos_index] or Vec3()
				vertex_normals[b.pos_index] = (vertex_normals[b.pos_index] + normal)

				vertex_normals[c.pos_index] = vertex_normals[c.pos_index] or Vec3()
				vertex_normals[c.pos_index] = (vertex_normals[c.pos_index] + normal)
				coroutine.yield(false, "generating normals", i/count)
			end
			
			local default_normal = Vec3(0, 0, -1)

			local count = #output
			for i = 1, count do
				local n = vertex_normals[output[i].pos_index] or default_normal
				n:Normalize()
				normals[i] = n
				output[i].normal = n
				coroutine.yield(false, "smoothing normals", i/count)
			end
		end
		
		callback(output)
		coroutine.yield(true)
	end)
	
	local last_why
	
	timer.Thinker(function() 
		local dead, done, why, msg = coroutine.resume(co)
		
		if done then
			mmyy.SetWindowTitle(nil, 2)
			return true
		else
			if wait(0.1) or last_why ~= why then
				if why == "inserting lines" then
					mmyy.SetWindowTitle(why .. " " .. msg, 2)
				else
					mmyy.SetWindowTitle(why .. " " .. math.round(msg*100) .. " %", 2)
				end
				
				coroutine.resume(co)
				last_why = why
			end
		end
	end, 1024 * 16)
end

local cache = {}

function Mesh(data)
	check(data, "table")
	
	local vbo = cache[data]
	
	if vbo then 
		return vbo
	else	
		vbo = render.CreateVBO(data)
		
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