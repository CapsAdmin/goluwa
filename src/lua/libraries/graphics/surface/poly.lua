local surface = (...) or _G.surface

local META = prototype.CreateTemplate("poly")

META.X, META.Y = 0, 0
META.ROT = 0
META.R,META.G,META.B,META.A = 1,1,1,1
META.U1, META.V1, META.U2, META.V2 = 0, 0, 1, 1
META.UVSW, META.UVSH = 1, 1

function META:SetColor(r,g,b,a)
	self.R = r or 1
	self.G = g or 1
	self.B = b or 1
	self.A = a or 1

	self.dirty = true
end

function META:SetUV(u1, v1, u2, v2, sw, sh)
	self.U1 = u1
	self.U2 = u2
	self.V1 = v1
	self.V2 = v2
	self.UVSW = sw
	self.UVSH = sh

	self.dirty = true
end

local function set_uv(self, i, x,y, w,h, sx,sy)
	if not x then
		self.Vertices.Pointer[i + 1].uv.A = 0
		self.Vertices.Pointer[i + 1].uv.B = 1

		self.Vertices.Pointer[i + 0].uv.A = 0
		self.Vertices.Pointer[i + 0].uv.B = 0

		self.Vertices.Pointer[i + 2].uv.A = 1
		self.Vertices.Pointer[i + 2].uv.B = 0

		--

		self.Vertices.Pointer[i + 4].uv = self.Vertices.Pointer[i + 2].uv

		self.Vertices.Pointer[i + 3].uv.A = 1
		self.Vertices.Pointer[i + 3].uv.B = 1

		self.Vertices.Pointer[i + 5].uv = self.Vertices.Pointer[i + 0].uv
	else
		sx = sx or 1
		sy = sy or 1

		y = -y - h

		self.Vertices.Pointer[i + 1].uv.A = x / sx
		self.Vertices.Pointer[i + 1].uv.B = (y + h) / sy

		self.Vertices.Pointer[i + 0].uv.A = x / sx
		self.Vertices.Pointer[i + 0].uv.B = y / sy

		self.Vertices.Pointer[i + 2].uv.A = (x + w) / sx
		self.Vertices.Pointer[i + 2].uv.B = y / sy

		--

		self.Vertices.Pointer[i + 4].uv = self.Vertices.Pointer[i + 2].uv

		self.Vertices.Pointer[i + 3].uv.A = (x + w) / sx
		self.Vertices.Pointer[i + 3].uv.B = (y + h) / sy

		self.Vertices.Pointer[i + 5].uv = self.Vertices.Pointer[i + 1].uv
	end
end

function META:SetVertex(i, x,y, u,v)
	if i > self.vertex_count or i < 0 then logf("i = %i vertex_count = %i\n", i, self.vertex_count) return end

	x = x or 0
	y = y or 0

	if self.ROT ~= 0 then
		x = x - self.X
		y = y - self.Y

		local new_x = x * math.cos(self.ROT) - y * math.sin(self.ROT)
		local new_y = x * math.sin(self.ROT) + y * math.cos(self.ROT)

		x = new_x + self.X
		y = new_y + self.Y
	end

	self.Vertices.Pointer[i].pos.A = x
	self.Vertices.Pointer[i].pos.B = y

	self.Vertices.Pointer[i].color.A = self.R
	self.Vertices.Pointer[i].color.B = self.G
	self.Vertices.Pointer[i].color.C = self.B
	self.Vertices.Pointer[i].color.D = self.A

	if u and v then
		self.Vertices.Pointer[i].uv.A = u
		self.Vertices.Pointer[i].uv.B = v
	end

	self.dirty = true
end

function META:SetTriangle(i, x1,y1, x2,y2, x3,y3, u1,v1,u2,v2,u3,v3)
	i = i * 3
	self:SetVertex(i + 0, x1,x1, u1,v1)
	self:SetVertex(i + 1, x2,x2, u2,v2)
	self:SetVertex(i + 2, x3,x3, u3,v3)
end

function META:SetRect(i, x,y,w,h, r, ox,oy)

	self.X = x or 0
	self.Y = y or 0
	self.ROT = r or 0
	self.OX = ox or 0
	self.OY = oy or 0

	i = i - 1
	i = i * 6

	set_uv(self, i, self.U1, self.V1, self.U2, self.V2, self.UVSW, self.UVSH)

	self:SetVertex(i + 0, self.X + self.OX, self.Y + h + self.OY)
	self:SetVertex(i + 1, self.X + self.OX, self.Y + self.OY)
	self:SetVertex(i + 2, self.X + w + self.OX, self.Y + h + self.OY)

	self:SetVertex(i + 3, self.X + w + self.OX, self.Y + self.OY)
	self:SetVertex(i + 4, self.X + w + self.OX, self.Y + h + self.OY)
	self:SetVertex(i + 5, self.X + self.OX, self.Y + self.OY)
end

function META:DrawLine(i, x1, y1, x2, y2, w)
	w = w or 1

	local dx,dy = x2-x1, y2-y1
	local ang = math.atan2(dx, dy)
	local dst = math.sqrt((dx * dx) + (dy * dy))

	self:SetRect(i, x1, y1, w, dst, -ang)
end

function META:Draw(count)
	if self.dirty then
		self.mesh:UpdateBuffer()
		self.dirty = false
	end
	surface.mesh_2d_shader.tex = surface.mesh_2d_shader.tex--surface.GetTexture()
	--surface.mesh_2d_shader.global_color = surface.GetColor(true)
	self.mesh:Draw(count)
end

function META:SetNinePatch(i, x, y, w, h, patch_size_w, patch_size_h, corner_size, u_offset, v_offset, uv_scale, skin_w, skin_h)
	u_offset = u_offset or 0
	v_offset = v_offset or 0
	uv_scale = uv_scale or 1

	if w/2 < corner_size then corner_size = w/2 end
	if h/2 < corner_size then corner_size = h/2 end

	-- 1
	self:SetUV(
		u_offset,
		v_offset,
		corner_size/uv_scale,
		corner_size/uv_scale,
		skin_w, skin_h
	)
	self:SetRect(i + 0,
		x,
		y,
		corner_size,
		corner_size
	)

	-- 2
	self:SetUV(
		u_offset + corner_size,
		v_offset,
		(patch_size_w - corner_size*2)/uv_scale,
		corner_size/uv_scale,
		skin_w, skin_h
	)
	self:SetRect(i + 1,
		x + corner_size,
		y,
		w - corner_size*2,
		corner_size
	)

	-- 3
	self:SetUV(
		u_offset + patch_size_w - corner_size/uv_scale,
		v_offset,
		corner_size/uv_scale,
		corner_size/uv_scale,
		skin_w, skin_h
	)
	self:SetRect(i + 2,
		x + w - corner_size,
		y,
		corner_size,
		corner_size
	)

	-- 4
	self:SetUV(
		u_offset,
		v_offset + corner_size,
		corner_size/uv_scale,
		(patch_size_h - corner_size*2)/uv_scale,
		skin_w, skin_h
	)
	self:SetRect(i + 3,
		x,
		y + corner_size,
		corner_size,
		h - corner_size*2
	)

	-- 5
	self:SetUV(
		u_offset + corner_size,
		v_offset + corner_size,
		patch_size_w - corner_size*2,
		patch_size_h - corner_size*2,
		skin_w, skin_h
	)
	self:SetRect(i + 4,
		x + corner_size,
		y + corner_size,
		w - corner_size*2,
		h - corner_size*2
	)

	-- 6
	self:SetUV(
		u_offset + patch_size_w - corner_size/uv_scale,
		v_offset + corner_size/uv_scale,
		corner_size/uv_scale,
		(patch_size_h - corner_size*2)/uv_scale,
		skin_w, skin_h
	)
	self:SetRect(i + 5,
		x + w - corner_size,
		y + corner_size,
		corner_size,
		h - corner_size*2
	)

	-- 7
	self:SetUV(
		u_offset,
		v_offset + patch_size_h - corner_size/uv_scale,
		corner_size/uv_scale,
		corner_size/uv_scale,
		skin_w, skin_h
	)
	self:SetRect(i + 6,
		x,
		y + h - corner_size,
		corner_size,
		corner_size
	)

	-- 8
	self:SetUV(
		u_offset + corner_size/uv_scale,
		v_offset + patch_size_h - corner_size/uv_scale,
		(patch_size_w - corner_size*2)/uv_scale,
		corner_size/uv_scale,
		skin_w, skin_h
	)
	self:SetRect(i + 7,
		x + corner_size,
		y + h - corner_size,
		w - corner_size*2,
		corner_size
	)

	-- 9
	self:SetUV(
		u_offset + patch_size_w - corner_size/uv_scale,
		v_offset + patch_size_h - corner_size/uv_scale,
		corner_size/uv_scale,
		corner_size/uv_scale,
		skin_w, skin_h
	)
	self:SetRect(i + 8,
		x + w - corner_size,
		y + h - corner_size,
		corner_size,
		corner_size
	)
end

function META:AddRect(...)
	self.added = (self.added or 1)
	self:SetRect(self.added, ...)
	self.added = self.added + 1
end

function META:AddNinePatch(...)
	self.added = (self.added or 1)
	self:SetRect(self.added, ...)
	self.added = self.added + 9
end

prototype.Register(META)

function surface.CreatePoly(vertex_count)
	local mesh = surface.CreateMesh(vertex_count)

	-- they never change anyway
	mesh:SetUpdateIndices(false)

	local self = prototype.CreateObject(META)

	self.mesh = mesh
	self.vertex_count = vertex_count
	self.Vertices = mesh.Vertices

	return self
end

do
	local META = prototype.CreateTemplate("quadric_beizer_curve")

	META:GetSet("JoinLast", true)

	function surface.CreateQuadricBeizerCurve()
		local self = prototype.CreateObject(META)

		self.nodes = {}

		return self
	end

	function META:Add(point, control)
		table.insert(self.nodes, {point = point, control = control})
	end

	local function quadratic_bezier(a, b, control, t)
		return (1 - t) * (1 - t) * a + (2 - 2 * t) * t * control + b * t * t
	end

	function META:ConvertToPoints(quality)
		quality = quality or 60

		local points = {}
		local precision = 1 / quality

		for i, current in ipairs(self.nodes) do
			local next = self.nodes[i + 1]
			if self.JoinLast then
				if not next then
					next = self.nodes[1]
				end
			else
				if not next then
					break
				end
			end
			local current_control = current.control or current.point:GetLerped(0.5, next.point)

			for step = 0, 1, precision do
				table.insert(points, quadratic_bezier(current.point, next.point, current_control, step))
			end
		end

		return points
	end

	local function line_segment_normal(a, b)
		return Vec2(b.y - a.y, a.x - b.x):Normalize()
	end

	function META:CreateOffsetedCurve(offset)
		local offseted = surface.CreateQuadricBeizerCurve()

		for i, current in ipairs(self.nodes) do
			local next = self.nodes[i+1]
			if self.JoinLast then
				if not next then
					next = self.nodes[1]
				end
			else
				if not next then
					break
				end
			end
			local prev = self.nodes[i-1] or self.nodes[#self.nodes]
			local current_control = current.control or current.point:GetLerped(0.5, next.point)
			local prev_control = prev.control or prev.point:GetLerped(0.5, current.point)

			local normal = line_segment_normal(current.point, current_control)
			normal = normal + line_segment_normal(prev_control, current.point)
			normal:Normalize()

			local surface_normal = line_segment_normal(current.point, next.point)

			offseted:Add(current.point + normal * offset, current_control + surface_normal * offset)
		end

		return offseted
	end

	function META:ConstructPoly(width, quality, stretch)
		width = width or 30
		stretch = stretch or 1

		local negative_points = self:CreateOffsetedCurve(-width):ConvertToPoints(quality)
		local positive_points = self:CreateOffsetedCurve(width):ConvertToPoints(quality)

		local poly = surface.CreatePoly(#positive_points * 2)
		local distance_positive = 0

		for i in ipairs(positive_points) do
			if i > 1 then
				distance_positive = distance_positive +
				(negative_points[i - 1]:Distance(negative_points[i]) + positive_points[i - 1]:Distance(positive_points[i])) / stretch / 2
			end

			poly:SetVertex((i - 1) * 2, negative_points[i].x, negative_points[i].y, distance_positive, 0)
			poly:SetVertex((i - 1) * 2 + 1, positive_points[i].x, positive_points[i].y, distance_positive, 1)
		end

		return poly
	end

	META:Register()
end