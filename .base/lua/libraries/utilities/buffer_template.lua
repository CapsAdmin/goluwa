local utilities = (...) or _G.utilities

ffi.cdef[[
	typedef union {
		uint8_t chars[8];
		uint16_t shorts[4];
		uint32_t longs[2];
		
		int64_t integer_signed;
		uint64_t integer_unsigned;
		double decimal;
		
	} number_buffer_longlong;
	
	typedef union {
		uint8_t chars[4];
		uint16_t shorts[2];
		
		int32_t integer_signed;
		uint32_t integer_unsigned;
		float decimal;
		
	} number_buffer_long;
	
	typedef union {
		uint8_t chars[2];
	
		int16_t integer_signed;
		uint16_t integer_unsigned;
		
	} number_buffer_short;
	
]]

local integer_assign = [[if signed then 
		buff.integer_signed = num
	else
		buff.integer_unsigned = num
	end]]
local integer_return = [[if signed then 
		return buff.integer_signed
	else
		return buff.integer_unsigned
	end]]
	
local decimal_assign = "buff.decimal = num"
local decimal_return = "return buff.decimal"

local template = [[
local META, buff = ...
META["@WRITE@"] = function(@READ_ARGS@)
	@ASSIGN@
@WRITE_BYTES@
return self
end
META["@READ@"] = function(@WRITE_ARGS@)
@READ_BYTES@
	@RETURN@
end]]

local function ADD_FFI_OPTIMIZED_TYPE(META, typ)
	local decimal = false
	
	if typ == "Float" or typ == "Double" then
		decimal = true
	end
	
	local template = template
		:gsub("@READ@", "Read" ..typ)
		:gsub("@WRITE@", "Write" ..typ)		
	if decimal then
		template = template:gsub("@READ_ARGS@", "self, num")
		template = template:gsub("@WRITE_ARGS@", "self")
		template = template:gsub("@ASSIGN@", decimal_assign) 
		template = template:gsub("@RETURN@", decimal_return)
	else
		template = template:gsub("@READ_ARGS@", "self, num, signed")
		template = template:gsub("@WRITE_ARGS@", "self, signed")
		template = template:gsub("@ASSIGN@", integer_assign)
		template = template:gsub("@RETURN@", integer_return)
	end
		
	local size = ffi.sizeof(typ:lower() == "longlong" and "long long" or typ:lower())
	
	local read_unroll = ""
	for i = 1, size do
		read_unroll = read_unroll .. "\tbuff.chars[" .. i-1 .. "] = self:ReadByte()\n"
	end		
	template = template:gsub("@READ_BYTES@", read_unroll)
	
	local write_unroll = ""
	for i = 1, size do
		write_unroll = write_unroll .. "\tself:WriteByte(buff.chars[" .. i-1 .. "])\n"
	end		
	template = template:gsub("@WRITE_BYTES@", write_unroll)
	
	local func = loadstring(template)
	
	local def = typ:lower()
	if typ == "Float" then def = "long" end
	if typ == "Double" then def = "longlong" end
	
	func(META, ffi.new("number_buffer_" .. def))
end

function utilities.BufferTemplate(META)
	check(META.WriteByte, "function")
	check(META.ReadByte, "function")

	do -- basic data types
	
		ADD_FFI_OPTIMIZED_TYPE(META, "Float")	
		ADD_FFI_OPTIMIZED_TYPE(META, "Double")	
		
		ADD_FFI_OPTIMIZED_TYPE(META, "Short")	
		ADD_FFI_OPTIMIZED_TYPE(META, "Long")	
		ADD_FFI_OPTIMIZED_TYPE(META, "LongLong")
	
		--[==[
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
		]==]
		
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
		
		-- string
		function META:WriteString(str)	
			for i = 1, #str do
				self:WriteByte(str:byte(i))
			end
			self:WriteByte(0)
			return self
		end

		function META:ReadString(length)
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
			do return num end
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
				
				val = fix_number(data, val)
				
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