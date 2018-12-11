
local TOKENIZER
local BUILDER

do
    TOKENIZER = {}
    TOKENIZER.__index = TOKENIZER

    do -- these can/should be overriden with an utf8 variant
        function TOKENIZER:GetLength()
            return #self.code
        end

        function TOKENIZER:GetCharOffset(offset)
            return string.sub(self.code, self.i + offset, self.i + offset)
        end

        function TOKENIZER:GetCharsRange(start, stop)
            return string.sub(self.code, start, stop)
        end
    end

    function TOKENIZER:GetCurrentChar()
        return self:GetCharOffset(0)
    end

    function TOKENIZER:GetCharsOffset(length)
        return self:GetCharsRange(self.i, self.i + length)
    end

    function TOKENIZER:GetCharType(char)
        return self.CharacterMap[char] or (self.FallbackCharacterType and char:byte() < 128)
    end

    function TOKENIZER:ReadChar()
        local char = self:GetCurrentChar()
        self.i = self.i + 1
        return char
    end

    function TOKENIZER:ReadCharByte()
        local b = self:GetCurrentChar()
        self.i = self.i + 1
        return b
    end

    function TOKENIZER:Advance(len)
        self.i = self.i + len
    end

    function TOKENIZER:Error(msg, start, stop)
        if self.OnError then
            self:OnError(msg, start or self.i, stop or self.i)
        end
    end

    function TOKENIZER:BufferWhitespace(type, start, stop)
        self.whitespace_buffer[self.whitespace_buffer_i] = {
            type = type,
            start = start == 1 and 0 or start,
            stop = stop,
            value = self:GetCharsRange(start, stop),
        }

        self.whitespace_buffer_i = self.whitespace_buffer_i + 1
    end

    function TOKENIZER:ReadToken()
        if self.ShebangTokenType.Is(self) then
            self.ShebangTokenType.Capture(self)
            return self.ShebangTokenType.Type, 1, self.i - 1, {}
        end

        local type, start, stop, whitespace = self:CaptureToken()

        if not type then
            local start = self.i
            local char = self:ReadChar()
            local stop = self.i - 1

            return "unknown", start, stop, {}
        end

        return type, start, stop, whitespace
    end

    function TOKENIZER:GetTokens()
        self.i = 1

        local tokens = {}
        local tokens_i = 1

        for _ = self.i, self.code_length do
            local type, start, stop, whitespace = self:ReadToken()

            tokens[tokens_i] = {
                type = type,
                start = start,
                stop = stop,
                whitespace = whitespace,
                value = self:GetCharsRange(start, stop)
            }

            if type == "end_of_file" then break end

            tokens_i = tokens_i + 1
        end

        return tokens
    end

    function TOKENIZER:ResetState()
        self.code_length = self:GetLength()
        self.whitespace_buffer = {}
        self.whitespace_buffer_i = 1
        self.i = 1
    end
end

do
    BUILDER = {}
    BUILDER.__index = BUILDER

    function BUILDER:SetupSyntax(syntax)
        self.CharacterMap = {}

        for type, chars in pairs(syntax) do
            for i, char in ipairs(chars) do
                self.CharacterMap[char] = type
            end
        end

        self.longest_symbol = 0
        self.SymbolLookup = {}

        for char, type in pairs(self.CharacterMap) do
            if type == "symbol" then
                self.SymbolLookup[char] = true
                do -- this triggers symbol lookup. For example it adds "~" from "~=" so that "~" is a symbol
                    local first_char = string.sub(char, 1, 1)
                    if not self.CharacterMap[first_char] then
                        self.CharacterMap[first_char] = "symbol"
                    end
                end
                self.longest_symbol = math.max(self.longest_symbol, #char)
            end
        end
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

        function BUILDER:BuildCaptureLoop(tokenizer)
            local sorted_token_classes = tolist(self.TokenClasses)
            local sorted_whitespace_classes = tolist(self.WhitespaceClasses)

            local code = "return function(self)\n"

            code = code .. "\tfor _ = self.i, self.code_length do\n"
            for i, class in ipairs(sorted_whitespace_classes) do
                if i == 1 then
                    code = code .. "\t\tif "
                else
                    code = code .. "\t\telseif "
                end

                code = code .. "self.WhitespaceClasses." .. class.val.Type .. ".Is(self) then\n"
                code = code .. "\t\t\tlocal start = self.i\n"
                code = code .. "\t\t\tself.WhitespaceClasses." .. class.val.Type .. ".Capture(self)\n"
                code = code .. "\t\t\tself:BufferWhitespace(\"" .. class.val.ParserType .. "\", start, self.i - 1)\n"
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

                code = code .. "self.TokenClasses." .. class.val.Type .. ".Is(self) then\n"
                code = code .. "\t\tlocal start = self.i\n"
                code = code .. "\t\tself.TokenClasses." .. class.val.Type .. ".Capture(self)\n"
                code = code .. "\t\tlocal whitespace = self.whitespace_buffer\n"
                code = code .. "\t\tself.whitespace_buffer = {}\n"
                code = code .. "\t\tself.whitespace_buffer_i = 1\n"
                code = code .. "\t\treturn \"" .. class.val.ParserType .. "\", start, self.i - 1, whitespace\n"
            end
            code = code .. "\tend\n"
            code = code .. "end\n"

            return assert(loadstring(code))()
        end
    end


    function BUILDER:RegisterTokenClass(tbl)
        tbl.ParserType = tbl.ParserType or tbl.Type
        tbl.Priority = tbl.Priority or 0

        self.TokenClasses = self.TokenClasses or {}
        self.WhitespaceClasses = self.WhitespaceClasses or {}

        if tbl.Whitespace then
            self.WhitespaceClasses[tbl.Type] = tbl
        else
            self.TokenClasses[tbl.Type] = tbl
        end
    end

    function BUILDER:BuildTokenizer(config)
        self:SetupSyntax(config.Syntax)

        config.FallbackCharacterType = config.FallbackCharacterType or false
        config.OnInitialize = config.OnInitialize or function(self, code, on_error) self.code = code end

        local CaptureToken = self:BuildCaptureLoop()

        return function(code, on_error)
            local tk = setmetatable({}, TOKENIZER)

            tk.CaptureToken = CaptureToken

            config.OnInitialize(tk, code, on_error)

            tk.OnError = on_error or false

            tk.GetCharsRange = config.GetCharsRange or tk.GetCharsRange
            tk.GetCharOffset = config.GetCharOffset or tk.GetCharsOffset
            tk.GetLength = config.GetLength or tk.GetLength
            tk.FallbackCharacterType = config.FallbackCharacterType

            tk.TokenClasses = self.TokenClasses
            tk.WhitespaceClasses = self.WhitespaceClasses
            tk.ShebangTokenType = self.ShebangTokenType
            tk.CharacterMap = self.CharacterMap
            tk.longest_symbol = self.longest_symbol
            tk.SymbolLookup = self.SymbolLookup

            return tk
        end
    end
end

return function()
    local self = setmetatable({}, BUILDER)


    do -- eof
        local Token = {}

        Token.Type = "end_of_file"
        Token.Priority = math.huge

        function Token:Is()
            return self.i > self.code_length
        end

        function Token:Capture()
            -- nothing to capture, but remaining whitespace will be added
        end

        self:RegisterTokenClass(Token)
    end

    return self
end