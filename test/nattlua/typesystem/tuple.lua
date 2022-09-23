local T = require("test.helpers")
local String = T.String
local Number = T.Number
local Tuple = T.Tuple
local Any = T.Any
local SN = Tuple(String(), Number())
local NS = Tuple(Number(), String())
local SNS = Tuple(String(), Number(), String())

test(tostring(SN) .. " should not be a subset of " .. tostring(NS), function()
	assert(not SN:IsSubsetOf(NS))
end)

test(tostring(SN) .. " should be a subset of " .. tostring(SN), function()
	assert(SN:IsSubsetOf(SN))
end)

pending(tostring(SN) .. " should be a subset of " .. tostring(SNS), function()
	assert(SN:IsSubsetOf(SNS))
end)

test(tostring(SNS) .. " should not be a subset of " .. tostring(SN), function()
	assert(not SNS:IsSubsetOf(SN))
end)

test("remainder", function()
	local tup = Tuple(
		String(),
		Number(),
		String(),
		Number(),
		String(),
		Number(),
		String(),
		Number(),
		String(),
		Number()
	):AddRemainder(Tuple(String()):SetRepeat(10))
	assert(tup:GetLength() == 10 + (1 * 10))
	assert(tup:Get(1).Type == "string")
	assert(tup:Get(2).Type == "number")
	assert(tup:Get(9).Type == "string")
	assert(tup:Get(10).Type == "number")
	assert(tup:Get(11).Type == "string")
	assert(tup:Get(12).Type == "string")
	assert(tup:Get(15).Type == "string")
	assert(tup:Get(18).Type == "string")
	assert(tup:Get(19).Type == "string")
	assert(tup:Get(20).Type == "string")
	assert(tup:Get(21) == false)
end)

test("remainder with repeated tuple structure", function()
	local tup = Tuple(String()):AddRemainder(Tuple(String(), Number()):SetRepeat(4))
	assert(tup:GetLength() == 1 + (2 * 4))
	assert(tup:Get(1).Type == "string")
	assert(tup:Get(2).Type == "string")
	assert(tup:Get(3).Type == "number")
	assert(tup:Get(4).Type == "string")
	assert(tup:Get(5).Type == "number")
end)

test("tuple unpack", function()
	local tup = Tuple(String()):AddRemainder(Tuple(String(), Number()):SetRepeat(4))
	local tbl = {tup:Unpack()}
	assert(tup:GetLength() == 1 + (2 * 4))
	assert(tup:GetLength() == #tbl)
	assert(tbl[1].Type == "string")
	assert(tbl[2].Type == "string")
	assert(tbl[3].Type == "number")
	assert(tbl[4].Type == "string")
	assert(tbl[5].Type == "number")
end)

test("tuple unpack", function()
	local tup = Tuple(String()):AddRemainder(Tuple(String(), Number()):SetRepeat(4))
	local tbl = {tup:Unpack(3)}
	assert(#tbl == 3)
	assert(tbl[1].Type == "string")
	assert(tbl[2].Type == "string")
	assert(tbl[3].Type == "number")
	local tbl = {tup:Unpack(1)}
	assert(#tbl == 1)
	assert(tbl[1].Type == "string")
end)

test("infinite tuple repetition", function()
	local tup = Tuple(String()):AddRemainder(Tuple(String(), Number()):SetRepeat(math.huge))
	assert(tup:Get(1).Type == "string")
	assert(tup:Get(2).Type == "string")
	assert(tup:Get(10000).Type == "string")
	assert(tup:Get(10001).Type == "number")
	assert(select("#", tup:Unpack(100)) == 100)
end)

test("length subset", function()
	local A = Tuple(String(), String())
	local B = Tuple(String(), String(), String())
	assert(B:IsSubsetOf(A) == false)
end)

test("length subset", function()
	local A = Tuple(String(), String())
	local B = Tuple(String()):AddRemainder(Tuple(String()):SetRepeat(4))
	assert(B:IsSubsetOf(A) == true)
end)

test("initialize with remainder", function()
	local A = Tuple(String(), Tuple(String()):SetRepeat(2))
	assert(A:GetLength() == 3)
	assert(A:Get(1).Type == "string")
	assert(A:Get(2).Type == "string")
	assert(A:Get(3).Type == "string")
end)

test("initialize with remainder", function()
	local A = Tuple(Tuple(String()):SetRepeat(2), Number())
	assert(A:GetLength() == 2)
	assert(A:Get(1).Type == "tuple")
	assert(A:Get(2).Type == "number")
end)

test("merge tuples", function()
	local infinite_any = Tuple():AddRemainder(Tuple(Any()):SetRepeat(math.huge))
	local number_number = Tuple(Number(), Number())
	infinite_any:Merge(number_number)
	assert(infinite_any:GetLength() == math.huge)
	assert(infinite_any:Get(1).Type == "union")
	assert(infinite_any:Get(2).Type == "union")
	assert(infinite_any:Get(1):GetType("number"))
	assert(infinite_any:Get(1):GetType("any"))
	assert(infinite_any:Get(2):GetType("number"))
	assert(infinite_any:Get(2):GetType("any"))
	assert(not infinite_any:Get(2):GetType("string"))
end)

test("tuple in tuple", function()
	local T = Tuple(1, 2, 3, Tuple(4, 5, 6))
	assert(T:GetLength() == 6)

	for i = 1, 6 do
		assert(T:Get(i):GetData() == i)
	end
end)
