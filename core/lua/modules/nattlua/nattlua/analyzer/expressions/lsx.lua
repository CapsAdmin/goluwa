local Any = require("nattlua.types.any").Any
local Table = require("nattlua.types.table").Table
local Tuple = require("nattlua.types.tuple").Tuple
local LString = require("nattlua.types.string").LString
return {
	AnalyzeLSX = function(self, node)
		self:PushAnalyzerEnvironment("runtime")
		local func = self:AnalyzeExpression(node.tag)
		node.tokens["type2"]:AddType(func)
		local tbl = Table()

		do
			self:PushCurrentType(tbl, "table")
			tbl:SetCreationScope(self:GetScope())

			for _, node in ipairs(node.props) do
				if node.kind == "table_key_value" then
					local key = LString(node.tokens["identifier"].value)
					local val = self:AnalyzeExpression(node.value_expression):GetFirstValue() or Nil()
					self:NewIndexOperator(tbl, key, val)
				end
			end

			local children = Table()

			for _, node in ipairs(node.children) do
				children:Insert(self:AnalyzeExpression(node))
			end

			self:NewIndexOperator(tbl, LString("children"), children)
			self:PopCurrentType("table")
		end

		local ret, err = self:Call(func, Tuple({tbl}), node)
		self.current_expression = node
		self:PopAnalyzerEnvironment()

		if not ret then
			self:Error(err)
			return Any()
		end

		return ret
	end,
}