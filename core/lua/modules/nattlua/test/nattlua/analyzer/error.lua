local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    local function foo()
        local x = _ as boolean
        if not x then
            error("!")
        end
        return x
    end
    
    local y = foo()
    attest.equal(y, true)
]]
analyze[[
    local function throw()
        error("lol")
    end
    
    local x = tonumber(_ as string)
    attest.equal(x, _ as nil | number)
    if not x then
        throw()
    end
    attest.equal(x, _ as number)
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
    local x = ("lol"):byte(1,1 as 1 | 0)
    if not x then 
        error("lol")
    end

    attest.equal(x, 108)
]]
analyze[[
    local a: 1 | nil

    if not a then
        assert(false)
    end

    attest.equal(a, 1)
]]
analyze[[
    local a = assert(_ as 1 | nil)
    --attest.equal(a, 1)
]]
analyze[[
    local function foo(input)
        local x = tonumber(input)
        if not x then
            error("!")
        end
        return x
    end
    
    local y = foo(_ as string)
    attest.equal<|y, number|>
]]
analyze[[
    local a: 1 | nil

    if not a then
        error("!")
    end

    attest.equal(a, 1)
]]
analyze[[
    local a = true

    if MAYBE then
        error("!")
    end

    attest.equal(a, true)
]]
analyze[[
    local function foo()
        local x = math.random() > 0.5
        if x then
            return 1
        end
    
        error("nope")
    end
]]
analyze[[
    local function throw()
        error("nope")
    end
    
    local function foo()
        local x = math.random() > 0.5
        if x then
            return 1
        end
    
        throw()
    end
]]
analyze[[
    local function throw()
        error("nope")
    end
    
    local function foo(): number
        local x = math.random() > 0.5
        if x then
            return 1
        end
        
        throw()
    end
]]
analyze[[
    local function foo(): number
        local x = math.random() > 0.5
        if x then
            return 1
        end
    
        error("nope")
    end

    local x = foo()

    attest.equal(x, _ as number)
]]
analyze[[
    local function foo(): number
        local x = math.random() > 0.5
        if x then
            error("nope")
        end
        
        return 1
    end
]]
analyze[[
    local function throw()
        error("nope")
    end
    
    local function foo(): number
        local x = math.random() > 0.5
        if x then
            throw()
        end
        
        return 1
    end
    
    attest.equal(foo(), _ as number)
]]
analyze[[
    local function throw()
        error("!")
    end

    do
        local function bar()
            throw()
        end

        local function foo()
            bar()
        end

        local function test()
            if MAYBE then return 1 end 
            foo()
            return 2
        end

        attest.equal(test(), 1)
    end
]]
analyze[[
    local map = {
        --foo = function(x: nil | number) if math.random() > 0.5 then throw() end return 1 end,
        bar = function() 
            if math.random() > 0.5 then
                error("!")
            end
            return 2 
        end,
    }
    
    local function main()
        local x = map[_ as string]
        if x then
            local val = x()
            --attest.equal(x, _ as function=()>())
            return val
        end
        error("nope")
    end
    
    attest.equal(main(), 2)
]]
analyze[[
    local function codepoint_to_utf8(n: number): ref string
        --§assert(analyzer:IsDefinetlyReachable())
        -- if called from parse_unicode_escape then it's not nessecearily reachable here

        if math.random() > 0.5 then
            §assert(not analyzer:IsDefinetlyReachable())
            return "foo"
        end
        §assert(not analyzer:IsDefinetlyReachable())
        error("no!")
    end
    
    
    local function parse_unicode_escape(s: string): ref string
        §assert(analyzer:IsDefinetlyReachable())
        local n1 = 1 as nil | number
        §assert(analyzer:IsDefinetlyReachable())
        if not n1 then 
            error("failed to parse unicode escape")
        end
        §assert(not analyzer:IsDefinetlyReachable())
        local x = codepoint_to_utf8(n1)
        §assert(not analyzer:IsDefinetlyReachable())
        attest.equal(x, "foo")
        return x
    end
    
    local x = parse_unicode_escape("lol")
    attest.equal(x, "foo")
]]
analyze[[
    local map = {
        foo = function()
            if math.random() > 0.5 then
                return "str", 1
            end
            do
                error("lol")
            end
        end,
    }
    
    local function parse(): string, number
        local f = map[_ as string]
        if f then
            local x,y = f()
            return x,y
        end
        error("lol")
    end
    
    parse()    
]]
analyze[[
    local function foo()
        local x = _ as 1 | 2 | 3
    
        if x == 1 then
            error("nope")
        end
    
        if x == 2 then
            error("nope")
        end
    
        attest.equal(x, 3)
    end
]]
