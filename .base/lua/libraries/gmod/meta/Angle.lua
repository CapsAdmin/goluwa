local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Angle")
META.__index = META

function META:__tostring()
	return ("Angle(%f, %f, %f)"):format(self.q:GetAngles():Deg():Unpack())
end

function META:Forward()
	return self.q:Forward()
end

function META:Right()
	return self.q:Right()
end

function META:Up()
	return self.q:Up()
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
	
	self.q = QuatDeg3(p,y,r)
	
	return setmetatable(self, META)
end