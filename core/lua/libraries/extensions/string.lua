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

function string.transform_case(str, from, to)
	if from == "fooBar" then
		if to == "FooBar" then
			return str:sub(1, 1):upper() .. str:sub(2)
		elseif to == "foo_bar" then
			return string.transform_case(str:sub(1, 1):upper() .. str:sub(2), "FooBar", "foo_bar")
		end
	elseif from == "FooBar" then
		if to == "foo_bar" then
			return str:gsub("(%l)(%u)", function(a, b)
				return a .. "_" .. b:lower()
			end):lower()
		elseif to == "fooBar" then
			return str:sub(1, 1):lower() .. str:sub(2)
		end
	elseif from == "foo_bar" then
		if to == "FooBar" then
			return ("_" .. str):gsub("_(%l)", function(s)
				return s:upper()
			end)
		elseif to == "fooBar" then
			return string.transform_case(string.transform_case(str, "foo_bar", "FooBar"), "FooBar", "fooBar")
		end
	elseif from == "Foo_Bar" then
		return string.transform_case(("_" .. str):gsub("_(%u)", function(s)
			return s:upper()
		end), "FooBar", to)
	end

	return str
end