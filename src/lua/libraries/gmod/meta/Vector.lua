local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Vector")

META.__gc = nil

function META:__index(key)
	if key == "x" then
		return self.v.x
	elseif key == "y" then
		return self.v.y
	elseif key == "z" then
		return self.v.z
	end

	return META[key]
end

function META:__newindex(key, val)
	self.v[key] = val
end

function META:__tostring()
	return ("Vector(%f, %f, %f)"):format(self.v:Unpack())
end

function META.__eq(a, b)
	return a.v == b.v
end

function META.__add(a, b) return gmod.env.Vector((a.v + b.v):Unpack()) end
function META.__sub(a, b) return gmod.env.Vector((a.v - b.v):Unpack()) end
function META.__mul(a, b) if type(b) == "number" then return gmod.env.Vector((a.v * b):Unpack()) elseif type(a) == "number" then return gmod.env.Vector((a * b.v):Unpack()) else return gmod.env.Vector((a.v * b.v):Unpack()) end end
function META.__div(a, b) if type(b) == "number" then return gmod.env.Vector((a.v / b):Unpack()) elseif type(a) == "number" then return gmod.env.Vector((a / b.v):Unpack()) else return gmod.env.Vector((a.v / b.v):Unpack()) end end

function META:ToScreen()
	local pos,vis = math3d.WorldPositionToScreen(self.v)
	return {
		x = pos.x,
		y = pos.y,
		visible = vis > 0,
	}
end

function META:Zero()
	self.v:Set(0,0,0)
end

function META:Cross(vec)
	return gmod.env.Vector(self.v:Cross(vec):Unpack())
end

function META:Cross(vec)
	return self.v:Distance(vec.v)
end

function META:Dot(vec)
	return self.v:Dot(vec.v)
end

META.DotProduct = META.Dot

function META:Normalize()
	self.v:Normalize()
end

function META:GetNormalized()
	self.v:GetNormalized()
end

META.GetNormal = META.GetNormalized

function META:Add(vec)
	self.x = self.x + vec.x
	self.y = self.y + vec.y
	self.z = self.z + vec.z
end

function META:Angle()
	return gmod.env.Angle(self.v:GetAngles():Unpack())
end

function META:Length()
	return self.v:GetLength()
end

function META:IsZero()
	return self.v.x == 0 and self.v.y == 0 and self.v.z == 0
end

function gmod.env.LerpVector(alpha, a, b)
	return a.v:GetLerped(alpha, b.v)
end

function gmod.env.Vector(x, y, z)
	local self = {}

	if type(x) == "string" then
		x, y, z = x:match("(%S+)%s-(%S+)%s-(%S+)")
		x = tonumber(x)
		y = tonumber(y)
		z = tonumber(z)
	end

	self.v = Vec3(x or 0, y or 0, z or 0)

	return setmetatable(self, META)
end
