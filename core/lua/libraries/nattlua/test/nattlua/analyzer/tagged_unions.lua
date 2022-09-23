local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    local x = _  as {foo = true, bar = 1337} | {foo = false, bar = 777}

    if x.foo then 
        attest.equal(x.bar, 1337) 
    else 
        attest.equal(x.bar, 777) 
    end
]]
analyze[[
    local x = _  as {foo = true, bar = 1337, lol = "!?", kind = 1} | {foo = false, bar = 777, kind = 2}

    if x.kind == 2 then 
        attest.equal(x, {foo = false, bar = 777, kind = 2}) 
    end
]]
analyze[[
    local x = _  as {foo = true, bar = 1337, lol = "!?", kind = 1} | {foo = false, bar = 777, kind = 2}

    if x.kind == 2 then 
        attest.equal(x, {foo = false, bar = 777, kind = 2}) 
    else
        attest.equal(x.bar, 1337)
    end
]]
analyze[[
    local x = _  as {foo = true, bar = 1337, lol = "!?", kind = 1} | {foo = false, bar = 777, kind = 2}

    if x.kind == 2 or x.bar == 1337 then 
        attest.equal(x.bar, _ as 1337 | 777)
    else
        error("shouldn't be reached")
    end
]]
analyze[[
    local x = _  as {foo = true, bar = 1337, lol = "!?", kind = 1} | {foo = false, bar = 777, kind = 2}

    if x.bar ~= 1337 then 
        attest.equal(x.bar, 777)
    else
        attest.equal(x.bar, 1337)
    end
]]