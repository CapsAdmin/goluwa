local helpers = require("nattlua.other.helpers")
local class = require("nattlua.other.class")
local META = class.CreateTemplate("code")
--[[#type META.@Name = "Code"]]
--[[#type META.@Self = {
	Buffer = string,
	Name = string,
}]]

function META:GetString()
	return self.Buffer
end

function META:GetName()
	return self.Name
end

function META:GetByteSize()
	return #self.Buffer
end

function META:GetStringSlice(start--[[#: number]], stop--[[#: number]])
	return self.Buffer:sub(start, stop)
end

function META:IsStringSlice(start--[[#: number]], stop--[[#: number]], str--[[#: string]])
	return self.Buffer:sub(start, stop) == str
end

function META:GetByte(pos--[[#: number]])
	return self.Buffer:byte(pos) or 0
end

function META:FindNearest(str--[[#: string]], start--[[#: number]])
	local _, pos = self.Buffer:find(str, start, true)

	if not pos then return nil end

	return pos + 1
end

local function remove_bom_header(str--[[#: string]])--[[#: string]]
	if str:sub(1, 2) == "\xFE\xFF" then
		return str:sub(3)
	elseif str:sub(1, 3) == "\xEF\xBB\xBF" then
		return str:sub(4)
	end

	return str
end

local function get_default_name()
	local info = debug.getinfo(3)

	if info then
		local parent_line = info.currentline
		local parent_name = info.source:sub(2)
		return parent_name .. ":" .. parent_line
	end

	return "unknown line : unknown name"
end

function META:BuildSourceCodePointMessage(
	msg--[[#: string]],
	start--[[#: number]],
	stop--[[#: number]],
	size--[[#: number]]
)
	return helpers.BuildSourceCodePointMessage(self:GetString(), self:GetName(), msg, start, stop, size)
end

function META.New(lua_code--[[#: string]], name--[[#: string | nil]])
	local self = setmetatable(
		{
			Buffer = remove_bom_header(lua_code),
			Name = name or get_default_name(),
		},
		META
	)
	return self
end

if jit then
	local ffi = require("ffi")
	ffi.cdef("int memcmp ( const void * ptr1, const void * ptr2, size_t num );")

	function META:IsStringSlice(start--[[#: number]], stop--[[#: number]], str--[[#: string]])
		return (
				ffi.C.memcmp
			--[[# as any]])((ffi.cast("unsigned char*", self.Buffer)--[[# as any]]) - 1 + start, str, #str) == 0
	end

	function META:GetByte(pos--[[#: number]])
		return ffi.cast("unsigned char*", self.Buffer)[pos - 1]
	end
end

--[[#type META.Code = META.@Self]]
return META
