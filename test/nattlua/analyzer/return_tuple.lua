local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
        local function test(): ErrorReturn<|{foo = number}|>
            if math.random() > 0.5 then return {foo = 2} end
        
            return nil, "uh oh"
        end
        
        local x, y = test()
        
        attest.equal(x, _ as nil | {foo = number})
        attest.equal(y, _ as nil | string)
    ]]
analyze[[

    local function last_error()
        if math.random() > 0.5 then
            return "strerror returns null"
        end

        if math.random() > 0.5 then
            return _ as string
        end
    end

    local function test(): ErrorReturn<|{foo = number}|>
        if math.random() > 0.5 then
            return {foo = number}
        end
        return nil, last_error()
    end    

]]
analyze[[
    local function test(): (1,"lol1") | (2,"lol2")
        return 2, "lol2"
    end    
]]
analyze[[
    local foo: function=()>(true | false, string | nil)
    local ok, err = foo()
    attest.equal(ok, _ as true | false)
    attest.equal(err, _ as nil | string)
]]
analyze[[
    local foo: function=()>((true, 1) | (false, string, 2))
    local x,y,z = foo() 
    attest.equal(x, _ as true | false)
    attest.equal(y, _ as 1 | string)
    attest.equal(z, _ as 2 | nil)
]]
analyze(
	[[
    local function test(): (1,"lol1") | (2,"lol2")
        return "", "lol2"
    end
]],
	"\"\" is not the same type as 1"
)
analyze[[
    local function foo()
        return _ as true | (nil, string, number)
    end
    local x,y,z = foo()
    attest.equal(x, _ as true | nil)
    attest.equal(y, _ as string | nil)
    attest.equal(z, _ as number | nil)
]]
analyze[[
    local function foo()
        return _ as true | (nil, (string, number))
    end
    local x,y,z = foo()
    attest.equal(x, _ as true | nil)
    attest.equal(y, _ as string | nil)
    attest.equal(z, _ as number | nil)
]]
analyze[[
    local function foo()
        return _ as (true | (nil, string, number))
    end
    local x,y,z = foo()
    attest.equal(x, _ as true | nil)
    attest.equal(y, _ as string | nil)
    attest.equal(z, _ as number | nil)
]]