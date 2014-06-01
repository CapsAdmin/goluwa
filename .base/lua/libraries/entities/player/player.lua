local META = {}

META.ClassName = "player"
META.TypeX = "player"

META.socket = NULL

class.GetSet(META, "UniqueID", "???")
class.GetSet(META, "ID", -1)

nvars.IsSet(META, "Bot", false)
nvars.GetSet(META, "Nick", e.USERNAME, "cl_nick")

function META:IsConnected()
	return self.connected
end

function META:GetNick()
	for key, ply in pairs(players.GetAll()) do
		if ply ~= self and ply.nv.Nick == self.nv.Nick then
			return ("%s(%i)"):format(self.nv.Nick, self.ID)
		end
	end
	
	return self.nv.Nick or "PubePurse"
end

function META:__tostring()
	return string.format("player[%s][%i]", self:GetName(), self:GetID())
end

function META:GetName()	
	return self.nv and self.nv.Nick or self:GetUniqueID()
end

function META:OnRemove()	
	self.nv:Remove()
	players.active_players[self:GetUniqueID()] = nil
	if SERVER then 
		if self.socket:IsValid() then
			network.HandleMessage(self.socket, network.DISCONNECT, "removed")
		end
	end
end	

function META:GetUniqueColor()
	local r,g,b = tostring(crypto.CRC32(self:GetUniqueID())):match(("(%d%d%d)"):rep(3))
	local c = Color(tonumber(r), tonumber(g), tonumber(b))
	c:SetLightness(1)
	return c
end

if SERVER then
	function META:Kick(reason)
		if self.socket:IsValid() then
			network.HandleMessage(self.socket, network.DISCONNECT, reason or "kicked")
		end
		
		if self:IsBot() then
			event.Call("PlayerLeft", self:GetName(), self:GetUniqueID(), reason, self)
			event.BroadcastCall("PlayerLeft", self:GetName(), self:GetUniqueID(), reason)
			network.BroadcastMessage(network.DISCONNECT, self:GetUniqueID(), reason)
		
			self:Remove()
		end
	end
end

include("pingpong.lua", META)
include("input.lua", META)
include("extended.lua", META)
include("user_command.lua", META)

utilities.DeclareMetaTable(META.ClassName, META)
entities.Register(META)