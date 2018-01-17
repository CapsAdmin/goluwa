local kua = {}

local double_quote = "\""
local literal_quote = "`"
local escape = "\\"
local char_types = {}

do -- space
	char_types[""] = "space"
	char_types[" "] = "space"
	char_types["\n"] = "space"
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
	char_types["-"] = "symbol"
	char_types["+"] = "symbol"
	char_types["*"] = "symbol"
	char_types["/"] = "symbol"
	char_types["\""] = "symbol"
	char_types["`"] = "symbol"
end

local operators = {
	"+",
	"-",
	"*",
	"/",
	"%",
	"^",
	"-",
	"==",
	"~=",
	">",
	"<",
	">=",
	"<=",
	"and",
	"or",
	"not",
	"..",
	"#",
}
for k,v in pairs(operators) do operators[v] = v end

local keywords = {
	"and",
	"break",
	"do",
	"else",
	"elseif",
	"end",
	"false",
	"for",
	"function",
	"if",
	"in",
	"local",
	"nil",
	"not",
	"or",
	"repeat",
	"return",
	"then",
	"true",
	"until",
	"while",
}
for k,v in pairs(keywords) do keywords[v] = v end

local keyword_values = {
	"nil",
	"true",
	"false",
}
for k,v in pairs(keyword_values) do keyword_values[v] = v end

do
	local function compile_error(state, msg)
		--table.print(state)
		local lines = state.code:split("\n")
		for i = 1, #lines do
			log(i, ": ")
			if i == state.line_pos then
				local line = lines[state.line_pos]
				logn(line)
				logn((" "):rep(state.sub_pos + #(i .. ": ")) .. "^ : " .. msg)
			else
				logn(lines[i])
			end
		end

		return nil, msg
	end

	local function flush(state)
		local res = table.concat(state.chunk)
		local type = state.last_type

		if keywords[res] then
			type = "keyword"
		end

		if type ~= "space" then
			table.insert(state.chunks, {
				char_pos = state.char_pos,
				line_pos = state.line_pos,
				chunk = res,
				type = type,
				is_value = keyword_values[res],
				is_operator = operators[res],
			})
		end
		table.clear(state.chunk)
	end

	local function advance(state, char)
		if char == "\n" then
			state.line_pos = state.line_pos + 1
			state.char_pos = 1
		end

		state.char_pos = state.char_pos + 1
	end

	function kua.GetChunks(code)
		local state = {}

		state.code = code

		state.chunks = {}

		state.chunk = {}
		state.chunk_line_pos = nil
		state.chunk_char_pos = nil

		state.char_pos = 1
		state.line_pos = 1
		state.sub_pos = 1

		state.last_char = ""

		local i = 1
		for _ = 1, #code + 1 do


			do -- comments
				if code:sub(i, i) == "-" and code:sub(i+1, i+1) == "-" then
					if code:sub(i+2, i+2) == "`" then
						i = i + 2

						local length = 0

						for offset = 0, 32 do
							if code:sub(i + offset, i + offset) ~= literal_quote then
								length = offset
								break
							end
						end

						local stop

						local count = 0
						for i = i + length, #code do
							local c = code:sub(i, i)

							advance(state, c)

							if code:sub(i-1, i-1) ~= escape then
								if c == literal_quote then
									count = count + 1
								else
									count = 0
								end

								if count == length then
									stop = i
									break
								end
							end
						end

						if not stop then
							return compile_error(state, "cannot find the end of multiline comment")
						end

						i = stop + 1
					else
						for i2 = i + 1, #code do
							local c = code:sub(i2, i2)
							advance(state, c)
							if c == "\n" then
								i = i2
								break
							end
						end
					end
				end
			end

			local char = code:sub(i, i)
			local t = char_types[char]

			if not t then
				return compile_error(state, "unknown symbol >>" .. char .. "<<")
			end

			state.char = char
			state.char_type = t

			if char == double_quote then
				flush(state)

				local stop

				for i = i + 1, #code do
					local c = code:sub(i, i)

					advance(state, c)

					if code:sub(i-1, i-1) ~= escape then
						if c == double_quote then
							stop = i
							break
						end
					end
				end

				if not stop then
					return compile_error(state, "cannot find the end of double quote")
				end

				table.insert(state.chunks, {
					type = "string",
					chunk = code:sub(i, stop),
				})

				i = stop
			elseif char == literal_quote then
				flush(state)

				local length = 0

				for offset = 0, 32 do
					if code:sub(i + offset, i + offset) ~= literal_quote then
						length = offset
						break
					end
				end

				local stop

				local count = 0
				for i = i + length, #code do
					local c = code:sub(i, i)

					advance(state, c)

					if code:sub(i-1, i-1) ~= escape then
						if c == literal_quote then
							count = count + 1
						else
							count = 0
						end

						if count == length then
							stop = i
							break
						end
					end
				end

				if not stop then
					return compile_error(state, "cannot find the end of multiline quote")
				end

				table.insert(state.chunks, {
					type = "string",
					chunk = code:sub(i, stop),
				})

				i = stop
			else
				do -- numbers
					if state.number_fraction then
						if char == "." then
							return compile_error(state, "malformed number: only one symbol allowed")
						end
					end

					if state.number_hex then
						local char = char:lower()

						if
							char == "a" or
							char == "b" or
							char == "c" or
							char == "d" or
							char == "e" or
							char == "f"
						then
							t = "number"
						else
							if t ~= "space" and (c == "symbol" and c ~= ".") or t == "letter" then
								return compile_error(state, "malformed number: only abcdef0123456789 allowed after hex notation")
							end

						end
					elseif state.number_exponent then
						if char == "+" or char == "-" then
							state.number_exponent = nil
							state.number_exponent_stage_2 = true
							t = "number"
						else
							return compile_error(state, "malformed number: only + or - allowed after exponent")
						end
					elseif state.number_exponent_stage_2 then
						if t ~= "number" then
							if t ~= "space" and (c == "symbol" and c ~= ".") or t == "letter" then
								return compile_error(state, "malformed number: only 0123456789 allowed after exponent expression")
							end
						end
					end

					if state.last_type == "number" then
						local char = char:lower()

						if char == "x" then
							state.number_hex = true
							t = "number"
						end

						if char == "." then
							state.number_fraction = true
							t = "number"
						end

						if char == "e" then
							state.number_exponent = true
							t = "number"
						end

						if t == "letter" then
							return compile_error(state, "malformed number")
						end

						if t ~= "number" then
							state.number_exponent = nil
							state.number_exponent_stage_2 = nil
							state.number_fraction = nil
							state.number_hex = nil
						end
					end
				end

				if char == "_" or (state.last_type == "letter" and t == "number") then
					t = "letter"
				end

				if char == "." and code:sub(i+1, i+1) == "." and code:sub(i+2, i+2) == "." then
					char = "..."
					i = i + 2
				elseif char == "." and code:sub(i+1, i+1) == "." then
					char = ".."
					i = i + 1
				end

				if char == "!" and code:sub(i+1, i+1) == "=" then
					char = "!="
					i = i + 1
				end

				if char == "=" and code:sub(i+1, i+1) == "=" then
					char = "=="
					i = i + 1
				end

				if t ~= state.last_type or t == "symbol" then
					if state.chunk[1] then
						flush(state)
					end
				end

				if t ~= "space" then
					table.insert(state.chunk, char)
				end
			end

			advance(state, char)

			state.last_char = char
			state.sub_pos = i
			state.last_type = t

			i = i + 1
		end

		return state.chunks
	end
end

local code = [[
var1 = true
var2 = `cant see me`
tbl = {}
tbl.field = true
if 2+3 == 5 do
	var2 = true
	print(var1, var2)
end
var3 = true
lol(var1, var2)
print(var1, var2)
tbl.field(1,function(...) local lol = function(foo,bar) h=1 end print(1) end,3)
lol = function(a,b,c) print(1,2,3) print((1+5)+5) end
asdf = ```adad ad a wdawd ```
foo.bar = true and false
foo["bar"]
www.google.com.foo[lol and "bar" or "faz"] = true and false
foo = true
faz = 1 and 2+3 == 4 or 6

ah = function()
	lol = true
	www.google.com.foo[lol and "bar" or "faz"].foo = true and false

	if true do
		asdf = true
	end
end
print("asdf" .. "hi")
print("asdf", "hi")

-- a comment
--```
multiline comment
test
```

var1=`test`
var2=`test
one two three
newline`
var3 =   ``` print(`hi`, ``hi``) ```
var4="hi\"hi"

print(3)

--`
a
multiline
comment
`

print(1)
]]

table.print2(kua.GetChunks(code))

do return end

local function balanced_match(chunks, i, max, match)
	local out = {}
	local balance = 0

	for i2 = i, max do
		local chunk = chunks[i2]
		if match[chunk.chunk] == true then
			balance = balance + 1
		elseif match[chunk.chunk] == false then
			balance = balance - 1
		end

		table.insert(out, chunk)

		if balance == 0 then
			return out, i2
		end
	end
end


local function parse_operators(chunks)
	local out = {}

	local last_op

	local i = 1
	local max = #chunks
	for _ = 1, max do
		local chunk = chunks[i]

		if not chunk then break end

		if operators[chunk.chunk] then
			local op = {
				type = operators[chunk.chunk],
				left = last_op or chunks[i - 1],
				right = chunks[i + 1],
			}

			last_op = op
		end

		i = i + 1
	end

	return last_op or chunks[1]
end

local function parse_operator_scopes(chunks)
	local out = {}

	local i = 1
	local max = #chunks
	for _ = 1, max do
		local chunk = chunks[i]

		if not chunk then break end

		if chunk.chunk == "(" then
			local res, stop_i = balanced_match(chunks, i, max, {["("] = true, [")"] = false})
			if res then
				table.remove(res, 1) -- )
				table.remove(res, #res) -- (

				table.insert(out, parse_operator_scopes(res))

				i = stop_i
			end
		else
			table.insert(out, chunk)
		end

		i = i + 1
	end

	return parse_operators(out)
end


local function parse_calls_and_assignments(chunks)
	local state = {}

	state.out = {}
	state.scope = 0

	local i = 1
	local max = #chunks
	for _ = 1, max do
		local chunk = chunks[i]

		if not chunk then break end

		if state.statement then
			if chunk.chunk == "do" then
				table.insert(state.out, {
					type = "statement",
					val = state.statement,
					scope = state.scope,
				})
				state.statement = nil
				state.scope = state.scope + 1
			else
				table.insert(state.statement, chunk)
			end
		else
			if chunk.chunk == "do" then
				state.scope = state.scope + 1
			elseif chunk.chunk == "end" then
				state.scope = state.scope - 1
			elseif chunk.chunk == "if" then
				state.statement = {}
			elseif chunk.type == "letter" then
				local left = {}
				local type

				for i2 = i, max do
					local chunk2 = chunks[i2]
					if chunk2.chunk == "=" or chunk2.chunk == "(" then
						if chunk2.chunk == "=" then
							type = "assignment"
						elseif chunk2.chunk == "(" then
							type = "call"
						end
						i = i2
						break
					end
					table.insert(left, chunk2)
				end

				if type == "call" then
					local call_line = balanced_match(chunks, i, max, {["("] = true, [")"] = false})
					table.remove(call_line, 1)
					table.remove(call_line, #call_line)

					local arguments = {}
					local argument = {}

					for _, chunk in ipairs(call_line) do
						if chunk.chunk == "," then
							table.insert(arguments, parse_operator_scopes(argument))
							argument = {}
						else
							table.insert(argument, chunk)
						end
					end

					if argument[1] then
						table.insert(arguments, parse_operator_scopes(argument))
					end

					table.insert(state.out, {
						type = "call",
						left = left,
						arguments = arguments,
					})
				elseif type == "assignment" then
					table.insert(state.out, {
						type = "assignment",
						left = left,
						right = chunks[i + 1],
					})
				end
			end
		end

		i = i + 1
	end

	return state.out
end

local function parse_assignments(chunks)
	local state = {}

	state.out = {}

	local i = 1
	local max = #chunks
	for _ = 1, max do
		local chunk = chunks[i]

		if not chunk then break end

		if chunk.chunk == "=" then
			local left = {}
			local type

			local square_bracket_balance = 0
			local left = {chunks[i-1]}

			chunks[i-1].assignment = true

			for i2 = i-2, 1, -1 do
				local chunk2 = chunks[i2]

				if chunk2.chunk == "]" then
					square_bracket_balance = square_bracket_balance + 1
				elseif chunk2.chunk == "[" then
					square_bracket_balance = square_bracket_balance - 1
				end

				local last = chunks[i2 + 1]

				if square_bracket_balance == 0 then
					if last.type == "letter" then
						if chunk2.chunk == "." or chunk2.chunk == "[" then
							chunk2.assignment = true
							table.insert(left, 1, chunk2)
						else
							break
						end
					elseif last.chunk == "." or last.chunk == "[" then
						if chunk2.type == "letter" then
							chunk2.assignment = true
							table.insert(left, 1, chunk2)
						else
							print("unexpected symbol " .. last.chunk)
							break
						end
					else
						print(last.chunk)
					end
				else
					chunk2.assignment = true
					table.insert(left, 1, chunk2)
				end
			end

			local assignment = {
				type = "=",
				left = left,
			}

			table.insert(state.out, assignment)

		else
			table.insert(state.out, chunk)
		end

		i = i + 1
	end

	local selected
	local found_right_side

	for i = #state.out, 1, -1 do
		local chunk = state.out[i]
		if chunk.assignment then
			table.remove(state.out, i)
		end
	end

	for i,v in ipairs(state.out) do
		if v.type == "=" then
			v.right = {}
			for i = i+1, #state.out do
				local chunk = state.out[i]
				if chunk.type == "=" or (chunk.type == "keyword" and not chunk.is_value and not chunk.is_operator) then break end

				chunk.assignment = true

				table.insert(v.right, chunk)
			end
		end
	end


	for i = #state.out, 1, -1 do
		local chunk = state.out[i]
		if chunk.assignment then
			table.remove(state.out, i)
		end
	end

	return state.out
end


local function parse_scopes(chunks)
	local out = {}

	local i = 1
	local max = #chunks
	for _ = 1, max do
		local chunk = chunks[i]

		if not chunk then break end

		if chunk.chunk == "function" then
			local body, stop_i = balanced_match(chunks, i, max, {["do"] = true, ["function"] = true, ["end"] = false})
			i = stop_i

			local arg_offset = 2
			local name

			if body[2].chunk == "letters" then
				arg_offset = 3
				name = table.remove(body, 2)
			end

			local arguments = balanced_match(body, arg_offset, max, {["("] = true, [")"] = false})

			for i = 1, #arguments + 1 do
				table.remove(body, 1)
			end

			table.remove(body, #body) -- end
			table.remove(arguments, 1) -- (
			table.remove(arguments, #arguments) -- )

			local temp = {}

			for k,v in ipairs(arguments) do
				if v.chunk ~= "," then
					table.insert(temp, v)
				end
			end


			table.insert(out, {
				type = "function",
				arguments = temp,
				children = (parse_scopes(body)), -- was here
				name = name,
			})
		else
			table.insert(out, chunk)
		end

		i = i + 1
	end

	return parse_assignments(out)
end

local function compile(code)
	return parse_scopes(parse_operator_scopes(assert(parse_strings_and_numbers(code))))
end


local function parse_statement(data)
	local out = ""
	if data.left then
		out = out .. "(" .. parse_statement(data.left) .. data.type .. parse_statement(data.right) .. ")"
	else
		out = out .. data.chunk
	end
	return out
end

local tree = parse_assignments(parse_strings_and_numbers(code))
table.print2(tree)