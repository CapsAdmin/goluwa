local oh = ... or _G.oh
local syntax = {}

do -- syntax rules
	syntax.quote = "\""
	syntax.literal_quote = "`"
	syntax.escape_character = "\\"
	syntax.comment = "--"

	syntax.types = {
		"string",
		"number",
	}


	do
		local char_types = {}

		do -- space
			char_types[""] = "space"
			char_types[" "] = "space"
			char_types["\n"] = "space"
			char_types["\r"] = "space"
			char_types["\t"] = "space"
		end

		do -- numbers
			for i = 0, 9 do
				char_types[tostring(i)] = "number"
			end
		end

		do -- letters
			char_types["_"] = "letter"

			for i = string.byte("A"), string.byte("z") do
				char_types[string.char(i)] = "letter"
			end
		end

		do -- symbols
			char_types["."] = "symbol"
			char_types[","] = "symbol"
			char_types["("] = "symbol"
			char_types[")"] = "symbol"
			char_types["{"] = "symbol"
			char_types["}"] = "symbol"
			char_types["["] = "symbol"
			char_types["]"] = "symbol"
			char_types["="] = "symbol"
			char_types[":"] = "symbol"
			char_types[";"] = "symbol"
			char_types["`"] = "symbol"
			char_types["'"] = "symbol"
			char_types["\""] = "symbol"
			char_types["~"] = "symbol" -- op
		end

		syntax.char_types = char_types
	end

	syntax.unary_operators = {
		["+"] = true,
		["-"] = true,
		["#"] = true,
		["not"] = true,
	}

	syntax.operators = {
		["^"] = -9,
		["%"] = 7,
		["/"] = 7,
		["*"] = 7,
		["+"] = 6,
		["-"] = 6,
		[".."] = 5,
		["<="] = 3,
		["=="] = 3,
		["~="] = 3,
		["<"] = 3,
		[">"] = 3,
		[">="] = 3,
		["and"] = 2,
		["or"] = 1,
		[">>"] = -1,
		["#"] = -1,
		["not"] = -1,
		["<<"] = -1,
		["!="] = -1,
		["&"] = -1,
		["|"] = -1,
	}

	for i,v in pairs(syntax.operators) do
		if v < 0 then
			syntax.operators[i] = {-v + 1, -v}
		else
			syntax.operators[i] = {v, v}
		end
	end

	syntax.keywords = {
		"and", "break", "do", "else", "elseif", "end",
		"false", "for", "function", "if", "in", "local",
		"nil", "not", "or", "repeat", "return", "then",
		"true", "until", "while", "goto", "...",
	}
	for k,v in pairs(syntax.keywords) do
		syntax.keywords[v] = v
	end

	syntax.keyword_values = {
		"...",
		"nil",
		"true",
		"false",
	}
	for k,v in pairs(syntax.keyword_values) do
		syntax.keyword_values[v] = v
	end

	do
		local symbols = {"...", "::"}
		local done = {}
		for k,v in pairs(syntax.char_types) do
			if v == "symbol" and not done[k] then
				table.insert(symbols, k)
				done[k] = true
			end
		end
		for k,v in pairs(syntax.operators) do
			if not done[k] then
				table.insert(symbols, k)
				done[k] = true
			end
		end
		table.sort(symbols, function(a, b) return #a > #b end)
		syntax.symbols = symbols

		local longest_symbol = 0
		local lookup = {}
		for k,v in ipairs(symbols) do
			lookup[v] = true
			longest_symbol = math.max(longest_symbol, #v)
			if #v == 1 then
				syntax.char_types[v] = "symbol"
			end
		end
		syntax.longest_symbol = longest_symbol
		syntax.symbols_lookup = lookup
	end

	function syntax.IsValue(token)
		return token.type == "number" or token.type == "string" or syntax.keyword_values[token.value]
	end

	function syntax.GetLeftOperatorPriority(token)
		return oh.syntax.operators[token.value] and oh.syntax.operators[token.value][1]
	end

	function syntax.GetRightOperatorPriority(token)
		return oh.syntax.operators[token.value] and oh.syntax.operators[token.value][2]
	end

	function syntax.IsUnaryOperator(token)
		return syntax.unary_operators[token.value]
	end
end

oh.syntax = syntax


if RELOAD then
	oh.Test()
end