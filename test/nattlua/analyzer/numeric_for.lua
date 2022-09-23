local T = require("test.helpers")
local analyze = T.RunCode
local transpile = T.Transpile
analyze[[
    for i = 1, 10000 do
        attest.equal(i, _ as 1 .. 10000)
    end
]]
analyze[[
    for i = 1, _ as number do
        attest.equal(i, _ as 1..inf)
    end
]]
analyze[[
    --for i = 1, number is an uncertain scope
    local a = 0
    for i = 1, _ as number do
        attest.equal(i, _ as 1..inf)
        a = 1
    end
    attest.equal(a, _ as number)
]]
analyze[[
    local a = 0
    for i = 1, _ as number do
        a = a + 1
    end
    attest.equal(a, _ as number)
]]

if false then
	local code = transpile([[
        local x
        for i = 1, 2 do -- i should be 1 | 2
            x = i == 1 -- x should be true | false
            local a = x -- x should be true | false 
            -- because from the users point of view x is both x = 1 == 1 and x = 2 == 1 at the same time
        end
        -- x should be false, because i == 2 is the last statement
        local b = x
    ]])
	assert(code:find("i--[[#:1 | 2]] = 1", nil, true) ~= nil)
	-- if the union sorting algorithm changes, we probably need to change this
	assert(code:find("local a--[[#:false | true]] = x", nil, true) ~= nil)
	assert(code:find("local b--[[#:false]] = x", nil, true) ~= nil)
end

analyze[[
    local lol = 0

    for i = 1, 5 do
        if i == 3 then
            break
        end
        
        lol = lol + 1

        if i == 3 then
            attest.equal("should never reach")
        end
    end

    attest.equal(lol, 2)
]]
analyze[[
    for i = 1, 3 do
        -- i is number if max is math.huge for example
    
        local x = ("lol"):byte(1,1 as 1 | 0) -- we do 1 | 0 because 0 will make :byte return nil and 108 (l)
        -- becomes number | nil
        --print(x, i)
        if not x then
            error("lol")
        end
        local y = x
        -- when ran as merged scope error("lol") doesn't return properly
    
        attest.equal(x, 108)
    end
]]
analyze[[
    local string_byte = string.byte
    local x = 0
    local check = false
    for i = 1, 10 do
        x = x + i
        attest.equal(string_byte, string.byte)
        
        if check then
            attest.equal(i, _ as 1 | 10 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9)
        end
        
        if i == 10 then
            check = true
        end
    end
    attest.equal(x,55)
]]
analyze[[
    local tbl = {}
    for i = 1, 10000 do
        tbl[i] = i*100
    end
    tbl[50] = true
    attest.equal(tbl[20], _ as (100..1000000) | true)
]]
analyze[[
    local tbl = {}
    for i = 1, 2 | 3 do
        tbl[i] = i
    end
    attest.equal(tbl[3], 3)
]]
analyze[[
    local lol = 0

    for i = 1, 10 do
        if math.random() > 0.5 then
            break
        end
        lol = lol + 1
        
        local function check<||>
            if i == 1 then
                attest.equal(lol, 1)
            elseif i == number then
                attest.equal(lol, number)
            end
        end

        check<||>
    end
    
    attest.equal(lol, _ as number)

]]
analyze[[
    for i = 1, 5 do
        local a = _ as nil | 1
        if not a then break end
        attest.equal(a, 1)
    end
]]
analyze[[
    for i = 1, 10 do
        local lol = 0
        if math.random() > 0.5 then
            break
        end
        lol = lol + 1
        attest.equal(lol, 1)    
    end
]]
