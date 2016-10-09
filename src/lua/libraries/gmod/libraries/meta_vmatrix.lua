local gmod = ... or gmod

local META = gmod.GetMetaTable("VMatrix")

function gmod.env.Matrix(tbl)
	local self = {}

	if type(tbl) == "cdata" then
		self.p = tbl
	elseif type(tbl) == "table" then
		self.p = Matrix44()
		self.p.m00 = tbl[1][1]
		self.p.m01 = tbl[1][2]
		self.p.m02 = tbl[1][3]
		self.p.m03 = tbl[1][4]

		self.p.m10 = tbl[2][1]
		self.p.m11 = tbl[2][2]
		self.p.m12 = tbl[2][3]
		self.p.m13 = tbl[2][4]

		self.p.m20 = tbl[3][1]
		self.p.m21 = tbl[3][2]
		self.p.m22 = tbl[3][3]
		self.p.m23 = tbl[3][4]

		self.p.m30 = tbl[4][1]
		self.p.m31 = tbl[4][2]
		self.p.m32 = tbl[4][3]
		self.p.m33 = tbl[4][4]
	else
		self.p = Matrix44()
	end

	return setmetatable(self, META)
end

do
	local tr = {}

	for x = 1, 4 do
		for y = 1, 4 do
			tr[x] = tr[x] or {}
			tr[x][y] = "m" .. (x - 1) .. (y - 1)
		end
	end

	function META:GetField(r, c)
		if tr[r] and tr[r][c] then
			return self.p[tr[r][c]]
		end
	end

	function META:ToTable()
		local tbl = {}
		for x = 1, 4 do
			for y = 1, 4 do
				tbl[x] = tbl[x] or {}
				tbl[x][y] = self:GetField(x, y)
			end
		end
		return tbl
	end
end

function META:GetForward()
	return self:GetAngles():GetForward()
end

function META:GetRight()
	return self:GetAngles():GetRight()
end

function META:GetUp()
	return self:GetAngles():GetUp()
end

function META:Scale(v)
	self.p:Scale(v.x, v.y, v.z)
end

function META:SetScale(v)
	self.p.m00 = v.x
	self.p.m11 = v.y
	self.p.m22 = v.z
end

function META:GetScale()
	return gmod.env.Vector(self.p.m00, self.p.m11, self.p.m22)-- / self.p.m33
end

function META:Translate(v)
	self.p:Translate(v.x, v.y, v.z)
end

function META:SetTranslation(v)
	self.p:SetTranslation(v.x, v.y, v.z)
end

function META:GetTranslation()
	return gmod.env.Vector(self.p.m03, self.p.m13, self.p.m23)-- / self.p.m33
end

function META:ScaleTranslation(scale)
	self:SetTranslation(self:GetTranslation() * scale)
end

function META:SetAngles(ang)
	self.p:SetAngles(ang:GetRad())
end

function META:GetAngles()
	return self.p:GetAngles():Deg()
end

function META:Set(m)
	self.p:Copy(m.p)
end

function META:Identity()
	self.p:Identity()
end

do
	local identity = Matrix44()

	function META:IsIdentity()
		return self.p == identity
	end
end

function META:Invert()
	self.p = self.p:GetInverse()
end

function META:InvertTR()
	self.p = self.p:GetInverse()
end

function META:GetInverse()
	return gmod.env.Matrix(self:GetInverse())
end

function META:GetInverseTR()
	return gmod.env.Matrix(self:GetInverse())
end