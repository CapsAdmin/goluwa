local T = require("test.helpers")
local analyze = T.RunCode
local check = function(analyzer, to)
	equal(
		to:gsub("%s+", " "),
		tostring(analyzer:GetLocalOrGlobalValue(T.String("a"))):gsub("%s+", " "),
		2
	)
end
analyze[[
        -- can be simple
        local x = {1, 2, 3}
        x[2] = 10

        attest.equal(x[2], 10)
    ]]
analyze[[
        -- can be sparse
        local x = {
            [2] = 2,
            [10] = 3,
        }

        attest.equal(x[10], 3)
    ]]
analyze[[
        -- can be indirect
        local RED = 1
        local BLUE = 2
        local x = {
            [RED] = 2,
            [BLUE] = 3,
        }
        attest.equal(x[RED], 2)
    ]]
-- {[number]: any}
check(analyze[[local a: {[number] = any} = {[1] = 1}]], "{ [number] = number as any }")
analyze([[local a: {[number] = any} = {foo = 1}]], [[has no field "foo"]])
-- {[1 .. inf]: any}
check(
	analyze[[local a: {[1 .. inf] = any} = {[1234] = 1}]],
	"{ [1..inf] = number as any }"
)
analyze([[local a: {[1 .. inf] = any} = {[-1234] = 1}]], [[has no field %-1234]])
analyze[[
        -- traditional array
        local function Array<|T: any, L: number|>
            return {[1 .. L] = T}
        end

        local list: Array<|number, 3|> = {1, 2, 3}
    ]]
analyze(
	[[
        local function Array<|T: any, L: number|>
            return {[1 .. L] = T}
        end

        local list: Array<|number, 3|> = {1, 2, 3, 4}
    ]],
	"has no field 4"
)
analyze[[
    local a: {1,2,3} = {1,2,3}
    attest.equal(a[1], 1)
]]
analyze[[
    local a: {[number]=string}
    attest.equal(a[1], _ as string)
]]