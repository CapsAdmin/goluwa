local T = require("test.helpers")
local analyze = T.RunCode
analyze([[
    local type A = {Type = "human"}
    local type B = {Type = "cat"}

    local x: A | B

    if x.Type == "cat" then
        attest.equal(x.Type, "cat")
    end

    if x.Type == "human" then
        attest.equal(x.Type, "human")
    end
]])
