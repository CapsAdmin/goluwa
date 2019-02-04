local oh = ... or _G.oh

return function(syntax)
    if syntax.UTF8 then
        syntax.TokenizerSetup = oh.utf8_tokenizer_config
    end

    do
        local map = {}

        map.space = syntax.SpaceCharacters or {" ", "\n", "\r", "\t"}

        if syntax.NumberCharacters then
            map.number = syntax.NumberCharacters
        else
            map.number = {}
            for i = 0, 9 do
                map.number[i+1] = tostring(i)
            end
        end

        if syntax.LetterCharacters then
            map.letter = syntax.LetterCharacters
        else
            map.letter = {"_"}

            for i = string.byte("A"), string.byte("Z") do
                table.insert(map.letter, string.char(i))
            end

            for i = string.byte("a"), string.byte("z") do
                table.insert(map.letter, string.char(i))
            end
        end

        if syntax.SymbolCharacters then
            map.symbol = syntax.SymbolCharacters
        else
            error("syntax.SymbolCharacters not defined", 2)
        end

        map.end_of_file = {syntax.EndOfFileCharacter or ""}

        syntax.CharacterMap = map
    end

    do -- extend the symbol map from grammar rules
        for _, symbol in pairs(syntax.UnaryOperators) do
            if symbol:find("%p") then
                table.insert(syntax.CharacterMap.symbol, symbol)
            end
        end

        for priority, group in ipairs(syntax.Operators) do
            for _, token in ipairs(group) do
                if token:find("%p") then
                    if token:sub(1, 1) == "R" then
                       token = token:sub(2)
                    end

                    table.insert(syntax.CharacterMap.symbol, token)
                end
            end
        end

        for _, symbol in ipairs(syntax.Keywords) do
            if symbol:find("%p") then
                table.insert(syntax.CharacterMap.symbol, symbol)
            end
        end
    end

    do
        local temp = {}
        for type, chars in pairs(syntax.CharacterMap) do
            for i, char in ipairs(chars) do
                temp[char] = type
            end
        end
        syntax.CharacterMap = temp

        syntax.LongestSymbolLength = 0
        syntax.SymbolLookup = {}

        for char, type in pairs(syntax.CharacterMap) do
            if type == "symbol" then
                syntax.SymbolLookup[char] = true
                do -- this triggers symbol lookup. For example it adds "~" from "~=" so that "~" is a symbol
                    local first_char = string.sub(char, 1, 1)
                    if not syntax.CharacterMap[first_char] then
                        syntax.CharacterMap[first_char] = "symbol"
                    end
                end
                syntax.LongestSymbolLength = math.max(syntax.LongestSymbolLength, #char)
            end
        end
    end

    do -- grammar rules
        if syntax.UTF8 then
            function syntax.GetCharacterType(char)
                return syntax.CharacterMap[char] or (syntax.FallbackCharacterType and char:byte() < 128)
            end
        else
            function syntax.GetCharacterType(char)
                return syntax.CharacterMap[char]
            end
        end

        function syntax.IsValue(token)
            return token.type == "number" or token.type == "string" or syntax.KeywordValues[token.value]
        end

        function syntax.IsOperator(token)
            return syntax.Operators[token.value] ~= nil
        end

        function syntax.GetLeftOperatorPriority(token)
            return syntax.Operators[token.value] and syntax.Operators[token.value][1]
        end

        function syntax.GetRightOperatorPriority(token)
            return syntax.Operators[token.value] and syntax.Operators[token.value][2]
        end

        function syntax.GetFunctionForOperator(token)
            return syntax.OperatorFunctions[token.value]
        end

        function syntax.GetFunctionForUnaryOperator(token)
            return syntax.UnaryOperatorFunctions[token.value]
        end

        function syntax.IsUnaryOperator(token)
            return syntax.UnaryOperators[token.value]
        end

        function syntax.IsKeyword(token)
            return syntax.Keywords[token.value]
        end

        local temp = {}
        for priority, group in ipairs(syntax.Operators) do
            for _, token in ipairs(group) do
                if token:sub(1, 1) == "R" then
                    temp[token:sub(2)] = {priority + 1, priority}
                else
                    temp[token] = {priority, priority}
                end
            end
        end
        syntax.Operators = temp

        local temp = {}
        for i, val in pairs(syntax.UnaryOperators) do
            temp[val] = true
        end
        syntax.UnaryOperators = temp

        local temp = {}
        for k,v in pairs(syntax.Keywords) do
            temp[v] = v
        end
        syntax.Keywords = temp

        local temp = {}
        for k,v in pairs(syntax.KeywordValues) do
            temp[v] = v
        end
        syntax.KeywordValues = temp
    end

    return syntax
end