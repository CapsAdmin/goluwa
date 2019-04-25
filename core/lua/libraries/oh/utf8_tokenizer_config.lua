local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift
local math_floor = math.floor
local string_char = string.char
local table_concat = table.concat
local UTF8_ACCEPT = 0
local UTF8_REJECT = 12

local utf8d = ffi.new("const uint8_t[364]", {
	-- The first part of the table maps bytes to character classes that
	-- to reduce the size of the transition table and create bitmasks.
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
	7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
	8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	10,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3, 11,6,6,6,5,8,8,8,8,8,8,8,8,8,8,8,

	-- The second part is a transition table that maps a combination
	-- of a state of the automaton and a character class to a state.
	0,12,24,36,60,96,84,12,12,12,48,72, 12,12,12,12,12,12,12,12,12,12,12,12,
	12, 0,12,12,12,12,12, 0,12, 0,12,12, 12,24,12,12,12,12,12,24,12,24,12,12,
	12,12,12,12,12,12,12,24,12,12,12,12, 12,24,12,12,12,12,12,12,12,24,12,12,
	12,12,12,12,12,12,12,36,12,36,12,12, 12,36,12,12,12,12,12,36,12,36,12,12,
	12,36,12,12,12,12,12,12,12,12,12,12,
})

local function totable(str)
	local state = UTF8_ACCEPT
	local codepoint = 0;
	local offset = 0;
	local ptr = ffi.cast("uint8_t *", str)

	local out = {}
	local out_i = 1

	for i = 0, #str - 1 do
		local byte = ptr[i]
		local ctype = utf8d[byte]

		if state ~= UTF8_ACCEPT then
			codepoint = bor(band(byte, 0x3f), lshift(codepoint, 6))
		else
			codepoint = band(rshift(0xff, ctype), byte)
		end

		state = utf8d[256 + state + ctype]

		if state == UTF8_ACCEPT then
			if codepoint > 0xffff then
				codepoint = lshift(((0xD7C0 + rshift(codepoint, 10)) - 0xD7C0), 10) +
				(0xDC00 + band(codepoint, 0x3ff)) - 0xDC00
			end

			if codepoint <= 127 then
				out[out_i] = string_char(codepoint)
			elseif codepoint < 2048 then
				out[out_i] = string_char(
					192 + math_floor(codepoint / 64),
					128 + (codepoint % 64)
				)
			elseif codepoint < 65536 then
				out[out_i] = string_char(
					224 + math_floor(codepoint / 4096),
					128 + (math_floor(codepoint / 64) % 64),
					128 + (codepoint % 64)
				)
			elseif codepoint < 2097152 then
				out[out_i] = string_char(
					240 + math_floor(codepoint / 262144),
					128 + (math_floor(codepoint / 4096) % 64),
					128 + (math_floor(codepoint / 64) % 64),
					128 + (codepoint % 64)
				)
			else
				out[out_i] = ""
			end

			out_i = out_i + 1
		end
	end
	return out
end

local config = {}

-- This is needed for UTF8. Assume everything is a letter if it's not any of the other types.
config.FallbackCharacterType = "letter" 

function config.OnInitialize(tk, str, on_error)
	tk.code = totable(str)
	tk.code_length = #tk.code
	tk.tbl_cache = {}
end
function config.GetLength(tk)
	return tk.code_length
end
function config.GetCharOffset(tk, i)
	return tk.code[tk.i + i] or ""
end
function config.GetCharsRange(tk, start, stop)
	local length = stop-start
	if not tk.tbl_cache[length] then
		tk.tbl_cache[length] = {}
	end
	local str = tk.tbl_cache[length]

	local str_i = 1
	for i = start, stop do
		str[str_i] = tk.code[i]
		str_i = str_i + 1
	end
	return table_concat(str)
end

return config