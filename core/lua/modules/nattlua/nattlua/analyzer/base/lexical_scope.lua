local ipairs = ipairs
local pairs = pairs
local error = error
local tostring = tostring
local assert = assert
local setmetatable = setmetatable
local Union = require("nattlua.types.union").Union
local table_insert = table.insert
local table = _G.table
local type = _G.type
local class = require("nattlua.other.class")
local Upvalue = require("nattlua.analyzer.base.upvalue").New
local META = class.CreateTemplate("lexical_scope")

do
	function META:IsUncertain()
		return self:IsTruthy() and self:IsFalsy()
	end

	function META:IsCertain()
		return not self:IsUncertain()
	end

	function META:IsCertainlyFalse()
		return self:IsFalsy() and not self:IsTruthy()
	end

	function META:IsCertainlyTrue()
		return self:IsTruthy() and not self:IsFalsy()
	end

	META:IsSet("Falsy", false--[[# as boolean]])
	META:IsSet("Truthy", false--[[# as boolean]])
end

META:IsSet("ConditionalScope", false--[[# as boolean]])
META:GetSet("Parent", nil--[[# as boolean]])
META:GetSet("Children", nil--[[# as boolean]])

function META:SetParent(parent)
	self.Parent = parent

	if parent then table_insert(parent:GetChildren(), self) end
end

function META:GetMemberInParents(what)
	local scope = self

	while true do
		if scope[what] then return scope[what], scope end

		scope = scope:GetParent()

		if not scope then break end
	end

	return nil
end

function META:AddTrackedObject(val)
	local scope = self:GetNearestFunctionScope()
	scope.TrackedObjects = scope.TrackedObjects or {}
	table.insert(scope.TrackedObjects, val)
end

function META:AddDependency(val)
	self.dependencies = self.dependencies or {}
	self.dependencies[val] = val
end

function META:GetDependencies()
	local out = {}

	if self.dependencies then
		for val in pairs(self.dependencies) do
			table.insert(out, val)
		end
	end

	return out
end

function META:FindUpvalue(key, env)
	if type(key) == "table" and key.Type == "string" and key:IsLiteral() then
		key = key:GetData()
	end

	local scope = self
	local prev_scope

	for _ = 1, 1000 do
		if not scope then return end

		local upvalue = scope.upvalues[env].map[key]

		if upvalue then
			local upvalue_position = prev_scope and prev_scope.upvalue_position

			if upvalue_position then
				if upvalue:GetPosition() >= upvalue_position then
					local upvalue = upvalue:GetShadow()

					while upvalue do
						if upvalue:GetPosition() <= upvalue_position then return upvalue end

						upvalue = upvalue:GetShadow()
					end
				end
			end

			return upvalue
		end

		prev_scope = scope
		scope = scope:GetParent()
	end

	error("this should never happen")
end

function META:CreateUpvalue(key, obj, env)
	local shadow

	if key ~= "..." and env == "runtime" then
		shadow = self.upvalues[env].map[key]
	end

	local upvalue = Upvalue(obj)
	upvalue:SetKey(key)
	upvalue:SetShadow(shadow)
	upvalue:SetPosition(#self.upvalues[env].list)
	upvalue:SetScope(self)
	table_insert(self.upvalues[env].list, upvalue)
	self.upvalues[env].map[key] = upvalue
	return upvalue
end

function META:GetUpvalues(type--[[#: "runtime" | "typesystem"]])
	return self.upvalues[type].list
end

function META:Copy()
	local copy = self.New()

	if self.upvalues.typesystem then
		for _, upvalue in ipairs(self.upvalues.typesystem.list) do
			copy:CreateUpvalue(upvalue.key, upvalue:GetValue(), "typesystem")
		end
	end

	if self.upvalues.runtime then
		for _, upvalue in ipairs(self.upvalues.runtime.list) do
			copy:CreateUpvalue(upvalue.key, upvalue:GetValue(), "runtime")
		end
	end

	copy.returns = self.returns
	copy:SetParent(self:GetParent())
	copy:SetConditionalScope(self:IsConditionalScope())
	return copy
end

META:GetSet("TrackedUpvalues")
META:GetSet("TrackedTables")

function META:TracksSameAs(scope, obj)
	local upvalues_a, tables_a = self:GetTrackedUpvalues(), self:GetTrackedTables()
	local upvalues_b, tables_b = scope:GetTrackedUpvalues(), scope:GetTrackedTables()

	if not upvalues_a or not upvalues_b then return false end

	if not tables_a or not tables_b then return false end

	for i, data_a in ipairs(upvalues_a) do
		for i, data_b in ipairs(upvalues_b) do
			if data_a.upvalue == data_b.upvalue then return true end
		end
	end

	for i, data_a in ipairs(tables_a) do
		for i, data_b in ipairs(tables_b) do
			if data_a.obj == data_b.obj and data_a.obj == obj then return true end
		end
	end

	return false
end

function META:FindResponsibleConditionalScopeFromUpvalue(upvalue)
	local scope = self

	while true do
		local upvalues = scope:GetTrackedUpvalues()

		if upvalues then
			for i, data in ipairs(upvalues) do
				if data.upvalue == upvalue then return scope, data end
			end
		end

		-- find in siblings too, if they have returned
		-- ideally when cloning a scope, the new scope should be 
		-- inside of the returned scope, then we wouldn't need this code
		for _, child in ipairs(scope:GetChildren()) do
			if child ~= scope and self:IsPartOfTestStatementAs(child) then
				local upvalues = child:GetTrackedUpvalues()

				if upvalues then
					for i, data in ipairs(upvalues) do
						if data.upvalue == upvalue then return child, data end
					end
				end
			end
		end

		scope = scope:GetParent()

		if not scope then return end
	end

	return nil
end

META:GetSet("PreviousConditionalSibling")
META:GetSet("NextConditionalSibling")
META:IsSet("ElseConditionalScope")
META:IsSet("LoopScope")

function META:SetStatement(statement)
	self.statement = statement
end

function META:SetLoopIteration(i)
	self.loop_iteration = i
end

function META:GetStatementType()
	return self.statement and self.statement.kind
end

function META.IsPartOfTestStatementAs(a, b)
	local yes = a:GetStatementType() == "if" and
		b:GetStatementType() == "if" and
		a.statement == b.statement

	if yes then
		local a_iteration = a:GetMemberInParents("loop_iteration")
		local b_iteration = b:GetMemberInParents("loop_iteration")
		return a_iteration == b_iteration
	end

	return yes
end

function META:FindFirstConditionalScope()
	local obj, scope = self:GetMemberInParents("ConditionalScope")
	return scope
end

function META:Contains(scope)
	if scope == self then return true end

	local parent = scope

	for i = 1, 1000 do
		if not parent then break end

		if parent == self then return true end

		parent = parent:GetParent()
	end

	return false
end

function META:GetRoot()
	local parent = self

	for i = 1, 1000 do
		if not parent:GetParent() then break end

		parent = parent:GetParent()
	end

	return parent
end

do
	function META:MakeFunctionScope(node)
		self.returns = {}
		self.node = node
	end

	function META:IsFunctionScope()
		return self.returns ~= nil
	end

	function META:CollectOutputSignatures(node, types)
		table.insert(self:GetNearestFunctionScope().returns, {node = node, types = types})
	end

	function META:DidCertainReturn()
		return self.certain_return ~= nil
	end

	function META:ClearCertainReturn()
		self.certain_return = nil
	end

	function META:CertainReturn()
		local scope = self

		while true do
			scope.certain_return = true

			if scope.returns then break end

			scope = scope:GetParent()

			if not scope then break end
		end
	end

	function META:UncertainReturn()
		self:GetNearestFunctionScope().uncertain_function_return = true
	end

	function META:GetNearestFunctionScope()
		local ok, scope = self:GetMemberInParents("returns")

		if ok then return scope end

		return self
	end

	function META:GetNearestLoopScope()
		local ok, scope = self:GetMemberInParents("LoopScope")

		if ok then return scope end

		return self
	end

	function META:GetOutputSignature()
		return self.returns
	end

	function META:ClearCertainOutputSignatures()
		self.returns = {}
	end

	function META:IsCertainFromScope(from)
		return not self:IsUncertainFromScope(from)
	end

	function META:IsUncertainFromScope(from)
		if from == self then return false end

		local scope = self

		if self:IsPartOfTestStatementAs(from) then return true end

		while true do
			if scope == from then break end

			if scope:IsFunctionScope() then
				if
					scope.node and
					scope.node:GetLastType() and
					scope.node:GetLastType().Type == "function" and
					not scope:Contains(from)
				then
					return not scope.node:GetLastType():IsCalled()
				end
			end

			if scope:IsTruthy() and scope:IsFalsy() then
				if scope:Contains(from) then return false end

				return true, scope
			end

			scope = scope:GetParent()

			if not scope then break end
		end

		return false
	end
end

function META:__tostring()
	local x = 1

	do
		local scope = self

		while scope:GetParent() do
			x = x + 1
			scope = scope:GetParent()
		end
	end

	local y = 1

	if self:GetParent() then
		for i, v in ipairs(self:GetParent():GetChildren()) do
			if v == self then
				y = i

				break
			end
		end
	end

	local s = "scope[" .. x .. "," .. y .. "]" .. "[" .. (
			self:IsUncertain() and
			"uncertain" or
			"certain"
		) .. "]"

	if self.node then s = s .. tostring(self.node) end

	return s
end

function META:DumpScope()
	local s = {}

	for i, v in ipairs(self.upvalues.runtime.list) do
		table.insert(s, "local " .. tostring(v.key) .. " = " .. tostring(v))
	end

	for i, v in ipairs(self.upvalues.typesystem.list) do
		table.insert(s, "local type " .. tostring(v.key) .. " = " .. tostring(v))
	end

	for i, v in ipairs(self:GetChildren()) do
		table.insert(s, "do\n" .. v:DumpScope() .. "\nend\n")
	end

	return table.concat(s, "\n")
end

local ref = 0

function META.New(parent, upvalue_position, obj)
	ref = ref + 1
	local scope = {
		obj = obj,
		ref = ref,
		Children = {},
		upvalue_position = upvalue_position,
		upvalues = {
			runtime = {
				list = {},
				map = {},
			},
			typesystem = {
				list = {},
				map = {},
			},
		},
	}
	setmetatable(scope, META)
	scope:SetParent(parent)
	return scope
end

return META