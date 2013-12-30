local syntax = {}

syntax.DEFAULT    = 1
syntax.KEYWORD    = 2
syntax.IDENTIFIER = 3
syntax.STRING     = 4
syntax.NUMBER     = 5
syntax.OPERATOR   = 6

syntax.patterns = {
	[2]  = "([%a_][%w_]*)",
	[1]  = "(\".-\")",
	[5]  = "([%d]+%.?%d*)",
	[6]  = "([%+%-%*/%%%(%)%.,<>=:;{}%[%]])",
	[7]  = "(//[^\n]*)",
	[8]  = "(/%*.-%*/)",
	[9]  = "(%-%-[^%[][^\n]*)",
	[10] = "(%-%-%[%[.-%]%])",
	[11] = "(%[=-%[.-%]=-%])",
	[12] = "('.-')"
}

local COLOR_BLACK = 0
local COLOR_RED = 1
local COLOR_GREEN = 2
local COLOR_YELLOW = 3
local COLOR_BLUE = 4
local COLOR_MAGENTA = 5
local COLOR_CYAN = 6
local COLOR_WHITE = 7

syntax.colors = {
	COLOR_WHITE, --Color(255, 255, 255),
	COLOR_CYAN + 2 ^ 13, --Color(127, 159, 191),
	COLOR_WHITE, --Color(223, 223, 223),
	COLOR_RED, --Color(191, 127, 127),
	COLOR_GREEN, --Color(127, 191, 127),
	COLOR_YELLOW, --Color(191, 191, 159),
	COLOR_WHITE, --Color(159, 159, 159),
	COLOR_WHITE, --Color(159, 159, 159),
	COLOR_WHITE, --Color(159, 159, 159),
	COLOR_WHITE, --Color(159, 159, 159),
	COLOR_YELLOW, --Color(191, 159, 127),
	COLOR_RED, --Color(191, 127, 127),
}

syntax.keywords = {
	["local"]    = true,
	["function"] = true,
	["return"]   = true,
	["break"]    = true,
	["continue"] = true,
	["end"]      = true,
	["if"]       = true,
	["not"]      = true,
	["while"]    = true,
	["for"]      = true,
	["repeat"]   = true,
	["until"]    = true,
	["do"]       = true,
	["then"]     = true,
	["true"]     = true,
	["false"]    = true,
	["nil"]      = true,
	["in"]       = true
}

function syntax.process(code)
	local output, finds, types, a, b, c = {}, {}, {}, 0, 0, 0

	while b < #code do
		local temp = {}

		for k, v in pairs(syntax.patterns) do
			local aa, bb = code:find(v, b + 1)
			if aa then table.insert(temp, {k, aa, bb}) end
		end

		if #temp == 0 then
			table.insert(temp, {1, b + 1, #code})
		end

		table.sort(temp, function(a, b) return (a[2] == b[2]) and (a[3] > b[3]) or (a[2] < b[2]) end)
		c, a, b = unpack(temp[1])

		table.insert(finds, a)
		table.insert(finds, b)

		table.insert(types, c == 2 and (syntax.keywords[code:sub(a, b)] and 2 or 3) or c)
	end

	for i = 1, #finds - 1 do
		local asdf = (i - 1) % 2
		local sub = code:sub(finds[i + 0] + asdf, finds[i + 1] - asdf)

		table.insert(output, asdf == 0 and syntax.colors[types[1 + (i - 1) / 2]] or 7)
		table.insert(output, (asdf == 1 and sub:find("^%s+$")) and sub:gsub("%s", " ") or sub)
	end

	return output
end

return syntax