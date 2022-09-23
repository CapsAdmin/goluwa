local T = require("test.helpers")
local analyze = T.RunCode
local String = T.String

do
	local foo = analyze([[
        local upvalue1 = 1
        local upvalue2 = 2
        local upvalue3 = 3
        local upvalue4 = 4
        local upvalue5 = 5
        local upvalue6 = 6

        gvalue2 = "bar"

        local function foo()
            upvalue1 = 2
            gvalue1 = "foo" .. gvalue2
            local x = upvalue2

            for i = 1, x - upvalue4 do
                local v = (function()
                    upvalue6 = upvalue6 + 1
                    return upvalue5
                end)()
            end
            return upvalue3
        end

        foo()
    ]]):GetLocalOrGlobalValue(String("foo"))
	equal(foo:GetCallCount(), 1)
	equal(#foo:GetSideEffects(), 5)
end

do
	local foo = analyze([[
        local function foo(x: number)
            return 1 + 2 + x
        end
        
    ]]):GetLocalOrGlobalValue(String("foo"))
	equal(foo:IsPure(), true)
end
