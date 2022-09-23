local T = require("test.helpers")
local N = T.Number
local Symbol = T.Number
local Union = T.Union
local yes = Symbol(true)
local no = Symbol(false)
local yes_and_no = Union(yes, no)

test(tostring(yes) .. " should be a subset of " .. tostring(yes_and_no), function()
	assert(yes:IsSubsetOf(yes_and_no))
end)

test(tostring(no) .. "  should be a subset of " .. tostring(yes_and_no), function()
	assert(no:IsSubsetOf(yes_and_no))
end)

test(tostring(yes_and_no) .. " is NOT a subset of " .. tostring(yes), function()
	assert(not yes_and_no:IsSubsetOf(yes))
end)

test(tostring(yes_and_no) .. " is NOT a subset of " .. tostring(no), function()
	assert(not yes_and_no:IsSubsetOf(no))
end)
