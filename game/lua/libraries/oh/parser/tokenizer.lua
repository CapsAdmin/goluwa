local META = ... or oh.parser_meta

function META:StringEscape(c)
	if self.string_escape then
		self.string_escape = false
		return true
	end

	if c == oh.syntax.escape_character then
		self.string_escape = true
	end

	return false
end

do
	function META:IsLineComment(i)
		return self:GetChars(i, i + #oh.syntax.comment - 1) == oh.syntax.comment
	end

	function META:CaptureLineComment(i)
		local start = i
		local stop

		i = i + #oh.syntax.comment

		if self:IsLiteralString(i) then
			stop = self:CaptureLiteralString(i)

			if stop then
				self:AddToken("multiline_comment", start, stop)
				return stop
			end
		end

		for i = i, self.code_length do
			local c = self:GetChar(i)

			if c == "\n" or i == self.code_length then
				self:AddToken("line_comment", start, i)
				return i
			end
		end
	end
end

do
	function META:IsQuotedString(i, quote)
		return self:GetChar(i) == quote
	end

	function META:CaptureQuotedString(i, quote)
		local start = i

		for i = i + 1, self.code_length do
			local char = self:GetChar(i)
			if not self:StringEscape(char) and char == quote then
				self:AddToken("string", start, i)
				return i
			end
		end

		self:Error("cannot find the end of double quote", start, start)
	end
end

do
	function META:IsLiteralString(i)
		return
			self:GetChar(i) == oh.syntax.literal_quote or
			self:GetChars(i, i + 1) == "[=" or
			self:GetChars(i, i + 1) == "[["
	end

	function META:CaptureLiteralString(i)
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

				if not self:StringEscape(c) then
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

			return stop, length
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

			return stop, length
		end
	end
end

do
	function META:IsNumber(i)
		-- .1234
		if self:GetChar(i) == "." and oh.syntax.char_types[self:GetChar(i + 1)] == "number" then
			return true
		end

		return oh.syntax.char_types[self:GetChar(i)] == "number" and self.last_type ~= "letter"
	end

	function META:CaptureHexNumber(i)
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

				local char = self:GetChar(stop + 1)
				local t = oh.syntax.char_types[char]

				if t == "space" or t == "symbol" then
					return stop
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
					self:AddToken("number", i, offset - 1)
					return offset - 1
				elseif char == "symbol" or t == "letter" then
					self:Error("malformed number: invalid character '" .. char .. "'. only abcdef0123456789_ allowed after hex notation", i, offset)
				end
			end
		end
	end

	function META:CaptureBinaryNumber(i)
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

		self:AddToken("number", i, stop)

		return stop
	end

	function META:CaptureNumber(i)
		if self:GetChar(i + 1):lower() == "x" then
			return self:CaptureHexNumber(i)
		elseif self:GetChar(i + 1):lower() == "b" then
			return self:CaptureBinaryNumber(i)
		end

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
					elseif char:lower() == "i" then
						stop = offset + 1
						break
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

		if not stop then
			self:Error("malformed number: expected number after exponent", i, i)
		end

		self:AddToken("number", i, stop)

		return stop
	end
end

do
	function META:IsSymbol(i)
		return oh.syntax.char_types[self:GetChar(i)] == "symbol"
	end

	function META:CaptureSymbol(i)
		for i2 = oh.syntax.longest_symbol - 1, 0, -1 do
			if oh.syntax.symbols_lookup[self:GetChars(i, i+i2)] then
				self:AddToken("symbol", i, i+i2)
				return i + i2
			end
		end
	end
end

do
	function META:IsLetter(i)
		return oh.syntax.char_types[self:GetChar(i)] == "letter"
	end

	function META:CaptureLetter(i)
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

		self:AddToken("letter", i, stop)

		return stop
	end
end

do
	function META:IsSpace(i)
		return oh.syntax.char_types[self:GetChar(i)] == "space"
	end

	function META:CaptureSpace(i)
		local stop

		for offset = i, self.code_length  do
			local char = self:GetChar(offset)
			local t = oh.syntax.char_types[char]

			if t ~= "space" then
				local start = i
				local stop = offset - 1
				self:AddToken("space", i, stop)
				return stop
			end
		end

		return i
	end
end

do
	function META:IsShebang(i)
		return i == 1 and char == "#"
	end

	function META:CaptureShebang(i)
		local stop = self.code_length

		for i = 1, self.code_length do
			local c = self:GetChar(i)

			if c == "\n" then
				stop = i+1
				break
			end
		end

		self:AddToken("shebang", i, stop - 2)

		return stop
	end

end

do
	local comment_buffer = {}

	function META:AddToken(type, start, stop)
		if type == "shebang" then return end

		if type == "line_comment" or type == "multiline_comment" or type == "space" then
			table.insert(comment_buffer, {
				type = type,
				value = self:GetChars(start, stop),
				start = start,
				stop = stop,
			})
			return
		end

		local prev = self.chunks[self.chunks_i - 1]

		self.chunks[self.chunks_i] = {
			type = type,
			value = self:GetChars(start, stop),
			start = start,
			stop = stop,
			whitespace_start = prev and (prev.stop + 1) or 1,
			whitespace_stop = start - 1,
		}

		if comment_buffer[1] then
			self.chunks[self.chunks_i].comments = comment_buffer
			comment_buffer = {}
		end
		self.chunks_i = self.chunks_i + 1
	end
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

		local t = oh.syntax.char_types[char]

		if not t then
			self:Error("unknown symbol >>" .. char .. "<< (" .. char:byte() .. ")", i, i)
		end

		if self:IsShebang(i) then
			i = self:CaptureShebang(i)
		elseif self:IsLineComment(i) then
			i = self:CaptureLineComment(i)
		elseif self:IsQuotedString(i, oh.syntax.double_quote) then
			i = self:CaptureQuotedString(i, oh.syntax.double_quote)
		elseif self:IsQuotedString(i, oh.syntax.single_quote) then
			i = self:CaptureQuotedString(i, oh.syntax.single_quote)
		elseif self:IsLiteralString(i) then
			local stop, err = self:CaptureLiteralString(i)

			if not stop and err then
				self:Error("cannot find the end of literal quote: " .. err, i, i)
			end

			self:AddToken("string", i, stop)

			i = stop
		elseif self:IsNumber(i) then
			i = self:CaptureNumber(i)
		elseif self:IsLetter(i) then
			i = self:CaptureLetter(i)
		elseif self:IsSymbol(i) then
			i = self:CaptureSymbol(i)
		elseif self:IsSpace(i) then
			i = self:CaptureSpace(i)
		end

		self.last_type = t

		i = i + 1
	end
end

if RELOAD then
	oh.Test() do return end
	print(oh.Tokenize([[
		local escape_char_map = {
  [ "\\" ] = "\\\\",
  [ "\"" ] = "\\\"",
}
	]]):Dump())
end