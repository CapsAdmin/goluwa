
do
	local lookup = {
		{from = "\a", to = [[\a]]},
		{from = "\b", to = [[\b]]},
		{from = "\f", to = [[\f]]},
		{from = "\n", to = [[\n]]},
		{from = "\r", to = [[\r]]},
		{from = "\t", to = [[\t]]},
		{from = "\v", to = [[\v]]},
		{from = "\\", to = [[\]]},
	}

	function string.escape(str)
		for _, char in ipairs(lookup) do
			str = str:gsub(char.from, char.to)
		end
		return str
	end
end

function string.indent(str, count)
	local tbl = str:split("\n")
	for i, line in ipairs(tbl) do
		tbl[i] = ("\t"):rep(count) .. line
	end
	return table.concat(tbl, "\n")
end

function string.buildclass(...)
	local classes = {...}
	local check

	if type(classes[#classes]) == "function" then
		check = table.remove(classes, #classes)
	end

	local out = ""

	for i = 0, 255 do
		for _, class in ipairs(classes) do
			local char = string.char(i)
			if char:find(class) and (not check or check(char) ~= false) then
				out = out .. char
			end
		end
	end

	return out
end

function string.iswhitespace(char)
	return
		char == "\32" or
		char == "\9" or
		char == "\10" or
		char == "\11" or
		char == "\12"
end

function string.haswhitespace(str)
	for i = 1, #str do
		local b = str:byte(i)
		if b == 32 or (b >= 9 and b <= 12) then
			return true
		end
	end
end


function string.upperchar(self, pos)
	return self:sub(0, pos-1) .. self:sub(pos, pos):upper() .. self:sub(pos + 1)
end

function string.wholeword(self, what)
	return self:find("%f[%a%d_]"..what.."%f[^%a%d_]") ~= nil
end

function string.slice(self, what, from, offset)
	offset = offset or 0
	local _, pos = self:find(what, from, true)

	if pos then
		return self:sub(0, pos - offset), self:sub(pos + offset)
	end
end

do
	local vowels = {"e", "a", "o", "i", "u", "y"}
	local consonants = {"t", "n", "s", "h", "r", "d", "l", "c", "m", "w", "f", "g", "p", "b", "v", "k", "j", "x", "q", "z"}
	local first_letters = {"t", "a", "s", "h", "w", "i", "o", "b", "m", "f", "c", "l", "d", "p", "n", "e", "g", "r", "y", "u", "v", "j", "k", "q", "z", "x"}

	function string.randomwords(word_count, seed)
		word_count = word_count or 8
		seed = seed or 0

		local text = {}

		local last_punctation = 1
		local capitalize = true

		for i = 1, word_count do
			math.randomseed(seed + i)
			local word = ""

			local consonant_start = 1

			local length = math.ceil((math.random()^3)*8) + math.random(2, 3)

			for i = 1, length do
				if i == 1 then
					word = word .. first_letters[math.floor((math.random()^3) * #first_letters) + 1]
					if table.hasvalue(vowels, word[i]) then
						consonant_start = 0
					end
				elseif i%2 == consonant_start then
					word = word .. consonants[math.floor((math.random()^4) * #consonants) + 1]
				else
					if i ~= length or math.random() < 0.25 then
						word = word .. vowels[math.floor((math.random()^3) * #vowels) + 1]
					end
				end

				if capitalize then
					word = word:upper()
					capitalize =  false
				end
			end

			text[i] = word

			last_punctation = last_punctation + 1

			if last_punctation > math.random(4,16) then
				if math.random() > 0.9 then
					text[i] = text[i] .. ","
				else
					text[i] = text[i] .. "."
					capitalize = true
				end
				last_punctation = 1
			end

			text[i] = text[i]  .. " "
		end

		return table.concat(text)
	end
end

function string.random(length, min, max)
	length = length or 10
	min = min or 32
	max = max or 126

	local tbl = {}

	for i = 1, length do
		tbl[i] = string.char(math.random(min, max))
	end

	return table.concat(tbl)
end

-- gsub doesn't seem to remove \0

function string.removepadding(str, padding)
	padding = padding or "\0"

	local new = {}

	for i = 1, #str do
		local char = str:sub(i, i)
		if char ~= padding then
			table.insert(new, char)
		end
	end

	return table.concat(new)
end

function string.readablehex(str)
	return (str:gsub("(.)", function(str) str = ("%X"):format(str:byte()) if #str == 1 then str = "0" .. str end return str .. " " end))
end

function string.readablebinary(str)
	return (str:gsub("(.)", function(str)
		local byte = str:byte()
		if byte >= 27 and byte <= 126 then
			str = " " .. str
		elseif str == "\r" then
			str = "\\r"
		elseif str == "\n" then
			str = "\\n"
		else
			str = "\\" .. byte
		end
		return str
	 end))
end

function string.hexformat(str, chunk_width, row_width, space_separator)
	row_width = row_width or 4
	chunk_width = chunk_width or 4
	space_separator = space_separator or " "

	local str = str:readablehex():lower():split(" ")
	local out = {}

	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do
		table.insert(out, char)
		table.insert(out, " ")

		if row_i >= (row_width * chunk_width) then
			table.insert(out, "\n")
			chunk_i = 0
			row_i = 0
		end

		if chunk_i >= chunk_width then
			table.insert(out, space_separator)
			chunk_i = 0
		end

		row_i = row_i + 1
		chunk_i = chunk_i + 1
	end

	return table.concat(out):trim()
end

function string.binformat(str, row_width, space_separator, with_hex, format)
	row_width = row_width or 8
	space_separator = space_separator or " "

	local str = str:totable()
	local out = {}

	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do

		local bin = utility.NumberToBinary(char:byte(), 8)
		if with_hex then
			table.insert(out, ("%02X/"):format(char:byte()))
		end

		if format then
			local str = ""
			local bin = bin:totable()


			local offset = 1
			for _, num in ipairs(format:totable()) do
				num = tonumber(num)
				table.insert(bin, num + offset, "-")
				offset = offset + 1
			end

			table.insert(out, table.concat(bin))
		else
			table.insert(out, bin)
		end
		table.insert(out, space_separator)

		if row_i >= row_width then
			table.insert(out, "\n")
			row_i = 0
		end

		row_i = row_i + 1
	end

	return table.concat(out):trim()
end

function string.octformat(str, row_width, space_separator, with_hex)
	row_width = row_width or 8
	space_separator = space_separator or " "

	local str = str:totable()
	local out = {}

	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do

		local bin = string.format("%03o", char:byte())

		if with_hex then
			table.insert(out, ("%02X/"):format(char:byte()))
		end

		table.insert(out, bin)--:sub(0, 4) .. "-" .. bin:sub(5, 8))
		table.insert(out, space_separator)

		if row_i >= row_width then
			table.insert(out, "\n")
			row_i = 0
		end

		row_i = row_i + 1
	end

	return table.concat(out):trim()
end

function string.endswith(a, b)
	return a:sub(-#b) == b
end

function string.endswiththese(a, b)
	for _, str in ipairs(b) do
		if a:sub(-#str) == str then
			return true
		end
	end
end

function string.startswith(a, b)
	return a:sub(0, #b) == b
end

function string.levenshtein(a, b)
	local distance = {}

	for i = 0, #a do
	  distance[i] = {}
	  distance[i][0] = i
	end

	for i = 0, #b do
	  distance[0][i] = i
	end

	local str1 = utf8.totable(a)
	local str2 = utf8.totable(b)

	for i = 1, #a do
		for j = 1, #b do
			distance[i][j] = math.min(
				distance[i-1][j] + 1,
				distance[i][j-1] + 1,
				distance[i-1][j-1] + (str1[i-1] == str2[j-1] and 0 or 1)
			)
		end
	end

	return distance[#a][#b]
end

function string.lengthsplit(str, len)
	if #str > len then
		local tbl = {}

		local max = math.floor(#str/len)

		for i = 0, max do

			local left = i * len + 1
			local right = (i * len) + len
			local res = str:sub(left, right)

			if res ~= "" then
				table.insert(tbl, res)
			end
		end

		return tbl
	end

	return {str}
end

function string.getchartype(char)

	if char:find("%p") and char ~= "_" then
		return "punctation"
	elseif char:find("%s") then
		return "space"
	elseif char:find("%d") then
		return "digit"
	elseif char:find("%a") or char == "_" then
		return "letters"
	end

	return "unknown"
end

local types = {
	"%a",
	"%c",
	"%d",
	"%l",
	"%p",
	"%u",
	"%w",
	"%x",
	"%z",
}

function string.charclass(char)
	for _, v in ipairs(types) do
		if char:find(v) then
			return v
		end
	end
end

function string.safeformat(str, ...)
	str = str:gsub("%%(%d+)", "%%s")
	local count = select(2, str:gsub("(%%)", ""))

	if str:find("%...", nil, true) then
		local temp = {}

		for i = count, select("#", ...) do
			table.insert(temp, tostringx(select(i, ...)))
		end
		str = str:replace("%...", table.concat(temp, ", "))

		count = count - 1
	end

	if count == 0 then
		return table.concat({str, ...}, "")
	end

	local copy = {}
	for i = 1, count do
		table.insert(copy, tostringx(select(i, ...)))
	end
	return string.format(str, unpack(copy))
end

function string.findsimple(self, find)
	return self:find(find, nil, true) ~= nil
end

function string.findsimplelower(self, find)
	return self:lower():find(find:lower(), nil, true) ~= nil
end

function string.compare(self, target)
	return
		self == target or
		self:findsimple(target) or
		self:lower() == target:lower() or
		self:findsimplelower(target)
end

function string.trim(self, char)
	if char then
		char = char:patternsafe() .. "*"
	else
		char = "%s*"
	end

	local _, start = self:find(char, 0)
	local end_start, end_stop = self:reverse():find(char, 0)

	if start and end_start then
		return self:sub(start + 1, (end_start - end_stop) - 2)
	elseif start then
		return self:sub(start + 1)
	elseif end_start then
		return self:sub(0, (end_start - end_stop) - 2)
	end

	return self
end

function string.getchar(self, pos)
	return string.sub(self, pos, pos)
end

function string.getbyte(self, pos)
	return self:getchar(pos):byte() or 0
end

function string.totable(self)
	local tbl = table.new(#self, 0)
	for i = 1, #self do
		tbl[i] = self:sub(i, i)
	end
	return tbl
end

function string.split(self, separator, plain_search)
	if separator == nil or separator == "" then
		return self:totable()
	end

	if plain_search == nil then
		plain_search = true
	end

	local tbl = {}
	local current_pos = 1

	for i = 1, #self do
		local start_pos, end_pos = self:find(separator, current_pos, plain_search)
		if not start_pos then break end
		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	if current_pos > 1 then
		tbl[#tbl + 1] = self:sub(current_pos)
	else
		tbl[1] = self
	end

	return tbl
end

function string.count(self, what, plain)
	if plain == nil then plain = true end

	local count = 0
	local current_pos = 1

	for _ = 1, #self do
		local start_pos, end_pos = self:find(what, current_pos, plain)
		if not start_pos then break end
		count = count + 1
		current_pos = end_pos + 1
	end
	return count
end

function string.containsonly(self, pattern)
	return self:gsub(pattern, "") == ""
end

function string.replace(self, what, with)
	local tbl = {}
	local current_pos = 1
	local last_i

	for i = 1, #self do
		local start_pos, end_pos = self:find(what, current_pos, true)
		if not start_pos then last_i = i break end
		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	if current_pos > 1 and last_i then
		tbl[last_i] = self:sub(current_pos)

		return table.concat(tbl, with)
	end

	return self
end

local pattern_escape_replacements = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z"
}

function string.escapepattern(str)
	return (str:gsub(".", pattern_escape_replacements))
end

function string.getchar(self, pos)
	return self:sub(pos, pos)
end

if desire("ffi") then
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

    function string.utf8totable(str)
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
end