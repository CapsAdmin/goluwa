local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    local function foo(): number, number
        if math.random() > 0.5 then
            return foo()
        end
        return 2, 1
    end
    
    attest.equal(foo(), _ as (number, number))
]]
analyze(
	[[
    local function foo(): number, number
        if math.random() > 0.5 then
            return foo()
        end
        return nil, 1
    end
]],
	"nil is not the same type as number"
)
analyze[[
    local type Json = string | number | boolean | nil | {[string] = CurrentType<|"union", 2|>} | {[number] = CurrentType<|"union", 1|>}
    -- TODO, when we want to get the current union, we have to get it 1 level above the current because of how the union operator is evaluated

    local json: Json = {
        foo = {1, 2, 3},
        bar = true,
        faz = {
            asdf = true,
            bar = false,
            foo = {1,2,3},
            lol = {},
        }
    }
]]
analyze(
	[[
    local type Json = string | number | boolean | nil | {[string] = CurrentType<|"union", 2|>} | {[number] = CurrentType<|"union", 1|>}

    local json: Json = {
        foo = {1, 2, 3},
        bar = true,
        faz = {
            asdf = true,
            [2] = false,
            foo = {1,2,3},
            lol = {},
        }
    }
]],
	"2 is not the same type as string"
)
analyze[[
    type VirtualNode = string | {string, {[string] = any}, [3 .. inf] = CurrentType<|"union"|>}
    local myNode: VirtualNode = {
        "div",
        {id = "parent"},
        {"div", {id = "first-child"}, "I'm the first child"},
        {"div", {id = "second-child"}, "I'm the second child"},
    }
]]
analyze(
	[[
    type VirtualNode = string | {string, {[string] = any}, [3 .. inf] = CurrentType<|"union"|>}
    local myNode: VirtualNode = {
        "div",
        {id = "parent"},
        {"div", {id = "first-child"}, "I'm the first child"},
        {"div", {1,id = "second-child"}, "I'm the second child"},
    }
]],
	"1 is not the same type as string"
)