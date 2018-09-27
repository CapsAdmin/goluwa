local META = {}
META.__index = META

function META:Error(msg, start, stop, level)
	start = start or self:GetToken() and self:GetToken().start or self.i
	stop = stop or self:GetToken() and self:GetToken().stop or self.i
	offset = offset or 0

	local context_start = self.code:sub(math.max(start - 50, 2), start - 1)
	local context_stop = self.code:sub(stop, stop + 50)

	context_start = context_start:gsub("\t", " ")
	context_stop = context_stop:gsub("\t", " ")

	local content_before = #(context_start:reverse():match("(.-)\n") or context_start)
	local content_after = (context_stop:match("(.-)\n") or "")

	local len = math.abs(stop - start)
	local str = (len > 0 and self.code:sub(start, stop - 1) or "") .. content_after .. "\n"

	str = str .. (" "):rep(content_before) .. ("_"):rep(len) .. "^" .. ("_"):rep(#content_after - 1) .. " " .. msg .. "\n"

	str = "\n" .. context_start .. str .. context_stop:sub(#content_after + 1)

	str =  "\n" .. self.path .. ":" .. self.code:sub(0, start):count("\n") .. "\n" .. str

	error(str, level or 2)
end

function META:Dump()
	local out = {}
	local start = 0
	for i,v in ipairs(self.chunks) do
		out[i] = self.code:sub(start+1, v.start-1) ..
			"⸢" .. self.code:sub(v.start, v.stop) .. "⸥"
		start = v.stop
	end

	table.insert(out, self.code:sub(start+1))

	return table.concat(out)
end

--[[
space,	2785639
symbol,	303452
letter,	289552
number,	50520
string,	14888
line_comment,	9163
multiline_comment,	265
]]

local function RegisterTokenClass(tbl)
	tbl.Priority = tbl.Priority or 0
	table.insert(META.TokenClasses, tbl)
	table.sort(META.TokenClasses, function(a, b)
		return a.Priority > b.Priority
	end)
end


META.TokenClasses = {}

local function CaptureLiteralString(self)
	local stop
	local length = 0
	local start = self.i

	local c = self:GetChar(self.i)
	if c ~= "[" then return nil, "expected [ got " .. c end

	self.i = self.i + 1

	for offset = self.i, self.code_length do
		if self:GetChar(offset) ~= "=" then
			self.i = offset
			break
		end
	end

	local c = self:GetChar(self.i)
	if c ~= "[" then return nil, "expected " .. self.code:sub(start, self.i - 1) .. "[ got " .. self.code:sub(start, self.i - 1) .. c end

	length = self.i - start + 1

	if length < 2 then return nil end

	local closing = "]" .. ("="):rep(length - 2) .. "]"

	for i = self.i + length, self.code_length do
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

	function Token:Is()
		return self:GetChars(self.i, self.i + 3) == "--[=" or self:GetChars(self.i, self.i + 3) == "--[["
	end

	function Token:Capture()
		self.i = self.i + 2
		local stop, err = CaptureLiteralString(self)

		if not stop and err then
			self:Error("cannot find the end of literal quote: " .. err)
		end

		self.i = stop
		return true
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "line_comment"
	Token.Priority = 99

	function Token:Is()
		return self:GetChars(self.i, self.i + oh.syntax.line_comment_length - 1) == oh.syntax.line_comment
	end

	function Token:Capture()
		for i = self.i + oh.syntax.line_comment_length, self.code_length do
			if self:GetChar(i) == "\n" or i == self.code_length then
				self.i = i
				return true
			end
		end
	end

	RegisterTokenClass(Token)
end

for _, quote in ipairs({oh.syntax.single_quote, oh.syntax.double_quote}) do
	local Token = {}

	Token.Type = "string"

	function Token:Is()
		return self:GetChar(self.i) == quote
	end

	function Token:Capture()
		for i = self.i + 1, self.code_length do
			local char = self:GetChar(i)
			if not self:StringEscape(char) and char == quote then
				self.i = i
				return true
			end
		end

		self:Error("cannot find the end of quote")
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "string"
	Token.Priority = 1000

	function Token:Is()
		return self:GetChars(self.i, self.i + 1) == "[=" or self:GetChars(self.i, self.i + 1) == "[["
	end

	function Token:Capture()
		local stop, err = CaptureLiteralString(self)

		if not stop and err then
			self:Error("cannot find the end of literal quote: " .. err)
		end

		self.i = stop
		return true
	end

	RegisterTokenClass(Token)
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
					self.i = i + len
					return true
				end
			end
		end
	end

	function Token:Is()
		if self:GetChar(self.i) == "." and self:GetCharType(self.i + 1) == "number" then
			return true
		end

		return self:GetCharType(self.i) == "number"
	end

	function Token:CaptureHexNumber()
		local stop

		local pow = false

		for offset = self.i + 2, self.i + 64 do
			local stop = Token.CaptureAnnotations(self, offset)
			if stop then self.i = stop return true end

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
					self.i = offset - 1
					return true
				elseif char == "symbol" or t == "letter" then
					self:Error("malformed number: invalid character '" .. char .. "'. only abcdef0123456789_ allowed after hex notation", self.i, offset)
				end
			end
		end
	end

	function Token:CaptureBinaryNumber()
		local stop

		for offset = self.i + 2, self.i + 64 do
			local char = self:GetChar(offset):lower()
			local t = self:GetCharType(offset)

			if char ~= "1" and char ~= "0" and char ~= "_" then
				if not t or t == "space" or t == "symbol" then
					stop = offset - 1
					break
				elseif char == "symbol" or t == "letter" or (char ~= "0" and char ~= "1") then
					self:Error("malformed number: only 01_ allowed after binary notation", self.i, offset)
				end
			end
		end

		self.i = stop

		return true
	end

	function Token:CaptureNumber()
		local stop

		local found_dot = false
		local exponent = false

		for offset = self.i, self.code_length + 1 do
			local char = self:GetChar(offset)
			local t = self:GetCharType(offset)

			if exponent then
				if char ~= "-" and char ~= "+" and t ~= "number" then
					self:Error("malformed number: invalid character '" .. char .. "'. only +-0123456789 allowed after exponent", self.i, offset)
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
						self:Error("malformed number: invalid character '" .. char .. "'. only " .. table.concat(oh.syntax.legal_number_annotations, ", ") .. " allowed after a number", i, offset)
					end
				elseif not found_dot and char == "." then
					found_dot = true
				elseif t == "space" or t == "symbol" then
					stop = offset - 1
					break
				else
					self:Error("malformed number: invalid character '" .. char .. "'. this should never happen?", self.i, offset)
				end
			end
		end

		if not stop then
			self:Error("malformed number: expected number after exponent")
		end

		self.i = stop

		return true
	end


	function Token:Capture()
		if self:GetChar(self.i + 1):lower() == "x" then
			return Token.CaptureHexNumber(self)
		elseif self:GetChar(self.i + 1):lower() == "b" then
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
		return self:GetCharType(self.i) == "symbol"
	end

	function Token:Capture()
		for len = oh.syntax.longest_symbol - 1, 0, -1 do
			if oh.syntax.symbols_lookup[self:GetChars(self.i, self.i + len)] then
				self.i = self.i + len
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
		return self:GetCharType(self.i) == "letter"
	end

	function Token:Capture()
		for offset = self.i, self.i + 256 do
			local t = self:GetCharType(offset)
			if not (t == "letter" or t == "number" and offset ~= self.i) then
				self.i = offset - 1
				return true
			end
		end
	end

	RegisterTokenClass(Token)
end

do
	local Token = {}

	Token.Type = "space"

	function Token:Is()
		return self:GetCharType(self.i) == "space"
	end

	function Token:Capture()
		for offset = self.i, self.code_length  do
			if self:GetCharType(offset) ~= "space" then
				self.i = offset - 1
				return true
			end
		end
		return true
	end

	RegisterTokenClass(Token)
end

do -- shebang
	local Token = {}

	Token.Type = "shebang"

	function Token:Is()
		return self.i == 1 and self:GetChar(self.i) == "#"
	end

	function Token:Capture()
		for i = 1, self.code_length do
			if self:GetChar(i) == "\n" then
				self.i = i + 1
				return true
			end
		end
	end

	RegisterTokenClass(Token)
end

do
	local comment_buffer = {}
	local comment_buffer_i = 1

	function META:AddToken(type, start, stop)
		if type == "shebang" then return end

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

function META:ReadChar()
	local char = self:GetChar()
	self.i = self.i + 1
	return char
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
	self.i = 1

	for _ = 1, self.code_length + 1 do
		if not self:GetCharType(self.i) then
			self:Error("unknown symbol >>" .. self:GetChar(self.i) .. "<< (" .. self:GetChar(i):byte() .. ")", self.i, self.i)
		end

		for _, class in ipairs(self.TokenClasses) do
			if class.Is(self) then
				local start = self.i
				if not class.Capture(self) then
					self:Error("unable to capture " .. class.Type)
				end
				self:AddToken(class.Type, start, self.i)
				break
			end
		end

		self.i = self.i + 1
	end

	return self.chunks
end

function oh.Tokenizer(code, path)
	local self = {}

	setmetatable(self, META)

	self.code = code
	self.path = path or "?"
	self.code_length = #code

	self.chunks = table.new(self.code_length / 6, 1) -- rough estimation of how many chunks there are going to be
	self.chunks_i = 1
	self.i = 1

	return self
end

if RELOAD then
	oh.TestAllFiles("/home/caps/goluwa/core")
	oh.TestAllFiles("/home/caps/goluwa/framework")
	oh.TestAllFiles("/home/caps/goluwa/engine")
	oh.TestAllFiles("/home/caps/goluwa/game")
	oh.TestAllFiles("/home/caps/goluwa/lua-5.2.2-tests")
	--oh.TestAllFiles("/home/caps/goluwa/love_games/lovers")
end