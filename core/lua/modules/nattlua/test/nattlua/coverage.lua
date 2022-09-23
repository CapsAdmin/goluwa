local coverage = require("nattlua.other.coverage")

local function collect(code)
	assert(loadstring(coverage.Preprocess(code, "test")))()
--    print(coverage.Collect("test"))
end

collect([[

    local foo = {
        bar = function() 
            local x = 1
            x = x + 1
            do return x end
            return x
        end
    }

    --foo:bar()

    for i = 1, 10 do
        -- lol
        if i == 15 then
            while false do
                notCovered:Test()
            end
        end
    end
]])
collect([=[
    local analyze = function() end
    analyze([[]])
    analyze[[]]  
]=])
collect[[
    local tbl = {}
    function tbl.ReceiveJSON(data, methods, ...)

    end
]]
