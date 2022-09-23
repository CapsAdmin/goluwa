local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    local type A = (1,2)
    local type B = (3,4)
    local type C = A .. B
    attest.equal<|C, (1,2,3,4)|>
]]
-- test for most edge cases regarding the tuple unpack mess
analyze[[

local function test() return function(num: ref number) return 1336 + num end end

attest.equal(test()(1), 1337)
local a = test()(1)
attest.equal(a, 1337)

for i = 1, test()(1) - 1336 do
    attest.equal(i, 1)
end

local a,b,c = (function() return 1,2,3 end)()

attest.equal(a, 1)
attest.equal(b, 2)
attest.equal(c, 3)

local x = (function() if math.random() > 0.5 then return 1 end return 2 end)()

attest.equal(x, _ as 1 | 2)

local function lol()
    if math.random() > 0.5 then
        return 1
    end
end

local x = lol()

attest.equal<|x, 1 | nil|>

local function func(): number, number
    if math.random() > 0.5 then
        return 1, 2
    end

    return 3, 2
end


local foo: function=()>((true, 1) | (false, string, 2))
local x,y,z = foo() 
attest.equal(x, _ as boolean)
attest.equal(y, _ as 1 | string)
attest.equal(z, _ as 2 | nil)


local function foo()
    return 2,true, 1
end

foo()

attest.equal<|unpack<|ReturnType<|foo|>|>, (2,true,1)|>

local function test()
    if math.random() > 0.5 then
        return 1, 2
    end
    return 1, (function() return 2 end)()
end

test()

attest.equal<|unpack<|ReturnType<|test|>|>, (1, 2)|>


local a = function()
    if math.random() > 0.5 then
        -- the return value here sneaks into val
        return ""
    end
    
    -- val is "" | 1
    local val = (function() return 1 end)()
    
    attest.equal(val, 1)

    return val
end

attest.equal(a(), _ as 1 | "")

local analyzer function Union(...: ...any)
    return types.Union({...})
end

local function Extract<|a: any, b: any|>
	local out = Union<||>
    for aval in UnionValues(a) do
		for bval in UnionValues(b) do
			if aval < bval then
				out = out | aval
			end
		end
	end

	return out
end

attest.equal<|Extract<|1337 | 231 | "deadbeef", number|>, 1337 | 231|>

local analyzer function foo() 
    return 1
end

local a = {
    foo = foo()
}

§assert(env.runtime.a:Get(types.LString("foo")).Type ~= "tuple")


local function prefix (w1: ref string, w2: ref string)
    return w1 .. ' ' .. w2
end

local w1,w2 = "foo", "bar"
local statetab = {["foo bar"] = 1337}

local test = statetab[prefix(w1, w2)]
attest.equal(test, 1337)


attest.equal({(_ as any)()}, _ as {[1 .. inf] = any})
attest.equal({(_ as any)(), 1}, _ as {any, 1})

local tbl = {...}
attest.equal(tbl[1], _ as any)
attest.equal(tbl[2], _ as any)
attest.equal(tbl[100], _ as any)

;(function(...)   
    local tbl = {...}
    attest.equal(tbl[1], 1)
    attest.equal(tbl[2], 2)
    attest.equal(tbl[100], _ as nil) -- or nil?
end)(1,2)

]]
analyze(
	[[
    local function func(): number, number
        return 1
    end
]],
	"index 2 does not exist"
)
analyze[[
    local type a = (3, 4, 5)
    attest.equal<|a, (3,4,5)|>

    local type a = (5,)
    attest.equal<|a, (5,)|>

    local type a = ()
    attest.equal<|a, ()|>
]]
analyze[[
    local analyzer function test(a: any, b: any)
        local tup = types.Tuple({types.LNumber(1),types.LNumber(2),types.LNumber(3)})
        assert(a:Equal(tup))
        assert(b:Equal(tup))
    end

    local type a = (1,2,3)

    test<|a,a|>
]]
analyze[[
    local function test2<|a: (number, number, number), b: (number, number, number)|>: (number, number, number)
        attest.equal<|a, (1,2,3)|>
        attest.equal<|b, (1,2,3)|>
        return a, b
    end

    local type a = (1,2,3)

    local type a, b = test2<|a,a|>
    attest.equal<|a, (1,2,3)|>
    attest.equal<|b, a|>
]]
analyze[[
    local function aaa(foo: string, bar: number, faz: boolean): (1,2,3)
        return 1,2,3
    end
    attest.equal<|unpack<|argument_type<|aaa|>|>, (string, number, boolean)|>
    attest.equal<|unpack<|return_type<|aaa|>|>, ((1, 2, 3),)|>
]]
analyze[[
    local type test = analyzer function()
        return 11,22,33
    end

    local a,b,c = test()

    attest.equal(a, 11)
    attest.equal(b, 22)
    attest.equal(c, 33)
]]
