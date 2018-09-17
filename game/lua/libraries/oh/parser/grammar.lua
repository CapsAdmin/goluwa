local META = ... or oh.parser_meta

local table_insert = table.insert
local table_remove = table.remove

function META:ReadExpressions()
	local out = {}
	for _ = 1, self:GetLength() do
		local exp = self:ReadExpression()

		if not exp then return out end

		table_insert(out, exp)

		if not self:IsValue(",") then
			break
		end

		self:NextToken()
	end

	return out
end

function META:ReadArguments(stop)
	local out = {}
	for _ = 1, self:GetLength() do
		if not self:IsType("letter") and not self:IsValue("...") then
			break
		end

		local exp = self:ReadToken()

		if not exp then return out end

		table_insert(out, exp)

		if not self:IsValue(",") then
			break
		end

		self:NextToken()
	end

	return out
end


function META:ReadAssignment()
	local left = self:ReadExpressions()

	if self:ReadIfValue("=") then
		return {type = "assignment", left = left, right = self:ReadExpressions()}
	else
		return {type = "assignment", left = left}
	end
end

function META:ReadTable()
	local tree = {}
	tree.type = "table"
	tree.children = {}

	self:ReadExpectValue("{")

	for _ = 1, self:GetLength() do
		local token = self:GetToken()
		if not token then break end

		if token.value == "}" then
			break
		elseif self:IsValue("=", 1) then
			local index = self:GetToken()
			self:NextToken()
			self:NextToken()

			local data = {}
			data.type = "assignment"
			data.expressions = {self:ReadExpression()}
			data.indices = {index}

			table_insert(tree.children, data)
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
			table_insert(tree.children, data)
		else
			local data = {}
			data.type = "value"
			data.value =  self:ReadExpression()
			table_insert(tree.children, data)
		end

		if self:IsValue("}") then
			break
		end

		if not self:IsValue(",") and not self:IsValue(";") then
			self:Error("expected , or ; got " .. self:GetToken().value, nil,nil,level or 3)
		end

		self:NextToken()
	end

	self:ReadExpectValue("}")

	return tree
end

function META:ReadIndexExpression(hm, simple_call)
	local out = {}

	for _ = 1, self:GetLength() do
		local token = self:ReadToken()

		if not token then break end

		if token.type == "letter" and not oh.syntax.keywords[token.value] then
			if _ > 1 and (self:IsType("letter", -2) or self:IsValue("]", -2) or self:IsValue("}", -2)) then
				self:Back()
				break
			end
			table_insert(out, {type = "index", operator = _ == 1 and {value = ""} or self:GetToken(-2), value = token})
		elseif token.value == "[" then
			table_insert(out, {type = "index_expression", value = self:ReadExpression()})
			self:ReadExpectValue("]")
		elseif token.value == "(" and (not out[1] and not hm and not simple_call) then
			self:NextToken()
			local val = self:ReadExpression()
			table_insert(out, {type = "call2", value = val})
			print("!?")
		elseif token.value == "(" then
			self:Back()

			if simple_call then break end

			while self:ReadIsValue("(") do
				table_insert(out, {type = "call", arguments = simple_call and self:ReadArguments() or self:ReadExpressions()})
				self:ReadExpectValue(")")
			end

			self:Back()

			if self:IsType("letter") then
				break
			end
		elseif token.value == "{" then
			self:Back()
			table_insert(out, {type = "call", arguments = {self:ReadTable()}})
		elseif token.type == "string" then
			table_insert(out, {type = "call", arguments = {token}})
			if self:IsType("letter") then
				break
			end
		elseif token.value ~= "." and token.value ~= ":" then
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

	if oh.syntax.IsUnaryOperator(token) then
		local unary = self:ReadToken().value
		local exp = self:ReadExpression(0)
		val = {type = "unary", value = unary, argument = exp}
	elseif self:ReadIfValue("(") then
		val = self:ReadExpression(0)
		self:ReadExpectValue(")")

		if self:IsValue(".") or self:IsValue(":") or self:IsValue("[") or self:IsValue("(") or self:IsValue("{") or self:IsType("string") then
			local right = self:ReadIndexExpression(true)
			table_insert(right, 1, val)
			val = {type = "index_call_expression", value = right}
		end
	elseif oh.syntax.IsValue(token) then
		val = self:ReadToken()
	elseif token.value == ":" then
		val = {type = "index_call_expression", value = self:ReadIndexExpression()}
	elseif token.value == "{" then
		val = self:ReadTable()
	elseif token.value == "function" then
		self:NextToken()
		self:ReadExpectValue("(")
		local arguments = self:ReadArguments()
		self:ReadExpectValue(")")
		local body = self:ReadBody({["end"] = true})
		val = {type = "function", arguments = arguments, body = body}
	elseif token.type == "letter" and not oh.syntax.keywords[token.value] then
		val = {type = "index_call_expression", value = self:ReadIndexExpression()}
	elseif token.value == ";" then
		self:NextToken()
		return
	else
		return
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
	self.loop_stack = self.loop_stack or {}

	local out = {}

	for _ = 1, self:GetLength() do
		local token = self:ReadToken()

		if not token then break end

		if stop and stop[token.value] then
			return out
		end

		if token.value == "::" then
			local data = {}
			data.type = "goto_label"
			data.label = self:ReadExpectType("letter")
			table_insert(out, data)
			self:ReadExpectValue("::")
		elseif token.value == "goto" then
			local data = {}
			data.type = "goto"
			data.label = self:ReadExpectType("letter")
			table_insert(out, data)
		elseif token.value == "continue" then
			local data = {}
			data.type = "continue"
			table_insert(out, data)

			if self.loop_stack[1] then
				self.loop_stack[#self.loop_stack].has_continue = true
			end
		elseif token.value == "repeat" then
			local data = {}
			data.type = "repeat"

			table_insert(self.loop_stack, data)

			data.body = self:ReadBody({["until"] = true})
			data.expr = self:ReadExpression()
			table_insert(out, data)

			table_remove(self.loop_stack)
		elseif token.value == "local" then
			if self:GetToken().value == "function" then
				self:NextToken()
				local data = {}
				data.type = "function"
				data.is_local = true
				data.index_expression = self:ReadExpectType("letter")
				self:ReadExpectValue("(")
				data.arguments = self:ReadArguments()
				self:ReadExpectValue(")")
				data.body = self:ReadBody({["end"] = true})
				table_insert(out, data)
			else
				local data = self:ReadAssignment()

				data.is_local = true
				table_insert(out, data)
			end
		elseif token.value == "return" then
			local data = {}
			data.type = "return"
			data.expressions = self:ReadExpressions()
			table_insert(out, data)
		elseif token.value == "break" then
			local data = {}
			data.type = "break"
			table_insert(out, data)
		elseif token.value == "do" then
			local data = {}
			data.type = "do"
			data.body = self:ReadBody({["end"] = true})
			table_insert(out, data)
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
					table_insert(data.statements, {
						body = self:ReadBody({["end"] = true}),
						token = token,
					})
				else
					local expr = self:ReadExpression()
					self:ReadExpectValue("then")

					table_insert(data.statements, {
						expr = expr,
						body = self:ReadBody({["else"] = true, ["elseif"] = true, ["end"] = true}),
						token = token,
					})
				end

				self:Back() -- we want to read the else/elseif/end in the next iteration
			end
			table_insert(out, data)
		elseif token.value == "while" then
			local data = {}
			data.type = "while"
			data.expr = self:ReadExpression()
			self:ReadExpectValue("do")

			table_insert(self.loop_stack, data)

			data.body = self:ReadBody({["end"] = true})
			table_insert(out, data)

			table.remove(self.loop_stack)
		elseif token.value == "for" then
			local data = {}
			data.type = "for"

			table_insert(self.loop_stack, data)

			if self:GetToken(1).value == "=" then
				data.iloop = true
				data.name = self:ReadExpectType("letter")
				self:ReadExpectValue("=")
				data.val = self:ReadExpression()
				self:ReadExpectValue(",")
				data.max = self:ReadExpression()

				if self:IsValue(",") then
					self:NextToken()
					data.incr = self:ReadExpression()
				end

				self:ReadExpectValue("do")
			else
				local names = self:ReadArguments()

				self:ReadExpectValue("in")

				data.iloop = false
				data.names = names
				data.expressions = self:ReadExpressions()
				self:ReadExpectValue("do")
			end

			local body = self:ReadBody({["end"] = true})

			data.body = body

			table_insert(out, data)

			table.remove(self.loop_stack)
		elseif token.value == "function" then
			local data = {}
			data.type = "function"
			data.arguments = {}
			data.is_local = false
			data.index_expression = self:ReadIndexExpression(true, true)
			self:ReadExpectValue("(")
			data.arguments = self:ReadArguments()
			self:ReadExpectValue(")")
			data.body = self:ReadBody({["end"] = true})
			table_insert(out, data)
		elseif token.value == "(" then
			local expr = self:ReadExpression()
			self:ReadExpectValue(")")
			if
				not self:IsValue(".") and
				not self:IsValue(":") and
				not self:IsValue("[") and
				not self:IsValue("(") and
				not self:IsValue("{")
			then
				self:Error("expected .:[({ got " .. self:GetToken().value, nil,nil,level or 3)
			end
			self:NextToken()
			self:Back()

			local right = self:ReadIndexExpression(true)
			table_insert(right, 1, expr)
			table_insert(out, {type = "index_call_expression", value = right})
		elseif token.type == "letter" then
			self:Back() -- we want to include the current letter in the loop
			table_insert(out, self:ReadAssignment())
		elseif token.value ~= ";" then -- hmm
			self:Back()
			self:Error("unexpected token " .. token.value)
		end
	end

	return out
end

if RELOAD then
--	oh.Test()
end