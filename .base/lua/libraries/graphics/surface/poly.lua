local surface = (...) or _G.surface

local META = metatable.CreateTemplate("poly")

local X, Y = 0, 0
local ROT = 0	
local R,G,B,A = 1,1,1,1
local U1, V1, U2, V2 = 0, 0, 1, 1
local UVSW, UVSH = 1, 1

function META:SetColor(r,g,b,a)
	R = r or 1
	G = g or 1
	B = b or 1
	A = a or 1
end

function META:SetUV(u1, v1, u2, v2, sw, sh)
	U1 = u1
	U2 = u2
	V1 = v1
	V2 = v2
	UVSW = sw
	UVSH = sh
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
	if i > self.size or i < 0 then logf("i = %i size = %i\n", i, size) return end
	
	x = x or 0
	y = y or 0
	u = u or 0
	v = v or 1
	
	if ROT ~= 0 then				
		x = x - X
		y = y - Y				
		
		local new_x = x * math.cos(ROT) - y * math.sin(ROT)
		local new_y = x * math.sin(ROT) + y * math.cos(ROT)
		
		x = new_x + X
		y = new_y + Y				
	end
		
	self.vertices[i].pos.A = x
	self.vertices[i].pos.B = y
	
	self.vertices[i].color.A = R
	self.vertices[i].color.B = G
	self.vertices[i].color.C = B
	self.vertices[i].color.D = A
end

function META:SetRect(i, x,y,w,h, r, ox,oy)

	X = x or 0
	Y = y or 0
	ROT = r or 0
	OX = ox or 0
	OY = oy or 0
	
	i = i - 1
	i = i * 6
	
	set_uv(self, i, U1, V1, U2, V2, UVSW, UVSH)

	self:SetVertex(i + 0, X + OX, Y + OY)
	self:SetVertex(i + 1, X + OX, Y + h + OY)
	self:SetVertex(i + 2, X + w + OX, Y + h + OY)

	self:SetVertex(i + 3, X + w + OX, Y + h + OY)
	self:SetVertex(i + 4, X + w + OX, Y + OY)
	self:SetVertex(i + 5, X + OX, Y + OY)
end

function META:DrawLine(i, x1, y1, x2, y2, w)
	w = w or 1

	local dx,dy = x2-x1, y2-y1
	local ang = math.atan2(dx, dy)
	local dst = math.sqrt((dx * dx) + (dy * dy))
				
	self:SetRect(i, x1, y1, w, dst, -ang)
end

function META:Draw()
	self.mesh:UpdateBuffer()
	surface.mesh_2d_shader.tex = surface.GetTexture()
	surface.mesh_2d_shader.global_color = surface.GetColor(true)
	surface.mesh_2d_shader:Bind()
	self.mesh:Draw()
end

function surface.CreatePoly(size)		
	size = size * 6
	local mesh = surface.CreateMesh(size)

	local self = META:New()

	self.mesh = mesh
	self.size = size
	self.vertices = mesh.vertices

	return self
end