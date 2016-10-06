local gmod = ... or gmod

local ENT = gmod.env.FindMetaTable("Entity")

function ENT:__newindex(k,v)
	if not rawget(self, "__storable_table") then rawset(self, "__storable_table", {}) end
	self.__storable_table[k] = v
end

function ENT:SetPos(vec)
	self.__obj:SetPosition(vec.v)
end

function ENT:GetPos()
	return gmod.env.Vector(self.__obj:GetPosition():Unpack())
end

function ENT:GetForward()
	return self.__obj:GetRotation():GetForward()
end

function ENT:GetUp()
	return self.__obj:GetRotation():GetUp()
end

function ENT:GetRight()
	return self.__obj:GetRotation():GetRight()
end

function ENT:GetBoneCount()
	return 0
end

function ENT:GetTable()
	if not rawget(self, "__storable_table") then rawset(self, "__storable_table", {}) end
	return self.__storable_table
end

function ENT:EntIndex()
	return -1
end

function ENT:GetNetworkedString(what)
	if what == "UserGroup" then
		return "Player"
	end
end

function ENT:SetNoDraw() end
function ENT:SetAngles() end
function ENT:GetNumBodyGroups() return 1 end
function ENT:GetBodygroupCount() return 1 end
function ENT:SkinCount() return 1 end
function ENT:LookupSequence() return -1 end
function ENT:DrawModel() end

function ENT:GetClass()
	return self.ClassName or self.MetaName
end

function ENT:GetNWFloat(key, def)
	return def or 0
end

function ENT:GetNWEntity(key, def)
	return def or _G.NULL
end

function ENT:GetAttachedRagdoll()
	return _G.NULL
end

function gmod.env.ClientsideModel(path)
	local ent = entities.CreateEntity("visual")
	ent:SetModelPath(path)
	return gmod.WrapObject(ent, "Entity")
end