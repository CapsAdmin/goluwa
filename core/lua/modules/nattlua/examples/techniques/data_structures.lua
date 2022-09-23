local ffi = require("ffi")
ffi.cdef([[
    void *realloc(void *, size_t);
    void *malloc(size_t);
    void free(void *);
]])
local s8 = ffi.typeof("int8_t")
local u8 = ffi.typeof("uint8_t")
local s16 = ffi.typeof("int16_t")
local u16 = ffi.typeof("uint16_t")
local s32 = ffi.typeof("int32_t")
local u32 = ffi.typeof("uint32_t")
local s64 = ffi.typeof("int64_t")
local u64 = ffi.typeof("uint64_t")
local f32 = ffi.typeof("float")
local f64 = ffi.typeof("double")
local ssize = ffi.typeof("intptr_t")
local usize = ffi.typeof("uintptr_t")

local function cast32(ptr)
	return ffi.cast("uint32_t*", ptr)[0]
end

local function cast16(ptr)
	return ffi.cast("uint16_t*", ptr)[0]
end

local function cast8(ptr)
	return ffi.cast("uint8_t*", ptr)[0]
end

local function address_hash(key)
	return ffi.cast(u64, key)
end

local function meiyan_hash(key)
	local count = u64(#key)
	local h = u64(0x811c9dc5)
	key = ffi.cast("const char *", key)

	while count >= 8 do
		h = bit.bxor(
				h,
				bit.bxor(bit.bor(bit.lshift(cast32(key), 5), bit.rshift(cast32(key), 27)), cast32(key + 4))
			) * 0xad3e7
		count = count - 8
		key = key + 8
	end

	if bit.band(count, 4) ~= 0 then
		h = bit.bxor(h, cast16(key)) * 0xad3e7
		key = key + 2
		h = bit.bxor(h, cast16(key)) * 0xad3e7
		key = key + 2
	end

	if bit.band(count, 2) ~= 0 then
		h = bit.bxor(h, cast16(key)) * 0xad3e7
		key = key + 2
	end

	if bit.band(count, 1) ~= 0 then h = bit.bxor(h, cast8(key)) * 0xad3e7 end

	local b = bit.rshift(ffi.cast("uint32_t", h), 16)
	h = bit.bxor(h, b)
	h = ffi.cast("uint32_t", h)
	return tonumber(h)
end

function Struct(tbl)
	local members = {}
	local ctypes = {}

	for i, val in ipairs(tbl) do
		local key = val[1]
		local type = val[2]

		if _G.type(type) == "string" then type = ffi.typeof(type) end

		members[i] = string.format("$ %s;", key)
		ctypes[i] = type
	end

	return ffi.typeof("struct{" .. table.concat(members, "") .. "}", unpack(ctypes))
end

local function Pointer(val)
	return ffi.typeof("$ *", val)
end

function StaticArrayType(T, length)
	local element_size = ffi.sizeof(T)
	local ctype = ffi.typeof("struct { $ items[$]; }", T, length)
	local META = {}
	META.__index = META

	local function check_bounds(self, i)
		if i < 0 or i >= length then
			error("index " .. i .. " is out of bounds", 3)
		end
	end

	function META:Set(i, val)
		check_bounds(self, i)
		self.items[i] = val
	end

	function META:Get(i)
		check_bounds(self, i)
		return self.items[i]
	end

	function META:__len()
		return tonumber(length)
	end

	ffi.metatype(ctype, META)
	return ctype
end

function ArrayType(T)
	local element_size = ffi.sizeof(T)
	local ctype = ffi.typeof("struct { $ len; $ * items;}", u32, T)
	local META = {}
	META.__index = META

	local function check_bounds(self, i)
		if i < 0 or i >= self.len then
			error("index " .. i .. " is out of bounds", 3)
		end
	end

	function META:Set(i, val)
		check_bounds(self, i)
		self.items[i] = val
	end

	function META:Get(i)
		check_bounds(self, i)
		return self.items[i]
	end

	function META:__len()
		return tonumber(self.len)
	end

	function META:SliceView(start, stop)
		local arr = ctype()
		arr.len = (stop - start) + 1
		arr.items = self.items + start
		return arr
	end

	function META:Slice(start, stop)
		local arr = ctype()
		arr.len = (stop - start) + 1
		arr.items = ffi.C.malloc(element_size * arr.len)
		ffi.copy(arr.items, self.items + start, element_size * arr.len)
		return arr
	end

	ffi.metatype(ctype, META)
	return function(length)
		return ctype(length, ffi.C.malloc(element_size * length))
	end,
	ctype
end

do
	local Uint32Array = ArrayType(u32)
	local arr = Uint32Array(10)
	assert(#arr == 10)

	for i = 0, 9 do
		arr:Set(i, 1337)
	end

	for i = 0, 9 do
		assert(arr:Get(i) == 1337)
	end

	arr:Set(5, 777)
	assert(#arr == 10)
	assert(arr:Get(5) == 777)
	local ok, err = pcall(function()
		arr:Set(11, 5)
	end)
	assert(ok == false)
	assert(err:find("out of bounds") ~= nil)
	local ok, err = pcall(function()
		arr:Set(-1, 5)
	end)
	assert(ok == false)
	assert(err:find("out of bounds") ~= nil)
	arr:Set(5, 1)
	arr:Set(6, 2)
	arr:Set(7, 3)
	local view_slice = arr:SliceView(5, 7)
	assert(view_slice:Get(0) == 1)
	assert(view_slice:Get(1) == 2)
	assert(view_slice:Get(2) == 3)
	view_slice:Set(1, 666)
	assert(view_slice:Get(1) == 666)
	assert(arr:Get(6) == 666)
	local slice = arr:Slice(5, 7)
	assert(slice:Get(0) == 1)
	assert(slice:Get(1) == 666)
	assert(slice:Get(2) == 3)
	slice:Set(1, 2)
	assert(slice:Get(1) == 2)
	assert(view_slice:Get(1) == 666)
	local UInt8Array10 = StaticArrayType(u8, 10)
	local arr = UInt8Array10()
	assert(#arr == 10)
	arr:Set(5, 44)
	assert(arr:Get(5) == 44)
end

function DynamicArrayType(T)
	local ctype = ffi.typeof("struct { $ pos; $ len; $ * items; }", u32, u32, T)
	local size = ffi.sizeof(T)
	local META = {}
	META.__index = META

	local function check_bounds(self, i)
		if i < 0 then error("index " .. i .. " is out of bounds") end
	end

	function META:Initialize(len, T)
		self.pos = 0
		self.len = 0
		self:Grow()
	end

	function META:Push(val)
		check_bounds(self, self.pos)

		while self.pos >= self.len do
			self:Grow()
		end

		self.items[self.pos] = val
		self.pos = self.pos + 1
	end

	function META:Set(i, val)
		if i > 0 then while i >= self.len do
			self:Grow()
		end end

		check_bounds(self, i)
		self.items[i] = val
	end

	function META:Get(i)
		check_bounds(self, i)
		return self.items[i]
	end

	function META:__len()
		return tonumber(self.pos)
	end

	function META:Grow()
		self.len = self.len + 32

		if self.items == nil then
			self.items = ffi.C.malloc(size * self.len)
		else
			self.items = ffi.C.realloc(self.items, size * self.len)
		end

		if self.items == nil then error("realloc failed") end
	end

	ffi.metatype(ctype, META)
	return function(len)
		local self = ctype()
		self:Initialize(len, T)
		return self
	end,
	ctype
end

do
	local Uint32Array = DynamicArrayType(u32)
	local arr = Uint32Array()
	assert(#arr == 0)

	for i = 0, 9 do
		arr:Push(10 + i)
		assert(#arr == i + 1)
	end

	for i = 0, 9 do
		assert(arr:Get(i) == 10 + i)
	end

	arr:Set(5, 777)
	assert(#arr == 10)
	assert(arr:Get(5) == 777)
	arr:Set(1111, 5)
	assert(arr:Get(1111) == 5)
	assert(arr.len >= 1111)
	local ok, err = pcall(function()
		arr:Set(-1111, 5)
	end)
	assert(ok == false)
	assert(err:find("out of bounds") ~= nil)
end

function HashTableType(key_type, val_type)
	local KeyVal = Struct({
		{"key", key_type},
		{"val", val_type},
	})
	local KeyValArray, TKeyValArray = DynamicArrayType(KeyVal)
	local Array, TArray = ArrayType(TKeyValArray)
	local ctype = ffi.typeof("struct { $ array; }", TArray)
	local META = {}
	META.__index = META

	function META:Hash(key)
		--return address_hash(key)
		return meiyan_hash(key)
	end

	function META:Set(key, val)
		local hash = self:Hash(key)

		
		local index = hash % #self.array
		local keyval_array = self.array:Get(index)

		if keyval_array == nil then
			keyval_array = KeyValArray()
			self.array:Set(index, keyval_array)
		end

		local keyval = KeyVal()
		keyval.key = key
		keyval.val = val
		keyval_array:Push(keyval)
	end

	function META:GetBucket(key)
		local hash = self:Hash(key)
		local index = hash % #self.array
		return self.array:Get(index)
	end

	function META:Get(key)
		local arr = self:GetBucket(key)

		for i = 0, #arr - 1 do
			local keyval = arr:Get(i)

			if keyval.key == key then return keyval.val end
		end

		return nil
	end

	function META:GetCollisionRate()
		local count = 0
		local total = 0

		for i = 0, #self.array - 1 do
			local arr = self.array:Get(i)

			if arr:Get(0) ~= nil then
				count = count + tonumber(#arr)
				total = total + 1
			end
		end

		return count / total
	end

	ffi.metatype(ctype, META)
	return function(len)
		local self = ctype()
		self.array = Array(len or 1000)
		return self
	end,
	ctype
end

do
	local META = {}
	META.__index = META

	function META:Set(key, val)
		self.table[key] = val
	end

	function META:Get(key)
		return self.table[key]
	end

	function META:GetCollisionRate()
		return 0
	end

	function LuaTable()
		local self = setmetatable({table = {}}, META)
		return self
	end
end

do
	math.randomseed(0)
	local keys = {}
	local done = {}

	for i = 1, 10000 do
		local str = {}

		for i = 1, math.random(1, 30) do
			str[i] = string.char(math.random(32, 128))
		end

		str = table.concat(str)

		if not done[str] then
			table.insert(keys, str)
			done[str] = true
		end
	end

	local function key()
		return keys[math.random(1, #keys)]
	end

	local UInt32HashMap = HashTableType("const char *", f64)
	local map = UInt32HashMap()
	--map = LuaTable()
	local MAX = 100000
	local time = os.clock()

	for i = 1, MAX do
		local val = i
		local key = keys[(i % #keys) + 1] .. "-" .. i
		map:Set(key, val)

		if map:Get(key) ~= val then
			print("BUCKET: ")
			local arr = map:GetBucket(key)

			for i = 0, #arr - 1 do
				print(
					"[" .. i .. "] " .. ffi.string(arr:Get(i).key) .. " = " .. tostring(arr:Get(i).val)
				)
			end

			error("key " .. key .. " = " .. tostring(map:Get(key)) .. " does not equal " .. val)
		end
	end

	print(os.clock() - time .. " seconds")
	print(map:GetCollisionRate())
end

do
	return
end

local MyStruct = Struct({
	{"index", u32},
	{"counter", u32},
})
local len = 1000000
local MyArray = DynamicArrayType(MyStruct)
local arr = MyArray()
local time = os.clock()

for i = 1, len do
	local t = MyStruct()
	t.index = 1337 + i
	t.counter = i - 1
	arr:Push(t)
end

print(os.clock() - time)
print(arr:Get(333).index)
print(arr:Get(333).counter)
