local builder = require("../base_tokenizer")()
local string_lower = string.lower

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
		return nil, "expected " .. quote_token(self.get_code_char_range(self, start, self.i - 1) .. "[") .. " got " .. quote_token(self.get_code_char_range(self, start, self.i - 1) .. c)
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
			local char = string_lower(self:GetCurrentChar())
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
					if string_lower(char) == "e" then
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
		for len = self.longest_symbol - 1, 0, -1 do
			if self.SymbolLookup[self:GetCharsOffset(len)] then
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

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift
local math_floor = math.floor
local string_char = string.char
local UTF8_ACCEPT = 0
local UTF8_REJECT = 12

local utf8d = ffi.new("const uint8_t[364]", {
	-- The first part of the table maps bytes to character classes that
	-- to reduce the size of the transition table and create bitmasks.
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
	7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
	8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	10,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3, 11,6,6,6,5,8,8,8,8,8,8,8,8,8,8,8,

	-- The second part is a transition table that maps a combination
	-- of a state of the automaton and a character class to a state.
	0,12,24,36,60,96,84,12,12,12,48,72, 12,12,12,12,12,12,12,12,12,12,12,12,
	12, 0,12,12,12,12,12, 0,12, 0,12,12, 12,24,12,12,12,12,12,24,12,24,12,12,
	12,12,12,12,12,12,12,24,12,12,12,12, 12,24,12,12,12,12,12,12,12,24,12,12,
	12,12,12,12,12,12,12,36,12,36,12,12, 12,36,12,12,12,12,12,36,12,36,12,12,
	12,36,12,12,12,12,12,12,12,12,12,12,
})

local function totable(str)
	local state = UTF8_ACCEPT
	local codepoint = 0;
	local offset = 0;
	local ptr = ffi.cast("uint8_t *", str)

	local out = {}
	local out_i = 1

	for i = 0, #str - 1 do
		local byte = ptr[i]
		local ctype = utf8d[byte]

		if state ~= UTF8_ACCEPT then
			codepoint = bor(band(byte, 0x3f), lshift(codepoint, 6))
		else
			codepoint = band(rshift(0xff, ctype), byte)
		end

		state = utf8d[256 + state + ctype]

		if state == UTF8_ACCEPT then
			if codepoint > 0xffff then
				codepoint = lshift(((0xD7C0 + rshift(codepoint, 10)) - 0xD7C0), 10) +
				(0xDC00 + band(codepoint, 0x3ff)) - 0xDC00
			end

			if codepoint <= 127 then
				out[out_i] = string_char(codepoint)
			elseif codepoint < 2048 then
				out[out_i] = string_char(
					192 + math_floor(codepoint / 64),
					128 + (codepoint % 64)
				)
			elseif codepoint < 65536 then
				out[out_i] = string_char(
					224 + math_floor(codepoint / 4096),
					128 + (math_floor(codepoint / 64) % 64),
					128 + (codepoint % 64)
				)
			elseif codepoint < 2097152 then
				out[out_i] = string_char(
					240 + math_floor(codepoint / 262144),
					128 + (math_floor(codepoint / 4096) % 64),
					128 + (math_floor(codepoint / 64) % 64),
					128 + (codepoint % 64)
				)
			else
				out[out_i] = ""
			end

			out_i = out_i + 1
		end
	end
	return out
end

local table_concat = table.concat

return builder:BuildTokenizer({
	OnInitialize = function(self, str, on_error)
		self.code = totable(str)
		self.code_length = #self.code
		self.tbl_cache = {}
	end,

	Syntax = (function()
		local tbl = {}

		tbl.space = {" ", "\n", "\r", "\t"}

		tbl.number = {}
		for i = 0, 9 do
			tbl.number[i+1] = tostring(i)
		end

		tbl.letter = {"_"}

		for i = string.byte("A"), string.byte("Z") do
			table.insert(tbl.letter, string.char(i))
		end

		for i = string.byte("a"), string.byte("z") do
			table.insert(tbl.letter, string.char(i))
		end

		tbl.symbol = {
			".", ",", "(", ")", "{", "}", "[", "]",
			"=", ":", ";", "::", "...", "-", "#",
			"not", "-", "<", ".", ">", "/", "^",
			"==", "<=", "..", "~=", "+", "*", "and",
			">=", "or", "%", "\"", "'"
		}

		tbl.end_of_file = {""}

		return tbl
	end)(),

	FallbackCharacterType = "letter", -- This is needed for UTF8. Assume everything is a letter if it's not any of the other types.

	GetLength = function(tk)
		return tk.code_length
	end,
	GetCharOffset = function(tk, i)
		return tk.code[tk.i + i] or ""
	end,
	GetCharsRange = function(tk, start, stop)
		local length = stop-start
		if not tk.tbl_cache[length] then
			tk.tbl_cache[length] = {}
		end
		local str = tk.tbl_cache[length]

		local str_i = 1
		for i = start, stop do
			str[str_i] = tk.code[i]
			str_i = str_i + 1
		end
		return table_concat(str)
	end,
	OnError = function(tk, msg, start, stop)
		table.insert(errors, {msg = msg, start = start, stop = stop})
	end
})