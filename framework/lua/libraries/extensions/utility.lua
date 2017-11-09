do
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
		table.insert(self.buffer, byte)
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
			table.clear(self.buffer)
			self.position = 0
		end

		function META:GetString()
			local temp = {}

			for _, v in ipairs(self.buffer) do
				temp[#temp + 1] = string.char(v)
			end

			return table.concat(temp)
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

				table.insert(self.stack, self:GetPosition())

				self:SetPosition(pos)
			end

			function META:PopPosition()
				self:SetPosition(table.remove(self.stack))
			end
		end

		function META:Advance(i)
			i = i or 1
			self:SetPosition(self:GetPosition() + i)
		end

		META.__len = META.GetSize

		function META:GetDebugString()
			return self:GetString():readablehex()
		end

		function META:AddHeader(buffer)
			for i, b in ipairs(buffer.buffer) do
				table.insert(self.buffer, i, b)
			end
			return self
		end
	end

	META:Register()
end

do -- tree
	local META = prototype.CreateTemplate("tree")

	function META:SetEntry(str, value)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if type(next[key]) ~= "table" then
					next[key] = {}
				end
				next = next[key]
			end
		end

		next.key = str
		next.value = value
	end

	function META:GetEntry(str)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					return false, "key ".. key .." not found"
				end
				next = next[key]
			end
		end

		return next.value
	end

	function META:GetChildren(str)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					return false, "not found"
				end
				next = next[key]
			end
		end

		return next
	end

	META:Register()

	function utility.CreateTree(delimiter, tree)
		local self = META:CreateObject()

		self.tree = tree or {}
		self.delimiter = delimiter

		return self
	end
end
