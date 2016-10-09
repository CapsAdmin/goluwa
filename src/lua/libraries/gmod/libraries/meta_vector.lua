local META = gmod.GetMetaTable("Vector")

function gmod.env.Vector(x, y, z)
	local self = {}

	if type(x) == "table" then
		x, y, z = x.p:Unpack()
	elseif type(x) == "cdata" then
		x, y, z = x:Unpack()
	elseif type(x) == "string" then
		x, y, z = x:match("(%S+)%s-(%S+)%s-(%S+)")
		x = tonumber(x)
		y = tonumber(y)
		z = tonumber(z)
	end

	x = x or 0
	y = y or 0
	z = z or 0

	self.p = Vec3(x, y, z)

	return setmetatable(self, META)
end

function META:__index(key)
	if key == "x" then
		return self.p.x
	elseif key == "y" then
		return self.p.y
	elseif key == "z" then
		return self.p.z
	end

	return META[key]
end

function META:__newindex(key, val)
	if key == "x" then
		self.p.x = val
	elseif key == "y" then
		self.p.y = val
	elseif key == "z" then
		self.p.z = val
	end
end
function META:__tostring()
	return ("Vector(%f, %f, %f)"):format(self.p:Unpack())
end

function META.__eq(a, b)
	return a.p == b.p
end

function META.__unm(a)
	return gmod.env.Vector(-a.p)
end

function META.__add(a, b)
	return gmod.env.Vector(a.p + b.p)
end

function META.__sub(a, b)
	return gmod.env.Vector(a.p - b.p)
end

function META.__mul(a, b)
	if type(b) == "number" then
		return gmod.env.Vector(a.p * b)
	elseif type(a) == "number" then
		return gmod.env.Vector(a * b.p)
	end

	return gmod.env.Vector(a.p * b.p)
end

function META.__div(a, b)
	if type(b) == "number" then
		return gmod.env.Vector(a.p / b)
	elseif type(a) == "number" then
		return gmod.env.Vector(a / b.p)
	end

	return gmod.env.Vector(a.p / b.p)
end

function META:ToScreen()
	local pos,vis = math3d.WorldPositionToScreen(self.p)
	return {
		x = pos.x,
		y = pos.y,
		visible = vis > 0,
	}
end

function META:Zero()
	self.p:Set(0, 0, 0)
end

function META:Cross(vec)
	return gmod.env.Vector(self.p:Cross(vec))
end

function META:Distance(vec)
	return self.p:Distance(vec.p)
end

function META:Dot(vec)
	return self.p:Dot(vec.p)
end

META.DotProduct = META.Dot

function META:Normalize()
	self.p:Normalize()
end

function META:GetNormalized()
	return gmod.env.Vector(self.p:GetNormalized())
end

META.GetNormal = META.GetNormalized

function META:Add(vec)
	self.x = self.x + vec.x
	self.y = self.y + vec.y
	self.z = self.z + vec.z
end

function META:Sub(vec)
	self.x = self.x - vec.x
	self.y = self.y - vec.y
	self.z = self.z - vec.z
end

function META:Mul(vec)
	self.x = self.x * vec.x
	self.y = self.y * vec.y
	self.z = self.z * vec.z
end

function META:Angle()
	return gmod.env.Angle(self.p:GetAngles())
end

function META:Length()
	return self.p:GetLength()
end
function META:DistToSqr(b)
	return (self.p - b.p):GetLengthSquared()
end

function META:IsZero()
	return self.p:IsZero()
end

function gmod.env.LerpVector(alpha, a, b)
	return gmod.env.Vector(a.p:GetLerped(alpha, b.p))
end