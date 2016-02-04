local network = _G.network or {}

network.socket = network.socket or NULL

local function ipport_to_uid(peer)
	return tostring(tonumber(ffi.cast("unsigned long *", peer.peer.data)[0]))
end

function network.HandlePacket(str, peer, type)
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
end

do -- string table
	if SERVER then
		local i = 0

		function network.AddString(str)

			if not network.IsStarted() then
				event.Delay(0.1, function() network.AddString(str) end)
				return
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

function network.UpdateStatistics()
	console.SetTitle(("NET in: %s"):format(network.socket:GetStatistics().received), "network udp in")
	console.SetTitle(("NET out: %s"):format(network.socket:GetStatistics().sent), "network udp out")
end

if CLIENT then
	local var = console.CreateVariable("connect_translate", "")

	function network.Connect(ip, port, retries)
		network.Disconnect("already connected")

		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")

		retries = retries or 3

		if retries > 0 then
			event.Delay(3, function()
				if not network.IsConnected() then
					if network.debug then
						llog("retrying %s:%s (%i retries left)..", ip, port, retries)
					end
					network.Connect(ip, port, retries - 1)
				end
			end)
		end

		if var:Get() ~= "" then
			local from, to = unpack(var:Get():explode(">"))
			if ip == from then
				ip = to
			end
		end

		if not enet then
			warning("unable to host connect: enet not found")
			return
		end

		local peer = enet.CreatePeer(ip, port)

		function peer:OnReceive(str, type)
			network.HandlePacket(str, nil, type)
		end

		network.socket = peer

		network.just_disconnected = nil

		event.Call("NetworkStarted")

		return peer
	end

	function network.Disconnect(reason)
		reason = reason or "left"

		if network.IsConnected() then
			network.socket:Disconnect(1)
			network.socket:Remove()

			llog("disconnected from server (%s)", reason or "unknown reason")
			network.just_disconnected = true
			network.started = false

			event.Call("Disconnected", reason)

			for _, client in pairs(clients.GetAll()) do
				client:Remove()
			end
		end
	end

	function network.IsConnected()
		if network.just_disconnected then
			return false
		end
		return network.socket:IsValid() and network.socket:IsConnected()
	end

	function network.SendPacketToHost(str, flags, channel)
		if network.socket:IsValid() then
			network.socket:Send(str, flags, channel)
		end
	end
end

if SERVER then
	function network.Host(ip, port)
		ip = tostring(ip)
		port = tonumber(port) or check(port, "number")

		network.port = port

		if network.IsHosting() then
			network.CloseServer("already hosting")
			event.Delay(1, function() network.Host(ip, port) end)
			return
		end

		if not enet then
			warning("unable to host server: enet not found")
			return
		end

		local server = enet.CreateServer(ip, port)

		function server:OnReceive(peer, str, type)
			network.HandlePacket(str, peer, type)
		end

		function server:OnPeerConnect(peer)
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

					for _, other in pairs(clients.GetAll()) do
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
		end

		function server:OnPeerDisconnect(peer)
			local uid = ipport_to_uid(peer)
			local client = clients.GetByUniqueID(uid)

			if client:IsValid() then
				event.CallShared("ClientLeft", client:GetName(), "unknown reason") -- todo: reason
				client:Remove()
			end
		end

		network.socket = server

		event.Call("NetworkStarted")

		network.JoinIRCServer()
	end

	function network.CloseServer(reason)
		llog("server shutdown (%s)", reason or "unknown reason")

		network.socket:Remove()
	end

	function network.IsHosting()
		return network.socket:IsValid()
	end

	function network.GetPeers()
		return network.socket:GetPeers()
	end

	function network.SendPacketToPeer(peer, str, flags, channel)
		if peer:IsValid() then
			peer:Send(str, flags, channel)
		end
	end

	function network.BroadcastPacket(str, flags, channel)
		for _, peer in pairs(network.GetPeers()) do
			network.SendPacketToPeer(peer, str)
		end
	end
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
			warning("sockets not availible")
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
			warning("irc client not available")
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

return network