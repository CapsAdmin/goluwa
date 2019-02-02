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
    {"&"},
    {"<<", ">>"},
    {"R.."}, -- right associative
    {"+", "-"},
    {"*", "/", "//", "%"},
    {"R^"}, -- right associative
}

return syntax