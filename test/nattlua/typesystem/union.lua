local T = require("test.helpers")
local Union = T.Union
local String = T.String
local Number = T.Number
local Tuple = T.Tuple

test("a union should not contain duplicates", function()
	assert(Union("a", "b", "a", "a"):Equal(Union("a", "b")))
end)

local larger = Union("a", "b", "c")
local smaller = Union("a", "b")
local different = Union("b", "x", "y")

test("a union should be a subset of an identical union", function()
	assert(smaller:IsSubsetOf(smaller))
end)

test("a smaller union should be a subset of a larger union", function()
	assert(smaller:IsSubsetOf(larger))
end)

test("a larger union should not be a subset of a smaller union", function()
	assert(not larger:IsSubsetOf(smaller))
end)

test("a different union should not be a subset of a union", function()
	assert(not different:IsSubsetOf(larger))
end)

test("a larger union should not be a subset of a different union", function()
	assert(not larger:IsSubsetOf(different))
end)

pending("a tuple of one smaller union should be a subset of a larger union", function()
	assert(Tuple(smaller):IsSubsetOf(larger))
end)

test("a smaller union should be a subset of a tuple containing 1 larger union", function()
	assert(smaller:IsSubsetOf(Tuple(larger)))
end)

test("a number should be a subset of a union with numbers", function()
	assert(Number(24)):IsSubsetOf(Union(Number(), Number()))
end)

test("a smaller union within an empty union should be identical to the smaller union", function()
	assert(smaller:Equal(Union(smaller)))
end)

test("a union containing one literal number should be a subset of a union containing a number", function()
	assert(Union(1):IsSubsetOf(Number()))
end)

local A = Union(1, 2, 3)
local B = Union(1, 2, 3, 4)

test(tostring(B) .. " should equal the union of " .. tostring(A) .. " and " .. tostring(B), function()
	assert(B:Equal(A:Union(B)))
	equal(4, B:GetLength())
	assert(A:IsSubsetOf(B))
end)

assert(tostring(Union()) == "|")
