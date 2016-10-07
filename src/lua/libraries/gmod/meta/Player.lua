local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Player")

function gmod.env.LocalPlayer()
	gmod.local_player = gmod.local_player or gmod.WrapObject(clients.GetLocalClient(), "Player")
	return gmod.local_player
end

function META:EyePos()
	return gmod.env.EyePos()
end

function META:GetPos()
	return gmod.env.EyePos()
end

function META:EyeAngles()
	return gmod.env.EyeAngles()
end

function META:GetAimVector()
	return gmod.env.EyeVector()
end

function META:GetViewEntity()
	return NULL
end

function META:Armor()
	return 50
end

function META:Health()
	return 100
end

function META:GetMaxHealth()
	return 100
end

function META:Team()
	return 0
end

function META:Frags()
	return 0
end

function META:Deaths()
	return 0
end

function META:Ping()
	return 0
end

function META:IsMuted()
	return false
end

function META:IsBot()
	return false
end

function META:SteamID()
	return "STEAM_0:1:9355639"
end

function META:SteamID64()
	return "76561197978977007"
end

function META:Nick()
	return self.__obj:GetNick()
end

function META:ConCommand(str)
	logn("gmod cmd: ", str)
end

function META:UniqueID()
	return crypto.CRC32(self.__obj:GetUniqueID())
end

function META:GetActiveWeapon()
	if not self.__obj.gmod_weapon then
		self.__obj.gmod_weapon = gmod.CreateWeapon()
	end
	return gmod.WrapObject(self.__obj.gmod_weapon, "Weapon")
end

function META:IsPlayer()
	return true
end

function META:UserID()
	return math.abs(tonumber(self:UniqueID())%1000) -- todo
end

function META:GetFriendStatus()
	return "none"
end

function META:GetAttachedRagdoll()
	return _G.NULL
end

function META:SetClassID(id)
	self.__obj.gmod_classid = id
end

function META:GetClassID()
	return self.__obj.gmod_classid or 0
end

function META:IsDrivingEntity(ent)
	return false
end

function META:GetVehicle()
	return NULL
end

function META:InVehicle()
	return false
end

function META:Alive()
	return true
end

function META:IPAddress()
	return "192.168.1.101:27005"
end

function META:IsSpeaking()
	return false
end

function META:GetInfoNum(key, def)
	return def or 0
end