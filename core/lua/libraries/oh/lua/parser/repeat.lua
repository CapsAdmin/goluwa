local META = ...

function META:IsRepeatStatement()
	return self:IsValue("repeat")
end

function META:ReadRepeatStatement()
	local token = self:GetToken()
	local node = self:Node("repeat")
	node.tokens["repeat"] = self:ReadToken()
	self:PushLoopBlock(node)
	node.block = self:Block({["until"] = true})
	node.tokens["until"] = self:ReadExpectValue("until", token, token)
	node.condition = self:Expression()
	self:PopLoopBlock()
	return node
end