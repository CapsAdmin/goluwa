local type = type
local ipairs = ipairs
local tostring = tostring
local LexicalScope = require("nattlua.analyzer.base.lexical_scope").New
local Table = require("nattlua.types.table").Table
local LString = require("nattlua.types.string").LString
local table = _G.table
return function(META)
	table.insert(META.OnInitialize, function(self)
		self.default_environment = {
			runtime = Table(),
			typesystem = Table(),
		}
		self.environments = {runtime = {}, typesystem = {}}
		self.scope_stack = {}
	end)

	function META:PushScope(scope)
		table.insert(self.scope_stack, self.scope)
		self.scope = scope
		return scope
	end

	function META:CreateAndPushFunctionScope(obj)
		return self:PushScope(LexicalScope(obj:GetScope() or self:GetScope(), obj:GetUpvaluePosition(), obj))
	end

	function META:CreateAndPushModuleScope()
		return self:PushScope(LexicalScope())
	end

	function META:CreateAndPushScope()
		return self:PushScope(LexicalScope(self:GetScope()))
	end

	function META:PopScope()
		local new = table.remove(self.scope_stack)
		local old = self.scope

		if new then self.scope = new end

		return old
	end

	function META:GetScope()
		return self.scope
	end

	function META:GetScopeStack()
		return self.scope_stack
	end

	function META:CloneCurrentScope()
		local scope_copy = self:GetScope():Copy(true)
		local g = self:GetGlobalEnvironment("runtime"):Copy()
		local last_node = self.environment_nodes[#self.environment_nodes]
		self:PopScope()
		self:PopGlobalEnvironment("runtime")
		scope_copy:SetParent(scope_copy:GetParent() or self:GetScope())
		self:PushGlobalEnvironment(last_node, g, "runtime")
		self:PushScope(scope_copy)

		for _, keyval in ipairs(g:GetData()) do
			self:MutateTable(g, keyval.key, keyval.val)
		end

		for _, upvalue in ipairs(scope_copy:GetUpvalues("runtime")) do
			self:MutateUpvalue(upvalue, upvalue:GetValue())
		end

		return scope_copy
	end

	function META:CreateLocalValue(key, obj, const)
		local upvalue = self:GetScope():CreateUpvalue(key, obj, self:GetCurrentAnalyzerEnvironment())
		self:MutateUpvalue(upvalue, obj)
		upvalue:SetImmutable(const)
		return upvalue
	end

	function META:FindLocalUpvalue(key, scope)
		scope = scope or self:GetScope()

		if not scope then return end

		return scope:FindUpvalue(key, self:GetCurrentAnalyzerEnvironment())
	end

	function META:GetLocalOrGlobalValue(key, scope)
		local upvalue = self:FindLocalUpvalue(key, scope)

		if upvalue then
			if self:IsRuntime() then
				return self:GetMutatedUpvalue(upvalue) or upvalue:GetValue()
			end

			return upvalue:GetValue()
		end

		-- look up in parent if not found
		if self:IsRuntime() then
			local g = self:GetGlobalEnvironment(self:GetCurrentAnalyzerEnvironment())
			local val, err = g:Get(key)

			if not val then
				self:PushAnalyzerEnvironment("typesystem")
				local val, err = self:GetLocalOrGlobalValue(key)
				self:PopAnalyzerEnvironment()
				return val, err
			end

			return self:IndexOperator(g, key)
		end

		return self:IndexOperator(self:GetGlobalEnvironment(self:GetCurrentAnalyzerEnvironment()), key)
	end

	function META:SetLocalOrGlobalValue(key, val, scope)
		local upvalue = self:FindLocalUpvalue(key, scope)

		if upvalue then
			if upvalue:IsImmutable() then
				return self:Error({"cannot assign to const variable ", key})
			end

			if not self:MutateUpvalue(upvalue, val) then upvalue:SetValue(val) end

			return upvalue
		end

		local g = self:GetGlobalEnvironment(self:GetCurrentAnalyzerEnvironment())

		if not g then
			self:FatalError("tried to set environment value outside of Push/Pop/Environment")
		end

		if self:IsRuntime() then self:Warning({"_G[\"", key, "\"] = ", val}) end

		self:Assert(self:NewIndexOperator(g, key, val))
		return val
	end

	do -- environment
		function META:SetEnvironmentOverride(node, obj, env)
			node.environments_override = node.environments_override or {}
			node.environments_override[env] = obj
		end

		function META:GetGlobalEnvironmentOverride(node, env)
			if node.environments_override then return node.environments_override[env] end
		end

		function META:SetDefaultEnvironment(obj, env)
			self.default_environment[env] = obj
		end

		function META:GetDefaultEnvironment(env)
			return self.default_environment[env]
		end

		function META:PushGlobalEnvironment(node, obj, env)
			table.insert(self.environments[env], 1, obj)
			node.environments = node.environments or {}
			node.environments[env] = obj
			self.environment_nodes = self.environment_nodes or {}
			table.insert(self.environment_nodes, 1, node)
		end

		function META:PopGlobalEnvironment(env)
			table.remove(self.environment_nodes, 1)
			table.remove(self.environments[env], 1)
		end

		function META:GetGlobalEnvironment(env)
			local g = self.environments[env][1] or self:GetDefaultEnvironment(env)

			if
				self.environment_nodes[1] and
				self.environment_nodes[1].environments_override and
				self.environment_nodes[1].environments_override[env]
			then
				g = self.environment_nodes[1].environments_override[env]
			end

			return g
		end
	end
end
