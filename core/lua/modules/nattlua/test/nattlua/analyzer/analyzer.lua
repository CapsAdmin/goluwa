local T = require("test.helpers")
local analyze = T.RunCode
local String = T.String
-- check that type assert works
analyze("attest.equal(1, 2)", "expected.-2 got 1")
analyze("attest.equal(nil as 1|2, 1)", "expected.-1")
analyze("attest.equal<|string, number|>", "expected number got string")
analyze("attest.equal(not true, false)")
analyze("attest.equal(not 1, false)")
analyze("attest.equal(nil == nil, true)")

test("declaring base types", function()
	analyze[[
        local type Symbol = analyzer function(T: string)
            return types.Symbol((loadstring or load)("return " .. T:GetData())(), true)
        end
        
        -- primitive types
        local type Nil = Symbol("nil")
        local type True = Symbol("true")
        local type False = Symbol("false")
        local type Boolean = True | False
        local type Number = -inf .. inf | nan
        local type String = $".-"
        
        -- the any type is all types, but we need to add function and table later
        local type Any = Number | Boolean | String | Nil
        local type Function = function=(...Any)>(...Any)
        local type Table = {[Any] = Any}
        
        local analyzer function AddToUnion(union: any, what: any)
            -- this modifies the existing type rather than creating a new one
            union:AddType(what)
        end
        AddToUnion<|Any, Table|>
        AddToUnion<|Any, Function|>
        
        -- if the union sorting algorithm changes, we probably need to change this
        local analyzer function check()
            local a = tostring(env.typesystem.Any)
            local b = "$\".-\" | -inf..inf | false | function=((current_union,)*inf,)>((current_union,)*inf,) | nan | nil | true | { [current_union] = current_union }"
            if a ~= b then
                print(a)
                print(b)
                error("signatures dont' match!")
            end
        end
        check<||>
        

        local str: String = "asdasdawd"
        local b: Boolean = true
        local b: Boolean = false

        local tbl: Table = {
            foo1 = true,
            bar = false,
            asdf = "asdf",
            [{foo2 = "bar"}] = "aaaaa",
            [{foo3 = "bar"}] = {[{1}] = {}},
        }

        local type Foo = Symbol("asdf")
        attest.equal<|Foo == "asdf", false|>
    ]]
end)

test("escape comments", function()
	analyze[=[
        local a = --[[# 1  ^ ]] --[[# -1]] * 3 --[[# * 1]]
        local b = 1 ^ -1 * 3 + 1 * 1
        
        type_expect(a, b)
    ]=]
	analyze([=[
        local function foo(
            a --[[#: string]], 
            b --[[#: number]], 
            c --[[#: string]]) 
        end
         
        attest.equal<|argument_type<|foo, 1|>[1], string|>
        attest.equal<|argument_type<|foo, 2|>[1], number|>
        attest.equal<|argument_type<|foo, 3|>[1], string|>
    ]=])
	analyze[=[
        --[[# local type a = 1 ]]
        attest.equal(a, 1)
    ]=]
end)

test("runtime scopes", function()
	local v = analyze("local a = 1"):GetLocalOrGlobalValue(String("a"))
	equal(true, v.Type == "number")
end)

test("default declaration is literal", function()
	analyze([[
        local a = 1
        local t = {k = 1}
        local b = t.k

        attest.literal<|a|>
        attest.literal<|b|>
    ]])
end)

test("runtime block scopes", function()
	local analyzer, syntax_tree = analyze("do local a = 1 end")
	equal(false, (syntax_tree.environments.runtime:Get(String("a"))))
	equal(
		1,
		analyzer:GetScope():GetChildren()[1]:GetUpvalues("runtime")[1]:GetValue():GetData()
	)
	local v = analyze[[
        local a = 1
        do
            local a = 2
        end
    ]]:GetLocalOrGlobalValue(String("a"))
	equal(v:GetData(), 1)
end)

test("typesystem differs from runtime", function()
	local analyzer = analyze[[
        local a = 1
        local type a = 2
    ]]
	analyzer:PushAnalyzerEnvironment("runtime")
	equal(analyzer:GetLocalOrGlobalValue(String("a")):GetData(), 1)
	analyzer:PopAnalyzerEnvironment()
	analyzer:PushAnalyzerEnvironment("typesystem")
	equal(analyzer:GetLocalOrGlobalValue(String("a")):GetData(), 2)
	analyzer:PopAnalyzerEnvironment()
end)

test("global types", function()
	local analyzer = analyze[[
        do
            type a = 2
        end
        local b: a
        type a = nil
    ]]
	equal(2, analyzer:GetLocalOrGlobalValue(String("b")):GetData())
end)

test("constant types", function()
	local analyzer = analyze[[
        local a: 1
        local b: number
    ]]
	equal(true, analyzer:GetLocalOrGlobalValue(String("a")):IsLiteral())
	equal(false, analyzer:GetLocalOrGlobalValue(String("b")):IsLiteral())
end)

-- literal + vague = vague
test("1 + number = number", function()
	local analyzer = analyze[[
        local a: 1
        local b: number
        local c = a + b
    ]]
	local v = analyzer:GetLocalOrGlobalValue(String("c"))
	equal(true, v.Type == ("number"))
	equal(false, v:IsLiteral())
end)

test("1 + 2 = 3", function()
	local analyzer = analyze[[
        local a = 1
        local b = 2
        local c = a + b
    ]]
	local v = analyzer:GetLocalOrGlobalValue(String("c"))
	equal(true, v.Type == ("number"))
	equal(3, v:GetData())
end)

test("function return value", function()
	local analyzer = analyze[[
        local function test()
            return 1+2+3
        end
        local a = test()
    ]]
	local v = analyzer:GetLocalOrGlobalValue(String("a"))
	equal(6, v:GetData())
end)

do -- multiple function return values
	local analyzer = analyze[[
        local function test()
            return 1,2,3
        end
        local a,b,c = test()
    ]]
	equal(1, analyzer:GetLocalOrGlobalValue(String("a")):GetData())
	equal(2, analyzer:GetLocalOrGlobalValue(String("b")):GetData())
	equal(3, analyzer:GetLocalOrGlobalValue(String("c")):GetData())
end

do -- scopes shouldn't leak
	local analyzer = analyze[[
        local a = {}
        function a:test(a, b)
            return nil, a+b
        end
        local _, a = a:test(1, 2)
    ]]
	equal(3, analyzer:GetLocalOrGlobalValue(String("a")):GetData())
end

analyze[[
        -- explicitly annotated variables need to be set properly
        local a: number | string = 1
    ]]

do -- functions can modify parent scope
	local analyzer = analyze[[
        local a = 1
        local c = a
        local function test()
            a = 2
        end
        test()
    ]]
	equal(2, analyzer:GetLocalOrGlobalValue(String("a")):GetData())
	equal(1, analyzer:GetLocalOrGlobalValue(String("c")):GetData())
end

do -- uncalled functions should be called
	local analyzer = analyze[[
        local lib = {}

        function lib.foo1(a, b)
            return lib.foo2(a, b)
        end

        function lib.main()
            return lib.foo1(1, 2)
        end

        function lib.foo2(a, b)
            return a + b
        end
    ]]
	local lib = analyzer:GetLocalOrGlobalValue(String("lib"))
	equal(
		"number",
		assert(lib:Get(String("foo1")):GetInputSignature():Get(1):GetType("number")).Type
	)
	equal(
		"number",
		assert(lib:Get(String("foo1")):GetInputSignature():Get(2):GetType("number")).Type
	)
	equal("number", assert(lib:Get(String("foo1")):GetOutputSignature():Get(1)).Type)
	equal(
		"number",
		lib:Get(String("foo2")):GetInputSignature():Get(1):GetType("number").Type
	)
	equal(
		"number",
		lib:Get(String("foo2")):GetInputSignature():Get(2):GetType("number").Type
	)
	equal(
		"number",
		lib:Get(String("foo2")):GetOutputSignature():Get(1):GetType("number").Type
	)
end

analyze[[
    -- when setting a to nil in the typesystem we want to delete it
    type a = nil
    local a = 1
    attest.equal<|a, 1|>
]]
analyze[[
    local num = 0b01 -- binary numbers
    attest.equal(num, 1)
]]
analyze([[
    local a: UNKNOWN_GLOBAL = true
]], "has no field.-UNKNOWN_GLOBAL")
analyze([[
    unknown_type_function<|1,2,3|>
]], "has no field.-unknown_type_function")
analyze(
	[[
    local type should_error = function()
        error("the error")
    end

    should_error()
]],
	"the error"
)
analyze[[
    local function list()
        local tbl
        local i

        local self = {
            clear = function(self)
                tbl = {}
                i = 1
            end,
            add = function(self, val)
                tbl[i] = val
                i = i + 1
            end,
            get = function(self)
                return tbl
            end
        }

        self:clear()

        return self
    end


    local a = list()
    a:add(1)
    a:add(2)
    a:add(3)
    attest.equal(a:get(), {1,2,3})
]]
analyze[[
    local FOO = enum<|{
        A = 1,
        B = 2,
        C = 3,
    }|>
    
    local x: FOO = 2

    attest.equal(x, _ as 2)
    attest.equal<|x, 1 | 2 | 3|>

    -- make a way to undefine enums
    type A = nil
    type B = nil
    type C = nil
]]
analyze[[
    local type Foo = {
        x = number,
        y = self,
    }

    local x = {} as Foo

    attest.equal(x.y.y.y.x, _ as number)
]]
analyze[[
    local type Foo = {
        x = number,
        y = self,
    }

    local x = {} as Foo

    attest.equal(x.y.y.y.x, _ as number)
]]
analyze[[
    local type Foo = {
        x = number,
        y = Foo,
    }

    local x = {} as Foo

    attest.equal(x.y.y.y.x, _ as number)
]]

test("forward declare types", function()
	analyze[[
        local type Ping = {}
        local type Pong = {}

        type Ping.pong = Pong
        type Pong.ping = Ping

        local x: Pong

        attest.equal(x.ping.pong.ping, Ping)
        attest.equal(x.ping.pong.ping.pong, Pong)
    ]]
end)

analyze([[type_error("hey over here")]], "hey over here")
analyze(
	[[
local a    
local b    
§error("LOL")
local c    

]],
	[[3 | §error%("LOL"%)]]
)
analyze(
	[[
    local foo = function() return "hello" end

    local function test(cb: function=()>(number))

    end

    test(foo)
]],
	"hello.-is not the same type as.-number"
)
analyze[[
    return function()

        local function foo(x)
            return x+3
        end
    
        local function bar(x)
            return foo(3)+x
        end
    
        local function faz(x)
            return bar(2)+x
        end
    
        type_expect(faz(1), 12)
    end
]]
analyze[[
    local type Boolean = true | false
    local type Number = -inf .. inf | nan
    local type String = $".*"
    local type Any = Number | Boolean | String | nil
    local type Table = {[exclude<|Any, nil|> | self] = Any | self}
    local type Function = function=(...Any)>(...Any)

    do
        -- At this point, Any does not include the Function and Table type.
        -- We work around this by mutating the type after its declaration

        local analyzer function extend_any(obj: any, func: any, tbl: any)
            obj:AddType(tbl)
            obj:AddType(func)
        end

        --extend_any<|Any, Function, Table|>
    end

    local a: Any
    local b: Boolean
    local a: String = "adawkd"

    local t: {
        [String] = Function,
    }

    local x,y,z = t.foo(a, b)
    
    attest.equal(x, _ as Any)
    attest.equal(y, _ as Any)
    attest.equal(z, _ as Any)
]]
analyze[[
    -- we should be able to initialize with no value if the value can be nil
    local x: { y = number | nil } = {}
]]
analyze([[
    local x: { y = number } = {}
]], "is not a subset of")
analyze[[
    local Foo = {Bar = {}}

    function Foo.Bar:init() end
]]
analyze[[
    function test2(callback: function=(...any)>(...any)) 

    end

    test2(function(lol: boolean) 
    
    end)
]]
analyze[[
    local math = {}
    -- since math is defined explicitly as a local here
    -- it should not get its type from the base environment
    math = {}
]]
analyze[[
    local analyzer function nothing()
        return -- return nothing, not even nil
    end

    -- when using in a comparison, the empty tuple should become a nil value instead
    local a = nothing() == nil
    
    attest.equal(a, true)
]]
analyze[[
    a = {b = {c = {d = {lol = true}}}}
    function a.b.c.d:e()
        attest.equal(self.lol, true)
    end
    a.b.c.d:e()
    a = nil
]]
analyze[[
    local a = {b = {c = {d = {lol = true}}}}
    function a.b.c.d:e()
        return self.lol
    end
    attest.equal(a.b.c.d:e(), true)
]]
analyze[[
    type lib = {}
    type lib.myfunc = function=(number, string)>(boolean)

    local lib = {} as lib

    function lib.myfunc(a, b)
        return true
    end

    attest.equal(lib.myfunc, _ as function=(number, string)>(boolean))
]]
analyze[[
    local val: nan
    attest.equal(val, 0/0)
]]
analyze[[
    local val: nil
    attest.equal(val, nil)
]]
analyze[[
    local {Foo} = {}
    attest.equal(Foo, nil)
]]
analyze([[
    local type {Foo} = {}
]], "Foo does not exist")
analyze[[
    local function test(num: number)
        attest.equal<|num, number|>
        return num
    end
    
    local a = test(1)
    attest.equal<|typeof a, number|>
    
    
    local function test(num)
        attest.equal<|num, 1|>
        return num
    end
    
    local a = test(1)
    attest.equal<|typeof a, 1|> -- TODO: we have to use typeof here because earlier we do type a = nil
]]
analyze[[
    local type Shape = {
        Foo = number,
    }
    
    local function mutate(a: ref Shape)
        a.Foo = 5
    end
    
    local tbl = {Foo = 1}
    mutate(tbl)
    attest.equal<|tbl.Foo, 5|>
    
    local function mutate(a)
        a.Foo = 5
    end
    
    local tbl: Shape = {Foo = 1}
    mutate(tbl)
    attest.superset_of<|tbl.Foo, number|>
]]
analyze[[
    local T: (boolean,) | (1|2,)
    attest.equal<|T, (boolean,) | (1|2,)|>
]]
analyze[[
    local x = {foo = 1, bar = 2}
    x.__index = x
    x.func = _ as function=(lol: x | nil)>(x)
    x.bar = _ as function=(lol: x)>({lol = x})

    §assert(env.runtime.x:Equal(env.runtime.x:Copy()))
]]
analyze[[
    -- this has to do with the analyzer 
    -- not calling analyzer:ClearError() when analyzing unreachable code

    local function build(name: string)
        return function()
            while math.random() > 0.5 do end
            attest.equal(name, _ as string)
        end
    end
    
    local foo = build("double")
    
    local function Read()    
        foo()
    end
]]
analyze[[
    local type test = function=(a: number, b: string)>(1)

    function test(a, b)
        return 1
    end
    
    test(1, "")
    
    test = nil
    
    local type test = function=(boolean, boolean)>(number)
    
    local a = test(true, true)
]]
analyze(
	[[
    local analyzer function test(foo: number): number
        return "foo"
    end
    
    local x = test(1)
]],
	[["foo" is not the same type as number]]
)
analyze(
	[[
    local analyzer function test(foo: number): number
        return 1, 2
    end
    
    local x = test(1)
]],
	[[index 2 does not exist]]
)
analyze[[
    local analyzer function test(foo: number)
        return 1, 2
    end
    
    local x = test(1)
]]
analyze[[
    local analyzer function test(foo: literal number): number
        return 1
    end
    
    attest.equal(test(_ as number), _ as number)
]]
analyze[[
    local analyzer function test(foo: literal number)
        return 1, 2
    end
    
    local x = test(1)
]]
analyze(
	[[
    local function foo(s: literal string)
        return s
    end
    
    foo(_ as string)    
]],
	"string is not a subset of literal string"
)
analyze[[
    local analyzer function test(foo: literal number | literal string)
        return 1
    end
    
    local x = test(1)
    local x = test("")
]]
analyze(
	[[
    local analyzer function test(foo: literal number | literal string)
        return 1
    end
    
    local x = test(_ as number)
]],
	"number is not a subset of literal number | literal string"
)
analyze(
	[[
    local analyzer function test(foo: literal number | literal string)
        return 1
    end
    
    local x = test(_ as string)
]],
	"string is not a subset of literal number | literal string"
)
analyze(
	[[
    local analyzer function test(foo: literal number | literal string)
        return 1
    end
    
    local x = test(_ as string | number)
]],
	"number | string is not a subset of literal number | literal string"
)
analyze(
	[[
    local analyzer function test(foo: literal number | literal string)
        return 1
    end
    
    local x = test(_ as string | number)
]],
	"number | string is not a subset of literal number | literal string"
)
analyze[[
    local function test(foo: literal function=(literal number)>(literal number))
    end
    
    local x = test(_ as function=(1)>(1))
]]
analyze[[
    local function test(foo: literal function=(literal number)>(literal number))
    end
    
    local x = test(_ as function=(literal number)>(literal number))
]]
analyze[[
    local function test(foo: literal function=(literal string)>(literal string))
    end
    
    local x = test(_ as function=(literal string)>(literal string))
]]
analyze(
	[[
    local analyzer function test(foo: literal function=(literal number)>(literal number))
        print(foo)
    end
    
    local x = test(_ as function=(number)>(1))
]],
	"function=%(number,%)>%(1,%) is not a subset of function=%(literal number,%)>%(literal number,%)"
)
analyze(
	[[
    local analyzer function test():(literal number)
        return types.Number()
    end
    
    local x = test()
]],
	"number is not a subset of literal number"
)
analyze[[
    local analyzer function test():(literal number)
        return 1
    end
    
    local x = test()
]]
analyze[[
    local analyzer function test(x: literal number): number
        return x:GetData() + 1
    end
    
    local x = test(_ as number)
    attest.equal(x, _ as number)
]]
