local packet = _G.packet or {}

packet.listeners = packet.listeners or {}

function packet.AddListener(id, callback)

	if SERVER then
		network.AddString(id)
	end

	packet.listeners[id] = callback
end

function packet.RemoveListener(id)
	packet.listeners[id] = nil
end

local function prepend_header(id, buffer)
	if CLIENT then
		id = network.StringToID(id)
	end

	if SERVER then
		id = network.AddString(id)
	end

	if not id then return end

	return buffer:AddHeader(packet.CreateBuffer():WriteShort(id)):GetString()
end

local function read_header(buffer)
	local id = buffer:ReadShort()
	id = network.IDToString(id)

	table.remove(buffer.buffer, 1)
	table.remove(buffer.buffer, 1)
	buffer:SetPosition(0)

	return id
end

if CLIENT then
	function packet.Send(id, buffer, flags, channel)
		flags = flags or "unsequenced"
		local data = prepend_header(id, buffer)

		if data then
			network.SendPacketToHost(data, flags, channel)
		end
	end

	function packet.OnPacketReceived(str)
		local buffer = packet.CreateBuffer(str)
		local id = read_header(buffer)

		if packet.listeners[id] then
			packet.listeners[id](buffer)
		end
	end

	event.AddListener("NetworkPacketReceived", "packet", packet.OnPacketReceived, {on_error = system.OnError})
end

if SERVER then
	function packet.Send(id, buffer, filter, flags, channel)
		flags = flags or "unsequenced"
		local data = prepend_header(id, buffer)

		if data then
			if typex(filter) == "client" then
				network.SendPacketToPeer(filter.socket, data, flags, channel)
			elseif typex(filter) == "client_filter" then
				for _, client in pairs(filter:GetAll()) do
					network.SendPacketToPeer(client.socket, data, flags, channel)
				end
			else
				for _, client in ipairs(clients.GetAll()) do
					network.SendPacketToPeer(client.socket, data, flags, channel)
				end
			end
		end
	end

	function packet.Broadcast(id, buffer, flags, channel)
		return packet.Send(id, buffer, flags, channel)
	end

	function packet.OnPacketReceived(str, client)
		local buffer = packet.CreateBuffer(str)
		local id = read_header(buffer)

		if packet.listeners[id] then
			packet.listeners[id](buffer, client)
		end
	end

	event.AddListener("NetworkPacketReceived", "packet", packet.OnPacketReceived, {on_error = system.OnError})
end

do -- buffer object
	-- some of this was taken from (mainly reading and writing decimal numbers)
	-- http://wowkits.googlecode.com/svn-history/r406/trunk/AddOns/AVR/ByteStream.lua

	local META = table.copy(prototype.GetRegistered("generic_buffer"))
	META.ClassName = "packet_buffer"

	function packet.CreateBuffer(val)
		local self = META:CreateObject()

		if type(val) == "string" or type(val) == "table" or not val then
			self.buffer = {}
			self.position = 1

			if type(val) == "table" then
				self:WriteStructure(val)
			elseif val then
				self:WriteBytes(val)
			end
		end

		return self
	end

	-- this must be done shared or else you'll mess up Write/ReadType on the other side
	function packet.ExtendBuffer(name, write_callback, read_callback)
		META["Read" .. name] = read_callback
		META["Write" .. name] = write_callback

		META:GenerateTypes()
	end

	function META:WriteNetString(str)
		self:WriteShort(network.AddString(str))
	end

	function META:ReadNetString()
		return network.IDToString(self:ReadShort())
	end

	prototype.Register(META)
end

_G.Buffer = packet.CreateBuffer

return packet
