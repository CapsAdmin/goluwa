local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
        local a = "1234"
        attest.equal(string.len(a), 4)
        attest.equal(a:len(), 4)
    ]]
analyze[[
        local a: $"FOO_.-" = "FOO_BAR"
    ]]
analyze([[
        local a: $"FOO_.-" = "lol"
    ]], "cannot find .- in pattern")
analyze[===[
    local foo = [[foo]]
    local bar = [=[foo]=]
    local faz = [==[foo]==]
    
    attest.equal(foo, "foo")
    attest.equal(bar, "foo")
    attest.equal(faz, "foo")
]===]
analyze[=[
    local fixed = {
        "a", "b", "f", "n", "r", "t", "v", "\\", "\"", "'",
    }
    local pattern = "\\[" .. table.concat(fixed, "\\") .. "]"

    local map_double_quote = {[ [[\"]] ] = [["]]}
    local map_single_quote = {[ [[\']] ] = [[']]}

    for _, v in ipairs(fixed) do
        map_double_quote["\\" .. v] = load("return \"\\" .. v .. "\"")()
        map_single_quote["\\" .. v] = load("return \"\\" .. v .. "\"")()
    end

    local function reverse_escape_string(str, quote)
        if quote == "\"" then
            str = str:gsub(pattern, map_double_quote)
        elseif quote == "'" then
            str = str:gsub(pattern, map_single_quote)
        end
        return str
    end

    attest.equal(reverse_escape_string("hello\\nworld", "\""), "hello\nworld")
]=]
analyze[[
    attest.equal("\x41\x41\065", "AAA")
    attest.equal("\065\065\x41", "AAA")
    attest.equal("\032\032\x41", "  A")
    attest.equal("\32\32\65", "  A")
    attest.equal("\u{01F698}", "🚘")
    attest.equal("\xFF", "\xfF")
]]
