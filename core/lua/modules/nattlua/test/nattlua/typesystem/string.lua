local T = require("test.helpers")
local Object = T.Object
local any = T.Any()
local foo = T.String("foo")
local all_letters = T.String()
local foo_bar = T.String("foo bar")

test("'foo' should be contained within all letters", function()
	assert(foo:IsSubsetOf(all_letters))
end)

test("all letters should not be contained within 'foo'", function()
	assert(not all_letters:IsSubsetOf(foo))
end)

test("'foo' should be contained in any", function()
	assert(foo:IsSubsetOf(any))
end)

test("any should be contained within 'foo'", function()
	assert(any:IsSubsetOf(foo))
end)
