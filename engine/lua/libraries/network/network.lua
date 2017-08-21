local network = _G.network or {}

network.socket = network.socket or NULL

local ffi = require("ffi")

local function ipport_to_uid(peer)
	return tostring(tonumber(ffi.cast("unsigned long *", peer.peer.data)[0]))
end

event.AddListener("PeerReceivePacket", "network", function(str, peer, type)
	local client = NULL

	if peer then
		local uid = ipport_to_uid(peer)
		client = clients.GetByUniqueID(uid)
	end

	if network.debug == 2 then
		llog("received %s packet (%s) from %s", type, utility.FormatFileSize(#str), peer)
	end

	if SERVER and not client:IsValid() then
		error("client is NULL")
	end

	event.Call("NetworkPacketReceived", str, client, type)
end)

if SERVER then

	event.AddListener("PeerDisconnect", "network", function(peer)
		local uid = ipport_to_uid(peer)
		local client = clients.GetByUniqueID(uid)

		if client:IsValid() then
			client:Disconnect("unknown reason") -- todo: reason
			client:Remove()
		end
	end)

	event.AddListener("PeerConnect", "network", function(peer)
		local uid = ipport_to_uid(peer)
		local client = clients.Create(uid, false, false) -- create the client serverside for now

		client.socket = peer

		if network.debug then
			llog("client %s connected", client)
		end

		if event.Call("ClientConnect", client) ~= false then
			nvars.Synchronize(client, function(client)

				if network.debug then
					llog("client %s done synchronizing nvars", client)
				end

				event.Call("ClientEntered", client)

				for _, other in ipairs(clients.GetAll()) do
					if other ~= client then
						-- tell all the other clients that our client spawned
						clients.Create(other:GetUniqueID(), other:IsBot(), true, client)

						-- tell our client about all the other clients
						clients.Create(uid, false, true, other)
					end
				end

				-- tell our client that it spawned
				clients.Create(uid, false, true, client, true)
			end)
		end
	end)
end

do -- string table
	if SERVER then
		local i = 0

		function network.AddString(str)

			if not network.IsStarted() then
				event.Delay(0.1, function() network.AddString(str) end)
				return 0
			end

			-- this is mainly used by the messsage which uses the packet library internally
			-- which in turn needs network.AddString
			-- -1 is reserved for the message library
			if type(str) == "number" then
				return str
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
		if type(str) == "number" then return str end
		return nvars.Get(str, nil, "string_table1")
	end

	function network.IDToString(id)
		if id < 0 then return id end
		return nvars.Get(id, nil, "string_table2")
	end
end

function network.IsStarted()
	return network.socket:IsValid()
end

do
	network.irc_client = network.irc_client or NULL
	network.available_servers = network.available_servers or {}
	network.server = "chat.freenode.net"
	network.channel = "#goluwa"

	function network.SetHostName(str)
		nvars.Set("hostname", str)
	end

	function network.GetHostname()
		return nvars.Get("hostname", e.USERNAME .. "'s server")
	end

	function network.GetAvailableServers()
		return network.available_servers
	end

	function network.JoinIRCServer()
		if not SOCKETS then
			wlog("sockets not availible")
			return
		end
		if not network.irc_client:IsValid() then
			local client = sockets.CreateIRCClient()

			if SERVER then
				client:SetNick(client:GetNick() .. "_server")

				client.OnPrivateMessage = network.OnIRCMessage

				client.OnReady = function() logn("successfully joined irc channel") end
			end

			if CLIENT then
				client:SetNick(client:GetNick() .. "_client")
				client.OnPrivateMessage = network.OnIRCMessage
				client.OnJoin = function(s, nick)
					if nick:endswith("_server") then
						client.asked[nick] = true
						client:PRIVMSG(nick .. " info")
					end
				end
				client.OnPart = function(s, nick, ip)
					if nick:endswith("_server") then
						network.available_servers[ip] = nil
					end
				end
				client.OnReady = function() logn("successfully joined irc channel") network.QueryAvailableServers() end
			end

			client:Connect(network.server)
			client:Join(network.channel)

			llog("joining %s:%s", network.server, network.channel)

			network.irc_client = client
		end
	end

	function network.QueryAvailableServers()
		network.available_servers = {}

		local irc_client = network.irc_client

		if not irc_client:IsValid() then
			wlog("irc client not available")
			return
		end

		logn("fetching public servers...")

		irc_client.asked = {}

		for user in pairs(network.irc_client:GetUsers()) do
			if user:endswith("_server") then
				irc_client.asked[user] = true
				irc_client:PRIVMSG(user .. " info")
			end
		end
	end

	function network.OnIRCMessage(irc_client, message, nick, ip)
		if CLIENT then
			if irc_client.asked[nick] then
				local info = serializer.Decode("msgpack", message)
				info.ip = ip
				network.available_servers[ip] = info
				event.Call("PublicServerFound", info)
			end
		end

		if SERVER then
			if message == "info" then
				irc_client:PRIVMSG(nick .. " :" .. serializer.Encode("msgpack", {name = network.GetHostname(), port = network.port}))
			end
		end
	end
end

do
	local default_ip = "*"
	local default_port = 1234

	if CLIENT then
		local ip_cvar = pvars.Setup("cl_ip", default_ip)
		local port_cvar = pvars.Setup("cl_port", default_port)

		local last_ip
		local last_port

		commands.Add("retry", function()
			if last_ip then
				network.Connect(last_ip, last_port)
			end
		end)

		commands.Add("connect=string|nil,number|nil", function(ip, port)
			ip = ip or ip_cvar:Get()
			port = tonumber(port) or port_cvar:Get()

			logf("connecting to %s:%i\n", ip, port)

			last_ip = ip
			last_port = port

			network.Connect(ip, port)
		end)

		commands.Add("disconnect=arg_line", function(line)
			network.Disconnect(line)
		end)
	end

	if SERVER then
		local ip_cvar = pvars.Setup("sv_ip", default_ip)
		local port_cvar = pvars.Setup("sv_port", default_port)

		commands.Add("host=string|nil,number|nil", function(ip, port)
			ip = ip or ip_cvar:Get()
			port = tonumber(port) or port_cvar:Get()

			logf("hosting at %s:%i\n", ip, port)

			network.Host(ip, port)
		end)
	end
end

return network
