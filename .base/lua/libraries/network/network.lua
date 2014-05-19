local network = _G.network or {}

network.client_tcp = network.client_tcp or NULL
network.server_tcp = network.server_tcp or NULL

network.client_udp = network.client_udp or NULL
network.server_udp = network.server_udp or NULL

network.CONNECT = 1
network.DISCONNECT = 2
network.ACCEPT = 3
network.MESSAGE = 4

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

function network.HandleTCPMessage(socket, type, a, b, ...)		
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
					logf("player %s removed because OnPlayerConnect returned false\n", player)
				end
				player:Remove()
			end
				
			-- this should be done after the player is created
			
			nvars.FullUpdate(player)
			
			logf("%s connected\n", socket:GetIPPort())
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
			logf("successfully connected to server\n")
			
			players.local_player = Player(uniqueid)
			players.local_player.socket = network.client_tcp
						
			event.Call("OnlineStarted")
		end
	elseif type == network.DISCONNECT then

		if SERVER then
			local player = Player(uniqueid)
			local reason = a
						
			event.Call("PlayerLeft", player:GetName(), uniqueid, reason, player)
			event.BroadcastCall("PlayerLeft", player:GetName(), uniqueid, reason)
			
			logf("%s disconnected (%s)\n", socket:GetIPPort(), reason or "unknown reason")
						
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

function network.HandleUDPMessage(str, ip, port)
	print(ip, port, str)
end

function network.IsStarted()
	return network.server_tcp:IsValid() or network.client_tcp:IsValid()
end

if CLIENT then
	function network.Connect(ip, port, retries)
		network.Disconnect("already connected")
		
		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")
		
		retries = retries or 3
		
		if retries > 0 then
			timer.Delay(3, function()
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
					network.HandleTCPMessage(nil, decode(message))
					found = found + 1
				end
				
				if found > 0 then
					temp = temp:match("^.+"..delimiter.."(.*)$") or ""
				end
			end
		
			network.client_tcp = client
		end
		
		do -- udp
			local client = sockets.CreateClient("udp", ip, port, "network_client_udp")		
			client:SetTimeout(false)
			
			function client:OnReceive(str)
				network.HandleUDPMessage(str)
			end
			
			network.client_udp = client	
		end
		
		network.just_disconnected = nil
		
		return client
	end

	function network.Disconnect(reason)	
		reason = reason or "left"
		
		if network.IsConnected() then
			network.SendToServer(network.DISCONNECT, reason)
			network.client_tcp:Remove()
			
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
		return network.client_tcp:IsValid() and network.client_tcp:IsConnected() and network.accepted or false
	end
	
	function network.SendToServer(event, ...)	
		if network.client_tcp:IsValid() then
			network.client_tcp:Send(encode(event, ...), buffered)
		end
	end
end

if SERVER then
	function network.Host(ip, port)	
		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")
		
		do -- tcp
			local server = sockets.CreateServer("tcp", ip, port, "network_server_tcp")
			
			function server:OnClientConnected(client, ip, port)
				client:SetReceiveMode(receive_mode)			
				network.HandleTCPMessage(client, network.CONNECT)
				return true
			end
			
			function server:OnReceive(str, client)
				client.temp = client.temp or ""
				client.temp = client.temp .. str
				
				local found = 0
				
				for message in client.temp:gmatch("(.-)" .. delimiter) do
					if network.HandleTCPMessage(client, decode(message)) == false then
						client:Remove()
					end
					found = found + 1
				end
				
				if found > 0 then
					client.temp = client.temp:match("^.+"..delimiter.."(.*)$") or ""
				end
			end

			network.server_tcp = server
		end
		
		do -- udp
			local server = sockets.CreateServer("udp", ip, port, "network_server_udp")
			
			-- receive "str, ip, port" instead of "str, client"
			server:UseDummyClient(false)
			
			function server:OnReceive(str, ip, port)
				network.HandleUDPMessage(str, ip, port)
			end
			
			network.server_udp = server
		end
		
		event.Call("OnlineStarted")
	end
	
	function network.GetClients()
		return network.server_tcp:GetClients()
	end
		
	function network.SendToClient(client, event, ...)
		if not client:IsValid() then return end
		client:Send(encode(event, ...), buffered)
	end
	
	function network.Broadcast(event, ...)		
		for _, client in pairs(network.GetClients()) do
			network.SendToClient(client, event, ...)
		end
	end
end

-- this is for when server or client is initialized (needs to handle SERVER and CLIENT globals)
function network.ReInclude()
	include("libraries/network/network.lua")
	include("libraries/network/message.lua")
	include("libraries/network/easylua.lua")
	include("libraries/network/nvars.lua")
	include("libraries/network/players.lua")
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
	addons.AutorunAll("client")

	local ip_cvar = console.CreateVariable("cl_ip", default_ip)
	local port_cvar = console.CreateVariable("cl_port", default_port)
	
	--logf("connecting to %s %i\n", ip_cvar:Get(), port_cvar:Get())
	--network.Connect(ip_cvar:Get(), port_cvar:Get())
	
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
	addons.AutorunAll("server")

	local ip_cvar = console.CreateVariable("sv_ip", default_ip)
	local port_cvar = console.CreateVariable("sv_port", default_port)
	
	--logf("hosting server at %s %i\n", ip_cvar:Get(), port_cvar:Get())
	--network.Host(ip_cvar:Get(), port_cvar:Get())
		
	console.AddCommand("host", function(line, ip, port)
		ip = ip or ip_cvar:Get()
		port = tonumber(port) or port_cvar:Get()
		
		logf("hosting at %s:%i\n", ip, port)
		
		network.Host(ip, port)
	end)
end

console.AddCommand("start_server", function()
	_G.SERVER = true
	addons.Reload()
	network.ReInclude()	
	entities.LoadAllEntities()
end)

console.AddCommand("start_client", function()
	_G.CLIENT = true
	addons.Reload()
	network.ReInclude()
	entities.LoadAllEntities()
end)

return network