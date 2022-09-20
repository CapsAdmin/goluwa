local ffi = desire("ffi")
local TMPL = prototype.CreateTemplate("array")
TMPL:GetSet("Length", 0)
TMPL:GetSet("Size", 0)
TMPL:GetSet("ArrayType", "uint8_t")
TMPL:EndStorable()
TMPL:GetSet("Pointer", nil)

function TMPL:OnSerialize()
	return {self.ArrayType, self.Size, self.Pointer}
end

function TMPL:OnDeserialize(data)
	self:SetArrayType(data[1])
	self:SetSize(data[2])
	self:SetPointer(data[3])
end

function TMPL:__tostring()
	return ("array[%p][%s][%i]"):format(self.Pointer, self.ArrayType, self:GetLength())
end

function TMPL:__index2(key)
	if type(key) == "number" and key >= 0 and key < self.Size then
		return self.Pointer[key]
	end
end

function TMPL:__newindex(key, val)
	if type(key) == "number" and key >= 0 and key < self.Size then
		self.Pointer[key] = val
	else
		rawset(self, key, val)
	end
end

function TMPL:Copy(array)
	if array then ffi.copy(self.Pointer, array.Pointer, self.Size) end
end

function TMPL:Fill(val)
	ffi.zero(self.Pointer, self.Size, val or 0)
end

TMPL:Register()
local translate = {
	int_8 = "int8_t[?]",
	uint_8 = "uint8_t[?]",
	int_16 = "int16_t[?]",
	uint_16 = "uint16_t[?]",
	int_32 = "int32_t[?]",
	uint_32 = "uint32_t[?]",
	int_64 = "int64_t[?]",
	uint_64 = "uint64_t[?]",
}

function Array(type, length, ptr)
	local self = prototype.CreateObject(TMPL)
	local constructor

	if not translate[type] then
		translate[type] = ffi.typeof("$[?]", ffi.typeof(type))
	end

	constructor = translate[type]
	self:SetArrayType(type)

	if _G.type(ptr) == "cdata" then
		self:SetPointer(ptr)
		self:SetSize(length * ffi.sizeof(ptr[0]))
		self:SetLength(length)
	elseif _G.type(ptr) == "table" then
		self.Pointer = constructor(length, ptr)
		self:SetSize(ffi.sizeof(self.Pointer))
		self:SetLength(length)
	else
		self.Pointer = constructor(length)
		self:SetSize(ffi.sizeof(self.Pointer))
		self:SetLength(length)
	end

	return self
end