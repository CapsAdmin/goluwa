local T = require("test.helpers")
local analyze = T.RunCode
local String = T.String

test("reassignment", function()
	local analyzer = analyze[[
        local tbl = {}
        tbl.foo = true
        tbl.foo = false
    ]]
	local tbl = analyzer:GetLocalOrGlobalValue(String("tbl"))
	equal(false, tbl:Get(String("foo")):GetData())
	local analyzer = analyze[[
        local tbl = {foo = true}
        tbl.foo = false
    ]]
	local tbl = analyzer:GetLocalOrGlobalValue(String("tbl"))
	equal(false, tbl:Get(String("foo")):GetData())
end)

test("typed field", function()
	local analyzer = analyze[[
        local tbl: {foo = boolean} = {foo = true}
    ]]
	equal(true, analyzer:GetLocalOrGlobalValue(String("tbl")):Get(String("foo")):GetData())
end)

test("typed table invalid reassignment should error", function()
	local analyzer = analyze(
		[[
            local tbl: {foo = 1} = {foo = 2}
        ]],
		"2 is not a subset of 1"
	)
end)

test("typed table invalid reassignment should error", function()
	local analyzer = analyze(
		[[
            local tbl: {foo = 1} = {foo = 1}
            tbl.foo = 2
        ]],
		"2 is not a subset of 1"
	)
	local v = analyzer:GetLocalOrGlobalValue(String("tbl"))
	analyze(
		[[
            local tbl: {foo = {number, number}} = {foo = {1,1}}
            tbl.foo = {66,66}
            tbl.foo = {1,true}
        ]],
		".-true is not a subset of.-number"
	)
end)

test("typed table correct assignment not should error", function()
	analyze([[
        local tbl: {foo = true} = {foo = true}
        tbl.foo = true
    ]])
end)

test("self referenced tables should be equal", function()
	local analyzer = analyze([[
        local a = {a=true}
        a.foo = {lol = a}

        local b = {a=true}
        b.foo = {lol = b}
    ]])
	local a = analyzer:GetLocalOrGlobalValue(String("a"))
	local b = analyzer:GetLocalOrGlobalValue(String("b"))
	local ok, err = a:IsSubsetOf(b)

	if not ok then error(err) end

	equal(true, ok)
end)

test("indexing nil in a table should be allowed", function()
	local analyzer = analyze([[
        local tbl = {foo = true}
        local a = tbl.bar
    ]])
	equal("symbol", analyzer:GetLocalOrGlobalValue(String("a")).Type)
	equal(nil, analyzer:GetLocalOrGlobalValue(String("a")):GetData())
end)

test("indexing nil in a table with a contract should error", function()
	analyze(
		[[
        local tbl: {foo = true} = {foo = true}
        local a = tbl.bar
    ]],
		"\"bar\" is not the same value as \"foo\""
	)
end)

test("string: any", function()
	analyze([[
        local a: {[string] = any | nil} = {} -- can assign a string to anything, (most common usage)
        a.lol = "aaa"
        a.lol2 = 2
        a.lol3 = {}
    ]])
end)

test("empty type table shouldn't be writable", function()
	analyze([[
        local a: {} = {}
        a.lol = true
    ]], "has no field .-lol")
end)

test("wrong right hand type should error", function()
	analyze(
		[[
        local {a,b} = nil
    ]],
		"expected a table on the right hand side, got"
	)
end)

test("should error when key doesn't match the type", function()
	analyze(
		[[
        local a: {[string] = string | nil} = {}
        a.lol = "a"
        a[1] = "a"
    ]],
		"is not the same type as string"
	)
end)

test("with typed numerically indexed table should error", function()
	analyze(
		[[
        local tbl: {1,true,3} = {1, true, 3}
        tbl[2] = false
    ]],
		"false is not the same value as true"
	)
end)

test("which has no data but contract says it does should return what the contract says", function()
	analyze[[
        local tbl = {} as {[string] = 1}
        attest.equal(tbl.foo, 1)
    ]]
	analyze(
		[[
        local tbl = {} as {[string] = 1}
        attest.equal(tbl[true], nil)
    ]],
		"has no field true"
	)
end)

test("is literal", function()
	local a = analyze[[
        local type a = {a = 1, b = 2}
    ]]
	a:PushAnalyzerEnvironment("typesystem")
	equal(a:GetLocalOrGlobalValue(String("a")):IsLiteral(), true)
	a:PopAnalyzerEnvironment()
	local a = analyze[[
        local type a = {a = 1, b = 2, c = {c = true}}
        ]]
	a:PushAnalyzerEnvironment("typesystem")
	equal(a:GetLocalOrGlobalValue(String("a")):IsLiteral(), true)
	a:PopAnalyzerEnvironment()
end)

test("is not literal", function()
	local a = analyze[[
        local type a = {a = number, [string] = boolean}
    ]]
	a:PushAnalyzerEnvironment("typesystem")
	equal(a:GetLocalOrGlobalValue(String("a")):IsLiteral(), false)
	a:PopAnalyzerEnvironment()
	local a = analyze[[
        local type a = {a = 1, b = 2, c = {c = boolean}}
    ]]
	a:PushAnalyzerEnvironment("typesystem")
	equal(a:GetLocalOrGlobalValue(String("a")):IsLiteral(), false)
	a:PopAnalyzerEnvironment()
end)

local a = analyze[[
        -- self reference
        local type Base = {
            Test = function=(self, number)>(number),
        }

        local type Foo = Base extends {
            GetPos = function=(self)>(number),
        }

        -- have to use as here because {} would not be a subset of Foo
        local x = _ as Foo
        
        attest.equal(x:Test(1), _ as number)
        attest.equal(x:GetPos(), _ as number)

        local func = x.Test
    ]]
equal(a:GetLocalOrGlobalValue(String("func")):GetInputSignature():Get(1):Get(String("GetPos")).Type, "function")
equal(a:GetLocalOrGlobalValue(String("func")):GetInputSignature():Get(1):Get(String("Test")).Type, "function")
analyze[[
        local type a = {
            foo = self,
        }

        local type b = {
            bar = true,
        } extends a

        attest.equal<|b.bar, true|>
        attest.equal<|b.foo, b|>
    ]]
analyze[[
        -- table extending table
        local type A = {
            Foo = true,
        }

        local type B = {
            Bar = false,
        }

        attest.equal<|A extends B, {Foo = true, Bar = false}|>
    ]]
analyze[[
        -- table + table
        local type A = {
            Foo = true,
            Bar = 1,
        }

        local type B = {
            Bar = false,
        }

        attest.equal<|A + B, {Foo = true, Bar = false}|>
    ]]
analyze[[
        -- index literal table with string
        local tbl = {
            [ '"' ] = 1,
            [ "0" ] = 2,
        }

        local key: string
        local val = tbl[key]
        attest.equal(val, _ as 1 | 2 | nil)
    ]]
analyze[[
        -- non literal keys should be treated as literals when used multiple times in the same scope
        local foo: string
        local bar: string

        local a = {}
        a[foo] = a[foo] or {}
        a[foo][bar] = a[foo][bar] or 1

        attest.equal(a[foo][bar], 1)
    ]]
analyze[[
        -- table is not literal
        local tbl:{[number] = number} = {1,2,3}
        local analyzer function check_literal(tbl: any)
            assert(tbl:IsLiteral() == false)
        end
        check_literal(tbl)
    ]]
analyze[[
        -- var args with unknown length
        local tbl = {...}
        attest.equal(tbl[1], _ as any)
        attest.equal(tbl[2], _ as any)
        attest.equal(tbl[100], _ as any)
    ]]
analyze[[
    local list: {[number] = any} | {}
    list = {}
    attest.equal(list, _ as {})
    attest.equal<|list, {[number] = any} | {}|>
]]
analyze[[
    local a = {foo = true, bar = false, 1,2,3}
    attest.equal(a[1], 1)
    attest.equal(a[2], 2)
    attest.equal(a[3], 3)
]]

test("deep nested copy", function()
	local a = analyze([[
        local a = {nested = {}}
        a.a = a
        a.nested.a = a
    ]]):GetLocalOrGlobalValue(String("a"))
	equal(a:Get(String("nested")):Get(String("a")), a)
	equal(a:Get(String("a")), a)
	equal(a:Get(String("a")), a:Get(String("nested")):Get(String("a")))
end)

analyze[[
    local lol = {
        foo = true,
        bar = false,
        lol = 1,
    }
    
    local function test(token)
        -- here token is, string | string, but it should be string when being used as key
        return lol[token]
    end         
    
    local x = test(lol as string | string)
    attest.equal(x, _ as 1 | true | false | nil)    
]]
analyze[[
    local type T = {Foo = "something" | nil, Bar = "definetly"}

    local a = {} as T
    attest.equal<|a.Foo, nil | "something"|>

    a.Foo = nil
    attest.equal(a.Foo, nil)

    a.Foo = "something"
    attest.equal(a.Foo, "something")


    a.Foo = _ as "something" | nil
    attest.equal<|a.Foo, "something" | nil|>

    attest.equal<|a.Bar, "definetly"|>
]]
analyze[[
    local function fill(t)
        t.foo = true
    end
    
    local tbl = {}
    fill(tbl)
    attest.equal(tbl.foo, true)
]]
analyze[[
    local function fill(t: mutable ref {foo = boolean, bar = number})
        t.foo = true
    end
    
    local tbl = {bar = 1, foo = false}
    fill(tbl)
    attest.equal(tbl.foo, true)
]]
analyze[[
    local type ShapeA = {Foo = boolean | nil}
    local type ShapeB = {Bar = string | nil}
    
    local function mutate(obj: mutable ShapeA & ShapeB)
        obj.Bar = "asdf"
    end
    
    local obj = {}
    mutate(obj)
]]
analyze(
	[[
    local type ShapeA = {Foo = boolean | nil}
    local type ShapeB = {Bar = string | nil}

    local function mutate(obj: ShapeA & ShapeB)
        obj.Bar = "asdf"
    end

    local obj = {Foo = nil}
    mutate(obj)
]],
	"mutating function argument"
)
analyze[[
    local type ShapeA = {Foo = boolean | nil}
    local type ShapeB = {Bar = string | nil}

    local function mutate(obj: ShapeA & ShapeB)

    end

    local obj = {}
    -- should be okay, because all the values in the contract can be nil
    mutate(obj)
]]
analyze(
	[[
    local type ShapeA = {Foo = boolean}
    local type ShapeB = {Bar = string}

    local function mutate(obj: ShapeA & ShapeB)

    end

    local obj = {}
    mutate(obj)
]],
	"{ } has no field.-Foo"
)
analyze(
	[[
    local type ShapeA = {Foo = boolean}
    local type ShapeB = {Bar = string}

    local function mutate(obj: ShapeA & ShapeB)

    end

    local obj = {Foo = true}
    mutate(obj)
]],
	"has no field \"Bar\""
)
analyze[[
    local type Foo = {}
    local type Bar = {
        field = number | nil,
    }

    local function test(ent: Foo & Bar)
        attest.equal(ent.field, _ as nil | number)
        ent.field = 1
        attest.equal(ent.field, _ as 1)
        ent.field = nil
        attest.equal(ent.field, _ as nil)
    end

    test(_ as Foo & Bar)
]]
analyze[[
    local type Foo = {}
    local type Bar = {
        field = number | nil,
    }

    local function test(ent: Foo & Bar)
        attest.equal(ent.field, _ as nil | number)
        ent.field = 1
        attest.equal(ent.field, _ as 1)
        ent.field = nil
        attest.equal(ent.field, _ as nil)
    end
]]
analyze[[
    local type Entity = {
        GetModel = function=(self)>(string),
        GetBodygroup = function=(self, number)>(number),
    }

    type Entity.@Name = "Entity"

    local type HeadPos = {
        findheadpos_head_bone = number | nil,
        findheadpos_head_attachment = string | nil,
        findheadpos_last_mdl = string | nil,
    }

    local function FindHeadPosition(ent: Entity & HeadPos)
        
        if ent.findheadpos_last_mdl ~= ent:GetModel() then
            ent.findheadpos_head_bone = nil
            ent.findheadpos_head_attachment = nil
            ent.findheadpos_last_mdl = ent:GetModel()
        end
        
    end
]]
analyze[[
    attest.equal({Unknown()}, _ as {[1 .. inf] = any})
    attest.equal({Unknown(), 1}, _ as {any, 1})
]]
analyze[[

    local function test(tbl: ref {
        Foo = boolean,
        Bar = number,
        [string] = any,
    })
        attest.equal(tbl.Foo, _ as true)
        attest.equal(tbl.Bar, _ as 1337)
    
        tbl.NewField = 8888
        tbl.NewField2 = 9999
    
        attest.equal(tbl.NewField, 8888)
        attest.equal(tbl.NewField2, 9999)
    end
    
    local tbl = {Foo = true, Bar = 1337}
    
    test(tbl)
    
    attest.equal(tbl.Foo, _ as true)
    attest.equal(tbl.Bar, _ as 1337)
    attest.equal(tbl.NewField, 8888)
    attest.equal(tbl.NewField2, 9999)
    
]]
analyze[[
    local e = {}

    e.FOO = 1337
    
    if math.random() > 0.5 then
        e.FOO = 666
    end
    
    for k,v in pairs(e) do
        attest.equal(k, "FOO")
        attest.equal(v, _ as 666 | 1337)
    end
]]
analyze[[
    local META = {}

    function META:Test()

    end

    if not META["Foo"] then
        
    end

    §assert(#analyzer.diagnostics == 1)
]]
analyze(
	[[
    local META = {} as {Test = function=(self)>(nil)}

    function META:Test()
    
    end
    
    if not META["Foo"] then
        
    end
]],
	"has no field \"Foo\""
)

if false then
	analyze[[
        local function tbl_get_foo(self)
            attest.equal(self.foo, 1337)
            return tbl.foo
        end

        local tbl = {}
        tbl.foo = 1337
        tbl.get_foo = tbl_get_foo
    ]]
end

analyze[[
    local function foo(tbl: {
        [number] = true,
        foo = true,
        bar = false,
    }) 
        local x = tbl[_ as number]
        local y = tbl[1]
        local z = tbl[_ as string]
        attest.equal(x,y)
        attest.equal(z, _ as nil | boolean)
    end
]]
analyze[[
    local lol: number
    local t = {}

    t[lol] = 1
    t[lol] = 2
    attest.equal(t[lol], 2)
]]
analyze(
	[[
    local RED = 1
    local BLUE = 2
    local GREEN: string
    local x: {[1 .. inf] = number} = {
        [RED] = 2,
        [BLUE] = 3,
        [GREEN] = 4,
    }
]],
	"has no field string"
)
analyze[[
    local type Foo = { bar = 1337 }
    local type Bar = { foo = 8888 }
    attest.equal<|Foo + Bar, Foo & Bar|>
]]
analyze[[
    local tbl = {}
    tbl.foo = true
    tbl.bar = false

    local key = _ as "foo" | "bar"
    attest.equal<|tbl[key], true | false|>
]]
analyze[[
    local tbl = _ as {foo = true} | {foo = false}
    attest.equal<|tbl.foo, true | false|>
]]
analyze[[
    local analyzer function test(a: any, b: any)
        analyzer:Assert(b:IsSubsetOf(a))
    end
    
    test(_ as {foo = number}, _ as {foo = number, bar = nil | number})
]]
analyze(
	[[
    local t = {} as {
        foo = {foo = string}    
    }
    t.foo["test"] = true
]],
	"is not the same value as .-foo"
)
analyze[[
    local META =  {}
    META.__index = META

    type META.@Self = {
        foo = true,
    }

    local type x = META.@Self & {bar = false}
    attest.equal<|x, {foo = true, bar = false}|>
    attest.equal<|META.@Self, _ as {foo = true}|>
]]
analyze[[
    local t = {} as {[1 .. inf] = number}
    attest.equal(#t, _ as 1 .. inf)
]]
analyze[[

    local function test<||>
        -- make sure we are analyzing nodes in the typesystem
        return {
            a = 1 | 2,
            b = function=(string)>(number),
        }
    end

    attest.equal(test().a, _ as 1 | 2)
    attest.equal(test().b, _ as function=(string)>(number))
]]
analyze[[
    local function create_set(...)
        local res = {}
        for i = 1, select("#", ...) do
            res[ select(i, ...) ] = true
        end
        return res
    end
    
    local space_chars   = create_set(" ", "\t", "\r", "\n")
    attest.equal(space_chars, {
        [" "] = true,
        ["\t"] = true,
        ["\r"] = true,
        ["\n"] = true,
    })
]]
analyze[[
    local throw = function() error("!") end

    local map = {
        foo = function() if math.random() > 0.5 then throw() end return 1 end,
        bar = function() if math.random() > 0.5 then throw() end return 2 end,
    }

    local function main()
        local x = map[_ as string]
        if x then
            local val = x()
            return val
        end
        error("nope")
    end

    attest.equal(main(), _ as 1 | 2)
]]
analyze[[
    local tbl = {}
    table.insert(tbl, _ as number)
    table.insert(tbl, _ as string)
    attest.equal(tbl, {_ as number, _ as string})
]]
analyze[[
    local type t = {[any] = any}
    attest.equal(t["foo" as string], _ as any)
]]
analyze[[
    local META = {}
    META.__index = META
    type META.@Self = {}

    function META.GetSet(name: ref string, default: ref any)
        META[name] = default
        type META.@Self[name] = META[name]
    end

    META.GetSet("Name", nil as nil | META.@Self)
    META.GetSet("Literal", false)

    function META:SetName(name: META.@Self)
        self.Name = name
    end
]]
analyze[[
    local type T = {
        foo = Table,
    }
    
    local x = {} as T
    
    x.foo.lol = true
    
    attest.equal(Table, _ as {[any] = any} | {})
]]
analyze[[
    
    local luadata = {}

    local type Context = {
        done = Table
    }
    function luadata.SetModifier(type: string, callback: function=(any, Context)>(nil), func: nil, func_name: nil)
    
    end
    
    luadata.SetModifier("table", function(tbl, context)
        context.done[tbl] = true
    
        attest.equal(Table, _ as {[any] = any} | {})
    end)
]]
analyze[[
    local lookup = {
        [_ as 1 | 2] = "foo",
        [_ as 1337 | 155] = "bar",
    }
    
    attest.equal(lookup[_ as number], _ as "foo" | "bar" | nil)
]]
analyze[[
    local x = {666, foo = true}
    attest.equal(#x, 1)
]]
analyze[[
    local x = {[1] = 1, [2] = 1, [5] = 2}
    attest.equal(#x, 2)
]]
analyze[[
    local x = {[1 as number] = 1, [2] = 1}
    attest.equal(#x, _ as number)
]]
analyze[[
    local x = {666}

    if math.random() > 0.5 then
        table.insert(x, 1337)
    elseif math.random() > 0.5 then
        table.insert(x, 7777)
    elseif math.random() > 0.5 then
        table.insert(x, 555)
    end

    attest.equal(x[2], _ as 1337 | 7777 | 555 | nil)
]]
analyze[[
    local x: {[number] = 1337} = {1337}
    attest.equal(x[5], _ as 1337)
]]
analyze[[
    local x = {}
    x[_ as number] = 1337
    attest.equal(x[5], _ as nil | 1337)
]]
analyze[[
    local type_func_map = {
        [ "nil"     ] = true,
        [ "table"   ] = "lol",
        [ "string"  ] = 1337,
        [ "number"  ] = false,
        [ "boolean" ] = true,
    }
    
    attest.equal(type_func_map[_ as string], _ as true | "lol" | 1337 | false | nil)
]]
analyze[[
    local operators: {[string] = function=(number, number)>(number)} = {
        ["+"] = function(l, r)
            return l + r
        end,
        ["-"] = function(l, r)
            return l - r
        end,
    }

    attest.equal(operators["-"], _ as function=(number, number)>(number))

    §assert(#analyzer.diagnostics == 0)
]]
analyze[[
    local type Lol = {}
    local function CreateLol()
        return { } as Lol
    end
    
    local type T = {
        foo = true,
    }
    local function lol()
    
        return CreateLol() as T
    end
    
    local x = lol()
    
    attest.expect_diagnostic("error", "has no field.-bar")
    x.bar = false
    
    attest.equal(x, {} as {
        foo = true,
    })
    attest.equal(Lol, {})
    attest.equal(T, {foo = true})
]]
analyze[[
    local tbl = {
        foo = true,
        bar = true,
    }
    local key: string
    
    if tbl[key] then
        local key: string
        local xx = tbl[key]
        attest.equal(xx, _  as nil | true)
        local key2: string
        local xx = tbl[key2]
        attest.equal(xx, _  as nil | true)
    end
]]
analyze[[
    local tbl = {
        [1] = true,
        [2] = true,
    }
    local key: number
    
    if tbl[key] then
        local key: number
        local xx = tbl[key]
        attest.equal(xx, _  as nil | true)
        local key2: number
        local xx = tbl[key2]
        attest.equal(xx, _  as nil | true)
    end
]]
analyze[[
    local tbl = {
        foo = true,
        bar = true,
    }
    if tbl[_ as string] then
        local xx = tbl[_ as string]
        attest.equal(xx, _  as nil | true)
    end
]]
analyze[[
    local tbl = {
        [1] = true,
        [2] = true,
    }
    if tbl[_ as number] then
        local xx = tbl[_ as number]
        attest.equal(xx, _  as nil | true)
    end
]]
analyze[[
    local tbl = {}
    tbl["@hello"] = true
    attest.equal(tbl, {["@hello"] = true})
]]
analyze(
	[[
    local tbl = {}
    type tbl["@hello"] = true
    attest.equal(tbl, {["@hello"] = true})
]],
	"no such function on table"
)
analyze[[
    local tbl = {3, 2, 1}
    table.sort(tbl)
    attest.equal(tbl, {1, 2, 3})
]]
analyze[[
    local tbl = {1, 2, 3}

    table.sort(tbl, function(a, b)
        return a > b
    end)

    attest.equal(tbl, {3, 2, 1})
]]
analyze(
	[[
    local tbl = {1, 2, 3}

    table.sort(tbl, function(a, b)
        return _ as boolean
    end)
]],
	"cannot sort literal table"
)