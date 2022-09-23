local table = _G.table
local Binary = require("nattlua.analyzer.operators.binary").Binary
local Nil = require("nattlua.types.symbol").Nil
local assert = _G.assert
return {
	AnalyzeBinaryOperator = function(self, node)
		return self:Assert(Binary(self, node))
	end,
}
