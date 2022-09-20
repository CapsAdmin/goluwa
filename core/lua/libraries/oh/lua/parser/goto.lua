local META = ...

function META:IsGotoLabelStatement()
	return self:IsValue("::")
end

function META:ReadGotoLabelStatement()
	local node = self:Node("goto_label")
	node.tokens["::left"] = self:ReadToken()
	node.label = self:Node("value")
	node.label.value = self:ReadExpectType("letter")
	node.tokens["::right"] = self:ReadExpectValue("::")
	return node
end

function META:IsGotoStatement()
	return self:IsValue("goto")
end

function META:ReadGotoStatement()
	local node = self:Node("goto")
	node.tokens["goto"] = self:ReadToken()
	node.label = self:Node("value")
	node.label.value = self:ReadExpectType("letter")
	return node
end