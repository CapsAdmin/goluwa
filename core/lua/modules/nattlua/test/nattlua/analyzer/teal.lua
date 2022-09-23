local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    £parser.TealCompat = true
    local record tl
        enum LoadMode
            "b"
            "t"
            "bt"
        end
        lol: LoadMode
    end
    £parser.TealCompat = false

    attest.equal(tl.LoadMode, _ as "b" | "bt" | "t")
    attest.equal(tl.lol, _ as "b" | "bt" | "t")
]]
analyze[[
    £parser.TealCompat = true

    local record VisitorCallbacks<N, T>
        foo: N
        bar: T
    end

    local x: VisitorCallbacks<string, number> = {foo = "hello", bar = 42}
    £parser.TealCompat = false

    attest.equal(x, _ as {foo = string, bar = number})
]]
analyze[[
    £parser.TealCompat = true

    local x: {string}
    
    £parser.TealCompat = false

    attest.equal(x, _ as {[number] = string})
]]
analyze[[
    £parser.TealCompat = true

    local x: {string, number, boolean}
    
    £parser.TealCompat = false

    attest.equal(x, _ as {string, number, boolean})
]]
analyze[[
    £parser.TealCompat = true

    local x: {string, number, boolean}
    
    £parser.TealCompat = false

    attest.equal(x, _ as {string, number, boolean})
]]
analyze[[
    £parser.TealCompat = true
    local record tl
        load_envs: { {any:any} : string }
    end
    £parser.TealCompat = false

    attest.equal(tl, _ as {load_envs = {[{[any] = any}] = string}})
]]
analyze[[
    £parser.TealCompat = true
    local enum TokenKind
        "foo"
        "bar"
        "faz"
    end
    attest.equal<|TokenKind, "foo" | "bar" | "faz"|>
]]
analyze[[
    £parser.TealCompat = true
    type LoadFunction = function(...:any): any...
    attest.equal<|LoadFunction, Function|>
]]
analyze[[
    £parser.TealCompat = true
    local type Color = string
    local record BagData
        count: number
        color: Color
    end
    local type DirectGraph = {Color:{BagData}}
    £parser.TealCompat = false
    attest.equal<|DirectGraph, {[string] = {[number] = {count = number, color = string}}}|>
]]
analyze[[
    £parser.TealCompat = true
    §analyzer.TealCompat = true

    local type Color = string
    local record BagData
        count: number
        color: Color
    end
    local type DirectGraph = {Color:{BagData}}
    local function parse_line(_line: string) : Color, {BagData}
        return "teal", {} as {BagData}
    end
    local M = {}
    function M.parse_input() : DirectGraph
        local r = {}
        local lines = {"a", "b"}
        for _, line in ipairs(lines) do
            local color, data = parse_line(line)
            r[color] = data
        end
        return r
    end
    £parser.TealCompat = false

    local res = M.parse_input()

    attest.equal<|res, {
        [string] = { 
            [number] = {
                ["count"] = number,
                ["color"] = string,
            }
        }
    }|>
]]