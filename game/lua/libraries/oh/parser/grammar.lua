local META = ... or oh.parser_meta

function META:ReadAssignment()

	local left = {}

	while true do
		table.insert(left, self:ReadExpression())

		if not self:IsValue(",") then
			break
		end

		self:NextToken()
	end

	if self:IsValue("=") then
		self:NextToken()

		local right = {}

		while true do
			table.insert(right, self:ReadExpression())

			if not self:IsValue(",") then
				break
			end

			self:NextToken()
		end

		return {type = "assignment", left = left, right = right}
	else
		return {type = "call", value = left[1]}
	end
end

function META:ReadArgumentDefintion()
	local out = {}
	self:ReadExpectValue("(")

	if self:GetToken().value == ")" then
		return out
	end

	while true do
		local token = self:ReadExpectType("letter")

		table.insert(out, token)

		if self:IsValue(")") then
			return out
		end

		self:ReadExpectValue(",")
	end
	return out
end

function META:ReadVariableLookup(stop, in_expression)
	local out = {}

	for _ = 1, self:GetLength() do
		local token = self:GetToken()

		if not token then return out end

		if stop and stop[token.value] or oh.syntax.keywords[token.value] then
			return out
		end

		if token.type == "letter" then
			if out[1] and self:GetToken(-1).type == "letter" then
				return out
			end

			table.insert(out, {type = "index", value = token})

		elseif token.value == "[" then
			self:NextToken()
			table.insert(out, {type = "expression", value = self:ReadExpression()})
			self:CheckTokenValue(self:GetToken(), "]")
		elseif token.value ~= "." then
			return out
		end

		self:NextToken()
	end

	return out
end

function META:ReadTable()
	local tree = {}
	tree.type = "table"
	tree.children = {}

	self:ReadExpectValue("{")

	while true do
		local token = self:GetToken()
		if not token then return tree end

		if token.value == "}" then
			self:NextToken()
			return tree
		elseif self:IsValue("=", 1) then
			local index = self:GetToken()
			self:NextToken()
			self:NextToken()

			local data = {}
			data.type = "assignment"
			data.expressions = {self:ReadExpression()}
			data.indices = {index}

			table.insert(tree.children, data)
		elseif token.value == "[" then
			self:NextToken()
			local val = self:ReadExpression()
			self:ReadExpectValue("]")
			self:ReadExpectValue("=")

			local data = {}
			data.type = "assignment"
			data.expressions = {self:ReadExpression()}
			data.indices = {val}
			data.expression_key = true
			table.insert(tree.children, data)
		else
			local data = {}
			data.type = "value"
			data.value =  self:ReadExpression()
			table.insert(tree.children, data)
		end

		if self:IsValue("}") then
			self:Back()
		else
			self:CheckTokenValue(self:GetToken(), ",")
		end

		self:NextToken()
	end

	return tree
end


function META:ReadIndexExpression()
	local out = {}

	for _ = 1, self:GetLength() do
		local token = self:ReadToken()

		if not token then break end

		if token.type == "letter" and not oh.syntax.keywords[token.value] then
			if _ > 1 and (self:GetToken(-2).type == "letter" or self:GetToken(-2).value == "]") then
				self:Back()
				break
			end
			table.insert(out, {type = "index", operator = _ == 1 and {value = ""} or self:GetToken(-2), value = token})
		elseif token.value == "[" then
			table.insert(out, {type = "index_expression", value = self:ReadExpression()})
			self:ReadExpectValue("]")
		elseif token.value == "(" then
			self:Back()

			-- fix this branch
			if self:IsValue(")", 1) then
				table.insert(out, {type = "call", arguments = {}})
				self:NextToken()
				self:NextToken()
			else
				while self:GetToken() and self:ReadToken().value == "(" do

					local arguments = {}
					while true do
						table.insert(arguments, self:ReadExpression())

						if not self:IsValue(",") then
							break
						end

						self:NextToken()
					end

					table.insert(out, {type = "call", arguments = arguments})

					self:ReadExpectValue(")")
				end
				self:Back()
			end

			-- new statement
			if self:IsType("letter") then
				break
			end
		elseif token.value == "." or token.value == ":" then

		else
			self:Back()
			break
		end
	end

	return out
end

function META:ReadExpression(priority)
	priority = priority or 0

	local val

	local token = self:GetToken()

	if not token then return end

	if oh.syntax.unary_operators[token.value] then
		local op = self:ReadToken()
		val = {type = "unary", value = op.value, argument = self:ReadExpression(0)}
	elseif token.value == "(" then
		self:NextToken()
		val = self:ReadExpression(0)
		self:ReadExpectValue(")")
	elseif token.type == "number" or token.type == "string" or oh.syntax.keyword_values[token.value] then
		val = self:ReadToken()
	elseif token.value == "{" then
		val = self:ReadTable()
	elseif token.value == "function" then
		self:NextToken()

		local arguments = {}

		self:ReadExpectValue("(")

		while true do
			local token = self:ReadToken()

			if not token or token.value == ")" then
				break
			end

			if token.type == "letter" then
				table.insert(arguments, token)
			elseif token.value ~= "," then
				break
			end
		end

		val = {type = "function", arguments = arguments, body = self:ReadBody("end")}

	elseif token.type == "letter" and not oh.syntax.keywords[token.value] then
		val = {type = "index_call_expression", value = self:ReadIndexExpression()}
	else
		return val
	end

	local token = self:GetToken()

	if not token then return val end

	while oh.syntax.operators[token.value] and oh.syntax.operators[token.value][1] > priority do
		local op = self:GetToken()
		if not op or not oh.syntax.operators[op.value] then return val end
		self:NextToken()
		val = {type = "operator", value = op.value, left = val, right = self:ReadExpression(oh.syntax.operators[op.value][2])}
	end

	return val
end

function META:ReadBody(stop)
	if type(stop) == "string" then
		stop = {[stop] = true}
	end

	local out = {}

	for _ = 1, self:GetLength() do
		local token = self:ReadToken()

		if not token then break end


		if stop and stop[token.value] then
			return out
		end

		if token.value == "local" then
			if self:GetToken().value == "function" then
				self:NextToken()
				local data = {}
				data.type = "function"
				data.is_local = true
				data.expression = self:ReadExpression()
				data.body = self:ReadBody("end")
				table.insert(out, data)
			else
				local data = self:ReadAssignment()
				data.is_local = true
				table.insert(out, data)
			end
		elseif token.value == "return" then
			local data = {}
			data.type = "return"
			data.expression = self:ReadExpression()
			table.insert(out, data)
		elseif token.value == "do" then
			local data = {}
			data.type = "do"
			data.body = self:ReadBody("end")
			table.insert(out, data)
		elseif token.value == "if" then
			local data = {}
			data.type = "if"
			data.statements = {}
			self:Back() -- we want to read the if in the upcoming loop

			for _ = 1, self:GetLength() do
				local token = self:ReadToken()

				if token.value == "end" then
					break
				end

				if token.value == "else" then
					table.insert(data.statements, {
						body = self:ReadBody("end"),
						token = token,
					})
				else
					local expr = self:ReadExpression()

					self:ReadExpectValue("then")
					table.insert(data.statements, {
						expr = expr,
						body = self:ReadBody({["else"] = true, ["elseif"] = true, ["end"] = true}, true),
						token = token,
					})
				end

				self:Back() -- we want to read the else/elseif/end in the next iteration
			end
			table.insert(out, data)
		elseif token.value == "while" then
			local data = {}
			data.type = "while"
			data.expr = self:ReadExpression()
			self:ReadExpectValue("do")
			data.body = self:ReadBody("end")
			table.insert(out, data)
		elseif token.value == "for" then
			local data = {}
			data.type = "for"

			if self:GetToken(1).value == "=" then
				data.iloop = true
				data.name = self:ReadExpression()
				self:ReadExpectValue("=")
				data.val = self:ReadExpression()
				self:ReadExpectValue(",")
				data.max = self:ReadExpression()
				self:ReadExpectValue("do")
				data.body = self:ReadBody("end")
				table.insert(out, data)
			else

				local names = {}

				while true do
					table.insert(names, self:ReadExpression())

					if not self:IsValue(",") then
						break
					end

					self:NextToken()
				end

				self:ReadExpectValue("in")

				data.iloop = false
				data.names = names
				data.expression = self:ReadExpression()
				self:ReadExpectValue("do")
				data.body = self:ReadBody("end")

				table.insert(out, data)
			end
		elseif token.value == "function" then
			local data = {}
			data.type = "function2"
			data.arguments = {}
			data.is_local = false
			data.expression = self:ReadIndexExpression(true)
			data.body = self:ReadBody("end")
			table.insert(out, data)
		elseif token.type == "letter" then
			self:Back() -- we want to include the current letter in the loop
			table.insert(out, self:ReadAssignment())
		end
	end

	return out
end

if RELOAD then
	oh.Test()
end