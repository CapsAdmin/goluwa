local T = require("test.helpers")
local analyze = T.RunCode
local String = T.String

test("arguments", function()
	local analyzer = analyze[[
        local function test(a,b,c)
            return a+b+c
        end
        local a = test(1,2,3)
    ]]
	equal(6, analyzer:GetLocalOrGlobalValue(String("a")):GetData())
end)

test("arguments should get annotated", function()
	local analyzer = analyze[[
        local function test(a,b,c)
            return a+c
        end

        test(1,"",3)
    ]]
	local args = analyzer:GetLocalOrGlobalValue(String("test")):GetInputSignature()
	equal("number", args:Get(1):GetType("number").Type)
	equal("string", args:Get(2):GetType("string").Type)
	equal("number", args:Get(3):GetType("number").Type)
	local rets = analyzer:GetLocalOrGlobalValue(String("test")):GetOutputSignature()
	equal("number", rets:Get(1).Type)
end)

test("arguments and return types are volatile", function()
	local analyzer = analyze[[
        local function test(a)
            return a
        end

        test(1)
        test("")
    ]]
	local func = analyzer:GetLocalOrGlobalValue(String("test"))
	local args = func:GetInputSignature()
	equal(true, args:Get(1):HasType("number"))
	equal(true, args:Get(1):HasType("string"))
	local rets = func:GetOutputSignature()
	equal(true, rets:Get(1):HasType("number"))
	equal(true, rets:Get(1):HasType("string"))
end)

test("which is not explicitly annotated should not dictate return values", function()
	local analyzer = analyze[[
        local function test(a)
            return a
        end

        test(1)

        local a = test(true)
    ]]
	local val = analyzer:GetLocalOrGlobalValue(String("a"))
	equal(true, val.Type == "symbol")
	equal(true, val:GetData())
end)

test("which is explicitly annotated should error when the actual return value is different", function()
	analyze(
		[[
        local function test(a)
            return a
        end

        local a: string = test(1)
    ]],
		"1.-is not the same type as string"
	)
end)

test("which is explicitly annotated should error when the actual return value is unknown", function()
	analyze(
		[[
        local function test(a: number): string
            return a
        end
    ]],
		"number is not the same type as string"
	)
end)

test("call within a function shouldn't mess up collected return types", function()
	local analyzer = analyze[[
        local function b()
            (function() return 888 end)()
            return 1337
        end

        local c = b()
    ]]
	local c = analyzer:GetLocalOrGlobalValue(String("c"))
	equal(1337, c:GetData())
end)

test("arguments with any", function()
	analyze([[
        local function test(b: any, a: any)

        end

        test(123, "a")
    ]])
end)

test("self argument should be volatile", function()
	local analyzer = analyze([[
        local meta = {}
        function meta:Foo(b)

        end
        local a = meta.Foo
    ]])
	local self = analyzer:GetLocalOrGlobalValue(String("a")):GetInputSignature():Get(1):GetType("table")
	equal("table", self.Type)
end)

test("arguments that are explicitly typed should error", function()
	analyze(
		[[
        local function test(a: 1)

        end

        test(2)
    ]],
		"2 is not a subset of 1"
	)
	analyze(
		[[
        local function test(a: number)

        end

        test("a")
    ]],
		"\"a\" is not the same type as number"
	)
	analyze(
		[[
        local function test(a: number, b: 1)

        end

        test(5123, 2)
    ]],
		"2 is not a subset of 1"
	)
	analyze(
		[[
        local function test(b: 123, a: number)

        end

        test(123, "a")
    ]],
		"\"a\" is not the same type as number"
	)
end)

test("arguments that are not explicitly typed should be volatile", function()
	do
		local analyzer = analyze[[
            local function test(a, b)
                return 1337
            end

            test(1,"a")
        ]]
		local args = analyzer:GetLocalOrGlobalValue(String("test")):GetInputSignature()
		local a = args:Get(1)
		local b = args:Get(2)
		equal("number", a:GetType("number").Type)
		equal(1, a:GetType("number"):GetData())
		equal("string", b:GetType("string").Type)
		equal("a", b:GetType("string"):GetData())
	end

	do
		local analyzer = analyze[[
            local function test(a, b)
                return 1337
            end

            test(1,"a")
            test("a",1)
        ]]
		local args = analyzer:GetLocalOrGlobalValue(String("test")):GetInputSignature()
		local a = args:Get(1)
		local b = args:Get(2)
		assert(a:Equal(b))
	end

	do
		local analyzer = analyze[[
            local function test(a, b)
                return 1337
            end

            test(1,"a")
            test("a",1)
            test(4,4)
        ]]
		local args = analyzer:GetLocalOrGlobalValue(String("test")):GetInputSignature()
		local a = args:Get(1)
		local b = args:Get(2)
		assert(a:Equal(b))
	end

	local analyzer = analyze[[
        local function test(a, b)
            return 1337
        end

        test(1,2)
        test("awddwa",{})
    ]]
	local b = analyzer:GetLocalOrGlobalValue(String("b"))
end)

test("https://github.com/teal-language/tl/blob/master/spec/lax/lax_spec.lua", function()
	local analyzer = analyze[[
        function f1()
            return { data = function () return 1, 2, 3 end }
        end

        function f2()
            local one, two, three
            local data = f1().data
            one, two, three = data()
            return one, two, three
        end

        local a,b,c = f2()
    ]]
	local a = analyzer:GetLocalOrGlobalValue(String("a"))
	local b = analyzer:GetLocalOrGlobalValue(String("b"))
	local c = analyzer:GetLocalOrGlobalValue(String("c"))
	equal(1, a:GetData())
	equal(2, b:GetData())
	equal(3, c:GetData())
end)

test("return type", function()
	local analyzer = analyze[[
        function foo(a: number):string return '' end
    ]]
end)

test("calling a union", function()
	analyze[[
        local type test = function=(boolean, boolean)>(number) | function=(boolean)>(string)

        local a = test(true, true)
        local b = test(true)

        attest.equal(a, _ as number)
        attest.equal(b, _ as string)
    ]]
end)

test("calling a union that has no field a function should error", function()
	analyze(
		[[
        local type test = function=(boolean, boolean)>(number) | function=(boolean)>(string) | number

        test(true, true)
    ]],
		"union .- contains uncallable object number"
	)
end)

pending("pcall", function()
	analyze[[
        local ok, err = pcall(function()
            local a, b = 10.5, nil
            return a < b
        end)

        attest.equal(ok, _ as false)
        attest.equal(err, _ as "not a valid binary operation")
    ]]
end)

test("complex", function()
	analyze[[
        local function foo()
            return foo()
        end
        
        foo()

        attest.superset_of(foo, nil as function=()>(any))
    ]]
end)

analyze[[
    do
        type x = boolean | number
    end

    local type c = x
    local a: c
    local type b = {foo = a as any}
    local c: function=(a: number, w:number)>(b, b)

    attest.equal(
        c, 
        nil as function=(number, number)>({foo = any}, {foo = any})
    )

    type x = nil
]]
analyze[[
    local x: function=(a: number)>(a, a)
    attest.equal(x, _ as function=(number)>(number, number))
]]
analyze[[
    local function test(a:number,b: number)
        return a + b
    end

    test(1,1)

    attest.equal(test, nil as function=(_:number, _:number)>(number))
]]

test("make sure analyzer return flags dont leak over to deferred calls", function()
	local foo = analyze([[
        local function bar() end
        bar()
        
        function foo()
            a = 1
            return true
        end
        
        return nil
    ]]):GetLocalOrGlobalValue(String("foo"))
	equal(foo:GetOutputSignature():Get(1):GetData(), true)
end)

analyze[[
    local a = function()
        if maybe then
            -- the return value here sneaks into val
            return ""
        end
        
        -- val is "" | 1
        local val = (function() return 1 end)()
        
        attest.equal(val, 1)

        return val
    end

    attest.equal(a(), _ as 1 | "")
]]
analyze[[
    local x = (" "):rep(#tostring(_ as string))
    attest.equal(x, _ as string)
]]
analyze[[
    local function foo()
        return "foo"
    end
    
    local function bar()
        return "bar"
    end
    
    local function genfunc(name)
        local f = name == "foo" and foo or bar
        return f
    end
    
    local f = genfunc("foo")
    attest.equal(f(), "foo")
]]
analyze[[
    function faz(a)
        return foo(a + 1)
    end
    
    function bar(a)
        return faz(a + 1)
    end
    
    function foo(a)
        return bar(a + 1)
    end
    
    attest.equal(foo(1), _ as any)
]]
analyze[[
    local Foo = {Bar = {foo = {bar={test={}}}}}

    function Foo.Bar.foo.bar.test:init() end

    attest.superset_of(Foo.Bar.foo.bar.test.init, _ as function=(...any)>(...any))
]]
analyze[[
    local aaa = function(...) end
    function foo(...: ...number)
        aaa(...)
    end
]]
analyze[[
    local analyzer function test2(a: any, ...: ...any)
        local b,c,d = ...
        assert(a:GetData() == "1")
        assert(b:GetData() == 2)
        assert(c:GetData() == 3)
        assert(d:GetData() == 4)
    end
    
    local function test(a, ...)
        test2(a, ...)
    end
    
    test("1",2,3,4)
]]
analyze[[
    local function foo(a,b,c,d)
        attest.equal(a, 1)
        attest.equal(b, 2)
        attest.equal(c, _ as any)
        attest.equal(d, _ as any)
    end
    
    something(function(...)
        foo(1,2,...)
    end)
]]
analyze[[
    local func = function(one, two) end
    func(1, 2)
    func(1, "2")
]]
analyze[[
    local type Token = {
        type = string,
        value = string,
    }
    
    local tbl = {
        foo = 1,
        bar = 2,
        faz = 3,
    }
    
    local function foo(arg: Token)
        return tbl[arg.value]
    end
    
    attest.equal(foo({value = "test", type = "lol"}), _ as 1|2|3|nil)
    attest.equal(foo({value = "test", type = "lol"}), _ as 1|2|3|nil)
]]
analyze[[
    local function test()
        if MAYBE then
            return true
        end
    end
    
    local x = test()
    attest.equal(x, _ as nil | true)
]]
analyze[[
    local function test(cb: function=(string)>(string))

    end
    
    test(function(s)
        return ""
    end)

    §assert(#analyzer.diagnostics == 0)
]]
analyze[[
    local function test(): ref number 
        return 1
    end 
    
    local x = test()
    attest.equal(x, 1)
]]
analyze[[
    local function test(): number 
        return 1
    end 
    
    local x = test()
    attest.equal(x, _ as number)
]]
analyze[[
    local A = {kind = "a"}
    function A:Foo()
        return self.kind
    end
    
    local B = {kind = "b"}
    function B:Bar()
        return self.kind
    end
    
    local C = {kind = "c"}
    C.Foo = A.Foo
    C.Bar = B.Bar
    
    attest.equal(C:Foo(), "c")
    attest.equal(C:Bar(), "c")
    
    attest.equal(A:Foo(), "a")
    attest.equal(B:Bar(), "b")
]]
analyze[[
    local function foo(str: boolean | nil)

    end
    
    foo()
]]
analyze[[
    local function foo(x: { foo = nil | number })

    end

    foo({})
]]
analyze[[
    local type MyTable = {foo = number}

    local function foo(tbl: MyTable & {bar = boolean | nil})
        attest.equal<|tbl.foo, number|>
        attest.equal<|tbl.bar, boolean | nil|>
        return tbl
    end

    local tbl = foo({
        foo = 1337
    })

    attest.equal<|tbl.foo, number|>
    attest.equal<|tbl.bar, boolean | nil|>
]]
analyze[[
    local meta = {}
    meta.__index = meta
    type meta.@Self = {foo = number}
    
    local function test(tbl: meta.@Self & {bar = string | nil})
        attest.equal(tbl.bar, _ as nil | string)
        return tbl:Foo() + 1
    end
    
    function meta:Foo()
        attest.equal<|self.foo, number|>
        return 1336
    end
    
    local obj = setmetatable({
        foo = 1
    }, meta)
    
    attest.equal(obj:Foo(), 1336)
    attest.equal(test(obj), 1337)
]]
analyze[[
    local type foo = (function=(
        boolean | nil, 
        boolean | nil, 
        string, 
        number | nil
    )>(nil))
    
    foo(true, nil, "")
]]
analyze[[
    local tbl = {}

    local function add(
        name: ref string
    )
        tbl[name] = function(name2: ref string)
            attest.equal(name, name2)
        end
    end
    
    add("FooNumber")
    add("BarString")
    
    tbl.FooNumber("FooNumber")
    tbl.BarString("BarString")
]]
analyze[[
    local type mytuple = (string, number, boolean)
    local type lol = function=(mytuple)>(mytuple)

    attest.equal(lol, _ as function=(string, number, boolean)>(string, number, boolean))
]]
analyze[[
    type lol = function =(foo: string, number)>(bar: string, string)

    attest.equal(lol, _ as function =(string, number)>(string, string))
    
    type lol = nil
]]
analyze[[
    local type Type = "foo" | "bar" 
    local type Object = {
        foo = Type,
        --[1337] = 1, TODO, this should error
    }

    local table_pool = function(alloc: ref (function=()>({[string] = any})))
        local pool = {} as {[number] = return_type<|alloc|>[1]}
        return function()
            return pool[1]
        end
    end

    local tk = table_pool(function() return { foo = "foo" } as Object end)()
    tk.foo = "bar"
    attest.equal<|tk.foo, Type|>
]]
analyze(
	[[
    local table_pool = function(alloc: (function=()>({[string] = any})))
        local pool = {} as {[number] = return_type<|alloc|>[1]}
        return function()
            return pool[1]
        end
    end

    table_pool(function() return { [777] = 777 } end)()
]],
	"777 is not the same type as string"
)
analyze[[
    local function foo(x: function=(number, string)>())

    end
    
    foo(function(x, y)
        attest.equal(x, _ as number)
        attest.equal(y, _ as string)
    end)
]]
analyze[[
    local function foo(x: function=(number, string)>())

    end
    
    foo(function(x: number)
        attest.equal(x, _ as number)
    end)
]]
analyze[[
    local foo = function(s: string)
        return "code" as string
    end
    
    (function(arg: {[number] = string})
        local code = foo(arg[1])
        attest.equal(code, _ as string)
    end)(arg)
]]
analyze[[
    local function IREqual(IR1: {number, number})
        return true
    end
    
    local function replaceIRs(haystack: {[number] = {number, number}})
        § assert(#env.runtime.haystack.Contracts == 1)
        local i: number
        IREqual(haystack[i])
        § assert(#env.runtime.haystack.Contracts == 1)
        IREqual(haystack[i])
        § assert(#env.runtime.haystack.Contracts == 1)
    end
    
    local instList = {{1, 0}}
    § assert(#env.runtime.instList.Contracts == 0)
    replaceIRs(instList)
    § assert(#env.runtime.instList.Contracts == 0)    
]]
analyze[[
    local z = 2
    do
        local function WORD(low: number, high: number)
        end
    
        do
            local function WSAStartup(a: any,b: any) end
            local x = 1
    
            local wsa_data = _ as function=()>() | nil
    
            local function initialize()
                -- make sure  parent scope of initialize is preserved when scope is cloned
                § analyzer.SuppressDiagnostics = true
                local data = wsa_data() -- scope clone occurs here because wsdata can be nil
                § analyzer.SuppressDiagnostics = nil
    
                attest.equal(x, 1)
                attest.equal(z, 2)
    
                WSAStartup(WORD(2, 2), data)
            end
        end
    end
]]
analyze[[
    local func: function=(number, string)>(nil)
    local x: function=(unpack<|Parameters<|func|>|>)>(nil)
    attest.equal(x, func)
]]
analyze[[
    local analyzer function foo(n: number): number, string
        return types.LNumber(1337), types.LString("foo")
    end
    
    local x,y = foo(1)
    attest.equal(x, 1337)
    attest.equal(y, "foo")
    
    attest.equal<|foo, function=(number)>(number, string)|>
]]
analyze(
	[[
    local function foo(s: ref literal string)
        return s
    end
    
    foo(_ as string)    
]],
	"string is not a subset of literal string"
)
analyze[[
    local function foo(str: literal ref (nil | string))
        return str
    end
    attest.equal(foo("hello"), "hello")
]]
analyze[[
    local function foo(x: any)
        local y = {foo = 0}
    
        if type(x) == "string" then
            y.foo = 1
        elseif type(x) == "number" then
            y.foo = 2
        elseif type(x) ~= "table" then
            y.foo = 3
        end
    
        return y
    end
    
    § analyzer:AnalyzeUnreachableCode()
    
    attest.equal(return_type<|foo|>[1], {foo = _ as 0 | 1 | 2 | 3})
]]
analyze[[
    local type Instruction = {number, number}
    local type InstructionList = {[number] = Instruction}

    local tbl = {} as InstructionList

    local function foo(x: InstructionList)

    end

    foo(tbl)
]]
analyze(
	[[
    local function foo(out: List<|string|>)
    end
    
    local x = {"", "b", 1}
    foo(x)
]],
	"key 3 is not a subset of nil | string"
)
analyze[[
    local function fmt(str: string)
        if math.random() > 0.5 then 
            error("!") 
        end
    end
    
    local function StartNode()
        assert(true)
        return 1337
    end
    
    local function ResolvePath()
        local node = StartNode()
        attest.equal(node, 1337)
    end
]]
analyze[[
    local function foo()
        assert(math.random() > 0.5)
        return 1337
    end
    
    local function ReadIdentifier()
        if math.random() > 0.5 then return nil end
        local node = foo()
    
        attest.equal(node, 1337)
    end
]]
analyze[[

    local function foo()
        assert(true)
        return 1337
    end

    local function ReadIdentifier()
        if math.random() > 0.5 then return nil end
        local node = foo()

        attest.equal(node, 1337)
    end
]]
analyze[[
    local type F = function=(foo: number, a: string, b: boolean, c: string)>(nil)

    local function foo(a: string, b: F)
    
    end
    
    foo("hello", function(a,b,c,d) 
        attest.equal(a, _ as number)
        attest.equal(b, _ as string)
        attest.equal(c, _ as boolean)
        attest.equal(d, _ as string)
    end)

    §assert(#analyzer.diagnostics == 0)
]]
analyze[[
    local type F = function=(foo: number, ...: (string,)*inf)>(nil)

    local function foo(a: string, b: F)
        
    end
    
    foo("hello", function(a,b,c,d) 
        attest.equal(a, _ as number)
        attest.equal(b, _ as string)
        attest.equal(c, _ as string)
        attest.equal(d, _ as string)
    end)
]]
analyze[[
    local type F = function=(foo: number, ...: ...string)>(nil)

    local function foo(a: string, b: F)
        
    end
    
    foo("hello", function(a,b,c,d) 
        attest.equal(a, _ as number)
        attest.equal(b, _ as string)
        attest.equal(c, _ as string)
        attest.equal(d, _ as string)
    end)
]]

analyze[[
    local function foo(n: number): string
        return "hello"
    end
    
    attest.expect_diagnostic<|"error", "not the same type"|>
    local x = foo("hello")
    attest.equal(x, _ as string)
]]