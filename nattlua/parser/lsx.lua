local META = ...

function META:ParseLSXExpression()
	if
		not (
			self:IsValue("<") and
			self:IsType("letter", 1) and
			not self:IsValue("local", -1)
		)
	then
		return
	end

	local node = self:StartNode("expression", "lsx")
	node.tokens["<"] = self:ExpectValue("<")
	node.tag = self:ExpectType("letter")
	node.props = {}
	node.children = {}

	for i = 1, self:GetLength() do
		if self:IsValue("{") and self:IsValue("...", 1) then
			local left = self:ExpectValue("{")
			local spread = self:read_table_spread()

			if not spread then
				self:Error("expected table spread")
				return
			end

			local right = self:ExpectValue("}")
			spread.tokens["{"] = left
			spread.tokens["}"] = right
			table.insert(node.props, spread)
		elseif self:IsType("letter") and self:IsValue("=", 1) then
			if self:IsValue("{", 2) then
				local keyval = self:StartNode("expression", "lsx")
				keyval.key = self:ExpectType("letter")
				keyval.tokens["="] = self:ExpectValue("=")
				keyval.tokens["{"] = self:ExpectValue("{")
				keyval.val = self:ExpectRuntimeExpression()
				keyval.tokens["}"] = self:ExpectValue("}")
				keyval = self:EndNode(keyval)
				table.insert(node.props, keyval)
			elseif self:IsType("string", 2) or self:IsType("number", 2) then
				local keyval = self:StartNode("expression", "lsx")
				keyval.key = self:ExpectType("letter")
				keyval.tokens["="] = self:ExpectValue("=")
				keyval.val = self:ParseToken()
				keyval = self:EndNode(keyval)
				table.insert(node.props, keyval)
			else
				self:Error("expected = { or = string or = number got " .. self:GetToken(3).type)
			end
		else
			break
		end
	end

	if self:IsValue("/") then
		node.tokens["/"] = self:ExpectValue("/")
		node.tokens[">"] = self:ExpectValue(">")
		node = self:EndNode(node)
		return node
	end

	node.tokens[">"] = self:ExpectValue(">")

	for i = 1, self:GetLength() do
		if self:IsValue("{") then
			local left = self:ExpectValue("{")
			local child = self:ExpectRuntimeExpression()
			child.tokens["lsx{"] = left
			table.insert(node.children, child)
			child.tokens["lsx}"] = self:ExpectValue("}")
		end

		for i = 1, self:GetLength() do
			if self:IsValue("<") and self:IsType("letter", 1) then
				table.insert(node.children, self:ParseLSXExpression())
			else
				break
			end
		end

		if self:IsValue("<") and self:IsValue("/", 1) then break end

		local tk = self:ParseToken()
		table.insert(node.children, tk)
	end

	node.tokens["<2"] = self:ExpectValue("<")
	node.tokens["/"] = self:ExpectValue("/")
	node.tokens["type2"] = self:ExpectType("letter")
	node.tokens[">2"] = self:ExpectValue(">")
	node = self:EndNode(node)
	return node
end