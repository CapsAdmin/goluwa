local oh = ... or _G.oh

local syntax = {}

do -- syntax rules
	syntax.space = {" ", "\n", "\r", "\t"}

	syntax.number = {}
	for i = 0, 9 do
		syntax.number[i+1] = tostring(i)
	end

	syntax.letter = {"_"}
	for i = string.byte("A"), string.byte("Z") do
		table.insert(syntax.letter, string.char(i))
	end
	for i = string.byte("a"), string.byte("z") do
		table.insert(syntax.letter, string.char(i))
	end

	syntax.symbol = {
		"(", ")", "[", "]", "->", ".", "++", "-", "+", "-", "!", "~", "++",
		"-", "*", "&", "*", "/", "%", "+", "-", "<<", ">>", "<", "<=", ">",
		">=", "==", "!=", "&", "^", "|", "&&", "||", "?", ":", "=", "+=",
		"-=", "*=", "/=", "%=", ">>=", "<<=", "&=", "^=", "|=", ",", "{", "}",
		";", "#", "\"", "'", "##"
	}

	do
		local char_types = {}

		for _, type in ipairs({"number", "letter", "space", "symbol"}) do
			for _, value in ipairs(syntax[type]) do
				char_types[value] = type
			end
		end

		syntax.char_types = char_types
	end

	function syntax.GetCharType(char)
		return syntax.char_types[char]
	end
end


local Tokenizer = {}
Tokenizer.__index = Tokenizer

function Tokenizer:ReadChar()
	local char = self:GetCurrentChar()
	self.i = self.i + 1
	return char
end

function Tokenizer:ReadCharByte()
	local b = self:GetCurrentChar()
	self.i = self.i + 1
	return b
end

function Tokenizer:Advance(len)
	self.i = self.i + len
end

function Tokenizer:GetCharOffset(offset)
	return self.config.code:sub(self.i + offset, self.i + offset)
end

function Tokenizer:GetCurrentChar()
	return self.config.code:sub(self.i, self.i)
end

function Tokenizer:GetChars(a, b)
	return self.config.code:sub(a, b)
end

function Tokenizer:GetCharsOffset(b)
	return self.config.code:sub(self.i, self.i + b)
end

function Tokenizer:Error(msg, start, stop)
	start = start or self.i
	stop = stop or self.i

	if not self.config.on_error or self.config.on_error(self, msg, start, stop) ~= false then
		table.insert(self.errors, {
			msg = msg,
			start = start,
			stop = stop,
		})
	end
end

local function RegisterTokenClass(tbl)
	tbl.ParserType = tbl.ParserType or tbl.Type
	tbl.Priority = tbl.Priority or 0

	Tokenizer.TokenClasses = Tokenizer.TokenClasses or {}
	Tokenizer.WhitespaceClasses = Tokenizer.WhitespaceClasses or {}

	if tbl.Whitespace then
		Tokenizer.WhitespaceClasses[tbl.Type] = tbl
	else
		Tokenizer.TokenClasses[tbl.Type] = tbl
	end
end

Tokenizer.TokenClasses = {}

do
	local Token = {}

	Token.Type = "multiline_comment"
	Token.Whitespace = true
	Token.Priority = 100

	function Token:Is()
		return self:GetCharsOffset(1) == "/*"
	end

	function Token:Capture()
		for _ = self.i, #self.config.code do
			if self:GetCharsOffset(1) == "*/" then
				self:Advance(2)
				break
			end
			self:Advance(1)
		end
		return true
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "angular_bracket_quote"
	Token.Priority = 100

	function Token:Is()
		return self:GetCurrentChar() == "<"
	end

	function Token:Capture()
		for _ = self.i, #self.config.code do
			if self:GetCurrentChar() == ">" then
				self:Advance(1)
				break
			end
			self:Advance(1)
		end
		return true
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "line_comment"
	Token.Whitespace = true
	Token.Priority = 99

	local line_comment = "//"

	function Token:Is()
		return self:GetCharsOffset(#line_comment - 1) == line_comment
	end

	function Token:Capture()
		self:Advance(#line_comment)

		for _ = self.i, #self.config.code do
			if self:ReadChar() == "\n" or self.i-1 == #self.config.code then
				return true
			end
		end
	end

	RegisterTokenClass(Token)
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
					Tokenizer.WhitespaceClasses.space.Capture(self)
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

			for _ = self.i, #self.config.code do
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

		RegisterTokenClass(Token)
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
			code = code .. "self:GetCharsOffset(" .. (len - 1) .. "):lower() == '" .. annotation .. "' then\n\z
			\t\tlocal t = syntax.GetCharType(self:GetCharOffset("..len.."))\n\z
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
			if self:GetCharsOffset(len - 1):lower() == annotation then
				local t = syntax.GetCharType(self:GetCharOffset(len))

				if t == "space" or t == "symbol" then
					self:Advance(len)
					return true
				end
			end
		end
	end

	function Token:Is()
		if self:GetCurrentChar() == "." and syntax.GetCharType(self:GetCharOffset(1)) == "number" then
			return true
		end

		return syntax.GetCharType(self:GetCurrentChar()) == "number"
	end

	function Token:CaptureHexNumber()
		self:Advance(2)

		local pow = false

		for _ = self.i, #self.config.code do
			if Token.CaptureAnnotations(self) then return true end

			local char = self:GetCurrentChar():lower()
			local t = syntax.GetCharType(self:GetCurrentChar())

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

		for _ = self.i, #self.config.code do
			local char = self:GetCurrentChar():lower()
			local t = syntax.GetCharType(self:GetCurrentChar())

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

		for _ = self.i, #self.config.code do
			local t = syntax.GetCharType(self:GetCurrentChar())
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
					if char:lower() == "e" then
						exponent = true
					elseif Token.CaptureAnnotations(self) then
						return true
					else
						self:Error("malformed number: invalid character " .. oh.QuoteToken(char) .. ". only " .. oh.QuoteTokens(legal_number_annotations, ", ") .. " allowed after a number", start, self.i)
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

	local longest_symbol = 0
	local lookup = {}

	for k, v in ipairs(syntax.symbol) do lookup[v] = true end

	for k, v in pairs(lookup) do
		longest_symbol = math.max(longest_symbol, #k)
		for i = 1, #k do
			local char = k:sub(i, i)
			if not syntax.char_types[char] then
				syntax.char_types[char] = "symbol"
			end
		end
	end

	function Token:Is()
		return syntax.GetCharType(self:GetCurrentChar()) == "symbol"
	end

	function Token:Capture()
		for len = longest_symbol - 1, 0, -1 do
			if lookup[self:GetCharsOffset(len)] then
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
		return syntax.GetCharType(self:GetCurrentChar()) == "letter"
	end

	function Token:Capture()
		local start = self.i
		self:Advance(1)
		for _ = self.i, #self.config.code do
			local t = syntax.GetCharType(self:GetCurrentChar())
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
		return syntax.GetCharType(self:GetCurrentChar()) == "space"
	end

	function Token:Capture()
		self:Advance(1)

		for _ = self.i, #self.config.code do
			if syntax.GetCharType(self:GetCurrentChar()) ~= "space" then
				return true
			end
			self:Advance(1)
		end

		return true
	end

	RegisterTokenClass(Token)
end

do -- eof
	local Token = {}

	Token.Type = "end_of_file"

	function Token:Is()
		return self.i > #self.config.code
	end

	function Token:Capture()
		-- nothing to capture, but remaining whitespace will be added
	end

	RegisterTokenClass(Token)
end

function Tokenizer:BufferWhitespace(type, start, stop)
	self.whitespace_buffer[self.whitespace_buffer_i] = {
		type = type,
		value = self:GetChars(start, stop),
		start = start == 1 and 0 or start,
		stop = stop,
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

	local sorted_token_classes = tolist(Tokenizer.TokenClasses)
	local sorted_whitespace_classes = tolist(Tokenizer.WhitespaceClasses)

	local code = "local META = ...\nfunction META:CaptureToken()\n"

	code = code .. "\tfor _ = self.i, #self.config.code do\n"
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

	assert(loadstring(code))(Tokenizer)
end

function Tokenizer:ReadToken()
	return self:CaptureToken()
end

function Tokenizer:GetTokens()
	self.i = 1

	local tokens = {}
	local tokens_i = 1

	for _ = self.i, #self.config.code do
		local type, start, stop, whitespace = self:ReadToken()

		if type then
			tokens[tokens_i] = {
				type = type,
				start = start,
				stop = stop,
				value = self:GetChars(start, stop),
				whitespace = whitespace,
			}

			if type == "end_of_file" then break end

			tokens_i = tokens_i + 1
		else
			self:Error("unexpected character " .. oh.QuoteToken(self:GetCurrentChar()) .. " (byte " .. self:GetCurrentChar():byte() .. ")", self.i, self.i)
			self:Advance(1)
		end

	end

	return tokens
end

local function tokenize(config, ...)
	if type(config) == "string" then
		config = {code = config, path = ...}
	else
		assert(type(config) == "table", "expected config table")
		assert(type(config.code) == "string", "expected config field code to be a string")
	end

	if not config.path then
		local line =  config.code:match("(.-)\n")
		if line ~= config.code then
			line = line .. "..."
		end
		local content = line:sub(0, 15)
		if content ~= line then
			content = content .. "..."
		end
		config.path =  "[string \""..content.."\"]"
	end

	if config.halt_on_error == nil then
		config.halt_on_error = true
	end

	local self = setmetatable({}, Tokenizer)

	self.config = config
	self.errors = {}
	self.whitespace_buffer = {}
	self.whitespace_buffer_i = 1
	self.i = 1

	return self
end

local path = "/home/caps/goluwa/data/users/caps/lua-5.3.5/src/lua.c"
local code = vfs.Read(path)
code = [[
#include <stdio.h>

#define LOL aaa\
        ##bbb

#define LOL2 "aaa\
                                          bbb"

int a\
b = 3;

int aaabbb = 5\
ull;

int main()
{
    if (ab =\
= 3)
        printf("Hello, World %d %d!\n"LOL2, LOL, ab);

    return 0;
}
]]

code = code:gsub("\\\n", "")

local tokenizer = tokenize(code, path)
local tokens = tokenizer:GetTokens()
--print(oh.DumpTokens(tokens, code))
--print(oh.GetErrorsFormatted(tokenizer.errors, code, path))

do
	local META = {}
	META.__index = META

	local table_insert = table.insert
	local table_remove = table.remove

	local function Node(t, val)
		local node = {}

		node.type = t
		node.tokens = {}

		if val then
			node.value = val
		end

		return node
	end

	function META:Error(msg, start, stop, level, offset)
		if type(start) == "table" then
			start = start.start
		end
		if type(stop) == "table" then
			stop = stop.stop
		end
		local tk = self:GetTokenOffset(offset or 0) or self.chunks[#self.chunks]
		start = start or tk.start
		stop = stop or tk.stop

		if self.halt_on_error then
			error(oh.FormatError(self.code, self.path, msg, start, stop), level or 2)
		end

		table_insert(self.errors, print(oh.FormatError(self.code, self.path, msg, start, stop)))
	end

	function META:GetToken()
		return self.chunks[self.i]
	end

	function META:GetTokenOffset(offset)
		return self.chunks[self.i + offset]
	end

	function META:ReadToken()
		local tk = self:GetToken()
		self:Advance(1)
		return tk
	end

	function META:IsValue(str)
		return self.chunks[self.i] and self.chunks[self.i].value == str and self.chunks[self.i]
	end

	function META:IsType(str)
		local tk = self:GetToken()
		return tk and tk.type == str
	end

	function META:ReadIfValue(str)
		local b = self:IsValue(str)
		if b then
			self:Advance(1)
		end
		return b
	end

	function META:ReadExpectType(type, start, stop)
		local tk = self:GetToken()
		if not tk then
			self:Error("expected " .. oh.QuoteToken(type) .. " reached end of code", start, stop, 3, -1)
		elseif tk.type ~= type then
			self:Error("expected " .. oh.QuoteToken(type) .. " got " .. oh.QuoteToken(tk.type), start, stop, 3, -1)
		end
		self:Advance(1)
		return tk
	end

	function META:ReadExpectValue(value, start, stop)
		local tk = self:ReadToken()
		if not tk then
			self:Error("expected " .. oh.QuoteToken(value) .. ": reached end of code", start, stop, 3, -1)
		elseif tk.value ~= value then
			self:Error("expected " .. oh.QuoteToken(value) .. ": got " .. oh.QuoteToken(tk.value), start, stop, 3, -1)
		end
		return tk
	end

	function META:ReadExpectValues(values, start, stop)
		local tk = self:GetToken()
		if not tk then
			self:Error("expected " .. oh.QuoteTokens(values) .. ": reached end of code", start, stop)
		elseif not table.hasvaluei(values, tk.value) then
			self:Error("expected " .. oh.QuoteTokens(values) .. " got " .. tk.value, start, stop)
		end
		self:Advance(1)
		return tk
	end

	function META:GetLength()
		return self.chunks_length
	end

	function META:Advance(offset)
		self.i = self.i + offset
	end

	function META:Block(stop)
		local out = {}

		for _ = 1, self:GetLength() do
			if not self:GetToken() or stop and stop[self:GetToken().value] then
				break
			end

			local data

			if self:IsValue("#") then
				self:Advance(1)
				local key = self:ReadToken().value
				local val = self:ReadToken().value
				print(key, val)
			else
				self:Advance(1)
			end

			table_insert(out, data)
		end
	end

	function META:BuildAST()
		return self:Block()
	end

	function cparser(tokens, code, path, halt_on_error)
		if halt_on_error == nil then
			halt_on_error = true
		end

		local self = setmetatable({}, META)

		self.chunks = tokens
		self.chunks_length = #tokens
		self.code = code
		self.path = path or "?"

		self.halt_on_error = halt_on_error
		self.errors = {}

		self.i = 1

		return self
	end
end

print(oh.DumpTokens(tokens, code))
cparser(tokens):BuildAST()
print(oh.GetErrorsFormatted(tokenizer.errors, code, path))

