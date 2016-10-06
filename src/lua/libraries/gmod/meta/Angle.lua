local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Angle")

function META:__index(key)
	if key == "p" then
		return self.q:GetAngles().x
	elseif key == "y" then
		return self.q:GetAngles().y
	elseif key == "r" then
		return self.q:GetAngles().z
	end

	return META[key]
end

function META:__newindex(key, val)
	local ang = self.q:GetAngles()
	if key == "p" then
		ang.x = val
	elseif key == "y" then
		ang.y = val
	elseif key == "r" then
		ang.z = val
	end
	self.q:SetAngles(ang)
end

function META:__tostring()
	return ("Angle(%f, %f, %f)"):format(self.q:GetAngles():Deg():Unpack())
end

function META.__eq(a, b)
	return a.q == b.q
end

function META.__mul(a, b)
	if type(b) == "number" then
		a.q:SetAngles(a.q:GetAngles() * b)
	else
		a.q:SetAngles(a.q:GetAngles() * b.q:GetAngles())
	end
	return a
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

	if type(p) == "table" then
		local temp = p
		p,y,r = temp.p, temp.y, temp.r
	else
		p = p or 0
		y = y or 0
		r = r or 0
	end

	self.q = QuatDeg3(p, y, r)

	return setmetatable(self, META)
end