local enet = runfile("enet.lua")

if not enet then return end

local network = _G.network or {}

network.socket = network.socket or NULL

function network.Initialize()
	enet.Initialize()
end

function network.IsStarted()
	return network.socket:IsValid()
end

if CLIENT then
	function network.Connect(ip, port, retries)
		network.Disconnect("already connected")

		ip = tostring(ip)
		port = tonumber(port)

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

		local peer = enet.CreatePeer(ip, port)

		function peer:OnReceive(str, type)
			event.Call("PeerReceivePacket", str, nil, type)
		end

		network.socket = peer

		network.just_disconnected = nil

		event.Call("NetworkStarted")

		return peer
	end

	function network.Disconnect()
		if network.IsConnected() then

			network.socket:Disconnect(1)
			network.socket:Remove()

			llog("disconnected from server")

			network.just_disconnected = true
			network.started = false

			event.Call("Disconnected")
		end
	end

	event.AddListener("ShutDown", network.Disconnect)

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
		port = tonumber(port)

		network.port = port

		if network.IsHosting() then
			network.CloseServer("already hosting")
			event.Delay(1, function() network.Host(ip, port) end)
			return
		end

		if not enet then
			wlog("unable to host server: enet not found")
			return
		end

		local server = enet.CreateServer(ip, port)

		function server:OnReceive(peer, str, type)
			event.Call("PeerReceivePacket", str, peer, type)
		end

		function server:OnPeerConnect(peer)
			event.Call("PeerConnect", peer)
		end

		function server:OnPeerDisconnect(peer, code)
			event.Call("PeerDisconnect", peer, code)
		end

		network.socket = server

		event.Call("NetworkStarted")
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

	function network.BroadcastPacket(str)
		for _, peer in pairs(network.GetPeers()) do
			network.SendPacketToPeer(peer, str)
		end
	end
end

return network
