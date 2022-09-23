local ipairs = ipairs
local tostring = tostring
local table = _G.table
local NodeToString = require("nattlua.types.string").NodeToString
local Union = require("nattlua.types.union").Union
local Nil = require("nattlua.types.symbol").Nil

local function check_type_against_contract(val, contract)
	-- if the contract is unique / nominal, ie
	-- local a: Person = {name = "harald"}
	-- Person is not a subset of {name = "harald"} because
	-- Person is only equal to Person
	-- so we need to disable this check during assignment
	local skip_uniqueness = contract:IsUnique() and not val:IsUnique()

	if skip_uniqueness then contract:DisableUniqueness() end

	local ok, reason = val:IsSubsetOf(contract)

	if skip_uniqueness then
		contract:EnableUniqueness()
		val:SetUniqueID(contract:GetUniqueID())
	end

	if not ok then return ok, reason end

	-- make sure the table contains all the keys in the contract as well
	-- since {foo = true, bar = "harald"} 
	-- is technically a subset of 
	-- {foo = true, bar = "harald", baz = "jane"}
	if contract.Type == "table" and val.Type == "table" then
		return val:ContainsAllKeysIn(contract)
	end

	return true
end

return {
	AnalyzeAssignment = function(self, statement)
		local left = {}
		local right = {}

		-- first we evaluate the left hand side
		for left_pos, exp_key in ipairs(statement.left) do
			if exp_key.kind == "value" then
				-- local foo, bar = *
				left[left_pos] = NodeToString(exp_key, true)
			elseif exp_key.kind == "postfix_expression_index" then
				-- foo[bar] = *
				left[left_pos] = self:AnalyzeExpression(exp_key.expression)
			elseif exp_key.kind == "binary_operator" then
				-- foo.bar = *
				left[left_pos] = self:AnalyzeExpression(exp_key.right)
			else
				self:FatalError("unhandled assignment expression " .. tostring(exp_key:Render()))
			end
		end

		if statement.right then
			for right_pos, exp_val in ipairs(statement.right) do
				-- when "self" is looked up in the typesystem in analyzer:AnalyzeExpression, we refer left[right_pos]
				-- use context?
				self.left_assigned = left[right_pos]
				local obj = self:Assert(self:AnalyzeExpression(exp_val))
				self:ClearTracked()

				if obj.Type == "tuple" and obj:GetLength() == 1 then
					obj = obj:Get(1)
				end

				if obj.Type == "tuple" then
					if self:IsRuntime() then
						-- at runtime unpack the tuple
						for i = 1, #statement.left do
							local index = right_pos + i - 1
							right[index] = obj:Get(i)
						end
					end

					if self:IsTypesystem() then
						if obj:HasTuples() then
							-- if we have a tuple with, plainly unpack the tuple while preserving the tuples inside
							for i = 1, #statement.left do
								local index = right_pos + i - 1
								right[index] = obj:GetWithoutExpansion(i)
							end
						else
							-- otherwise plainly assign it
							right[right_pos] = obj
						end
					end
				elseif obj.Type == "union" then
					-- if the union is empty or has no tuples, just assign it
					if obj:IsEmpty() or not obj:HasTuples() then
						right[right_pos] = obj
					else
						for i = 1, #statement.left do
							-- unpack unions with tuples
							-- ⦗false, string, 2⦘ | ⦗true, 1⦘ at first index would be true | false
							local index = right_pos + i - 1
							right[index] = obj:GetAtIndex(index)
						end
					end
				else
					right[right_pos] = obj

					-- when the right side has a type expression, it's invoked using the as operator
					if exp_val.type_expression then obj:Seal() end
				end
			end

			-- cuts the last arguments
			-- local funciton test() return 1,2,3 end
			-- local a,b,c = test(), 1337
			-- a should be 1
			-- b should be 1337
			-- c should be nil
			local last = statement.right[#statement.right]

			if last.kind == "value" and last.value.value ~= "..." then
				for _ = 1, #right - #statement.right do
					table.remove(right, #right)
				end
			end
		end

		-- here we check the types
		for left_pos, exp_key in ipairs(statement.left) do
			local val = right[left_pos] or Nil()

			-- do we have a type expression? 
			-- local a: >>number<< = 1
			if exp_key.type_expression then
				self:PushAnalyzerEnvironment("typesystem")
				local contract = self:AnalyzeExpression(exp_key.type_expression)
				self:PopAnalyzerEnvironment()

				if right[left_pos] then
					local contract = contract

					if contract.Type == "tuple" and contract:GetLength() == 1 then
						contract = contract:Get(1)
					end

					-- we copy the literalness of the contract so that
					-- local a: number = 1
					-- becomes
					-- local a: number = number
					val:CopyLiteralness(contract)

					if val.Type == "table" and contract.Type == "table" then
						-- coerce any untyped functions based on contract
						val:CoerceUntypedFunctions(contract)
					end

					self.current_expression = exp_key
					self:Assert(check_type_against_contract(val, contract))
				else
					if contract.Type == "tuple" and contract:GetLength() == 1 then
						contract = contract:Get(1)
					end
				end

				-- we set a's contract to be number
				val:SetContract(contract)

				-- this is for "local a: number" without the right side being assigned
				if not right[left_pos] then
					-- make a copy of the contract and use it
					-- so the value can change independently from the contract
					val = contract:Copy()
					val:SetContract(contract)
				end
			end

			-- used by the emitter
			exp_key:AddType(val)
			val:SetAnalyzerEnvironment(self:GetCurrentAnalyzerEnvironment())

			-- if all is well, create or mutate the value
			if statement.kind == "local_assignment" then
				local immutable = false

				if exp_key.attribute then
					if exp_key.attribute.value == "const" then immutable = true end
				end

				-- local assignment: local a = 1
				self:CreateLocalValue(exp_key.value.value, val, immutable):SetNode(exp_key)
			elseif statement.kind == "assignment" then
				local key = left[left_pos]

				-- plain assignment: a = 1
				if exp_key.kind == "value" then
					if self:IsRuntime() then -- check for any previous upvalues
						local existing_value = self:GetLocalOrGlobalValue(key)
						local contract = existing_value and existing_value:GetContract()

						if contract then
							if contract.Type == "tuple" then
								contract = contract:GetFirstValue()
							end

							if contract then
								val:CopyLiteralness(contract)
								self:Assert(check_type_against_contract(val, contract))
								val:SetContract(contract)
							end
						end
					end

					local val = self:SetLocalOrGlobalValue(key, val)

					if val then
						-- this is used for tracking function dependencies
						if val.Type == "upvalue" then
							self:GetScope():AddDependency(val)
						else
							self:GetScope():AddDependency({key = key, val = val})
						end
					end
				else
					-- TODO: refactor out to mutation assignment?
					-- index assignment: foo[a] = 1
					local obj = self:AnalyzeExpression(exp_key.left)
					self:ClearTracked()

					if self:IsRuntime() then key = key:GetFirstValue() end

					self:Assert(self:NewIndexOperator(obj, key, val))
				end
			end
		end
	end,
}