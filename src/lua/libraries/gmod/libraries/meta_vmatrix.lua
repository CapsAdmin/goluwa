local gine = ... or _G.gine

local META = gine.GetMetaTable("VMatrix")

function gine.env.Matrix(tbl)
	local self = {}

	if type(tbl) == "cdata" then
		self.ptr = tbl
	elseif type(tbl) == "table" then
		self.ptr = Matrix44()
		self.ptr.m00 = tbl[1][1]
		self.ptr.m01 = tbl[1][2]
		self.ptr.m02 = tbl[1][3]
		self.ptr.m03 = tbl[1][4]

		self.ptr.m10 = tbl[2][1]
		self.ptr.m11 = tbl[2][2]
		self.ptr.m12 = tbl[2][3]
		self.ptr.m13 = tbl[2][4]

		self.ptr.m20 = tbl[3][1]
		self.ptr.m21 = tbl[3][2]
		self.ptr.m22 = tbl[3][3]
		self.ptr.m23 = tbl[3][4]

		self.ptr.m30 = tbl[4][1]
		self.ptr.m31 = tbl[4][2]
		self.ptr.m32 = tbl[4][3]
		self.ptr.m33 = tbl[4][4]
	else
		self.ptr = Matrix44()
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
			return self.ptr[tr[r][c]]
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
	self.ptr:Scale(v.x, v.y, v.z)
end

function META:SetScale(v)
	self.ptr.m00 = v.x
	self.ptr.m11 = v.y
	self.ptr.m22 = v.z
end

function META:GetScale()
	return gine.env.Vector(self.ptr.m00, self.ptr.m11, self.ptr.m22)-- / self.ptr.m33
end

function META:Translate(v)
	self.ptr:Translate(v.x, v.y, v.z)
end

function META:SetTranslation(v)
	self.ptr:SetTranslation(v.x, v.y, v.z)
end

function META:GetTranslation()
	return gine.env.Vector(self.ptr.m03, self.ptr.m13, self.ptr.m23)-- / self.ptr.m33
end

function META:ScaleTranslation(scale)
	self:SetTranslation(self:GetTranslation() * scale)
end

function META:SetAngles(ang)
	self.ptr:SetAngles(ang:GetRad())
end

function META:GetAngles()
	return self.ptr:GetAngles():Deg()
end

function META:Set(m)
	self.ptr:Copy(m.ptr)
end

function META:Identity()
	self.ptr:Identity()
end

do
	local identity = Matrix44()

	function META:IsIdentity()
		return self.ptr == identity
	end
end

function META:Invert()
	self.ptr = self.ptr:GetInverse()
end

function META:InvertTR()
	self.ptr = self.ptr:GetInverse()
end

function META:GetInverse()
	return gine.env.Matrix(self:GetInverse())
end

function META:GetInverseTR()
	return gine.env.Matrix(self:GetInverse())
end