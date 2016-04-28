local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Angle")

function META:__index(key)
	if key == "p" then
		return self.v.x
	elseif key == "y" then
		return self.v.y
	elseif key == "r" then
		return self.v.z
	end

	return META[key]
end

function META:__newindex(key, val)
	if key == "p" then
		self.v.x = val
	elseif key == "y" then
		self.v.y = val
	elseif key == "r" then
		self.v.z = val
	end
end

function META:__tostring()
	return ("Angle(%f, %f, %f)"):format(self.q:GetAngles():Deg():Unpack())
end

function META.__eq(a, b)
	return a.q == b.q
end

function META.__add(a, b)
	return QuatDeg3((a.q:GetAngles() + b.q:GetAngles()):Unpack())
end

function META:Forward()
	return gmod.env.Vector(self.q:Forward():Unpack())
end

function META:Right()
	return gmod.env.Vector(self.q:Right():Unpack())
end

function META:Up()
	return gmod.env.Vector(self.q:Up():Unpack())
end

function META:IsZero()
	return self.q.x == 0 and self.q.y == 0 and self.q.z == 0
end

function META:Normalize()
	self.q:Normalize()
end

function META:Set(p,y,r)
	self.q = QuatDeg3(p,y,r)
end

function META:RotateAroundAxis(axis, rot)
	self.q:SetAxis(math.deg(rot), axis)
end

function META:Zero()
	self.q:Identity()
end

function gmod.env.Angle(p, y, r)
	local self = {}

	self.q = QuatDeg3(p, y, r)

	return setmetatable(self, META)
end