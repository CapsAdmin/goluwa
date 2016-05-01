local META = ...

local ffi = require("ffi")

-- <cmtptr> CapsAdmin, http://codepad.org/uN7qlQTm
local function swap_endian(num, size)
	local result = 0
	for shift = 0, size - 8, 8 do
		result = bit.bor(bit.lshift(result, 8),
				bit.band(bit.rshift(num, shift), 0xff))
	end
	return result
end

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

local function ADD_FFI_OPTIMIZED_TYPES(META)
	for name, type in pairs(type_info) do
		type = ffi.typeof(type)
		local size = ffi.sizeof(type)

		local ctype = ffi.typeof("$*", type)
		META["Read" .. name] = function(self)
			return ffi.cast(ctype, self:ReadBytes(size))[0]
		end

		local ctype = ffi.typeof("$[1]", type)
		local hmm = ffi.new(ctype, 0)
		META["Write" .. name] = function(self, num)
			hmm[0] = num
			self:WriteBytes(ffi.string(hmm, size))
			return self
		end
	end
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

check(META.WriteByte, "function")
check(META.ReadByte, "function")

do -- basic data types

	-- see the top of the script
	ADD_FFI_OPTIMIZED_TYPES(META)

	function META:WriteBytes(str)
		for i = 1, #str do
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

	function META:ReadString(length, advance)

		if length and not advance then
			return self:ReadBytes(length)
		end

		local str = {}

		local pos = self:GetPosition()

		for _ = 1, length or self:GetSize() do
			local byte = self:ReadByte()
			if not byte or byte == 0 then break end
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

	local cache = utility.CreateWeakTable()

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
					goto continue
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

			::continue::
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

			if t == "vec3" or t == "ang3" then
				size = size + ffi.sizeof("float") * 3
			else
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

		for k, v in pairs(self) do
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

		self.read_functions = read_functions
		self.write_functions = write_functions

		local ids = {}

		for k in pairs(read_functions) do
			table.insert(ids, k)
		end

		table.sort(ids, function(a, b) return a > b end)

		self.type_ids = ids
	end

	META:GenerateTypes()

	function META:WriteType(val, t, type_func)
		t = t or type(val)

		if self.write_functions[t] then
			if t == "table" then
				return self.write_functions[t](self, val, type_func)
			else
				return self.write_functions[t](self, val)
			end
		end

		error("tried to write unknown type " .. t, 2)
	end

	function META:ReadType(t, signed)

		if self.read_functions[t] then
			return self.read_functions[t](self, signed)
		end

		error("tried to read unknown type " .. t, 2)
	end

	function META:GetTypeID(val)
		for k,v in ipairs(self.type_ids) do
			if v == val then
				return k
			end
		end
	end

	function META:GetTypeFromID(id)
		return self.type_ids[id]
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

function META:TheEnd()
	return self:GetPosition() >= self:GetSize()
end

function META:PeakByte()
	return self:ReadByte(), self:Advance(-1)
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