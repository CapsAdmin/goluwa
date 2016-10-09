local gmod = ... or gmod

local ENT = gmod.env.FindMetaTable("Entity")

function ENT:__newindex(k,v)
	if not rawget(self, "__storable_table") then rawset(self, "__storable_table", {}) end
	self.__storable_table[k] = v
end

function ENT:GetTable()
	if not rawget(self, "__storable_table") then rawset(self, "__storable_table", {}) end
	return self.__storable_table
end

function ENT:SetPos(vec)
	self.__obj:SetPosition(vec.v)
end

function ENT:GetPos()
	return gmod.env.Vector(self.__obj:GetPosition():Unpack())
end

function ENT:GetForward()
	return gmod.env.Vector(self.__obj:GetRotation():GetForward():Unpack())
end

function ENT:GetUp()
	return gmod.env.Vector(self.__obj:GetRotation():GetUp():Unpack())
end

function ENT:GetRight()
	return gmod.env.Vector(self.__obj:GetRotation():GetRight():Unpack())
end

function ENT:GetBoneCount()
	return 0
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

function ENT:GetVelocity()
	return gmod.env.Vector(0, 0, 0)
end

function ENT:IsFlagSet()
	return false
end

function ENT:GetOwner()
	return NULL
end

function ENT:GetSkin()
	return 0
end

function ENT:GetModel()
	return ""
end

function ENT:IsDormant()
	return true
end

function ENT:GetSpawnEffect()
	return false
end

function ENT:GetNWBool()
	return false
end

function ENT:GetMoveType()
	return gmod.env.MOVETYPE_NONE
end

function gmod.env.ClientsideModel(path)
	local ent = entities.CreateEntity("visual")
	ent:SetModelPath(path)
	return gmod.WrapObject(ent, "Entity")
end

function ENT:LocalToWorld()
	return gmod.env.Vector()
end

function ENT:OBBCenter()
	return gmod.env.Vector()
end