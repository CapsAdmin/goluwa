

local syntax = {}

do -- syntax rules
	syntax.quote = "\""
	syntax.literal_quote = "`"
	syntax.escape_character = "\\"
	syntax.comment = "--"

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
		end

		syntax.char_types = char_types
	end

	syntax.operator_precedence = {
		["+"] = "left",
		["-"] = "left",
		["*"] = "left",
		["/"] = "left",
		["%"] = "left",
		["-U"] = "left",
		["=="] = "left",
		["~="] = "left",
		["!="] = "left",
		[">"] = "left",
		["<"] = "left",
		[">="] = "left",
		["<="] = "left",
		["#"] = "left",
		["^"] = "right",
		[".."] = "right",
		["&"] = "right",
		["~U"] = "right",
		["|"] = "right",
		[">>"] = "right",
		["<<"] = "right",
	}

	syntax.operator_priority = {
		"^",
		"not", "-", "#",
		"*", "/", "%",
		"+", "-",
		"..",
		"<<", ">>",
		"&",
		"~U",
		"|",
		"<", ">", "<=", ">=", "~=", "==",
		"and",
		"or",
	}

	syntax.keywords = {
		"and", "break", "do", "else", "elseif", "end",
		"false", "for", "function", "if", "in", "local",
		"nil", "not", "or", "repeat", "return", "then",
		"true", "until", "while", "goto",
	}
	for k,v in pairs(syntax.keywords) do
		syntax.keywords[v] = v
	end

	syntax.keyword_values = {
		"nil",
		"true",
		"false",
	}
	for k,v in pairs(syntax.keyword_values) do
		syntax.keyword_values[v] = v
	end

	syntax.symbol_priority = {"..."}
	syntax.symbol_priority_lookup = {}

	local is_operator = {}

	for k,v in pairs(syntax.operator_priority) do
		is_operator[v] = true
	end
	for k,v in pairs(syntax.operator_precedence) do
		is_operator[k] = true

		table.insert(syntax.symbol_priority, k)
		for i = 1, #k do
			local c = k:sub(i, i)
			if c:find("%p") then
				if i == 1 then
					syntax.symbol_priority_lookup[c] = true
				end
				syntax.char_types[c] = "symbol"
			end
		end
	end

	syntax.is_operator = is_operator

	table.sort(syntax.symbol_priority, function(a, b) return #a > #b end)





	local symbols = {
		"^",
		"-",
		"#",
		"*",
		"/",
		"%",
		"+",
		"-",
		"..",
		"<<",
		">>",
		"&",
		"|",
		"<",
		">",
		"<=",
		">=",
		"~=",
		"!=",
		"==",
		"..",
		"...",
		"+=",
		".",
		",",
		"(",
		")",
		"{",
		"}",
		"[",
		"]",
		"=",
		":",
		";",
		"`",
		"'",
		"\"",
	}
	table.sort(symbols, function(a, b) return #a > #b end)
	syntax.symbols = symbols

	local longest_symbol = 0
	local lookup = {}
	for k,v in ipairs(symbols) do
		lookup[v] = true
		longest_symbol = math.max(longest_symbol, #v)
	end
	syntax.longest_symbol = longest_symbol
	syntax.symbols_lookup = lookup
end

return syntax
