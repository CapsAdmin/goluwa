local T = require("test.helpers")
local analyze = T.RunCode
analyze([[
        local a = 1
        a = -a
        attest.equal(a, -1)
    ]])
analyze([[
        local a = 1++
        attest.equal(a, 2)
    ]])
