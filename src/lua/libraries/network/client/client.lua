local META = prototype.CreateTemplate("client")

META.Name = "client"

META.socket = NULL

META:GetSet("UniqueID", "???")

nvars.IsSet(META, "Bot", false)
nvars.GetSet(META, "Group", "player")
nvars.GetSet(META, "Nick", e.USERNAME, "cl_nick")
nvars.GetSet(META, "AvatarPath", "https://avatars2.githubusercontent.com/u/204157?v=3&s=460", "cl_avatar_path")

function META:IsConnected()
	return self.connected
end

function META:GetNick()
	for key, client in ipairs(clients.GetAll()) do
		if client ~= self and client.nv.Nick == self.nv.Nick then
			return ("%s(%s)"):format(self.nv.Nick, self:GetUniqueID())
		end
	end

	return self.nv.Nick or "PubePurse"
end

function META:__tostring2()
	return string.format("[%s][%s]", self:GetName(), self:GetUniqueID())
end

function META:GetName()
	return self.nv and self.nv.Nick or self:GetUniqueID()
end

function META:OnRemove()
	self.nv:Remove()

	clients.active_clients_uid[self:GetUniqueID()] = nil
	table.removevalue(clients.active_clients, self)

	if SERVER then
		if self.socket:IsValid() then
			self.socket:Disconnect(--[[removed]])
		end
	end
end

function META:GetUniqueColor()
	local r,g,b = tostring(crypto.CRC32(self:GetUniqueID())):match(("(%d%d%d)"):rep(3))
	local c = Color(tonumber(r), tonumber(g), tonumber(b), 1)
	c:SetLightness(1)
	return c
end

if SERVER then
	function META:Kick(reason)
		if self.socket:IsValid() then
			network.HandleMessage(self.socket, network.DISCONNECT, reason or "kicked")
		end

		if self:IsBot() then
			event.Call("ClientLeft", self:GetName(), self:GetUniqueID(), reason, self)
			event.BroadcastCall("ClientLeft", self:GetName(), self:GetUniqueID(), reason)
			network.BroadcastMessage(network.DISCONNECT, self:GetUniqueID(), reason)

			self:Remove()
		end
	end
end

include("input.lua", META)
include("extended.lua", META)
include("user_command.lua", META)
include("chat_above_head.lua", META)

prototype.Register(META)