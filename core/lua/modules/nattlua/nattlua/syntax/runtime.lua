local Syntax = require("nattlua.syntax").New
local runtime = Syntax()
runtime:AddSymbolCharacters(
	{
		",",
		";",
		"=",
		"::",
		{"(", ")"},
		{"{", "}"},
		{"[", "]"},
		{"\"", "\""},
		{"'", "'"},
		{"<|", "|>"},
	}
)
runtime:AddNumberAnnotations({
	"ull",
	"ll",
	"ul",
	"i",
})
runtime:AddKeywords(
	{
		"do",
		"end",
		"if",
		"then",
		"else",
		"elseif",
		"for",
		"in",
		"while",
		"repeat",
		"until",
		"break",
		"return",
		"local",
		"function",
		"and",
		"not",
		"or",
		-- these are just to make sure all code is covered by tests
		"ÆØÅ",
		"ÆØÅÆ",
	}
)
-- these are keywords, but can be used as names
runtime:AddNonStandardKeywords({"continue", "import", "literal", "ref", "mutable", "goto"})
runtime:AddKeywordValues({
	"...",
	"nil",
	"true",
	"false",
})
runtime:AddPrefixOperators({"-", "#", "not", "!", "~", "supertype"})
runtime:AddPostfixOperators(
	{
		-- these are just to make sure all code is covered by tests
		"++",
		"ÆØÅ",
		"ÆØÅÆ",
	}
)
runtime:AddBinaryOperators(
	{
		{"or", "||"},
		{"and", "&&"},
		{"<", ">", "<=", ">=", "~=", "==", "!="},
		{"|"},
		{"~"},
		{"&"},
		{"<<", ">>"},
		{"R.."}, -- right associative
		{"+", "-"},
		{"*", "/", "/idiv/", "%"},
		{"R^"}, -- right associative
	}
)
runtime:AddPrimaryBinaryOperators({
	".",
	":",
})
runtime:AddBinaryOperatorFunctionTranslate(
	{
		[">>"] = "bit.rshift(A, B)",
		["<<"] = "bit.lshift(A, B)",
		["|"] = "bit.bor(A, B)",
		["&"] = "bit.band(A, B)",
		["//"] = "math.floor(A / B)",
		["~"] = "bit.bxor(A, B)",
	}
)
runtime:AddPrefixOperatorFunctionTranslate({
	["~"] = "bit.bnot(A)",
})
runtime:AddPostfixOperatorFunctionTranslate({
	["++"] = "(A+1)",
	["ÆØÅ"] = "(A)",
	["ÆØÅÆ"] = "(A)",
})
return runtime
