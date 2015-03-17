local gmod = ... or gmod

local ENT = gmod.env.FindMetaTable("Entity")

function ENT:__index(key)
	if ENT[key] then
		return ENT[key]
	end
	
	local base = rawget(self, "BaseClass")
	
	if base and base[key] then
		return base[key]
	end
end

function ENT:SetPos(vec)
	self.__obj:SetPosition(vec.v)
end

function ENT:GetPos()
	return gmod.env.Vector(self.__obj:GetPosition():Unpack())
end