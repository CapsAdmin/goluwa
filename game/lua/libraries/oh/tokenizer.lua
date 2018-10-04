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

if oh.USE_FFI then
	function META:GetCharOffset(offset)
		return string_char(self.code_ptr[self.i + offset])
	end

	function META:GetCurrentChar()
		return string_char(self.code_ptr[self.i])
	end

	function META:GetChars(a, b)
		return ffi_string(self.code_ptr + a, b - a + 1)
	end

	function META:GetCharOffsetByte(offset)
		return self.code_ptr[self.i + offset]
	end

	function META:GetCurrentCharByte()
		return self.code_ptr[self.i]
	end
else
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
end

function META:GetCharsOffset(a, b)
	return self:GetChars(self.i + a, self.i + b)
end

function META:Error(msg, start, stop)
	start = start or self.i
	stop = stop or self.i

	if self.halt_on_error then
		error(self:FormatError(msg, start, stop))
	end

	table.insert(self.errors, {
		msg = msg,
		start = start,
		stop = stop,
	})
end

--[[
space 2785639
symbol 303452
letter 289552
number 50520
string 14888
line_comment 9163
multiline_comment 265
]]

local function RegisterTokenClass(tbl)
	META.TokenClasses2 = META.TokenClasses2 or {}
	META.TokenClasses2[tbl.Type] = tbl
	tbl.ParserType = tbl.ParserType or tbl.Type
	tbl.Priority = tbl.Priority or 0
	table.insert(META.TokenClasses, tbl)
	table.sort(META.TokenClasses, function(a, b)
		return a.Priority > b.Priority
	end)
end

META.TokenClasses = {}

local function CaptureLiteralString(self)
	local start = self.i

	local c = self:ReadChar()
	if c ~= "[" then
		self:Error("expected [ got " .. c)
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
		self:Error("expected " .. self.code:sub(start, self.i - 1) .. "[ got " .. self.code:sub(start, self.i - 1) .. c)
		return false
	end

	local length = self.i - start

	if length < 2 then return nil end

	local closing = "]" .. ("="):rep(length - 2) .. "]"

	for _ = self.i, self.code_length do
		if self:GetCharsOffset(0, length - 1) == closing then
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
	Token.Priority = 100

	function Token:Is()
		return self:GetCharsOffset(0, 3) == "--[=" or self:GetCharsOffset(0, 3) == "--[["
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
	Token.Priority = 99

	function Token:Is()
		return self:GetCharsOffset(0, oh.syntax.line_comment_length - 1) == oh.syntax.line_comment
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
				META.TokenClasses2.space.Capture(self)
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
		return self:GetCharsOffset(0, 1) == "[=" or self:GetCharsOffset(0, 1) == "[["
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
			if self:GetCharsOffset(0, len - 1):lower() == annotation then
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
					self:Error("malformed number: invalid character '" .. char .. "'. only abcdef0123456789_ allowed after hex notation")
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
					self:Error("malformed number: only 01_ allowed after binary notation")
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
					self:Error("malformed number: invalid character '" .. char .. "'. only +-0123456789 allowed after exponent", start, self.i)
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
						self:Error("malformed number: invalid character '" .. char .. "'. only " .. table.concat(oh.syntax.legal_number_annotations, ", ") .. " allowed after a number", start, self.i)
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

	if false and oh.USE_FFI then
		local ffi = require("ffi")
		local ffi_cast = ffi.cast

		local _32 = ffi.typeof("uint32_t *")
		local _16 = ffi.typeof("uint16_t *")

		local len = table.count(oh.syntax.symbols_lookup2)
		local arr = ffi.new("uint32_t[?]", len)
		local i = 0
		for id in pairs(oh.syntax.symbols_lookup2) do
			arr[i] = id
			i = i + 1
		end

		local function lookup(id) do return oh.syntax.symbols_lookup2[id] end
			for i = 0, len - 1 do
				if arr[i] == id then
					return true
				end
			end
			return false
		end

		function Token:Capture()
			local ptr = self.code_ptr + self.i

			if ptr[0] == 46 then
				--print(self.code)
			end
			local a = tonumber(ptr[3])
			ptr[3] = 0
			if lookup(ffi_cast(_32, ptr)[0]) then self:Advance(3) return true end
			ptr[3] = a

			if ptr[0] == 46 then
				print("!!!!!!")
				--print(self.code)
			end

			if lookup(ffi_cast(_16, ptr)[0]) then self:Advance(2) return true end
			if lookup(ptr[0]) then self:Advance(1) return true end
		end
	else
		function Token:Capture()
			for len = oh.syntax.longest_symbol - 1, 0, -1 do
				if oh.syntax.symbols_lookup[self:GetCharsOffset(0, len)] then
					self:Advance(len + 1)
					return true
				end
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
		return (self.i == oh.USE_FFI and 0 or 1) and self:GetCurrentChar() == "#"
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

do
	local comment_buffer = {}
	local comment_buffer_i = 1

	function META:AddToken(type, start, stop)
		if type == "line_comment" or type == "multiline_comment" or type == "space" then
			comment_buffer[comment_buffer_i] = {
				type = type,
				value = self:GetChars(start, stop),
				start = start,
				stop = stop,
			}
			comment_buffer_i = comment_buffer_i + 1
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
			comment_buffer_i = 1
		end

		self.chunks_i = self.chunks_i + 1
	end
end

local system_GetTime = system.GetTime

--local stats = {add_token = {total_time = 0}} local start_time = system_GetTime()

commands.Add("tokenize_performance", function()
	local total_time = system_GetTime() - start_time
	print("total time", total_time)
	for k, v in table.sortedpairs(stats, function(a, b) return a.val.total_time > b.val.total_time end) do
		print(k, math.round(v.total_time/total_time, 3) * 100)
	end
end)

function META:CaptureToken()
	for _, class in ipairs(self.TokenClasses) do
		if oh.syntax.GetCharType(self:GetCurrentCharByte()) == nil then
			self:Error("unexpected character " .. self:GetCurrentChar() .. " (byte " .. self:GetCurrentChar():byte() .. ")", self.i, self.i)
			self:Advance(1)
		end

		if class.Is(self) then
			--stats[class.Type] = stats[class.Type] or {total_time = 0} stats[class.Type].start_time = system_GetTime()
			local start = self.i
			class.Capture(self)
			--stats[class.Type].total_time = stats[class.Type].total_time + system_GetTime() - stats[class.Type].start_time stats.add_token.start_time = system_GetTime()
			self:AddToken(class.ParserType, start, self.i - 1)
			--stats.add_token.total_time = stats.add_token.total_time + system_GetTime() - stats.add_token.start_time
			return
		end
	end
end

if false then
	local code = ""
	code = code .. "local META = ...\n"
	code = code .. "local TokenClasses = META.TokenClasses2\n"
	code = code .. "function META:CaptureToken()\n"
	for i, class in ipairs(META.TokenClasses) do
		if i == 1 then code = code .. "\t" end
		code = code .. "if TokenClasses." .. class.Type .. ".Is(self) then\n"

		code = code .. "\t\tlocal start = self.i\n"
		code = code .. "\t\tif not TokenClasses." .. class.Type .. ".Capture(self) then\n"
		code = code .. "\t\t\treturn self:Error(\"unable to capture "..class.Type.."\")\n"
		code = code .. "\t\tend\n"
		code = code .. "\t\tself:AddToken(\""..class.ParserType.."\", start, self.i - 1)\n"

		if i ~= #META.TokenClasses then
			code = code .. "\telse"
		else
			code = code .. "\tend\n"
		end
	end
	code = code .. "end\n"
	loadstring(code)(META)
end


function META:GetTokens()
	self.i = oh.USE_FFI and 0 or 1
	self.chunks_i = 1

	if META.ShebangTokenType.Is(self) then
		META.ShebangTokenType.Capture(self)
	end

	for _ = self.i, self.code_length do
		if self.i > self.code_length then
			break
		end
		self:CaptureToken()
	end

	return self.chunks
end

function oh.Tokenizer(code, path, halt_on_error)
	if halt_on_error == nil then
		halt_on_error = true
	end

	local self = {}

	setmetatable(self, META)

	self.code_ptr = ffi.cast("unsigned char *", code)
	self.code = code

	if not path then
		local line =  code:match("(.-)\n")
		if line ~= code then
			line = line .. "..."
		end
		local content = line:sub(0, 15)
		if content ~= line then
			content = content .. "..."
		end
		path =  "[string \""..content.."\"]"
	end

	self.path = path
	self.code_length = #code
	self.halt_on_error = halt_on_error
	self.errors = {}

	self.chunks = table.new(self.code_length / 6, 1) -- rough estimation of how many chunks there are going to be
	self.chunks_i = 1
	self.i = 1

	return self
end

function META:FormatError(msg, start, stop)
	local total_lines = self.code:count("\n")
	local line_number_length = #tostring(total_lines)

	local function tab2space(str)
		return str:gsub("\t", "    ")
	end

	local function line2str(i)
		return ("%i%s"):format(i, (" "):rep(line_number_length - #tostring(i)))
	end

	local context_size = 100
	local line_context_size = 1

	local length = (stop - start) + 1
	local before = self:GetChars(math.max(start - context_size, 0), stop - length)
	local middle = self:GetChars(start, stop)
	local after = self:GetChars(stop + 1, stop + context_size)

	local context_before, line_before = before:match("(.+\n)(.+)")
	local line_after, context_after = after:match("(.-)(\n.+)")

	if not line_before then
		context_before = before
		line_before = before
	end

	if not line_after then
		context_after = after
		line_after = after
	end

	local current_line = self:GetChars(0, stop):count("\n") + 1
	local char_number = #line_before + 1

	line_before = tab2space(line_before)
	line_after = tab2space(line_after)
	middle = tab2space(middle)

	local out = ""
	out = out .. "error: " ..  msg:escape() .. "\n"
	out = out .. " " .. ("-"):rep(line_number_length + 1) .. "> " .. self.path .. ":" .. current_line .. ":" .. char_number .. "\n"

	if line_context_size > 0 then
		local lines_before = tab2space(context_before:sub(0, -2)):split("\n")
		for offset = math.max(#lines_before - line_context_size, 1), #lines_before do
			local str = lines_before[offset]
			--if str:trim() ~= "" then
				offset = offset - 1
				out = out .. line2str(current_line - (-offset + #lines_before)) .. " | " .. str .. "\n"
			--end
		end
	end

	out = out .. line2str(current_line) .. " | " .. line_before .. middle .. line_after .. "\n"
	out = out .. (" "):rep(line_number_length) .. " |" .. (" "):rep(#line_before + 1) .. ("^"):rep(length) .. "\n"

	if line_context_size > 0 then
		local lines_after = tab2space(context_after:sub(2)):split("\n")
		for offset = 1, #lines_after do
			local str = lines_after[offset]
			--if str:trim() ~= "" then
				out = out .. line2str(current_line + offset) .. " | " .. str .. "\n"
			--end
			if offset >= line_context_size then break end
		end
	end

	out = out:trim()

	return out
end

function META:GetErrorsFormatted()
	if not self.errors[1] then
		return ""
	end

	local errors = {}
	local max_width = 0

	for i, data in ipairs(self.errors) do
		local msg = self:FormatError(data.msg, data.start, data.stop)

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
		out[i] = code:sub(start+1, v.start-1) ..
			"⸢" .. code:sub(v.start, v.stop) .. "⸥"
		start = v.stop
	end

	table.insert(out, code:sub(start+1))

	return table.concat(out)
end

if RELOAD then
	runfile("lua/libraries/oh/test.lua")
end