local META = ...

function META:IsDoStatement()
	return self:IsValue("do")
end

function META:ReadDoStatement()
	local token = self:GetToken()
	local node = self:Node("do")
	node.tokens["do"] = self:ReadToken()
	node.block = self:Block({["end"] = true})
	node.tokens["end"] = self:ReadExpectValue("end", token, token)
	return node
end