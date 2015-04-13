local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Player")

function gmod.env.LocalPlayer()
	gmod.local_player = gmod.local_player or gmod.WrapObject(clients.GetLocalClient(), "Player")
	return gmod.local_player
end

function META:EyePos()
	return gmod.env.Vector(render.camera_3d:GetPosition():Unpack())
end

gmod.env.EyePos = META.EyePos

function META:EyeAng()
	return gmod.env.Angles(render.camera_3d:GetAngles():Unpack())
end

gmod.env.EyeAng = META.EyeAng

function META:GetAimVector()
	return gmod.env.Vector(render.camera_3d:GetAngles():GetForward():Unpack())
end

function META:GetViewEntity()
	return NULL
end