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
		self.vertices[i + 0].uv.A = 0
		self.vertices[i + 0].uv.B = 1
		
		self.vertices[i + 1].uv.A = 0
		self.vertices[i + 1].uv.B = 0
		
		self.vertices[i + 2].uv.A = 1
		self.vertices[i + 2].uv.B = 0
		
		--
		
		self.vertices[i + 3].uv = self.vertices[i + 2].uv
		
		self.vertices[i + 4].uv.A = 1
		self.vertices[i + 4].uv.B = 1
		
		self.vertices[i + 5].uv = self.vertices[i + 0].uv	
	else			
		sx = sx or 1
		sy = sy or 1
		
		y = -y - h
		
		self.vertices[i + 0].uv.A = x / sx
		self.vertices[i + 0].uv.B = (y + h) / sy
		
		self.vertices[i + 1].uv.A = x / sx
		self.vertices[i + 1].uv.B = y / sy
		
		self.vertices[i + 2].uv.A = (x + w) / sx
		self.vertices[i + 2].uv.B = y / sy
		
		--
		
		self.vertices[i + 3].uv = self.vertices[i + 2].uv
		
		self.vertices[i + 4].uv.A = (x + w) / sx
		self.vertices[i + 4].uv.B = (y + h) / sy
		
		self.vertices[i + 5].uv = self.vertices[i + 0].uv	
	end
end

function META:SetVertex(i, x,y, u,v)
	if i > self.size or i < 0 then logf("i = %i size = %i\n", i, self.size) return end
	
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
		
	self.vertices[i].pos.A = x
	self.vertices[i].pos.B = y
	
	self.vertices[i].color.A = self.R
	self.vertices[i].color.B = self.G
	self.vertices[i].color.C = self.B
	self.vertices[i].color.D = self.A
	
	if u and v then
		self.vertices[i].uv.A = u
		self.vertices[i].uv.B = v
	end
	
	self.dirty = true
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

	self:SetVertex(i + 0, self.X + self.OX, self.Y + self.OY)
	self:SetVertex(i + 1, self.X + self.OX, self.Y + h + self.OY)
	self:SetVertex(i + 2, self.X + w + self.OX, self.Y + h + self.OY)

	self:SetVertex(i + 3, self.X + w + self.OX, self.Y + h + self.OY)
	self:SetVertex(i + 4, self.X + w + self.OX, self.Y + self.OY)
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
	if count then count = count * 6 end
	if self.dirty then
		self.mesh:UpdateBuffer()
		self.dirty = false
	end
	surface.mesh_2d_shader.tex = surface.GetTexture()
	surface.mesh_2d_shader.global_color = surface.GetColor(true)
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

function surface.CreatePoly(size)		
	size = size * 6
	local mesh = surface.CreateMesh(size)
	
	-- they never change anyway
	mesh:SetUpdateIndices(false)	
	
	local self = prototype.CreateObject(META)

	self.mesh = mesh
	self.size = size
	self.vertices = mesh.vertices

	return self
end

if RELOAD then

end