--ANALYZE
local tostring = tostring
local setmetatable = _G.setmetatable
local table = _G.table
local ipairs = _G.ipairs
local Nil = require("nattlua.types.symbol").Nil
local True = require("nattlua.types.symbol").True
local False = require("nattlua.types.symbol").False
local type_errors = require("nattlua.types.error_messages")

--[[#local type { TNumber } = require("nattlua.types.number")]]

local META = dofile("nattlua/types/base.lua")
--[[#local type TBaseType = META.TBaseType]]
--[[#type META.@Name = "TUnion"]]
--[[#type TUnion = META.@Self]]
--[[#type TUnion.Data = List<|TBaseType|>]]
--[[#type TUnion.suppress = boolean]]
--[[#type TUnion.falsy_disabled = List<|TBaseType|> | nil]]
META.Type = "union"

function META:GetHash()
	return tostring(self)
end

function META.Equal(a--[[#: TUnion]], b--[[#: TBaseType]])
	if a.suppress then return true end

	if b.Type ~= "union" and #a.Data == 1 and a.Data[1] then
		return a.Data[1]:Equal(b)
	end

	if a.Type ~= b.Type then return false end

	local b = b--[[# as TUnion]]

	if a:IsEmpty() and b:IsEmpty() then return true end

	if #a.Data ~= #b.Data then return false end

	for i = 1, #a.Data do
		local ok = false
		local a = a.Data[i]--[[# as TBaseType]]

		for i = 1, #b.Data do
			local b = b.Data[i]--[[# as TBaseType]]
			a.suppress = true--[[# as boolean]]
			ok = a:Equal(b)
			a.suppress = false--[[# as boolean]]

			if ok then break end
		end

		if not ok then
			a.suppress = false--[[# as boolean]]
			return false
		end
	end

	return true
end

local sort = function(a--[[#: string]], b--[[#: string]])
	return a < b
end

function META:__tostring()
	if self.suppress then return "current_union" end

	local s = {}
	self.suppress = true

	for _, v in ipairs(self.Data) do
		table.insert(s, tostring(v))
	end

	if not s[1] then
		self.suppress = false
		return "|"
	end

	self.suppress = false
	table.sort(s, sort)
	return table.concat(s, " | ")
end

function META:AddType(e--[[#: TBaseType]])
	if e.Type == "union" then
		for _, v in ipairs(e.Data) do
			self:AddType(v)
		end

		return self
	end

	for _, v in ipairs(self.Data) do
		if v:Equal(e) then
			if
				e.Type ~= "function" or
				e:GetContract() or
				(
					e:GetFunctionBodyNode() and
					(
						e:GetFunctionBodyNode() == v:GetFunctionBodyNode()
					)
				)
			then
				return self
			end
		end
	end

	if e.Type == "string" or e.Type == "number" then
		local sup = e

		for i = #self.Data, 1, -1 do
			local sub = self.Data[i]--[[# as TBaseType]] -- TODO, prove that the for loop will always yield TBaseType?
			if sub.Type == sup.Type then
				if sub:IsSubsetOf(sup) then table.remove(self.Data, i) end
			end
		end
	end

	table.insert(self.Data, e)
	return self
end

function META:GetData()
	return self.Data
end

function META:GetLength()
	return #self.Data
end

function META:RemoveType(e--[[#: TBaseType]])
	if e.Type == "union" then
		for i, v in ipairs(e.Data) do
			self:RemoveType(v)
		end

		return self
	end

	for i, v in ipairs(self.Data) do
		if v:Equal(e) then
			table.remove(self.Data, i)

			break
		end
	end

	return self
end

function META:Clear()
	self.Data = {}
end

function META:HasTuples()
	for _, obj in ipairs(self.Data) do
		if obj.Type == "tuple" then return true end
	end

	return false
end

function META:GetAtIndex(i--[[#: number]])
	assert(type(i) == "number")

	if not self:HasTuples() then return self end

	local val--[[#: any]]
	local errors = {}

	for _, obj in ipairs(self.Data) do
		if obj.Type == "tuple" then
			local found, err = obj:Get(i)

			if found then
				if val then val = self.New({val, found}) else val = found end
			else
				if val then val = self.New({val, Nil()}) else val = Nil() end

				table.insert(errors, err)
			end
		else
			if val then
				-- a non tuple in the union would be treated as a tuple with the value repeated
				val = self.New({val--[[# as any]], obj})
			elseif i == 1 then
				val = obj
			else
				val = Nil()
			end
		end
	end

	if not val then return false, errors end

	return val
end

function META:Get(key--[[#: TBaseType]])
	local errors = {}

	for _, obj in ipairs(self.Data) do
		local ok, reason = key:IsSubsetOf(obj)

		if ok then return obj end

		table.insert(errors, reason)
	end

	return type_errors.other(errors)
end

function META:IsEmpty()
	return self.Data[1] == nil
end

function META:GetTruthy()
	local copy = self:Copy()

	for _, obj in ipairs(self.Data) do
		if not obj:IsTruthy() then copy:RemoveType(obj) end
	end

	return copy
end

function META:GetFalsy()
	local copy = self:Copy()

	for _, obj in ipairs(self.Data) do
		if not obj:IsFalsy() then copy:RemoveType(obj) end
	end

	return copy
end

function META:IsType(typ--[[#: string]])
	assert(type(typ) == "string")

	if self:IsEmpty() then return false end

	for _, obj in ipairs(self.Data) do
		if obj.Type ~= typ then return false end
	end

	return true
end

function META:IsTypeExceptNil(typ--[[#: string]])
	assert(type(typ) == "string")

	if self:IsEmpty() then return false end

	for _, obj in ipairs(self.Data) do
		if obj.Type == "symbol" and obj.Data == nil then

		else
			if obj.Type ~= typ then return false end
		end
	end

	return true
end

function META:HasType(typ--[[#: string]])
	assert(type(typ) == "string")
	return self:GetType(typ) ~= false
end

function META:CanBeNil()
	for _, obj in ipairs(self.Data) do
		if obj.Type == "symbol" and obj:GetData() == nil then return true end
	end

	return false
end

function META:GetType(typ--[[#: string]])
	assert(type(typ) == "string")

	for _, obj in ipairs(self.Data) do
		if obj.Type == typ then return obj end
	end

	return false
end

function META:IsTargetSubsetOfChild(target--[[#: TBaseType]])
	local errors = {}

	for _, obj in ipairs(self:GetData()) do
		local ok, reason = target:IsSubsetOf(obj)

		if ok then return true end

		table.insert(errors, reason)
	end

	return type_errors.subset(target, self, errors)
end

function META.IsSubsetOf(a--[[#: TUnion]], b--[[#: TBaseType]])
	if b.Type == "tuple" then b = b:Get(1) end

	if b.Type ~= "union" then return a:IsSubsetOf(META.New({b})) end

	for _, a_val in ipairs(a.Data) do
		if a_val.Type == "any" then return true end
	end

	for _, b_val in ipairs(b.Data) do
		if b_val.Type == "any" then return true end
	end

	if a:IsEmpty() then return type_errors.subset(a, b, "union is empty") end

	for _, a_val in ipairs(a.Data) do
		local b_val, reason = b:Get(a_val)

		if not b_val then return type_errors.missing(b, a_val, reason) end

		local ok, reason = a_val:IsSubsetOf(b_val)

		if not ok then return type_errors.subset(a_val, b_val, reason) end
	end

	return true
end

function META:Union(union--[[#: TUnion]])
	assert(union.Type == "union")
	local copy = self:Copy()

	for _, e in ipairs(union.Data) do
		copy:AddType(e)
	end

	return copy
end

function META:Copy(map--[[#: Map<|any, any|> | nil]], copy_tables--[[#: nil | boolean]])
	map = map or {}
	local copy = META.New()
	map[self] = map[self] or copy

	for _, e in ipairs(self.Data) do
		if e.Type == "table" and not copy_tables then
			copy:AddType(e)
		else
			copy:AddType(e:Copy(map, copy_tables))
		end
	end

	copy:CopyInternalsFrom(self)
	return copy
end

function META:IsTruthy()
	for _, v in ipairs(self.Data) do
		if v:IsTruthy() then return true end
	end

	return false
end

function META:IsFalsy()
	for _, v in ipairs(self.Data) do
		if v:IsFalsy() then return true end
	end

	return false
end

function META:DisableFalsy()
	local found = {}

	for _, v in ipairs(self.Data) do
		if v:IsCertainlyFalse() then table.insert(found, v) end
	end

	for _, v in ipairs(found) do
		self:RemoveType(v)
	end

	self.falsy_disabled = found
	return self
end

function META:EnableFalsy()
	-- never called
	if not self.falsy_disabled then return end

	for _, v in ipairs(self.falsy_disabled) do
		self:AddType(v)
	end
end

function META:SetMax(val--[[#: TNumber]])
	-- never called
	local copy = self:Copy()

	for _, e in ipairs(copy.Data) do
		e:SetMax(val)
	end

	return copy
end

function META:IsLiteral()
	for _, obj in ipairs(self:GetData()) do
		if not obj:IsLiteral() then return false end
	end

	return true
end

function META:GetLargestNumber()
	-- never called
	if #self:GetData() == 0 then return type_errors.other({"union is empty"}) end

	local max = {}

	for _, obj in ipairs(self:GetData()) do
		if obj.Type ~= "number" then
			return type_errors.other({"union must contain numbers only", self})
		end

		if obj:IsLiteral() then table.insert(max, obj) else return obj end
	end

	table.sort(max, function(a, b)
		return a:GetData() > b:GetData()
	end)

	return max[1]
end

function META.New(data--[[#: nil | List<|TBaseType|>]])
	local self = setmetatable(
		{
			Data = {},
			Falsy = false,
			Truthy = false,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
			suppress = false,
			falsy_disabled = nil,
		},
		META
	)

	if data then for _, v in ipairs(data) do
		self:AddType(v)
	end end

	return self
end

return {
	Union = META.New,
	Nilable = function(typ--[[: TBaseType]] )
		return META.New({typ, Nil()})
	end,
	Boolean = function()
		return META.New({True(), False()})
	end,
}