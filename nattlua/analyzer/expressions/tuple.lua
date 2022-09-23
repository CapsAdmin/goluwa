local Tuple = require("nattlua.types.tuple").Tuple
return {
	AnalyzeTuple = function(self, node)
		local tup = Tuple():SetUnpackable(true)
		self:PushCurrentType(tup, "tuple")
		tup:SetTable(self:AnalyzeExpressions(node.expressions))
		self:PopCurrentType("tuple")
		return tup
	end,
}
