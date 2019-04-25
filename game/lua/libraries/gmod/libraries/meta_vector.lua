local META = gine.GetMetaTable("Vector")

function gine.env.Vector(x, y, z)
	local self = {}

	if type(x) == "table" then
		x, y, z = x.ptr:Unpack()
	elseif type(x) == "cdata" then
		x, y, z = x:Unpack()
	elseif type(x) == "string" then
		x, y, z = x:match("(%S+)%s-(%S+)%s-(%S+)")
		x = tonumber(x)
		y = tonumber(y)
		z = tonumber(z)
	end

	if type(x) ~= "number" then
		x = 0
	end

	if type(y) ~= "number" then
		y = 0
	end

	if type(z) ~= "number" then
		z = 0
	end

	self.ptr = Vec3(x, y, z)

	return setmetatable(self, META)
end

function META:__index(key)
	if key == "x" or key == "r" then
		return self.ptr.x
	elseif key == "y" or key == "g" then
		return self.ptr.y
	elseif key == "z" or key == "b" then
		return self.ptr.z
	end

	return META[key]
end

function META:__newindex(key, val)
	if key == "x" then
		self.ptr.x = val
	elseif key == "y" then
		self.ptr.y = val
	elseif key == "z" then
		self.ptr.z = val
	end
end
function META:__tostring()
	return ("Vector(%f, %f, %f)"):format(self.ptr:Unpack())
end

function META.__eq(a, b)
	return a.ptr == b.ptr
end

function META.__unm(a)
	return gine.env.Vector(-a.ptr)
end

function META.__add(a, b)
	return gine.env.Vector(a.ptr + b.ptr)
end

function META.__sub(a, b)
	return gine.env.Vector(a.ptr - b.ptr)
end

function META.__mul(a, b)
	if type(b) == "number" then
		return gine.env.Vector(a.ptr * b)
	elseif type(a) == "number" then
		return gine.env.Vector(a * b.ptr)
	end

	return gine.env.Vector(a.ptr * b.ptr)
end

function META.__div(a, b)
	if type(b) == "number" then
		return gine.env.Vector(a.ptr / b)
	elseif type(a) == "number" then
		return gine.env.Vector(a / b.ptr)
	end

	return gine.env.Vector(a.ptr / b.ptr)
end

function META:ToScreen()
	local pos,vis = math3d.WorldPositionToScreen(self.ptr)
	return {
		x = pos.x,
		y = pos.y,
		visible = vis > 0,
	}
end

function META:Zero()
	self.ptr:Set(0, 0, 0)
end

function META:Cross(vec)
	return gine.env.Vector(self.ptr:Cross(vec))
end

function META:Rotate()

end

function META:Distance(vec)
	return self.ptr:Distance(vec.ptr)
end

function META:Dot(vec)
	return self.ptr:GetDot(vec.ptr)
end

function META:Rotate(ang)

end

META.DotProduct = META.Dot

function META:Normalize()
	self.ptr:Normalize()
end

function META:GetNormalized()
	return gine.env.Vector(self.ptr:GetNormalized())
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
	if type(vec) == "number" then
		self.x = self.x * vec
		self.y = self.y * vec
		self.z = self.z * vec
	else
		self.x = self.x * vec.x
		self.y = self.y * vec.y
		self.z = self.z * vec.z
	end
end

function META:Set(vec)
	self.x = vec.x
	self.x = vec.y
	self.z = vec.z
end

function META:Angle()
	return gine.env.Angle(self.ptr:GetAngles())
end

function META:Length()
	return self.ptr:GetLength()
end
function META:DistToSqr(b)
	return (self.ptr - b.ptr):GetLengthSquared()
end

function META:IsZero()
	return self.ptr:IsZero()
end

function gine.env.LerpVector(alpha, a, b)
	return gine.env.Vector(a.ptr:GetLerped(alpha, b.ptr))
end
