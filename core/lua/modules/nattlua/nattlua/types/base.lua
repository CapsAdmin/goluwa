local assert = _G.assert
local tostring = _G.tostring
local setmetatable = _G.setmetatable
local type_errors = require("nattlua.types.error_messages")
local class = require("nattlua.other.class")
local META = class.CreateTemplate("base")
--[[#type META.Type = string]]
--[[#type META.@Self = {}]]
--[[#local type TBaseType = META.@Self]]
--[[#type TBaseType.@Name = "TBaseType"]]
--[[#type META.Type = string]]
--[[#type TBaseType.Name = string | nil]]
--[[#type TBaseType.parent = TBaseType | nil]]
META:GetSet("AnalyzerEnvironment", nil--[[# as nil | "runtime" | "typesystem"]])

function META.Equal(a--[[#: TBaseType]], b--[[#: TBaseType]]) --error("nyi " .. a.Type .. " == " .. b.Type)
end

function META:CanBeNil()
	return false
end

META:GetSet("Data", nil--[[# as nil | any]])

function META:GetLuaType()
	local contract = self:GetContract()

	if
		contract and
		contract.TypeOverride and
		contract.TypeOverride.Type == "string" and
		contract.TypeOverride.Data
	then
		return contract.TypeOverride.Data
	end

	return self.TypeOverride and
		self.TypeOverride.Type == "string" and
		self.TypeOverride.Data or
		self.Type
end

do
	function META:IsUncertain()
		return self:IsTruthy() and self:IsFalsy()
	end

	function META:IsCertainlyFalse()
		return self:IsFalsy() and not self:IsTruthy()
	end

	function META:IsCertainlyTrue()
		return self:IsTruthy() and not self:IsFalsy()
	end

	function META:GetTruthy()
		if self:IsTruthy() then return self end

		return nil
	end

	function META:GetFalsy()
		if self:IsFalsy() then return self end

		return nil
	end

	META:IsSet("Falsy", false--[[# as boolean]])
	META:IsSet("Truthy", false--[[# as boolean]])
end

do
	function META:Copy()
		return self
	end

	function META:CopyInternalsFrom(obj--[[#: mutable TBaseType]])
		self:SetLiteral(obj:IsLiteral())
		self:SetContract(obj:GetContract())
		self:SetName(obj:GetName())
		self:SetMetaTable(obj:GetMetaTable())
		self:SetAnalyzerEnvironment(obj:GetAnalyzerEnvironment())
		self:SetTypeOverride(obj:GetTypeOverride())
		self:SetLiteralArgument(obj:IsLiteralArgument())
		self:SetReferenceArgument(obj:IsReferenceArgument())
	end
end

do -- token, expression and statement association
	META:GetSet("Upvalue", nil--[[# as nil | any]])
	META:GetSet("Node", nil--[[# as nil | any]])

	function META:SetNode(node--[[#: nil | any]], is_local--[[#: nil | boolean]])
		self.Node = node
		return self
	end
end

do -- comes from tbl.@Name = "my name"
	META:GetSet("Name", nil--[[# as nil | TBaseType]])

	function META:SetName(name--[[#: TBaseType | nil]])
		if name then assert(name:IsLiteral()) end

		self.Name = name
	end
end

do -- comes from tbl.@TypeOverride = "my name"
	META:GetSet("TypeOverride", nil--[[# as nil | TBaseType]])

	function META:SetTypeOverride(name--[[#: nil | TBaseType]])
		self.TypeOverride = name
	end
end

do
	--[[#type TBaseType.disabled_unique_id = number | nil]]
	META:GetSet("UniqueID", nil--[[# as nil | number]])
	local ref = 0

	function META:MakeUnique(b--[[#: boolean]])
		if b then
			self.UniqueID = ref
			ref = ref + 1
		else
			self.UniqueID = nil
		end

		return self
	end

	function META:IsUnique()
		return self.UniqueID ~= nil
	end

	function META:DisableUniqueness()
		self.disabled_unique_id = self.UniqueID
		self.UniqueID = nil
	end

	function META:EnableUniqueness()
		self.UniqueID = self.disabled_unique_id
	end

	function META:GetHash()
		return self.UniqueID
	end

	function META.IsSameUniqueType(a--[[#: TBaseType]], b--[[#: TBaseType]])
		if a.UniqueID and not b.UniqueID then
			return type_errors.other({a, "is a unique type"})
		end

		if a.UniqueID ~= b.UniqueID then
			return type_errors.other({a, "is not the same unique type as ", a})
		end

		return true
	end
end

do
	META:IsSet("LiteralArgument", false--[[# as boolean]])
	META:IsSet("ReferenceArgument", false--[[# as boolean]])
end

do
	META:IsSet("Literal", false--[[# as boolean]])

	function META:CopyLiteralness(obj--[[#: TBaseType]])
		if obj:IsReferenceArgument() then
			self:SetLiteral(true)
			self:SetReferenceArgument(true)
		else
			self:SetLiteral(obj:IsLiteral())
		end
	end
end

do -- operators
	function META:Set(key--[[#: TBaseType | nil]], val--[[#: TBaseType | nil]])
		return type_errors.other(
			{
				"undefined set: ",
				self,
				"[",
				key,
				"] = ",
				val,
				" on type ",
				self.Type,
			}
		)
	end

	function META:Get(key--[[#: boolean]])
		return type_errors.other(
			{
				"undefined get: ",
				self,
				"[",
				key,
				"] on type ",
				self.Type,
			}
		)
	end

	function META:PrefixOperator(op--[[#: string]])
		return type_errors.other({"no operator ", op, " on ", self})
	end
end

do
	META:GetSet("Parent", nil--[[# as TBaseType | nil]])

	function META:SetParent(parent--[[#: TBaseType | nil]])
		if parent then
			if parent ~= self then self.Parent = parent end
		else
			self.Parent = nil
		end
	end

	function META:GetRoot()
		local parent = self
		local done = {}

		while true do
			if not parent.Parent or done[parent] then break end

			done[parent] = true
			parent = parent.Parent--[[# as any]]
		end

		return parent
	end
end

do -- contract
	function META:Seal()
		self:SetContract(self:GetContract() or self:Copy())
	end

	META:GetSet("Contract", nil--[[# as TBaseType | nil]])
end

do
	META:GetSet("MetaTable", nil--[[# as TBaseType | nil]])

	function META:GetMetaTable()
		local contract = self:GetContract()

		if contract and contract.MetaTable then return contract.MetaTable end

		return self.MetaTable
	end
end

function META:Widen()
	self:SetLiteral(false)
	return self
end

function META:GetFirstValue()
	-- for tuples, this would return the first value in the tuple
	return self
end

function META.LogicalComparison(l--[[#: TBaseType]], r--[[#: TBaseType]], op--[[#: string]])
	return type_errors.binary(op, l, r)
end

function META.New()
	return setmetatable({}--[[# as META.@Self]], META)
end

--[[#type META.TBaseType = any]] --copy<|META|>.@Self
return META