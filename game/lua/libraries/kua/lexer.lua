local kua = ... or _G.kua

kua.syntax = runfile("grammar.lua")

local function compile_error(state, msg)
	local code = state.code:gsub("\t", " ")
	local lines = code:split("\n")
	local str = ""
	local line_pos = state.line_pos
	for i = line_pos - 15, line_pos + 15 do
		if lines[i] then
			str = str .. i .. ": "
			if i == line_pos then
				local line = lines[i]
				str = str .. line .. "\n"
				str = str .. (" "):rep(state.char_pos + #(i .. ": ")) .. "^ : " .. msg .. "\n"
			else
				str = str .. lines[i] .. "\n"
			end
		end
	end

	return nil, str
end

local function string_escape(state, i)
	if state.string_escape then
		state.string_escape = false
		return true
	end

	if state.code:sub(i, i) == kua.syntax.escape_character then
		state.string_escape = true
	end
end

local function add_token(state, tbl)
	tbl.char_pos = state.char_pos
	tbl.line_pos = state.line_pos

	state.chunks[state.chunks_i] = tbl
	state.chunks_i = state.chunks_i + 1
end

local function flush(state)
	local res = table.concat(state.chunk)
	local type = state.last_type

	if kua.syntax.keywords[res] then
		type = "keyword"
	end

	if type ~= "space" then
		local operator_precedence = kua.syntax.operator_precedence[res]

		if res == "=" then
			type = "assignment"
		elseif operator_precedence then
			type = "operator"
		end

		add_token(state, {
			type = type,
			value = res,
			is_value = kua.syntax.keyword_values[res] ~= nil,
			precedence = operator_precedence,
		})
	end
	table.clear(state.chunk)
	state.chunk_i = 1
end

local function advance(state, char)
	if char == "\n" then
		state.line_pos = state.line_pos + 1
		state.char_pos = 1
	end

	state.char_pos = state.char_pos + 1
end

local function capture_literal_string(state, i)
	local length = 0

	local char_pos = state.char_pos
	local line_pos = state.line_pos

	for offset = 0, 32 do
		if state.code:sub(i + offset, i + offset) ~= kua.syntax.literal_quote then
			length = offset
			break
		end
	end

	local stop

	local count = 0
	for i = i + length, #state.code do
		local c = state.code:sub(i, i)

		advance(state, c)

		if not string_escape(state, i) then
			if c == kua.syntax.literal_quote then
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

	return stop
end

local function is_literal_lua_string(state, i)
	return
		state.code:sub(i, i) == "[" and
		(
			state.code:sub(i+1, i+1) == "[" or
			state.code:sub(i+1, i+1) == "="
		)
end

local function capture_literal_lua_string(state, i)
	local stop
	local length = 0

	local start = i

	for i = start, #state.code do
		local c = state.code:sub(i, i)
		if
			(c == "[" and i == start) or
			(c == "=" and length > 0)
		then
			length = length + 1
		elseif length > 0 and c == "[" then
			length = length + 1
			break
		end
	end

	if length < 2 then return nil end

	for i = i + length, #state.code do
		local c = state.code:sub(i, i)

		if c == "]" then
			local length = length
			for i2 = i, i + length do
				local c = state.code:sub(i2, i2)
				if c == "]" or c == "=" then
					length = length - 1
				elseif length == 0 then
					stop = i2 - 1
					break
				end
			end
			if stop then break end
		end
	end

	if not stop then
		return nil, "strange string"
	end

	return stop
end

function kua.Lexify(code)
	local state = {}

	state.code = code
	state.code_length = #code

	state.chunks = {}
	state.chunks_i = 1

	state.chunk = {}
	state.chunk_i = 1

	state.chunk_line_pos = nil
	state.chunk_char_pos = nil

	state.char_pos = 1
	state.line_pos = 1
	state.sub_pos = 1

	state.last_char = ""

	local i = 1
	for _ = 1, state.code_length + 1 do
		local char = state.code:sub(i, i)
		local t = kua.syntax.char_types[char]

		if i == 1 and char == "#" then
			local stop = state.code_length
			for i = 1, state.code_length do
				local c = state.code:sub(i, i)
				advance(state, c)
				if c == "\n" then
					stop = i+1
					break
				end
			end

			add_token(state, {
				type = "shebang",
				value = state.code:sub(i, stop),
			})

			i = stop

			char = state.code:sub(i, i)
			t = kua.syntax.char_types[char]
		end

		if not t then
			return compile_error(state, "unknown symbol >>" .. char .. "<< (" .. char:byte() .. ")")
		end

		state.char = char
		state.char_type = t

		if state.code:sub(i, i + #kua.syntax.comment - 1) == kua.syntax.comment then

			for i = i, i + #kua.syntax.comment - 1 do
				advance(state, state.code:sub(i, i))
			end

			i = i + #kua.syntax.comment

			if state.code:sub(i, i) == kua.syntax.literal_quote or is_literal_lua_string(state, i) then
				local stop

				if state.code:sub(i, i) == kua.syntax.literal_quote then
					stop = capture_literal_string(state, i)
				else
					stop = capture_literal_lua_string(state, i)
				end

				if not stop then
					return compile_error(state, "cannot find the end of multiline comment")
				end

				add_token(state, {
					type = "string",
					value = state.code:sub(i - #kua.syntax.comment, stop),
				})

				i = stop
			else
				local stop

				for i = i + 1, state.code_length do
					local c = state.code:sub(i, i)

					if c == "\n" or i == state.code_length then
						stop = i - 1
						break
					else
						advance(state, c)
					end
				end

				add_token(state, {
					type = "comment",
					value = state.code:sub(i - #kua.syntax.comment, stop),
				})

				i = stop

				char = state.code:sub(i, i)
			end
		elseif char == kua.syntax.quote then
			flush(state)

			local stop

			local char_pos = state.char_pos
			local line_pos = state.line_pos

			for i = i + 1, state.code_length do
				local c = state.code:sub(i, i)

				advance(state, c)

				if not string_escape(state, i) then
					if c == kua.syntax.quote then
						stop = i
						break
					end
				end
			end

			if not stop then
				state.char_pos = char_pos
				state.line_pos = line_pos
				state.sub_pos = sub_pos
				return compile_error(state, "cannot find the end of double quote")
			end

			add_token(state, {
				type = "string",
				value = state.code:sub(i, stop),
			})

			i = stop
		elseif state.code:sub(i, i) == kua.syntax.literal_quote or is_literal_lua_string(state, i) then
			flush(state)

			local stop

			local char_pos = state.char_pos
			local line_pos = state.line_pos

			if state.code:sub(i, i) == kua.syntax.literal_quote then
				stop = capture_literal_string(state, i)

				if not stop then
					state.char_pos = char_pos
					state.line_pos = line_pos
					state.sub_pos = sub_pos
					return compile_error(state, "cannot find the end of literal quote")
				end
			else
				local stop_, err = capture_literal_lua_string(state, i)
				if not stop_ and err then
					return compile_error(state, "cannot find the end of literal quote: " .. err)
				end
				stop = stop_
			end

			if stop then
				add_token(state, {
					type = "string",
					value = state.code:sub(i, stop),
				})

				i = stop
			end
		elseif char == "'" then
			flush(state)

			local stop

			local char_pos = state.char_pos
			local line_pos = state.line_pos

			for i = i + 1, state.code_length do
				local c = state.code:sub(i, i)

				advance(state, c)

				if not string_escape(state, i) then
					if c == "'" then
						stop = i
						break
					end
				end
			end

			if not stop then
				state.char_pos = char_pos
				state.line_pos = line_pos
				state.sub_pos = sub_pos
				return compile_error(state, "cannot find the end of single quote")
			end

			add_token(state, {
				type = "string",
				value = state.code:sub(i, stop),
			})

			i = stop
		elseif t == "number" and state.last_type ~= "letter" then
			if state.code:sub(i + 1, i + 1):lower() == "x" then
				flush(state)

				local stop
				local pow = false
				for offset = i + 2, i + 64 do
					local char = state.code:sub(offset, offset):lower()
					local t = kua.syntax.char_types[char]

					if (char:lower() == "u" or char:lower() == "l") and state.code:sub(offset+1, offset+1):lower() == "l" then
						if state.code:sub(offset+2, offset+2):lower() == "l" then
							stop = offset + 2
						else
							stop = offset + 1
						end

						local char = state.code:sub(stop+1, stop+1)
						local t = kua.syntax.char_types[char]

						if t == "space" or t == "symbol" then
							break
						end
					end

					if char == "p" then
						if not pow then
							pow = true
						else
							return compile_error(state, "malformed number: pow character can only be used once")
						end
					end

					if
						not (
							t == "number" or
							char == "a" or
							char == "b" or
							char == "c" or
							char == "d" or
							char == "e" or
							char == "f" or
							char == "p"
						)
					then
						if not t or t == "space" or t == "symbol" then
							stop = offset - 1
							break
						elseif char == "symbol" or t == "letter" then
							return compile_error(state, "malformed number: invalid character '" .. char .. "'. Only abcdef0123456789 allowed after hex notation")
						end
					end

					advance(state, char)
				end

				add_token(state, {
					type = "number",
					value = state.code:sub(i, stop),
				})

				i = stop
			elseif state.code:sub(i + 1, i + 1):lower() == "b" then
				flush(state)

				local stop
				for offset = i + 2, i + 64 do
					local char = state.code:sub(offset, offset):lower()
					local t = kua.syntax.char_types[char]

					if char ~= "1" and char ~= "0" then
						if not t or t == "space" or t == "symbol" then
							stop = offset - 1
							break
						elseif char == "symbol" or t == "letter" or (char ~= "0" and char ~= "1") then
							return compile_error(state, "malformed number: only 0 or 1 allowed after binary notation")
						end
					end

					advance(state, char)
				end

				add_token(state, {
					type = "number",
					value = state.code:sub(i, stop),
				})

				i = stop
			else
				flush(state)

				local stop
				local found_dot = false
				local exponent = false

				for offset = i, state.code_length+1 do
					local char = state.code:sub(offset, offset)
					local t = kua.syntax.char_types[char]

					if exponent then
						if char == "-" or char == "+" then

						else
							exponent = false
						end
					elseif t ~= "number" then
						if t == "letter" then
							if char:lower() == "e" then
								exponent = true
							elseif (char:lower() == "u" or char:lower() == "l") and state.code:sub(offset+1, offset+1):lower() == "l" then
								if state.code:sub(offset+2, offset+2):lower() == "l" then
									stop = offset + 2
								else
									stop = offset + 1
								end

								local char = state.code:sub(stop+1, stop+1)
								local t = kua.syntax.char_types[char]

								if t == "space" or t == "symbol" then
									break
								end
							else
								return compile_error(state, "malformed number")
							end
						elseif t == "space" or t == "symbol" then
							stop = offset - 1
							break
						elseif not found_dot and char == "." then
							found_dot = true
						else
							return compile_error(state, "malformed number")
						end
					end

					advance(state, char)
				end

				add_token(state, {
					type = "number",
					value = state.code:sub(i, stop),
				})

				if not stop then return compile_error(state, "malformed number") end

				i = stop
			end
		else
			if state.last_type == "letter" and (char == "_" or t == "number") then
				t = "letter"
			end

			if kua.syntax.symbol_priority_lookup[char] then
				for _, token in ipairs(kua.syntax.symbol_priority) do
					if state.code:sub(i, i + #token - 1) == token then
						char = token
						i = i + #token - 1
						break
					end
				end
			end

			if t ~= state.last_type or t == "symbol" then
				if state.chunk[1] then
					flush(state)
				end
			end

			if t ~= "space" then
				state.chunk[state.chunk_i] = char
				state.chunk_i = state.chunk_i + 1
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

function kua.DumpTokens(tokens)
	local temp = {}
	for i,v in ipairs(tokens) do
		temp[v.line_pos] = temp[v.line_pos] or {}
		v.char_length = v.char_pos - (tokens[i - 1] and tokens[i - 1].char_pos or v.char_pos)
		table.insert(temp[v.line_pos], v)
	end

	local char_pos = 0

	for k,line in pairs(temp) do
		log(k, ": ")
		table.sort(line, function(a, b) return a.char_pos < b.char_pos end)
		for _,v in ipairs(line) do
			log(v.value, " ")
		end
		logn()
	end
end

if false and RELOAD then
	local tokens, err = kua.Lexify([====[
		asdf2 = true and false or nil
		--test
		--`ww
			wwtest
		`
		asdf = [[hello]]
		asdf = "helloawdawda\nadwadadad"
		asdf2 = true and false or nil

		if a == true then
			print(0xf5)
		end
	]====])

	if tokens then
		kua.DumpTokens(tokens)
	else
		print(err, "!?!")
	end
end