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