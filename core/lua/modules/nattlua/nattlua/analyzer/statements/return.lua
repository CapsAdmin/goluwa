local Nil = require("nattlua.types.symbol").Nil
return {
	AnalyzeReturn = function(self, statement)
		local ret = self:AnalyzeExpressions(statement.expressions)
		self:Return(statement, ret)
	end,
}
