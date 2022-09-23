local Postfix = require("nattlua.analyzer.operators.postfix").Postfix
return {
	AnalyzePostfixOperator = function(self, node)
		return self:Assert(Postfix(self, node, self:AnalyzeExpression(node.left)))
	end,
}
