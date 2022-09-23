local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
        -- pairs on literal table
        local tbl = {1,2,3}
        local key_sum = 0
        local val_sum = 0

        for key, val in pairs(tbl) do
            key_sum = key_sum + key
            val_sum = val_sum + val
        end
        
        attest.equal(key_sum, 6)
        attest.equal(val_sum, 6)
    ]]
--[=[
analyze[[
    -- ipairs on non literal table
    local tbl = {1,2,3} as {[number] = number}
    local key_sum = 0
    local val_sum = 0

    for key, val in ipairs(tbl) do
        key_sum = key_sum + key
        val_sum = val_sum + val

        attest.equal(key, _ as number)
        attest.equal(val, _ as number)
    end
    
    attest.equal(key_sum, _ as number | 0)
    attest.equal(val_sum, _ as number | 0)
]]
]=] analyze[[
    -- pairs on non literal table

    local tbl:{[number] = number} = {1,2,3}
    
    for key, val in pairs(tbl) do
        attest.equal(key, _ as number)
        attest.equal(val, _ as number)
    end
]]
analyze[[
        -- pairs on any should at least make k,v any
        local key, val

        for k,v in pairs(unknown) do
            key = k
            val = v
        end

        attest.equal(key, _ as any | nil)
        attest.equal(val, _ as any | nil)
    ]]
analyze[[
    local x = 0
    for i = 1, 10 do
        x = x + i
    end
    attest.equal(x, 55)
]]
analyze[[
    local x = 0
    for i = 1, 10 do
        x = x + i
        if i == 4 then
            break
        end
    end
    attest.equal(x, 10)
]]
analyze[[
    local x = 0
    for i = 1, 10 do
        x = x + i
        if i == maybe then
            break
        end
    end
    attest.equal(x, _ as number)
]]
analyze[[
    local a, b = 0, 0
    for i = 1, 8000 do
        if 5 == i then
            a = 1
        end
        if i == 5 then
            b = 1
        end
    end
    attest.equal(a, _ as number)
    attest.equal(b, _ as number)
]]
analyze[[
    local t = {foo = true}
    for k,v in pairs(t) do
        attest.equal(k, _ as "foo")
        attest.equal(v, _ as true)
    end
]]
