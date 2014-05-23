local packet = _G.packet or {}

packet.Listeners = packet.Listeners or {}

function packet.AddListener(id, callback)
	
	if SERVER then
		network.AddString(id)
	end

	packet.Listeners[id] = callback
end

function packet.RemoveListener(id)
	packet.Listeners[id] = nil
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
	local id = network.IDToString(buffer:ReadShort())
	
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
		
		if packet.Listeners[id] then
			packet.Listeners[id](buffer)
		end
	end

	event.AddListener("PacketReceived", "packet", packet.OnPacketReceived, print)
end

if SERVER then
	function packet.Send(id, filter, buffer)
		local data = prepend_header(id, buffer)
		
		if data then
			if typex(filter) == "player" then
				network.SendPacketToClient(filter.socket, data)
			elseif typex(filter) == "player_filter" then
				for _, player in pairs(filter:GetAll()) do
					network.SendPacketToClient(player.socket, data)
				end
			else
				for key, ply in pairs(players.GetAll()) do
					network.SendPacketToClient(ply.socket, data)
				end
			end
		end
	end
	
	function packet.Broadcast(id, buffer)
		return packet.Send(id, nil, buffer)
	end
	
	function packet.OnPacketReceived(ply, str)
		local buffer = packet.CreateBuffer(str)
		local id = read_header(buffer)
		
		if packet.Listeners[id] then
			packet.Listeners[id](ply, buffer)
		end
	end
	
	event.AddListener("PacketReceived", "packet", packet.OnPacketReceived, print)
end

do -- buffer object
	-- some of this was taken from (mainly reading and writing decimal numbers)
	-- http://wowkits.googlecode.com/svn-history/r406/trunk/AddOns/AVR/ByteStream.lua

	local META = utilities.CreateBaseMeta("buffer")

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

	do -- basic data types
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
				return self.file:read(1):byte()
			else
				self.position = math.min(self.position + 1, #self.buffer)
				return self.buffer[self.position]
			end
		end

		-- short
		function META:WriteShort(short)
			self:WriteByte(bit.band(short, 0xFF))
			self:WriteByte(bit.band(bit.rshift(short, 8), 0xFF))
			return self
		end

		function META:ReadShort()
			local b1, b2 = self:ReadByte(), self:ReadByte()
			if not b1 or not b2 then return end
			return b1 + bit.lshift(b2, 8)  
		end
		
		-- long
		function META:WriteLong(int)	
			self:WriteShort(bit.band(int, 0xFFFF))
			self:WriteShort(bit.band(bit.rshift(int, 16), 0xFFFF))
			return self
		end

		function META:ReadLong()
			local s1, s2 = self:ReadShort(), self:ReadShort()
			if not s1 or not s2 then return end
			return s1 + bit.lshift(s2, 16)
		end
		
		-- half
		function META:WriteHalf(value)
		-- ieee 754 binary16
		-- 111111
		-- 54321098 76543210
		-- seeeeemm mmmmmmmm
			if value==0.0 then
				self:WriteByte(0)
				self:WriteByte(0)
				return
			end

			local signBit=0
			if value<0 then
				signBit=128 -- shifted left to appropriate position 
				value=-value
			end
			
			local m,e=math.frexp(value) 
			m=m*2-1
			e=e-1+15
			e=math.min(math.max(0,e),31)
			
			m=m*4
			-- sign, 5 bits of exponent, 2 bits of mantissa
			self:WriteByte(bit.bor(signBit,bit.band(e,31)*4,bit.band(m,3)))
			
			-- get rid of written bits and shift for next 8
			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))	
			return self
		end

		function META:ReadHalf()
			local b=self:ReadByte()
			local sign=1
			if b>=128 then 
				sign=-1
				b=b-128
			end
			local exponent=bit.rshift(b,2)-15
			local mantissa=bit.band(b,3)/4
			
			b=self:ReadByte()
			mantissa=mantissa+b/4/256
			if mantissa==0.0 and exponent==-15 then return 0.0
			else return (mantissa+1.0)*math.pow(2,exponent)*sign end
		end

		-- float
		function META:WriteFloat(value)
		-- ieee 754 binary32
		-- 33222222 22221111 111111
		-- 10987654 32109876 54321098 76543210
		-- seeeeeee emmmmmmm mmmmmmmm mmmmmmmm
			if value==0.0 then
				self:WriteByte(0)
				self:WriteByte(0)
				self:WriteByte(0)
				self:WriteByte(0)
				return
			end

			local signBit=0
			if value<0 then
				signBit=128 -- shifted left to appropriate position 
				value=-value
			end
			
			local m,e=math.frexp(value) 
			m=m*2-1
			e=e-1+127
			e=math.min(math.max(0,e),255)
			
			-- sign and 7 bits of exponent
			self:WriteByte(bit.bor(signBit,bit.band(bit.rshift(e,1),127)))
			
			-- first 7 bits of mantissa
			m=m*128
			-- write last bit of exponent and first 7 of mantissa
			self:WriteByte(bit.bor(bit.band(bit.lshift(e,7),255),bit.band(m,127)))
			-- get rid of written bits and shift for next 8
			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))
			
			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))	
			return self
		end

		function META:ReadFloat()
			local b=self:ReadByte()
			local sign=1
			if b>=128 then 
				sign=-1
				b=b-128
			end
			local exponent=b*2
			b=self:ReadByte()
			exponent=exponent+bit.band(bit.rshift(b,7),1)-127
			local mantissa=bit.band(b,127)/128
			
			b=self:ReadByte()
			mantissa=mantissa+b/128/256
			b=self:ReadByte()
			mantissa=mantissa+b/128/65536
			if mantissa==0.0 and exponent==-127 then return 0.0
			else return (mantissa+1.0)*math.pow(2,exponent)*sign end
		end
		
		-- double
		function META:WriteDouble(value)
		-- ieee 754 binary64
		-- 66665555 55555544 44444444 33333333 33222222 22221111 111111
		-- 32109876 54321098 76543210 98765432 10987654 32109876 54321098 76543210
		-- seeeeeee eeeemmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm
			if value==0.0 then
				for i = 1, 8 do
					self:WriteByte(0)
				end
				return
			end

			local signBit=0
			
			if value<0 then
				signBit=128 -- shifted left to appropriate position 
				value=-value
			end
			
			local m,e=math.frexp(value) 
			m=m*2-1 -- m in [0.5,1.0), multiply by 2 will get it to [1.0,2.0) giving the implicit first bit in mantissa, -1 to get rid of that
			e=e-1+1023 -- adjust for the *2 on previous line and 1023 is the exponent zero offset
			
			-- sign and 7 bits of exponent
			self:WriteByte(bit.bor(signBit,bit.band(bit.rshift(e,4),127)))
			
			-- first 4 bits of mantissa
			m=m*16
			
			-- write last 4 bits of exponent and first 4 of mantissa
			self:WriteByte(bit.bor(bit.band(bit.lshift(e,4),255),bit.band(m,15)))
			
			-- get rid of written bits and shift for next 8
			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))
			
			-- repeat for rest of mantissa
			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))

			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))

			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))

			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))
			
			m=(m-math.floor(m))*256
			self:WriteByte(bit.band(m,255))
			
			return self
		end

		function META:ReadDouble()
			local b = self:ReadByte()
			if not b then return end
			local sign = 1
			
			if b >= 128 then 
				sign =- 1
				b = b - 128
			end
			
			local exponent = b*16
			b = self:ReadByte()
			if not b then return end
			exponent = exponent+bit.band(bit.rshift(b,4),15)-1023
			local mantissa=bit.band(b,15)/16
			
			b = self:ReadByte()
			if not b then return end
			mantissa = mantissa+b/16/256
			b = self:ReadByte()
			if not b then return end
			mantissa = mantissa+b/16/65536
			b = self:ReadByte()
			if not b then return end
			mantissa = mantissa+b/16/65536/256
			b = self:ReadByte()
			if not b then return end
			mantissa = mantissa+b/16/65536/65536
			b = self:ReadByte()
			if not b then return end
			mantissa = mantissa+b/16/65536/65536/256
			b = self:ReadByte()
			if not b then return end
			mantissa = mantissa+b/16/65536/65536/65536
			
			if mantissa==0.0 and exponent==-1023 then 
				return 0.0
			else 
				return (mantissa+1.0)*math.pow(2,exponent)*sign 
			end
		end
		
		ffi.cdef [[
		  typedef union {
			uint32_t longs[2];
			uint64_t longlong;
		  } ll_buffer_int64;
		]]

		local btl = ffi.typeof("ll_buffer_int64")
		local data = btl()
		
		--long long
		function META:WriteLongLong(longlong)
			data.longlong = longlong
			self:WriteLong(data.longs[0])
			self:WriteLong(data.longs[1])
			return self
		end
		
		function META:ReadLongLong()
			local l1, l2 = self:ReadLong(), self:ReadLong()
			if not l1 or not l2 then return end
			local buffer = btl()
			buffer.longs[0] = l1
			buffer.longs[1] = l2
			return buffer.longlong
		end
		
		-- string
		function META:WriteString(str)	
			for i = 1, #str do
				self:WriteByte(str:byte(i))
			end
			self:WriteByte(0)
			return self
		end

		function META:ReadString(length)
			if self.file and length then
				return self.file:read(length)
			else
				local str = {}
				
				for i = 1, length or self:GetSize() do
					local byte = self:ReadByte()
					if not byte then break end
					if not length and byte == 0 then break end
					table.insert(str, string.char(byte))
				end
				
				return table.concat(str)
			end
		end
	end

	do -- extended

		-- boolean
		function META:WriteBoolean(b)
			self:WriteByte(b and 1 or 0)
			return self
		end
		
		function META:ReadBoolean()
			return self:ReadByte() >= 1
		end
		
		-- number
		META.WriteNumber = META.WriteDouble
		META.ReadNumber = META.ReadDouble
			
		-- char
		function META:WriteChar(b)
			self:WriteByte(b:byte())
			return self
		end
		
		function META:ReadChar()
			return string.char(self:ReadByte())
		end
		
		-- nil
		function META:WriteNil(n)
			self:WriteByte(0)
			return self
		end
		
		function META:ReadNil()
			self:ReadByte()
			return nil
		end
		
		-- vec3
		function META:WriteVec3(v)
			self:WriteFloat(v.x)
			self:WriteFloat(v.y)
			self:WriteFloat(v.z)
			return self
		end
		
		function META:ReadVec3()
			return Vec3(self:ReadFloat(), self:ReadFloat(), self:ReadFloat())
		end
		
		-- ang3
		function META:WriteAng3(v)
			self:WriteFloat(v.x)
			self:WriteFloat(v.y)
			self:WriteFloat(v.z)
			return self
		end
		
		function META:ReadAng3()
			return Vec3(self:ReadFloat(), self:ReadFloat(), self:ReadFloat())
		end
		
		-- integer/long
		META.WriteInt = META.WriteLong
		META.ReadInt = META.ReadLong
		
		function META:WriteBytes(str)
			for i = 1, #str do
				self:WriteByte(str:byte(i))
			end
			return self
		end
	end

	do -- structures
		local function header_to_table(str)
			local out = {}

			str = str:gsub("//.-\n", "") -- remove line comments
			str = str:gsub("/%*.-%s*/", "") -- remove multiline comments
			str = str:gsub("%s+", " ") -- remove excessive whitespace
			
			for field in str:gmatch("(.-);") do
				local type, key = field:match("(.+) (.+)$")
				
				type = type:trim()
				key = key:trim()
				
				local length
				
				key = key:gsub("%[(.-)%]$", function(num)
					length = tonumber(num)
					return ""
				end)	
				
				local qualifier, _type = type:match("(.+) (.+)")
				
				if qualifier then
					type = _type
				end
				
				if not type then 	
					print(field)
					error("somethings wrong with this line!", 2) 
				end
				
				if qualifier == nil then
					qualifier = "signed"
				end
				
				if type == "char" and not length then 
					type = "byte"
				end
				
				table.insert(out, {type, key, signed = qualifier == "signed", length = length, padding = qualifier == "padding"})
			end
			
			return out
		end

		function META:WriteStructure(structure, values)
			for i, data in ipairs(structure) do
				if type(data) == "number" then
					self:WriteByte(data)
				else
					if data.get then					
						if type(data.get) == "function" then
							self:WriteType(data.get(values), data[1])
						else
							if not values or values[data.get] == nil then
								errorf("expected %s %s got nil", 2, data[1], data.get)
							end
							self:WriteType(values[data.get], data[1])
						end
					else
						self:WriteType(data[2], data[1])
					end
				end
			end
		end
		
		local function fix_number(data, num)
			if type(num) == "number" then 
				if not data.signed then
					num = bit.bnot(bit.bnot(num))
				end
				
				num = math.round(num, 8)
			end
			return num
		end
		 
		function META:ReadStructure(structure)
			
			if type(structure) == "string" then
				return self:ReadStructure(header_to_table(structure))
			end
		
			local out = {}
				
			for i, data in ipairs(structure) do
			
				if data.match then
					local key, val = next(data.match)
					if (type(val) == "function" and not val(out[key])) or out[key] ~= val then
						goto continue
					end
				end
				
				
				local val
				
				if data.length then
					if data[1] == "char" or data[1] == "string" then
						val = self:ReadString(data.length)
					else
						local values = {}
						for i = 1, data.length do
							table.insert(values, fix_number(data, self:ReadType(data[1])))
						end
						val = values
					end
				else
					val = self:ReadType(data[1]) 
				end
				
				fix_number(data, val)
				
				if data.assert then
					if val ~= data.assert then
						errorf("error in header: %s %s expected %X got %s", 2, data[1], data[2], data.assert, (type(val) == "number" and ("%X"):format(val) or type(val)))
					end
				end
		
				if data.translate then
					val = data.translate[val] or val
				end			
				
				if not data.padding then
					if val == nil then val = "nil" end
					local key = data[2]
					if out[key] then key = key .. i end
					out[key] = val
				end
					
				if type(data[3]) == "table" then
					local tbl = {}
					out[data[2]] = tbl			
					for i = 1, val do
						table.insert(tbl, self:ReadStructure(data[3]))
					end
				end
				
				if data.switch then
					for k, v in pairs(self:ReadStructure(data.switch[val])) do
						out[k] = v
					end
				end
				
				::continue::
			end
			
			return out
		end
	end


	do -- automatic
		local read_functions = {}
		local write_functions = {}

		for k, v in pairs(META) do
			if type(k) == "string" then
				local key = k:match("Read(.+)")
				if key then
					read_functions[key:lower()] = v
				end
				
				local key = k:match("Write(.+)")
				if key then
					write_functions[key:lower()] = v
				end
			end
		end

		function META:WriteType(val, t)
			t = t or type(val)
						
			if write_functions[t] then
				return write_functions[t](self, val)
			end
			
			error("tried to write unknown type " .. t, 2)
		end
		
		function META:ReadType(t)
		
			if read_functions[t] then
				return read_functions[t](self, val)
			end
			
			error("tried to read unknown type " .. t, 2)
		end
	end
end

_G.Buffer = packet.CreateBuffer

return packet