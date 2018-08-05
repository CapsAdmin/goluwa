local kua = ... or _G.kua or {}

kua.syntax = runfile("grammar.lua")

local function compile_error(state, msg, start, stop)
	offset = offset or 0

	local context_start = state.code:sub(math.max(start - 50, 2), start - 1)
	local context_stop = state.code:sub(stop, stop + 50)


	context_start = context_start:gsub("\t", " ")
	context_stop = context_stop:gsub("\t", " ")

	local content_before = #(context_start:reverse():match("(.-)\n") or context_start)
	local content_after = (context_stop:match("(.-)\n") or "")

	local len = math.abs(stop - start)
	local str = (len > 0 and state.code:sub(start, stop - 1) or "") .. content_after .. "\n"

	str = str .. (" "):rep(content_before) .. ("_"):rep(len) .. "^" .. ("_"):rep(#content_after - 1) .. " " .. msg .. "\n"

	str = context_start .. str .. context_stop:sub(#content_after + 1)

	print(str)

	return nil, "\n" .. str
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

local function add_token(state, type, start, stop)
	state.chunks[state.chunks_i] = {
		type = type,
		--value = state.code:sub(start, stop),
		start = start,
		stop = stop,
	}
	state.chunks_i = state.chunks_i + 1
end

local function capture_literal_string(state, i)
	local length = 0

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

function kua.Tokenize(code)
	local state = {}

	state.code = code
	state.code_length = #code

	state.chunks = {}
	state.chunks_i = 1

	local i = 1
	for _ = 1, state.code_length + 1 do
		local char = state.code:sub(i, i)
		local t = kua.syntax.char_types[char]

		if i == 1 and char == "#" then
			local stop = state.code_length
			for i = 1, state.code_length do
				local c = state.code:sub(i, i)

				if c == "\n" then
					stop = i+1
					break
				end
			end

			add_token(state, "shebang", i, stop)

			i = stop

			t = kua.syntax.char_types[char]
		end

		if not t then
			return compile_error(state, "unknown symbol >>" .. char .. "<< (" .. char:byte() .. ")", i, i)
		end

		state.char = char
		state.char_type = t

		if state.code:sub(i, i + #kua.syntax.comment - 1) == kua.syntax.comment then
			i = i + #kua.syntax.comment

			if state.code:sub(i, i) == kua.syntax.literal_quote or is_literal_lua_string(state, i) then
				local stop

				if state.code:sub(i, i) == kua.syntax.literal_quote then
					stop = capture_literal_string(state, i)
				else
					stop = capture_literal_lua_string(state, i)
				end

				if not stop then
					return compile_error(state, "cannot find the end of multiline comment", i, i)
				end

				add_token(state, "comment", i - #kua.syntax.comment, stop)

				i = stop
			else
				local stop

				for i = i + 1, state.code_length do
					local c = state.code:sub(i, i)

					if c == "\n" or i == state.code_length then
						stop = i - 1
						break
					end
				end

				add_token(state, "comment", i - #kua.syntax.comment, stop)

				i = stop
			end
		elseif char == kua.syntax.quote then
			local stop

			for i = i + 1, state.code_length do
				local c = state.code:sub(i, i)

				if not string_escape(state, i) then
					if c == kua.syntax.quote then
						stop = i
						break
					end
				end
			end

			if not stop then
				return compile_error(state, "cannot find the end of double quote", i, i)
			end

			add_token(state, "string", i, stop)

			i = stop
		elseif state.code:sub(i, i) == kua.syntax.literal_quote or is_literal_lua_string(state, i) then
			local stop

			if state.code:sub(i, i) == kua.syntax.literal_quote then
				stop = capture_literal_string(state, i)

				if not stop then
					return compile_error(state, "cannot find the end of literal quote", i, i)
				end
			else
				local stop_, err = capture_literal_lua_string(state, i)
				if not stop_ and err then
					return compile_error(state, "cannot find the end of literal quote: " .. err, i, i)
				end
				stop = stop_
			end

			if stop then
				add_token(state, "string", i, stop)

				i = stop
			end
		elseif char == "'" then
			local stop

			for i = i + 1, state.code_length do
				local c = state.code:sub(i, i)

				if not string_escape(state, i) then
					if c == "'" then
						stop = i
						break
					end
				end
			end

			if not stop then
				return compile_error(state, "cannot find the end of single quote", i, i)
			end

			add_token(state, "string", i, stop)

			i = stop
		elseif t == "number" and state.last_type ~= "letter" then
			if state.code:sub(i + 1, i + 1):lower() == "x" then
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
							char == "p" or
							char == "_"
						)
					then
						if not t or t == "space" or t == "symbol" then
							stop = offset - 1
							break
						elseif char == "symbol" or t == "letter" then
							return compile_error(state, "malformed number: invalid character '" .. char .. "'. only abcdef0123456789_ allowed after hex notation", i, offset)
						end
					end


				end

				add_token(state, "number", i, stop)

				i = stop
			elseif state.code:sub(i + 1, i + 1):lower() == "b" then
				local stop

				for offset = i + 2, i + 64 do
					local char = state.code:sub(offset, offset):lower()
					local t = kua.syntax.char_types[char]

					if char ~= "1" and char ~= "0" and char ~= "_" then
						if not t or t == "space" or t == "symbol" then
							stop = offset - 1
							break
						elseif char == "symbol" or t == "letter" or (char ~= "0" and char ~= "1") then
							return compile_error(state, "malformed number: only 01_ allowed after binary notation", i, offset)
						end
					end
				end

				add_token(state, "number", i, stop)

				i = stop
			else
				local stop

				local found_dot = false
				local exponent = false

				for offset = i, state.code_length+1 do
					local char = state.code:sub(offset, offset)
					local t = kua.syntax.char_types[char]

					if exponent then
						if char ~= "-" and char ~= "+" and t ~= "number" then
							return compile_error(state, "malformed number: invalid character '" .. char .. "'. only +-0123456789 allowed after exponent", i, offset)
						elseif char ~= "-" and char ~= "+" then
							exponent = false
						end
					elseif t ~= "number" then
						if t == "letter" then
							if char:lower() == "e" then
								exponent = true
							elseif char == "_" or (char:lower() == "u" or char:lower() == "l") and state.code:sub(offset+1, offset+1):lower() == "l" then
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
								return compile_error(state, "malformed number: invalid character '" .. char .. "'. only ule allowed after a number", i, offset)
							end
						elseif t == "space" or t == "symbol" then
							stop = offset - 1
							break
						elseif not found_dot and char == "." then
							found_dot = true
						else
							return compile_error(state, "malformed number: invalid character '" .. char .. "'. this should never happen?", i, offset)
						end
					end


				end

				add_token(state, "number", i, stop)

				if not stop then
					return compile_error(state, "malformed number: expected number after exponent", i, i)
				end

				i = stop
			end
		elseif t == "letter" then
			local stop

			local last_type

			for offset = i, i + 256 do
				local char = state.code:sub(offset, offset)
				local t = kua.syntax.char_types[char]

				if t ~= "letter" and (t ~= "number" and last_type == "letter") then
					stop = offset - 1
					break
				else
					t = "letter"
				end

				last_type = t
			end

			if not stop then
				return compile_error(state, "malformed letter: could not find end", i, i)
			end

			add_token(state, "letter", i, stop)

			i = stop
		elseif t == "symbol" then
			for i2 = kua.syntax.longest_symbol - 1, 0, -1 do
				if kua.syntax.symbols_lookup[state.code:sub(i, i+i2)] then
					add_token(state, "symbol", i, i+i2)
					i = i + i2
					break
				end
			end
		end


		state.last_type = t

		i = i + 1
	end

	function state:GetToken(i)
		local info = self.chunks[i]
		if not info then return end
		info.value = info.value or self.code:sub(info.start, info.stop)
		info.i = i
		return info
	end

	state.i = 1

	return state
end

function kua.DumpTokens(state, err)

	--table.print2(state.chunks)

	local start = 0
	for _,v in ipairs(state.chunks) do
		log(
			state.code:sub(start+1, v.start-1),
			"⸢", state.code:sub(v.start, v.stop), "⸥"
		)
		start = v.stop
	end
	log(state.code:sub(start+1))
end