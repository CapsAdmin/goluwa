local T = require("test.helpers")
local analyze = T.RunCode
analyze([[
    local a = 1
    local function b(lol)
        if lol == 1 then return "foo" end
        return lol + 4, true
    end
    local d = b(2)
    attest.equal(d, 6)
    local d = b(a)
    attest.equal(d, "foo")
]])
analyze[[
    local function test(i)
        if i == 20 then
            return false
        end

        if i == 5 then
            return true
        end

        return "lol"
    end

    local a = test(20) -- false
    local b = test(5) -- true
    local c = test(1) -- "lol"

    attest.equal(a, false)
    attest.equal(b, true)
    attest.equal(c, "lol")
]]
analyze[[
    local function test(max)
        for i = 1, max do
            if i == 20 then
                return false
            end

            if i == 5 then
                return true
            end
        end
    end

    local a = test(20)
    attest.equal(a, _ as true | false)
]]
analyze[[
    local x = 0
    local MAYBE: true | false

    if MAYBE then
        x = 1
    end

    if MAYBE2 then
        attest.equal<|x, 0 | 1|>
        x = 2
    end

    if MAYBE then
        attest.equal<|x, 1 | 2|>
    end

]]
analyze([[
    -- assigning a value inside an uncertain branch
    local a = false

    if _ as any then
        attest.equal(a, false)
        a = true
        attest.equal(a, true)
    end
    attest.equal(a, _ as false | true)
]])
analyze([[
    -- assigning in uncertain branch and else part
    local a = false

    if _ as any then
        attest.equal(a, false)
        a = true
        attest.equal(a, true)
    else
        attest.equal(a, false)
        a = 1
        attest.equal(a, 1)
    end

    attest.equal(a, _ as true | 1)
]])
analyze([[
    local a: nil | 1

    if a then
        attest.equal(a, _ as 1)
    end

    attest.equal(a, _ as 1 | nil)
]])
analyze([[
    local a: nil | 1

    if a then
        attest.equal(a, _ as 1)
    else
        attest.equal(a, _ as nil)
    end

    attest.equal(a, _ as 1 | nil)
]])
analyze([[
    local a = 0

    if MAYBE then
        a = 1
    end
    attest.equal(a, _ as 0 | 1)
]])
analyze[[
    local a: nil | 1

    if a then
        attest.equal(a, _ as 1)
        if a then
            if a then
                attest.equal(a, _ as 1)
            end
            attest.equal(a, _ as 1)
        end
    end

    attest.equal(a, _ as 1 | nil)
]]
analyze([[
    local a: nil | 1

    if not a then
        attest.equal(a, _ as nil)
    end

    attest.equal(a, _ as 1 | nil)
]])
analyze[[
    local a: true | false

    if not a then
        attest.equal(a, false)
    else
        attest.equal(a, true)
    end
]]
analyze([[
    local a: number | string

    if type(a) == "number" then
        attest.equal(a, _ as number)
    end

    attest.equal(a, _ as number | string)
]])
analyze[[
    local a: 1 | false | true

    if type(a) == "boolean" then
        attest.equal(a, _ as boolean)
    end

    if type(a) ~= "boolean" then
        attest.equal(a, 1)
    else
        attest.equal(a, _ as boolean)
    end
]]

do
	_G.lol = nil
	analyze([[
        local type hit = analyzer function()
            _G.lol = (_G.lol or 0) + 1
        end

        local a: number
        local b: number

        if a == b then
            hit()
        else
            hit()
        end
    ]])
	equal(2, _G.lol)
	_G.lol = nil
end

analyze([[
    local a: 1
    local b: 1

    local c = 0

    if a == b then
        c = c + 1
    else
        c = c - 1
    end

    attest.equal(c, 1)
]])
analyze([[
    local a: number
    local b: number

    local c = 0

    if a == b then
        c = c + 1
    else
        c = c - 1
    end

    attest.equal(c, _ as -1 | 1)
]])
analyze[[
    local a = false

    attest.equal(a, false)

    if maybe then
        a = true
        attest.equal(a, true)
    end

    attest.equal(a, _ as true | false)
]]
analyze[[
    local a: true | false

    if a then
        attest.equal(a, true)
    else
        attest.equal(a, false)
    end

    if not a then
        attest.equal(a, false)
    else
        attest.equal(a, true)
    end

    if not a then
        if a then
            attest.equal("this should never be reached")
        end
    else
        if a then
            attest.equal(a, true)
        else
            attest.equal("unreachable code!!")
        end
    end
]]
analyze[[
    local a: nil | 1
        
    if a then
        attest.equal(a, _ as 1)
        if a then
            if a then
                attest.equal(a, _ as 1)
            end
            attest.equal(a, _ as 1)
        end
    end

    attest.equal(a, _ as 1 | nil)
]]
analyze[[
    local x: false | 1
    assert(not x)
    attest.equal(x, false)
]]
analyze[[
    local x: true | nil 
    attest.equal(assert(x), true)
    attest.equal(x, true)
]]
analyze[[
    local x: false | 1
    assert(x)
    attest.equal(x, 1)
]]
analyze[[
    local x: true | false
    
    if x then return end
    
    attest.equal(x, false)
]]
analyze[[
    local x: true | false
    
    if not x then return end
    
    attest.equal(x, true)
]]
analyze[[
    local c = 0

    if maybe then
        c = c + 1
    else
        c = c - 1
    end

    attest.equal(c, _ as -1 | 1)
]]
analyze([[
    local a: nil | 1
    if not a then return end
    attest.equal(a, 1)
]])
analyze([[
    local a: nil | 1
    if a then return end
    attest.equal(a, nil)
]])
analyze[[
    local a = true

    while maybe do
        a = false
    end

    attest.equal(a, _ as true | false)
]]
analyze[[
    local a = true

    for i = 1, 10 do
        a = false
    end

    attest.equal(a, _ as false)
]]
analyze[[
    local a = true

    for i = 1, _ as number do
        a = false
    end

    attest.equal(a, _ as true | false)
]]
analyze[[
    local a: {[string] = number}
    local b = true

    for k,v in pairs(a) do
        attest.equal(k, _ as string)
        attest.equal(v, _ as number)
        b = false
    end

    attest.equal(b, _ as true | false)
]]
analyze[[
    local a: {foo = number}
    local b = true

    for k,v in pairs(a) do
        b = false
    end

    attest.equal(b, _ as false)
]]
analyze([[
    local type a = {}

    if not a then
        -- shouldn't reach
        attest.equal(1, 2)
    else
        attest.equal(1, 1)
    end
]])
analyze([[
    local type a = {}
    if not a then
        -- shouldn't reach
        attest.equal(1, 2)
    end
]])
analyze[[
    local a: true | false | number | "foo" | "bar" | nil | 1

    if a then
        attest.equal(a, _ as true | number | "foo" | "bar" | 1)
    else
        attest.equal(a, _ as false | nil)
    end

    if not a then
        attest.equal(a, _ as false | nil)
    end

    if a == "foo" then
        attest.equal(a, "foo")
    end
]]
analyze[[
    local x: nil | true

    if not x then
        return
    end

    do
        do
            attest.equal(x, true)
        end
    end
]]
analyze[[
    local function parse_unicode_escape(s: string)
        local n = tonumber(s:sub(1, 1))
        
        if not n then
            return
        end
        
        if true then
            return n + 1
        end
    end
]]
analyze[[
    local function parse_unicode_escape(s: string)
        local n = tonumber(s:sub(1, 1))
        
        if not n then
            return
        end
        
        if true then
            local a = n
            return a + 1
        end
    end
]]
analyze[[
    do
        local s: string
        local _1337_false: false | 1337
        local _7777_false: false | 7777
    
        if not _1337_false then
            return
        end
    
        if not _7777_false then
            return
        end
    
        if _7777_false then
            return _1337_false - 1
        end
    end
]]
analyze[[
    local MAYBE: function=()>(boolean)
    local x = 0
    if MAYBE() then x = x + 1 end -- 1
    if MAYBE() then x = x - 1 end -- -1 | 0
    attest.equal(x, _ as -1 | 0 | 1)
]]
analyze[[
    local x = 0
    if MAYBE then
        x = 1
    else
        x = -1
    end
    attest.equal(x, _ as -1 | 1)
]]
analyze[[
    local x = 0
    if MAYBE then
        x = 1
    end
    attest.equal(x, _ as 0 | 1)
]]
analyze[[
    x = 1

    if MAYBE then
        x = 2
    end

    if MAYBE then
        x = 3
    end

    attest.equal(x, _ as 1|2|3)

    x = nil
]]
analyze[[
    local foo = false

    if MAYBE then
        foo = true
    end

    if true then
        foo = true
    end

    attest.equal(foo, true)
]]
analyze[[
    local x = 1

    if MAYBE then
        if true then
            x = 2
        end
    end

    attest.equal(x, _ as 1 | 2)
]]
analyze[[
    local x = 1

    if false then
        
    else
        x = 2
    end

    attest.equal(x, _ as 2)
]]
analyze[[
    local x = 1

    if MAYBE then
        x = 2
    end

    if MAYBE then
        x = 3
    end

    attest.equal(x, _ as 1 | 2 | 3)
]]
analyze[[
    --DISABLE_CODE_RESULT

    local x = 1

    if MAYBE then
        attest.equal<|x, 1|>
        x = 2
        attest.equal<|x, 2|>
    elseif MAYBE then
        attest.equal<|x, 1|>
        x = 3
        attest.equal<|x, 3|>
    elseif MAYBE then
        attest.equal<|x, 1|>
        x = 4
        attest.equal<|x, 4|>
    end

    attest.equal<|x, 1 | 2 | 3 | 4|>
]]
analyze[[
    local foo = false

    if MAYBE then
        foo = true
    end
    if not foo then
        return
    end

    attest.equal(foo, true)
]]
analyze[[
    local x = 1
    attest.equal<|x, 1|>
]]
analyze[[
    local x = 1
    do
        attest.equal<|x, 1|>
    end
]]
analyze[[
    local x = 1
    x = 2
    attest.equal<|x, 2|>
]]
analyze[[
    local x = 1
    if true then
        x = 2
    end
    attest.equal<|x, 2|>
]]
analyze[[
    local x = 1
    if MAYBE then
        x = 2
    end
    attest.equal<|x, 1 | 2|>
]]
analyze[[
    local x = 1
    if MAYBE then
        attest.equal<|x, 1|>
        x = 2
        attest.equal<|x, 2|>
    end
    attest.equal<|x, 1|2|>
]]
analyze[[
    local x = 1

    if math.random() > 0.5 then
        x = 2
        attest.equal<|x, 2|>
    else
        attest.equal<|x, 1|>
        x = 3
    end
    attest.equal<|x, 2 | 3|>
]]
analyze[[
    local x = 1

    if math.random() > 0.5 then
        x = 2
    elseif math.random() > 0.5 then
        x = 3
    elseif math.random() > 0.5 then
        x = 4
    end

    attest.equal<|x, 1|2|3|4|>
]]
analyze[[
    local x = 1

    if MAYBE then
        x = 2
    elseif MAYBE then
        x = 3
    elseif MAYBE then
        x = 4
    else
        x = 5
    end

    attest.equal<|x, 5|2|3|4|>
]]
analyze([[
    local x = 1

    if x == 1 then
        x = 2
    end

    if x == 2 then
        x = 3
    end

    attest.equal<|x, 3|>
]])
analyze[[
    local x: -1 | 0 | 1 | 2 | 3
    local y = x >= 0 and x or nil
    attest.equal<|y, 0 | 1 | 2 | 3 | nil|>

    local y = x >= 0 and x >= 1 and x or nil
    attest.equal<|y, 1 | 2 | 3 | nil|>
]]
analyze[[
    local function test(LOL)
        attest.equal(LOL, "str")
    end
    
    local x: 1 | "str"
    if x == 1 or test(x) then
    
    end
]]
analyze[[
    local function test(LOL)
        attest.equal(LOL, 1)
    end
    
    local x: 1 | "str"
    if x ~= 1 or test(x) then
    
    end
]]
analyze[[
    local function test(LOL)
        return LOL
    end
    
    local x: 1 | "str"
    local y = x ~= 1 or test(x)
    
    attest.equal<|y, 1 | true|>
]]
analyze[[
    local a = {}
    if MAYBE then
        a.lol = true
        attest.equal(a.lol, true)
    end
    attest.equal(a.lol, _ as nil | true)
]]
analyze[[
    if _ as boolean then
        local function foo() 
            local c = {}
            c.foo = true
            
            if _ as boolean then
                local function test()
                    local x = c.foo
                    attest.equal(x, true)
                end
                test()
            end
        end
        foo()
    end
]]
analyze[[
    local tbl = {foo = 1}

    if MAYBE then
        tbl.foo = 2
        attest.equal(tbl.foo, 2)
    end
    
    attest.equal(tbl.foo, _ as 1 | 2)
]]
analyze[[
    local tbl = {foo = {bar = 1}}

    if MAYBE then
        tbl.foo.bar = 2
        attest.equal(tbl.foo.bar, 2)
    end

    attest.equal(tbl.foo.bar, _ as 1 | 2)
]]
analyze[[
    local x: {
        field = number | nil,
    } = {}
    
    if MAYBE then
        x.field = nil
        attest.equal(x.field, nil)
    end
    attest.equal(x.field, _ as number | nil)
]]
analyze[[
    local x = { lol = _ as false | 1 }
    if not x.lol then
        if MAYBE then
            x.lol = 1 
        end
    end
    attest.equal(x.lol, _ as false | 1)
]]
analyze[[
    assert(maybe)

    local y = 1

    local function foo()
        local x = 1
        return 1
    end    

    attest.equal(foo(), 1)
]]
analyze[[
    local function lol()
        if MAYBE then
            return 1
        end
    end
    
    local x = lol()
    
    attest.equal<|x, 1 | nil|>
]]
analyze[[
    --DISABLE_CODE_RESULT

    local type HeadPos = {
        findheadpos_head_bone = number | false,
        findheadpos_head_attachment = number | nil,
        findheadpos_last_mdl = string | nil,
        @Name = "BlackBox",
    }

    local function FindHeadPosition(ent: mutable HeadPos)
        
        if MAYBE then
            ent.findheadpos_head_bone = false
        end
        
        if ent.findheadpos_head_bone then

        else
            if not ent.findheadpos_head_attachment then
                ent.findheadpos_head_attachment = _ as nil | number 
            end

            attest.equal<|ent.findheadpos_head_attachment, nil | number|>
        end
    end
]]
analyze[[
    local function test()
        if MAYBE then
            return "test"
        else
            return "foo"
        end
    end
    
    local x = test()
    
    attest.equal(x, _ as "test" | "foo")
]]
analyze[[
    local x: {foo = nil | 1}

    if x.foo then
        attest.equal(x.foo, 1)
    end
]]
analyze[[
    local MAYBE1: boolean
    local MAYBE2: boolean

    local x =  1

    if MAYBE1 then
        x = 2
    else
        if MAYBE2 then
            x = 3
        else
            x = 4
        end
    end

    attest.equal(x, _ as 2 | 3 | 4)
]]
analyze[[
    local MAYBE1: boolean
    local MAYBE2: boolean

    local x

    if MAYBE1 then
        x = function() return 1 end
    else
        if MAYBE2 then
            x = function() return 2 end
        else
            x = function() return 3 end
        end
    end
    
    -- none of the functions are called anywhere when looking x up, so x becomes just "function()" from the union's point of view
    -- this ensures that they are inferred before being added
    attest.equal(x(), _ as 1 | 2 | 3)
]]
analyze[[
    local x

    if _ as boolean then
        x = 1
    else
        x = 2
    end

    attest.equal(x, _ as 1 | 2)

    local function lol()
        attest.equal(x, _ as 1 | 2)
    end

    lol()
]]
analyze[[
    if math.random() > 0.5 then
        FOO = 1
    
        attest.equal(FOO, 1)
        
        do
            attest.equal(FOO, 1)
        end
    end
]]
analyze[[
    assert(math.random() > 0.5)

    LOL = true

    if math.random() > 0.5 then end

    attest.equal(LOL, true)
]]
analyze[[
    local foo = {}
    assert(math.random() > 0.5)

    foo.bar = 1

    if math.random() > 0.5 then end

    attest.equal(foo.bar, 1)
]]
analyze[[
    local foo = 1

    assert(_ as boolean)

    if _ as boolean then
        foo = 2

        if _ as boolean then
            local a = 1
        end

        attest.equal(foo, 2)
    end
]]
analyze[[
    local foo = 1

    assert(_ as boolean)

    if _ as boolean then
        foo = 2

        if _ as boolean then
            local a = 1
        else

        end

        attest.equal(foo, 2)
    end
]]
analyze[[
    local function test(x: ref any)
        attest.equal(x, true)
        return true
    end
    
    local function foo(x: {foo = boolean | nil}) 
        if x.foo and test(x.foo) then
            attest.equal(x.foo, true)
        end
    end
]]
analyze[[
    local META = {}
    META.__index = META

    type META.@Self = {
        Position = number,
    }

    local function GetStringSlice(start: number)
    end

    function META:IsString(str: string, offset: number | nil)
        offset = offset or 0
        GetStringSlice(self.Position + offset)
        GetStringSlice(self.Position)
        return math.random() > 0.5
    end


    local function ReadMultilineString(lexer: META.@Self)
        -- PushTruthy/FalsyExpressionContext leak to calls
        if lexer:IsString("[", 0) or lexer:IsString("[", 1) then
        end
    end

]]
analyze[[
    local MAYBE: boolean

    x = 1

    if MAYBE then
        x = 2
    end

    if MAYBE then
        x = 3
    end

    -- anything can happen in a global environment
    attest.equal(x, _ as 1|2|3)

    x = nil
]]
analyze[[
    local a: nil | 1

    if not not a then
        attest.equal(a, _ as nil)
    end

    attest.equal(a, _ as 1 | nil)
]]
analyze[[
    local x = 1

    do
        assert(math.random() > 0.5)

        x = 2
    end

    attest.equal(x, 2)
]]
analyze[[
    if false then
    else
        local x = 1
        do
            attest.equal(x, 1)
        end
    end
]]
analyze[[
    local bar

    if false then
    else
        local function foo()
            return 1
        end

        bar = function()
            return foo() + 1
        end
    end

    attest.equal(bar(), 2)
]]
analyze[[
    local tbl = {} as {field = nil | {foo = true | false}}

    if tbl.field and tbl.field.foo then
        attest.equal(tbl.field, _ as { foo = false | true })
    end
]]
analyze[[
    local type T = {
        config = {
            extra_indent = nil | {
                [string] = "toggle"|{to=string},
            },
            preserve_whitespace = boolean | nil,
        }
    }

    local x = _ as string
    local t = {} as T


    if t.config.extra_indent then
        local lol = t.config.extra_indent
        attest.equal(t.config.extra_indent[x], lol[x])
    end
]]
analyze[[
    local META = {}
    META.__index = META
    type META.@Self = {parent = number | nil}
    function META:SetParent(parent : number | nil)
        if parent then
            self.parent = parent
        else
            -- test BaseType:UpvalueReference collision with object and upvalue
            attest.equal(self.parent, _ as nil | number)
        end
    end
]]
analyze[[
    local x = _ as 1 | 2 | 3
    if x == 1 then return end
    attest.equal(x, _ as 2 | 3)
    if x ~= 3 then return end
    attest.equal(x, _ as 2)
    if x == 2 then return end
    error("dead code")
]]
analyze[[
    local x = _ as 1 | 2

    if x == 1 then
        attest.equal(x, 1)
        return
    else
        attest.equal(x, 2)
        return
    end
    
    error("shouldn't happen")
]]
analyze[[
    local lol
    if true then
        lol = {}
    end

    do
        if _ as boolean then
            lol.x = 1
        else
            lol.x = 2
        end

        local function get_files()
            attest.equal(lol.x, _ as 1 | 2)
        end
    end
]]
analyze[[
    -- mutation tracking for wide key
    local operators = {
        ["+"] = 1,
        ["-"] = -1,
        [">"] = 1,
        ["<"] = -1
    }
    local i = 0
    local op = "" as string

    if operators[op] then
        attest.equal(operators[op], _ as -1 | 1)
        i = operators[op]
    end

    attest.equal(i, _ as -1 | 0 | 1)
]]
analyze[[
    local ffi = require("ffi")

    do
        local C

        -- make sure C is not C | nil because it's assigned to the same value in both branches

        if ffi.os == "Windows" then
            C = assert(ffi.load("ws2_32"))
        else
            C = ffi.C
        end
        
        do 
            attest.equal(C, _ as ffi.C)
        end
    end
]]
analyze[=[
    local ffi = require("ffi")

    local x: boolean
    if x == true then
        error("LOL")
    end
    
    attest.equal(x, false)
    
    ffi.cdef[[
        void strerror(int errnum);
    ]]
    
    if ffi.os == "Windows" then
        local x = ffi.C.strerror
        attest.equal(x, _ as function=(number)>(nil))
    end
]=]
analyze[=[
    local ffi = require("ffi")

    if math.random() > 0.5 then
        ffi.cdef[[
            uint32_t FormatMessageA(
                uint32_t dwFlags,
            );
        ]]
        
        do
            if math.random() > 0.5 then
                ffi.C.FormatMessageA(1)
            end
        end
    
        if math.random() > 0.5 then
            ffi.C.FormatMessageA(1)
        end
    end
]=]
analyze[[
    local function foo(x: any)
        if type(x) == "string" then
            § SCOPE1 = analyzer:GetScope()
            x = 1
        elseif type(x) == "number" then
            § assert(not analyzer:GetScope():IsCertainFromScope(SCOPE1))
            x = 2
        elseif type(x) == "table" then
            § assert(not analyzer:GetScope():IsCertainFromScope(SCOPE1))
            x = 3
        end
    
        § SCOPE1 = nil
    end
]]
analyze[[
    local val: any

    if type(val) == "boolean" then
        val = ffi.new("int[1]", val and 1 or 0)
    elseif type(val) == "number" then
        val = ffi.new("int[1]", val)
    elseif type(val) ~= "cdata" then
        error("uh oh")
    end
    
    attest.equal(val, _ as any | {[number] = number})
]]
analyze(
	[[
    local function foo(b: true)
        if b then
    
        end
    end
]],
	nil,
	"if condition is always true"
)
analyze(
	[[
    local function foo(b: false)
        if false then
    
        end
    end
]],
	nil,
	"if condition is always false"
)
analyze(
	[[
    local function foo(b: false)
        if b then
    
        else
    
        end
    end
]],
	nil,
	"else part of if condition is always true"
)
analyze[[
    local function foo(b: literal ref boolean)
        if b then

        end
    end

    foo(true)
    foo(false)
    
    §assert(#analyzer.diagnostics == 0)
]]
analyze[[
    --local type print = any
    local ffi = require("ffi")

    do
        local C

        if ffi.os == "Windows" then
            C = assert(ffi.load("ws2_32"))
        else
            C = ffi.C
        end

        if ffi.os == "OSX" then
        elseif ffi.os == "Windows" then
        else -- posix
        end

        attest.equal(ffi.os == "Windows", _ as true | false)
    end
]]
analyze([[
    local function foo(x: literal ref (nil | boolean))
        if x then
    
        end
    end
    
    foo()
    foo(true)
    foo(false)

    §assert(#analyzer.diagnostics == 0)
]])
analyze[[
    local function foo(x: literal ref (nil | boolean))
        if x == false then
    
        end
    end
    
    foo()
    foo(true)
    foo(false)

    §assert(#analyzer.diagnostics == 0)
]]
analyze[[
    local function foo(x: literal ref (nil | boolean))
        if x == false then
    
        elseif x then
    
        else
    
        end
    end
    
    foo()
    foo(true)
    foo(false)

    §assert(#analyzer.diagnostics == 0)
]]
analyze[[
    local test
    local function foo()
        test()
    end

    test = function()
        if jit.os == "Linux" then
            return true
        end
    end
]]
analyze[[
    local x: string | {} | nil

    if x then
        if type(x) == "table" then
            attest.equal(x, {})
        end
    end
]]
analyze[[
    local x: -3 | -2 | -1 | 0 | 1 | 2 | 3

    if x >= 0 then
        attest.equal<|x, 0|1|2|3|>
        if x >= 1 then
            attest.equal<|x, 1|2|3|>
        end
    end
]]
analyze[[
    for i = 1, 10 do
        if i == 1 then
            
        end
    end

    §assert(#analyzer.diagnostics == 0)
]]
analyze[[
    local tbl = {foo = true, bar = false}

    for k,v in pairs(tbl) do
        if k == "foo" then
        end
    end

    §assert(#analyzer.diagnostics == 0)
]]
analyze[[
    local type AddressInfo = {
        addrinfo = 1337
    }
    local function connect(host: string | AddressInfo)
        if type(host) == "table" and host.addrinfo then
        else
            attest.equal(host, _ as string)
        end
    end
]]
analyze[[
    local function last_error()
        if math.random() > 0.5 then return "hello" end
    end
    
    if math.random() > 0.5 then return end
    
    local str = last_error()
    attest.equal(str, _  as nil | "hello")
]]
analyze[[
    local ffi = require("ffi")

    do
        assert(ffi.sizeof("int") == 4)
    end

    attest.truthy(ffi.sizeof)
]]
analyze[[
    local meta = {}
    meta.__index = meta
    type meta.@Self = {
        on_close = nil | function=(self)>(),
        on_receive = nil | function=(self, string, number, number)>(),
    }
    type meta.@Self.@Name = "TSocket"

    local function create()
        return setmetatable({}, meta)
    end

    function meta:close()
        if self.on_close then self:on_close() end
    end

    function meta:receive_from(size: number)
        return self:receive(size)
    end

    function meta:receive(size: number)
        if self.on_receive then return self:on_receive("hello", 1, size) end

        if math.random() > 0.5 then self:close() end
    end
]]
analyze[[
    local x = {}

    if math.random() > 0.5 then
        x.foo = true
        x.bar = {}

        do
            x.bar.lol = true
        end
    end

    attest.equal(x.bar, _  as nil | {lol = true})
]]
analyze[[
    local x = {}

    if math.random() > 0.5 then x.foo = "no!" end

    if math.random() > 0.4 then attest.equal(x.foo, _ as nil | "no!") end
]]
analyze[[
    local x = {lol = math.random()}
    if x.lol > 0.5 then x.foo = "no!" end
    if x.lol > 0.4 then attest.equal(x.foo, _ as nil | "no!") end
]]
analyze[[
    local x = {lol = math.random()}

    if x.lol > 0.5 then
        x.foo = "no!"

        do
            x.bar = "true"
            x.tbl = {}

            if math.random() > 0.5 then
                x.tbl.bar = true

                if math.random() > 0.5 then
                    x.tbl.foo = {}

                    if math.random() > 0.5 then
                        x.tbl.foo.test = 1337
                        x.tbl.foo.test2 = x
                    end
                end
            end
        end
    end

    local analyzer function GetMutatedFromScope(x: Table)
        return x:GetMutatedFromScope(analyzer:GetScope())
    end

    attest.equal<|GetMutatedFromScope<|x|>, {
        ["tbl"] = nil | {
                ["foo"] = nil | {
                        ["test2"] = CurrentType<|"table"|> | nil,
                        ["test"] = 1337 | nil
                },
                ["bar"] = nil | true
        },
        ["foo"] = "no!" | nil,
        ["lol"] = number,
        ["bar"] = "true" | nil
    }|>
]]
analyze[[
    do
        local x: {foo = nil | true}
    
        if x.foo == nil then
        return
        end
    
        attest.equal(x.foo, true)
    end
]]
analyze[[
    local x: true | false | 2

    if x then
        attest.equal(x, _  as true | 2)
        x = 1
    end

    attest.equal(x, _  as false | 1)
]]
analyze[[

    local x = 1
    local MAYBE = math.random() > 0.5
    
    if MAYBE then
        attest.equal<|x, 1|>
        x = 1.5
        attest.equal<|x, 1.5|>
        x = 1.75
        attest.equal<|x, 1.75|>
    
        if MAYBE then
            x = 2
    
            if MAYBE then x = 2.5 end
    
            attest.equal<|x, 2.5|>
        end
    
        x = 3
        attest.equal<|x, 3|>
    end
    
    attest.equal<|x, 3 | 2.5|>
]]

if false then
	pending[[
        local x = 1

        if math.random() > 0.5 then
            attest.equal<|x, 1|>
            x = 1.5
            attest.equal<|x, 1.5|>
            x = 1.75
            attest.equal<|x, 1.75|>
        
            if math.random() > 0.5 then
                x = 2
        
                if math.random() > 0.5 then x = 2.5 end
        
                attest.equal<|x, 2 | 2.5|>
            end
        
            x = 3
            attest.equal<|x, 3|>
        end

        attest.equal(x, _  as 3 | 1)
    ]]
	pending[[
        local x = 1

        if math.random() > 0.5 then
            if true then
                do
                    x = 1337
                end
            end
            attest.equal<|x, 1337|>
            x = 2
            attest.equal<|x, 2|>
        else
            attest.equal<|x, 1|>
            x = 66
        end
        
        attest.equal<|x, 1 | 2|>
    ]]
	pending[[
        local x = 1

        
        if MAYBE then
            x = 2

            if MAYBE then
                x = 1337
            end

            x = 0 -- the last one counts

        elseif MAYBE then
            x = 3
        elseif MAYBE then
            x = 4
        end

        attest.equal<|x, 1337 | 0 | 1 | 3 | 4|>
    ]]
	pending[[
        elseif MAYBE then
            attest.equal<|x, 1|>
            x = 3
            attest.equal<|x, 3|>
        elseif MAYBE then
            attest.equal<|x, 1|>
            x = 4
            attest.equal<|x, 4|>
        else
            attest.equal<|x, 1|>
            x = 5
            attest.equal<|x, 5|>
        end

        print(x)

        --attest.equal<|x, 1 | 2 | 3 | 4|>
    ]]
	pending([[
        local a: nil | 1

        if not a or true and a or false then
            attest.equal(a, _ as 1 | nil)
        end

        attest.equal(a, _ as 1 | nil)
    ]])
	pending[[
        local MAYBE: boolean
        local x = 0
        if MAYBE then x = x + 1 end -- 1
        if MAYBE then x = x - 1 end -- 0
        attest.equal(x, 0)
    ]]
	pending[[
        local type Shape = { kind = "circle", radius = number } | { kind = "square", sideLength = number }

        local function area(shape: Shape): number
            if shape.kind == "circle" then 
                print(shape.radius)
            else
                print(shape.sideLength)
            end 
        end
    ]]
	pending[[
        local a: nil | 1

        if not not a then
            attest.equal(a, _ as 1)
        end

        attest.equal(a, _ as 1 | nil)
    ]]
	pending[[
        local a: nil | 1

        if a or true and a or false then
            attest.equal(a, _ as 1 | 1)
        end

        attest.equal(a, _ as 1 | nil)
    ]]
	pending[[

        local x: number
        
        if x >= 0 and x <= 10 then
            attest.equal<|x, 0 .. 10|>
        end
    ]]
	pending[[
        local x: 1 | "1"
        local y = type(x) == "number"
        if y then
            attest.equal(x, 1)
        else
            attest.equal(x, "1")
        end
    ]]
	pending[[
        local x: 1 | "1"
        local y = type(x) ~= "number"
        if y then
            attest.equal(x, "1")
        else
            attest.equal(x, 1)
        end
    ]]
	pending[[
        local x: 1 | "1"
        local t = "number"
        local y = type(x) ~= t
        if y then
            attest.equal(x, "1")
        else
            attest.equal(x, 1)
        end
    ]]
end