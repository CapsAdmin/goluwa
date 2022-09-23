local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    local function test() 
        if MAYBE then
            return nil
        end
        return 2
    end
    
    local x = { lol = _ as false | 1 }
    if not x.lol then
        x.lol = test()
        attest.equal(x.lol, _ as 2 | nil)
    end

    attest.equal(x.lol, _ as 1 | 2 | false | nil)
]]
analyze[[
    local x = _ as nil | 1 | false
    if x then x = false end
    attest.equal<|x, nil | false|>

    local x = _ as nil | 1
    if not x then x = 1 end
    attest.equal<|x, 1|>

    local x = _ as nil | 1
    if x then x = nil end
    attest.equal<|x, nil|>
]]
