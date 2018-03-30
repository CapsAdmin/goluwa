local network = _G.network or {}

network.socket = network.socket or NULL

local ffi = desire("ffi")
local ipport_to_uid

if ffi then
	function ipport_to_uid(peer)
		return tostring(tonumber(ffi.cast("unsigned long *", peer.peer.data)[0]))
	end
else
	function ipport_to_uid(peer)
		return tostring(peer)
	end
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


-- TODO
function network.PingServer(ip, cb)
	local lol = io.popen("ping " .. ip .. (WINDOWS and "-n 1" or " -c 1"))

	event.Thinker(function()
		local str = lol:read("*all")
		local time = str:match("time=(%S+)")
		cb(tonumber(time) / 100)
		if not c then return false end
	end)
end

if SERVER then

	event.AddListener("PeerDisconnect", "network", function(peer, code)
		local uid = ipport_to_uid(peer)
		local client = clients.GetByUniqueID(uid)

		if client:IsValid() then
			client:Disconnect(code)
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

				for _, other in ipairs(clients.GetAll()) do
					if other ~= client then
						-- tell this client about all the clients on the server
						clients.Create(other:GetUniqueID(), other:IsBot(), true, client, false, true)

						-- tell all the other clients that this client entered
						clients.Create(client:GetUniqueID(), client:IsBot(), true, other, false, false)
					end
				end

				-- tell this client that we entered
				clients.Create(client:GetUniqueID(), client:IsBot(), true, client, true, false)

				event.Call("ClientEntered", client)
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

	network.serverbrowser_hostname = "chat.freenode.net"
	network.serverbrowser_channel = "#goluwa"
	network.serverbrowser_port = 6667

	function network.SetHostName(str)
		nvars.Set("hostname", str)
	end

	function network.GetHostname()
		return nvars.Get("hostname", e.USERNAME .. "'s server")
	end

	function network.GetAvailableServers()
		return network.available_servers
	end

	function network.JoinIRCServer(cb)
		if not SOCKETS then
			wlog("sockets not availible")
			return
		end

		if network.irc_client:IsValid() then
			if CLIENT then
				network.QueryAvailableServers(cb)
			end
			return
		end

		local client = sockets.CreateIRCClient()

		if SERVER then
			sockets.Download("https://api.ipify.org/?format=plaintext", function(s)
				network.public_ip = s
				llog("public ip is %s", s)
			end)

			client:SetNick(client:GetNick() .. "_server")

			client.OnPrivateMessage = network.OnIRCMessage

			client.OnReady = function()
				logn("successfully joined irc channel")
				if cb then cb() end
			end
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
			client.OnReady = function()
				logn("successfully joined irc channel")
				network.QueryAvailableServers(cb)
			end
		end

		client:Connect(network.serverbrowser_hostname)
		client:Join(network.serverbrowser_channel, network.serverbrowser_port)

		llog("joining %s:%s", network.serverbrowser_hostname, network.serverbrowser_channel)

		network.irc_client = client
	end

	function network.QueryAvailableServers(cb)
		network.available_servers = {}

		local irc_client = network.irc_client

		if not irc_client:IsValid() then
			wlog("irc client not available")
			return
		end

		logn("fetching public servers...")

		irc_client.asked = {}

		local found = 0

		for user in pairs(network.irc_client:GetUsers()) do
			if user:endswith("_server") then
				irc_client.asked[user] = true
				irc_client:PRIVMSG(user .. " info")
				found = found + 1
			end
		end

		if cb then cb(found) end
	end

	function network.OnIRCMessage(irc_client, message, nick, ip)
		if CLIENT then
			if irc_client.asked[nick] then
				local info = serializer.Decode("msgpack", message)
				info.masked_ip = ip
				network.available_servers[ip] = info
				network.PingServer(info.ip, function(sec)
					info.latency = sec
					event.Call("PublicServerFound", info)
				end)
			end
		end

		if SERVER then
			if message == "info" then
				local players = {}
				for i, ply in ipairs(clients.GetAll()) do
					players[i] = ply:GetNick()
				end
				irc_client:PRIVMSG(nick .. " :" .. serializer.Encode("msgpack", {
					name = network.GetHostname(),
					port = network.port,
					players = players,
					scene_name = "none",
					ip = network.public_ip,
				}))
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

		commands.Add("disconnect", function()
			network.Disconnect()
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
