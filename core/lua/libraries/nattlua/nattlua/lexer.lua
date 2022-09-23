--[[#local type { TokenType } = import("./lexer/token.lua")]]

--[[#local type { Code } = import<|"~/nattlua/code.lua"|>]]

local reverse_escape_string = require("nattlua.other.reverse_escape_string")
local Token = require("nattlua.lexer.token").New
local class = require("nattlua.other.class")
local setmetatable = _G.setmetatable
local ipairs = _G.ipairs
local META = class.CreateTemplate("lexer")
--[[#type META.@Name = "Lexer"]]
--[[#type META.@Self = {
	Code = Code,
	Position = number,
}]]
local B = string.byte

function META:GetLength()--[[#: number]]
	return self.Code:GetByteSize()
end

function META:GetStringSlice(start--[[#: number]], stop--[[#: number]])--[[#: string]]
	return self.Code:GetStringSlice(start, stop)
end

function META:PeekByte(offset--[[#: number | nil]])--[[#: number]]
	offset = offset or 0
	return self.Code:GetByte(self.Position + offset)
end

function META:FindNearest(str--[[#: string]])--[[#: nil | number]]
	return self.Code:FindNearest(str, self.Position)
end

function META:ReadByte()--[[#: number]]
	local char = self:PeekByte()
	self.Position = self.Position + 1
	return char
end

function META:ResetState()
	self.Position = 1
end

function META:Advance(len--[[#: number]])
	self.Position = self.Position + len
end

function META:SetPosition(i--[[#: number]])
	self.Position = i
end

function META:GetPosition()
	return self.Position
end

function META:TheEnd()--[[#: boolean]]
	return self.Position > self:GetLength()
end

function META:IsString(str--[[#: string]], offset--[[#: number | nil]])--[[#: boolean]]
	offset = offset or 0
	return self.Code:IsStringSlice(self.Position + offset, self.Position + offset + #str - 1, str)
end

function META:IsStringLower(str--[[#: string]])--[[#: boolean]]
	return self.Code:GetStringSlice(self.Position, self.Position + #str - 1):lower() == str
end

function META:OnError(
	code--[[#: Code]],
	msg--[[#: string]],
	start--[[#: number | nil]],
	stop--[[#: number | nil]]
) end

function META:Error(msg--[[#: string]], start--[[#: number | nil]], stop--[[#: number | nil]])
	self:OnError(self.Code, msg, start or self.Position, stop or self.Position)
end

function META:ReadShebang()
	if self.Position == 1 and self:IsString("#") then
		for _ = self.Position, self:GetLength() do
			self:Advance(1)

			if self:IsString("\n") then break end
		end

		return true
	end

	return false
end

function META:ReadEndOfFile()
	if self.Position > self:GetLength() then
		-- nothing to capture, but remaining whitespace will be added
		self:Advance(1)
		return true
	end

	return false
end

function META:ReadUnknown()
	self:Advance(1)
	return "unknown", false
end

function META:Read()--[[#: (TokenType, boolean) | (nil, nil)]]
	return nil, nil
end

function META:ReadSimple()--[[#: (TokenType, boolean, number, number)]]
	if self:ReadShebang() then return "shebang", false, 1, self.Position - 1 end

	local start = self.Position
	local type, is_whitespace = self:Read()

	if type == "discard" then return self:ReadSimple() end

	if not type then
		if self:ReadEndOfFile() then
			type = "end_of_file"
			is_whitespace = false
		end
	end

	if not type then type, is_whitespace = self:ReadUnknown() end

	is_whitespace = is_whitespace or false
	return type, is_whitespace, start, self.Position - 1
end

function META:NewToken(
	type--[[#: TokenType]],
	is_whitespace--[[#: boolean]],
	start--[[#: number]],
	stop--[[#: number]]
)
	return Token(type, is_whitespace, start, stop)
end

do
	function META:ReadToken()
		local type, is_whitespace, start, stop = self:ReadSimple() -- TODO: unpack not working
		local token = self:NewToken(type, is_whitespace, start, stop)
		token.value = self:GetStringSlice(token.start, token.stop)

		if token.type == "string" then
			if token.value:sub(1, 1) == [["]] or token.value:sub(1, 1) == [[']] then
				token.string_value = reverse_escape_string(token.value:sub(2, #token.value - 1))
			elseif token.value:sub(1, 1) == "[" then
				local start = token.value:find("[", 2, true)

				if not start then error("start not found") end

				token.string_value = token.value:sub(start + 1, -start - 1)
			end
		end

		return token
	end

	function META:ReadNonWhitespaceToken()
		local token = self:ReadToken()

		if not token.is_whitespace then
			token.whitespace = {}
			return token
		end

		local whitespace = {token}
		local whitespace_i = 2

		for i = self.Position, self:GetLength() + 1 do
			local token = self:ReadToken()

			if not token.is_whitespace then
				token.whitespace = whitespace
				return token
			end

			whitespace[whitespace_i] = token
			whitespace_i = whitespace_i + 1
		end
	end
end

function META:ReadFirstFromArray(strings--[[#: List<|string|>]])--[[#: boolean]]
	for _, str in ipairs(strings) do
		if self:IsString(str) then
			self:Advance(#str)
			return true
		end
	end

	return false
end

function META:ReadFirstLowercaseFromArray(strings--[[#: List<|string|>]])--[[#: boolean]]
	for _, str in ipairs(strings) do
		if self:IsStringLower(str) then
			self:Advance(#str)
			return true
		end
	end

	return false
end

function META:GetTokens()
	self:ResetState()
	local tokens = {}
	local tokens_i = 1

	for i = self.Position, self:GetLength() + 1 do
		local token = self:ReadNonWhitespaceToken()

		if not token then break end

		tokens[tokens_i] = token
		tokens_i = tokens_i + 1

		if token.type == "end_of_file" then break end
	end

	return tokens
end

function META.New(code--[[#: Code]])
	local self = setmetatable({
		Code = code,
		Position = 1,
	}, META)
	self:ResetState()
	return self
end

-- lua lexer
do
	--[[#local type Lexer = META.@Self]]

	--[[#local type { TokenType } = import("~/nattlua/lexer/token.lua")]]

	--[[#local type TokenReturnType = TokenType | false]]
	local characters = require("nattlua.syntax.characters")
	local runtime_syntax = require("nattlua.syntax.runtime")
	local helpers = require("nattlua.other.quote")

	local function ReadSpace(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
		if characters.IsSpace(lexer:PeekByte()) then
			while not lexer:TheEnd() do
				lexer:Advance(1)

				if not characters.IsSpace(lexer:PeekByte()) then break end
			end

			return "space"
		end

		return false
	end

	local function ReadLetter(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
		if not characters.IsLetter(lexer:PeekByte()) then return false end

		while not lexer:TheEnd() do
			lexer:Advance(1)

			if not characters.IsDuringLetter(lexer:PeekByte()) then break end
		end

		return "letter"
	end

	local function ReadMultilineCComment(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
		if not lexer:IsString("/*") then return false end

		local start = lexer:GetPosition()
		lexer:Advance(2)

		while not lexer:TheEnd() do
			if lexer:IsString("*/") then
				lexer:Advance(2)
				return "multiline_comment"
			end

			lexer:Advance(1)
		end

		lexer:Error(
			"expected multiline c comment to end, reached end of code",
			start,
			start + 1
		)
		return false
	end

	local function ReadLineCComment(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
		if not lexer:IsString("//") then return false end

		lexer:Advance(2)

		while not lexer:TheEnd() do
			if lexer:IsString("\n") then break end

			lexer:Advance(1)
		end

		return "line_comment"
	end

	local function ReadLineComment(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
		if not lexer:IsString("--") then return false end

		lexer:Advance(2)

		while not lexer:TheEnd() do
			if lexer:IsString("\n") then break end

			lexer:Advance(1)
		end

		return "line_comment"
	end

	local function ReadMultilineComment(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
		if
			not lexer:IsString("--[") or
			(
				not lexer:IsString("[", 3) and
				not lexer:IsString("=", 3)
			)
		then
			return false
		end

		local start = lexer:GetPosition()
		-- skip past the --[
		lexer:Advance(3)

		while lexer:IsString("=") do
			lexer:Advance(1)
		end

		if not lexer:IsString("[") then
			-- if we have an incomplete multiline comment, it's just a single line comment
			lexer:SetPosition(start)
			return ReadLineComment(lexer)
		end

		-- skip the last [
		lexer:Advance(1)
		local pos = lexer:FindNearest("]" .. string.rep("=", (lexer:GetPosition() - start) - 4) .. "]")

		if pos then
			lexer:SetPosition(pos)
			return "multiline_comment"
		end

		lexer:Error("expected multiline comment to end, reached end of code", start, start + 1)
		lexer:SetPosition(start + 2)
		return false
	end

	local function ReadInlineAnalyzerDebugCode(lexer--[[#: Lexer & {comment_escape = string | nil}]])--[[#: TokenReturnType]]
		if not lexer:IsString("§") then return false end

		lexer:Advance(#"§")

		while not lexer:TheEnd() do
			if
				lexer:IsString("\n") or
				(
					lexer.comment_escape and
					lexer:IsString(lexer.comment_escape)
				)
			then
				break
			end

			lexer:Advance(1)
		end

		return "analyzer_debug_code"
	end

	local function ReadInlineParserDebugCode(lexer--[[#: Lexer & {comment_escape = string | nil}]])--[[#: TokenReturnType]]
		if not lexer:IsString("£") then return false end

		lexer:Advance(#"£")

		while not lexer:TheEnd() do
			if
				lexer:IsString("\n") or
				(
					lexer.comment_escape and
					lexer:IsString(lexer.comment_escape)
				)
			then
				break
			end

			lexer:Advance(1)
		end

		return "parser_debug_code"
	end

	local function ReadNumberPowExponent(lexer--[[#: Lexer]], what--[[#: string]])
		lexer:Advance(1)

		if lexer:IsString("+") or lexer:IsString("-") then
			lexer:Advance(1)

			if not characters.IsNumber(lexer:PeekByte()) then
				lexer:Error(
					"malformed " .. what .. " expected number, got " .. string.char(lexer:PeekByte()),
					lexer:GetPosition() - 2
				)
				return false
			end
		end

		while not lexer:TheEnd() do
			if not characters.IsNumber(lexer:PeekByte()) then break end

			lexer:Advance(1)
		end

		return true
	end

	local function ReadHexNumber(lexer--[[#: Lexer]])
		if
			not lexer:IsString("0") or
			(
				not lexer:IsString("x", 1) and
				not lexer:IsString("X", 1)
			)
		then
			return false
		end

		lexer:Advance(2)
		local has_dot = false

		while not lexer:TheEnd() do
			if lexer:IsString("_") then lexer:Advance(1) end

			if not has_dot and lexer:IsString(".") then
				-- 22..66 would be a number range
				-- so we have to return 22 only
				if lexer:IsString(".", 1) then break end

				has_dot = true
				lexer:Advance(1)
			end

			if characters.IsHex(lexer:PeekByte()) then
				lexer:Advance(1)
			else
				if characters.IsSpace(lexer:PeekByte()) or characters.IsSymbol(lexer:PeekByte()) then
					break
				end

				if lexer:IsString("p") or lexer:IsString("P") then
					if ReadNumberPowExponent(lexer, "pow") then break end
				end

				if lexer:ReadFirstLowercaseFromArray(runtime_syntax:GetNumberAnnotations()) then
					break
				end

				lexer:Error(
					"malformed hex number, got " .. string.char(lexer:PeekByte()),
					lexer:GetPosition() - 1,
					lexer:GetPosition()
				)
				return false
			end
		end

		return "number"
	end

	local function ReadBinaryNumber(lexer--[[#: Lexer]])
		if
			not lexer:IsString("0") or
			not (
				lexer:IsString("b", 1) and
				not lexer:IsString("B", 1)
			)
		then
			return false
		end

		-- skip past 0b
		lexer:Advance(2)

		while not lexer:TheEnd() do
			if lexer:IsString("_") then lexer:Advance(1) end

			if lexer:IsString("1") or lexer:IsString("0") then
				lexer:Advance(1)
			else
				if characters.IsSpace(lexer:PeekByte()) or characters.IsSymbol(lexer:PeekByte()) then
					break
				end

				if lexer:IsString("e") or lexer:IsString("E") then
					if ReadNumberPowExponent(lexer, "exponent") then break end
				end

				if lexer:ReadFirstLowercaseFromArray(runtime_syntax:GetNumberAnnotations()) then
					break
				end

				lexer:Error(
					"malformed binary number, got " .. string.char(lexer:PeekByte()),
					lexer:GetPosition() - 1,
					lexer:GetPosition()
				)
				return false
			end
		end

		return "number"
	end

	local function ReadDecimalNumber(lexer--[[#: Lexer]])
		if
			not characters.IsNumber(lexer:PeekByte()) and
			(
				not lexer:IsString(".") or
				not characters.IsNumber(lexer:PeekByte(1))
			)
		then
			return false
		end

		-- if we start with a dot
		-- .0
		local has_dot = false

		if lexer:IsString(".") then
			has_dot = true
			lexer:Advance(1)
		end

		while not lexer:TheEnd() do
			if lexer:IsString("_") then lexer:Advance(1) end

			if not has_dot and lexer:IsString(".") then
				-- 22..66 would be a number range
				-- so we have to return 22 only
				if lexer:IsString(".", 1) then break end

				has_dot = true
				lexer:Advance(1)
			end

			if characters.IsNumber(lexer:PeekByte()) then
				lexer:Advance(1)
			else
				if characters.IsSpace(lexer:PeekByte()) or characters.IsSymbol(lexer:PeekByte()) then
					break
				end

				if lexer:IsString("e") or lexer:IsString("E") then
					if ReadNumberPowExponent(lexer, "exponent") then break end
				end

				if lexer:ReadFirstLowercaseFromArray(runtime_syntax:GetNumberAnnotations()) then
					break
				end

				lexer:Error(
					"malformed number, got " .. string.char(lexer:PeekByte()) .. " in decimal notation",
					lexer:GetPosition() - 1,
					lexer:GetPosition()
				)
				return false
			end
		end

		return "number"
	end

	local function ReadMultilineString(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
		if
			not lexer:IsString("[", 0) or
			(
				not lexer:IsString("[", 1) and
				not lexer:IsString("=", 1)
			)
		then
			return false
		end

		local start = lexer:GetPosition()
		lexer:Advance(1)

		if lexer:IsString("=") then
			while not lexer:TheEnd() do
				lexer:Advance(1)

				if not lexer:IsString("=") then break end
			end
		end

		if not lexer:IsString("[") then
			lexer:Error(
				"expected multiline string " .. helpers.QuoteToken(lexer:GetStringSlice(start, lexer:GetPosition() - 1) .. "[") .. " got " .. helpers.QuoteToken(lexer:GetStringSlice(start, lexer:GetPosition())),
				start,
				start + 1
			)
			return false
		end

		lexer:Advance(1)
		local closing = "]" .. string.rep("=", (lexer:GetPosition() - start) - 2) .. "]"
		local pos = lexer:FindNearest(closing)

		if pos then
			lexer:SetPosition(pos)
			return "string"
		end

		lexer:Error(
			"expected multiline string " .. helpers.QuoteToken(closing) .. " reached end of code",
			start,
			start + 1
		)
		return false
	end

	local ReadSingleQuoteString
	local ReadDoubleQuoteString

	do
		local B = string.byte
		local escape_character = B([[\]])

		local function build_string_reader(name--[[#: string]], quote--[[#: string]])
			return function(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
				if not lexer:IsString(quote) then return false end

				local start = lexer:GetPosition()
				lexer:Advance(1)

				while not lexer:TheEnd() do
					local char = lexer:ReadByte()

					if char == escape_character then
						local char = lexer:ReadByte()

						if char == B("z") and not lexer:IsString(quote) then
							ReadSpace(lexer)
						end
					elseif char == B("\n") then
						lexer:Advance(-1)
						lexer:Error("expected " .. name:lower() .. " quote to end", start, lexer:GetPosition() - 1)
						return "string"
					elseif char == B(quote) then
						return "string"
					end
				end

				lexer:Error(
					"expected " .. name:lower() .. " quote to end: reached end of file",
					start,
					lexer:GetPosition() - 1
				)
				return "string"
			end
		end

		ReadDoubleQuoteString = build_string_reader("double", "\"")
		ReadSingleQuoteString = build_string_reader("single", "'")
	end

	local function ReadSymbol(lexer--[[#: Lexer]])--[[#: TokenReturnType]]
		if lexer:ReadFirstFromArray(runtime_syntax:GetSymbols()) then return "symbol" end

		return false
	end

	local function ReadCommentEscape(lexer--[[#: Lexer & {comment_escape = string | nil}]])--[[#: TokenReturnType]]
		if lexer:IsString("--[[#") then
			lexer:Advance(5)
			lexer.comment_escape = "]]"
			return "comment_escape"
		elseif lexer:IsString("--[=[#") then
			lexer:Advance(6)
			lexer.comment_escape = "]=]"
			return "comment_escape"
		end

		return false
	end

	local function ReadRemainingCommentEscape(lexer--[[#: Lexer & {comment_escape = string | nil}]])--[[#: TokenReturnType]]
		if lexer.comment_escape and lexer:IsString(lexer.comment_escape--[[# as string]]) then
			lexer:Advance(#lexer.comment_escape--[[# as string]])
			lexer.comment_escape = nil
			return "comment_escape"
		end

		return false
	end

	function META:Read()--[[#: (TokenType, boolean) | (nil, nil)]]
		if ReadRemainingCommentEscape(self) then return "discard", false end

		do
			local name = ReadSpace(self) or
				ReadCommentEscape(self) or
				ReadMultilineCComment(self) or
				ReadLineCComment(self) or
				ReadMultilineComment(self) or
				ReadLineComment(self)

			if name then return name, true end
		end

		do
			local name = ReadInlineAnalyzerDebugCode(self) or
				ReadInlineParserDebugCode(self) or
				ReadHexNumber(self) or
				ReadBinaryNumber(self) or
				ReadDecimalNumber(self) or
				ReadMultilineString(self) or
				ReadSingleQuoteString(self) or
				ReadDoubleQuoteString(self) or
				ReadLetter(self) or
				ReadSymbol(self)

			if name then return name, false end
		end
	end
end

return META
