local META = prototype.CreateTemplate("client")

META.Name = "client"

META.socket = NULL

META:GetSet("UniqueID", "???")

nvars.IsSet(META, "Bot", false)
nvars.GetSet(META, "Group", "player")
nvars.GetSet(META, "Nick", e.USERNAME, "cl_nick")
nvars.GetSet(META, "AvatarPath", "https://avatars2.githubusercontent.com/u/204157?v=3&s=460", "cl_avatar_path")
nvars.GetSet(META, "Ping", -1)

function META:IsConnected()
	return self.connected
end

function META:GetNick()
	for key, client in ipairs(clients.GetAll()) do
		if client ~= self and client.nv.Nick and client.nv.Nick == self.nv.Nick then
			return ("%s (%s)"):format(self.nv.Nick, self:GetUniqueID())
		end
	end

	return self.nv.Nick or self.last_nick or "PubePurse"
end

function META:__tostring2()
	return string.format("[%s][%s]", self:GetName(), self:GetUniqueID())
end

function META:GetName()
	return self.nv and self.nv.Nick or self:GetUniqueID()
end

if SERVER then
	function META:SetGroup(group)
		local old = self.nv.Group
		self.nv.Group = group
		if old ~= group then
			event.CallShared("ClientChangedGroup", self, self.nv.Group)
		end
	end
end

function META:OnRemove()
	self.nv:Remove()

	clients.active_clients_uid[self:GetUniqueID()] = nil
	table.removevalue(clients.active_clients, self)

	if SERVER then
		self:Disconnect("removed")
	end
end

function META:GetUniqueColor()
	local crc = crypto.CRC32(self:GetUniqueID())
	local r,g,b = crc:match("(%d%d%d)(%d%d%d)(%d%d%d)")
	if not r then
		r,g,b = crc:match("(%d%d)(%d%d)(%d%d)")
	end
	local c = Color(tonumber(r), tonumber(g), tonumber(b), 1)
	c:SetLightness(1)
	return c
end

if SERVER then
	local reasons = {
		[0] = "timeout / unknown reason",
		[1] = "disconnected",
	}

	function META:Disconnect(code)
		if not self.disconnected then
			self.disconnected = true

			local reason = reasons[code] or "unknown disconnect code " .. code

			event.Call("ClientLeft", self, reason)
			message.Send("remove_client", nil, self:GetUniqueID(), reason)

			if self.socket:IsValid() then
				self.socket:Disconnect(code)
			end
		end
	end

	function META:Kick(reason)
		self:Disconnect(reason)
		self:Remove()
	end
end

runfile("input.lua", META)
runfile("extended.lua", META)
runfile("user_command.lua", META)

META:Register()

if SERVER then
	event.Timer("update_clients", 1, 0, function()
		for _, client in ipairs(clients.GetAll()) do
			if not client:IsBot() then
				client:SetPing(client.socket.peer.roundTripTime)
			end
		end
	end)
end
