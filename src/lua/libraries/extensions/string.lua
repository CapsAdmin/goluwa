do
	local vowels = {"e", "a", "o", "i", "u", "y"}
	local consonants = {"t", "n", "s", "h", "r", "d", "l", "c", "m", "w", "f", "g", "p", "b", "v", "k", "j", "x", "q", "z"}
	local first_letters = {"t", "a", "s", "h", "w", "i", "o", "b", "m", "f", "c", "l", "d", "p", "n", "e", "g", "r", "y", "u", "v", "j", "k", "q", "z", "x"}

	function string.randomwords(word_count)
		word_count = word_count or 8

		local text = {}

		local last_punctation = 1
		local capitalize = true

		for i = 1, word_count do
			math.randomseed(i)
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

function string.readablehex(str)
	return (str:gsub("(.)", function(str) str = ("%X"):format(str:byte()) if #str == 1 then str = "0" .. str end return str .. " " end))
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

function string.dumphex(str)
	local str = str:readablehex():lower():explode(" ")
	local out = {}

	for i, char in pairs(str) do
		table.insert(out, char)
		table.insert(out, " ")
		if i%16 == 0 then
			table.insert(out, "\n")
		end
		if i%16 == 4 or i%16 == 12 then
			table.insert(out, " ")
		end
		if i%16 == 8 then
			table.insert(out, "  ")
		end

	end
	table.insert(out, "\n")
	return table.concat(out)
end

function string.endswith(a, b)
	return a:sub(-#b) == b
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
		local leftover = #str - (max * len)

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
	for i, v in ipairs(types) do
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

function string.explode(self, sep, pattern)
	if not sep or sep == "" then
		local tbl = table.new(#str, 0)
		for i = 1, #str do
			tbl[i] = str:sub(i, i)
		end
		return tbl
	end

	local tbl = {}
	local current_pos = 1

	if pattern == nil then
		pattern = false
	end

	for i = 1, #self do
		local start_pos, end_pos = self:find(sep, current_pos, pattern)
		if not start_pos then break end
		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	tbl[#tbl + 1] = self:sub(current_pos)

	return tbl
end

function string.count(self, what, pattern)
	local count = 0
	local current_pos = 1
	for i = 1, #self do
		local start_pos, end_pos = self:find(what, current_pos, pattern)
		if not start_pos then break end
		count = count + 1
		current_pos = end_pos + 1
	end
	return count
end

function string.containsonly(self, pattern)
	return self:gsub(pattern, "") == ""
end

function string.replace(self, a, b)
	local tbl = self:explode(a)

	if tbl[1] then
		return table.concat(tbl, b)
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