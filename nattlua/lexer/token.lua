local table_pool = require("nattlua.other.table_pool")
local quote_helper = require("nattlua.other.quote")
local class = require("nattlua.other.class")
local META = class.CreateTemplate("token")
local setmetatable = _G.setmetatable
--[[#type META.@Name = "Token"]]
--[[#type META.TokenWhitespaceType = "line_comment" | "multiline_comment" | "comment_escape" | "space"]]
--[[#type META.TokenType = "analyzer_debug_code" | "parser_debug_code" | "letter" | "string" | "number" | "symbol" | "end_of_file" | "shebang" | "discard" | "unknown" | META.TokenWhitespaceType]]
--[[#type META.@Self = {
	@Name = "Token",
	type = META.TokenType,
	value = string,
	start = number,
	stop = number,
	is_whitespace = boolean | nil,
	string_value = nil | string,
	inferred_type = nil | any,
	inferred_types = nil | List<|any|>,
	parent = nil | any,
	whitespace = false | nil | List<|CurrentType<|"table", 1|>|>,
}]]
--[[#type META.Token = META.@Self]]

function META:GetRoot()
	if self.parent then
		return (self.parent --[[#as any]]):GetRoot()
	end

	return self
end

function META:__tostring()
	return "[token - " .. self.type .. " - " .. quote_helper.QuoteToken(self.value) .. "]"
end

function META:AddType(obj)
	self.inferred_types = self.inferred_types or {}
	table.insert(self.inferred_types, obj)
end

function META:GetTypes()
	return self.inferred_types or {}
end

function META:GetLastType()
	return self.inferred_types and self.inferred_types[#self.inferred_types]
end

local new_token = table_pool(
	function()
		local x = {
			type = "unknown",
			value = "",
			whitespace = false,
			start = 0,
			stop = 0,
		}--[[# as META.@Self]]
		return x
	end,
	3105585
)

function META.New(
	type--[[#: META.TokenType]],
	is_whitespace--[[#: boolean]],
	start--[[#: number]],
	stop--[[#: number]]
)--[[#: META.@Self]]
	local tk = new_token()
	tk.type = type
	tk.is_whitespace = is_whitespace
	tk.start = start
	tk.stop = stop
	setmetatable(tk, META)
	return tk
end

return META
