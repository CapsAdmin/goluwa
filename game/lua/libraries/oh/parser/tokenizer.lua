local META = ... or oh.parser_meta

--[[
space,	2785639
symbol,	303452
letter,	289552
number,	50520
string,	14888
line_comment,	9163
multiline_comment,	265
]]

local function AddTokenClass(tbl)
	tbl.Priority = tbl.Priority or 0
	table.insert(META.TokenClasses, tbl)
	table.sort(META.TokenClasses, function(a, b)
		return a.Priority > b.Priority
	end)
end


META.TokenClasses = {}

local function CaptureLiteralString(self, i)
	local stop
	local length = 0
	local start = i

	local c = self:GetChar(i)
	if c ~= "[" then return nil, "expected [ got " .. c end

	i = i + 1

	for offset = i, self.code_length do
		if self:GetChar(offset) ~= "=" then
			i = offset
			break
		end
	end

	local c = self:GetChar(i)
	if c ~= "[" then return nil, "expected [ got " .. c end

	length = i - start + 1

	if length < 2 then return nil end

	local closing = "]" .. ("="):rep(length - 2) .. "]"

	for i = i + length, #self.code do
		if self:GetChars(i, i + length - 1) == closing then
			return i + length - 1
		end
	end

	return nil, "strange string"
end

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
	local Token = {}

	Token.Type = "multiline_comment"
	Token.Priority = 100

	function Token:Is(i)
		return self:GetChars(i, i + 3) == "--[=" or self:GetChars(i, i + 3) == "--[["
	end

	function Token:Capture(i)
		i = i + 2
		local stop, err = CaptureLiteralString(self, i)

		if not stop and err then
			self:Error("cannot find the end of literal quote: " .. err, i, i)
		end

		return stop
	end

	AddTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "line_comment"
	Token.Priority = 99

	function Token:Is(i)
		return self:GetChars(i, i + oh.syntax.line_comment_length - 1) == oh.syntax.line_comment
	end

	function Token:Capture(i)
		for i = i + oh.syntax.line_comment_length, self.code_length do
			if self:GetChar(i) == "\n" or i == self.code_length then
				return i
			end
		end
	end

	AddTokenClass(Token)
end

for _, quote in ipairs({oh.syntax.single_quote, oh.syntax.double_quote}) do
	local Token = {}

	Token.Type = "string"

	function Token:Is(i)
		return self:GetChar(i) == quote
	end

	function Token:Capture(i)
		for i = i + 1, self.code_length do
			local char = self:GetChar(i)
			if not self:StringEscape(char) and char == quote then
				return i
			end
		end

		self:Error("cannot find the end of double quote", start, start)
	end

	AddTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "string"
	Token.Priority = 1000

	function Token:Is(i)
		return self:GetChars(i, i + 1) == "[=" or self:GetChars(i, i + 1) == "[["
	end

	function Token:Capture(i)
		local stop, err = CaptureLiteralString(self, i)

		if not stop and err then
			self:Error("cannot find the end of literal quote: " .. err, i, i)
		end

		return stop
	end

	AddTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "number"
	Token.Priority = 1000

	function Token:CaptureAnnotations(i)
		for _, annotation in ipairs(oh.syntax.legal_number_annotations) do
			local len = #annotation - 1
			if self:GetChars(i, i + len):lower() == annotation then
				local t = self:GetCharType(i + len + 1)

				if t == "space" or t == "symbol" then
					return i + len
				end
			end
		end
	end

	function Token:Is(i)
		if self:GetChar(i) == "." and self:GetCharType(i + 1) == "number" then
			return true
		end

		return self:GetCharType(i) == "number"
	end

	function Token:CaptureHexNumber(i)
		local stop

		local pow = false

		for offset = i + 2, i + 64 do
			local stop = Token.CaptureAnnotations(self, offset)
			if stop then return stop end

			local char = self:GetChar(offset):lower()
			local t = self:GetCharType(offset)

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
					return offset - 1
				elseif char == "symbol" or t == "letter" then
					self:Error("malformed number: invalid character '" .. char .. "'. only abcdef0123456789_ allowed after hex notation", i, offset)
				end
			end
		end
	end

	function Token:CaptureBinaryNumber(i)
		local stop

		for offset = i + 2, i + 64 do
			local char = self:GetChar(offset):lower()
			local t = self:GetCharType(offset)

			if char ~= "1" and char ~= "0" and char ~= "_" then
				if not t or t == "space" or t == "symbol" then
					stop = offset - 1
					break
				elseif char == "symbol" or t == "letter" or (char ~= "0" and char ~= "1") then
					self:Error("malformed number: only 01_ allowed after binary notation", i, offset)
				end
			end
		end

		return stop
	end

	function Token:CaptureNumber(i)
		local stop

		local found_dot = false
		local exponent = false

		for offset = i, self.code_length+1 do
			local char = self:GetChar(offset)
			local t = self:GetCharType(offset)

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
					else
						local stop = Token.CaptureAnnotations(self, offset)
						if stop then return stop end

						self:Error("malformed number: invalid character '" .. char .. "'. only " .. table.concat(Token.Annotations, ", ") .. " allowed after a number", i, offset)
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

		return stop
	end


	function Token:Capture(i)
		if self:GetChar(i + 1):lower() == "x" then
			return Token.CaptureHexNumber(self, i)
		elseif self:GetChar(i + 1):lower() == "b" then
			return Token.CaptureBinaryNumber(self, i)
		end

		return Token.CaptureNumber(self, i)
	end

	AddTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "symbol"
	Token.Priority = -1000

	function Token:Is(i)
		return self:GetCharType(i) == "symbol"
	end

	function Token:Capture(i)
		for len = oh.syntax.longest_symbol - 1, 0, -1 do
			if oh.syntax.symbols_lookup[self:GetChars(i, i + len)] then
				return i + len
			end
		end
	end

	AddTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "letter"

	function Token:Is(i)
		return self:GetCharType(i) == "letter"
	end

	function Token:Capture(i)
		for offset = i, i + 256 do
			local t = self:GetCharType(offset)

			if not (t == "letter" or t == "number" and offset ~= i) then
				return offset - 1
			end
		end

		return i
	end

	AddTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "space"

	function Token:Is(i)
		return self:GetCharType(i) == "space"
	end

	function Token:Capture(i)
		for offset = i, self.code_length  do
			if self:GetCharType(offset) ~= "space" then
				return offset - 1
			end
		end

		return i
	end

	AddTokenClass(Token)
end

do -- shebang
	local Token = {}

	Token.Type = "shebang"

	function Token:Is(i)
		return i == 1 and self:GetChar(i) == "#"
	end

	function Token:Capture(i)
		for i = 1, self.code_length do
			if self:GetChar(i) == "\n" then
				return i + 1
			end
		end
	end

	AddTokenClass(Token)
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

function META:GetCharType(i)
	return oh.syntax.char_types[self.code:sub(i, i)]
end

function META:GetChars(a, b)
	return self.code:sub(a, b)
end

function META:Tokenize()

	local i = 1
	for _ = 1, self.code_length + 1 do
		local t = self:GetCharType(i)

		if not t then
			self:Error("unknown symbol >>" .. self:GetChar(i) .. "<< (" .. self:GetChar(i):byte() .. ")", i, i)
		end

		for _, class in ipairs(self.TokenClasses) do
			if class.Is(self, i) then
				local start = i
				i = class.Capture(self, i)
				if not i then
					self:Error("unable to capture " .. class.Type, start, start)
				end
				self:AddToken(class.Type, start, i)
				break
			end
		end

		i = i + 1
	end

end

if RELOAD then

	--print(oh.Tokenize([====[ 10i+5i+5ull+10ul ]====]):Dump()) do return end
	oh.TestAllFiles("/home/caps/goluwa/core")
	oh.TestAllFiles("/home/caps/goluwa/framework")
	oh.TestAllFiles("/home/caps/goluwa/engine")
	oh.TestAllFiles("/home/caps/goluwa/game")
	oh.TestAllFiles("/home/caps/goluwa/lua-5.2.2-tests")
	--oh.TestAllFiles("/home/caps/goluwa/love_games/lovers")
end