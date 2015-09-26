local render = ... or _G.render

local META = prototype.CreateTemplate("mesh_builder")

function META:__tostring2()
	return ("[%i vertices]"):format(#self.Vertices)
end

prototype.GetSet(META, "Vertices", {})
prototype.GetSet(META, "Indices")
prototype.GetSet(META, "BBMin", Vec3())
prototype.GetSet(META, "BBMax", Vec3())

function render.CreateMeshBuilder()
	return prototype.CreateObject(META)
end

META.i = 1

function META:AddVertex(vertex)
	self.Vertices[self.i] = vertex
	self.i = self.i + 1
end

function META:Clear()
	self.i = 1
	table.clear(self.Vertices)
	if self.Indices then table.clear(self.Indices) end
end


function META:Upload(skip_unref)
	if #self.Vertices == 0 then return end

	self.mesh = render.CreateMesh(self.Vertices, self.Indices)

	-- don't store the geometry on the lua side
	if not skip_unref then
		self:UnreferenceVertices()
	end
end

function META:UnreferenceVertices()
	if self.mesh then
		self.mesh:UnreferenceMesh()
	end
	self:Clear()
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
			--[[
			-- This is a triangle from your vertices
			local v1 = self.Vertices[ai].pos;
			local v2 = self.Vertices[bi].pos;
			local v3 = self.Vertices[ci].pos;

			-- These are the texture coordinate of the triangle
			local w1 = self.Vertices[ai].uv;
			local w2 = self.Vertices[bi].uv;
			local w3 = self.Vertices[ci].uv;

			local x1 = v2.x - v1.x
			local x2 = v3.x - v1.x
			local y1 = v2.y - v1.y
			local y2 = v3.y - v1.y
			local z1 = v2.z - v1.z
			local z2 = v3.z - v1.z

			local s1 = w2.x - w1.x
			local s2 = w3.x - w1.x
			local t1 = w2.y - w1.y
			local t2 = w3.y - w1.y

			local r = 1 / (s1 * t2 - s2 * t1)
			local sdir = Vec3((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r)
			local tdir = Vec3((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r)

			-- Gram-Schmidt orthogonalize
			local tangent = sdir - normal * normal:GetDot(sdir)
			tangent:Normalize()

			-- Calculate handedness (here maybe you need to switch >= with <= depend on the geometry winding order)
			local tangentdir = normal:Cross(sdir):GetDot(tdir) >= 0 and 1 or -1
			local binormal = normal:Cross(tangent) * tangentdir

			self.Vertices[ai].normal = normal
			self.Vertices[ai].tangent = tangent
			self.Vertices[ai].binormal = binormal

			self.Vertices[bi].normal = normal
			self.Vertices[bi].tangent = tangent
			self.Vertices[bi].binormal = binormal

			self.Vertices[ci].normal = normal
			self.Vertices[ci].tangent = tangent
			self.Vertices[ci].binormal = binormal]]

			tasks.Wait()
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
					tasks.Wait()
				end
			end
		end
	end

	--[[
		2___1
		|  /
	   3|/
	]]

	function META:LoadObj(data, generate_normals)
		local positions = {}
		local texcoords = {}
		local normals = {}

		local output = {}

		local lines = {}

		local i = 1
		for line in data:gmatch("(.-)\n") do
			local parts = line:gsub("%s+", " "):trim():explode(" ")

			table.insert(lines, parts)
			tasks.ReportProgress("inserting lines", math.huge)
			tasks.Wait()
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
			self:Wait()
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

			tasks.ReportProgress("solving indices", vert_count)
			tasks.Wait()
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
				tasks.ReportProgress("generating normals", count)
				tasks.Wait()
			end

			local default_normal = Vec3(0, 0, -1)

			local count = #output
			for i = 1, count do
				local n = vertex_normals[output[i].pos_index] or default_normal
				n:Normalize()
				normals[i] = n
				output[i].normal = n
				tasks.ReportProgress("smoothing normals", count)
				tasks.Wait()
			end
		end

		return output
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

		function META:LoadHeightmap(tex, size, res, height, pow)
			size = size or Vec2(1024, 1024)
			res = res or Vec2(128, 128)
			height = height or -64
			pow = pow or 1

			local s = size / res
			local s2 = s / 2

			local pixel_advance = (Vec2(1, 1)/res) * tex:GetSize()

			local function get_color(x, y)
				local r,g,b,a = tex:GetPixelColor(x, y)
				return (((r+g+b+a) / 4) / 255) ^ pow
			end

			local offset = -Vec3(size.x, size.y, height) / 2

			for x = 0, res.x do
				local x2 = (x/res.x) * tex.w

				for y = 0, res.y do
					local y2 = (y/res.y) * tex.h

					y2 = -y2 + tex.h -- fix me

					--[[
							  __
						    |\ /|
							|/_\|
					]]


					local z3 = get_color(x2, y2) * height -- top left
					local z4 = get_color(x2+pixel_advance.w, y2) * height -- top right
					local z1 = get_color(x2, y2+pixel_advance.h) * height -- bottom left
					local z2 = get_color(x2+pixel_advance.w, y2+pixel_advance.h) * height -- bottom right

					local z5 = (z1+z2+z3+z4)/4

					local x = (x * s.x)
					local y = y * s.y

					--[[
						___
						\ /
					]]

					local a1 = {}
					a1.pos = Vec3(x, y, z1) + offset
					a1.uv = Vec2(a1.pos.x + offset.x, a1.pos.y + offset.y) / size
					self:AddVertex(a1)

					local b1 = {}
					b1.pos = Vec3(x + s.x, y, z2) + offset
					b1.uv = Vec2(b1.pos.x + offset.x, b1.pos.y + offset.y) / size
					self:AddVertex(b1)

					local c1 = {}
					c1.pos = Vec3(x + s2.x, y + s2.y, z5) + offset
					c1.uv = Vec2(c1.pos.x + offset.x, c1.pos.y + offset.y) / size
					self:AddVertex(c1)

					local normal = -(a1.pos - b1.pos):Cross(b1.pos - c1.pos):GetNormalized()
					a1.normal = normal
					b1.normal = normal
					c1.normal = normal

					--[[
						 ___
						|\ /
						|/
					]]

					local a2 = {}
					a2.pos = Vec3(x, y, z1) + offset
					a2.uv = Vec2(a2.pos.x + offset.x, a2.pos.y + offset.y) / size
					self:AddVertex(a2)

					local b2 = {}
					b2.pos = Vec3(x + s2.x, y + s2.y, z5) + offset
					b2.uv = Vec2(b2.pos.x + offset.x, b2.pos.y + offset.y) / size
					self:AddVertex(b2)

					local c2 = {}
					c2.pos = Vec3(x, y + s.y, z3) + offset
					c2.uv = Vec2(c2.pos.x + offset.x, c2.pos.y + offset.y) / size
					self:AddVertex(c2)

					local normal = -(a2.pos - b2.pos):Cross(b2.pos - c2.pos):GetNormalized()
					a2.normal = normal
					b2.normal = normal
					c2.normal = normal

					--[[
						___
					   |\_/
					   |/_\
					]]

					local a3 = {}
					a3.pos = Vec3(x, y + s.y, z3) + offset
					a3.uv = Vec2(a3.pos.x + offset.x, a3.pos.y + offset.y) / size
					self:AddVertex(a3)

					local b3 = {}
					b3.pos = Vec3(x + s2.x, y + s2.y, z5) + offset
					b3.uv = Vec2(b3.pos.x + offset.x, b3.pos.y + offset.y) / size
					self:AddVertex(b3)

					local c3 = {}
					c3.pos = Vec3(x + s.x, y + s.y, z4) + offset
					c3.uv = Vec2(c3.pos.x + offset.x, c3.pos.y + offset.y) / size
					self:AddVertex(c3)

					local normal = -(a3.pos - b3.pos):Cross(b3.pos - c3.pos):GetNormalized()
					a3.normal = normal
					b3.normal = normal
					c3.normal = normal

					--[[
						___
					   |\_/|
					   |/_\|
					]]

					local a4 = {}
					a4.pos = Vec3(x + s2.x, y + s2.y, z5) + offset
					a4.uv = Vec2(a4.pos.x + offset.x, a4.pos.y + offset.y) / size
					self:AddVertex(a4)

					local b4 = {}
					b4.pos = Vec3(x + s.x, y, z2) + offset
					b4.uv = Vec2(b4.pos.x + offset.x, b4.pos.y + offset.y) / size
					self:AddVertex(b4)

					local c4 = {}
					c4.pos = Vec3(x + s.x, y + s.y, z4) + offset
					c4.uv = Vec2(c4.pos.x + offset.x, c4.pos.y + offset.y) / size
					self:AddVertex(c4)

					local normal = -(a4.pos - b4.pos):Cross(b4.pos - c4.pos):GetNormalized()
					a4.normal = normal
					b4.normal = normal
					c4.normal = normal

					tasks.Wait()
				end
			end
		end
	end
end

prototype.Register(META)
