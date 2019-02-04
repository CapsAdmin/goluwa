local syntax = {}

syntax.UTF8 = true

syntax.SymbolCharacters = {
    ".", ",", ":", ";",
    "(", ")", "{", "}", "[", "]",
    "=", "::", "\"", "'",
}

syntax.Keywords = {
    "and", "break", "do", "else", "elseif", "end",
    "false", "for", "function", "if", "in", "local",
    "nil", "not", "or", "repeat", "return", "then",
    "...",
}

syntax.KeywordValues = {
    "...",
    "nil",
    "true",
    "false",
}

syntax.UnaryOperators = {
    "-", "#", "not", "~",
}

syntax.Operators = {
    {"or"},
    {"and"},
    {"<", ">", "<=", ">=", "~=", "=="},
    {"|"},
    {"~"},
    {"&"},
    {"<<", ">>"},
    {"R.."}, -- right associative
    {"+", "-"},
    {"*", "/", "//", "%"},
    {"R^"}, -- right associative
}

syntax.OperatorFunctions = {
    [">>"] = "bit.rshift",
    ["<<"] = "bit.lshift",
    ["|"] = "bit.bor",
    ["&"] = "bit.band",
    ["//"] = "math.floordiv",
    ["~"] = "bit.bxor",
}

syntax.UnaryOperatorFunctions = {
    ["~"] = "bit.bnot",
}

-- temp
function math.floordiv(a, b)
    return math.floor(a / b)
end

return syntax