local Binary = require("nattlua.analyzer.operators.binary").Binary
local Node = require("nattlua.parser.node")
return {
	Postfix = function(self, node, r)
		local op = node.value.value

		if op == "++" then
			return Binary(self, setmetatable({value = {value = "+"}}, Node), r, r)
		end
	end,
}
