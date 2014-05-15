local META = utilities.CreateBaseMeta("buffer")

function Buffer(str)
	local self = META:New()
	
	self.buffer = {}
	self.position = 0
	
	if str then self:WriteBytes(str) end
	
	return self
end

do -- generic
	function META:GetBuffer()
		return self.buffer
	end

	function META:GetSize()
		return #self.buffer
	end
	
	META.__len = META.Length
	
	function META:GetString()
		local temp = {}
		
		for k,v in ipairs(self.buffer) do
			temp[#temp + 1] = string.char(v)
		end
		
		return table.concat(temp)
	end
	
	function META:SetPos(pos)
		self.position = math.clamp(pos + 1, 1, self:GetSize())
	end
	
	function META:GetPos()
		return self.position
	end

	function META:Advance(i)
		i = i or 1
		self:SetPos(self:GetPos() + i) 
	end
end

do -- basic data types
	-- byte
	function META:WriteByte(byte)
		self.buffer[#self.buffer + 1] = byte
	end

	function META:ReadByte()
		self.position = self.position + 1
		return self.buffer[self.position]
	end

	-- short
	function META:WriteShort(short)
		self:WriteByte(bit.band(bit.rshift(short,8),0xFF))
		self:WriteByte(bit.band(short,0xFF))
	end

	function META:ReadShort()
		local b1, b2 = self:ReadByte(), self:ReadByte()
		if not b1 or not b2 then return end
		return bit.lshift(b1, 8) + bit.lshift(b2, 0)
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
			bit.lshift(b1, 24) + 
			bit.lshift(b2, 16) + 
			bit.lshift(b3, 8) + 
			bit.lshift(b4, 0)
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
	function META:WriteFloat(float)
		if float == 0 then
			self:WriteByte(0x00)
			self:WriteByte(0x00)
			self:WriteByte(0x00)
			self:WriteByte(0x00)
		elseif number ~= number then
			self:WriteByte(0xFF)
			self:WriteByte(0xFF)
			self:WriteByte(0xFF)
			self:WriteByte(0xFF)
		else
			local sign = 0x00
			if float < 0 then
				sign = 0x80
				float = -float
			end
			local mantissa, exponent = math.frexp(float)
			exponent = exponent + 0x7F
			if exponent <= 0 then
				mantissa = math.ldexp(mantissa, exponent - 1)
				exponent = 0
			elseif exponent > 0 then
				if exponent >= 0xFF then
					self:WriteByte(sign + 0x7F)
					self:WriteByte(0x80)
					self:WriteByte(0x00)
					self:WriteByte(0x00)
					return
				elseif exponent == 1 then
					exponent = 0
				else
					mantissa = mantissa * 2 - 1
					exponent = exponent - 1
				end
			end
			mantissa = math.floor(math.ldexp(mantissa, 23) + 0.5)

			self:WriteByte(sign + math.floor(exponent / 2))
			self:WriteByte((exponent % 2) * 0x80 + math.floor(mantissa / 0x10000))
			self:WriteByte(math.floor(mantissa / 0x100) % 0x100)
			self:WriteByte(mantissa % 0x100)
		end
	end

	function META:ReadFloat()
		local b1, b2, b3, b4 = self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte()
		if not b1 or not b2 or not b3 or not b4 then return end
		local exponent = (b1 % 0x80) * 0x02 + math.floor(b2 / 0x80)
		local mantissa = math.ldexp(((b2 % 0x80) * 0x100 + b3) * 0x100 + b4, -23)
		if exponent == 0xFF then
			if mantissa > 0 then
				return 0 / 0
			else
				mantissa = math.huge
				exponent = 0x7F
			end
		elseif exponent > 0 then
			mantissa = mantissa + 1
		else
			exponent = exponent + 1
		end
		if b1 >= 0x80 then
			mantissa = -mantissa
		end
		return math.ldexp(mantissa, exponent - 0x7F)
	end
	
	-- double
	function META:WriteDouble(value)
	-- http://wowkits.googlecode.com/svn-history/r406/trunk/AddOns/AVR/ByteStream.lua
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
			bit.lshift(b1, 56) + 
			bit.lshift(b1, 48) + 
			bit.lshift(b1, 40) + 
			bit.lshift(b1, 32) + 
			bit.lshift(b1, 24) + 
			bit.lshift(b2, 16) + 
			bit.lshift(b3, 8) + 
			bit.lshift(b4, 0)
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
		return self:WriteByte() == 1
	end
	
	-- nil
	function META:WriteNil(n)
		self:WriteByte(0)
	end
	
	function META:ReadNil()
		self:ReadByte()
		return nil
	end
	
	function META:WriteBytes(str)
		for i = 1, #str do
			self:WriteByte(str:byte(i))
		end
	end
	
	function META:WriteType(val, t)
		t = t or type(val)
		
		if t == "number" then
			self:WriteDouble(val)
		elseif t == "boolean" then
			self:WriteBoolean(val)
		elseif t == "string" then
			self:WriteString(val)
		elseif t == "byte" then
			self:WriteByte(val)
		elseif t == "short" then
			self:WriteShort(val)
		elseif t == "half" then
			self:WriteHalf(val)
		elseif t == "long" then
			self:WriteLong(val)
		elseif t == "float" then
			self:WriteFloat(val)
		elseif t == "double" then
			self:WriteDouble(val)
		elseif t == "longlong" then
			self:WriteLongLong(val)
		end
	end
	
	function META:ReadType(t)	
		if t == "number" then
			return self:ReadDouble()
		elseif t == "boolean" then
			return self:ReadBoolean()
		elseif t == "string" then
			return self:ReadString()
		elseif t == "byte" then
			return self:ReadByte()
		elseif t == "short" then
			return self:ReadShort()
		elseif t == "half" then
			return self:ReadHalf()
		elseif t == "long" then
			return self:ReadLong()
		elseif t == "float" then
			return self:ReadFloat()
		elseif t == "double" then
			return self:ReadDouble()
		elseif t == "longlong" then
			return self:ReadLongLong()
		end
		
		error("tried to read unknown type " .. t, 2)
	end
	
	function META:GetDebugString()
		return (self:GetString():gsub("(.)", function(str) return ("%x "):format(str:byte()) end))
	end
end