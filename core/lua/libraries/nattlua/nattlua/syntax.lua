local class = require("nattlua.other.class")

--[[#local type { Token } = import("~/nattlua/lexer/token.lua")]]

local META = class.CreateTemplate("syntax")
--[[#type META.@Name = "Syntax"]]
--[[#type META.@Self = {
	BinaryOperatorInfo = Map<|string, {left_priority = number, right_priority = number}|>,
	NumberAnnotations = List<|string|>,
	Symbols = List<|string|>,
	BinaryOperators = Map<|string, true|>,
	PrefixOperators = Map<|string, true|>,
	PostfixOperators = Map<|string, true|>,
	PrimaryBinaryOperators = Map<|string, true|>,
	SymbolCharacters = List<|string|>,
	SymbolPairs = Map<|string, string|>,
	KeywordValues = Map<|string, true|>,
	Keywords = Map<|string, true|>,
	NonStandardKeywords = Map<|string, true|>,
	BinaryOperatorFunctionTranslate = Map<|string, {string, string, string}|>,
	PostfixOperatorFunctionTranslate = Map<|string, {string, string}|>,
	PrefixOperatorFunctionTranslate = Map<|string, {string, string}|>,
}]]

function META.New()
	local self = setmetatable(
		{
			NumberAnnotations = {},
			BinaryOperatorInfo = {},
			Symbols = {},
			BinaryOperators = {},
			PrefixOperators = {},
			PostfixOperators = {},
			PrimaryBinaryOperators = {},
			SymbolCharacters = {},
			SymbolPairs = {},
			KeywordValues = {},
			Keywords = {},
			NonStandardKeywords = {},
			BinaryOperatorFunctionTranslate = {},
			PostfixOperatorFunctionTranslate = {},
			PrefixOperatorFunctionTranslate = {},
		},
		META
	)
	return self
end

local function has_value(tbl--[[#: {[1 .. inf] = string} | {}]], value--[[#: string]])
	for k, v in ipairs(tbl) do
		if v == value then return true end
	end

	return false
end

function META:AddSymbols(tbl--[[#: List<|string|>]])
	for _, symbol in pairs(tbl) do
		if symbol:find("%p") and not has_value(self.Symbols, symbol) then
			table.insert(self.Symbols, symbol)
		end
	end

	table.sort(self.Symbols, function(a, b)
		return #a > #b
	end)
end

function META:AddNumberAnnotations(tbl--[[#: List<|string|>]])
	for i, v in ipairs(tbl) do
		if not has_value(self.NumberAnnotations, v) then
			table.insert(self.NumberAnnotations, v)
		end
	end

	table.sort(self.NumberAnnotations, function(a, b)
		return #a > #b
	end)
end

function META:GetNumberAnnotations()
	return self.NumberAnnotations
end

function META:AddBinaryOperators(tbl--[[#: List<|List<|string|>|>]])
	for priority, group in ipairs(tbl) do
		for _, token in ipairs(group) do
			local right = token:sub(1, 1) == "R"

			if right then token = token:sub(2) end

			if right then
				self.BinaryOperatorInfo[token] = {
					left_priority = priority + 1,
					right_priority = priority,
				}
			else
				self.BinaryOperatorInfo[token] = {
					left_priority = priority,
					right_priority = priority,
				}
			end

			self:AddSymbols({token})
			self.BinaryOperators[token] = true
		end
	end
end

function META:GetBinaryOperatorInfo(tk--[[#: Token]])
	return self.BinaryOperatorInfo[tk.value]
end

function META:AddPrefixOperators(tbl--[[#: List<|string|>]])
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.PrefixOperators[str] = true
	end
end

function META:IsPrefixOperator(token--[[#: Token]])
	return self.PrefixOperators[token.value]
end

function META:AddPostfixOperators(tbl--[[#: List<|string|>]])
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.PostfixOperators[str] = true
	end
end

function META:IsPostfixOperator(token--[[#: Token]])
	return self.PostfixOperators[token.value]
end

function META:AddPrimaryBinaryOperators(tbl--[[#: List<|string|>]])
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.PrimaryBinaryOperators[str] = true
	end
end

function META:IsPrimaryBinaryOperator(token--[[#: Token]])
	return self.PrimaryBinaryOperators[token.value]
end

function META:AddSymbolCharacters(tbl--[[#: List<|string | {string, string}|>]])
	local list = {}

	for _, val in ipairs(tbl) do
		if type(val) == "table" then
			table.insert(list, val[1])
			table.insert(list, val[2])
			self.SymbolPairs[val[1]] = val[2]
		else
			table.insert(list, val)
		end
	end

	self.SymbolCharacters = list
	self:AddSymbols(list)
end

function META:AddKeywords(tbl--[[#: List<|string|>]])
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.Keywords[str] = true
	end
end

function META:IsKeyword(token--[[#: Token]])
	return self.Keywords[token.value]
end

function META:AddKeywordValues(tbl--[[#: List<|string|>]])
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.Keywords[str] = true
		self.KeywordValues[str] = true
	end
end

function META:IsKeywordValue(token--[[#: Token]])
	return self.KeywordValues[token.value]
end

function META:AddNonStandardKeywords(tbl--[[#: List<|string|>]])
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.NonStandardKeywords[str] = true
	end
end

function META:IsNonStandardKeyword(token--[[#: Token]])
	return self.NonStandardKeywords[token.value]
end

function META:GetSymbols()
	return self.Symbols
end

function META:AddBinaryOperatorFunctionTranslate(tbl--[[#: Map<|string, string|>]])
	for k, v in pairs(tbl) do
		local a, b, c = v:match("(.-)A(.-)B(.*)")

		if a and b and c then
			self.BinaryOperatorFunctionTranslate[k] = {" " .. a, b, c .. " "}
		end
	end
end

function META:GetFunctionForBinaryOperator(token--[[#: Token]])
	return self.BinaryOperatorFunctionTranslate[token.value]
end

function META:AddPrefixOperatorFunctionTranslate(tbl--[[#: Map<|string, string|>]])
	for k, v in pairs(tbl) do
		local a, b = v:match("^(.-)A(.-)$")

		if a and b then
			self.PrefixOperatorFunctionTranslate[k] = {" " .. a, b .. " "}
		end
	end
end

function META:GetFunctionForPrefixOperator(token--[[#: Token]])
	return self.PrefixOperatorFunctionTranslate[token.value]
end

function META:AddPostfixOperatorFunctionTranslate(tbl--[[#: Map<|string, string|>]])
	for k, v in pairs(tbl) do
		local a, b = v:match("^(.-)A(.-)$")

		if a and b then
			self.PostfixOperatorFunctionTranslate[k] = {" " .. a, b .. " "}
		end
	end
end

function META:GetFunctionForPostfixOperator(token--[[#: Token]])
	return self.PostfixOperatorFunctionTranslate[token.value]
end

function META:IsValue(token--[[#: Token]])
	if token.type == "number" or token.type == "string" then return true end

	if self:IsKeywordValue(token) then return true end

	if self:IsKeyword(token) then return false end

	if token.type == "letter" then return true end

	return false
end

function META:GetTokenType(tk--[[#: Token]])
	if tk.type == "letter" and self:IsKeyword(tk) then
		return "keyword"
	elseif tk.type == "symbol" then
		if self:IsPrefixOperator(tk) then
			return "operator_prefix"
		elseif self:IsPostfixOperator(tk) then
			return "operator_postfix"
		elseif self:GetBinaryOperatorInfo(tk) then
			return "operator_binary"
		end
	end

	return tk.type
end

return META
