local ipairs = ipairs
local Any = require("nattlua.types.any").Any
local Nil = require("nattlua.types.symbol").Nil
local Tuple = require("nattlua.types.tuple").Tuple
local Union = require("nattlua.types.union").Union
-- this turns out to be really hard so I'm trying 
-- naive approaches while writing tests
return function(META)
	function META:AnalyzeStatements(statements)
		for _, statement in ipairs(statements) do
			self:AnalyzeStatement(statement)

			if self:DidCertainBreak() then break end

			if self._continue_ then return end

			if self:GetScope():DidCertainReturn() then
				self:GetScope():ClearCertainReturn()
				return
			end
		end

		if self:GetScope().uncertain_function_return == nil then
			self:GetScope().uncertain_function_return = false
		end

		if statements[1] then
			self:GetScope().missing_return = statements[#statements].kind ~= "return"
		else
			self:GetScope().missing_return = true
		end
	end

	function META:Break()
		local scope = self:GetScope()
		self.break_out_scope = scope
		self:ApplyMutationsAfterReturn(
			scope,
			scope:GetNearestFunctionScope(),
			true,
			scope:GetTrackedUpvalues(),
			scope:GetTrackedTables()
		)
	end

	function META:DidCertainBreak()
		return self.break_out_scope and self.break_out_scope:IsCertain()
	end

	function META:DidUncertainBreak()
		return self.break_out_scope and self.break_out_scope:IsUncertain()
	end

	function META:ClearBreak()
		self.break_out_scope = nil
	end

	function META:AnalyzeStatementsAndCollectOutputSignatures(statement)
		local scope = self:GetScope()
		scope:MakeFunctionScope(statement)
		self:AnalyzeStatements(statement.statements)

		if scope.missing_return and self:IsMaybeReachable() then
			self:Return(statement, {Nil()})
		end

		local union = Union({})

		for _, ret in ipairs(scope:GetOutputSignature()) do
			if #ret.types == 1 then
				union:AddType(ret.types[1])
			elseif #ret.types == 0 then
				local tup = Tuple({Nil()})
				union:AddType(tup)
			else
				local tup = Tuple(ret.types)
				union:AddType(tup)
			end
		end

		scope:ClearCertainOutputSignatures()

		if #union:GetData() == 1 then return union:GetData()[1] end

		return union
	end

	function META:ThrowSilentError(assert_expression)
		if assert_expression and assert_expression:IsCertainlyTrue() then return end

		for _, frame in ipairs(self:GetCallStack()) do
			local function_scope = frame.scope:GetNearestFunctionScope()

			if not assert_expression or assert_expression:IsCertainlyTrue() then
				function_scope.lua_silent_error = function_scope.lua_silent_error or {}
				table.insert(function_scope.lua_silent_error, 1, self:GetScope())
				frame.scope:UncertainReturn()
			end

			if assert_expression and assert_expression:IsTruthy() then
				-- track the assertion expression
				local upvalues

				if frame.scope:GetTrackedUpvalues() then
					upvalues = {}

					for _, a in ipairs(frame.scope:GetTrackedUpvalues()) do
						for _, b in ipairs(self:GetTrackedUpvalues()) do
							if a.upvalue == b.upvalue then table.insert(upvalues, a) end
						end
					end
				end

				local tables

				if frame.scope:GetTrackedTables() then
					tables = {}

					for _, a in ipairs(frame.scope:GetTrackedTables()) do
						for _, b in ipairs(self:GetTrackedTables()) do
							if a.obj == b.obj then table.insert(tables, a) end
						end
					end
				end

				self:ApplyMutationsAfterReturn(frame.scope, frame.scope, true, upvalues, tables)
				return
			end

			self:ApplyMutationsAfterReturn(
				frame.scope,
				function_scope,
				true,
				frame.scope:GetTrackedUpvalues(),
				frame.scope:GetTrackedTables()
			)
		end
	end

	function META:AssertError(obj, msg, level, no_report)
		-- track "if x then" which has no binary or prefix operators
		if obj.Type == "union" then
			self:TrackUpvalueUnion(obj, obj:GetTruthy(), obj:GetFalsy())
		else
			self:TrackUpvalue(obj)
		end

		self.lua_assert_error_thrown = {
			msg = msg,
			obj = obj,
		}

		if obj:IsTruthy() then
			self:GetScope():UncertainReturn()
		else
			self:GetScope():CertainReturn()
		end

		local old = {}

		for i, upvalue in ipairs(self:GetScope().upvalues.runtime.list) do
			old[i] = upvalue
		end

		self:ApplyMutationsAfterReturn(
			self:GetScope(),
			self:GetScope():GetNearestFunctionScope(),
			false,
			self:GetTrackedUpvalues(old),
			self:GetTrackedTables()
		)

		if not no_report then
			self.current_expression = self:GetCallFrame(level).call_node
			self:Error(msg)
		end
	end

	function META:ThrowError(msg, obj, level)
		self.lua_error_thrown = msg
		self.current_expression = self:GetCallFrame(level).call_node
		self:Error(msg)
	end

	function META:GetThrownErrorMessage()
		return self.lua_error_thrown or
			self.lua_assert_error_thrown and
			self.lua_assert_error_thrown.msg
	end

	function META:ClearError()
		self.lua_error_thrown = nil
		self.lua_assert_error_thrown = nil
	end

	function META:Return(node, types)
		local scope = self:GetScope()
		local function_scope = scope:GetNearestFunctionScope()

		if scope == function_scope then
			-- the root scope of the function when being called is definetly certain
			function_scope.uncertain_function_return = false
		elseif scope:IsUncertain() then
			function_scope.uncertain_function_return = true

			-- else always hits, so even if the else part is uncertain
			-- it does mean that this function at least returns something
			if scope:IsElseConditionalScope() then
				function_scope.uncertain_function_return = false
				function_scope:CertainReturn()
			end
		elseif function_scope.uncertain_function_return then
			function_scope.uncertain_function_return = false
		end

		local thrown = false

		if function_scope.lua_silent_error then
			local errored_scope = table.remove(function_scope.lua_silent_error)

			if
				errored_scope and
				self:GetScope():IsCertainFromScope(errored_scope) and
				errored_scope:IsCertain()
			then
				thrown = true
			end
		end

		if not thrown then
			scope:CollectOutputSignatures(node, types)
		else
			scope.throws = true
		end

		if scope:IsUncertain() then
			function_scope:UncertainReturn()
			scope:UncertainReturn()
		else
			function_scope:CertainReturn(self)
			scope:CertainReturn(self)
		end

		self:ApplyMutationsAfterReturn(scope, function_scope, true, scope:GetTrackedUpvalues(), scope:GetTrackedTables())
	end

	do
		function META:GetCallStack()
			return self.call_stack or {}
		end

		function META:GetCallFrame(level)
			local stack = self:GetCallStack()
			local frame = level and stack[#stack - level] or stack[#stack]
			return frame
		end

		function META:PushCallFrame(obj, call_node, not_recursive_call)
			-- setup and track the callstack to avoid infinite loops or callstacks that are too big
			self.call_stack = self.call_stack or {}

			if
				self:IsRuntime() and
				call_node and
				not not_recursive_call and
				not obj:IsRefFunction()
			then
				for _, v in ipairs(self.call_stack) do
					-- if the callnode is the same, we're doing some infinite recursion
					if v.call_node == call_node then
						if obj:IsExplicitOutputSignature() then
							-- so if we have explicit return types, just return those
							obj.recursively_called = obj:GetOutputSignature():Copy()
							return obj.recursively_called
						else
							-- if not we sadly have to resort to any
							-- TODO: error?
							obj.recursively_called = Tuple({}):AddRemainder(Tuple({Any()}):SetRepeat(math.huge))
							return obj.recursively_called
						end
					end
				end
			end

			table.insert(
				self.call_stack,
				1,
				{
					obj = obj,
					call_node = call_node,
					scope = self:GetScope(),
				}
			)
		--[[for i, frame in ipairs(self.call_stack) do
				print(("\t"):rep(i - 1) .. tostring(frame.call_node))
				print(("\t"):rep(i - 1) .. tostring(frame.obj:GetFunctionBodyNode() or frame.obj))
			end]] end

		function META:PopCallFrame()
			table.remove(self.call_stack, 1)
		end
	end

	function META:IsDefinetlyReachable()
		local scope = self:GetScope()
		local function_scope = scope:GetNearestFunctionScope()

		if not scope:IsCertain() then return false, "scope is uncertain" end

		if function_scope.uncertain_function_return == true then
			return false, "uncertain function return"
		end

		if function_scope.lua_silent_error then
			for _, scope in ipairs(function_scope.lua_silent_error) do
				if not scope:IsCertain() then
					return false, "parent function scope can throw an error"
				end
			end
		end

		for _, frame in ipairs(self:GetCallStack()) do
			local scope = frame.scope

			if not scope:IsCertain() then
				return false, "call stack scope is uncertain"
			end

			if scope.uncertain_function_return == true then
				return false, "call stack scope has uncertain function return"
			end
		end

		return true
	end

	function META:IsMaybeReachable()
		local scope = self:GetScope()
		local function_scope = scope:GetNearestFunctionScope()

		if function_scope.lua_silent_error then
			for _, scope in ipairs(function_scope.lua_silent_error) do
				if not scope:IsCertain() then return false end
			end
		end

		for _, frame in ipairs(self:GetCallStack()) do
			local parent_scope = frame.scope

			if parent_scope.uncertain_function_return then return true end

			if not parent_scope:IsCertain() and parent_scope:IsCertainFromScope(scope) then
				return false
			end
		end

		return true
	end

	function META:UncertainReturn()
		self.call_stack[1].scope:UncertainReturn()
	end

	function META:Print(...)
		local helpers = require("nattlua.other.helpers")
		local node = self.current_expression
		local start, stop = node:GetStartStop()

		do
			local node = self.current_statement
			local start2, stop2 = node:GetStartStop()

			if start2 > start then
				start = start2
				stop = stop2
			end
		end

		local str = {}

		for i = 1, select("#", ...) do
			str[i] = tostring(select(i, ...))
		end

		print(node.Code:BuildSourceCodePointMessage(table.concat(str, ", "), start, stop, 1))
	end

	function META:PushConditionalScope(statement, truthy, falsy)
		local scope = self:CreateAndPushScope()
		scope:SetConditionalScope(true)
		scope:SetStatement(statement)
		scope:SetTruthy(truthy)
		scope:SetFalsy(falsy)
		return scope
	end

	function META:ErrorAndCloneCurrentScope(err)
		self:Error(err)
		self:CloneCurrentScope()
		self:GetScope():SetConditionalScope(true)
	end

	function META:PopConditionalScope()
		self:PopScope()
	end
end