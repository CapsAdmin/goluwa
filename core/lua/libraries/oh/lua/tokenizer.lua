local lua, oh = ...
oh = oh or _G.oh
lua = lua or oh.lua

local builder = oh.CreateBaseTokenizer()
local string_lower = string.lower

local function CaptureLiteralString(self, multiline_comment)
	local start = self.i

	local c = self:ReadChar()
	if c ~= "[" then
		if multiline_comment then return true end
		return nil, "expected "..oh.QuoteToken("[").." got " .. oh.QuoteToken(c)
	end

	if self:GetCurrentChar() == "=" then
		self:Advance(1)

		for _ = self.i, self.code_length do
			if self:GetCurrentChar() ~= "=" then
				break
			end
			self:Advance(1)
		end
	end

	c = self:ReadChar()
	if c ~= "[" then
		if multiline_comment then return true end
		return nil, "expected " .. oh.QuoteToken(self.get_code_char_range(self, start, self.i - 1) .. "[") .. " got " .. oh.QuoteToken(self.get_code_char_range(self, start, self.i - 1) .. c)
	end

	local length = self.i - start

	if length < 2 then return nil end

	local closing = "]" .. string.rep("=", length - 2) .. "]"
	local found = false
	for _ = self.i, self.code_length do
		if self:GetCharsOffset(length - 1) == closing then
			self:Advance(length)
			found = true
			break
		end
		self:Advance(1)
	end

	if not found then
		return nil, "expected "..oh.QuoteToken(closing).." reached end of code"
	end

	return true
end

do
	local Token = {}

	Token.Type = "multiline_comment"
	Token.Whitespace = true
	Token.Priority = 100

	function Token:Is()
		local str = self:GetCharsOffset(3)
		return str == "--[=" or str == "--[["
	end

	function Token:Capture()
		local start = self.i
		self:Advance(2)
		local ok, err = CaptureLiteralString(self, true)
		if not ok then
			self.i = start + 2
			self:Error("unterminated multiline comment: " .. err, start, start + 1)
			return false
		end
		return ok
	end

	builder:RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "line_comment"
	Token.Whitespace = true
	Token.Priority = 99

	local line_comment = "--"

	function Token:Is()
		return self:GetCharsOffset(#line_comment - 1) == line_comment
	end

	function Token:Capture()
		self:Advance(#line_comment)

		for _ = self.i, self.code_length do
			if self:ReadChar() == "\n" or self.i-1 == self.code_length then
				return true
			end
		end
	end

	builder:RegisterTokenClass(Token)
end

do
	local escape_character = "\\"
	local quotes = {
		double = [["]],
		single = [[']],
	}

	for name, quote in pairs(quotes) do
		local Token = {}

		Token.Type = name .. "_quote_string"
		Token.ParserType = "string"

		function Token:Is()
			return self:GetCurrentChar() == quote
		end

		function Token:StringEscape(c)
			if self.string_escape then

				if c == "z" and self:GetCurrentChar() ~= quote then
					self.WhitespaceClasses.space.Capture(self)
				end

				self.string_escape = false
				return true
			end

			if c == escape_character then
				self.string_escape = true
			end

			return false
		end

		function Token:Capture()
			local start = self.i
			self:Advance(1)

			for _ = self.i, self.code_length do
				local char = self:ReadCharByte()

				if not Token.StringEscape(self, char) then

					if char == "\n" then
						self:Advance(-1)
						self:Error("unterminated " .. name .. " quote string", start, self.i - 1)
						return false
					end

					if char == quote then
						return true
					end
				end
			end

			self:Error("unterminated " .. name .. " quote string", start, self.i - 1)

			return false
		end

		builder:RegisterTokenClass(Token)
	end
end

do
	local Token = {}

	Token.Type = "multiline_string"
	Token.ParserType = "string"
	Token.Priority = 1000

	function Token:Is()
		return self:GetCharsOffset(1) == "[=" or self:GetCharsOffset(1) == "[["
	end

	function Token:Capture()
		local start = self.i
		local ok, err = CaptureLiteralString(self, true)
		if not ok then
			self:Error("unterminated multiline string: " .. err, start, start + 1)
			return false
		end
		return ok
	end

	builder:RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "number"
	Token.Priority = 1000

	local allowed = {
		["a"] = true,
		["b"] = true,
		["c"] = true,
		["d"] = true,
		["e"] = true,
		["f"] = true,
		["p"] = true,
		["_"] = true,
		["."] = true,
	}

	local pow_letter = "p"
	local plus_sign = "+"
	local minus_sign = "-"

	local legal_number_annotations = {"ull", "ll", "ul", "i"}
	table.sort(legal_number_annotations, function(a, b) return #a > #b end)

	do
		local code = "local Token, oh = ... function Token:CaptureAnnotations()\n"

		for i, annotation in ipairs(legal_number_annotations) do
			if i == 1 then
				code = code .. "\tif "
			else
				code = code .. "\telseif "
			end

			local len = #annotation
			code = code .. "string.lower(self:GetCharsOffset(" .. (len - 1) .. ")) == '" .. annotation .. "' then\n"
			code = code .. "\t\tlocal t = self:GetCharType(self:GetCharOffset("..len.."))\n"
			code = code .. "\t\tif t == \"space\" or t == \"symbol\" then\n"
			code = code .. "\t\t\tself:Advance("..len..")\n"
			code = code .. "\t\t\treturn true\n"
			code = code .. "\t\tend\n"

		end

		code = code .. "\tend\n"
		code = code .. "\treturn false\nend\n"

		assert(loadstring(code))(Token, oh)
	end

	function Token:CaptureAnnotations()
		for _, annotation in ipairs(legal_number_annotations) do
			local len = #annotation
			if string_lower(self:GetCharsOffset(len - 1)) == annotation then
				local t = self:GetCharType(self:GetCharOffset(len))

				if t == "space" or t == "symbol" then
					self:Advance(len)
					return true
				end
			end
		end
	end

	function Token:Is()
		if self:GetCurrentChar() == "." and self:GetCharType(self:GetCharOffset(1)) == "number" then
			return true
		end

		return self:GetCharType(self:GetCurrentChar()) == "number"
	end

	function Token:CaptureHexNumber()
		self:Advance(2)

		local pow = false

		for _ = self.i, self.code_length do
			if Token.CaptureAnnotations(self) then return true end

			local char = string_lower(self:GetCurrentChar())
			local t = self:GetCharType(self:GetCurrentChar())

			if char == pow_letter then
				if not pow then
					pow = true
				else
					self:Error("malformed number: pow character can only be used once")
					return false
				end
			end

			if not (t == "number" or allowed[char] or ((char == plus_sign or char == minus_sign) and string_lower(self:GetCharOffset(-1)) == pow_letter) ) then
				if not t or t == "space" or t == "symbol" then
					return true
				elseif char == "symbol" or t == "letter" then
					self:Error("malformed number: invalid character "..oh.QuoteToken(char)..". only "..oh.QuoteTokens("abcdef0123456789_").." allowed after hex notation")
					return false
				end
			end

			self:Advance(1)
		end

		return false
	end

	function Token:CaptureBinaryNumber()
		self:Advance(2)

		for _ = self.i, self.code_length do
			local char = string_lower(self:GetCurrentChar())
			local t = self:GetCharType(self:GetCurrentChar())

			if char ~= "1" and char ~= "0" and char ~= "_" then
				if not t or t == "space" or t == "symbol" then
					return true
				elseif char == "symbol" or t == "letter" or (char ~= "0" and char ~= "1") then
					self:Error("malformed number: only "..oh.QuoteTokens("01_").." allowed after binary notation")
					return false
				end
			end

			self:Advance(1)
		end

		return true
	end

	function Token:CaptureNumber()
		local found_dot = false
		local exponent = false

		local start = self.i

		for _ = self.i, self.code_length do
			local t = self:GetCharType(self:GetCurrentChar())
			local char = self:GetCurrentChar()

			if exponent then
				if char ~= "-" and char ~= "+" and t ~= "number" then
					self:Error("malformed number: invalid character " .. oh.QuoteToken(char) .. ". only "..oh.QuoteTokens("+-0123456789").." allowed after exponent", start, self.i)
					return false
				elseif char ~= "-" and char ~= "+" then
					exponent = false
				end
			elseif t ~= "number" then
				if t == "letter" then
					start = self.i
					if string_lower(char) == "e" then
						exponent = true
					elseif Token.CaptureAnnotations(self) then
						return true
					else
						self:Error("malformed number: invalid character " .. oh.QuoteToken(char) .. ". only " .. oh.QuoteTokens(legal_number_annotations) .. " allowed after a number", start, self.i)
						return false
					end
				elseif not found_dot and char == "." then
					found_dot = true
				elseif t == "space" or t == "symbol" then
					return true
				end
			end

			self:Advance(1)
		end
	end

	function Token:Capture()
		local s = string_lower(self:GetCharOffset(1))
		if s == "x" then
			return Token.CaptureHexNumber(self)
		elseif s == "b" then
			return Token.CaptureBinaryNumber(self)
		end

		return Token.CaptureNumber(self)
	end

	builder:RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "symbol"
	Token.Priority = -1000

	function Token:Is()
		return self:GetCharType(self:GetCurrentChar()) == "symbol"
	end

	function Token:Capture()
		for len = lua.syntax.LongestSymbolLength - 1, 0, -1 do
			if lua.syntax.SymbolLookup[self:GetCharsOffset(len)] then
				self:Advance(len + 1)
				return true
			end
		end
	end

	builder:RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "letter"

	function Token:Is()
		return self:GetCharType(self:GetCurrentChar()) == "letter"
	end

	function Token:Capture()
		local start = self.i
		self:Advance(1)
		for _ = self.i, self.code_length do
			local t = self:GetCharType(self:GetCurrentChar())
			if t == "space" or not (t == "letter" or (t == "number" and self.i ~= start)) then
				return true
			end
			self:Advance(1)
		end
	end

	builder:RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "space"
	Token.Whitespace = true

	function Token:Is()
		return self:GetCharType(self:GetCurrentChar()) == "space"
	end

	function Token:Capture()
		self:Advance(1)

		for _ = self.i, self.code_length do
			if self:GetCharType(self:GetCurrentChar()) ~= "space" then
				return true
			end
			self:Advance(1)
		end

		return true
	end

	builder:RegisterTokenClass(Token)
end

do -- shebang
	local Token = {}

	Token.Type = "shebang"

	function Token:Is()
		return self.i == 1 and self:GetCurrentChar() == "#"
	end

	function Token:Capture()
		for _ = self.i, self.code_length do
			if self:ReadChar() == "\n" then
				return true
			end
		end
	end

	builder.ShebangTokenType = Token
end

local config = {}

config.Syntax = lua.syntax

config.CharacterMap = lua.syntax.CharacterMap

for key, val in pairs(lua.syntax.TokenizerSetup) do
	config[key] = val
end

function config.OnError(tk, msg, start, stop)
	table.insert(errors, {msg = msg, start = start, stop = stop})
end

return builder:BuildTokenizer(config)