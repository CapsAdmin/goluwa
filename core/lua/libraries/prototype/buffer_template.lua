local META = ...

local ffi = desire("ffi")

-- <cmtptr> CapsAdmin, http://codepad.org/uN7qlQTm
local function swap_endian(num, size)
	local result = 0
	for shift = 0, size - 8, 8 do
		result = bit.bor(bit.lshift(result, 8),
				bit.band(bit.rshift(num, shift), 0xff))
	end
	return result
end

local function header_to_table(str)
	local out = {}

	str = str:gsub("//.-\n", "") -- remove line comments
	str = str:gsub("/%*.-%s*/", "") -- remove multiline comments
	str = str:gsub("%s+", " ") -- remove excessive whitespace

	for field in str:gmatch("(.-);") do
		local type, key
		local assert
		local swap_endianess = false

		field = field:trim()

		if field:startswith("swap") then
			field = field:sub(#"swap" + 1)
			swap_endianess = true
		end

		if field:find("=") then
			type, key, assert = field:match("^(.+) (.+) = (.+)$")
			assert = tonumber(assert) or assert
		else
			type, key = field:match("(.+) (.+)$")
		end

		type = type:trim()
		key = key:trim()

		local length

		key = key:gsub("%[(.-)%]$", function(num)
			length = tonumber(num) or num
			return ""
		end)

		local qualifier, _type = type:match("(.+) (.+)")

		if qualifier then
			type = _type
		end

		if not type then
			logn("somethings wrong with the above line!")
			error(field, 2)
		end

		if qualifier == nil then
			qualifier = "signed"
		end

		if type == "char" and not length then
			type = "byte"
		end

		table.insert(out, {
			type,
			key,
			signed = qualifier == "signed",
			length = length,
			padding = qualifier == "padding",
			assert = assert,
			swap_endianess = swap_endianess,
		})
	end

	return out
end

assert(META.WriteByte, "missing META:WriteByte")
assert(META.ReadByte, "missing META:ReadByte")

do -- basic data types
	if ffi then
		local type_info = {
			LongLong = "int64_t",
			UnsignedLongLong = "uint64_t",

			Long = "int32_t",
			UnsignedLong = "uint32_t",

			Short = "int16_t",
			UnsignedShort = "uint16_t",

			Double = "double",
			Float = "float",
		}

		local ffi_cast = ffi.cast
		local ffi_string = ffi.string
		for name, type in pairs(type_info) do
			type = ffi.typeof(type)
			local size = ffi.sizeof(type)

			local ctype = ffi.typeof("$*", type)
			META["Read" .. name] = function(self)
				return ffi_cast(ctype, self:ReadBytes(size))[0]
			end

			local ctype = ffi.typeof("$[1]", type)
			local hmm = ffi.new(ctype, 0)
			META["Write" .. name] = function(self, num)
				hmm[0] = num
				self:WriteBytes(ffi_string(hmm, size))
				return self
			end
		end


		function META:ReadVariableSizedInteger(byte_size)
			local ret = 0

			for i = 0, byte_size - 1 do
				local byte = self:ReadByte()
				ret = bit.bor(ret, bit.lshift(bit.band(byte, 127), 7 * i))
				if bit.band(byte, 128) == 0 then
					break
				end
			end

			if byte_size == 1 then
				ret = tonumber(ffi.cast("uint8_t", ret))
			elseif byte_size == 2 then
				ret = tonumber(ffi.cast("uint16_t", ret))
			elseif byte_size >= 2 and byte_size <= 4 then
				ret = tonumber(ffi.cast("uint32_t", ret))
			elseif byte_size > 4 and byte_size <= 8 then
				ret = tonumber(ffi.cast("uint64_t", ret))
			end

			return ret
		end

		function META:WriteSizedInteger(value, byte_size)
			for i = 0, byte_size do
				if value > 127 then
					self:WriteByte(tonumber(bit.band(value, 7)))
					value = bit.rshift(value, 7)
				else
					self:WriteByte(0)
				end
			end
		end

		function META:ReadSizedInteger(byte_size)
			local ret = 0

			for i = 0, byte_size do
				ret = bit.bor(ret, bit.lshift(self:ReadByte(), 7 * i))
			end

			if byte_size == 1 then
				ret = tonumber(ffi.cast("uint8_t", ret))
			elseif byte_size == 2 then
				ret = tonumber(ffi.cast("uint16_t", ret))
			elseif byte_size >= 2 and byte_size <= 4 then
				ret = tonumber(ffi.cast("uint32_t", ret))
			elseif byte_size > 4 and byte_size <= 8 then
				ret = tonumber(ffi.cast("uint64_t", ret))
			end

			return ret
		end
	else
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
	end

	META.WriteUInt16_T = META.WriteUnsignedShort
	META.WriteUInt32_T = META.WriteUnsignedLong
	META.WriteUInt64_T = META.WriteUnsignedLongLong

	META.ReadUInt16_T = META.ReadUnsignedShort
	META.ReadUInt32_T = META.ReadUnsignedLong
	META.ReadUInt64_T = META.ReadUnsignedLongLong

	META.WriteInt16_T = META.WriteShort
	META.WriteInt32_T = META.WriteLong
	META.WriteInt64_T = META.WriteLongLong

	META.ReadInt16_T = META.ReadShort
	META.ReadInt32_T = META.ReadLong
	META.ReadInt64_T = META.ReadLongLong

	function META:WriteBytes(str, len)
		for i = 1, len or #str do
			self:WriteByte(str:byte(i))
		end
		return self
	end

	function META:ReadBytes(bytes)
		local out = {}
		for i = 1, bytes do
			out[i] = string.char(self:ReadByte())
		end
		return table.concat(out)
	end

	-- null terminated string
	function META:WriteString(str)
		self:WriteBytes(str)
		self:WriteByte(0)
		return self
	end

	function META:ReadString(length, advance, terminator)
		terminator = terminator or 0

		if length and not advance then
			return self:ReadBytes(length)
		end

		local str = {}

		local pos = self:GetPosition()

		for _ = 1, length or self:GetSize() do
			local byte = self:ReadByte()
			if not byte or byte == terminator then break end
			table.insert(str, string.char(byte))
		end

		if advance then self:SetPosition(pos + length) end

		return table.concat(str)
	end

	-- not null terminated string (write size of string first)
	function META:WriteString2(str)
		if #str > 0xFFFFFFFF then error("string is too long!", 2) end
		self:WriteUnsignedLong(#str)
		self:WriteBytes(str)
		return self
	end

	function META:ReadString2()

		local length = self:ReadUnsignedLong()

		local str = {}

		for _ = 1, length do
			local byte = self:ReadByte()
			if not byte then break end
			table.insert(str, string.char(byte))
		end

		return table.concat(str)
	end
end

do -- extended

	function META:IterateStrings()
		return function()
			local value = self:ReadString()
			return value ~= "" and value or nil
		end
	end

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

	function META:ReadVarInt(signed)
		local res = 0
		local size = 0

		for shift = 0, math.huge, 7 do
			local b = self:ReadByte()

			if shift < 28 then
				res = res + bit.lshift(bit.band(b, 0x7F), shift)
			else
				res = res + bit.band(b, 0x7F) * (2 ^ shift)
			end

			size = size + 1

			if b < 0x80 then break end
		end

		if signed then
			res = res - bit.band(res, 2^15) * 2
		end

		return res
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
	function META:WriteNil()
		self:WriteByte(0)
		return self
	end

	function META:ReadNil()
		self:ReadByte()
		return nil
	end

	-- matrix44
	function META:WriteMatrix44(matrix)
		for i = 1, 16 do
			self:WriteFloat(matrix[i - 1])
		end
		return self
	end

	function META:ReadMatrix44()
		local out = Matrix44()

		for i = 1, 16 do
			out.m[i - 1] = self:ReadFloat()
		end

		return out
	end

	-- matrix33
	function META:WriteMatrix33(matrix)
		for i = 1, 8 do
			self:WriteFloat(matrix[i - 1])
		end
		return self
	end

	function META:ReadMatrix33()
		local out = Matrix33()

		for i = 1, 8 do
			out.m[i - 1] = self:ReadFloat()
		end

		return out
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

	-- vec2
	function META:WriteVec2(v)
		self:WriteFloat(v.x)
		self:WriteFloat(v.y)
		return self
	end

	function META:ReadVec2()
		return Vec2(self:ReadFloat(), self:ReadFloat())
	end

	-- vec2
	function META:WriteVec2Short(v)
		self:WriteShort(v.x)
		self:WriteShort(v.y)
		return self
	end

	function META:ReadVec2Short()
		return Vec2(self:ReadShort(), self:ReadShort())
	end

	-- ang3
	function META:WriteAng3(v)
		self:WriteFloat(v.x)
		self:WriteFloat(v.y)
		self:WriteFloat(v.z)
		return self
	end

	function META:ReadAng3()
		return Ang3(self:ReadFloat(), self:ReadFloat(), self:ReadFloat())
	end

	-- quat
	function META:WriteQuat(quat)
		self:WriteFloat(quat.x)
		self:WriteFloat(quat.y)
		self:WriteFloat(quat.z)
		self:WriteFloat(quat.w)
		return self
	end

	function META:ReadQuat()
		return Quat(self:ReadFloat(), self:ReadFloat(), self:ReadFloat(), self:ReadFloat())
	end

	-- color
	function META:WriteColor(color)
		self:WriteFloat(color.r)
		self:WriteFloat(color.g)
		self:WriteFloat(color.b)
		self:WriteFloat(color.a)
		return self
	end

	function META:ReadColor()
		return Color(self:ReadFloat(), self:ReadFloat(), self:ReadFloat(), self:ReadFloat())
	end

	-- integer/long
	META.WriteInt = META.WriteLong
	META.WriteUnsignedInt = META.WriteUnsignedLong
	META.ReadInt = META.ReadLong
	META.ReadUnsignedInt = META.ReadUnsignedLong

	function META:WriteVariableSizedInteger(value)
		local output_size = 1

		while value > 127 do
			self:WriteByte(tonumber(bit.bor(bit.band(value, 127), 128)))
			value = bit.rshift(value, 7)
			output_size = output_size + 1
		end

		self:WriteByte(tonumber(bit.band(value, 127)))

		return output_size
	end

	-- consistency
	META.ReadUnsignedByte = META.ReadByte
	META.WriteUnsignedByte = META.WriteByte

	function META:WriteTable(tbl, type_func)
		type_func = type_func or _G.type

		for k, v in pairs(tbl) do
			local t = type_func(k)
			local id = self:GetTypeID(t)
			if not id then error("tried to write unknown type " .. t, 2) end
			self:WriteByte(id)
			self:WriteType(k, t, type_func)

			t = type_func(v)
			id = self:GetTypeID(t)
			if not id then error("tried to write unknown type " .. t, 2) end
			self:WriteByte(id)
			self:WriteType(v, t, type_func)
		end
	end

	function META:ReadTable()
		local tbl = {}

		while true do
			local b = self:ReadByte()
			local t = self:GetTypeFromID(b)
			if not t then error("typeid " .. b .. " is unknown!", 2) end
			local k = self:ReadType(t)

			b = self:ReadByte()
			t = self:GetTypeFromID(b)
			if not t then error("typeid " .. b .. " is unknown!", 2) end

			tbl[k] = self:ReadType(t)

			if self:TheEnd() then return tbl end
		end

	end

	function META:ReadULEB()
		local result, shift = 0, 0
		while not self:TheEnd() do
			local b = self:ReadByte()
			result = bit.bor( result, bit.lshift( bit.band( b, 0x7f ), shift ) )
			if bit.band( b, 0x80 ) == 0 then break end
			shift = shift + 7
		end
		return result
	end

end

do -- structures
	function META:WriteStructure(structure, values)
		for _, data in ipairs(structure) do
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

	local cache = table.weak()

	function META:ReadStructure(structure, ordered)
		if cache[structure] then
			return self:ReadStructure(cache[structure], ordered)
		end

		if type(structure) == "string" then
			-- if the string is something like "vec3" just call ReadType
			if META.read_functions[structure] then
				return self:ReadType(structure)
			end

			local data = header_to_table(structure)

			cache[structure] = data

			return self:ReadStructure(data, ordered)
		end

		if self:GetSize() == 0 then return end

		local out = {}

		for i, data in ipairs(structure) do
			if data.match then
				local key, val = next(data.match)
				if (type(val) == "function" and not val(out[key])) or out[key] ~= val then
					goto continue_
				end
			end

			local read_type = data.signed and data[1] or "unsigned " .. data[1]
			local val

			if data.length then
				local length = data.length

				if type(length) == "string" then
					if out[length] then
						length = out[length]
					else
						error(length .. "  is not defined!")
					end
				end

				if data[1] == "char" or data[1] == "string" then
					val = self:ReadString(length)
				else
					local values = {}
					for i = 1, length do
						values[i] = self:ReadType(read_type)
					end
					val = values
				end
			else
				if data[1] == "bufferpos" then
					val = self:GetPosition()
				else
					val = self:ReadType(read_type)
					if data.swap_endianess then

						local size = 16
						if read_type:find("32", nil, true) or read_type:find("long", nil, true) then
							size = 32 -- asdasdasd
						end
						val = swap_endian(val, size)
					end
				end
			end

			if data.assert then
				if val ~= data.assert then
					errorf("error in header: %s %s expected %s got %s", 2, data[1], data[2], data.assert, (type(val) == "number" and ("%X"):format(val) or val))
				end
			end

			if data.translate then
				val = data.translate[val] or val
			end

			if not data.padding then
				if val == nil then val = "nil" end
				local key = data[2]

				if ordered then
					table.insert(out, {key = key, val = val})
				else
					if out[key] then
						key = key .. i
					end

					out[key] = val
				end
			end

			if type(data[3]) == "table" then
				local tbl = {}

				if ordered then
					table.insert(out, {key = data[2], val = tbl})
				else
					out[data[2]] = tbl
				end

				for _ = 1, val do
					table.insert(tbl, self:ReadStructure(data[3], ordered))
				end
			end

			if data.switch then
				for k, v in pairs(self:ReadStructure(data.switch[val], ordered)) do
					if ordered then
						table.insert(out, {key = k, val = v})
					else
						out[k] = v
					end
				end
			end

			::continue_::
		end

		return out
	end

	function META:GetStructureSize(structure)
		if type(structure) == "string" then
			return self:GetStructureSize(header_to_table(structure))
		end

		local size = 0

		for _, v in ipairs(structure) do
			local t = v[1]

			if t == "longlong" then t = "long long" end
			if t == "byte" then t = "uint8_t" end

			if structs.GetStructMeta(t) then
				size = size + structs.GetStructMeta(t).byte_size
			elseif ffi then
				size = size + ffi.sizeof(t)
			end
		end

		return size
	end
end


do -- automatic

	function META:GenerateTypes()
		local read_functions = {}
		local write_functions = {}

		for k, v in pairs(META) do
			if type(k) == "string" then
				local key = k:match("Read(.+)")
				if key then
					read_functions[key:lower()] = v

					if key:find("Unsigned") then
						key = key:gsub("(Unsigned)(.+)", "%1 %2")
						read_functions[key:lower()] = v
					end
				end

				key = k:match("Write(.+)")
				if key then
					write_functions[key:lower()] = v

					if key:find("Unsigned") then
						key = key:gsub("(Unsigned)(.+)", "%1 %2")
						write_functions[key:lower()] = v
					end
				end
			end
		end

		META.read_functions = read_functions
		META.write_functions = write_functions

		local ids = {}

		for k in pairs(read_functions) do
			table.insert(ids, k)
		end

		table.sort(ids, function(a, b) return a > b end)

		META.type_ids = ids
	end

	META:GenerateTypes()

	function META:WriteType(val, t, type_func)
		t = t or type(val)

		if META.write_functions[t] then
			if t == "table" then
				return META.write_functions[t](self, val, type_func)
			else
				return META.write_functions[t](self, val)
			end
		end

		error("tried to write unknown type " .. t, 2)
	end

	function META:ReadType(t, signed)

		if META.read_functions[t] then
			return META.read_functions[t](self, signed)
		end

		error("tried to read unknown type " .. t, 2)
	end

	function META:GetTypeID(val)
		for k,v in ipairs(META.type_ids) do
			if v == val then
				return k
			end
		end
	end

	function META:GetTypeFromID(id)
		return META.type_ids[id]
	end
end

do -- push pop position
	function META:PushPosition(pos)
		if pos >= self:GetSize() then error("position pushed is larger than reported size of buffer", 2) end
		self.push_pop_pos_stack = self.push_pop_pos_stack or {}

		table.insert(self.push_pop_pos_stack, self:GetPosition())

		self:SetPosition(pos)
	end

	function META:PopPosition()
		self:SetPosition(table.remove(self.push_pop_pos_stack))
	end
end

function META:ReadBytesUntil(what)
	local pos = self:FindString(what)

	if pos then
		local str = self:ReadBytes(pos - self:GetPosition())
		self:Advance(#what)
		return str
	end

	return false
end

function META:RemainingSize()
	return self:GetSize() - self:GetPosition()
end

function META:FindString(str)
	local old_pos = self:GetPosition()

	for i = 1, self:GetSize() do
		local chr = self:ReadChar()

		if chr == str:sub(1, 1) then
			for i = 2, #str do
				if self:ReadChar() == str:sub(i, i) then
					local pos = self:GetPosition() - #str
					self:SetPosition(old_pos)
					return pos
				end
			end
		end
	end

	self:SetPosition(old_pos)

	return false
end

function META:TheEnd()
	return self:GetPosition() >= self:GetSize()
end

function META:PeakByte()
	return self:ReadByte(), self:Advance(-1)
end

function META:PeakBytes(len)
	return self:ReadBytes(len), self:Advance(-len)
end

function META:Advance(i)
	i = i or 1
	local pos = self:GetPosition() + i
	self:SetPosition(pos)
	return pos
end

META.__len = META.GetSize

function META:GetDebugString()
	self:PushPosition(1)
		local str = self:GetString():readablehex()
	self:PopPosition()
	return str
end

do -- read bits
	function META:RestartReadBits()
		self.buf_byte = 0
		self.buf_nbit = 0
	end

	function META:BitsLeftInByte()
		return self.buf_nbit
	end

	function META:ReadBits(nbits)
		if nbits == 0 then return 0 end

		for i = 0, nbits, 8 do
			if self.buf_nbit >= nbits then break end

			self.buf_byte = self.buf_byte + bit.lshift(self:ReadByte(), self.buf_nbit)
			self.buf_nbit = self.buf_nbit + 8
		end

		self.buf_nbit = self.buf_nbit - nbits

		local bits
		if nbits == 32 then
			bits = self.buf_byte
			self.buf_byte = 0
		else
			bits = bit.band(self.buf_byte, bit.rshift(0xffffffff, 32 - nbits))
			self.buf_byte = bit.rshift(self.buf_byte, nbits)
		end

		return bits
	end
end