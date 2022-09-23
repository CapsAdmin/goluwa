--ANALYZE
local map = {
	["a"] = "\a",
	["b"] = "\b",
	["f"] = "\f",
	["n"] = "\n",
	["r"] = "\r",
	["t"] = "\t",
	["v"] = "\v",
	["\\"] = "\\",
	["\""] = "\"",
	["'"] = "'",
}
map["00"] = "\0"
map["0"] = "\0"
map["x00"] = "\0"

for i = 1, 255 do
	local char = string.char(i)
	map[("%i"):format(i)] = char
	map[("x%02x"):format(i)] = char
end

local is_number = {}

for i = 0, 9 do
	is_number[tostring(i)] = true
end

local bytemarkers = {{0x7FF, 192}, {0xFFFF, 224}, {0x1FFFFF, 240}}

local function unicode_escape(decimal--[[#: number]])
	if decimal < 128 then return string.char(decimal) end

	local charbytes = {}

	for bytes, vals in ipairs(bytemarkers) do
		if decimal <= vals[1] then
			for b = bytes + 1, 2, -1 do
				local mod = decimal % 64
				decimal = (decimal - mod) / 64
				charbytes[b] = string.char(128 + mod)
			end

			charbytes[1] = string.char(vals[2] + decimal)

			break
		end
	end

	return table.concat(charbytes)
end

local function reverse_escape_string(str--[[#: string]])
	local pos = 1

	while true do
		local start, stop = str:find("\\", pos, true)

		if not start or not stop then break end

		local len = 2
		local char = str:sub(start + 1, stop + 1)

		if char == "u" then
			if str:sub(start + 2, stop + 2) == "{" then
				local len = 3

				while str:sub(start + len, stop + len) ~= "}" do
					len = len + 1
				end

				local hex = tonumber(str:sub(start + 3, stop + len - 1), 16)

				if hex then
					str = str:sub(1, start - 1) .. unicode_escape(hex) .. str:sub(stop + len + 1)
				end
			end
		else
			-- hex escape is always 3 characters
			if char == "x" then
				len = 4
				char = str:sub(start + 1, stop + len - 1):lower()
			elseif is_number[char] then
				-- byte escape can be between 1 and 3 characters
				len = 2

				if is_number[str:sub(start + 2, stop + 2)] then
					len = 3

					if is_number[str:sub(start + 3, stop + 3)] then len = 4 end
				end

				char = str:sub(start + 1, stop + len - 1)

				-- remove left zero padding
				if #char == 3 and char:sub(1, 1) == "0" then
					char = char:sub(2)

					if #char == 2 and char:sub(1, 1) == "0" then char = char:sub(2) end
				end
			end

			if map[char] then
				str = str:sub(1, start - 1) .. map[char] .. str:sub(stop + len)
			end
		end

		pos = pos + 1
	end

	return str
end

return reverse_escape_string