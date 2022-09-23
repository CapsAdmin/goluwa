local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
local x = 2
x*=2
attest.equal(x, 4)
]]