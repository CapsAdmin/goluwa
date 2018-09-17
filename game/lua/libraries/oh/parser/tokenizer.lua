local META = ... or oh.parser_meta

local escape = false
local function string_escape(self, c, i)
	if escape then
		escape = false
		return true
	end

	if c == oh.syntax.escape_character then
		escape = true
	end

	return false
end

local function add_token(self, type, start, stop)
	self.chunks[self.chunks_i] = {
		type = type,
		value = self:GetChars(start, stop),
		start = start,
		stop = stop,
	}
	self.chunks_i = self.chunks_i + 1
end

local function capture_literal_string(self, i)
	if self:GetChar(i) == oh.syntax.literal_quote then
		local length = 0

		for offset = 0, 32 do
			if self:GetChar(i + offset) ~= oh.syntax.literal_quote then
				length = offset
				break
			end
		end

		local stop

		local count = 0
		for i = i + length, #self.code do
			local c = self:GetChar(i)

			if not string_escape(self, c, i) then
				if c == oh.syntax.literal_quote then
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
	else
		local stop
		local length = 0

		local start = i

		for i = start, #self.code do
			local c = self:GetChar(i)
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

		local closing = "]" .. ("="):rep(length - 2) .. "]"

		for i = i + length, #self.code do
			if self:GetChars(i, i + length - 1) == closing then
				stop = i + length - 1
				break
			end
		end

		if not stop then
			return nil, "strange string"
		end

		return stop
	end
end

local function is_literal_string(self, i)
	return
		self:GetChar(i) == oh.syntax.literal_quote or
		self:GetChars(i, i + 1) == "[=" or
		self:GetChars(i, i + 1) == "[["
end

function META:GetChar(i)
	return self.code:sub(i, i)
end

function META:GetChars(a, b)
	return self.code:sub(a, b)
end

function META:Tokenize()
	local i = 1
	for _ = 1, self.code_length + 1 do
		local char = self:GetChar(i)

		if i == 1 and char == "#" then
			local stop = self.code_length
			for i = 1, self.code_length do
				local c = self:GetChar(i)

				if c == "\n" then
					stop = i+1
					break
				end
			end

			--add_token(self, "shebang", i, stop)

			i = stop
		end

		local t = oh.syntax.char_types[char]

		if not t then
			self:Error("unknown symbol >>" .. char .. "<< (" .. char:byte() .. ")", i, i)
		end

		if self:GetChars(i, i + #oh.syntax.c_comment_start - 1) == oh.syntax.c_comment_start then
			i = i + #oh.syntax.c_comment_start

			local stop

			for i = i, self.code_length do
				if self:GetChars(i, i + #oh.syntax.c_comment_stop - 1) == oh.syntax.c_comment_stop then
					i = i + #oh.syntax.c_comment_stop
					stop = i
					break
				end
			end

			--add_token(self, "comment", i - #oh.syntax.c_comment_stop, stop)

			i = stop
		elseif self:GetChars(i, i + #oh.syntax.cpp_comment - 1) == oh.syntax.cpp_comment then
			i = i + #oh.syntax.cpp_comment

			local stop

			for i = i, self.code_length do
				local c = self:GetChar(i)

				if c == "\n" or i == self.code_length then
					stop = i
					break
				end
			end

			--add_token(self, "comment", i - #oh.syntax.comment, stop)

			i = stop
		elseif self:GetChars(i, i + #oh.syntax.comment - 1) == oh.syntax.comment then
			i = i + #oh.syntax.comment

			if is_literal_string(self, i) then
				local stop = capture_literal_string(self, i)

				if not stop then
					self:Error("cannot find the end of multiline comment", i, i)
				end

				--add_token(self, "comment", i - #oh.syntax.comment, stop)

				i = stop
			else
				local stop

				for i = i, self.code_length do
					local c = self:GetChar(i)

					if c == "\n" or i == self.code_length then
						stop = i
						break
					end
				end

				--add_token(self, "comment", i - #oh.syntax.comment, stop)

				i = stop
			end
		elseif char == oh.syntax.quote then
			local stop

			for i = i + 1, self.code_length do
				local c = self:GetChar(i)
				if not string_escape(self, c, i) then
					if c == oh.syntax.quote then
						stop = i
						break
					end
				end
			end

			if not stop then
				self:Error("cannot find the end of double quote", i, i)
			end

			add_token(self, "string", i, stop)

			i = stop
		elseif is_literal_string(self, i) then
			local stop, err = capture_literal_string(self, i)

			if not stop and err then
				self:Error("cannot find the end of literal quote: " .. err, i, i)
			end

			add_token(self, "string", i, stop)

			i = stop
		elseif char == "'" then
			local stop

			for i = i + 1, self.code_length do
				local c = self:GetChar(i)
				if not string_escape(self, c, i) then
					if c == "'" then
						stop = i
						break
					end
				end
			end

			if not stop then
				self:Error("cannot find the end of single quote", i, i)
			end

			add_token(self, "string", i, stop)

			i = stop
		elseif
			t == "number" and self.last_type ~= "letter" or
			(char == "." and oh.syntax.char_types[self:GetChar(i + 1)]) == "number"
		then
			if self:GetChar(i + 1):lower() == "x" then
				local stop

				local pow = false
				for offset = i + 2, i + 64 do
					local char = self:GetChar(offset):lower()
					local t = oh.syntax.char_types[char]

					if (char == "u" or char == "l") and self:GetChar(offset+1):lower() == "l" then
						if self:GetChar(offset+2):lower() == "l" then
							stop = offset + 2
						else
							stop = offset + 1
						end

						local char = self:GetChar(stop+1)
						local t = oh.syntax.char_types[char]

						if t == "space" or t == "symbol" then
							break
						end
					end

					if char == "p" then
						if not pow then
							pow = true
						else
							self:Error("malformed number: pow character can only be used once")
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
							char == "_" or
							char == "." or
							((char == "+" or char == "-") and self:GetChar(offset-1):lower() == "p")
						)
					then
						if not t or t == "space" or t == "symbol" then
							stop = offset - 1
							break
						elseif char == "symbol" or t == "letter" then
							self:Error("malformed number: invalid character '" .. char .. "'. only abcdef0123456789_ allowed after hex notation", i, offset)
						end
					end


				end

				add_token(self, "number", i, stop)

				i = stop
			elseif self:GetChar(i + 1):lower() == "b" then
				local stop

				for offset = i + 2, i + 64 do
					local char = self:GetChar(offset):lower()
					local t = oh.syntax.char_types[char]

					if char ~= "1" and char ~= "0" and char ~= "_" then
						if not t or t == "space" or t == "symbol" then
							stop = offset - 1
							break
						elseif char == "symbol" or t == "letter" or (char ~= "0" and char ~= "1") then
							self:Error("malformed number: only 01_ allowed after binary notation", i, offset)
						end
					end
				end

				add_token(self, "number", i, stop)

				i = stop
			else
				local stop

				local found_dot = false
				local exponent = false

				for offset = i, self.code_length+1 do
					local char = self:GetChar(offset)
					local t = oh.syntax.char_types[char]

					if exponent then
						if char ~= "-" and char ~= "+" and t ~= "number" then
							self:Error("malformed number: invalid character '" .. char .. "'. only +-0123456789 allowed after exponent", i, offset)
						elseif char ~= "-" and char ~= "+" then
							exponent = false
						end
					elseif t ~= "number" then
						if t == "letter" then
							if char:lower() == "e" then
								exponent = true
							elseif char == "_" or (char:lower() == "u" or char:lower() == "l") and self:GetChar(offset+1):lower() == "l" then
								if self:GetChar(offset+2):lower() == "l" then
									stop = offset + 2
								else
									stop = offset + 1
								end

								local char = self:GetChar(stop+1)
								local t = oh.syntax.char_types[char]

								if t == "space" or t == "symbol" then
									break
								end
							else
								self:Error("malformed number: invalid character '" .. char .. "'. only ule allowed after a number", i, offset)
							end
						elseif not found_dot and char == "." then
							found_dot = true
						elseif t == "space" or t == "symbol" then
							stop = offset - 1
							break
						else
							self:Error("malformed number: invalid character '" .. char .. "'. this should never happen?", i, offset)
						end
					end


				end

				add_token(self, "number", i, stop)

				if not stop then
					self:Error("malformed number: expected number after exponent", i, i)
				end

				i = stop
			end
		elseif t == "letter" then
			local stop

			local last_type

			for offset = i, i + 256 do
				local char = self:GetChar(offset)
				local t = oh.syntax.char_types[char]

				if t ~= "letter" and (t ~= "number" and last_type == "letter") then
					stop = offset - 1
					break
				else
					t = "letter"
				end

				last_type = t
			end

			if not stop then
				self:Error("malformed letter: could not find end", i, i)
			end

			add_token(self, "letter", i, stop)

			i = stop
		elseif t == "symbol" then
			for i2 = oh.syntax.longest_symbol - 1, 0, -1 do
				if oh.syntax.symbols_lookup[self:GetChars(i, i+i2)] then
					add_token(self, "symbol", i, i+i2)
					i = i + i2
					break
				end
			end
		end

		self.last_type = t

		i = i + 1
	end
end