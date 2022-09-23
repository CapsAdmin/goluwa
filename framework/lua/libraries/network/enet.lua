local ffi = require("ffi")
local lib = desire("enet")

if not lib then return end

local enet = _G.enet or {}

function enet.Initialize()
	return lib.Initialize()
end

enet.sockets = enet.sockets or table.weak()
local valid_flags = {
	default_valid_flag = 0,
	unreliable = 0,
	reliable = lib.e.PACKET_FLAG_RELIABLE,
	unsequenced = lib.e.PACKET_FLAG_UNSEQUENCED,
	unreliable_fragment = lib.e.PACKET_FLAG_UNRELIABLE_FRAGMENT,
	sent = lib.e.PACKET_FLAG_SENT,
}

local function ipport2address(ip, port)
	if not ip or not port then return nil end

	local address = ffi.new("struct _ENetAddress[1]")
	lib.AddressSetHost(address, ip)
	address[0].port = port
	return address
end

local function create_host(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
	max_connections = max_connections or 32
	max_channels = max_channels or 8
	incomming_bandwidth = incomming_bandwidth or 0
	outgoing_bandwidth = outgoing_bandwidth or 0
	local host = lib.HostCreate(
		ipport2address(ip, port),
		max_connections,
		max_channels,
		incomming_bandwidth,
		outgoing_bandwidth
	)

	if host == nil then
		print(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
		error("host is NULL")
	end

	--[[
	local cb = ffi.cast(host.intercept, function(host, event)
		jit.off(true, true)
		print(host, event)
		return 0
	end)
	host.intercept = cb
	]] return host
end

do -- peer
	local CLIENT = prototype.CreateTemplate("enet_peer")

	function CLIENT:Connect(ip, port, channels)
		channels = channels or 1
		self.peer = lib.HostConnect(self.host, ipport2address(ip, port), channels, 0)
	end

	function CLIENT:Disconnect(code)
		code = code or 0
		lib.PeerDisconnect(self.peer, code)

		if self.host then
			local evt = ffi.new("struct _ENetEvent[1]")

			while lib.HostService(self.host, evt, 3000) > 0 do
				if evt[0].type == lib.e.EVENT_TYPE_DISCONNECT then
					return true
				elseif evt[0].type == lib.e.EVENT_TYPE_RECEIVE then
					lib.PacketDestroy(evt[0].packet)
				end
			end
		end

		lib.PeerReset(self.peer)
	end

	function CLIENT:Send(str, flags, channel)
		flags = utility.TableToFlags(flags, valid_flags)
		channel = channel or 0
		local packet = lib.PacketCreate(str, #str, flags)
		lib.PeerSend(self.peer, channel, packet)
	end

	function CLIENT:OnConnect() end

	function CLIENT:OnDisconnect() end

	function CLIENT:OnReceive(str, type) end

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
				list.remove(enet.sockets, i)

				break
			end
		end
	end

	function enet.CreatePeer(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
		local self = prototype.CreateObject(CLIENT)
		max_connections = max_connections or 8
		max_channels = max_channels or 8
		incomming_bandwidth = incomming_bandwidth or 57600
		outgoing_bandwidth = outgoing_bandwidth or 14400
		self.host = create_host(nil, nil, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
		--self.peer = peer
		list.insert(enet.sockets, self)

		if ip and port then self:Connect(ip, port) end

		return self
	end

	function enet.CreateDummyPeer()
		return prototype.CreateObject(CLIENT)
	end

	prototype.Register(CLIENT)
end

do -- server
	local SERVER = prototype.CreateTemplate("enet_server")

	function SERVER:GetPeers()
		return self.peers
	end

	function SERVER:Broadcast(str, flags, channel)
		flags = utility.TableToFlags(flags, valid_flags)
		channel = channel or 0
		local packet = lib.PacketCreate(str, #str, flags)
		lib.HostBroadcast(self.host, channel, packet)
	end

	function SERVER:OnReceive(peer, str, flags, channel) end

	function SERVER:OnPeerConnect(peer) end

	function SERVER:OnPeerDisconnect(peer) end

	function SERVER:OnRemove()
		for i, socket in ipairs(enet.sockets) do
			if socket == self then
				list.remove(enet.sockets, i)

				break
			end
		end
	end

	function enet.CreateServer(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
		local self = prototype.CreateObject(SERVER)
		self.peers = {}
		self.host = create_host(ip, port, max_connections, max_channels, incomming_bandwidth, outgoing_bandwidth)
		list.insert(enet.sockets, self)
		return self
	end

	prototype.Register(SERVER)
end

local evt = ffi.new("struct _ENetEvent[1]")
enet.uid_ref = enet.uid_ref or {}
local unique_id = 0

local function getuid(peer)
	return tonumber(ffi.cast("unsigned long *", peer.data)[0])
end

timer.Repeat(
	"enet",
	1 / 30,
	0,
	function()
		for _, socket in ipairs(enet.sockets) do
			while lib.HostService(socket.host, evt, 0) > 0 do
				if evt[0].type == lib.e.EVENT_TYPE_CONNECT then
					if socket.Type == "enet_peer" then
						socket:OnConnect()
						socket.connected = true

						if enet.debug then llog("%s: connected to server", socket) end
					else
						local peer = enet.CreateDummyPeer()
						peer.peer = evt[0].peer
						local uid = ffi.new("unsigned long[1]", unique_id)
						list.insert(enet.uid_ref, uid)
						peer.peer.data = uid
						unique_id = unique_id + 1
						socket.peers[getuid(peer.peer)] = peer
						socket:OnPeerConnect(peer)
						peer:OnConnect()
						peer.connected = true

						if enet.debug then llog("%s: %s connected", socket, peer) end
					end
				elseif evt[0].type == lib.e.EVENT_TYPE_DISCONNECT then
					if socket.Type == "enet_peer" then
						socket:OnDisconnect()
						socket.connected = false

						if enet.debug then llog("%s: disconnected from server", socket) end
					else
						local peer = socket.peers[getuid(evt[0].peer)]
						socket:OnPeerDisconnect(peer, evt[0].data)
						peer:OnDisconnect()
						peer.connected = false
						socket.peers[getuid(peer.peer)] = nil

						if enet.debug then llog("%s: %s disconnected", socket, peer) end
					end
				elseif evt[0].type == lib.e.EVENT_TYPE_RECEIVE then
					local str, flags, channel = ffi.string(evt[0].packet.data, evt[0].packet.dataLength),
					evt[0].packet.flags,
					evt[0].channelID
					flags = utility.FlagsToTable(flags, valid_flags)

					if socket.Type == "enet_peer" then
						if enet.debug then
							llog(
								"%s: received %s of data: %s",
								socket,
								utility.FormatFileSize(#str),
								str:hex_format()
							)
						end

						socket:OnReceive(str, flags, channel)
					else
						local peer = socket.peers[getuid(evt[0].peer)]

						if enet.debug then
							llog(
								"%s: received %s of data from %s: %s",
								socket,
								utility.FormatFileSize(#str),
								peer,
								str:hex_format()
							)
						end

						socket:OnReceive(peer, str, flags, channel)
					end
				end
			end
		end
	end
)

return enet