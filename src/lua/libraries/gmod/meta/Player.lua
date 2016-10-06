local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Player")

function gmod.env.LocalPlayer()
	gmod.local_player = gmod.local_player or gmod.WrapObject(clients.GetLocalClient(), "Player")
	return gmod.local_player
end

function META:EyePos()
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
	return gmod.WrapObject(gmod.CreateWeapon(), "Weapon")
end

function META:IsPlayer()
	return true
end

function META:UserID()
	return 0
end

function META:GetFriendStatus()
	return "none"
end