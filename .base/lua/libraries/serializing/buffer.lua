-- some of this was taken from (mainly reading and writing decimal numbers)
-- http://wowkits.googlecode.com/svn-history/r406/trunk/AddOns/AVR/ByteStream.lua

local META = utilities.CreateBaseMeta("buffer")

function Buffer(val)
	local self = META:New()
	
	if type(val) == "string" then
		self.buffer = {}
		self.position = 0
		
		if val then 
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
			return #self.buffer
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
			self.position = math.clamp(pos + 1, 1, self:GetSize() + 1)
		end
	end
	
	function META:GetPos()
		if self.file then
			return self.file:seek("cur")
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
		return (self:GetString():gsub("(.)", function(str) str = ("%X"):format(str:byte()) if #str == 1 then str = "0" .. str end return str .. " " end))
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
	end

	function META:ReadByte()
		if self.file then
			return self.file:read(1):byte()
		else
			self.position = self.position + 1
			return self.buffer[self.position]
		end
	end

	-- short
	function META:WriteShort(short)
		self:WriteByte(bit.band(bit.rshift(short,8),0xFF))
		self:WriteByte(bit.band(short,0xFF))
	end

	function META:ReadShort()
		local b1, b2 = self:ReadByte(), self:ReadByte()
		if not b1 or not b2 then return end
		return bit.tobit(bit.lshift(b2, 8) + bit.lshift(b1, 0))
	end

	-- long
	function META:WriteLong(int)
		self:WriteByte(bit.band(bit.rshift(int,24),0xFF))
		self:WriteByte(bit.band(bit.rshift(int,16),0xFF))
		self:WriteByte(bit.band(bit.rshift(int,8),0xFF))
		self:WriteByte(bit.band(int,0xFF))
	end

	function META:ReadLong()
		local b1, b2, b3, b4 = self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte()
		if not b1 or not b2 or not b3 or not b4 then return end
		return 
			bit.lshift(b4, 24) + bit.lshift(b3, 16) + bit.lshift(b2, 8) + bit.lshift(b1, 0)
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
		e=min(max(0,e),31)
		
		m=m*4
		-- sign, 5 bits of exponent, 2 bits of mantissa
		self:WriteByte(bit.bor(signBit,bit.band(e,31)*4,bit.band(m,3)))
		
		-- get rid of written bits and shift for next 8
		m=(m-math.floor(m))*256
		self:WriteByte(bit.band(m,255))	
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
		e=min(max(0,e),255)
		
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
	end

	function META:ReadDouble()
		local b=self:ReadByte()
		local sign=1
		if b>=128 then 
			sign=-1
			b=b-128
		end
		local exponent=b*16
		b=self:ReadByte()
		exponent=exponent+bit.band(bit.rshift(b,4),15)-1023
		local mantissa=bit.band(b,15)/16
		
		b=self:ReadByte()
		mantissa=mantissa+b/16/256
		b=self:ReadByte()
		mantissa=mantissa+b/16/65536
		b=self:ReadByte()
		mantissa=mantissa+b/16/65536/256
		b=self:ReadByte()
		mantissa=mantissa+b/16/65536/65536
		b=self:ReadByte()
		mantissa=mantissa+b/16/65536/65536/256
		b=self:ReadByte()
		mantissa=mantissa+b/16/65536/65536/65536
		if mantissa==0.0 and exponent==-1023 then return 0.0
		else return (mantissa+1.0)*math.pow(2,exponent)*sign end
	end
	
	--long long
	function META:WriteLongLong(int)
		self:WriteByte(bit.band(bit.rshift(int,56),0xFF))
		self:WriteByte(bit.band(bit.rshift(int,48),0xFF))
		self:WriteByte(bit.band(bit.rshift(int,40),0xFF))
		self:WriteByte(bit.band(bit.rshift(int,32),0xFF))
		self:WriteByte(bit.band(bit.rshift(int,24),0xFF))
		self:WriteByte(bit.band(bit.rshift(int,16),0xFF))
		self:WriteByte(bit.band(bit.rshift(int,8),0xFF))
		self:WriteByte(bit.band(int,0xFF))
	end
	
	function META:ReadLongLong()
		local b1, b2, b3, b4, b5, b6, b7, b8 = self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte()
		if not b1 or not b2 or not b3 or not b4 or not b5 or not b6 or not b7 or not b8 then return end
		return
			bit.lshift(b8, 56) + 
			bit.lshift(b7, 48) + 
			bit.lshift(b6, 40) + 
			bit.lshift(b5, 32) + 
			bit.lshift(b4, 24) + 
			bit.lshift(b3, 16) + 
			bit.lshift(b2, 8) + 
			bit.lshift(b1, 0)
	end
	
	-- string
	function META:WriteString(str)	
		for i = 1, #str do
			self:WriteByte(str:byte(i))
		end
		self:WriteByte(0)
	end

	function META:ReadString(length)
		local str = {}
		
		for i = 1, length or self:GetSize() do
			local byte = self:ReadByte()
			if not byte then return end
			if not length and byte == 0 then break end
			table.insert(str, string.char(byte))
		end
		
		return table.concat(str)
	end
end

do -- extended

	-- boolean
	function META:WriteBoolean(b)
		self:WriteByte(b and 1 or 0)
	end
	
	function META:ReadBoolean()
		return self:ReadByte() == 1
	end
	
	-- number
	META.WriteNumber = META.WriteDouble
	META.ReadNumber = META.ReadDouble
		
	-- char
	function META:WriteChar(b)
		self:WriteByte(b:byte())
	end
	
	function META:ReadChar()
		return string.char(self:ReadByte())
	end
	
	-- nil
	function META:WriteNil(n)
		self:WriteByte(0)
	end
	
	function META:ReadNil()
		self:ReadByte()
		return nil
	end
	
	-- integer/long
	META.WriteInt = META.WriteLong
	META.ReadInt = META.ReadLong
	
	function META:WriteBytes(str)
		for i = 1, #str do
			self:WriteByte(str:byte(i))
		end
	end
end

do -- structures
	local function header_to_table(str)
		local out = {}

		str = str:gsub("//.-\n", "") -- remove line comments
		str = str:gsub("/%*.-%s*/", "") -- remove multiline comments
		str = str:gsub("%s+", " ") -- remove excessive whitespace
		str = str:match("^.-(%b{})") -- grab only the first bracket
		str = str:match("{(.+)}")
		
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
			
			table.insert(out, {type, key, signed = qualifier == "signed", length = length})
		end
		
		return out
	end

	function META:WriteStructure(structure)
		for i, data in ipairs(structure) do
			self:WriteType(data[2], data[1])
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
				if data[1] == "char" then
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
					error("error in header, expected " .. data[1] .. " " .. ("%X"):format(data.assert) .. " got " .. (type(val) == "number" and ("%X"):format(val) or type(val)), 2)
				end
			end
	
			if data.translate then
				val = data.translate[val] or val
			end			
						
			out[data[2]] = val or "nil"
				
			if type(data[3]) == "table" then
				local tbl = {}
				out[data[2]] = tbl			
				for i = 1, val do
					table.insert(tbl, self:ReadStructure(data[3]))
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
