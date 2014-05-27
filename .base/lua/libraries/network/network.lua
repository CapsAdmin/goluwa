local network = _G.network or {}

network.tcp = network.tcp or NULL
network.udp = network.udp or NULL

network.CONNECT = 1
network.ACCEPT = 2
network.UDP_PORT = 3

network.DISCONNECT = 4
network.MESSAGE = 5

network.udp_accept = {}

-- packet handling
local delimiter = "\1\3\2"
local receive_mode = 61440
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
	
	return serializer.Encode("msgpack", unpack(args)) .. delimiter
end

local function decode(...)
	
	local ok, args = pcall(function(...) return {serializer.Decode("msgpack", ...)} end, ...)
	
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

function network.HandleMessage(socket, type, a, b, ...)		
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
						
			if event.Call("PlayerConnect", player) ~= false then			
				-- tell all the clients that he just joined
				network.BroadcastMessage(type, uniqueid, ...)
						
				-- now tell him about all the other clients
				for key, other in pairs(players.GetAll()) do
					network.SendMessageToClient(socket, type, other:GetUniqueID(), ...)
				end
				
				network.SendMessageToClient(socket, network.ACCEPT, uniqueid)
			else
				if network.debug then
					debug.trace()
					logf("player %s removed because OnPlayerConnect returned false\n", player)
				end
				player:Remove()
			end
				
			-- this should be done after the player is created
			
			nvars.FullUpdate(player)
			
			logf("%s connected\n", socket:GetIPPort())
		end
		
		if CLIENT then
			event.Call("PlayerConnect", player) 
		end
	elseif CLIENT and type == network.ACCEPT then		
		network.accepted = true
		logf("successfully connected to server\n")
		
		players.local_player = Player(uniqueid)
		players.local_player.socket = network.tcp
					
		event.Call("OnlineStarted")
		
		network.SendMessageToServer(network.UDP_PORT, network.udp:GetPort())
	elseif SERVER and type == network.UDP_PORT then
		
		if _G.type(a) ~= "number" then
			logn("client ", uniqueid ," gave invalid port: ", tostring(a))
			return false
		end
	
		local player = Player(uniqueid)
		socket.udp_port = a
		network.udp_accept[socket:GetIP() .. a] = player
	elseif SERVER and not socket.udp_port then
		-- forgot to send the udp port to server		
		local player = Player(uniqueid)
	
		player:Remove()
		logf("rejecting %s because it forgot to send the UDP_PORT packet after ACCEPT\n", socket:GetIPPort())
		
		return false -- reject the client
	elseif type == network.DISCONNECT then

		if SERVER then
			local player = Player(uniqueid)
			local reason = a
						
			event.Call("PlayerLeft", player:GetName(), uniqueid, reason, player)
			event.BroadcastCall("PlayerLeft", player:GetName(), uniqueid, reason)
			
			logf("%s disconnected (%s)\n", socket:GetIPPort(), reason or "unknown reason")
						
			if SERVER then	
				network.BroadcastMessage(type, uniqueid, reason)				
				network.udp_accept[socket:GetIP() .. socket.udp_port] = nil
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
			event.Call("UserMessage", a, b, ...)
		end
		
		if SERVER then
			local player = Player(uniqueid)
			event.Call("UserMessage", player, a, b, ...)
		end
	end	
end

function network.HandlePacket(str, player)
	if CLIENT then
		event.Call("PacketReceived", str)
	elseif SERVER then
		event.Call("PacketReceived", player, str)
	end
end

do -- string table
	if SERVER then
		local i = 0
		
		function network.AddString(str)
			
			if not network.IsStarted() then
				event.Delay(0, function() network.AddString(str) end)
				return
			end
		
			local id = nvars.Get(str, nil, "string_table1")
			
			if id then return id end
			
			i = i + 1
			nvars.Set(str, i, "string_table1")
			nvars.Set(i, str, "string_table2")
			
			return i
		end
	end

	function network.StringToID(str)
		return nvars.Get(str, nil, "string_table1")
	end
	
	function network.IDToString(id)
		return nvars.Get(id, nil, "string_table2")
	end
end

function network.IsStarted()
	return network.tcp:IsValid()
end

function network.UpdateStatistics()
	system.SetWindowTitle(("TCP in: %s"):format(network.tcp:GetStatistics().received), "network tcp in")
	system.SetWindowTitle(("TCP out: %s"):format(network.tcp:GetStatistics().sent), "network tcp out")
	
	system.SetWindowTitle(("UDP in: %s"):format(network.udp:GetStatistics().received), "network udp in")
	system.SetWindowTitle(("UDP out: %s"):format(network.udp:GetStatistics().sent), "network udp out")
end

if CLIENT then
	function network.Connect(ip, port, retries)
		network.Disconnect("already connected")
		
		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")
		
		retries = retries or 3
		
		if retries > 0 then
			event.Delay(3, function()
				if not network.IsConnected() then
					logf("retrying %s:%s (%i retries left)..\n", ip, port, retries)
					network.Connect(ip, port, retries - 1)
				end	
			end)
		end
		
		do -- tcp
			local client = sockets.CreateClient("tcp", ip, port, "network_client_tcp")
			client:SetTimeout(false)
			client:SetReceiveMode(receive_mode)
					
			local temp = ""
			
			function client:OnReceive(str)
				temp = temp .. str
				
				local found = 0
				
				for message in temp:gmatch("(.-)" .. delimiter) do
					network.HandleMessage(nil, decode(message))
					found = found + 1
				end
				
				if found > 0 then
					temp = temp:match("^.+"..delimiter.."(.*)$") or ""
				end
			end
			
			network.tcp = client
		end
		
		do -- udp
			local client = sockets.CreateClient("udp", ip, port, "network_client_udp")		
			client:SetTimeout(false)
			
			function client:OnReceive(str)
				network.HandlePacket(str, NULL)
			end
			
			network.udp = client	
		end
		
		network.just_disconnected = nil
		
		return client
	end

	function network.Disconnect(reason)	
		reason = reason or "left"
		
		if network.IsConnected() then
			network.SendMessageToServer(network.DISCONNECT, reason)
			network.tcp:Remove()
			
			players.GetLocalPlayer():Remove()
			
			logf("disconnected from server (%s)\n", reason or "unknown reason")
			network.just_disconnected = true
			network.accepted = false
			
			event.Call("Disconnected", reason)
		end
	end

	function network.IsConnected()
		if network.just_disconnected then	
			return false
		end
		return network.tcp:IsValid() and network.tcp:IsConnected() and network.accepted or false
	end
	
	function network.SendMessageToServer(event, ...)		
		if network.tcp:IsValid() then
			network.tcp:Send(encode(event, ...), event ~= network.MESSAGE)
			network.UpdateStatistics()
		end
	end
	
	function network.SendPacketToServer(str)
		if network.udp:IsValid() then
			network.udp:Send(str)
			network.UpdateStatistics()
		end
	end
end

if SERVER then
	function network.Host(ip, port)				
		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")
		
		if network.IsHosting() then
			network.CloseServer("already hosting")
			event.Delay(1, function() network.Host(ip, port) end)
			return
		end
		
		do -- tcp
			local server = sockets.CreateServer("tcp", ip, port, "network_server_tcp")
			
			function server:OnClientConnected(client, ip, port)
				client:SetReceiveMode(receive_mode)
				network.HandleMessage(client, network.CONNECT)
				return true
			end
			
			function server:OnReceive(str, client)
				client.temp = client.temp or ""
				client.temp = client.temp .. str
				
				local found = 0
				
				for message in client.temp:gmatch("(.-)" .. delimiter) do
					if network.HandleMessage(client, decode(message)) == false then
						client:Remove()
					end
					found = found + 1
				end
				
				if found > 0 then
					client.temp = client.temp:match("^.+"..delimiter.."(.*)$") or ""
				end
				
				network.UpdateStatistics()
			end

			network.tcp = server
		end
		
		do -- udp
			local server = sockets.CreateServer("udp", ip, port, "network_server_udp")
			
			-- receive "str, ip, port" instead of "str, client"
			server:UseDummyClient(false)
			
			function server:OnReceive(str, ip, port)
				local player = network.udp_accept[ip .. port]
				if player and player.socket:GetIP() == ip then
					network.HandlePacket(str, player)
				end
				network.UpdateStatistics()
			end
			
			network.udp = server
		end
		
		event.Call("OnlineStarted")
	end
	
	function network.CloseServer(reason)
		network.BroadcastMessage(network.SERVER_CLOSE, reason or "unknown reason")
		
		logf("server shutdown (%s)\n", reason or "unknown reason")
		
		network.tcp:Remove()
		network.udp:Remove()
	end
	
	function network.IsHosting()
		return network.tcp:IsValid()
	end
	
	function network.GetClients()
		return network.tcp:GetClients()
	end
		
	function network.SendMessageToClient(client, event, ...)
		if not client:IsValid() then return end
		client:Send(encode(event, ...), event ~= network.MESSAGE)
		network.UpdateStatistics()
	end
	
	function network.SendPacketToClient(client, str)
		if not client:IsValid() or not client.udp_port then return end
		network.udp:Send(str, client:GetIP(), client.udp_port)
		network.UpdateStatistics()
	end
	
	function network.BroadcastMessage(event, ...)		
		for _, client in pairs(network.GetClients()) do
			network.SendMessageToClient(client, event, ...)
		end
	end
	
	function network.BroadcastPacket(str)		
		for _, client in pairs(network.GetClients()) do
			network.SendPacketToClient(client, str)
		end
	end
end

-- some usage

console.AddCommand("say", function(line)
	chat.Say(line)
end)

console.AddCommand("lua_run", function(line)
	easylua.RunLua(players.GetLocalPlayer(), line, nil, true)
end)

console.AddCommand("lua_open", function(line)
	easylua.Start(players.GetLocalPlayer())
		include(line)
	easylua.End()
end)

console.AddServerCommand("lua_run_sv", function(ply, line)
	logn(ply:GetNick(), " ran ", line)
	easylua.RunLua(ply, line, nil, true)
end)

console.AddServerCommand("lua_open_sv", function(ply, line)
	logn(ply:GetNick(), " opened ", line)
	easylua.Start(ply)
		include(line)
	easylua.End()
end)


local default_ip = "*"
local default_port = 1234

if CLIENT then
	local ip_cvar = console.CreateVariable("cl_ip", default_ip)
	local port_cvar = console.CreateVariable("cl_port", default_port)
	
	console.AddCommand("connect", function(line, ip, port)		
		ip = ip or ip_cvar:Get()
		port = tonumber(port) or port_cvar:Get()
		
		logf("connecting to %s:%i\n", ip, port)
		
		network.Connect(ip, port)
	end)

	console.AddCommand("disconnect", function(line)	
		network.Disconnect(line)
	end)
end

if SERVER then
	local ip_cvar = console.CreateVariable("sv_ip", default_ip)
	local port_cvar = console.CreateVariable("sv_port", default_port)
			
	console.AddCommand("host", function(line, ip, port)
		ip = ip or ip_cvar:Get()
		port = tonumber(port) or port_cvar:Get()
		
		logf("hosting at %s:%i\n", ip, port)
		
		network.Host(ip, port)
	end)
end

return network