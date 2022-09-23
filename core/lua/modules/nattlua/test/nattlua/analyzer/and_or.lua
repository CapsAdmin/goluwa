local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
        -- order of 'and' expression
        local res = 0
        local a = function(arg) 
            if res == 0 then
                attest.equal(arg, 1)
            elseif res == 1 then
                attest.equal(arg, 2)
            end
            res = arg
            return true 
        end
        local b = a(1) and a(2)
    ]]

do
	_G.TEST_DISABLE_ERROR_PRINT = true
	analyze[[
        local a: false | {foo = true}
        
        -- if left side is false or something, return a union of the left and right side
        local b = a and a.foo

        attest.equal(b, _ as false | true)
    ]]
	_G.TEST_DISABLE_ERROR_PRINT = false
end

analyze[[        
        local a = function(arg) 
            attest.equal(arg, 1)
            return false
        end
        
        -- if left side of 'and' is false, don't analyze the right side
        local b = a(1) and a(2)
    ]]
analyze[[
        local a = function(arg) 
            attest.equal(arg, 1)
            return 1337
        end
        
        -- if left side of 'or' is true, don't analyze the right side
        local b = a(1) or a(2)
        attest.equal(b, 1337)
    ]]
analyze[[
        local a = function(arg) 
            if arg == 1 then return false end
            return 1337
        end
        
        -- right side of or
        local b = a(1) or a(2)
        attest.equal(b, 1337)
    ]]
analyze[[
        local maybe: false | true
        local b = maybe or 1
        attest.equal(b, _ as true | 1)
    ]]
analyze[[
        local maybe: false | true
        local b = maybe or maybe
        attest.equal(b, _ as true | false)
    ]]
analyze[[
        local maybe: false | true
        local maybe2: nil | 1337
        local b = maybe or maybe2
        attest.equal(b, _ as 1337 | nil | true)
    ]]
analyze[[
        local maybe: false | true
        local maybe2: nil | 1337
        local b = maybe2 or maybe
        attest.equal(b, _ as 1337 | false | true)
    ]]
