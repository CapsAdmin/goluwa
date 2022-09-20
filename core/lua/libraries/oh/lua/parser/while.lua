local META = ...

function META:IsWhileStatement()
	return self:IsValue("while")
end

function META:ReadWhileStatement()
	local node = self:Node("while")
	node.tokens["while"] = self:ReadToken()
	node.expression = self:Expression()
	node.tokens["do"] = self:ReadExpectValue("do")
	self:PushLoopBlock(node)
	node.block = self:Block({["end"] = true})
	node.tokens["end"] = self:ReadExpectValue("end", node.tokens["while"], node.tokens["while"])
	self:PopLoopBlock()
	return node
end