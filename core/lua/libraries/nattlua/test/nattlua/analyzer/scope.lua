local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    local lol
    do
        lol = 1
    end

    do
        attest.equal(lol, 1)
    end
]]
analyze([[
    -- test shadow upvalues
    local foo = 1337

    local function test()
        attest.equal(foo, 1337)
    end
    
    local foo = 666
]])
analyze([[
    -- test shadow upvalues
    local foo = 1337

    function test()
        attest.equal(foo, 1337)
    end
    
    local foo = 666
]])
analyze[[
    local foo = 1337

    local function test()
        if math.random() > 0.5 then
            attest.equal(foo, 1337)
        end
    end

    local foo = 666
]]
analyze[[
    local x = 0

    local function lol()
        attest.equal(x, _ as 0 | 1 | 2)
    end
    
    local function foo()
        x = x + 1
    end
    
    local function bar()
        x = x + 1
    end
]]
