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
		logf("received %s packet (%s) from %s\n", type, utility.FormatFileSize(#str), peer)
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
			
			logf("disconnected from server (%s)\n", reason or "unknown reason")
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
		
		if network.IsHosting() then
			network.CloseServer("already hosting")
			event.Delay(1, function() network.Host(ip, port) end)
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
				logf("client %s connected\n", client)
			end
			
			if event.Call("ClientConnect", client) ~= false then
				nvars.Synchronize(client, function(client)
					
					if network.debug then
						logf("client %s done synchronizing nvars\n", client)
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
	end
	
	function network.CloseServer(reason)		
		logf("server shutdown (%s)\n", reason or "unknown reason")
		
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

return network