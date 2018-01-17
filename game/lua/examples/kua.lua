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
	"or",
	"and",
	"+",
	"-",
	"/",
	"*",
	"==",
}

for k,v in pairs(operators) do operators[v] = v end

local function parse_strings_and_numbers(code)
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
		local char = code:sub(i, i)
		local t = char_types[char]

		if not t then
			return compile_error(state, "unknown symbol >>" .. char .. "<<")
		end

		state.char = char
		state.char_type = t

		if state.escape then
			table.insert(state.chunk, char)
		elseif state.multiline_quotes_stop then
			t = "string"
			table.insert(state.chunk, char)
			if state.multiline_quotes_stop == i then
				state.multiline_quotes_stop = nil
				table.insert(state.chunks, {
					start_line_pos = line_pos,
					stop_line_pos = chunk_line_pos,

					start_char_pos = char_pos,
					stop_char_pos = chunk_char_pos,

					chunk = table.concat(state.chunk),
					type = "string",
				})
				table.clear(state.chunk)
			end
		else
			if char == "\\" then
				state.escape = true
			end

			if char == "\"" and not state.multiline_quotes then
				state.quotes = not state.quotes

				table.insert(state.chunk, char)

				if not state.quotes then
					table.insert(state.chunks, {
						start_line_pos = line_pos,
						stop_line_pos = chunk_line_pos,

						start_char_pos = char_pos,
						stop_char_pos = chunk_char_pos,

						chunk = table.concat(state.chunk),
						type = "string",
					})
					table.clear(state.chunk)
				end
			elseif char == "`" and not state.quotes then
				local length = 0

				for offset = 0, 32 do
					if code:sub(i + offset, i + offset) ~= "`" then
						length = offset
						break
					end
				end

				local stop

				local count = 0
				for i = i + length, #code do
					local c = code:sub(i, i)

					if code:sub(i-1, i-1) ~= "\\" then
						if c == "`" then
							count = count + 1
						else
							count = 0
						end

						if count == length then
							stop = i - length
							break
						end
					end
				end

				if not stop then
					return compile_error(state, "cannot find the end of multiline quote")
				end

				state.multiline_quotes_stop = stop + length

				table.insert(state.chunk, char)
			else
				if state.quotes or state.multiline_quotes then
					table.insert(state.chunk, char)
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
							table.insert(state.chunks, {
								char_pos = state.char_pos,
								line_pos = state.line_pos,
								chunk = table.concat(state.chunk),
								type = state.last_type,
							})
							table.clear(state.chunk)
						end
					end

					if t ~= "space" then
						table.insert(state.chunk, char)
					end
				end
			end
		end

		if char == "\n" then
			state.line_pos = state.line_pos + 1
			state.char_pos = 1
		end

		state.char_pos = state.char_pos + 1
		state.last_char = char
		state.sub_pos = i
		state.last_type = t

		i = i + 1
	end

	return state.chunks
end

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

	return parse_calls_and_assignments(out)
end

local function compile(code)
	return parse_scopes(parse_operator_scopes(assert(parse_strings_and_numbers(code))))
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
]]

code = [[lol = function(a,b,c) print(1,2,3) print((1+5)+5) end]]
code = [[print((1==1) and true or false,2,function(...) print(1,2,3,...) end,1+2+3+4)]]

local function parse_statement(data)
	local out = ""
	if data.left then
		out = out .. "(" .. parse_statement(data.left) .. data.type .. parse_statement(data.right) .. ")"
	else
		out = out .. data.chunk
	end
	return out
end

local function dump_tree(tree, indent)
	local str = ""
	indent = indent or 0
	for _, data in ipairs(tree) do
		str = str .. ("\t"):rep(indent)

		if data.type == "assignment" then
			str = str .. data.left.chunk .. " = " .. parse_statement(data.right)
		end
	end
	return str
end

local tree = parse_scopes(parse_strings_and_numbers(code))
table.print(tree)