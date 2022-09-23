local type = type
local tostring = tostring
local setmetatable = _G.setmetatable
local type_errors = require("nattlua.types.error_messages")
local META = dofile("nattlua/types/base.lua")
--[[#local type TBaseType = META.TBaseType]]
--[[#type META.@Name = "TSymbol"]]
--[[#type TSymbol = META.@Self]]
META.Type = "symbol"
META:GetSet("Data", nil--[[# as any]])

function META.Equal(a--[[#: TSymbol]], b--[[#: TBaseType]])
	return a.Type == b.Type and a:GetData() == b:GetData()
end

function META.LogicalComparison(l--[[#: TSymbol]], r--[[#: TBaseType]], op--[[#: string]])
	if op == "==" then
		if l:IsLiteral() and r:IsLiteral() then return l:GetData() == r:GetData() end

		return nil
	end

	return type_errors.binary(op, l, r)
end

function META:GetLuaType()
	return type(self:GetData())
end

function META:__tostring()
	return tostring(self:GetData())
end

function META:GetHash()
	return tostring(self.Data)
end

function META:Copy()
	local copy = self.New(self:GetData())
	copy:CopyInternalsFrom(self)
	return copy
end

function META:CanBeNil()
	return self:GetData() == nil
end

function META.IsSubsetOf(a--[[#: TSymbol]], b--[[#: TBaseType]])
	if b.Type == "tuple" then b = b:Get(1) end

	if b.Type == "any" then return true end

	if b.Type == "union" then return b:IsTargetSubsetOfChild(a--[[# as any]]) end

	if b.Type ~= "symbol" then return type_errors.type_mismatch(a, b) end

	local b = b--[[# as TSymbol]]

	if a:GetData() ~= b:GetData() then return type_errors.value_mismatch(a, b) end

	return true
end

function META:IsFalsy()
	return not self.Data
end

function META:IsTruthy()
	return not not self.Data
end

function META.New(data--[[#: any]])
	local self = setmetatable(
		{
			Data = data,
			Falsy = false,
			Truthy = false,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
		},
		META
	)
	self:SetLiteral(true)
	return self
end

local Symbol = META.New
return {
	Symbol = Symbol,
	Nil = function()
		return Symbol(nil)
	end,
	True = function()
		return Symbol(true)
	end,
	False = function()
		return Symbol(false)
	end,
}