local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    import("~/nattlua/definitions/glua.nlua")    
    attest.equal(string.Split("1|2|3", "|"), {"1","2","3"})
]]
analyze[[
    local type { WorldToLocal, Vector, Angle } = import("~/nattlua/definitions/glua.nlua")
    local pos, ang = WorldToLocal(Vector(1,2,3), Angle(1,5,2), Vector(5,6,2), Angle(10235,123,123))
    
    attest.equal(pos, _ as Vector)
    attest.equal(ang, _ as Angle)
]]
analyze[[
    local type { hook } = import("~/nattlua/definitions/glua.nlua")
    
    hook.Add("OnStart", "mytest", function(a,b,c, d)
        attest.equal(a, _ as string)
        attest.equal(b, _ as boolean)        
    end)
    
    hook.Add("OnStop", "mytest", function(a,b,c, d)
        attest.equal(a, _ as string)
        attest.equal(b, _ as string)
        return 1
    end)
]]
