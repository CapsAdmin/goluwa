local ipairs = ipairs
local Union = require("nattlua.types.union").Union

local function contains_ref_argument(upvalues)
	for _, v in pairs(upvalues) do
		if v.upvalue:GetValue():IsReferenceArgument() or v.upvalue:GetValue().from_for_loop then
			return true
		end
	end

	return false
end

return {
	AnalyzeIf = function(self, statement)
		local prev_expression
		local blocks = {}

		for i, statements in ipairs(statement.statements) do
			if statement.expressions[i] then
				self.current_if_statement = statement
				local exp = statement.expressions[i]
				local no_operator_expression = exp.kind ~= "binary_operator" and
					exp.kind ~= "prefix_operator" or
					(
						exp.kind == "binary_operator" and
						exp.value.value == "."
					)

				if no_operator_expression then self:PushTruthyExpressionContext(true) end

				local obj = self:AnalyzeExpression(exp)
				self.current_expression = exp

				if no_operator_expression then self:PopTruthyExpressionContext() end

				if no_operator_expression then
					-- track "if x then" which has no binary or prefix operators
					if obj.Type == "union" then
						self:TrackUpvalueUnion(obj, obj:GetTruthy(), obj:GetFalsy())
					else
						self:TrackUpvalue(obj)
					end
				end

				self.current_if_statement = nil
				prev_expression = obj

				if obj:IsTruthy() then
					local upvalues = self:GetTrackedUpvalues()
					local tables = self:GetTrackedTables()
					self:ClearTracked()
					table.insert(
						blocks,
						{
							statements = statements,
							upvalues = upvalues,
							tables = tables,
							expression = obj,
						}
					)

					if obj:IsCertainlyTrue() and self:IsRuntime() then
						if not contains_ref_argument(upvalues) then
							self:Warning("if condition is always true")
						end
					end

					if not obj:IsFalsy() then break end
				end

				if obj:IsCertainlyFalse() and self:IsRuntime() then
					if not contains_ref_argument(self:GetTrackedUpvalues()) then
						self:Warning("if condition is always false")
					end
				end
			else
				if prev_expression:IsCertainlyFalse() and self:IsRuntime() then
					if not contains_ref_argument(self:GetTrackedUpvalues()) then
						self:Warning("else part of if condition is always true")
					end
				end

				if prev_expression:IsFalsy() then
					table.insert(
						blocks,
						{
							statements = statements,
							upvalues = blocks[#blocks] and blocks[#blocks].upvalues,
							tables = blocks[#blocks] and blocks[#blocks].tables,
							expression = prev_expression,
							is_else = true,
						}
					)
				end
			end
		end

		local last_scope

		for i, block in ipairs(blocks) do
			block.scope = self:GetScope()
			local scope = self:PushConditionalScope(statement, block.expression:IsTruthy(), block.expression:IsFalsy())

			if last_scope then
				last_scope:SetNextConditionalSibling(scope)
				scope:SetPreviousConditionalSibling(last_scope)
			end

			last_scope = scope
			scope:SetTrackedUpvalues(block.upvalues)
			scope:SetTrackedTables(block.tables)

			if block.is_else then
				scope:SetElseConditionalScope(true)
				self:ApplyMutationsInIfElse(blocks)
			else
				self:ApplyMutationsInIf(block.upvalues, block.tables)
			end

			self:AnalyzeStatements(block.statements)
			self:PopConditionalScope()
		end

		self:ClearTracked()
	end,
}