-- some of this was taken from (mainly reading and writing decimal numbers)
-- http://wowkits.googlecode.com/svn-history/r406/trunk/AddOns/AVR/ByteStream.lua
local META = prototype.CreateTemplate("generic_buffer")

function utility.CreateBuffer(val)
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

-- byte
function META:WriteByte(byte)
	list.insert(self.buffer, byte)
	return self
end

function META:ReadByte()
	local val = self.buffer[self.position]
	self.position = math.min(self.position + 1, #self.buffer)
	return val
end

-- this adds ReadLong, WriteShort, WriteFloat, WriteStructure, etc
runfile("lua/libraries/prototype/buffer_template.lua", META)

do -- generic
	function META:GetBuffer()
		return self.buffer
	end

	function META:GetSize()
		return #self.buffer
	end

	function META:TheEnd()
		return self:GetPosition() >= self:GetSize()
	end

	function META:Clear()
		list.clear(self.buffer)
		self.position = 0
	end

	function META:GetString()
		local temp = {}

		for _, v in ipairs(self.buffer) do
			temp[#temp + 1] = string.char(v)
		end

		return list.concat(temp)
	end

	function META:SetPosition(pos)
		self.position = math.clamp(pos, 1, self:GetSize())
		return self:GetPosition()
	end

	function META:GetPosition()
		return self.position
	end

	do -- push pop position
		function META:PushPosition(pos)
			self.stack = self.stack or {}
			list.insert(self.stack, self:GetPosition())
			self:SetPosition(pos)
		end

		function META:PopPosition()
			self:SetPosition(list.remove(self.stack))
		end
	end

	function META:Advance(i)
		i = i or 1
		self:SetPosition(self:GetPosition() + i)
	end

	META.__len = META.GetSize

	function META:GetDebugString()
		return self:GetString():readable_hex()
	end

	function META:AddHeader(buffer)
		for i, b in ipairs(buffer.buffer) do
			list.insert(self.buffer, i, b)
		end

		return self
	end
end

META:Register()