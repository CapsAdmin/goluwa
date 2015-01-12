local render = ... or _G.render

local META = prototype.CreateTemplate("mesh_builder")
	
prototype.GetSet(META, "Vertices", {})
prototype.GetSet(META, "Indices")
prototype.GetSet(META, "BBMin", Vec3())
prototype.GetSet(META, "BBMax", Vec3())

function render.CreateMeshBuilder()
	return prototype.CreateObject(META)
end

function META:AddVertex(vertex)
	table.insert(self.Vertices, vertex)
end

function META:Clear()
	table.clear(self.Vertices)
	if self.Indices then table.clear(self.Indices) end
end


function META:Upload(skip_unref)
	if #self.Vertices == 0 then return end
	
	self.mesh = render.CreateMesh(self.Vertices, self.Indices)
	-- don't store the geometry on the lua side
	if not skip_unref then
		self.mesh:UnreferenceMesh()
		self:Clear()
	end
end

function META:GetMesh()
	return self.mesh
end
	
function META:Export(path)
	
end

function META:Draw()
	if self.mesh then
		self.mesh:Draw()
	end
end

do -- helpers
	function META:BuildBoundingBox()	
		local min = Vec3()
		local max = Vec3()
		
		for _, vertex in ipairs(self.Vertices) do
			if vertex.pos.x < min.x then min.x = vertex.pos.x end
			if vertex.pos.y < min.y then min.y = vertex.pos.y end
			if vertex.pos.z < min.z then min.z = vertex.pos.z end
			
			if vertex.pos.x > max.x then max.x = vertex.pos.x end
			if vertex.pos.y > max.y then max.y = vertex.pos.y end
			if vertex.pos.z > max.z then max.z = vertex.pos.z end
		end
		
		self.BBMin = min
		self.BBMax = max
		
		return min, max
	end

	function META:BuildNormals()
		for i = 1, #self.Vertices, 3 do

			local ai = i + 0
			local bi = i + 1
			local ci = i + 2
			
			local a, b, c = self.Vertices[ai], self.Vertices[bi], self.Vertices[ci] 
			local normal = (a.pos - b.pos):Cross(b.pos - c.pos):GetNormalized()
			normal = -Vec3(normal.x, normal.y, normal.z)
			
			self.Vertices[ai].normal = normal
			self.Vertices[bi].normal = normal
			self.Vertices[ci].normal = normal
		end
	end

	function META:SmoothNormals()
		local temp = {}
			
		local i = 1
		
		for _, vertex in ipairs(self.Vertices) do
			local x, y, z = vertex.pos.x, vertex.pos.y, vertex.pos.z
				
			temp[x] = temp[x] or {}
			temp[x][y] = temp[x][y] or {}		
			temp[x][y][z] = temp[x][y][z] or {}
			
			temp[x][y][z][i] = vertex
			i = i + 1
		end
		
		local found = 0
		
		for _, x in pairs(temp) do		
			for _, y in pairs(x) do		
				for _, z in pairs(y) do
					
					local normal = Vec3(0)

					for _, vertex in pairs(z) do	
						normal = normal + vertex.normal
					end
					
					normal:Normalize()		
				
					for _, vertex in pairs(z) do				
						vertex.normal = normal
					end
				end
			end
		end
	end
	
	--[[
		2___1
		|  /
	   3|/	
	]]

	function META:LoadObj(data, callback, generate_normals)
		local thread = utility.CreateThread()
		function thread:OnStart()		
			local positions = {}
			local texcoords = {}
			local normals = {}
			
			local output = {}
			
			local lines = {}
			
			local i = 1
			for line in data:gmatch("(.-)\n") do
				local parts = line:gsub("%s+", " "):trim():explode(" ")

				table.insert(lines, parts)
				self:ReportProgress("inserting lines", math.huge)
				self:Sleep()
				i = i + 1
			end
		
			local vert_count = #lines
		
			for i, parts in pairs(lines) do		
				if parts[1] == "v" and #parts >= 4 then
					table.insert(positions, Vec3(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])))
				elseif parts[1] == "vt" and #parts >= 3 then
					table.insert(texcoords, Vec2(tonumber(parts[2]), tonumber(parts[3])))
				elseif not generate_normals and parts[1] == "vn" and #parts >= 4 then
					table.insert(normals, Vec3(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])):GetNormalized())
				end
				
				self:ReportProgress("parsing lines", vert_count)
				self:Sleep()
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
							
							table.insert(output, v1)
							table.insert(output, v2)
							table.insert(output, v3)
						end

						previous = current
					end
				end
				
				self:ReportProgress("solving indices", vert_count)
				self:Sleep()
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
					self:ReportProgress("generating normals", count)
					self:Sleep()
				end
				
				local default_normal = Vec3(0, 0, -1)

				local count = #output
				for i = 1, count do
					local n = vertex_normals[output[i].pos_index] or default_normal
					n:Normalize()
					normals[i] = n
					output[i].normal = n
					self:ReportProgress("smoothing normals", count)
					self:Sleep()
				end
			end
			
			return output
		end
		
		function thread:OnFinish(output)
			callback(output)
		end
		
		thread:SetIterationsPerTick(1024 * 16)
		
		thread:Start()
	end

	function META:CreateCube(size, texture_scale)
		size = size or 1
		texture_scale = texture_scale or 1

		-- top
		self:AddVertex({pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(size, -size, size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(-size, -size, size), uv = Vec2(0, 0)})
		self:AddVertex({pos = Vec3(-size, size, size), uv = Vec2(0, texture_scale)})
		self:AddVertex({pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(-size, -size, size), uv = Vec2(0, 0)})

		-- bottom
		self:AddVertex({pos = Vec3(-size, -size, -size), uv = Vec2(0, 0)})
		self:AddVertex({pos = Vec3(size, -size, -size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(-size, size, -size), uv = Vec2(0, texture_scale)})
		self:AddVertex({pos = Vec3(size, -size, -size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(size, size, -size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(-size, size, -size), uv = Vec2(0, texture_scale)})
		
		-- left
		self:AddVertex({pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(size, size, -size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(size, -size, -size), uv = Vec2(0, 0)})
		self:AddVertex({pos = Vec3(size, -size, size), uv = Vec2(0, texture_scale)})
		self:AddVertex({pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(size, -size, -size), uv = Vec2(0, 0)})

		-- right
		self:AddVertex({pos = Vec3(-size, -size, -size), uv = Vec2(0, 0)})
		self:AddVertex({pos = Vec3(-size, size, -size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(-size, -size, size), uv = Vec2(0, texture_scale)})
		self:AddVertex({pos = Vec3(-size, size, -size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(-size, size, size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(-size, -size, size), uv = Vec2(0, texture_scale)})
		
		-- front
		self:AddVertex({pos = Vec3(size, -size, size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(size, -size, -size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(-size, -size, -size), uv = Vec2(0, 0)})
		self:AddVertex({pos = Vec3(-size, -size, size), uv = Vec2(0, texture_scale)})
		self:AddVertex({pos = Vec3(size, -size, size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(-size, -size, -size), uv = Vec2(0, 0)})

		-- back
		self:AddVertex({pos = Vec3(-size, size, -size), uv = Vec2(0, 0)})
		self:AddVertex({pos = Vec3(size, size, -size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(-size, size, size), uv = Vec2(0, texture_scale)})
		self:AddVertex({pos = Vec3(size, size, -size), uv = Vec2(texture_scale, 0)})
		self:AddVertex({pos = Vec3(size, size, size), uv = Vec2(texture_scale, texture_scale)})
		self:AddVertex({pos = Vec3(-size, size, size), uv = Vec2(0, texture_scale)})
		
	end

	function META:CreateSphere(res)
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
						   
				self:AddVertex({pos = Vec3(x + size, y, z)})
				self:AddVertex({pos = Vec3(x, y, z)})
				self:AddVertex({pos = Vec3(x, y + size, z)})
				
				self:AddVertex({pos = Vec3(x, y + size, z)})
				self:AddVertex({pos = Vec3(x + size, y + size, z)})
				self:AddVertex({pos = Vec3(x + size, y, z)})
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

				self:AddVertex({normal = e:Copy(), uv = Vec2(idivn, jdivn), pos = p:Copy()})

				e2.x = cost2 * math.cos(t3)
				e2.z = cost2 * math.sin(t3)
				
				p2.x = r * e2.x
				p2.z = r * e2.z

				self:AddVertex({normal = e2:Copy(), uv = Vec2(idivn, jdivn), pos = p2:Copy()})

				idivn = idivn + unodivn
			end
		end
	end
		
	do	
		local up = Vec3(0, 0, -1)	
		
		function META:LoadHeightmap(tex, size, res, height)
			size = size or 1024
			res = res or 128
			height = height or -128
			
			local buffer = tex:Download()
			
			local s = size / res
				
			local i = 1
			
			for x = 0, res do				
				local x2 = (x/res) * tex.w
				
				for y = 0, res do	
					local y2 = (y/res) * tex.h
					
					y2 = -y2 + tex.h
					
					local z1 = tex:GetPixelColor(x2, y2, buffer).r * height -- top left
					local z2 = tex:GetPixelColor(x2 + 1, y2, buffer).r * height -- top right
					local z3 = tex:GetPixelColor(x2, y2 + 1, buffer).r * height -- bottom left
					local z4 = tex:GetPixelColor(x2 + 1, y2 + 1, buffer).r * height -- bottom right

					local x = x * s
					local y = y * s
					
					local vertex = {}
					vertex.pos = Vec3(x, y + s, z3)
					vertex.normal = up
					vertex.uv = Vec2(vertex.pos.x / size, vertex.pos.y / size)
					self:AddVertex(vertex)
				
					local vertex = {}
					vertex.pos = Vec3(x + s, y, z2)
					vertex.normal = up
					vertex.uv = Vec2(vertex.pos.x / size, vertex.pos.y / size)
					self:AddVertex(vertex)

					local vertex = {}
					vertex.pos = Vec3(x, y, z1)
					vertex.normal = up
					vertex.uv = Vec2(vertex.pos.x / size, vertex.pos.y / size)
					self:AddVertex(vertex)
					
				
				
					local vertex = {}
					vertex.pos = Vec3(x, y + s, z3)
					vertex.normal = up
					vertex.uv = Vec2(vertex.pos.x / size, vertex.pos.y / size)
					self:AddVertex(vertex)
					
					local vertex = {}
					vertex.pos = Vec3(x + s, y + s, z4)
					vertex.normal = up
					vertex.uv = Vec2(vertex.pos.x / size, vertex.pos.y / size)
					self:AddVertex(vertex)
					
					local vertex = {}
					vertex.pos = Vec3(x + s, y, z3)
					vertex.normal = up
					vertex.uv = Vec2(vertex.pos.x / size, vertex.pos.y / size)
					self:AddVertex(vertex)				
				end
			end
		end
	end
end

prototype.Register(META)