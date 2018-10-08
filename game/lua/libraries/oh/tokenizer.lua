local oh = ... or _G.oh

local META = {}
META.__index = META

local ffi = require("ffi")
local string_char = string.char
local ffi_string = ffi.string

function META:ReadChar()
	local char = self:GetCurrentChar()
	self.i = self.i + 1
	return char
end

function META:ReadCharByte()
	local b = self:GetCurrentCharByte()
	self.i = self.i + 1
	return b
end

function META:Advance(len)
	self.i = self.i + len
end

function META:GetCharOffset(offset)
	return self.code:sub(self.i + offset, self.i + offset)
end

function META:GetCurrentChar()
	return self.code:sub(self.i, self.i)
end

function META:GetChars(a, b)
	return self.code:sub(a, b)
end

META.GetCharOffsetByte = META.GetCharOffset
META.GetCurrentCharByte = META.GetCurrentChar

function META:GetCharsOffset(b)
	return self.code:sub(self.i, self.i + b)
end

function META:Error(msg, start, stop)
	start = start or self.i
	stop = stop or self.i

	if self.halt_on_error then
		error(oh.FormatError(self.code, self.path, msg, start, stop))
	end

	table.insert(self.errors, {
		msg = msg,
		start = start,
		stop = stop,
	})
end

local function RegisterTokenClass(tbl)
	tbl.ParserType = tbl.ParserType or tbl.Type
	tbl.Priority = tbl.Priority or 0

	META.TokenClasses = META.TokenClasses or {}
	META.WhitespaceClasses = META.WhitespaceClasses or {}

	if tbl.Whitespace then
		META.WhitespaceClasses[tbl.Type] = tbl
	else
		META.TokenClasses[tbl.Type] = tbl
	end
end

META.TokenClasses = {}

local function CaptureLiteralString(self)
	local start = self.i

	local c = self:ReadChar()
	if c ~= "[" then
		self:Error("expected "..oh.QuoteToken("[").." got " .. oh.QuoteToken(c))
		return false
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

	local c = self:ReadChar()
	if c ~= "[" then
		self:Error("expected " .. oh.QuoteToken(self.code:sub(start, self.i - 1) .. "[") .. " got " .. oh.QuoteToken(self.code:sub(start, self.i - 1) .. c))
		return false
	end

	local length = self.i - start

	if length < 2 then return nil end

	local closing = "]" .. ("="):rep(length - 2) .. "]"

	for _ = self.i, self.code_length do
		if self:GetCharsOffset(length - 1) == closing then
			self:Advance(length)
			return true
		end
		self:Advance(1)
	end
	return nil, length
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
		local ok, len = CaptureLiteralString(self)
		if not ok then
			self.i = start + 2 + len
			self:Error("unterminated multiline comment", start, start + len + 1)
			return false
		end
		return ok
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "line_comment"
	Token.Whitespace = true
	Token.Priority = 99

	function Token:Is()
		return self:GetCharsOffset(oh.syntax.line_comment_length - 1) == oh.syntax.line_comment
	end

	function Token:Capture()
		self:Advance(oh.syntax.line_comment_length)

		for _ = self.i, self.code_length do
			if self:ReadChar() == "\n" or self.i-1 == self.code_length then
				return true
			end
		end
	end

	RegisterTokenClass(Token)
end

for name, quote in pairs(oh.syntax.quotes) do
	local Token = {}

	Token.Type = name .. "_quote_string"
	Token.ParserType = "string"

	function Token:Is()
		return self:GetCurrentCharByte() == quote
	end

	function Token:StringEscape(c)
		if self.string_escape then

			if c == "z" then
				META.WhitespaceClasses.space.Capture(self)
			end

			self.string_escape = false
			return true
		end

		if c == oh.syntax.escape_character then
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

				if char == oh.syntax.newline then
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

	RegisterTokenClass(Token)
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
		local ok, len = CaptureLiteralString(self)
		if not ok then
			self:Error("unterminated multiline string", start, start + len - 1)
		end
		return ok
	end

	RegisterTokenClass(Token)
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

	function Token:CaptureAnnotations()
		for _, annotation in ipairs(oh.syntax.legal_number_annotations) do
			local len = #annotation
			if self:GetCharsOffset(len - 1):lower() == annotation then
				local t = oh.syntax.GetCharType(self:GetCharOffsetByte(len))

				if t == "space" or t == "symbol" then
					self:Advance(len)
					return true
				end
			end
		end
	end

	function Token:Is()
		if self:GetCurrentChar() == oh.syntax.index_operator and oh.syntax.GetCharType(self:GetCharOffsetByte(1)) == "number" then
			return true
		end

		return oh.syntax.GetCharType(self:GetCurrentCharByte()) == "number"
	end

	function Token:CaptureHexNumber()
		self:Advance(2)

		local pow = false

		for _ = self.i, self.code_length do
			if Token.CaptureAnnotations(self) then return true end

			local char = self:GetCurrentChar():lower()
			local t = oh.syntax.GetCharType(self:GetCurrentCharByte())

			if char == pow_letter then
				if not pow then
					pow = true
				else
					self:Error("malformed number: pow character can only be used once")
					return false
				end
			end

			if not (t == "number" or allowed[char] or ((char == plus_sign or char == minus_sign) and self:GetCharOffset(-1):lower() == pow_letter) ) then
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
			local char = self:GetCurrentChar():lower()
			local t = oh.syntax.GetCharType(self:GetCurrentCharByte())

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
			local t = oh.syntax.GetCharType(self:GetCurrentCharByte())
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
					local start = self.i
					if char:lower() == "e" then
						exponent = true
					elseif Token.CaptureAnnotations(self) then
						return true
					else
						self:Error("malformed number: invalid character " .. oh.QuoteToken(char) .. ". only " .. oh.QuoteTokens(oh.syntax.legal_number_annotations, ", ") .. " allowed after a number", start, self.i)
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
		if self:GetCharOffset(1):lower() == "x" then
			return Token.CaptureHexNumber(self)
		elseif self:GetCharOffset(1):lower() == "b" then
			return Token.CaptureBinaryNumber(self)
		end

		return Token.CaptureNumber(self)
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "symbol"
	Token.Priority = -1000

	function Token:Is()
		return oh.syntax.GetCharType(self:GetCurrentCharByte()) == "symbol"
	end

	function Token:Capture()
		for len = oh.syntax.longest_symbol - 1, 0, -1 do
			if oh.syntax.symbols_lookup[self:GetCharsOffset(len)] then
				self:Advance(len + 1)
				return true
			end
		end
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "letter"

	function Token:Is()
		return oh.syntax.GetCharType(self:GetCurrentCharByte()) == "letter"
	end

	function Token:Capture()
		local start = self.i
		self:Advance(1)
		for _ = self.i, self.code_length do
			local t = oh.syntax.GetCharType(self:GetCurrentCharByte())
			if t == "space" or not (t == "letter" or (t == "number" and self.i ~= start)) then
				return true
			end
			self:Advance(1)
		end
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "space"
	Token.Whitespace = true

	function Token:Is()
		return oh.syntax.GetCharType(self:GetCurrentCharByte()) == "space"
	end

	function Token:Capture()
		self:Advance(1)

		for _ = self.i, self.code_length do
			if oh.syntax.GetCharType(self:GetCurrentCharByte()) ~= "space" then
				return true
			end
			self:Advance(1)
		end

		return true
	end

	RegisterTokenClass(Token)
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
				self.i = self.i + 1
				return true
			end
		end
	end

	META.ShebangTokenType = Token
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

	META.ShebangTokenType = Token
end

function META:BufferWhitespace(type, start, stop)
	self.whitespace_buffer[self.whitespace_buffer_i] = {
		type = type,
		value = self:GetChars(start, stop),
		start = start == 1 and 0 or start,
		stop = stop,
	}

	self.whitespace_buffer_i = self.whitespace_buffer_i + 1
end
do
	local sorted_token_classes = table.tolist(META.TokenClasses)
	table.sort(sorted_token_classes, function(a, b) return a.val.Priority > b.val.Priority end)

	local sorted_whitespace_classes = table.tolist(META.WhitespaceClasses)
	table.sort(sorted_whitespace_classes, function(a, b) return a.val.Priority > b.val.Priority end)

	local code = "local META = ...\nfunction META:ReadToken()\n"

	code = code .. "\tfor _ = self.i, self.code_length do\n"
	for i, class in ipairs(sorted_whitespace_classes) do
		if i == 1 then
			code = code .. "\t\tif "
		else
			code = code .. "\t\telseif "
		end

		code = code .. "META.WhitespaceClasses." .. class.val.Type .. ".Is(self) then\n"
		code = code .. "\t\t\tlocal start = self.i\n"
		code = code .. "\t\t\tMETA.WhitespaceClasses." .. class.val.Type .. ".Capture(self)\n"
		code = code .. "\t\t\tself:BufferWhitespace(\"" .. class.val.ParserType .. "\", start, self.i - 1)\n"
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

		code = code .. "META.TokenClasses." .. class.val.Type .. ".Is(self) then\n"
		code = code .. "\t\tlocal start = self.i\n"
		code = code .. "\t\tMETA.TokenClasses." .. class.val.Type .. ".Capture(self)\n"
		code = code .. "\t\tlocal whitespace = self.whitespace_buffer\n"
		code = code .. "\t\tself.whitespace_buffer = {}\n"
		code = code .. "\t\tself.whitespace_buffer_i = 1\n"
		code = code .. "\t\treturn \"" .. class.val.ParserType .. "\", start, self.i - 1, whitespace\n"
	end
	code = code .. "\tend\n"
	code = code .. "end\n"

	assert(loadstring(code))(META)
end

function META:GetTokens()
	self.i = 1
	self.tokens_i = 1

	if META.ShebangTokenType.Is(self) then
		META.ShebangTokenType.Capture(self)
	end

	for _ = self.i, self.code_length do
		--if oh.syntax.GetCharType(self:GetCurrentCharByte()) == nil then
		--	self:Error("unexpected character " .. oh.QuoteToken(self:GetCurrentChar()) .. " (byte " .. self:GetCurrentChar():byte() .. ")", self.i, self.i)
		--	self:Advance(1)
		--end

		local type, start, stop, whitespace = self:ReadToken()

		if not type then break end

		self.tokens[self.tokens_i] = {
			type = type,
			start = start,
			stop = stop,
			--value = self:GetChars(start, stop),
			whitespace = whitespace,
		}

		self.tokens_i = self.tokens_i + 1
	end

	return self.tokens
end

function oh.Tokenizer(config, ...)

	if type(config) == "string" then
		config = {code = config, path = ...}
	end

	if halt_on_error == nil then
		halt_on_error = true
	end

	local self = setmetatable({}, META)

	self.code = config.code

	if config.path then
		self.path = config.path
	else
		local line =  config.code:match("(.-)\n")
		if line ~= self.code then
			line = line .. "..."
		end
		local content = line:sub(0, 15)
		if content ~= line then
			content = content .. "..."
		end
		self.path =  "[string \""..content.."\"]"
	end

	if config.halt_on_error == nil then
		self.halt_on_error = true
	else
		self.halt_on_error = config.halt_on_error
	end

	self.code_length = #self.code
	self.errors = {}

	self.tokens = {}
	self.tokens_i = 1

	self.whitespace_buffer = {}
	self.whitespace_buffer_i = 1

	self.i = 1
	self.config = config

	return self
end

function META:GetErrorsFormatted()
	if not self.errors[1] then
		return ""
	end

	local errors = {}
	local max_width = 0

	for i, data in ipairs(self.errors) do
		local msg = oh.FormatError(self.code, self.path, data.msg, data.start, data.stop)

		for _, line in ipairs(msg:split("\n")) do
			max_width = math.max(max_width, #line)
		end

		errors[i] = msg
	end

	local str = ""

	for _, msg in ipairs(errors) do
		str = str .. ("="):rep(max_width) .. "\n" .. msg .. "\n"
	end

	str = str .. ("="):rep(max_width) .. "\n"

	return str
end

function oh.DumpTokens(chunks, code)
	local out = {}
	local start = 0
	for i,v in ipairs(chunks) do
		out[i] = code:sub(start+1, v.start-1) .. oh.QuoteToken(code:sub(v.start, v.stop))
		start = v.stop
	end

	table.insert(out, code:sub(start+1))

	return table.concat(out)
end

if RELOAD then
	runfile("lua/libraries/oh/test.lua")
end