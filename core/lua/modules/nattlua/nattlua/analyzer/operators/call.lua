local ipairs = ipairs
local Union = require("nattlua.types.union").Union
local Any = require("nattlua.types.any").Any
local type_errors = require("nattlua.types.error_messages")
local Tuple = require("nattlua.types.tuple").Tuple
local LString = require("nattlua.types.string").LString
return {
	Call = function(META)
		require("nattlua.analyzer.operators.call_analyzer")(META)
		require("nattlua.analyzer.operators.call_body")(META)
		require("nattlua.analyzer.operators.call_function_signature")(META)

		local function call_tuple(self, obj, input, call_node)
			return self:Call(obj:GetFirstValue(), input, call_node, true)
		end

		local function call_union(self, obj, input, call_node)
			if obj:IsEmpty() then return type_errors.operation("call", nil) end

			do
				-- make sure the union is callable, we pass the analyzer and 
				-- it will throw errors if the union contains something that is not callable
				-- however it will continue and just remove those values from the union
				local truthy_union = obj.New()

				for _, v in ipairs(obj.Data) do
					if v.Type ~= "function" and v.Type ~= "table" and v.Type ~= "any" then
						self:ErrorAndCloneCurrentScope(
							{
								"union ",
								obj,
								" contains uncallable object ",
								v,
							},
							obj
						)
					else
						truthy_union:AddType(v)
					end
				end

				truthy_union:SetUpvalue(obj:GetUpvalue())
				obj = truthy_union
			end

			local is_overload = true

			for _, obj in ipairs(obj.Data) do
				if obj.Type ~= "function" or obj:GetFunctionBodyNode() then
					is_overload = false

					break
				end
			end

			if is_overload then
				local errors = {}

				for _, obj in ipairs(obj.Data) do
					if
						obj.Type == "function" and
						input:GetLength() < obj:GetInputSignature():GetMinimumLength()
					then
						table.insert(
							errors,
							{
								"invalid amount of arguments: ",
								input,
								" ~= ",
								obj:GetInputSignature(),
							}
						)
					else
						local res, reason = self:Call(obj, input, call_node, true)

						if res then return res end

						table.insert(errors, reason)
					end
				end

				return type_errors.other(errors)
			end

			local new = Union({})

			for _, obj in ipairs(obj.Data) do
				local val = self:Assert(self:Call(obj, input, call_node, true))

				-- TODO
				if val.Type == "tuple" and val:GetLength() == 1 then
					val = val:Unpack(1)
				elseif val.Type == "union" and val:GetMinimumLength() == 1 then
					val = val:GetAtIndex(1)
				end

				new:AddType(val)
			end

			return Tuple({new})
		end

		local function call_table(self, obj, input, call_node)
			local __call = obj:GetMetaTable() and obj:GetMetaTable():Get(LString("__call"))

			if __call then
				local new_input = {obj}

				for _, v in ipairs(input:GetData()) do
					table.insert(new_input, v)
				end

				return self:Call(__call, Tuple(new_input), call_node, true)
			end

			return type_errors.other("table has no __call metamethod")
		end

		local function call_any(self, input)
			-- it's ok to call any types, it will just return any
			-- check arguments that can be mutated
			for _, arg in ipairs(input:GetData()) do
				if arg.Type == "table" and arg:GetAnalyzerEnvironment() == "runtime" then
					if arg:GetContract() then
						-- error if we call any with tables that have contracts
						-- since anything might happen to them in an any call
						self:Error(
							{
								"cannot mutate argument with contract ",
								arg:GetContract(),
							}
						)
					else
						-- if we pass a table without a contract to an any call, we add any to its key values
						for _, keyval in ipairs(arg:GetData()) do
							keyval.key = Union({Any(), keyval.key})
							keyval.val = Union({Any(), keyval.val})
						end
					end
				end
			end

			return Tuple({Tuple({}):AddRemainder(Tuple({Any()}):SetRepeat(math.huge))})
		end

		local function call_other(obj)
			return type_errors.other({
				"type ",
				obj.Type,
				": ",
				obj,
				" cannot be called",
			})
		end

		local function call_function(self, obj, input)
			-- mark the object as called so the unreachable code step won't call it
			obj:SetCalled(true)

			-- infer any uncalled functions in the arguments to get their return type
			for i, b in ipairs(input:GetData()) do
				if b.Type == "function" and not b:IsCalled() and not b:IsExplicitOutputSignature() then
					local a = obj:GetInputSignature():Get(i)

					if
						a and
						(
							(
								a.Type == "function" and
								not a:GetOutputSignature():IsSubsetOf(b:GetOutputSignature())
							)
							or
							not a:IsSubsetOf(b)
						)
					then
						local func = a

						if func.Type == "union" then func = a:GetType("function") end

						b:SetArgumentsInferred(true)

						-- TODO: callbacks with ref arguments should not be called
						-- mixed ref args make no sense, maybe ref should be a keyword for the function instead?
						if not b:IsRefFunction() and func then
							self:Assert(self:Call(b, func:GetInputSignature():Copy(nil, true)))
						end
					end
				end
			end

			if obj:GetAnalyzerFunction() then
				return self:CallAnalyzerFunction(obj, input)
			elseif obj:GetFunctionBodyNode() then
				return self:CallBodyFunction(obj, input)
			end

			return self:CallFunctionSignature(obj, input)
		end

		function META:Call(obj, input, call_node, not_recursive_call)
			if obj.Type == "tuple" then
				return call_tuple(self, obj, input, call_node)
			elseif obj.Type == "union" then
				return call_union(self, obj, input, call_node)
			elseif obj.Type == "table" then
				return call_table(self, obj, input, call_node)
			elseif obj.Type == "any" then
				return call_any(self, input)
			elseif obj.Type ~= "function" then
				return call_other(obj)
			end

			if
				self:IsRuntime() and
				obj:IsCalled() and
				not obj:IsRefFunction()
				and
				obj:GetFunctionBodyNode() and
				obj:GetFunctionBodyNode().environment == "runtime" and
				not obj:GetAnalyzerFunction()
				and
				obj:IsExplicitInputSignature()
			then
				if obj.scope and obj.scope.throws then
					self:GetScope():CertainReturn()
				end
				return obj:GetOutputSignature():Copy()
			end

			local ok, err = self:PushCallFrame(obj, call_node, not_recursive_call)

			if not ok == false then return ok, err end

			if ok then return ok end

			local ok, err = call_function(self, obj, input)
			self:PopCallFrame()
			return ok, err
		end
	end,
}