local T = require("test.helpers")
local analyze = T.RunCode
local String = T.String
-- boolean is a union
assert(
	T.Union(true, false):Equal(analyze("local a: boolean"):GetLocalOrGlobalValue(String("a")))
)
-- boolean is truthy and falsy
local a = analyze("local a: boolean")
equal(true, a:GetLocalOrGlobalValue(String("a")):IsTruthy())
equal(true, a:GetLocalOrGlobalValue(String("a")):IsFalsy())
