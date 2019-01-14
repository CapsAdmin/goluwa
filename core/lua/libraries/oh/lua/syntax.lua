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
    ["or"] = 1,
    ["and"] = 2,
    ["<"] = 3, [">"] = 3, ["<="] = 3, [">="] = 3, ["~="] = 3, ["=="] = 3,
    [".."] = -7, -- right associative
    ["+"] = 8, ["-"] = 8,
    ["*"] = 9, ["/"] = 9, ["%"] = 9,
    ["^"] = -11, -- right associative
}

return syntax