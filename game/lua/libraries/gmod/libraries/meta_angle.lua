local META = gine.GetMetaTable("Angle")

function gine.env.LerpAngle(f, a, b)
	return gine.env.Angle(a.ptr:GetLerped(f, b.ptr))
end

function gine.env.Angle(p, y, r)
	local self = {}

	if type(p) == "table" then
		p, y, r = p.ptr:Unpack()
	elseif type(p) == "cdata" then
		p, y, r = p:Unpack()
	elseif type(p) == "string" then
		p, y, r = x:match("(%S+)%s-(%S+)%s-(%S+)")
		p = tonumber(x)
		y = tonumber(y)
		r = tonumber(z)
	end

	p = p or 0
	y = y or 0
	r = r or 0

	self.ptr = Ang3(p, y, r)

	return setmetatable(self, META)
end

function META:__index(key)
	if key == "p" or key == "pitch" then
		return self.ptr.x
	elseif key == "y" or key == "yaw" then
		return self.ptr.y
	elseif key == "r" or key == "roll" then
		return self.ptr.z
	end

	return META[key]
end

function META:__newindex(key, val)
	if key == "p" then
		self.ptr.x = val
	elseif key == "y" then
		self.ptr.y = val
	elseif key == "r" then
		self.ptr.z = val
	end
end

function META:__tostring()
	return ("Angle(%f, %f, %f)"):format(self.ptr:Deg():Unpack())
end

function META.__eq(a, b)
	return a.q == b.q
end

function META:__unm()
	return gine.env.Angle(-self.ptr)
end

function META.__mul(a, b)
	if type(b) == "number" then
		return gine.env.Angle(a.ptr * b)
	end

	return gine.env.Angle(a.ptr * b.ptr)
end

function META.__add(a, b)
	return gine.env.Angle(a.ptr + b.ptr)
end

function META.__sub(a, b)
	return gine.env.Angle(a.ptr - b.ptr)
end

function META:Forward()
	return gine.env.Vector(self.ptr:GetRad():GetForward())
end

function META:Right()
	return gine.env.Vector(self.ptr:GetRad():GetRight())
end

function META:Up()
	return gine.env.Vector(self.ptr:GetRad():GetUp())
end

function META:IsZero()
	return self.ptr:IsZero()
end

function META:Normalize()
	self.ptr = self.ptr:GetRad():GetNormalized():GetDeg()
end

function META:Set(p, y, r)
	self.ptr.x = p
	self.ptr.y = y
	self.ptr.z = r
end

function META:RotateAroundAxis(axis, rot)
	self.ptr:RotateAroundAxis(axis.ptr, math.rad(rot))
end

function META:Zero()
	self.ptr:Set(0, 0, 0)
end
