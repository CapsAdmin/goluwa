local meta = {}
meta.__index = meta

local function quote_token(str)
	return "『" .. str .. "』"
end

local function quote_tokens(var)
	if type(var) == "string" then
		local tbl = {}
		for i = 1, string.len(var) do
			tbl[i] = string.sub(var, i, i)
		end
		var = tbl
	end

	local str = ""
	for i, v in ipairs(var) do
		str = str .. quote_token(v)

		if i == #var - 1 then
			str = str .. " or "
		elseif i ~= #var then
			str = str .. ", "
		end
	end
	return str
end

function meta:BuildLookupTables(syntax)
	self.char_lookup = {}

	for type, chars in pairs(syntax) do
		for i, char in ipairs(chars) do
			self.char_lookup[char] = type
		end
	end

	self.longest_symbol = 0
	self.symbol_lookup = {}

	for char, type in pairs(self.char_lookup) do
		if type == "symbol" then
			self.symbol_lookup[char] = true
			do -- this triggers symbol lookup. For example it adds "~" from "~=" so that "~" is a symbol
				local first_char = self.string_sub(char, 1, 1)
				if not self.char_lookup[first_char] then
					self.char_lookup[first_char] = "symbol"
				end
			end
			self.longest_symbol = math.max(self.longest_symbol, #char)
		end
	end
end

function meta:GetCharType(char)
	return self.char_lookup[char] or self.char_fallback_type
end

function meta:ReadChar()
	local char = self:GetCurrentChar()
	self.i = self.i + 1
	return char
end

function meta:ReadCharByte()
	local b = self:GetCurrentChar()
	self.i = self.i + 1
	return b
end

function meta:Advance(len)
	self.i = self.i + len
end

function meta:GetCharOffset(offset)
	return self.string_sub(self.code, self.i + offset, self.i + offset)
end

function meta:GetCurrentChar()
	return self.string_sub(self.code, self.i, self.i)
end

function meta:GetChars(a, b)
	return self.string_sub(self.code, a, b)
end

function meta:GetCharsOffset(b)
	return self.string_sub(self.code, self.i, self.i + b)
end

function meta:Error(msg, start, stop)
	if self.on_error then
		self:on_error(msg, start or self.i, stop or self.i)
	end
end

function meta:RegisterTokenClass(tbl)
	tbl.ParserType = tbl.ParserType or tbl.Type
	tbl.Priority = tbl.Priority or 0

	self.TokenClasses = self.TokenClasses or {}
	self.WhitespaceClasses = self.WhitespaceClasses or {}

	if tbl.Whitespace then
		self.WhitespaceClasses[tbl.Type] = tbl
	else
		self.TokenClasses[tbl.Type] = tbl
	end
end

meta.TokenClasses = {}

local function CaptureLiteralString(self, multiline_comment)
	local start = self.i

	local c = self:ReadChar()
	if c ~= "[" then
		if multiline_comment then return true end
		return nil, "expected "..quote_token("[").." got " .. quote_token(c)
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
		return nil, "expected " .. quote_token(self.string_sub(self.code, start, self.i - 1) .. "[") .. " got " .. quote_token(self.string_sub(self.code, start, self.i - 1) .. c)
	end

	local length = self.i - start

	if length < 2 then return nil end

	local closing = "]" .. string.rep("=", length - 2) .. "]"

	for _ = self.i, self.code_length do
		if self:GetCharsOffset(length - 1) == closing then
			self:Advance(length)
			break
		end
		self:Advance(1)
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

	meta:RegisterTokenClass(Token)
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

	meta:RegisterTokenClass(Token)
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
					meta.WhitespaceClasses.space.Capture(self)
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

		meta:RegisterTokenClass(Token)
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

	meta:RegisterTokenClass(Token)
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
			code = code .. "self.string_lower(self:GetCharsOffset(" .. (len - 1) .. ")) == '" .. annotation .. "' then\n\z
			\t\tlocal t = self:GetCharType(self:GetCharOffset("..len.."))\n\z
			\t\tif t == \"space\" or t == \"symbol\" then\n\z
				\t\t\tself:Advance("..len..")\n\z
				\t\t\treturn true\n\z
			\t\tend\n"

		end

		code = code .. "\tend\n"
		code = code .. "\treturn false\nend\n"

		assert(loadstring(code))(Token, oh)
	end

	function Token:CaptureAnnotations()
		for _, annotation in ipairs(legal_number_annotations) do
			local len = #annotation
			if self.string_lower(self:GetCharsOffset(len - 1)) == annotation then
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

			local char = self.string_lower(self:GetCurrentChar())
			local t = self:GetCharType(self:GetCurrentChar())

			if char == pow_letter then
				if not pow then
					pow = true
				else
					self:Error("malformed number: pow character can only be used once")
					return false
				end
			end

			if not (t == "number" or allowed[char] or ((char == plus_sign or char == minus_sign) and self.string_lower(self:GetCharOffset(-1)) == pow_letter) ) then
				if not t or t == "space" or t == "symbol" then
					return true
				elseif char == "symbol" or t == "letter" then
					self:Error("malformed number: invalid character "..quote_token(char)..". only "..quote_tokens("abcdef0123456789_").." allowed after hex notation")
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
			local char = self.string_lower(self:GetCurrentChar())
			local t = self:GetCharType(self:GetCurrentChar())

			if char ~= "1" and char ~= "0" and char ~= "_" then
				if not t or t == "space" or t == "symbol" then
					return true
				elseif char == "symbol" or t == "letter" or (char ~= "0" and char ~= "1") then
					self:Error("malformed number: only "..quote_tokens("01_").." allowed after binary notation")
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
					self:Error("malformed number: invalid character " .. quote_token(char) .. ". only "..quote_tokens("+-0123456789").." allowed after exponent", start, self.i)
					return false
				elseif char ~= "-" and char ~= "+" then
					exponent = false
				end
			elseif t ~= "number" then
				if t == "letter" then
					start = self.i
					if self.string_lower(char) == "e" then
						exponent = true
					elseif Token.CaptureAnnotations(self) then
						return true
					else
						self:Error("malformed number: invalid character " .. quote_token(char) .. ". only " .. quote_tokens(legal_number_annotations) .. " allowed after a number", start, self.i)
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
		local s = self.string_lower(self:GetCharOffset(1))
		if s == "x" then
			return Token.CaptureHexNumber(self)
		elseif s == "b" then
			return Token.CaptureBinaryNumber(self)
		end

		return Token.CaptureNumber(self)
	end

	meta:RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "symbol"
	Token.Priority = -1000

	function Token:Is()
		return self:GetCharType(self:GetCurrentChar()) == "symbol"
	end

	function Token:Capture()
		for len = self.longest_symbol - 1, 0, -1 do
			if self.symbol_lookup[self:GetCharsOffset(len)] then
				self:Advance(len + 1)
				return true
			end
		end
	end

	meta:RegisterTokenClass(Token)
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

	meta:RegisterTokenClass(Token)
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

	meta:RegisterTokenClass(Token)
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

	meta.ShebangTokenType = Token
end

do -- eof
	local Token = {}

	Token.Type = "end_of_file"

	function Token:Is()
		return self.i > self.code_length
	end

	function Token:Capture()
		-- nothing to capture, but remaining whitespace will be added
	end

	meta:RegisterTokenClass(Token)
end

function meta:BufferWhitespace(type, start, stop)
	self.whitespace_buffer[self.whitespace_buffer_i] = {
		type = type,
		start = start == 1 and 0 or start,
		stop = stop,
		value = self:GetChars(start, stop),
	}

	self.whitespace_buffer_i = self.whitespace_buffer_i + 1
end

do
	local function tolist(tbl, sort)
		local list = {}
		for key, val in pairs(tbl) do
			table.insert(list, {key = key, val = val})
		end
		table.sort(list, function(a, b) return a.val.Priority > b.val.Priority end)
		return list
	end

	local sorted_token_classes = tolist(meta.TokenClasses)
	local sorted_whitespace_classes = tolist(meta.WhitespaceClasses)

	local code = "local META = ...\nfunction META:CaptureToken()\n"

	code = code .. "\tfor _ = self.i, self.code_length do\n"
	for i, class in ipairs(sorted_whitespace_classes) do
		if i == 1 then
			code = code .. "\t\tif "
		else
			code = code .. "\t\telseif "
		end

		--\t\tprint('capturing "..class.val.Type.."')\n\z
		code = code .. "\z
		META.WhitespaceClasses." .. class.val.Type .. ".Is(self) then\n\z
		\t\t\tlocal start = self.i\n\z
		\t\t\tMETA.WhitespaceClasses." .. class.val.Type .. ".Capture(self)\n\z
		\t\t\tself:BufferWhitespace(\"" .. class.val.ParserType .. "\", start, self.i - 1)\n"
	end
	code = code .. "\t\telse\n\t\t\tbreak\n\t\tend\n"
	code = code .. "\tend\n"

	code = code .. "\n"

	for i, class in ipairs(sorted_token_classes) do
		if i == 1 then
			code = code .. "\tif "
		else
			code = code .. "\telseif "
		end

		--\t\tprint('capturing "..class.val.Type.."')\n\z
		code = code .. "\z
		META.TokenClasses." .. class.val.Type .. ".Is(self) then\n\z
		\t\tlocal start = self.i\n\z
		\t\tMETA.TokenClasses." .. class.val.Type .. ".Capture(self)\n\z
		\t\tlocal whitespace = self.whitespace_buffer\n\z
		\t\tself.whitespace_buffer = {}\n\z
		\t\tself.whitespace_buffer_i = 1\n\z
		\t\treturn \"" .. class.val.ParserType .. "\", start, self.i - 1, whitespace\n"
	end
	code = code .. "\tend\n"
	code = code .. "end\n"

	assert(loadstring(code))(meta)
end

function meta:ReadToken()
	if meta.ShebangTokenType.Is(self) then
		meta.ShebangTokenType.Capture(self)
		return meta.ShebangTokenType.Type, 1, self.i, {}
	end

	local type, start, stop, whitespace = self:CaptureToken()

	if not type then
		local start = self.i
		local char = self:ReadChar()
		local stop = self.i - 1

		return "unknown", start, stop, {}
	end

	return type, start, stop, whitespace
end

function meta:GetTokens()
	self.i = 1

	local tokens = {}
	local tokens_i = 1

	for _ = self.i, self.code_length do
		local type, start, stop, whitespace = self:ReadToken()

		tokens[tokens_i] = {
			type = type,
			start = start,
			stop = stop,
			whitespace = whitespace,
			value = self:GetChars(start, stop)
		}

		if type == "end_of_file" then break end

		tokens_i = tokens_i + 1
	end

	return tokens
end

function meta:SetCode(code)
	self.code = code
	self.code_length = self.string_length(code)
	self.whitespace_buffer = {}
	self.whitespace_buffer_i = 1
	self.i = 1
end

return function(config)
	local self = setmetatable({}, meta)

	self.string_lower = config.string_lower or string.lower
	self.string_sub = config.string_sub or string.sub
	self.string_length = config.string_length or string.len
	self.on_error = config.on_error
	self.char_fallback_type = config.fallback_type or false
	self:BuildLookupTables(config.syntax)

	return self
end