network = network or {}
network.client_socket = network.client_socket or NULL
network.server_socket = network.server_socket or NULL

network.udp_receiver = network.udp_receiver or NULL

network.CONNECT = 1
network.DISCONNECT = 2
network.ACCEPT = 3
network.MESSAGE = 4

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
	
	local ok, args = pcall(function(...) return {msgpack.Decode(...)} end, ...)
	
	if not ok then
		local str = select(1, ...)
		-- this error makes no sense and the stack trace ends here
		-- str is usually "fffft" where t is often a random character
		
		--...x/goluwa/.base/lua/glw/libraries/network/network.lua:34: bad argument #1 to 'Decode' (table expected, got number)
		
		--print(args)
		--print(str, type(str))
		
		return {}
	end
	
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

local function ipport_to_uid(ipport)
	return tostring(123456789 + ipport:gsub("%D", "")%255255255255)
end

function network.HandleEvent(socket, type, a, b, ...)		
	local uniqueid
	
	if CLIENT then
		uniqueid = a
	end
	
	if SERVER then
		uniqueid = ipport_to_uid(socket:GetIPPort())
	end
	
	if type == network.CONNECT then		
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
				
				network.SendToClient(socket, network.ACCEPT, uniqueid)
			else
				if network.debug then
					debug.trace()
					logf("player %s removed because OnPlayerConnect returned false", player)
				end
				player:Remove()
			end
				
			-- this should be done after the player is created
			
			nvars.FullUpdate(player)
			
			logf("%s connected", socket:GetIPPort())
		end
		
		if CLIENT then
			event.Call("OnPlayerConnect", player) 
		end
	end
	
	
	if SERVER then 
		local player = Player(uniqueid)
		
		-- if the player does not have a socket it forgot to connect
		if not player.socket then
			-- reject the client
			player:Remove()
			return false 
		end
	end
	
	if type == network.ACCEPT then		
		if CLIENT then
			network.accepted = true
			logf("successfully connected to server")
			
			players.local_player = Player(uniqueid)
			players.local_player.socket = network.client_socket
						
			event.Call("OnlineStarted")
		end
	elseif type == network.DISCONNECT then

		if SERVER then
			local player = Player(uniqueid)
			local reason = a
			
			logf("%s disconnected (%s)", socket:GetIPPort(), reason or "unknown reason")
						
			if SERVER then	
				network.Broadcast(type, uniqueid, reason)
			end
			
			player:Remove()
		end
		
		if CLIENT then
			local player = Player(uniqueid)

			player:Remove()
		end
	elseif type == network.MESSAGE then
		if CLIENT then
			-- the arguments start after type. uniqueid is just used by this library
			event.Call("OnUserMessage", a, b, ...)
		end
		
		if SERVER then
			local player = Player(uniqueid)
			event.Call("OnUserMessage", player, a, b, ...)
		end
	end	
end

function network.IsStarted()
	return network.server_socket:IsValid() or network.client_socket:IsValid()
end

if CLIENT then
	function network.Connect(ip, port, retries)
		network.Disconnect()
		
		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")
		retries = retries or 3
				
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
		
		--[[local udp = luasocket.Server("udp")
		
		udp:Host(ip, port)
		udp.OnReceive = logn
		
		network.udp_receiver = udp]]
		
		if retries > 0 then
			timer.Delay(3, function()
				if not network.IsConnected() then
					logf("retrying %s:%s (%i retries left)..", ip, port, retries)
					network.Connect(ip, port, retries - 1)
				end	
			end)
		end
		
		network.just_disconnected = nil
		
		return client
	end

	function network.Disconnect(reason)	
		reason = reason or "left"
		
		if network.IsConnected() then
			network.SendToServer(network.DISCONNECT, reason)
			network.client_socket:Remove()
			
			players.GetLocalPlayer():Remove()
			
			logf("disconnected from server")
			network.just_disconnected = true
			network.accepted = false
		end
	end

	function network.IsConnected()
		if network.just_disconnected then	
			return false
		end
		return network.client_socket:IsValid() and network.client_socket:IsConnected() and network.accepted
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
			network.HandleEvent(client, network.CONNECT)
			return true
		end

		function server:OnReceive(str, client)
			if network.HandleEvent(client, decode(str)) == false then
				client:Remove()
			end
		end	
		
		event.Call("OnlineStarted")
		
		network.server_socket = server
		
		local udp = luasocket.Server("udp")
		
		udp:Host(ip, port)
		udp.OnReceive = logn
		
		network.udp_receiver = udp
	end
	
	function network.GetClients()
		return network.server_socket:GetClients()
	end
		
	function network.SendToClient(client, event, ...)
		if not client or not client:IsValid() then debug.trace() end
		client:Send(encode(event, ...), buffered)
	end
	
	function network.Broadcast(event, ...)		
		for _, client in pairs(network.GetClients()) do
			network.SendToClient(client, event, ...)
		end
	end
end