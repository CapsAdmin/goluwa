local clients = _G.clients or {}

local META = metatable.CreateTemplate("client")

include("client/client.lua", META)

clients.active_clients = clients.active_clients or {}
clients.local_client = clients.local_client or NULL

function clients.GetAll()
	return clients.active_clients
end

function clients.GetByUniqueID(id)
	return clients.active_clients[id] or NULL
end

function clients.GetLocalClient()
	return clients.local_client or NULL
end
	
function clients.BroadcastLua(str)
	for key, client in pairs(clients.GetAll()) do
		client:SendLua(str)
	end
end
		
function clients.Create(uniqueid, is_bot, clientside, filter, local_client)
	local self = clients.active_clients[uniqueid] or NULL

	if self:IsValid() then
	
		if SERVER then
			if clientside == nil or clientside then
				message.Send("create_client", filter, uniqueid, is_bot, local_client)
			end
		end
	
		return self
	end
	
	local self = META:New()
		
	self:SetUniqueID(uniqueid)
	
	clients.active_clients[self.UniqueID] = self
			
	-- add a networked table to the client
	self.nv = nvars.CreateObject(uniqueid)
	
	if is_bot ~= nil then
		self:SetBot(is_bot)
	end
	
	if SERVER then
		if is_bot then	
			if event.Call("ClientConnect", self) ~= false then
				event.Call("ClientEntered", self)
			end
		end
	end
		
	return self
end

if CLIENT then
	message.AddListener("create_client", function(uniqueid, is_bot, local_client)
		local client = clients.Create(uniqueid, is_bot)
		
		if local_client then
			clients.local_client = client
		end
		
		event.Call("ClientEntered", client)
	end)
end

do -- filter
	local META = metatable.CreateTemplate("client_filter")

	function META:AddAll()
		for key, client in pairs(clients.GetAll()) do
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
		return self.clients
	end

	function clients.CreateFilter()
		return META:New({clients = {}}, true)
	end
end

message.AddEncodeDecodeType("client", function(var, encode)
	if encode then
		return var:GetUniqueID()
	else
		return clients.GetByUniqueID(var)
	end
end)

return clients