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

local function compile(code)
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

	for i = 1, #code + 1 do
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

					if t ~= state.last_type then
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
	end

	return state.chunks
end

local code = [[

lst = [0xdead,5,3,1.523,1.23E+10, 1.23E-10]

str = "hello world"
str2 = ``multiline

string

``

for i, v in lst do
	print(i, v)
end

if false do

else if true do

end

lol_2 = true
]]

for k,v in ipairs(assert(compile(code))) do
	print(v.type, v.chunk)
end