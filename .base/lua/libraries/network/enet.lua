local lib = require("lj-enet")

local enet = {}

enet.sockets = {}

local translate_packet_flag = {
	reliable = lib.e.ENET_PACKET_FLAG_RELIABLE,
	unsequenced = lib.e.ENET_PACKET_FLAG_UNSEQUENCED,
	unreliable = 0,
}

local function ipport2address(ip, port)
	if not ip or not port then return nil end
	local address = ffi.new("ENetAddress[1]")

	lib.address_set_host(address, ip)
	address[0].port = port
	
	return address
end

local function create_host(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
	max_connections = max_connections or 32
	max_channels = max_channels or 32
	incomming_bandwidth = incomming_bandwidth or 0
	outgoing_bandwidth = outgoing_bandwidth or 0
			
	local host = lib.host_create(ipport2address(ip, port), max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
	
	return host
end

do -- peer
	local CLIENT = metatable.CreateTemplate("enet_peer")
	
	function CLIENT:Connect(ip, port, channels)
		channels = channels or 1
		check(ip, "string")
		check(port, "number")
		
		self.peer = lib.host_connect(self.host, ipport2address(ip, port), channels, 0)
	end
	
	function CLIENT:Disconnect(why)
		why = why or 0
		lib.peer_disconnect(self.peer, why)
		
		local evt = ffi.new("ENetEvent[1]")
		while lib.host_service(self.host, evt, 3000) > 0 do
			if evt[0].type == lib.e.ENET_EVENT_TYPE_DISCONNECT then
				return true
			elseif evt[0].type == lib.e.ENET_EVENT_TYPE_RECEIVE then
				lib.packet_destroy(evt[0].packet)
			end
		end
		
		lib.peer_reset(self.peer)
	end
	
	function CLIENT:Send(str, type, channel)
		type = translate_packet_flag[type] or 0
		channel = channel or 0
		
		local packet = lib.packet_create(str, #str, type)
		lib.peer_send(self.peer, channel, packet)
	end
	
	function CLIENT:OnConnect()

	end
	
	function CLIENT:OnDisconnect()
	
	end
	
	function CLIENT:OnReceive(str, type)
		
	end
	
	function CLIENT:GetIP()
		return self.peer.address.host
	end
	
	function CLIENT:GetPort()
		return self.peer.address.port
	end
	
	function CLIENT:IsConnected()
		return self.connected
	end
		
	function CLIENT:OnRemove()
		for i, socket in ipairs(enet.sockets) do
			if socket == self then
				table.remove(enet.sockets, i)
				break
			end
		end
	end

	function enet.CreatePeer(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)		
		local self = CLIENT:New()
		
		max_connections = max_connections or 2
		max_channels = max_channels or 2
		incomming_bandwidth = incomming_bandwidth or 57600
		outgoing_bandwidth = outgoing_bandwidth or 14400
		
		self.host = create_host(nil, nil, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
		self.peer = peer
		
		table.insert(enet.sockets, self)
		
		if ip and port then
			self:Connect(ip, port)
		end
		
		return self
	end
	
	function enet.CreateDummyPeer()
		return CLIENT:New()
	end
end

do -- server
	local SERVER = metatable.CreateTemplate("enet_server")
	
	SERVER.peers = {}
	
	function SERVER:GetPeers()
		return self.peers
	end
	
	function SERVER:Broadcast(str, typ, channel)
		type = translate_packet_flag[type] or 0
		channel = channel or 0
		
		local packet = lib.packet_create(str, #str, type)
		lib.host_broadcast(self.host, channel, packet)
	end
	
	function SERVER:OnReceive(peer, str, type)
	
	end
	
	function SERVER:OnPeerConnect(peer)
	
	end
	
	function SERVER:OnPeerDisconnect(peer)
		
	end
	
	function SERVER:OnRemove()
		for i, socket in ipairs(enet.sockets) do
			if socket == self then
				table.remove(enet.sockets, i)
				break
			end
		end
	end
	
	function enet.CreateServer(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)		
		local self = SERVER:New()
		
		self.host = create_host(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
		self.peer = peer
		
		table.insert(enet.sockets, self)
		
		return self
	end
end

local evt = ffi.new("ENetEvent[1]")

local unique_id = 0

local function getuid(peer)
	return tonumber(ffi.cast("unsigned long", peer.data))
end

event.AddListener("Update", "enet", function()
	for i, socket in ipairs(enet.sockets) do
		if lib.host_service(socket.host, evt, 0) > 0 then
			if evt[0].type == lib.e.ENET_EVENT_TYPE_CONNECT then
				if socket.Type == "enet_peer" then
					socket:OnConnect()
					socket.connected = true
					if enet.debug then logf("[enet] %s: connected to server\n", socket, peer) end
				else
					local peer = enet.CreateDummyPeer()
					peer.peer = evt[0].peer
					peer.peer.data = ffi.cast("void *", unique_id)
					unique_id = unique_id + 1
					socket.peers[getuid(peer.peer)] = peer
					socket:OnPeerConnect(peer)
					peer:OnConnect()
					peer.connected = true
					if enet.debug then logf("[enet] %s: %s connected\n", socket, peer) end
				end
			elseif evt[0].type == lib.e.ENET_EVENT_TYPE_DISCONNECT then
				if socket.Type == "enet_peer" then
					socket:OnDisconnect()
					socket.connected = false
					if enet.debug then logf("[enet] %s: disconnected from server\n", socket, peer) end
				else
					local peer = socket.peers[getuid(evt[0].peer)]
					socket:OnPeerDisconnect(peer)
					peer:OnDisconnect()
					peer.connected = false
					socket.peers[getuid(peer.peer)] = nil
					if enet.debug then logf("[enet] %s: %s disconnected\n", socket, peer) end
				end
			elseif evt[0].type == lib.e.ENET_EVENT_TYPE_RECEIVE then
				
				local str, flags, channel = ffi.string(evt[0].packet.data, evt[0].packet.dataLength), evt[0].packet.flags, evt[0].channelID
				flags = translate_packet_flag[flags] or flags
			
				if socket.Type == "enet_peer" then
					if enet.debug then logf("[enet] %s: received %s of data: %s\n", socket, utilities.FormatFileSize(#str), str:dumphex()) end
					socket:OnReceive(str, flags, channel)
				else
					local peer = socket.peers[getuid(evt[0].peer)]
					if enet.debug then logf("[enet] %s: received %s of data from %s: %s\n", socket, utilities.FormatFileSize(#str), peer, str:dumphex()) end
					socket:OnReceive(peer, str, flags, channel)
				end
			end
		end
	end
end)

return enet 