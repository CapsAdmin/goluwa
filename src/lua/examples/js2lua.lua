---local script = vfs.Read("data/typeset.js")
local script = [[
var i = 0,
        lines = [],
        point, j, r, lineStart = 0,
        y = 4,
        maxLength = Math.max.apply(null, lineLengths);
]]

local chars = script:utotable()

local bracket_level = 0

local scope = false
local scopes = {
	["if"] = true,
	["function"] = true,
	["for"] = true,
}
local symbol = ""
local last_symbol
local word = ""
local in_string = false
local in_commment = false
local in_typeof = false
local assignment = false
local in_function = false

local if_statement = false
local if_statement_bracket_level = false

local for_statement = false
local for_statement_bracket_level = false
local in_loop = false

local array_level = 0
local in_array = false

local last_word

local function replace(chars, i, str, with)
	for i2 = 1, #str do
		chars[i - i2] = ""
	end
	chars[i-1] = with
end

for i, char in ipairs(chars) do
	local t = char:getchartype()

	if char == [["]] or char == [[']] then
		in_string = char
	end

	if in_single_line_commment and char == "\n" then
		in_single_line_commment = false
	elseif char == "/" and chars[i - 1] == "/" then
		in_single_line_commment = true
		chars[i - 0] = "-"
		chars[i - 1] = "-"
	end

	if in_multi_line_commment and chars[i - 1] == "*" and char == "/" then
		in_multi_line_commment = false

		chars[i - 1] = ""
		chars[i] = "--]====]"
	elseif chars[i - 1] == "/" and char == "*" then
		in_multi_line_commment = true

		chars[i - 1] = ""
		chars[i] = "--[====["
	end

	if not in_string and not in_single_line_commment and not in_multi_line_commment then
		if t == "punctation" then
			symbol = symbol .. char
		elseif symbol ~= "" then
			if symbol == "?" then
				assignment = false
				chars[i-1] = " and "
			elseif symbol == ":" then
				chars[i-1] = " or "
			end

			if symbol == "===" then
				chars[i-1] = ""
			elseif symbol == "=" then
				assignment = true
			elseif symbol == "&&" then
				replace(chars, i, symbol, " and ")
			elseif symbol == "||" then
				replace(chars, i, symbol, " or ")
			elseif symbol == "!==" then
				replace(chars, i, symbol, "~=")
			elseif symbol == "+=" then
				replace(chars, i, symbol, " = " .. last_word .. " + ")
			elseif symbol == "-=" then
				replace(chars, i, symbol, " = " .. last_word .. " - ")
			end
			last_symbol = symbol
			symbol = ""
		end

		if char == "]" and in_array then
			array_level = array_level - 1
			chars[i] = "}"
			if array_level == 0 then
				in_array = false
			end
		elseif char == "[" and (last_symbol == "," or last_word == "return" or assignment) then
			chars[i] = "{"
			in_array = true
			array_level = array_level + 1
		end

		if t == "letters" then
			word = word .. char
		elseif word ~= "" then
			if scopes[word] then
				scope = bracket_level
			end

			if in_typeof then
				chars[i] = ")"
				in_typeof = false
			end

			if word == "typeof" then
				replace(chars, i, word, "type(")
				in_typeof = true
			elseif word == "this" then
				replace(chars, i, word, "self")
			end

			if word == "if" then
				if_statement = true
			elseif word == "for" then
				replace(chars, i, word, "do")
				for_statement = 0
			elseif word == "function" then
				in_function = true
			end

			if word == "null" then
				replace(chars, i, word, "nil")
			elseif word == "var" then
				replace(chars, i, word, "local")
			end

			last_word = word
			word = ""
		end

		if for_statement then
			if char == "(" then
				chars[i] = ""
				for_statement_bracket_level = (for_statement_bracket_level or 0) + 1
			elseif char == ")" then
				for_statement_bracket_level = for_statement_bracket_level - 1
				chars[i] = ""
			end

			if for_statement_bracket_level == 0 then
				for_statement_bracket_level = false
				for_statement = false

				chars[i] = " end while __itr_chk(j) do"

				in_loop = true
			end

			if char == ";" then
				for_statement = for_statement + 1

				if for_statement == 1 then
					chars[i] = "; local function __itr_chk(j) return "
				elseif for_statement == 2 then
					chars[i] = " end; local function __itr() "
				end
			end
		end

		if if_statement then
			if char == "(" then
				chars[i] = ""
				if_statement_bracket_level = (if_statement_bracket_level or 0) + 1
			elseif char == ")" then
				if_statement_bracket_level = if_statement_bracket_level - 1
				chars[i] = ""
			end

			if if_statement_bracket_level == 0 then
				if_statement_bracket_level = false
				if_statement = false

				chars[i] = " then"
			end
		end

		if in_function then

		end

		if char == "{" then
			if scope == bracket_level then
				chars[i] = ""
			end
			bracket_level = bracket_level + 1
		end

		if char == "}" then
			bracket_level = bracket_level - 1
			if scope and not assignment then
				if in_loop then
					chars[i] = "__itr() end end"
					in_loop = false
				else
					chars[i] = "end"
					if bracket_level == 0 then
						scope = false
					end
				end
			end
		end

		if assignment and char == "," then
			chars[i] = ";local "
		end

		if char == ";" then
			assignment = false
			if not for_statement  then
				chars[i] = ""
			end
		end
	end

	if in_string == char then
		in_string = false
	end
end

local out = table.concat(chars, "")

out = out:gsub("end%s*else", "else")
out = out:gsub("end%s*else%s*if", "elseif")
out = out:gsub("else%s*if", "elseif")

print(out)
print(loadstring(out))