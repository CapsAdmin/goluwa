local lua, oh = ...
oh = oh or _G.oh
lua = lua or oh.lua

local table_insert = table.insert
local table_remove = table.remove

local META = oh.BaseParser

-- separate into files
-- try to couple functions
-- Block, Statement, Expression, Value

runfile("parser/*", META)

function META:Block(stop, implicit_return)
	local node = self:Node("block")
	node.statements = {}

	for _ = 1, self:GetLength() do
		if not self:GetToken() or stop and stop[self:GetToken().value] then

			if implicit_return then
				local last = node.statements[#node.statements]
				if last and last.type == "expression" then
					local ret = self:Node("return")
					ret.implicit = true
					table_insert(node.statements, #node.statements, ret)
				end
			end

			break
		end

		local statement = self:Statement(node, implicit_return)

		if statement then
			if statement.type == "continue" then
				node.has_continue = true

				if self.loop_stack[1] then
					self.loop_stack[#self.loop_stack].has_continue = true
				end
			end

			table_insert(node.statements, statement)
		end
	end

	return node
end

function META:Statement(block, implicit_return)

	do
		if self:IsValue("return") then
			local node = self:Node("return")
			node.tokens["return"] = self:ReadToken()
			node.expressions = self:ExpressionList()
			return node
		elseif self:IsValue("break") then
			local node = self:Node("break")
			node.tokens["break"] = self:ReadToken()
			return node
		elseif self:IsValue("continue") then
			local node = self:Node("continue")
			node.tokens["continue"] = self:ReadToken()
			return node
		end
	end

	if self:IsCompilerOption() then
		return self:ReadCompilerOption()
	elseif self:IsGotoLabelStatement() then
		return self:ReadGotoLabelStatement()
	elseif self:IsInterfaceStatemenet() then
		return self:ReadInterfaceStatement()
	elseif self:IsGotoStatement() then
		return self:ReadGotoStatement()
	elseif self:IsRepeatStatement() then
		return self:ReadRepeatStatement()
	elseif self:IsFunctionStatement() then
		return self:ReadFunctionStatement()
	elseif self:IsLocalAssignmentStatement() then
		return self:ReadLocalAssignmentStatement()
	elseif self:IsDoStatement() then
		local node = self:ReadDoStatement()
		block.has_continue = node.block.has_continue
		return node
	elseif self:IsIfStatement() then
		return self:ReadIfStatement(block)
	elseif self:IsWhileStatement() then
		return self:ReadWhileStatement()
	elseif self:IsForStatement() then
		return self:ReadForStatement()
	elseif self:IsValue("{") then
		local node = self:Node("assignment")
		node.destructor = true

		node.lvalues = self:IdentifierList()
		node.tokens["="] = self:ReadExpectValue("=")
		node.rvalues = self:ExpressionList()
		return node
	elseif (self:IsType("letter") or self:IsValue("(")) and not lua.syntax.IsKeyword(self:GetToken()) then
		local node
		local start_token = self:GetToken()
		local expr = self:Expression()

		if self:IsValue("=") then
			node = self:Node("assignment")
			node.lvalues = {expr}
			node.tokens["="] = self:ReadToken()
			node.rvalues = self:ExpressionList()
		elseif self:IsValue(",") then
			node = self:Node("assignment")
			expr.tokens[","] = self:ReadToken()
			local list = self:ExpressionList()
			table_insert(list, 1, expr)
			node.lvalues = list
			node.tokens["="] = self:ReadExpectValue("=")
			node.rvalues = self:ExpressionList()
		elseif expr.suffixes and expr.suffixes[#expr.suffixes].type == "call" then
			node = self:Node("expression")
			node.value = expr
		elseif implicit_return then
			local node = self:Node("return")
			node.implicit = true
			node.expressions = self:ExpressionList()
			return node
		else
			self:Error("unexpected " .. start_token.type, start_token)
		end
		return node
	elseif self:IsValue(";") then
		local node = self:Node("end_of_statement")
		node.tokens[";"] = self:ReadToken()
		return node
	end

	local type = self:GetToken().type

	if lua.syntax.IsKeyword(self:GetToken()) then
		type = "keyword"
	end

	self:Error("unexpected " .. type)
end

function META:Expression(priority, stop_on_call)
	priority = priority or 0

	local token = self:GetToken()

	if not token then
		self:Error("attempted to read expression but reached end of code")
		return
	end

	local val

	if lua.syntax.IsUnaryOperator(token) then
		val = self:Node("unary")
		val.tokens["operator"] = self:ReadToken()
		val.operator = val.tokens["operator"].value
		val.expression = self:Expression(math.huge, stop_on_call)
	elseif self:IsValue("(") then
		local pleft = self:ReadToken()
		val = self:Expression(0, stop_on_call)
		if not val then
			self:Error("empty parentheses group", token)
		end

		val.tokens["left("] = val.tokens["left("] or {}
		table_insert(val.tokens["left("], pleft)

		val.tokens["right)"] = val.tokens["right)"] or {}
		table_insert(val.tokens["right)"], self:ReadExpectValue(")"))

	elseif self:IsAnonymousFunction() then
		val = self:AnonymousFunction()
	elseif token.type == "number" and self:GetTokenOffset(1).type == "letter" and self:GetTokenOffset(1).start == token.stop+1 then
		val = self:Node("value")
		val.value = self:ReadToken()
		val.annotation = self:ReadToken()
	elseif lua.syntax.IsValue(token) or (token.type == "letter" and not lua.syntax.IsKeyword(token)) then
		val = self:Node("value")
		val.value = self:ReadToken()

	elseif token.value == "{" then
		val = self:Table()
	elseif token.value == "<" then
		val = self:LSX()
	end

	if self:IsValue("as") and val then
		val.tokens["as"] = self:ReadToken()
		val.data_type = self:Type()
	end

	token = self:GetToken()

	if token and (token.value == "." or token.value == ":" or token.value == "[" or token.value == "(" or token.value == "{" or token.type == "string") then
		local suffixes = val.suffixes or {}

		for _ = 1, self:GetLength() do
			if not self:GetToken() then break end

			local node

			if self:IsValue(".") then
				node = self:Node("index")

				node.tokens["."] = self:ReadToken()
				node.value = self:Node("value")
				node.value.value = self:ReadExpectType("letter")
			elseif self:IsValue(":") then
				local nxt = self:GetTokenOffset(2)
				if nxt.type == "string" or nxt.value == "(" or nxt.value == "{" then
					node = self:Node("self_index")
					node.tokens[":"] = self:ReadToken()
					node.value = self:Node("value")
					node.value.value = self:ReadExpectType("letter")
				else
					break
				end
			elseif self:IsValue("[") then
				node = self:Node("index_expression")

				node.tokens["["] = self:ReadToken()
				node.value = self:Expression(0, stop_on_call)
				node.tokens["]"] = self:ReadExpectValue("]")
			elseif self:IsValue("(") then

				if stop_on_call then
					if suffixes[1] then
						val.suffixes = suffixes
					end
					return val
				end

				local start = self:GetToken()

				local pleft = self:ReadToken()
				node = self:Node("call")

				node.tokens["call("] = pleft
				node.arguments = self:ExpressionList()
				node.tokens["call)"] = self:ReadExpectValue(")", start)
			elseif self:IsValue("{") then
				node = self:Node("call")
				node.arguments = {self:Table()}
			elseif self:IsType"string" then
				node = self:Node("call")
				node.arguments = {self:Node("value")}
				node.arguments[1].value = self:ReadToken()
			else
				break
			end

			table_insert(suffixes, node)
		end

		if suffixes[1] then
			val.suffixes = suffixes
		end
	end

	if self:GetToken() then
		while self:GetToken() and lua.syntax.IsOperator(self:GetToken()) and lua.syntax.GetLeftOperatorPriority(self:GetToken()) > priority do

			local op = self:GetToken()
			local right_priority = lua.syntax.GetRightOperatorPriority(op)
			if not op or not right_priority then break end
			self:Advance(1)

			local right = self:Expression(right_priority, stop_on_call)
			local left = val

			val = self:Node("operator")
			val.operator = op.value
			val.tokens["operator"] = op
			val.left = left
			val.right = right
		end
	end

	return val
end

function META:LSX2()
	local node = self:Node("lsx2")
	node.class = self:ReadExpectType("letter")
	node.props = {}

	if self:IsValue("letter") then
		for i = 1, self:GetLength() do
			if self:IsValue("{") then break end

			if self:IsType("letter") then
				if self:GetTokenOffset(1).value == "=" then
					local prop = self:Node("prop")
					prop.key = self:ReadIdentifier()
					prop.tokens["="] = self:ReadExpectValue("=")
					prop.expression = self:Expression()
					table.insert(node.props, prop)
				end
			end
		end
	end

	self:ReadExpectValue("{")

	node.children = {}

	for i = 1, self:GetLength() do
		if self:IsValue("}") then break end

		if self:IsType("letter") then
			if self:GetTokenOffset(1).value == "=" then
				local prop = self:Node("prop")
				prop.key = self:ReadIdentifier()
				prop.tokens["="] = self:ReadExpectValue("=")
				prop.expression = self:Expression()
				table.insert(node.props, prop)
			elseif self:GetTokenOffset(1).value == "{" then
				table.insert(node.children, self:LSX2())
			else
				table.insert(node.children, self:Expression())
			end
		else
			table.insert(node.children, self:Expression())
		end
	end

	self:ReadExpectValue("}")

	return node
end

function META:LSX()
	if self:GetTokenOffset(1).value == "!" then
		self:Advance(2)
		local node = self:LSX2()
		self:ReadExpectValue(">")
		return node
	end

	local node = self:Node("lsx")
	node.tokens["start<"] = self:ReadExpectValue("<")

	node.class = self:ReadExpectType("letter")

	if self:IsType("letter") then
		node.props = {}
		while self:IsType("letter") do
			local prop = self:Node("prop")
			prop.key = self:ReadToken()
			prop.tokens["="] = self:ReadExpectValue("=")
			
			if lua.syntax.IsValue(self:GetToken()) then
				prop.value = self:ReadToken()
			else
				prop.tokens["{"] = self:ReadExpectValue("{")
				if not self:IsValue("}") then
					prop.expression = self:Expression()
				end
				prop.tokens["}"] = self:ReadExpectValue("}")
			end

			table.insert(node.props, prop)
		end
	end

	if self:IsValue("/") then
		node.tokens["/"] = self:ReadExpectValue("/")
		node.tokens["start>"] = self:ReadExpectValue(">")
		return node
	else
		node.tokens["start>"] = self:ReadExpectValue(">")

		node.children = {}
		for i = 1, self:GetLength() do
			if self:IsValue("<") and self:GetTokenOffset(1).value == "/" and self:GetTokenOffset(2).value == node.class.value then
				break
			elseif self:IsValue("<") and self:GetTokenOffset(1).value ~= "/" then
				table.insert(node.children, self:LSX())
			elseif self:IsValue("{") then
				self:ReadToken()
				if not self:IsValue("}") then
					table.insert(node.children, self:Expression())
				end
				self:ReadExpectValue("}")
			elseif self:IsValue(">") then
				break
			else
				table.insert(node.children, self:ReadToken())
			end
		end
		node.tokens["stop<"] = self:ReadToken()
		node.tokens["/"] = self:ReadExpectValue("/")
		node.tokens["identifier"] = self:ReadExpectValue(node.class.value)
		node.tokens["stop>"] = self:ReadToken()
	end
	return node
end

function META:ExpressionList()
    local out = {}

    for _ = 1, self:GetLength() do
        local exp = self:Expression()

        if not exp then
            break
        end

        table_insert(out, exp)

        if not self:IsValue(",") then
            break
        end

        exp.tokens[","] = self:ReadToken()
    end

    return out
end

function META:Table()
	local tree = self:Node("table")

	tree.children = {}
	tree.tokens["{"] = self:ReadExpectValue("{")

	for i = 1, self:GetLength() do
		local node

		if self:IsValue("}") then
			break
		elseif self:IsValue("[") then
			node = self:Node("table_expression_value")

			node.tokens["["] = self:ReadToken()
			node.key = self:Expression()
			node.tokens["]"] = self:ReadExpectValue("]")
			node.tokens["="] = self:ReadExpectValue("=")
			node.value = self:Expression()
			node.expression_key = true
		elseif self:IsType("letter") and self:GetTokenOffset(1).value == "=" then
			node = self:Node("table_key_value")

			node.key = self:Node("value")
			node.key.value = self:ReadToken()
			node.tokens["="] = self:ReadToken()
			node.value = self:Expression()
		elseif
			self:IsType("letter") and
			self:GetTokenOffset(1).value == ":" and
			self:GetTokenOffset(2).type == "letter" and
			(
				self:GetTokenOffset(3).type == "string" or
				self:GetTokenOffset(3).value == "(" or
				self:GetTokenOffset(3).value == "{"
			)
		then
			node = self:Node("table_index_value")
			node.value = self:Expression()
			node.key = i
			if not node.value then
				self:Error("expected expression got nothing")
			end
		elseif self:IsType("letter") and self:GetTokenOffset(1).value == ":" then
			node = self:Node("table_key_value")
			node.key = self:ReadIdentifier()

			if self:IsValue("=") then
				node.tokens["="] = self:ReadToken()
				node.value = self:Expression()
			end
		else
			node = self:Node("table_index_value")
			node.value = self:Expression()
			node.key = i
			if not node.value then
				self:Error("expected expression got nothing")
			end
		end

		table_insert(tree.children, node)

		if self:IsValue("}") then
			break
		end

		if not self:IsValue(",") and not self:IsValue(";") then
			self:Error("expected ".. oh.QuoteTokens(",", ";", "}") .. " got " .. (self:GetToken().value or "no token"))
		end

		node.tokens[","] = self:ReadToken()
	end

	tree.tokens["}"] = self:ReadExpectValue("}")

	return tree
end

if RELOAD then
	RELOAD = nil
	runfile("lua/libraries/oh/oh.lua")
	runfile("lua/libraries/oh/lua/test.lua")
	return
end

return function(on_error)
	local self = setmetatable({}, META)

	self.on_error = on_error

	return self
end