local gfx = (...) or _G.gfx

local META = prototype.CreateTemplate("polygon_3d")

function gfx.CreatePolygon3D()
	return META:CreateObject()
end

function META:__tostring2()
	return ("[%i vertices]"):format(#self.Vertices)
end

META:GetSet("Vertices", {})
META:GetSet("Indices")
META:GetSet("AABB", AABB())

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

	self.vertex_buffer = assert(render3d.CreateMesh(self.Vertices, self.Indices))
	self.vertex_buffer:SetDrawHint("static")

	-- don't store the geometry on the lua side
	if not skip_unref then
		self:UnreferenceVertices()
	end
end

function META:UnreferenceVertices()
	if self.vertex_buffer then
		self.vertex_buffer:UnreferenceMesh()
	end
	self:Clear()
end

function META:GetMesh()
	return self.vertex_buffer
end

function META:Draw()
	if self.vertex_buffer then
		self.vertex_buffer:Draw()
	end
end

do -- helpers
	function META:BuildBoundingBox()
		for _, vertex in ipairs(self.Vertices) do
			self.AABB:ExpandVec3(vertex.pos)
		end
	end

	local function build_normal(a,b,c)
		if a.normal and b.normal and c.normal then return end
		local normal = -(a.pos - b.pos):Cross(b.pos - c.pos):GetNormalized()

		a.normal = normal
		b.normal = normal
		c.normal = normal

		tasks.Wait()
	end

	function META:BuildNormals()
		if self.Indices then
			for i = 1, #self.Indices, 3 do
				local a = self.Vertices[self.Indices[i + 0] + 1]
				local b = self.Vertices[self.Indices[i + 1] + 1]
				local c = self.Vertices[self.Indices[i + 2] + 1]

				build_normal(a, b, c)
			end
		else
			for i = 1, #self.Vertices, 3 do
				local a = self.Vertices[i + 0]
				local b = self.Vertices[i + 1]
				local c = self.Vertices[i + 2]

				build_normal(a, b, c)
			end
		end
	end

	local function build_tangents(self, ai, bi, ci, tan1, tan2)
		local a = self.Vertices[ai]
		local b = self.Vertices[ci]
		local c = self.Vertices[bi]


		local x1 = b.pos.x - a.pos.x
		local x2 = c.pos.x - a.pos.x
		local y1 = b.pos.y - a.pos.y
		local y2 = c.pos.y - a.pos.y
		local z1 = b.pos.z - a.pos.z
		local z2 = c.pos.z - a.pos.z

		local s1 = b.uv.x - a.uv.x
		local s2 = c.uv.x - a.uv.x
		local t1 = b.uv.y - a.uv.y
		local t2 = c.uv.y - a.uv.y

		local r = 1 / (s1 * t2 - s2 * t1)
		local sdir = Vec3((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r)
		local tdir = Vec3((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r)

		tan1[ai] = (tan1[ai] or Vec3()) + sdir
		tan1[bi] = (tan1[bi] or Vec3()) + sdir
		tan1[ci] = (tan1[ai] or Vec3()) + sdir

		tan2[ai] = (tan2[ai] or Vec3()) + tdir
		tan2[bi] = (tan2[bi] or Vec3()) + tdir
		tan2[ci] = (tan2[ci] or Vec3()) + tdir

		tasks.Wait()
	end

	function META:BuildTangents()
		local tan1 = {}
		local tan2 = {}

		if self.Indices then
			for i = 1, #self.Indices, 3 do
				local ai = self.Indices[i + 0] + 1
				local bi = self.Indices[i + 1] + 1
				local ci = self.Indices[i + 2] + 1

				build_tangents(self, ai, bi, ci, tan1, tan2)
			end
		else
			for i = 1, #self.Vertices, 3 do
				local ai = i + 0
				local bi = i + 1
				local ci = i + 2

				build_tangents(self, ai, bi, ci, tan1, tan2)
			end
		end

		for i = 1, #self.Vertices do
			local n = self.Vertices[i].normal
			local t = tan1[i]

			if tan1[i] and tan2[i] and not self.Vertices.tangent then
				self.Vertices[i].tangent = (t - n  * n:GetDot(t)):Normalize()

				tasks.Wait()
			end
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
			local parts = line:gsub("%s+", " "):trim():split(" ")

			table.insert(lines, parts)
			tasks.ReportProgress("inserting lines", math.huge)
			tasks.Wait()
			i = i + 1
		end

		local vert_count = #lines

		for _, parts in pairs(lines) do
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

		for _, parts in pairs(lines) do
			if parts[1] == "f" and #parts > 3 then
				local first, previous

				for i = 2, #parts do
					local current = parts[i]:split("/")

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

		for _ = 1, ndiv2 do

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

			for _ = 1, n do
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

	function META:LoadHeightmap(tex, size, res, height, pow)
		size = size or Vec2(1024, 1024)
		res = res or Vec2(128, 128)
		height = height or -64
		pow = pow or 1

		local s = size / res
		local s2 = s / 2

		local pixel_advance = (Vec2(1, 1)/res) * tex:GetSize()

		local function get_color(x, y)
			local r,g,b,a = tex:GetRawPixelColor(x, y)
			return (((r+g+b+a) / 4) / 255) ^ pow
		end

		local offset = -Vec3(size.x, size.y, height) / 2

		for x = 0, res.x do
			local x2 = (x/res.x) * tex:GetSize().x

			for y = 0, res.y do
				local y2 = (y/res.y) * tex:GetSize().y

				y2 = -y2 + tex:GetSize().y -- fix me

				--[[
						  __
						|\ /|
						|/_\|
				]]


				local z3 = get_color(x2, y2) * height -- top left
				local z4 = get_color(x2+pixel_advance.x, y2) * height -- top right
				local z1 = get_color(x2, y2+pixel_advance.y) * height -- bottom left
				local z2 = get_color(x2+pixel_advance.x, y2+pixel_advance.y) * height -- bottom right

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

META:Register()
