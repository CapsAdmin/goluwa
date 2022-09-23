local T = require("test.helpers")
local analyze = T.RunCode
local String = T.String

do -- number range
	assert(
		analyze("local a: 1 .. 10 = 5"):GetLocalOrGlobalValue(String("a")):GetContract():GetMax()
	)
	analyze("local a: 1 .. 10 = 15", "15 is not a subset of 1..10")
end

do -- number range 0 .. inf
	assert(
		analyze("local a: 1 .. inf = 5"):GetLocalOrGlobalValue(String("a")):GetContract():GetMax()
	)
	analyze("local a: 1 .. inf = -15", "-15 is not a subset of 1..inf")
end

do -- number range -inf .. 0
	assert(
		analyze("local a: -inf .. 0 = -5"):GetLocalOrGlobalValue(String("a")):GetContract():GetMax()
	)
	analyze("local a: -inf .. 0 = 15", "15 is not a subset of %-inf..0")
end

do -- number range -inf .. inf
	assert(
		analyze("local a: -inf .. inf = -5"):GetLocalOrGlobalValue(String("a")):GetContract():GetMax()
	)
	analyze("local a: -inf .. inf = 0/0", "nan is not a subset of %-inf..inf")
end

do -- number range -inf .. inf | nan
	assert(analyze("local a: -inf .. inf | nan = 0/0"):GetLocalOrGlobalValue(String("a")):GetContract().Type == "union")
end

do -- cannot not be called
	analyze([[local a = 1 a()]], "1 cannot be called")
end

do -- cannot be indexed
	analyze([[local a = 1; a = a.lol]], "undefined get:")
end

do -- cannot be added to another type
	analyze([[local a = 1 + true]], "1 %+ .-true is not a valid binary operation")
end

analyze([[
        local a = 1 + (_ as number)

        attest.equal(a, _ as number)
    ]])
analyze([[
        local function isNaN (x)
            return (x ~= x)
        end

        assert(isNaN(0/0))
        assert(not isNaN(1/0))
    ]])
analyze[[
        local foo = ((500 // 2) + 3) // 2 // 3 // 3
        local bar = 5
        attest.equal(foo, 14)
        attest.equal(bar, 5)
    ]]
analyze[[
    local n = _ as 0 .. 1

    attest.equal(n > 1, false)
    attest.equal(n > 0.5, _ as boolean)
    attest.equal(n >= 1, _ as boolean)
    attest.equal(n <= 0, _ as boolean)
    attest.equal(n < 0, false)
    
    local n2 = _ as 0.5 .. 1.5
    
    attest.equal(n2 + n, _ as 0.5 .. 2.5)
]]
analyze[=[


    --[[

        1..10 < 3..5
            positive result:
                get all numbers in 1..10 that are less than 3
                and you end up with 1 | 2
        
                get all numbers in 1..10 that are less than 5
                and you end up with 1 | 2 | 3 | 4
        
                (1 | 2) | (1 | 2 | 3 | 4) = 1 | 2 | 3 | 4 
                or 
                1..4
                
            negative result:
                get all numbers in 1..10 that are NOT less than 3
                and you end up with 4 | 5 | 6 | 7 | 8 | 9 | 10
        
                get all numbers in 1..10 that are NOT less than 5
                and you end up with 6 | 7 | 8 | 9 | 10
        
                (4 | 5 | 6 | 7 | 8 | 9 | 10) | (6 | 7 | 8 | 9 | 10) = 4 | 5 | 6 | 7 | 8 | 9 | 10 
                or 
                4..10
        
        1..10 < -5..7
            positive result:
                get all numbers in 1..10 that are less than -5
                and you end up with nothing, so we default to 1
        
                get all numbers in 1..10 that are less than 7
                and you end up with 1 | 2 | 3 | 4 | 5 | 6 | 7
        
                (1) | (1 | 2 | 3 | 4 | 5 | 6 | 7) = 1 | 2 | 3 | 4 | 5 | 6 | 7
                or
                1..7
        
            negative result:
                get all numbers in 1..10 that are NOT less than -5
                and you end up with 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10
        
                get all numbers in 1..10 that are NOT less than 7
                and you end up with 8 | 9 | 10
        
                (1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10) | (8 | 9 | 10) = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10
                or
                1..10
                
        1..10 > 3..5
            positive result:
                get all numbers in 1..10 that are greater than 3
                and you end up with 4 | 5 | 6 | 7 | 8 | 9 | 10
        
                get all numbers in 1..10 that are greater than 5
                and you end up with 6 | 7 | 8 | 9 | 10
        
                (4 | 5 | 6 | 7 | 8 | 9 | 10) | (6 | 7 | 8 | 9 | 10) = 4 | 5 | 6 | 7 | 8 | 9 | 10 
                or 
                4..10
            
            negative result:
                get all numbers in 1..10 that are NOT greater than 3
                and you end up with 1 | 2
        
                get all numbers in 1..10 that are NOT greater than 5
                and you end up with 1 | 2 | 3 | 4
        
                (1 | 2) | (1 | 2 | 3 | 4) = 1 | 2 | 3 | 4 
                or 
                1..4
        
        1..10 < 5..5
            positive result:
                get all numbers in 1..10 that are less than 5
                and you end up with 1 | 2 | 3 | 4
        
                get all numbers in 1..10 that are less than 5
                and you end up with 1 | 2 | 3 | 4
        
                (1 | 2 | 3 | 4) | (1 | 2 | 3 | 4) = 1 | 2 | 3 | 4 
                or 
                1..4
        
            negative result:
                get all numbers in 1..10 that are NOT less than 5
                and you end up with 6 | 7 | 8 | 9 | 10
        
                get all numbers in 1..10 that are NOT less than 5
                and you end up with 6 | 7 | 8 | 9 | 10
        
                (6 | 7 | 8 | 9 | 10) | (6 | 7 | 8 | 9 | 10) = 6 | 7 | 8 | 9 | 10 
                or 
                6..10
        ]]
        
        local analyzer function check(a: number, op: string, b: number, expect_a: number | nil, expect_b: number | nil)
            local res_a, res_b = a:LogicalComparison2(b, op:GetData())
        
        
            if not expect_a or not expect_b then
                print(a, op, b, "=", res_a, res_b)
                return
            end
        
            if tostring(res_a) ~= tostring(expect_a) then
                error(("Expected %s, got %s"):format(expect_a, res_a))
            end
        
            if tostring(res_b) ~= tostring(expect_b) then
                error(("Expected %s, got %s"):format(expect_b, res_b))
            end 
        end
        
        check<|
            1..5, "<", 1..3, 
            1..2, -- positive
            3..5 -- negative
        |>
        
        check<|
            1..10, "<", 3..5, 
            1..4, -- positive
            5..10 -- negative
        |>
        
        check<|
            1..10, "<", 5, 
            1..4, -- positive
            5..10 -- negative
        |>
        

]=]
analyze[[
    local x: 1..inf = 2
    attest.equal<|x, 1..inf|>
]]
