local tostring = tostring
local ipairs = ipairs
local LNumber = require("nattlua.types.number").LNumber
local LString = require("nattlua.types.string").LString
local Table = require("nattlua.types.table").Table
local Nil = require("nattlua.types.symbol").Nil
local table = _G.table
return {
	AnalyzeTable = function(self, tree)
		local tbl = Table():SetLiteral(self:IsTypesystem())

		if self:IsRuntime() then tbl:SetReferenceId(tostring(tbl:GetData())) end

		self:PushCurrentType(tbl, "table")
		tbl:SetCreationScope(self:GetScope())

		for i, node in ipairs(tree.children) do
			if node.kind == "table_key_value" then
				local key = LString(node.tokens["identifier"].value)
				local val = self:AnalyzeExpression(node.value_expression):GetFirstValue() or Nil()
				self:NewIndexOperator(tbl, key, val)
			elseif node.kind == "table_expression_value" then
				local key = self:AnalyzeExpression(node.key_expression):GetFirstValue()
				local val = self:AnalyzeExpression(node.value_expression):GetFirstValue()
				self:NewIndexOperator(tbl, key, val)
			elseif node.kind == "table_index_value" then
				if node.spread then
					local val = self:AnalyzeExpression(node.spread.expression):GetFirstValue()

					if val.Type == "table" then
						for _, kv in ipairs(val:GetData()) do
							local val = kv.val

							if val.Type == "union" and val:CanBeNil() then
								val = val:Copy():RemoveType(Nil())
							end

							if kv.key.Type == "number" then
								self:NewIndexOperator(tbl, LNumber(tbl:GetLength(self):GetData() + 1), val)
							else
								self:NewIndexOperator(tbl, kv.key, val)
							end
						end
					end
				else
					local obj = self:AnalyzeExpression(node.value_expression)

					if
						node.value_expression.kind ~= "value" or
						node.value_expression.value.value ~= "..."
					then
						obj = obj:GetFirstValue()
					end

					if obj.Type == "tuple" then
						if tree.children[i + 1] then
							self:NewIndexOperator(tbl, LNumber(tbl:GetLength(self):GetData() + 1), obj:Get(1))
						else
							for i = 1, obj:GetMinimumLength() do
								tbl:Set(LNumber(#tbl:GetData() + 1), obj:Get(i))
							end

							if obj.Remainder then
								local current_index = LNumber(#tbl:GetData() + 1)
								local max = LNumber(obj.Remainder:GetLength())
								self:NewIndexOperator(tbl, current_index:SetMax(max), obj.Remainder:Get(1))
							end
						end
					else
						if node.i then
							self:NewIndexOperator(tbl, LNumber(tbl:GetLength(self):GetData() + 1), LNumber(obj))
						elseif obj then
							self:NewIndexOperator(tbl, LNumber(tbl:GetLength(self):GetData() + 1), obj)
						end
					end
				end
			end

			self:ClearTracked()
		end

		self:PopCurrentType("table")
		return tbl
	end,
}