local network = _G.network or {}

network.debug = true

network.tcp = network.tcp or NULL
network.udp = network.udp or NULL

network.CONNECT = 1
network.UDP_PORT = 2
network.CONNECTED = 3
network.SYNCHRONIZED = 4
network.READY = 5

network.DISCONNECT = 6
network.MESSAGE = 7

network.udp_accept = network.udp_accept or {}

-- packet handling
local delimiter = "\1\3\2"
local receive_mode = 61440
local buffered = true
network.serializer_types = network.serializer_types or {}

local function encode(...)
	
	local args = {...}
	
	for k, v in pairs(args) do
		local t = typex(v)
		local func = network.serializer_types[t]
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
			if v[1] == "msgpo" and network.serializer_types[v[2]] then
				if v[3] then
					args[k] = network.serializer_types[v[2]](v[3], false)
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
	network.serializer_types[type] = callback
end

local function ipport_to_uid(ipport)
	return tostring(123456789 + ipport:gsub("%D", "")%255255255255)
end

function network.HandleMessage(socket, stage, a, ...)
	local uniqueid = SERVER and ipport_to_uid(socket:GetIPPort()) or CLIENT and a
	
	if SERVER and stage == network.CONNECT then
	
		local client = clients.Create(uniqueid)
		
		if network.debug then
			logf("client %s connected\n", client)
		end
			
		-- store the socket in the client
		client.socket = socket
					
		if event.Call("ClientConnect", client) == false then
			
			if network.debug then
				logf("client %s removed because the ClientConnect event returned false\n", client)
			end
			
			client:Remove()			
			socket:Remove()
			return
		end
		
		if network.debug then
			logn("requesting udp port from ", client)
		end
		
		-- request the udp port
		network.SendMessageToClient(socket, network.UDP_PORT, uniqueid)
		
	elseif CLIENT and stage == network.UDP_PORT then
	
		if network.debug then
			logf("sending udp port %s to server\n", network.udp:GetPort())
		end
		
		network.SendMessageToServer(network.UDP_PORT, network.udp:GetPort())
		
	elseif SERVER and stage == network.UDP_PORT then
	
		local client = clients.GetByUniqueID(uniqueid)
		local udp_port = tonumber(a)
		
		if not client:IsValid() then
			if network.debug then
				logf("invalid message: socket %s tried to send UDP_PORT packet with port number %s but the client is NULL\n", socket, udp_port)
			end
			socket:Remove()
			return
		end
		
		-- remove the client if the udp port is not a number
		if not udp_port then
			logn("client ", uniqueid ," gave invalid port: ", tostring(a))
			socket:Remove()
			client:Remove()
			return
		end
		
		if network.debug then
			logf("client %s sent udp port %i\n", client, udp_port)
		end
		
		-- store the udp port
		network.udp_accept[socket:GetIP() .. udp_port] = client
		socket.udp_port = udp_port		
		
		-- send all the nvars to this client
		nvars.Synchronize(client)
		
		network.SendMessageToClient(socket, network.CONNECTED, uniqueid)
		
	elseif CLIENT and stage == network.CONNECTED then
		local client = clients.Create(uniqueid) -- get or create
		
		clients.local_client = client
		clients.local_client.socket = network.tcp
		
		if network.debug then
			logn("successfully connected to server")
		end
		
		-- send all our nvars to the server
		nvars.Synchronize()
		
		network.SendMessageToServer(network.SYNCHRONIZED)
		
	elseif SERVER and stage == network.SYNCHRONIZED then
	
		local client = clients.GetByUniqueID(uniqueid)
					
		if not client:IsValid() then
			if network.debug then
				logf("invalid message: socket %s tried to send SYNCHRONIZED but the client is NULL\n", socket)
			end
			socket:Remove()
			return
		end
		
		event.Call("ClientSpawned", client)		
		
		-- send a message to everyone that we connected successfully
		network.BroadcastMessage(network.READY, uniqueid)
		
		-- tell the client about all the other clients and bots
		for _, client in pairs(clients.GetAll()) do
			network.SendMessageToClient(socket, network.READY, client:GetUniqueID())
		end
		
	elseif CLIENT and stage == network.READY then
		local client = clients.Create(uniqueid) -- get or create
		
		event.Call("ClientSpawned", client)
	end
	
	if stage == network.MESSAGE then
		if CLIENT then
			-- the arguments start after type.
			-- uniqueid is just consistently used by network.HandleMessage
			event.Call("NetworkMessageReceived", a, ...)
		end
		
		if SERVER then
			local client = clients.GetByUniqueID(uniqueid)
			
			if not client:IsValid() then
				if network.debug then
					logf("invalid message: socket %s tried to send MESSAGE packet but the client is not a valid client\n", socket, reason)
					logn(a, ...)
				end
				socket:Remove()
				return
			end
						
			event.Call("NetworkMessageReceived", client, a, ...)
		end
	elseif stage == network.DISCONNECT then	
		local client = clients.GetByUniqueID(uniqueid)
		local reason = tostring(a)
		
		if SERVER then
			if not client:IsValid() then
				if network.debug then
					logf("invalid message: socket %s tried to send DISCONNECT packet with reason %q but the client is not a valid client\n", socket, reason)
				end
				
				socket:Remove()
				
				return
			end
		
			event.Call("ClientLeft", client:GetName(), uniqueid, reason, client)
			event.BroadcastCall("ClientLeft", client:GetName(), uniqueid, reason)
			
			-- send the message back to other clients
			network.BroadcastMessage(stage, uniqueid, reason)
			
			-- maybe the client disconnected before UDP_PORT
			if socket.udp_port and socket:GetIP() then
				network.udp_accept[socket:GetIP() .. socket.udp_port] = nil
			end
			
			socket:Remove()
		end
		
		if network.debug then
			logf("%s disconnected (%s)\n", client, reason or "unknown reason")
		end
		
			
		-- we allow disconnect at any time 
		-- so we need to make sure everything is valid
		
		if client:IsValid() then
			client:Remove()
		end
	end
end

function network.HandlePacket(str, client)
	if CLIENT then
		event.Call("NetworkPacketReceived", str)
	elseif SERVER then
		event.Call("NetworkPacketReceived", client, str)
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
	console.SetTitle(("TCP in: %s"):format(network.tcp:GetStatistics().received), "network tcp in")
	console.SetTitle(("TCP out: %s"):format(network.tcp:GetStatistics().sent), "network tcp out")
	
	console.SetTitle(("UDP in: %s"):format(network.udp:GetStatistics().received), "network udp in")
	console.SetTitle(("UDP out: %s"):format(network.udp:GetStatistics().sent), "network udp out")
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
					if network.debug then
						logf("retrying %s:%s (%i retries left)..\n", ip, port, retries)
					end
					network.Connect(ip, port, retries - 1)
				end	
			end)
		end
		
		do -- udp
			local client = sockets.CreateClient("udp", ip, port, "network_client_udp")		
			client:SetTimeout(false)
			
			function client:OnReceive(str)
				network.HandlePacket(str, NULL)
			end
			
			network.udp = client	
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
				
		network.just_disconnected = nil
		
		return client
	end

	function network.Disconnect(reason)	
		reason = reason or "left"
		
		if network.IsConnected() then
			network.SendMessageToServer(network.DISCONNECT, reason)
			network.udp:Remove()
			network.tcp:Remove()
			
			logf("disconnected from server (%s)\n", reason or "unknown reason")
			network.just_disconnected = true
			network.started = false
			
			event.Call("Disconnected", reason)
			
			for _, client in pairs(clients.GetAll()) do
				print(client)
				client:Remove()
			end
		end
	end

	function network.IsConnected()
		if network.just_disconnected then	
			return false
		end
		return network.tcp:IsValid() and network.tcp:IsConnected()
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
				local client = network.udp_accept[ip .. port]
				if client and client.socket:GetIP() == ip then
					network.HandlePacket(str, client)
				end
				network.UpdateStatistics()
			end
			
			network.udp = server
		end
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
		-- fixme
		if not client:GetIP() then
			client:Remove()
			return
		end
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
	easylua.RunLua(clients.GetLocalClient(), line, nil, true)
end)

console.AddCommand("lua_open", function(line)
	easylua.Start(clients.GetLocalClient())
		include(line)
	easylua.End()
end)

console.AddServerCommand("lua_run_sv", function(client, line)
	logn(client:GetNick(), " ran ", line)
	easylua.RunLua(client, line, nil, true)
end)

console.AddServerCommand("lua_open_sv", function(client, line)
	logn(client:GetNick(), " opened ", line)
	easylua.Start(client)
		include(line)
	easylua.End()
end)


local default_ip = "*"
local default_port = 1234

if CLIENT then
	local ip_cvar = console.CreateVariable("cl_ip", default_ip)
	local port_cvar = console.CreateVariable("cl_port", default_port)
	
	local last_ip
	local last_port
	
	console.AddCommand("retry", function()
		if last_ip then
			network.Connect(last_ip, last_port)
		end
	end)
	
	console.AddCommand("connect", function(line, ip, port)		
		ip = ip or ip_cvar:Get()
		port = tonumber(port) or port_cvar:Get()
		
		logf("connecting to %s:%i\n", ip, port)
		
		last_ip = ip
		last_port = port
		
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

network.AddEncodeDecodeType("null", function(var, encode) 
	if encode then
		return 0
	else
		return NULL
	end
end)

return network