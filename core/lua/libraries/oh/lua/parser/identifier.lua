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

		if not self:IsValue("|") then
			break
		end

		node.tokens["|"] = self:ReadToken()
	end

	return out
end

function META:ReadIdentifier()
	local node = self:Node("value")
	node.value = self:ReadExpectType("letter")

	if self:IsValue(":") then
		node.tokens[":"] = self:ReadToken(":")
		node.data_type = self:Type()
	end

	return node
end

function META:IdentifierList(out)
	out = out or {}

	for _ = 1, self:GetLength() do
		if not self:IsType("letter") and not self:IsValue("...") and not self:IsValue(":") then
			break
		end

		local node = self:ReadIdentifier()

		table.insert(out, node)

		if self:IsValue(",") then
			node.tokens[","] = self:ReadToken()
		else
			break
		end
	end

	return out
end
