local AnalyzeFunction = require("nattlua.analyzer.expressions.function").AnalyzeFunction
local NodeToString = require("nattlua.types.string").NodeToString
return {
	AnalyzeFunction = function(self, statement)
		if
			statement.kind == "local_function" or
			statement.kind == "local_analyzer_function" or
			statement.kind == "local_type_function"
		then
			self:PushAnalyzerEnvironment(statement.kind == "local_function" and "runtime" or "typesystem")
			self:CreateLocalValue(statement.tokens["identifier"].value, AnalyzeFunction(self, statement))
			self:PopAnalyzerEnvironment()
		elseif
			statement.kind == "function" or
			statement.kind == "analyzer_function" or
			statement.kind == "type_function"
		then
			local key = statement.expression
			self:PushAnalyzerEnvironment(statement.kind == "function" and "runtime" or "typesystem")

			if key.kind == "binary_operator" then
				local obj = self:AnalyzeExpression(key.left)
				local key = self:AnalyzeExpression(key.right)
				local val = AnalyzeFunction(self, statement)
				self:NewIndexOperator(obj, key, val)
			else
				self.current_expression = key
				local key = NodeToString(key)
				local val = AnalyzeFunction(self, statement)
				self:SetLocalOrGlobalValue(key, val)
			end

			self:PopAnalyzerEnvironment()
		else
			self:FatalError("unhandled statement: " .. statement.kind)
		end
	end,
}