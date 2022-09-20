local META = ...

function META:IsLocalAssignmentStatement()
	return self:IsValue("local")
end

function META:ReadLocalAssignmentStatement()
	local node = self:Node("assignment")
	node.tokens["local"] = self:ReadToken()
	node.is_local = true
	node.lvalues = self:IdentifierList()

	if self:IsValue("=") then
		node.tokens["="] = self:ReadToken("=")
		node.rvalues = self:ExpressionList()
	end

	return node
end