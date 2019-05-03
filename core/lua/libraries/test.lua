local test = {}
test.fail = false

local failed = false
local function fail(what, reason)
    if not failed then
        logn(" - FAIL")
    end

    if reason:find("\n", nil, true) then
        reason = "\n" .. reason
        reason = string.indent(reason, 1)
    end
    logf("%s: %s\n", what, reason)
    failed = true
    test.fail = true
end

function test.start(what)
    if not what then
        local info = debug.getinfo(2)
        table.print(info)
    end

    log("testing ", what)
    failed = false
end

function test.stop()
    if failed then
        
    else
        logn(" - OK")
    end
end

function test.test(func, ...)
    local ret = table.pack(pcall(func, ...))
    if not ret[1] then
        fail(debug.getname(func), ret[2])
        return
    end

    ret = table.pack(unpack(ret, 2))
    
    return {
        expect = function(...)
            local exp = table.pack(...)

            local msg = ""

            for i = 1, exp.n do
                if ret[i] ~= exp[i] then
                    msg = msg .. i .. ": expected " .. tostring(ret[i]) .. " got " .. tostring(exp[i]) .. "\n"
                end
            end
            
            if msg ~= "" then
                fail(debug.getname(func), msg)
            end
        end,

        expect_compare = function(...)
            local exp = table.pack(...)

            local msg = ""

            for i = 1, exp.n do
                local b = ret[i] == exp[i]
                
                if type(exp[i]) == "function" then
                    b = exp[i](ret[i])
                end

                if not b then
                    msg = msg .. i .. ": expected " .. tostring(ret[i]) .. " got " .. tostring(exp[i]) .. "\n"
                end
            end
            
            if msg ~= "" then
                fail(debug.getname(func), msg)
            end
        end,
    }
end

setmetatable(test, {
    __call = function(_, ...) return test.test(...) end,
})

return test