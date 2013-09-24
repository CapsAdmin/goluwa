
--[[
    2___1
    |  /
   3|/	
]]

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
			if dead == false and done then
				logn(done)
			end

			system.SetWindowTitle(nil, 2)
			return true
		else
			if wait(0.1) or last_why ~= why then
				if why == "inserting lines" then
					system.SetWindowTitle(why .. " " .. msg, 2)
				else
					system.SetWindowTitle(why .. " " .. math.round(msg*100) .. " %", 2)
				end
				
				coroutine.resume(co)
				last_why = why
			end
		end
	end, 1024 * 16)
end

function utilities.ParseHeightmap(tex, size, res, height)	
	
	size = size or 1024
	res = res or 64
	height = height or 128
	
	local data = {}
	local _size = size / res
	
	local function get_height(x, y)
		local r,g,b = tex:GetPixelColor(x/res, y/res)
		
		return (r+g+b) / 3
	end
	
	for y = 0, res do
		for x = 0, res do			
			local z1 = get_height(x, (y+1)) * height -- bottom left
			local z2 = get_height(x, y) * height -- top left
			local z3 = get_height((x+1), y) * height -- top right
			local z4 = get_height((x+1), (y+1)) * height -- bottom right
			
			table_insert(data, {pos = Vec3(x * _size + _size, y * _size, z3)})
			table_insert(data, {pos = Vec3(x * _size, y * _size, z2)})
			table_insert(data, {pos = Vec3(x * _size, y * _size + _size, z1)})
			
			table_insert(data, {pos = Vec3(x * _size, y * _size + _size, z1)})
			table_insert(data, {pos = Vec3(x * _size + _size, y * _size + _size, z4)})
			table_insert(data, {pos = Vec3(x * _size + _size, y * _size, z3)})		
		end
	end
			
	local up = Vec3(0,0,1)
	for _, vertex in pairs(data) do
		vertex.normal = up
		local uv = vertex.pos / size
		vertex.uv = Vec2(uv.y, uv.x)		
	end
	
	return data
end

function utilities.GenerateNormals(data)
	local vertex_normals = {}
	local count = #data/3
	
	for i = 1, count do
	
		local ai = 1+(i-1)*3+0
		local bi = 1+(i-1)*3+1
		local ci = 1+(i-1)*3+2
		
		local a, b, c = data[ai], data[bi], data[ci] 
		local normal = (c.pos - a.pos):Cross(b.pos - a.pos):GetNormalized()

		data[ai].normal = normal
		data[bi].normal = normal
		data[ci].normal = normal
	end
	
	return data
end

function utilities.CreateCube(size, texture_scale)
	size = size or 1
	texture_scale = texture_scale or 1
	
	return 
	{
		-- top
		{pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(size, -size, size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(-size, -size, size), uv = Vec2(0, 0)},
		{pos = Vec3(-size, size, size), uv = Vec2(0, texture_scale)},
		{pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(-size, -size, size), uv = Vec2(0, 0)},

		-- bottom
		{pos = Vec3(-size, -size, -size), uv = Vec2(0, 0)},
		{pos = Vec3(size, -size, -size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(-size, size, -size), uv = Vec2(0, texture_scale)},
		{pos = Vec3(size, -size, -size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(size, size, -size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(-size, size, -size), uv = Vec2(0, texture_scale)},
		
		-- left
		{pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(size, size, -size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(size, -size, -size), uv = Vec2(0, 0)},
		{pos = Vec3(size, -size, size), uv = Vec2(0, texture_scale)},
		{pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(size, -size, -size), uv = Vec2(0, 0)},

		-- right
		{pos = Vec3(-size, -size, -size), uv = Vec2(0, 0)},
		{pos = Vec3(-size, size, -size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(-size, -size, size), uv = Vec2(0, texture_scale)},
		{pos = Vec3(-size, size, -size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(-size, size, size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(-size, -size, size), uv = Vec2(0, texture_scale)},
		
		-- front
		{pos = Vec3(size, -size, size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(size, -size, -size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(-size, -size, -size), uv = Vec2(0, 0)},
		{pos = Vec3(-size, -size, size), uv = Vec2(0, texture_scale)},
		{pos = Vec3(size, -size, size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(-size, -size, -size), uv = Vec2(0, 0)},

		-- back
		{pos = Vec3(-size, size, -size), uv = Vec2(0, 0)},
		{pos = Vec3(size, size, -size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(-size, size, size), uv = Vec2(0, texture_scale)},
		{pos = Vec3(size, size, -size), uv = Vec2(texture_scale, 0)},
		{pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)},
		{pos = Vec3(-size, size, size), uv = Vec2(0, texture_scale)},
	}
end

function utilities.CreateSphere(res)
	res = 32
	local sphereMesh = {}
	
	if false then
		res = res / 2
		
		
		local pi = math.pi
		local pi2 = math.pi * 2
		
		local size = 1 / res
		
		for m = 1, res do
		for n = 1, res do
			local x = math.sin(pi * m/res) * math.cos(pi2 * n/res)
			local y = math.sin(pi * m/res) * math.sin(pi2 * n/res)
			local z = math.cos(pi * m/res)
					   
			table.insert(sphereMesh, {pos = Vec3(x + size, y, z)})
			table.insert(sphereMesh, {pos = Vec3(x, y, z)})
			table.insert(sphereMesh, {pos = Vec3(x, y + size, z)})
			
			table.insert(sphereMesh, {pos = Vec3(x, y + size, z)})
			table.insert(sphereMesh, {pos = Vec3(x + size, y + size, z)})
			table.insert(sphereMesh, {pos = Vec3(x + size, y, z)})
		end
		end
		
		return sphereMesh
	end

	local n = math.round(res * 2)
	local ndiv2 = n/2

	--[[
	Original code by Paul Bourke
	A more efficient contribution by Federico Dosil (below)
	Draw a point for zero radius spheres
	Use CCW facet ordering
	http://paulbourke.net/texture_colour/texturemap/
	]]

	local theta2 = math.pi * 2
	local phi1 = -math.pi / 2
	local phi2 = math.pi / 2
	local r = 1

	local i, j
	local theta1 = 0
	local unodivn = 1/n
	
	local cte3 = (theta2-theta1)/n
	local cte1 = (phi2-phi1)/ndiv2
	local dosdivn = 2*unodivn

	if n < 0 then
		n = -n
		ndiv2 = -ndiv2
	end

	if n < 4 then n = 4 ndiv2=n/2 end
	if r <= 0 then r = 1 end

	local t2 = phi1
	local cost2 = math.cos(phi1)
	local j1divn = 0

	local jdivn,idivn,t1,t3,cost1
	local e,p,e2,p2 = Vec3(), Vec3(), Vec3(), Vec3()

	for j = 1, ndiv2 do

		t1 = t2
		t2 = t2 + cte1
		t3 = theta1 - cte3
		
		cost1 = cost2
		cost2 = math.cos(t2)
		
		e.y = math.sin(t1)
		e2.y = math.sin(t2)
		
		p.y = r * e.y
		p2.y = r * e2.y

		idivn = 0
		jdivn = j1divn
		j1divn = j1divn + dosdivn
		
		for i = 1, n do 
			t3 = t3 + cte3
			
			e.x = cost1 * math.cos(t3)
			e.z = cost1 * math.sin(t3)
			
			p.x = r * e.x
			p.z = r * e.z

			table.insert(sphereMesh, {normal = e:Copy(), uv = Vec2(idivn, jdivn), pos = p:Copy()})

			e2.x = cost2 * math.cos(t3)
			e2.z = cost2 * math.sin(t3)
			
			p2.x = r * e2.x
			p2.z = r * e2.z

			table.insert(sphereMesh, {normal = e2:Copy(), uv = Vec2(idivn, jdivn), pos = p2:Copy()})

			idivn = idivn + unodivn
		end
	end

	return sphereMesh
end