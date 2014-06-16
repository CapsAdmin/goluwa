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
	buffer:SetPos(0)
	
	return id
end

if CLIENT then
	function packet.Send(id, buffer)
		local data = prepend_header(id, buffer)
		
		if data then
			network.SendPacketToServer(data)
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
	function packet.Send(id, buffer, filter)
		local data = prepend_header(id, buffer)
		
		if data then
			if typex(filter) == "client" then
				network.SendPacketToPeer(filter.socket, data)
			elseif typex(filter) == "client_filter" then
				for _, client in pairs(filter:GetAll()) do
					network.SendPacketToPeer(client.socket, data)
				end
			else
				for key, client in pairs(clients.GetAll()) do
					network.SendPacketToPeer(client.socket, data)
				end
			end
		end
	end
	
	function packet.Broadcast(id, buffer)
		return packet.Send(id, buffer)
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

	local META = metatable.CreateTemplate("buffer")

	function packet.CreateBuffer(val)
		local self = META:New()
		
		if type(val) == "string" or type(val) == "table" or not val then
			self.buffer = {}
			self.position = 0
			
			if type(val) == "table" then
				self:WriteStructure(val)
			elseif val then
				self:WriteBytes(val) 
			end
		elseif val.write and val.read and val.seek then
			val:setvbuf("no")
			val:seek("set")
			self.file = val
		end
		
		return self
	end
	
	-- byte
	function META:WriteByte(byte)
		if self.file then
			self.file:write(string.char(byte))
		else
			self.buffer[#self.buffer + 1] = byte
		end
		return self
	end

	function META:ReadByte()
		if self.file then
			local char = self.file:read(1)
			if char then
				return char:byte()
			end
		else
			self.position = math.min(self.position + 1, #self.buffer)
			return self.buffer[self.position]
		end
	end
	
	-- this adds ReadLong, WriteShort, WriteFloat, WriteStructure, etc
	metatable.AddBufferTemplate(META) 

	do -- generic
		function META:GetBuffer()
			if self.file then
				return self.file
			else	
				return self.buffer
			end
		end

		function META:GetSize()
			if self.file then 
				local old = self:GetPos()
				local size = self.file:seek("end")
				self:SetPos(old)
				return size
			else 
				return #self.buffer - 1
			end
		end
		
		function META:TheEnd()
			return self:GetPos() >= self:GetSize()
		end
		
		function META:Clear()
			if self.file then	
				error("not supported in file mode", 2)
			else
				table.clear(self.buffer)
				self.position = 0
			end
		end
		
		function META:GetString()
			if self.file then
				local old = self:GetPos()
				self.file:seek("set", 0)
				local str = self.file:read("*all")
				self:SetPos(old)
				return str
			else
				local temp = {}
				
				for k,v in ipairs(self.buffer) do
					temp[#temp + 1] = string.char(v)
				end
				
				return table.concat(temp)
			end
		end
		
		function META:SetPos(pos)
			if self.file then
				self.file:seek("set", pos)
			else
				self.position = math.clamp(pos, 0, self:GetSize())
			end
			
			return self:GetPos()
		end
		
		function META:GetPos()
			if self.file then
				return self.file:seek()
			else
				return self.position - 1
			end
		end

		function META:Advance(i)
			i = i or 1
			self:SetPos(self:GetPos() + i) 
		end
		
		META.__len = META.Length
		
		function META:GetDebugString()
			return self:GetString():readablehex()
		end
		
		function META:AddHeader(buffer)
			if self.file then
				error("not supported in file mode", 2)
			else
				for i, b in ipairs(buffer.buffer) do
					table.insert(self.buffer, i, b)
				end 
			end
			return self
		end
	end
end

_G.Buffer = packet.CreateBuffer

return packet