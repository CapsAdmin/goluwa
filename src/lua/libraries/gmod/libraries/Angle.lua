local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Angle")

function gmod.env.Angle(p, y, r)
	local self = {}

	if type(p) == "table" then
		p, y, r = p.p:Unpack()
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

	self.p = Ang3(p, y, r)

	return setmetatable(self, META)
end

function META:__index(key)
	if key == "p" or key == "pitch" then
		return self.p.x
	elseif key == "y" or key == "yaw" then
		return self.p.y
	elseif key == "r" or key == "roll" then
		return self.p.z
	end

	return META[key]
end

function META:__newindex(key, val)
	if key == "p" then
		self.p.x = val
	elseif key == "y" then
		self.p.y = val
	elseif key == "r" then
		self.p.z = val
	end
end

function META:__tostring()
	return ("Angle(%f, %f, %f)"):format(self.p:Deg():Unpack())
end

function META.__eq(a, b)
	return a.q == b.q
end

function META.__mul(a, b)
	if type(b) == "number" then
		return gmod.env.Angle(a.p * b)
	end

	return gmod.env.Angle(a.p * b.p)
end

function META.__add(a, b)
	return gmod.env.Angle(a.p + b.p)
end

function META:Forward()
	return gmod.env.Vector(self.p:GetRad():GetForward())
end

function META:Right()
	return gmod.env.Vector(self.p:GetRad():GetRight())
end

function META:Up()
	return gmod.env.Vector(self.p:GetRad():GetUp())
end

function META:IsZero()
	return self.p:IsZero()
end

function META:Normalize()
	self.p = self.p:GetDeg():GetNormalized():GetRad()
end

function META:Set(p, y, r)
	self.p.x = p
	self.p.y = y
	self.p.z = r
end

function META:RotateAroundAxis(axis, rot)
	self.p:RotateAroundAxis(axis, math.rad(rad))
end

function META:Zero()
	self.p:Set(0, 0, 0)
end