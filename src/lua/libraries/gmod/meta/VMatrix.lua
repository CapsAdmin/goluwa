local gmod = ... or gmod

local META = gmod.env.FindMetaTable("VMatrix")

function gmod.env.Matrix()
	local self = {}

	self.m = Matrix44()

	return setmetatable(self, META)
end


function META:Translate(v)
	self.m:Translate(v.x, v.y, v.z)
end