local T = require("test.helpers")
local analyze = T.RunCode
analyze[[ -- A
    local A = _ as true | false

    if A then 
        attest.equal(A, true)
    end
]]
analyze[[ -- A or B

    local A = _ as true | false
    local B = _ as true | false

    if A then 
        attest.equal(A, true)
        attest.equal(B, _ as true | false)
    elseif B then 
        attest.equal(B, true)
        attest.equal(A, false)
    end
]]
analyze[[ -- A and B
    local A = _ as true | false
    local B = _ as true | false
    if A then
        if B then
            attest.equal(A, true)
            attest.equal(B, true)
        end
    end
]]
analyze[[ -- A or B or C

    local A = _ as true | false
    local B = _ as true | false
    local C = _ as true | false

    if A then 
        attest.equal(A, true)
        attest.equal(B, _ as true | false)
        attest.equal(C, _ as true | false)
    elseif B then 
        attest.equal(A, false)
        attest.equal(B, true)
        attest.equal(C, _ as true | false)
    elseif C then 
        attest.equal(A, false)
        attest.equal(B, false)
        attest.equal(C, true)
    end
]]
analyze[[ -- A or not B

    local A = _ as true | false
    local B = _ as true | false

    if A then 
        attest.equal(A, true)
        attest.equal(B, _ as true | false)
    elseif not B then 
        attest.equal(A, false)
        attest.equal(B, false)
    end
]]
analyze[[ -- A or not B or C
    local A = _ as true | false
    local B = _ as true | false
    local C = _ as true | false

    if A then 
        attest.equal(A, true)
        attest.equal(B, _ as true | false)
        attest.equal(C, _ as true | false)
    elseif not B then 
        attest.equal(A, false)
        attest.equal(B, false)
        attest.equal(C, _ as true | false)
    elseif C then 
        attest.equal(A, false)
        attest.equal(B, true)
        attest.equal(C, true)
    end
]]
analyze[[ -- A or not B or not C
    local A = _ as true | false
    local B = _ as true | false
    local C = _ as true | false

    if A then 
        attest.equal(A, true)
        attest.equal(B, _ as true | false)
        attest.equal(C, _ as true | false)
    elseif not B then 
        attest.equal(A, false)
        attest.equal(B, false)
        attest.equal(C, _ as true | false)
    elseif not C then 
        attest.equal(A, false)
        attest.equal(B, true)
        attest.equal(C, false)
    end
]]
analyze[[ -- A and not B
    local A = _ as true | false
    local B = _ as true | false
    if A then
        if not B then
            attest.equal(A, true)
            attest.equal(B, false)
        end
    end
]]
analyze[[ -- not A and not B
    local A = _ as true | false
    local B = _ as true | false
    if not A then
        if not B then
            attest.equal(A, false)
            attest.equal(B, false)
        end
    end
]]
analyze[[ -- not A and B
    local A = _ as true | false
    local B = _ as true | false
    if not A then
        if B then
            attest.equal(A, false)
            attest.equal(B, true)
        end
    end
]]
analyze[[ -- (A and B) or (C and D)

    local A = _ as true | false
    local B = _ as true | false
    local C = _ as true | false
    local D = _ as true | false

    if A then
        if B then
            
            return
        end 
    end

    if C then
        if D then

            return
        end
    end
]]--[[
    https://www.youtube.com/watch?v=XMCW6NFLMsg

    z = A or (not A and B)
    z = (A or not A) and (A or B)
    z = true and (A or B)
    z = (A or B)

    z = A and ((A or not A) or not B)
    z = A and (true or not B)
    z = A and true
    z = A

    z = A and B or B and C and (B or C)
    z = (A and B) or ((B and C) and (B or C))
    z = (A and B) or (((B and C) and B) or ((B and C) and C))
    z = (A and B) or (B and C and B) or (B and C and C)
    z = (A and B) or (B and C) or (B and C)
    z = (A and B) or (B and C)
    z = B and (A or C)

    z = A or A and B
    z = A or (A and B)
    z = (A and true) or (A and B)


    A and B or A and (B or C) or B and (B or C)
    (A and B) or (A and (B or C)) or B

]] 
