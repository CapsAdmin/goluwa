local META = ...

function META:IsIfStatement()
	return self:IsValue("if")
end

function META:ReadIfStatement(out)
	local node = self:Node("if")
	node.clauses = {}
	local prev_token = self:GetToken()

	for _ = 1, self:GetLength() do
		if self:IsValue("end") then
			node.tokens["end"] = self:ReadToken()

			break
		end

		local clause = self:Node("clause")

		if self:IsValue("else") then
			clause.tokens["if/else/elseif"] = self:ReadToken()
			clause.block = self:Block({["end"] = true})
			clause.tokens["end"] = self:ReadExpectValue("end", prev_token, prev_token)
		else
			clause.tokens["if/else/elseif"] = self:ReadToken()
			clause.condition = self:Expression()
			clause.tokens["then"] = self:ReadExpectValue("then")
			clause.block = self:Block({["else"] = true, ["elseif"] = true, ["end"] = true})
			clause.tokens["end"] = self:ReadExpectValues({"else", "elseif", "end"}, prev_token, prev_token)
		end

		table.insert(node.clauses, clause)
		out.has_continue = node.clauses[#node.clauses].block.has_continue
		node.has_continue = out.has_continue
		prev_token = self:GetToken()
		self:Advance(-1) -- we want to read the else/elseif/end in the next iteration
	end

	return node
end