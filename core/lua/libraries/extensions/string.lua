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
	count = count or 1
	local tbl = str:split("\n")

	for i, line in ipairs(tbl) do
		tbl[i] = ("\t"):rep(count) .. line
	end

	return list.concat(tbl, "\n")
end

function string.buildclass(...)
	local classes = {...}
	local check

	if type(classes[#classes]) == "function" then
		check = list.remove(classes, #classes)
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

function string.is_whitespace(char)
	return char == "\32" or
		char == "\9" or
		char == "\10" or
		char == "\11" or
		char == "\12"
end

function string.has_whitespace(str)
	for i = 1, #str do
		local b = str:byte(i)

		if b == 32 or (b >= 9 and b <= 12) then return true end
	end
end

function string.whole_word(self, what)
	return self:find("%f[%a%d_]" .. what .. "%f[^%a%d_]") ~= nil
end

function string.slice(self, what, from, offset)
	offset = offset or 0
	local _, pos = self:find(what, from, true)

	if pos then return self:sub(0, pos - offset), self:sub(pos + offset) end
end

do
	local vowels = {"e", "a", "o", "i", "u", "y"}
	local consonants = {
		"t",
		"n",
		"s",
		"h",
		"r",
		"d",
		"l",
		"c",
		"m",
		"w",
		"f",
		"g",
		"p",
		"b",
		"v",
		"k",
		"j",
		"x",
		"q",
		"z",
	}
	local first_letters = {
		"t",
		"a",
		"s",
		"h",
		"w",
		"i",
		"o",
		"b",
		"m",
		"f",
		"c",
		"l",
		"d",
		"p",
		"n",
		"e",
		"g",
		"r",
		"y",
		"u",
		"v",
		"j",
		"k",
		"q",
		"z",
		"x",
	}

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
			local length = math.ceil((math.random() ^ 3) * 8) + math.random(2, 3)

			for i = 1, length do
				if i == 1 then
					word = word .. first_letters[math.floor((math.random() ^ 3) * #first_letters) + 1]

					if table.has_value(vowels, word[i]) then consonant_start = 0 end
				elseif i % 2 == consonant_start then
					word = word .. consonants[math.floor((math.random() ^ 4) * #consonants) + 1]
				else
					if i ~= length or math.random() < 0.25 then
						word = word .. vowels[math.floor((math.random() ^ 3) * #vowels) + 1]
					end
				end

				if capitalize then
					word = word:upper()
					capitalize = false
				end
			end

			text[i] = word
			last_punctation = last_punctation + 1

			if last_punctation > math.random(4, 16) then
				if math.random() > 0.9 then
					text[i] = text[i] .. ","
				else
					text[i] = text[i] .. "."
					capitalize = true
				end

				last_punctation = 1
			end

			text[i] = text[i] .. " "
		end

		return list.concat(text)
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

	return list.concat(tbl)
end

-- gsub doesn't seem to remove \0
function string.remove_padding(str, padding)
	padding = padding or "\0"
	local new = {}

	for i = 1, #str do
		local char = str:sub(i, i)

		if char ~= padding then list.insert(new, char) end
	end

	return list.concat(new)
end

function string.hex(str)
	local copy = {}

	for i = 1, #str do
		copy[i] = ("%x"):format(str:byte(i, i))
	end

	return list.concat(copy)
end

function string.readable_hex(str)
	return (
		str:gsub("(.)", function(str)
			str = ("%X"):format(str:byte())

			if #str == 1 then str = "0" .. str end

			return str .. " "
		end)
	)
end

do
	local map = {
		[0] = {"NUL", "␀", "^@", "\\0", "Null character"},
		[1] = {"SOH", "␁", "^A", "", "Start of Header"},
		[2] = {"STX", "␂", "^B", "", "Start of Text"},
		[3] = {"ETX", "␃", "^C", "", "End of Text"},
		[4] = {"EOT", "␄", "^D", "", "End of Transmission"},
		[5] = {"ENQ", "␅", "^E", "", "Enquiry"},
		[6] = {"ACK", "␆", "^F", "", "Acknowledgment"},
		[7] = {"BEL", "␇", "^G", "\\a", "Bell"},
		[8] = {"BS", "␈", "^H", "\\b", "Backspace"},
		[9] = {"HT", "␉", "^I", "\\t", "Horizontal Tab"},
		[10] = {"LF", "␊", "^J", "\\n", "Line feed"},
		[11] = {"VT", "␋", "^K", "\\v", "Vertical Tab"},
		[12] = {"FF", "␌", "^L", "\\f", "Form feed"},
		[13] = {"CR", "␍", "^M", "\\r", "Carriage return"},
		[14] = {"SO", "␎", "^N", "", "Shift Out"},
		[15] = {"SI", "␏", "^O", "", "Shift In"},
		[16] = {"DLE", "␐", "^P", "", "Data Link Escape"},
		[17] = {"DC1", "␑", "^Q", "", "Device Control 1 (oft. XON)"},
		[18] = {"DC2", "␒", "^R", "", "Device Control 2"},
		[19] = {"DC3", "␓", "^S", "", "Device Control 3 (oft. XOFF)"},
		[20] = {"DC4", "␔", "^T", "", "Device Control 4"},
		[21] = {"NAK", "␕", "^U", "", "Negative Acknowledgment"},
		[22] = {"SYN", "␖", "^V", "", "Synchronous Idle"},
		[23] = {"ETB", "␗", "^W", "", "End of Trans. Block"},
		[24] = {"CAN", "␘", "^X", "", "Cancel"},
		[25] = {"EM", "␙", "^Y", "", "End of Medium"},
		[26] = {"SUB", "␚", "^Z", "", "Substitute"},
		[27] = {"ESC", "␛", "^[", "\\e", "Escape"},
		[28] = {"FS", "␜", "^\\", "", "File Separator"},
		[29] = {"GS", "␝", "^]", "", "Group Separator"},
		[30] = {"RS", "␞", "^^", "", "Record Separator"},
		[31] = {"US", "␟", "^_", "", "Unit Separator"},
		[127] = {"DEL", "␡", "^?", "", "Delete"},
	}
	local number_map = {
		["0"] = "𝟶",
		["1"] = "𝟷",
		["2"] = "𝟸",
		["3"] = "𝟹",
		["4"] = "𝟺",
		["5"] = "𝟻",
		["6"] = "𝟼",
		["7"] = "𝟽",
		["8"] = "𝟾",
		["9"] = "𝟿",
		["A"] = "𝙰",
		["B"] = "𝙱",
		["C"] = "𝙲",
		["D"] = "𝙳",
		["E"] = "𝙴",
		["F"] = "𝙵",
	}

	function string.readablebinary(str)
		local str = (
			str:gsub("(.)", function(str)
				local byte = str:byte()

				if map[byte] then return map[byte][2] end

				if byte > 127 then
					return string.format("｢%X｣", byte):gsub(".", number_map)
				end

				return str
			end)
		)
		str = str:gsub("(␀+)", function(nulls)
			return "NX" .. #nulls
		end)
		return str
	end
end

function string.hex_format(str, chunk_width, row_width, space_separator)
	row_width = row_width or 4
	chunk_width = chunk_width or 4
	space_separator = space_separator or " "
	local str = str:readable_hex():lower():split(" ")
	local out = {}
	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do
		list.insert(out, char)
		list.insert(out, " ")

		if row_i >= (row_width * chunk_width) then
			list.insert(out, "\n")
			chunk_i = 0
			row_i = 0
		end

		if chunk_i >= chunk_width then
			list.insert(out, space_separator)
			chunk_i = 0
		end

		row_i = row_i + 1
		chunk_i = chunk_i + 1
	end

	return list.concat(out):trim()
end

function string.bin_format(str, row_width, space_separator, with_hex, format)
	row_width = row_width or 8
	space_separator = space_separator or " "
	local str = str:to_list()
	local out = {}
	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do
		local bin = utility.NumberToBinary(char:byte(), 8)

		if with_hex then list.insert(out, ("%02X/"):format(char:byte())) end

		if format then
			local str = ""
			local bin = bin:to_list()
			local offset = 1

			for _, num in ipairs(format:to_list()) do
				num = tonumber(num)
				list.insert(bin, num + offset, "-")
				offset = offset + 1
			end

			list.insert(out, list.concat(bin))
		else
			list.insert(out, bin)
		end

		list.insert(out, space_separator)

		if row_i >= row_width then
			list.insert(out, "\n")
			row_i = 0
		end

		row_i = row_i + 1
	end

	return list.concat(out):trim()
end

function string.oct_format(str, row_width, space_separator, with_hex)
	row_width = row_width or 8
	space_separator = space_separator or " "
	local str = str:to_list()
	local out = {}
	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do
		local bin = string.format("%03o", char:byte())

		if with_hex then list.insert(out, ("%02X/"):format(char:byte())) end

		list.insert(out, bin) --:sub(0, 4) .. "-" .. bin:sub(5, 8))
		list.insert(out, space_separator)

		if row_i >= row_width then
			list.insert(out, "\n")
			row_i = 0
		end

		row_i = row_i + 1
	end

	return list.concat(out):trim()
end

function string.ends_with(a, b)
	return a:sub(-#b) == b
end

function string.ends_with_these(a, b)
	for _, str in ipairs(b) do
		if a:sub(-#str) == str then return true end
	end
end

function string.starts_with(a, b)
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

	local str1 = utf8.to_list(a)
	local str2 = utf8.to_list(b)

	for i = 1, #a do
		for j = 1, #b do
			distance[i][j] = math.min(
				distance[i - 1][j] + 1,
				distance[i][j - 1] + 1,
				distance[i - 1][j - 1] + (str1[i - 1] == str2[j - 1] and 0 or 1)
			)
		end
	end

	return distance[#a][#b]
end

function string.length_split(str, len)
	if #str > len then
		local tbl = {}
		local max = math.floor(#str / len)

		for i = 0, max do
			local left = i * len + 1
			local right = (i * len) + len
			local res = str:sub(left, right)

			if res ~= "" then list.insert(tbl, res) end
		end

		return tbl
	end

	return {str}
end

function string.get_char_type(char)
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

function string.char_class(char)
	for _, v in ipairs(types) do
		if char:find(v) then return v end
	end
end

function string.safe_format(str, ...)
	str = str:gsub("%%(%d+)", "%%s")
	local count = select(2, str:gsub("(%%)", ""))

	if str:find("%...", nil, true) then
		local temp = {}

		for i = count, select("#", ...) do
			list.insert(temp, tostringx(select(i, ...)))
		end

		str = str:replace("%...", list.concat(temp, ", "))
		count = count - 1
	end

	if count == 0 then return list.concat({str, ...}, "") end

	local copy = {}

	for i = 1, count do
		list.insert(copy, tostringx(select(i, ...)))
	end

	return string.format(str, unpack(copy))
end

function string.find_simple(self, find)
	return self:find(find, nil, true) ~= nil
end

function string.find_simple_lower(self, find)
	return self:lower():find(find:lower(), nil, true) ~= nil
end

function string.compare(self, target)
	return self == target or
		self:find_simple(target) or
		self:lower() == target:lower()
		or
		self:find_simple_lower(target)
end

function string.trim(self, char)
	if char then char = char:patternsafe() .. "*" else char = "%s*" end

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

function string.get_char(self, pos)
	return string.sub(self, pos, pos)
end

function string.get_byte(self, pos)
	return self:get_char(pos):byte() or 0
end

function string.to_list(self)
	local tbl = table.new(#self, 0)

	for i = 1, #self do
		tbl[i] = self:sub(i, i)
	end

	return tbl
end

function string.split(self, separator, plain_search)
	if separator == nil or separator == "" then return self:to_list() end

	if plain_search == nil then plain_search = true end

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

function string.contains_only(self, pattern)
	return self:gsub(pattern, "") == ""
end

function string.replace(self, what, with)
	local tbl = {}
	local current_pos = 1
	local last_i

	for i = 1, #self do
		local start_pos, end_pos = self:find(what, current_pos, true)

		if not start_pos then
			last_i = i

			break
		end

		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	if current_pos > 1 and last_i then
		tbl[last_i] = self:sub(current_pos)
		return list.concat(tbl, with)
	end

	return self
end

do
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
		["\0"] = "%z",
	}

	function string.escape_pattern(str)
		return (str:gsub(".", pattern_escape_replacements))
	end
end

function string.capitalize(self)
	return self:sub(1, 1):upper() .. self:sub(2)
end