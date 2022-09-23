local T = require("test.helpers")
local analyze = T.RunCode
local String = T.String

do -- smoke
	local a = analyze[[local type a = 1337 | 8888]]
	a:PushAnalyzerEnvironment("typesystem")
	local union = a:GetLocalOrGlobalValue(String("a"))
	a:PopAnalyzerEnvironment()
	equal(2, union:GetLength())
	equal(1337, union:GetData()[1]:GetData())
	equal(8888, union:GetData()[2]:GetData())
end

do -- union operator
	local a = analyze[[
        local type a = 1337 | 888
        local type b = 666 | 777
        local type c = a | b
    ]]
	a:PushAnalyzerEnvironment("typesystem")
	local union = a:GetLocalOrGlobalValue(String("c"))
	a:PopAnalyzerEnvironment()
	equal(4, union:GetLength())
end

analyze[[
        --union + object
        local a = _ as (1 | 2) + 3
        attest.equal(a, _ as 4 | 5)
    ]]
analyze[[
        --union + union
        local a = _ as 1 | 2
        local b = _ as 10 | 20

        attest.equal(a + b, _ as 11 | 12 | 21 | 22)
    ]]
analyze[[
        --union.foo
        local a = _ as {foo = true} | {foo = false}

        attest.equal(a.foo, _ as true | false)
    ]]
analyze[[
        --union.foo = bar
        local type a = { foo = 4 } | { foo = 1|2 } | { foo = 3 }
        attest.equal<|a.foo, 1 | 2 | 3 | 4|>
    ]]

do --is literal
	local a = analyze[[
        local type a = 1 | 2 | 3
    ]]
	a:PushAnalyzerEnvironment("typesystem")
	assert(a:GetLocalOrGlobalValue(String("a")):IsLiteral() == true)
	a:PopAnalyzerEnvironment()
end

do -- is not literal
	local a = analyze[[
        local type a = 1 | 2 | 3 | string
    ]]
	a:PushAnalyzerEnvironment("typesystem")
	assert(a:GetLocalOrGlobalValue(String("a")):IsLiteral() == false)
	a:PopAnalyzerEnvironment()
end

analyze[[
    local x: any | function=()>(boolean)
    x()
]]
analyze[[
    local function test(x: {}  | {foo = nil | 1})
        attest.equal(x.foo, _ as nil | 1)
        if x.foo then
            attest.equal(x.foo, 1)
        end
    end

    test({})
]]
analyze[[
    local type a = 1 | 5 | 2 | 3 | 4
    local type b = 5 | 3 | 4 | 2 | 1
    attest.equal<|a == b, true|>
]]
analyze[[
    local shapes = _ as {[number] = 1} | {[number] = 2} | {[number] = 3}
    attest.equal(shapes[0], _ as 1|2|3)
]]
analyze(
	[[
    local shapes = _ as {[number] = 1} | {[number] = 2} | {[number] = 3}| false
    local x = shapes[0]
]],
	"false.-0.-on type symbol"
)
analyze([[
    local a: nil | {}
    a.foo = true
]], "undefined set.- = true")
analyze(
	[[
    local b: nil | {foo = true}
    local c = b.foo
]],
	"undefined get: nil.-foo"
)
analyze([[
    local analyzer function test(a: any, b: any)
        local arg = types.Tuple({})
        local ret = types.Tuple({})
    
        for _, func in ipairs(a:GetData()) do
            if func.Type ~= "function" then return false end
    
            arg:Merge(func:GetInputSignature())
            ret:Merge(func:GetOutputSignature())
        end
    
        local f = types.Function(arg, ret)

        assert(f:Equal(b))
    end
    local type A = function=(string)>(number)
    local type B = function=(number)>(boolean)
    local type C = function=(number | string)>(boolean | number)
    
    test<|A|B, C|>
]])
analyze[[
    local type a = |
    type a = a | 1
    type a = a | 2
    attest.equal<|a, 1|2|>
]]
analyze[[
    local type tbl = {[number] = string} | {}
    attest.equal<|tbl[1], string|>
]]
analyze[[
    local function test(foo: string)
        print(foo)
    end
    
    local type t = | 
    
    attest.expect_diagnostic("error", "union is empty")
    test(t)
]]
