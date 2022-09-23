local Prefix = require("nattlua.analyzer.operators.prefix").Prefix
return {
	AnalyzePrefixOperator = function(self, node)
		return self:Assert(Prefix(self, node))
	end,
}
