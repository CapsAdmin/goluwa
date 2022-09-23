local T = require("test.helpers")
local analyze = T.RunCode
analyze[=[
    -- without literal event_name


    local type declared = {}

    local events = {}

    local analyzer function FunctionFromTuples(arg: any, ret: any)
        if arg.Type ~= "tuple" then arg = types.Tuple({arg})  end -- TODO
        if ret.Type ~= "tuple" then ret = types.Tuple({ret})  end -- TODO
        return types.Function(arg, ret)
    end

    function events.Declare<|event_name: string, arguments: any, return_types: any|>
        declared[event_name] = FunctionFromTuples<|arguments, return_types|>
    end

    events.Declare<|"message", (string,), (boolean, string) | (number,)|>
    events.Declare<|"update", (number,), (boolean,)|>

    function events.AddListener(event_name: keysof<|declared|>, listener: declared[event_name])
        attest.equal(event_name, _ as "message" | "update")
        attest.equal(listener, _ as (function=(number | string)>((false | true | (false | true, string) | (number,)))))
    end

    events.AddListener("message", function(data) 
        attest.equal(data, _ as number | string)
        return 1337 
    end)
]=]
analyze[=[
    -- with literal event_name, causing it to choose the specific function

    local type declared = {}

    local events = {}

    local analyzer function FunctionFromTuples(arg: any, ret: any)
        if arg.Type ~= "tuple" then arg = types.Tuple({arg})  end -- TODO
        if ret.Type ~= "tuple" then ret = types.Tuple({ret})  end -- TODO
        return types.Function(arg, ret)
    end

    function events.Declare<|event_name: string, arguments: any, return_types: any|>
        declared[event_name] = FunctionFromTuples<|arguments, return_types|>
    end

    events.Declare<|"message", (string,), (boolean, string) | (number,)|>
    events.Declare<|"update", (number,), (boolean,)|>

    function events.AddListener(event_name: ref (keysof<|declared|>), listener: declared[event_name])
        attest.equal(event_name, _ as "message")
        attest.equal(listener, _ as (function=(string)>((boolean, string) | (nil,))))
    end

    events.AddListener("message", function(data) attest.equal(data, _ as string) return 1337 end)
]=]
analyze[[
    local type tbl = {}
    tbl.foo = 1337
    local function test(key: ref keysof<|tbl|>)
        return tbl[key]
    end
    attest.equal(test("foo"), 1337)
]]
analyze(
	[[
    local type tbl = {}
    tbl.foo = 1337
    local function test(key: ref keysof<|tbl|>)
        return tbl[key]
    end
    attest.equal(test("bar"), 1337)
]],
	"bar.- is not a subset of.-foo"
)
analyze[[
    local function TypeToString<|T: any|>
        if T > number then
            return "number"
        end
        return "other"
    end
    
    local type a = TypeToString<|number|>
    attest.equal<|a, "number"|>
    
    local type b = TypeToString<|string|>
    attest.equal<|b, "other"|>
]]
analyze[[
    local function foo<|A: any, B: any|>(a: A, b: B)
        attest.equal(a, _ as number)
        attest.equal(b, _ as number)
        return a, b
     end
     
     local x,y = foo<|number, number|>(1, 2)
     attest.equal(x, _ as number)
     attest.equal(y, _ as number)
]]
analyze[[
    local function Array<|T: any, Size: number|>(init: nil | {[Size] = T})
        attest.equal<|T, string|>
        attest.equal<|Size, 1..10|>
        attest.equal(init, _ as nil | {[Size] = T})
        return init
    end
    
    local arr = Array<|string, 1..10|>({"hello", "world"})
    attest.equal(arr, _ as nil | {[1..10] = string})    
]]
analyze[[
    local function Array<|T: any, Size: number|>(init: nil | {[Size] = T})
        attest.equal<|T, string|>
        attest.equal<|Size, 1..10|>
        attest.equal(init, _ as nil | {[Size] = T})
        return init
    end
    
    do
        local arr = Array<|string, 1..10|>({"hello", "world"})
        attest.equal(arr, _ as nil | {[1..10] = string})    
    end
]]
analyze[[
    local function sorted_keys<|A: any, B: any|>(m: {[A] = B}): ({[number] = A})
        local keys = {}
    
        for k, _ in pairs(m) do
            table.insert(keys, k)
        end
    
        table.sort(keys)
        return keys
    end
    
    local keys = sorted_keys<|string, string|>({foo = "123", bar = "123", faz = "123"})
    attest.equal<|keys, {[number] = string}|>
]]