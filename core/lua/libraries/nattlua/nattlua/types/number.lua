local math = math
local assert = assert
local error = _G.error
local tostring = _G.tostring
local tonumber = _G.tonumber
local setmetatable = _G.setmetatable
local type_errors = require("nattlua.types.error_messages")
local bit = _G.bit32 or _G.bit
local META = dofile("nattlua/types/base.lua")
--[[#local type TBaseType = META.TBaseType]]
--[[#type META.@Name = "TNumber"]]
--[[#type TNumber = META.@Self]]
META.Type = "number"
META:GetSet("Data", nil--[[# as number | nil]])
--[[#local type TUnion = {
	@Name = "TUnion",
	Type = "union",
	GetLargestNumber = function=(self)>(TNumber | nil, nil | any),
}]]

do -- TODO, operators is mutated below, need to use upvalue position when analyzing typed arguments
	local operators = {
		["-"] = function(l--[[#: number]])
			return -l
		end,
		["~"] = function(l--[[#: number]])
			return bit.bnot(l)
		end,
	}

	function META:PrefixOperator(op--[[#: keysof<|operators|>]])
		if self:IsLiteral() then
			local num = self.New(operators[op](self:GetData()--[[# as number]])):SetLiteral(true)
			local max = self:GetMax()

			if max then num:SetMax(max:PrefixOperator(op)) end

			return num
		end

		return self.New(nil--[[# as number]]) -- hmm
	end
end

function META:Widen()
	self:SetLiteral(false)
	return self
end

function META:GetHash()
	if self:IsNan() then return nil end

	if self:IsLiteral() then
		if self.Max then
			local hash = self.Max:GetHash()

			if hash and self.Data then
				return "__@type@__" .. self.Type .. self.Data .. ".." .. hash
			end
		end

		return self.Data
	end

	local upvalue = self:GetUpvalue()

	if upvalue then
		return "__@type@__" .. upvalue:GetHash() .. "_" .. self.Type
	end

	return "__@type@__" .. self.Type .. ("_%p"):format(self)
end

function META.Equal(a--[[#: TNumber]], b--[[#: TBaseType]])
	if a.Type ~= b.Type then return false end

	if b:IsLiteralArgument() and a:IsLiteralArgument() then return true end

	if b:IsLiteralArgument() and not a:IsLiteral() then return false end

	if not a:IsLiteral() and not b:IsLiteral() then return true end

	if a:IsLiteral() and b:IsLiteral() then
		if a:IsNan() and b:IsNan() then return true end

		return a:GetData() == b:GetData()
	end

	local a_max = a.Max
	local b_max = b.Max

	if a_max then if b_max then if a_max:Equal(b_max) then return true end end end

	if a_max or b_max then return false end

	if not a:IsLiteral() and not b:IsLiteral() then return true end

	return false
end

function META:CopyLiteralness(num--[[#: TNumber]])
	if num.Type == "number" and num:GetMax() then
		if self:IsSubsetOf(num) then
			if num:IsReferenceArgument() then
				self:SetLiteral(true)
				self:SetReferenceArgument(true)
			end

			self:SetData(num:GetData())
			self:SetMax(num:GetMax())
		end
	else
		if num:IsReferenceArgument() then
			self:SetLiteral(true)
			self:SetReferenceArgument(true)
		else
			self:SetLiteral(num:IsLiteral())
		end
	end
end

function META:Copy()
	local copy = self.New(self:GetData()):SetLiteral(self:IsLiteral())
	local max = self.Max

	if max then copy.Max = max:Copy() end

	copy:CopyInternalsFrom(self)
	return copy--[[# as any]] -- TODO: figure out inheritance
end

function META.IsSubsetOf(a--[[#: TNumber]], b--[[#: TBaseType]])
	if b.Type == "tuple" then b = (b--[[# as any]]):Get(1) end

	if b.Type == "any" then return true end

	if b.Type == "union" then
		return (b--[[# as any]]):IsTargetSubsetOfChild(a--[[# as any]])
	end

	if b.Type ~= "number" then return type_errors.type_mismatch(a, b) end

	if a:IsLiteralArgument() and b:IsLiteralArgument() then return true end

	if b:IsLiteralArgument() and not a:IsLiteral() then
		return type_errors.subset(a, b)
	end

	if a:IsLiteral() and b:IsLiteral() then
		local a_num = a:GetData()--[[# as number]]
		local b_num = b:GetData()--[[# as number]]

		-- compare against literals
		if a.Type == "number" and b.Type == "number" then
			if a:IsNan() and b:IsNan() then return true end
		end

		if a_num == b_num then return true end

		local max = b:GetMaxLiteral()

		if max then if a_num >= b_num and a_num <= max then return true end end

		return type_errors.subset(a, b)
	elseif a:GetData() == nil and b:GetData() == nil then
		-- number contains number
		return true
	elseif a:IsLiteral() and not b:IsLiteral() then
		-- 42 subset of number?
		return true
	elseif not a:IsLiteral() and b:IsLiteral() then
		-- number subset of 42 ?
		return type_errors.subset(a, b)
	end

	-- number == number
	return true
end

function META:IsNan()
	local n = self:GetData()
	return n ~= n
end

function META:__tostring()
	local n = self:GetData()
	local s--[[#: string]]

	if self:IsNan() then s = "nan" end

	s = tostring(n)

	if self:GetMax() then s = s .. ".." .. tostring(self:GetMax()) end

	if self:IsLiteral() then return s end

	if self:IsLiteralArgument() then return "literal number" end

	return "number"
end

META:GetSet("Max", nil--[[# as TNumber | nil]])

function META:SetMax(val--[[#: TBaseType | TUnion]])
	local err

	if val.Type == "union" then
		val, err = (val--[[# as any]]):GetLargestNumber()

		if not val then return val, err end
	end

	if val.Type ~= "number" then
		return type_errors.other({"max must be a number, got ", val})
	end

	if val:IsLiteral() then
		self.Max = val
	else
		self:SetLiteral(false)
		self:SetData(nil)
		self.Max = nil
	end

	return self
end

function META:GetMaxLiteral()
	return self.Max and self.Max:GetData()
end

do
	local operators = {
		[">"] = function(a--[[#: number]], b--[[#: number]])
			return a > b
		end,
		["<"] = function(a--[[#: number]], b--[[#: number]])
			return a < b
		end,
		["<="] = function(a--[[#: number]], b--[[#: number]])
			return a <= b
		end,
		[">="] = function(a--[[#: number]], b--[[#: number]])
			return a >= b
		end,
	}

	local function compare(
		val--[[#: number]],
		min--[[#: number]],
		max--[[#: number]],
		operator--[[#: keysof<|operators|>]]
	)
		local func = operators[operator]

		if func(min, val) and func(max, val) then
			return true
		elseif not func(min, val) and not func(max, val) then
			return false
		end

		return nil
	end

	function META.LogicalComparison(a--[[#: TNumber]], b--[[#: TNumber]], operator--[[#: "=="]])--[[#: boolean | nil]]
		if not a:IsLiteral() or not b:IsLiteral() then return nil end

		if operator == "==" then
			local a_val = a:GetData()
			local b_val = b:GetData()

			if b_val then
				local max = a:GetMax()
				local max = max and max:GetData()

				if max and a_val then
					if b_val >= a_val and b_val <= max then return nil end

					return false
				end
			end

			if a_val then
				local max = b:GetMax()
				local max = max and max:GetData()

				if max and b_val then
					if a_val >= b_val and a_val <= max then return nil end

					return false
				end
			end

			if a_val and b_val then return a_val == b_val end

			return nil
		end

		local a_val = a:GetData()
		local b_val = b:GetData()

		if a_val and b_val then
			local a_max = a:GetMaxLiteral()
			local b_max = b:GetMaxLiteral()

			if a_max then
				if b_max then
					local res_a = compare(b_val, a_val, b_max, operator)
					local res_b = not compare(a_val, b_val, a_max, operator)

					if res_a ~= nil and res_a == res_b then return res_a end

					return nil
				end
			end

			if a_max then
				local res = compare(b_val, a_val, a_max, operator)

				if res == nil then return nil end

				return res
			end

			if operators[operator] then return operators[operator](a_val, b_val) end
		else
			return nil
		end

		if operators[operator] then return nil end

		return type_errors.binary(operator, a, b)
	end

	function META.LogicalComparison2(a--[[#: TNumber]], b--[[#: TNumber]], operator--[[#: keysof<|operators|>]])--[[#: TNumber | nil,TNumber | nil]]
		local a_min = a:GetData()
		local b_min = b:GetData()

		if not a_min then return nil end

		if not b_min then return nil end

		local a_max = a:GetMaxLiteral() or a_min
		local b_max = b:GetMaxLiteral() or b_min
		local a_min_res = nil--[[# as number]]
		local b_min_res = nil--[[# as number]]
		local a_max_res = nil--[[# as number]]
		local b_max_res = nil--[[# as number]]

		if operator == "<" then
			a_min_res = math.min(a_min, b_max)
			a_max_res = math.min(a_max, b_max - 1)
			b_min_res = math.max(a_min, b_max)
			b_max_res = math.max(a_max, b_max)
		end

		if operator == ">" then
			a_min_res = math.max(a_min, b_max + 1)
			a_max_res = math.max(a_max, b_max)
			b_min_res = math.min(a_min, b_max)
			b_max_res = math.min(a_max, b_max)
		end

		local a = META.New(a_min_res):SetLiteral(true):SetMax(META.New(a_max_res):SetLiteral(true))
		local b = META.New(b_min_res):SetLiteral(true):SetMax(META.New(b_max_res):SetLiteral(true))
		return a, b
	end
end

do
	local operators--[[#: {[string] = function=(number, number)>(number)}]] = {
		["+"] = function(l, r)
			return l + r
		end,
		["-"] = function(l, r)
			return l - r
		end,
		["*"] = function(l, r)
			return l * r
		end,
		["/"] = function(l, r)
			return l / r
		end,
		["/idiv/"] = function(l, r)
			return (math.modf(l / r))
		end,
		["%"] = function(l, r)
			return l % r
		end,
		["^"] = function(l, r)
			return l ^ r
		end,
		["&"] = function(l, r)
			return bit.band(l, r)
		end,
		["|"] = function(l, r)
			return bit.bor(l, r)
		end,
		["~"] = function(l, r)
			return bit.bxor(l, r)
		end,
		["<<"] = function(l, r)
			return bit.lshift(l, r)
		end,
		[">>"] = function(l, r)
			return bit.rshift(l, r)
		end,
	}

	function META.ArithmeticOperator(l--[[#: TNumber]], r--[[#: TNumber]], op--[[#: keysof<|operators|>]])--[[#: TNumber]]
		local func = operators[op]

		if l:IsLiteral() and r:IsLiteral() then
			local obj = META.New(func(l:GetData()--[[# as number]], r:GetData()--[[# as number]])):SetLiteral(true)

			if r:GetMax() then
				obj:SetMax(l.ArithmeticOperator(l:GetMax() or l, r:GetMax()--[[# as TNumber]], op))
			end

			if l:GetMax() then
				obj:SetMax(l.ArithmeticOperator(l:GetMax()--[[# as TNumber]], r:GetMax() or r, op))
			end

			return obj
		end

		return META.New()
	end
end

function META.New(data--[[#: number | nil]])
	return setmetatable(
		{
			Data = data--[[# as number]],
			Falsy = false,
			Truthy = true,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
		},
		META
	)
end

local function string_to_integer(str--[[#: string]])
	return assert(loadstring("return " .. str))()--[[# as number]]
end

return {
	Number = META.New,
	LNumber = function(num--[[#: number | nil]])
		return META.New(num):SetLiteral(true)
	end,
	LNumberFromString = function(str--[[#: string]])
		local num = tonumber(str)

		if not num then
			if str:sub(1, 2) == "0b" then
				num = tonumber(str:sub(3), 2)
			elseif str:lower():sub(-3) == "ull" then
				num = string_to_integer(str)
			elseif str:lower():sub(-2) == "ll" then
				num = string_to_integer(str)
			end
		end

		if not num then return nil end

		return META.New(num):SetLiteral(true)
	end,
	TNumber = TNumber,
}