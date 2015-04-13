local gmod = ... or gmod

local ENT = gmod.env.FindMetaTable("Entity")

function ENT:__newindex(k,v)
	self.__storable_table[k] = v
end

function ENT:SetPos(vec)
	self.__obj:SetPosition(vec.v)
end

function ENT:GetPos()
	return gmod.env.Vector(self.__obj:GetPosition():Unpack())
end

function ENT:GetTable()
	return self.__storable_table
end

function ENT:SetNoDraw() end
function ENT:SetAngles() end
function ENT:LookupSequence() return -1 end
function ENT:DrawModel() end

function gmod.env.ClientsideModel(path)
	local ent = entities.CreateEntity("visual")
	ent:SetModelPath(path)
	local self = gmod.WrapObject(ent, "Entity")
	rawset(self, "__storable_table", {})
	return self
end