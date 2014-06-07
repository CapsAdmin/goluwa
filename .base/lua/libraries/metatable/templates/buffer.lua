local metatable = (...) or _G.metatable

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

local buff = ffi.new("number_buffer_longlong")
buff.integer_unsigned = 1LL
e.BIG_ENDIAN = buff.chars[0] == 0

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

local type_translate = {
	longlong = "uint64_t",
	long = "uint32_t",
	short = "uint16_t",
	char = "uint8_t",
}

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
		
	local size = ffi.sizeof(type_translate[typ:lower()] or typ:lower())
	
	local read_unroll = "\tlocal chars = ffi.cast('char *', self:ReadBytes(" .. size .. "))\n"	
	for i = 1, size do
		read_unroll = read_unroll .. "\tbuff.chars[" .. i-1 .. "] = chars[" .. i-1 .. "]\n"
	end
	template = template:gsub("@READ_BYTES@", read_unroll)
	
	local write_unroll = ""
	write_unroll = write_unroll .. "\tself:WriteBytes(ffi.string(buff.chars, " .. size .. "))\n"
	template = template:gsub("@WRITE_BYTES@", write_unroll)
	
	local func = loadstring(template)
	
	local def = typ:lower()
	if typ == "Float" then def = "long" end
	if typ == "Double" then def = "longlong" end
	
	func(META, ffi.new("number_buffer_" .. def))
end

function metatable.AddBufferTemplate(META)
	check(META.WriteByte, "function")
	check(META.ReadByte, "function")

	do -- basic data types
	
		ADD_FFI_OPTIMIZED_TYPE(META, "Float")	
		ADD_FFI_OPTIMIZED_TYPE(META, "Double")	
		
		ADD_FFI_OPTIMIZED_TYPE(META, "Short")	
		ADD_FFI_OPTIMIZED_TYPE(META, "Long")	
		ADD_FFI_OPTIMIZED_TYPE(META, "LongLong")
		
		function META:WriteBytes(str)
			for i = 1, #str do
				self:WriteByte(str:byte(i))
			end
			return self
		end
		
		function META:ReadBytes(bytes)
			local out = {}
			for i = 1, bytes do
				table.insert(out, string.char(self:ReadByte()))
			end
			return table.concat(out)
		end
		
		-- string
		function META:WriteString(str)	
			self:WriteBytes(str)
			self:WriteByte(0)
			return self
		end

		function META:ReadString(length)
		
			if length then
				return self:ReadBytes(length)
			end
			
			local str = {}
			
			for i = 1, length or self:GetSize() do
				local byte = self:ReadByte()
				if not byte or byte == 0 then break end
				table.insert(str, string.char(byte))
			end
			
			return table.concat(str)
		end
	end

	do -- extended	
	
		-- half precision (2 bytes)
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
		
		function META:ReadAll()
			return self:ReadBytes(self:GetSize())
		end
	
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