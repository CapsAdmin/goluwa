local characters = {}
local B = string.byte

function characters.IsNumber(c--[[#: number]])--[[#: boolean]]
	return (c >= B("0") and c <= B("9"))
end

function characters.IsLetter(c--[[#: ref number]])--[[#: ref boolean]]
	return (
			c >= B("a") and
			c <= B("z")
		)
		or
		(
			c >= B("A") and
			c <= B("Z")
		)
		or
		(
			c == B("_") or
			c == B("@")
			or
			c >= 127
		)
end

function characters.IsDuringLetter(c--[[#: number]])--[[#: boolean]]
	return characters.IsLetter(c) or characters.IsNumber(c)
end

function characters.IsSpace(c--[[#: number]])--[[#: boolean]]
	return c > 0 and c <= 32
end

function characters.IsSymbol(c--[[#: number]])--[[#: boolean]]
	return c ~= B("_") and
		(
			(
				c >= B("!") and
				c <= B("/")
			)
			or
			(
				c >= B(":") and
				c <= B("?")
			)
			or
			(
				c >= B("[") and
				c <= B("`")
			)
			or
			(
				c >= B("{") and
				c <= B("~")
			)
		)
end

function characters.IsHex(c--[[#: number]])--[[#: boolean]]
	return characters.IsNumber(c) or
		(
			c >= B("a") and
			c <= B("f")
		)
		or
		(
			c >= B("A") and
			c <= B("F")
		)
end

if jit then
	local ffi = require("ffi")

	for key, val in pairs(characters) do
		local map = ffi.new("char[256]")

		for i = 0, 255 do
			map[i] = val(i) and 1 or 0
		end

		characters[key] = function(c--[[#: number]])--[[#: boolean]]
			return map[c] ~= 0
		end
	end
end

return characters
