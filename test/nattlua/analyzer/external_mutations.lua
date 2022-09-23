local T = require("test.helpers")
local analyze = T.RunCode
analyze(
	[[
    local x: {foo = boolean} = {foo = true}

    unknown(x)
]],
	"cannot mutate argument"
)
analyze([[
    local x = {foo = true}

    unknown(x)

    attest.equal<|x.foo, any | true|>
]])
analyze[[
    local analyzer function unknown(tbl: {[any] = any} | {} )
        tbl:Set(types.LString("foo"), types.LString("bar"))
    end
    
    local x = {}
    
    unknown(x)
    
    attest.equal(x.foo, "bar")    
]]
analyze(
	[[
    local function mutate_table(tbl: {lol = number})
        tbl.lol = 1
    end
    
    local tbl = {lol = 2}
    
    mutate_table(tbl)
    
    attest.equal(tbl.lol, 1)
]],
	"immutable contract"
)
pending[[
    local function string_mutator<|tbl: mutable {[any] = any}|>
        for key, val in pairs(tbl) do
            tbl[key] = nil
        end
        tbl[string] = string
    end
        
    local a = {foo = true}
    
    if math.random() > 0.5 then
        string_mutator(a)
        attest.equal<|a, {[string] = string}|>
    end
    
    attest.equal<|a, {foo = true} | {[string] = string}|>
]]
analyze[[
    local function mutate_table(tbl: mutable ref {foo = number})
        if math.random() > 0.5 then
            tbl.foo = 2
        end
    end
    
    local tbl = {}
    
    tbl.foo = 1
    
    mutate_table(tbl)
    
    attest.equal(tbl.foo, _ as 1 | 2)
]]
analyze[[
    local function mutate_table(tbl: mutable ref {foo = number})
        tbl.foo = 2
    end

    local tbl = {}

    tbl.foo = 1

    mutate_table(tbl)

    attest.equal(tbl.foo, 2)
]]
analyze(
	[[
    local function mutate_table(tbl: {lol = number})
        tbl.lol = 1
    end
    
    local tbl = {lol = 2}
    
    mutate_table(tbl)
    
    attest.equal(tbl.lol, 1)
]],
	"immutable contract"
)
analyze([[
    local function mutate_table(tbl: mutable ref {lol = number})
        tbl.lol = 1
    end
    
    local tbl = {lol = 2}
    
    mutate_table(tbl)
    
    attest.equal(tbl.lol, 1)
]])
analyze([[
    local function mutate_table(tbl: mutable ref {lol = number})
        tbl.lol = 1
    end
    
    local tbl = {}
    
    tbl.lol = 2

    mutate_table(tbl)
    
    attest.equal(tbl.lol, 1)

    §assert(not analyzer:GetDiagnostics()[1])
]])
analyze[[
    local function mutate_table(tbl: ref mutable {foo = number})
        if math.random() > 0.5 then
            tbl.foo = 2
            attest.equal<|typeof tbl.foo, 2|>
        end
        attest.equal<|typeof tbl.foo, 1 | 2|>
    end
    
    local tbl = {}
    
    tbl.foo = 1
    
    mutate_table(tbl)
    
    attest.equal<|typeof tbl.foo, 1 | 2|>
]]
analyze[[
    §analyzer.config.external_mutation = true
    
    local type func = function=(number, {[string] = boolean}, number)>(nil)

    local test = {foo = true}
    
    func(1, test, 2)
    §assert(analyzer:GetDiagnostics()[1].msg:find("can be mutated by external call"))
]]
analyze[[
    local tbl = {} as {foo = number | nil}

    if tbl.foo then
        attest.equal(tbl.foo, _ as number)
    end
]]
analyze[[
    local function foo(x: {value = string})
        attest.equal<|typeof x.value, string|>
    end

    foo({value = "test"})
]]
analyze[[
    local function foo(x: ref {value = string})
        attest.equal<|typeof x.value, "test"|>
    end

    foo({value = "test"})
]]
analyze[[
    local function test(value: {foo = number | nil})
        if value.foo then
            attest.equal(value.foo, _ as number)
        end
    end
    
    test({foo = 4})
]]
analyze[[
    local function test(value: {foo = number | nil})
        if value.foo then
            attest.equal(value.foo, _ as number)
        end
    end
    
]]
analyze[[
    local function mutate(tbl: mutable ref {foo = number, [string] = any})
        tbl.lol = true
        tbl.foo = 3
    end
    
    local tbl = {foo = 1}
    
    attest.equal(tbl.foo, 1)
    
    tbl = {foo = 2}
    
    attest.equal(tbl.foo, 2)
    
    mutate(tbl)
    
    attest.equal(tbl.foo, 3)
    attest.equal(tbl.lol, true)
    
    tbl = {foo = 4}
    
    attest.equal(tbl.foo, 4)
]]
analyze[[
    local t = {lol = "lol"}

    ;(function(val: ref {[string] = string})
        val.foo = "foo"
        ;(function(val: ref {[string] = string})
            val.bar = "bar"
            ;(function(val: ref {[string] = string})
                val.faz = "faz"
                val.lol = "ROFL"
            end)(val)
        end)(val)
    end)(t)
    
    attest.equal(t, {
        foo = "foo",
        bar = "bar",
        faz = "faz",
        lol = "ROFL",
    })
]]
analyze[[
    local function string_mutator<|tbl: mutable {[any] = any}|>
        for key, val in pairs(tbl) do
            tbl[key] = nil
        end
        tbl[string] = string
    end
        
    local a = {foo = true}
    
    string_mutator(a)
    
    attest.equal<|a.foo, string|>
    attest.equal<|a.bar, string|>
]]
analyze[[
    local META = {}
    META.__index = META
    type META.Type = string
    type META.@Self = {}
    type BaseType = META.@Self
    
    function META.GetSet(tbl: ref any, name: ref string, default: ref any)
        tbl[name] = default as NonLiteral<|default|>
    	type tbl.@Self[name] = tbl[name] 
        tbl["Set" .. name] = function(self: tbl.@Self, val: typeof tbl[name] )
            self[name] = val
            return self
        end
        tbl["Get" .. name] = function(self: tbl.@Self): typeof tbl[name] 
            return self[name]
        end
    end
    
    do
        META:GetSet("UniqueID", nil  as nil | number)
        local ref = 0
    
        function META:MakeUnique(b: boolean)
            if b then
                §assert(not analyzer:HasMutations(env.runtime.self))
                self.UniqueID = ref
                ref = ref + 1
            else
                self.UniqueID = nil
            end
    
            return self
        end
    
        function META:DisableUniqueness()
            self.UniqueID = nil
        end
    end
]]
analyze[[
    local META = {}
    META.__index = META
    type META.@Self = {
        Position = number,
    }
    local type Lexer = META.@Self

    function META:IsString()
        return true
    end

    local function ReadCommentEscape(lexer: Lexer & {comment_escape = boolean | nil})
        lexer:IsString()
        lexer.comment_escape = true
    end

    function META:Read()
        ReadCommentEscape(self)
    end
]]