local META = ...

function META:Type()
	local node = self:Node("type")
	local out = {}

	for _ = 1, self:GetLength() do
		local token = self:ReadToken()

		if not token then return out end

		local node = self:Node("value")
		node.value = token
		table.insert(out, node)

		if token.type == "letter" and self:IsValue("(") then
			local start = self:GetToken()
			node.tokens["func("] = self:ReadExpectValue("(")
			node.function_arguments = self:IdentifierList()
			node.tokens["func)"] = self:ReadExpectValue(")", start, start)
			node.tokens["return:"] = self:ReadExpectValue(":")
			node.function_return_type = self:Type()
		end

		if not self:IsValue("|") then break end

		node.tokens["|"] = self:ReadToken()
	end

	return out
end

function META:ReadIdentifier()
	local node = self:Node("value")

	if self:IsValue("{") then
		node.tokens["{"] = self:ReadExpectValue("{")
		node.destructor = self:IdentifierList(nil, true)
		node.tokens["}"] = self:ReadExpectValue("}")
	else
		node.value = self:ReadExpectType("letter")
	end

	if self:IsValue(":") then
		node.tokens[":"] = self:ReadToken(":")
		node.data_type = self:Type()
	end

	return node
end

function META:IdentifierList(out, destructor)
	out = out or {}

	for _ = 1, self:GetLength() do
		if
			not self:IsType("letter") and
			not self:IsValue("...")
			and
			not self:IsValue(":")
			and
			not self:IsValue("{")
		then
			break
		end

		local node

		if self:IsValue("...") then
			node = self:Node("value")
			node.value = self:ReadToken()

			if self:IsValue(":") then
				node.tokens[":"] = self:ReadToken(":")
				node.data_type = self:Type()
			end
		else
			node = self:ReadIdentifier()
		end

		if destructor and self:IsValue("=") then
			self:ReadToken()
			node.default = self:Expression()
		end

		table.insert(out, node)

		if self:IsValue(",") then
			node.tokens[","] = self:ReadToken()
		else
			break
		end
	end

	return out
end