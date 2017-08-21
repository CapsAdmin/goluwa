local clients = _G.clients or {}

runfile("client/client.lua")

clients.active_clients_uid = clients.active_clients_uid or {}
clients.active_clients = clients.active_clients or {}

function clients.GetAll()
	return clients.active_clients
end

function clients.GetByUniqueID(id)
	return clients.active_clients_uid[id] or NULL
end

function clients.GetLocalClient()
	return clients.local_client or NULL
end

function clients.BroadcastLua(str)
	for _, client in ipairs(clients.GetAll()) do
		client:SendLua(str)
	end
end

function clients.Create(uniqueid, is_bot, clientside, filter, local_client)
	local self = clients.active_clients_uid[uniqueid] or NULL

	if self:IsValid() then

		if SERVER then
			if clientside == nil or clientside then
				message.Send("create_client", filter, uniqueid, is_bot, local_client)
			end
		end

		return self
	end

	self = prototype.CreateObject("client")

	self:SetUniqueID(uniqueid)

	clients.active_clients_uid[self.UniqueID] = self
	table.insert(clients.active_clients, self)

	-- add a networked table to the client
	self.nv = nvars.CreateObject(uniqueid)

	if is_bot ~= nil then
		self:SetBot(is_bot)
	end

	if SERVER then
		if is_bot then
			message.Send("create_client", filter, uniqueid, is_bot, local_client)
			if event.Call("ClientConnect", self) ~= false then
				event.Delay(function()
					event.Call("ClientEntered", self)
				end)
			end
		end
	end

	return self
end

function clients.CreateBot()
	local nick = string.randomwords(1, math.random()):trim()
	local bot = clients.Create(crypto.CRC32(nick), true)
	bot:SetNick(nick)
	bot:SetGroup(math.random() < 0.5 and "bot team a" or "bot team b")
	return bot
end

if CLIENT then
	message.AddListener("create_client", function(uniqueid, is_bot, local_client)
		local client

		if local_client then
			client = clients.local_client

			local old_nv = client.nv
			client.nv = nvars.CreateObject(uniqueid)
			for k, v in pairs(old_nv) do
				client.nv[k] = v
			end

			clients.active_clients_uid[client.UniqueID] = nil
			client:SetUniqueID(uniqueid)
			clients.active_clients_uid[client.UniqueID] = client
		else
			client = clients.Create(uniqueid, is_bot)
		end

		event.Call("ClientEntered", client)
	end)

	message.AddListener("remove_client", function(uniqueid, reason)
		local client = clients.active_clients_uid[uniqueid]

		if client then
			event.Call("ClientLeft", client, reason)
			client:Remove()
		end
	end)
end

do -- filter
	local META = prototype.CreateTemplate("client_filter")

	function META:AddAll()
		for _, client in ipairs(clients.GetAll()) do
			self.clients[client:GetUniqueID()] = client
		end

		return self
	end

	function META:AddAllExcept(client)
		self:AddAll()
		self.clients[client:GetUniqueID()] = nil

		return self
	end

	function META:Add(client)
		self.clients[client:GetUniqueID()] = client

		return self
	end

	function META:Remove(client)
		self.clients[client:GetUniqueID()] = nil

		return self
	end

	function META:GetAll()
		local out = {}

		for _, client in pairs(self.clients) do
			if client:IsValid() then
				table.insert(out, client)
			end
		end

		return out
	end

	function clients.CreateFilter()
		return prototype.CreateObject(META, {clients = {}}, true)
	end

	META:Register()
end

packet.ExtendBuffer(
	"Client",
	function(buffer, client)
		buffer:WriteString(client:GetUniqueID())
	end,
	function(buffer)
		return clients.GetByUniqueID(buffer:ReadString())
	end
)

clients.local_client = clients.local_client or clients.Create("unconnected")

return clients
