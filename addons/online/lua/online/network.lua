network = network or {}
network.client_socket = network.client_socket or NULL
network.server_socket = network.server_socket or NULL

e.USER_CONNECT = 1
e.USER_DISCONNECT = 2
e.USER_MESSAGE = 3

-- packet handling
local delimiter = "\n"
local receive_mode = "line"
local buffered = true
local custom_types = {}

local function encode(...)
	
	local args = {...}
	
	for k, v in pairs(args) do
		local t = typex(v)
		local func = custom_types[t]
		if func then			
			args[k] = {"msgpo", t, func(v, true)}
		end	
	end
	
	return msgpack.Encode(unpack(args)) .. delimiter
end

local function decode(...)
	
	local args = {msgpack.Decode(...)}
	
	for k, v in pairs(args) do
		if type(v) == "table" then
			if v[1] == "msgpo" and custom_types[v[2]] then
				if v[3] then
					args[k] = custom_types[v[2]](v[3], false)
				else
					args[k] = NULL
				end
			end
		end
	end

	return unpack(args)
end

local function split_packet(str)
	return str:explode(delimiter)
end

function network.AddEncodeDecodeType(type, callback)
	custom_types[type] = callback
end

function network.HandleEvent(socket, type, uniqueid, ...)		
	if type == e.USER_CONNECT then		
		local player = Player(uniqueid)
				
		if SERVER then			
			
			-- store the socket in the player
			player.socket = socket
						
			if event.Call("OnPlayerConnect", player) ~= false then			
				-- tell all the clients that he just joined
				network.Broadcast(type, uniqueid, ...)
						
				-- now tell him about all the other clients
				for key, other in pairs(players.GetAll()) do
					if other ~= player then
						network.SendToClient(socket, type, other:GetUniqueID(), ...)
					end
				end
			end
		end
				
		-- this should be done after the player is created
		if SERVER then
			nvars.FullUpdate(player)
		end
	
		logf("player %s connected", player:GetName())
	elseif type == e.USER_DISCONNECT then			
		local player = Player(uniqueid)
		
		logf("player %s disconnected (%s)", player:GetName(), reason or "unknown reason")
					
		if SERVER then	
			network.Broadcast(type, uniqueid, socket)
			utilities.SafeRemove(player.socket)
		end
		
		player:Remove()
	elseif type == e.USER_MESSAGE then
		if CLIENT then
			-- the arguments start after type. uniqueid is just used by this library
			event.Call("OnPlayerMessage", uniqueid, ...)
		end
		if SERVER then
			local player = Player(socket:GetIPPort())
			event.Call("OnPlayerMessage", player, uniqueid, ...)
		end
	end	
end

if CLIENT then
	function network.Connect(ip, port)
		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")
				
		local client = network.client_socket or NULL
		
		if client:IsValid() then
			client:Remove()
		end
		
		client = luasocket.Client()
		client:SetReceiveMode(receive_mode)
		client:SetTimeout()
		client:Connect(ip, port)
				
		-- because this will always index network so we can easier reload the script
		function client:OnReceive(str)
			network.HandleEvent(nil, decode(str))
		end
		
		network.client_socket = client
		
		return client
	end

	function network.Disconnect(reason)		
		network.client_socket:Remove()
	end

	function network.SendToServer(event, ...)	
		if network.client_socket:IsValid() then
			network.client_socket:Send(encode(event, ...), buffered)
		end
	end
end

if SERVER then
	function network.Host(ip, port)	
		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")
		
		local id = ip .. port
		
		local server = network.server_socket or NULL
		
		if server:IsValid() then
			server:Remove()
		end
		
		server = luasocket.Server()
		server:Host(ip, port)

		function server:OnClientConnected(client, ip, port)
			client:SetReceiveMode(receive_mode)			
			network.HandleEvent(client, e.USER_CONNECT, client:GetIPPort())
			return true
		end
		
		function server:OnClientClosed(client)
			network.HandleEvent(client, e.USER_DISCONNECT, client:GetIPPort())
		end
		
		function server:OnReceive(str, client)
			network.HandleEvent(client, decode(str))
		end	
		
		network.server_socket = server
	end
	
	function network.GetClients()
		return network.server_socket:GetClients()
	end
		
	function network.SendToClient(client, event, ...)
		client:Send(encode(event, ...), buffered)
	end
	
	function network.Broadcast(event, ...)		
		for _, client in pairs(network.GetClients()) do
			network.SendToClient(client, event, ...)
		end
	end
end