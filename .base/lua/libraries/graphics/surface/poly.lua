local surface = (...) or _G.surface

local META = utilities.CreateBaseMeta("poly")

function META:SetColor(r,g,b,a)
	R = r or 1
	G = g or 1
	B = b or 1
	A = a or 1
end
	
function META:SetUV(u1,v1,u2,v2)
	U1 = u1
	V1 = v1
	U2 = u2
	V2 = v2
end

function META:SetVertex(i, x,y, u,v)
	if i > size or i < 0 then logf("i = %i size = %i\n", i, size) return end
	
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
	
	buffer[i].pos.A = x
	buffer[i].pos.B = y
	
	buffer[i].uv.A = u
	buffer[i].uv.B = v
	
	--buffer[i].color.A = R
	--buffer[i].color.B = G
	--buffer[i].color.C = B
	--buffer[i].color.D = A
end

function META:SetRect(i, x,y,w,h, r, ox,oy)

	X = x or 0
	Y = y or 0
	ROT = r or 0
	OX = ox or 0
	OY = oy or 0
	
	i = i - 1
	i = i * 6
				
	self:SetVertex(i + 0, X + OX, Y + OY, U1, V1 + V2)
	self:SetVertex(i + 1, X + OX, Y + h + OY, U1, V1)
	self:SetVertex(i + 2, X + w + OX, Y + h + OY, U1 + U2, V1)

	self:SetVertex(i + 3, X + w + OX, Y + h + OY, U1 + U2, V1)
	self:SetVertex(i + 4, X + w + OX, Y + OY, U1 + U2, V1 + V2)
	self:SetVertex(i + 5, X + OX, Y + OY, U1, V1 + V2)
end

function META:Draw()
	self.mesh:UpdateBuffer()
	surface.mesh_2d_shader.tex = surface.bound_texture
	surface.mesh_2d_shader.global_color = COLOR
	self.mesh:Draw()
end

function surface.CreatePoly(size)		
	size = size * 6
	local mesh = render.CreateMesh2D(size)
	local buffer = mesh.buffer

	local X, Y = 0, 0
	local ROT = 0	
	local R,G,B,A = 1,1,1,1
	local U1, V1, U2, V2 = 0, 0, 1, 1

	local self = META:New()

	self.mesh = mesh
					
	return self
end