local runtime_syntax = require("nattlua.syntax.runtime")
local NodeToString = require("nattlua.types.string").NodeToString
local LNumber = require("nattlua.types.number").LNumber
local LNumberFromString = require("nattlua.types.number").LNumberFromString
local Any = require("nattlua.types.any").Any
local True = require("nattlua.types.symbol").True
local False = require("nattlua.types.symbol").False
local Nil = require("nattlua.types.symbol").Nil
local LString = require("nattlua.types.string").LString
local String = require("nattlua.types.string").String
local Number = require("nattlua.types.number").Number
local Boolean = require("nattlua.types.union").Boolean
local table = _G.table

local function lookup_value(self, node)
	local errors = {}
	local key = NodeToString(node)
	local obj, err = self:GetLocalOrGlobalValue(key)

	if self:IsTypesystem() then
		-- we fallback to runtime if we can't find the value in the typesystem
		if not obj then
			table.insert(errors, err)
			self:PushAnalyzerEnvironment("runtime")
			obj, err = self:GetLocalOrGlobalValue(key)
			self:PopAnalyzerEnvironment("runtime")

			-- when in the typesystem we want to see the objects contract, not its runtime value
			if obj and obj:GetContract() then obj = obj:GetContract() end
		end

		if not obj then
			table.insert(errors, err)
			self:Error(errors)
			return Nil()
		end
	else
		if not obj or (obj.Type == "symbol" and obj:GetData() == nil) then
			self:PushAnalyzerEnvironment("typesystem")
			local objt, errt = self:GetLocalOrGlobalValue(key)
			self:PopAnalyzerEnvironment()

			if objt then obj, err = objt, errt end
		end

		if not obj then
			self:Warning(err)
			obj = Any()
		end
	end

	local obj = self:GetTrackedUpvalue(obj) or obj

	if obj:GetUpvalue() then self:GetScope():AddDependency(obj:GetUpvalue()) end

	return obj
end

local function is_primitive(val)
	return val == "string" or
		val == "number" or
		val == "boolean" or
		val == "true" or
		val == "false" or
		val == "nil"
end

return {
	AnalyzeAtomicValue = function(self, node)
		local value = node.value.value
		local type = runtime_syntax:GetTokenType(node.value)

		if type == "keyword" then
			if value == "nil" then
				return Nil()
			elseif value == "true" then
				return True()
			elseif value == "false" then
				return False()
			end
		elseif node.force_upvalue then
			return lookup_value(self, node)
		elseif value == "..." then
			return lookup_value(self, node)
		elseif type == "letter" and node.standalone_letter then
			-- standalone_letter means it's the first part of something, either >true<, >foo<.bar, >foo<()
			if self:IsTypesystem() then
				local current_table = self:GetCurrentType("table")

				if current_table then
					if value == "self" then
						return current_table
					elseif
						self.left_assigned and
						self.left_assigned:GetData() == value and
						not is_primitive(value)
					then
						return current_table
					end
				end

				if value == "any" then
					return Any()
				elseif value == "inf" then
					return LNumber(math.huge)
				elseif value == "nan" then
					return LNumber(math.abs(0 / 0))
				elseif value == "string" then
					return String()
				elseif value == "number" then
					return Number()
				elseif value == "boolean" then
					return Boolean()
				end
			end

			return lookup_value(self, node)
		elseif type == "number" then
			local num = LNumberFromString(value)

			if not num then
				self:Error("unable to convert " .. value .. " to number")
				num = Number()
			end

			return num
		elseif type == "string" then
			return LString(node.value.string_value)
		elseif type == "letter" then
			return LString(value)
		end

		self:FatalError("unhandled value type " .. type .. " " .. node:Render())
	end,
}
