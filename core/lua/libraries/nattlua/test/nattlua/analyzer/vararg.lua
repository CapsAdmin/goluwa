local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
        local function test(...)

        end

        test({})
    ]]
analyze[[
        local function test(...)
            local a,b,c = ...
            return a+b+c
        end
        attest.equal(test(test(1,2,3), test(1,2,3), test(1,2,3)), 18)
    ]]
analyze[[
        local function test()
            return 1,2
        end

        local a,b,c = test(), 3
        assert_type(a, 1)
        assert_type(b, 3)
        assert_type(c, nil)
    ]]
analyze[[
        local function test(...)
            return 1,2,...
        end

        local a,b,c = test(3)

        attest.equal(a,1)
        attest.equal(b,2)
        attest.equal(c,3)
    ]]
analyze[[
        -- vararg in table
        local function test(...)
            local a = {...}
            attest.equal(a[1], 1)
            attest.equal(a[2], 2)
            attest.equal(a[3], 3)
        end

        test(1,2,3)
    ]]
analyze[[
        -- var arg in table and return
        local a,b,c = test(1,2,3)

        local function test(...)
            local a = {...}
            return a[1], a[2], a[3]
        end

        local a,b,c = test(10,20,30)
        attest.equal(a, 10)
        attest.equal(b, 20)
        attest.equal(c, 30)
    ]]
analyze[[
        local function test(...)
            return 1,2,3, ...
        end

        local A, B, C, D = test(), 4

        attest.equal(A, 1)
        attest.equal(B, 4)
        attest.equal(C, nil)
        attest.equal(D, nil)
    ]]
analyze[[
    local a,b,c = ...
    attest.equal(a, _ as any)
    attest.equal(b, _ as any)
    attest.equal(c, _ as any)
]]
analyze[[
    local tbl = {...}
    attest.equal(tbl[1], _ as any)
    attest.equal(tbl[2], _ as any)
    attest.equal(tbl[100], _ as any)
]]
analyze[[
    local function foo(...)
        local tbl = {...}
        attest.equal(tbl[1], _ as any)
        attest.equal(tbl[2], _ as any)
        attest.equal(tbl[100], _ as any)
    end
]]
analyze[[
    ;(function(...)   
        local tbl = {...}
        attest.equal(tbl[1], 1)
        attest.equal(tbl[2], 2)
        attest.equal(tbl[100], _ as nil) -- or nil?
    end)(1,2)
]]
analyze[[
    local a,b,c = unknown()
    attest.equal(a, _ as any)
    attest.equal(b, _ as any)
    attest.equal(c, _ as any)
]]
analyze[[
        --parenthesis around varargs should only return the first value in the tuple
        local function s(...) return ... end
        local a,b,c = (s(1, 2, 3))
        attest.equal(a, 1)
        attest.equal(b, nil)
        attest.equal(c, nil)
    ]]
analyze[[
        --analyzer function varargs
        local lol = function(...)
            local a,b,c = ...
            attest.equal(a, 1)
            attest.equal(b, 2)
            attest.equal(c, 3)
        end

        local function lol2(...)
            lol(...)
        end

        lol2(1,2,3)
    ]]
analyze[[
    local type lol = function=()>(...any)

    local a,b,c = lol()

    attest.equal(a, _ as any)
    attest.equal(b, _ as any)
    attest.equal(c, _ as any)    

    local type test = analyzer function(a,b,c) 
        assert(a.Type == "any")
        assert(b.Type == "any")
        assert(c.Type == "any")
    end

    test(lol())
]]
analyze[[
    local function resume(a, ...)
        local a, b, c = a, ...
        attest.equal(a, _ as 1)
        attest.equal(b, _ as 2)
        attest.equal(c, _ as 3)
    end
    
    resume(1, 2, 3)
]]
analyze[[
    local type lol = function=()>(1,...any)

    local a,b,c,d = lol()
    attest.equal(a, 1)
    attest.equal(b, _ as any)
    attest.equal(c, _ as any)
    attest.equal(d, _ as any)
    
    
    local a,b,c,d = lol(), 2,3,4
    
    attest.equal(a,1)
    attest.equal(b,2)
    attest.equal(c,3)
    attest.equal(d,4)
    
    
    local function foo(a, ...)
        local a, b, c = a, ...
        attest.equal(a, 1)
        attest.equal(b, 2)
        attest.equal(c, 3)
    end
    
    foo(1, 2, 3)
    
    local type test = analyzer function(a,b,c,...) 
        assert(a:GetData() == 1)
        assert(b.Type == "any")
        assert(c.Type == "any")
    end
    
    test(lol())
    
    local type test = analyzer function(a,b,c,...)
        assert(a:GetData() == 1)
        assert(b:GetData() == 2)
        assert(c:GetData() == 3)
        assert(... == nil)
    end
    
    test(lol(),2,3)
]]
analyze[[
    local a = {}

    local i = 0
    local function test(n)
        i = i + 1

        if i ~= n then
            type_error("wrong")
        end

        return n
    end

    -- test should be executed in the numeric order

    a[test(1)], a[test(2)], a[test(3)] = test(4), test(5), test(6)
]]
analyze[[
    local t = {foo = true}
    for k,v in pairs(t) do
        attest.equal(k, _ as "foo")
        attest.equal(v, _ as true)
    end
]]
analyze[[
    local analyzer function create(func: Function)
        local t = types.Table()
        t.func = func
        return t
    end
    
    local analyzer function call(obj: any, ...: ...any)
        analyzer:Call(obj.func, types.Tuple({...}))
    end
    
    local co = create(function(a,b,c)
        attest.equal(a, 1)
        attest.equal(b, 2)
        attest.equal(c, 3)
    end)
    
    call(co,1,2,3)
]]
analyze[[
    
    local function foo(...)

        -- make sure var args don't leak onto return type var args

        local type lol = function=()>(...any)
        local a,b,c = lol()
        attest.equal(a, _ as any)
        attest.equal(b, _ as any)
        attest.equal(c, _ as any)
    end
    
    foo(1,2,3)
]]
analyze[[
    ;(function(...) 
        local a,b,c,d = ...
        attest.equal(a, _ as 1)
        attest.equal(b, _ as 2)
        attest.equal(c, _ as 3)
        attest.equal(d, nil)
    end)(1,2,3)
]]
analyze(
	[[
    ;(function(...: ...number) 
        print("!", ...)
    end)(1,2,"foo",4,5)
]],
	"foo.-is not the same type as number"
)
analyze[[
    local function foo()
        return foo()
    end

    foo()

    -- should not be a nested tuple
    attest.superset_of(foo, nil as function=()>(any))
]]
analyze[[
    local analyzer function foo(a: any)
        assert(a == nil)
    end

    foo()
]]
analyze[[
    local analyzer function foo(a: any)
        assert(a.Type == "symbol")
        assert(a:GetData() == nil)
    end

    foo(nil)
]]

do
	_G.LOL = nil
	analyze[[
        local analyzer function test()
            return function() _G.LOL = true end
        end
        
        -- make sure the tuple is unpacked, otherwise we get "cannot call tuple"
        test()()
    ]]
	assert(_G.LOL == true)
	_G.LOL = nil
end

analyze[[
    local analyzer function foo() 
        return 1
    end
    
    local a = {
        foo = foo()
    }
    
    §assert(env.runtime.a:Get(types.LString("foo")).Type ~= "tuple")
]]
analyze[[
    local a,b,c = 1,2,3
    local function test(...)
        return a,b,c, ...
    end
    local z,x,y,æ,ø,å = test(4,5,6)

    attest.equal(z, 1)
    attest.equal(x, 2)
    attest.equal(y, 3)
    attest.equal(æ, 4)
    attest.equal(ø, 5)
    attest.equal(å, 6)

]]
analyze[[
    local function bar(a: string, b: number)
    
    end
    
    local function foo(a: string, ...: ...any)
        bar(a, ...)
    end
    
    foo("hello", {1,2,3})
    foo("hello", "foo")
    foo("hello", 1)
    foo("hello", function() end)
]]
analyze[[
    local function foo(a: number, ...: (number,)*inf)
        local x,y,z = ...
        attest.equal(a, _ as number)
        attest.equal(x, _ as number)
        attest.equal(y, _ as number)
        attest.equal(z, _ as number)
    end
]]
analyze[[
    local function foo(a: number, ...: (number,string)*inf)
        local b,x,y,z = ...
        attest.equal(a, _ as number)
        attest.equal(b, _ as number)
        attest.equal(x, _ as string)
        attest.equal(y, _ as number)
        attest.equal(z, _ as string)
    end
]]
analyze[[
    local type F = function=(foo: number, ...: ...string)>(nil)
    attest.equal<|argument_type<|F, 2|>[1], ((string,)*inf,)|>
]]
analyze[[
    local type F = function=(foo: number, ...: (string,)*inf)>(nil)
    attest.equal<|argument_type<|F, 2|>[1], ((string,)*inf,)|>
]]
analyze[[
    local function foo(a: string, b: function=(number, ...: ...string)>(nil))

    end
    
    attest.equal<|argument_type<|argument_type<|foo, 2|>[1], 2|>[1], ((number,)*inf,)|>
]]
analyze[[
    local function foo(a: string, b: function=(number, ...: (string,)*inf)>(nil))

    end
    attest.equal<|argument_type<|argument_type<|foo, 2|>[1], 2|>[1], ((number,)*inf,)|>
]]
analyze[[
    local type F = function=(foo: number, ...: (string,)*inf)>(nil)

    local function foo(a: string, b: ref F)
        b(1, "foo", "bar")
    end
    
    foo("hello", function(a,b,c,d) 
        attest.equal(a, 1)
        attest.equal(b, "foo")
        attest.equal(c, "bar")
        attest.equal(d, nil)
    end)
]]
analyze[[
    local type F = function=(foo: number, ...: (string,)*inf)>(nil)

    local function foo(a: string, b: ref F)
    end
    
    foo("hello", function(a,b,c,d) 
        attest.equal(a, _ as number)
        attest.equal(b, _ as string)
        attest.equal(c, _ as string)
        attest.equal(d, _ as string)
    end)
]]
analyze[[
    local type F = function=(foo: number, ...: (any,)*inf)>(nil)

    local function foo(a: string, func: ref F, ...: ref ...any)
        local a,b,c,d,e = ...
        attest.equal(a, 1)
        attest.equal(b, 2)
        attest.equal(c, 3)
        attest.equal(d, 4)
        attest.equal(e, nil)

        func(...)
    end

    foo("hello", function(a,b,c,d,e) 
        attest.equal(a, 1)
        attest.equal(b, 2)
        attest.equal(c, 3)
        attest.equal(d, 4)
        attest.equal(e, nil)
    end,1,2,3,4)
]]
