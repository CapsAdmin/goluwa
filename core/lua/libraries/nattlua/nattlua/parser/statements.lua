local META = ...
local runtime_syntax = require("nattlua.syntax.runtime")
local typesystem_syntax = require("nattlua.syntax.typesystem")

do -- destructure statement
	function META:IsDestructureStatement(offset--[[#: number]])
		offset = offset or 0
		return (
				self:IsValue("{", offset + 0) and
				self:IsType("letter", offset + 1)
			) or
			(
				self:IsType("letter", offset + 0) and
				self:IsValue(",", offset + 1) and
				self:IsValue("{", offset + 2)
			)
	end

	function META:IsLocalDestructureAssignmentStatement()
		if self:IsValue("local") then
			if self:IsValue("type", 1) then return self:IsDestructureStatement(2) end

			return self:IsDestructureStatement(1)
		end
	end

	function META:ParseDestructureAssignmentStatement()
		if not self:IsDestructureStatement() then return end

		local node = self:StartNode("statement", "destructure_assignment")

		do
			if self:IsType("letter") then
				node.default = self:ParseValueExpressionToken()
				node.default_comma = self:ExpectValue(",")
			end

			node.tokens["{"] = self:ExpectValue("{")
			node.left = self:ParseMultipleValues(nil, self.ParseIdentifier)
			node.tokens["}"] = self:ExpectValue("}")
			node.tokens["="] = self:ExpectValue("=")
			node.right = self:ExpectRuntimeExpression(0)
		end

		node = self:EndNode(node)
		return node
	end

	function META:ParseLocalDestructureAssignmentStatement()
		if not self:IsLocalDestructureAssignmentStatement() then return end

		local node = self:StartNode("statement", "local_destructure_assignment")
		node.tokens["local"] = self:ExpectValue("local")

		if self:IsValue("type") then
			node.tokens["type"] = self:ExpectValue("type")
			node.environment = "typesystem"
		end

		do -- remaining
			if self:IsType("letter") then
				node.default = self:ParseValueExpressionToken()
				node.default_comma = self:ExpectValue(",")
			end

			node.tokens["{"] = self:ExpectValue("{")
			node.left = self:ParseMultipleValues(nil, self.ParseIdentifier)
			node.tokens["}"] = self:ExpectValue("}")
			node.tokens["="] = self:ExpectValue("=")
			node.right = self:ExpectRuntimeExpression(0)
		end

		node = self:EndNode(node)
		return node
	end
end

do
	function META:ParseFunctionNameIndex()
		if not runtime_syntax:IsValue(self:GetToken()) then return end

		local node = self:ParseValueExpressionToken()
		local first = node
		first.standalone_letter = node

		while self:IsValue(".") or self:IsValue(":") do
			local left = node
			local self_call = self:IsValue(":")
			node = self:StartNode("expression", "binary_operator")
			node.value = self:ParseToken()
			node.right = self:ParseValueExpressionType("letter")
			node.left = left
			node.right.self_call = self_call
			node.is_left_assignment = true
			node = self:EndNode(node)
		end

		return node
	end

	function META:ParseFunctionStatement()
		if not self:IsValue("function") then return end

		local node = self:StartNode("statement", "function")
		node.tokens["function"] = self:ExpectValue("function")
		node.expression = self:ParseFunctionNameIndex()

		if node.expression and node.expression.kind == "binary_operator" then
			node.self_call = node.expression.right.self_call
		end

		if self:IsValue("<|") then
			node.kind = "type_function"
			self:ParseTypeFunctionBody(node)
		else
			self:ParseFunctionBody(node)
		end

		node = self:EndNode(node)
		return node
	end

	function META:ParseAnalyzerFunctionStatement()
		if not (self:IsValue("analyzer") and self:IsValue("function", 1)) then return end

		local node = self:StartNode("statement", "analyzer_function")
		node.tokens["analyzer"] = self:ExpectValue("analyzer")
		node.tokens["function"] = self:ExpectValue("function")
		local force_upvalue

		if self:IsValue("^") then
			force_upvalue = true
			node.tokens["^"] = self:ParseToken()
		end

		node.expression = self:ParseFunctionNameIndex()

		do -- hacky
			if node.expression.left then
				node.expression.left.standalone_letter = node
				node.expression.left.force_upvalue = force_upvalue
			else
				node.expression.standalone_letter = node
				node.expression.force_upvalue = force_upvalue
			end

			if node.expression.value.value == ":" then node.self_call = true end
		end

		self:ParseAnalyzerFunctionBody(node, true)
		node = self:EndNode(node)
		return node
	end
end

function META:ParseLocalFunctionStatement()
	if not (self:IsValue("local") and self:IsValue("function", 1)) then return end

	local node = self:StartNode("statement", "local_function")
	node.tokens["local"] = self:ExpectValue("local")
	node.tokens["function"] = self:ExpectValue("function")
	node.tokens["identifier"] = self:ExpectType("letter")
	self:ParseFunctionBody(node)
	node = self:EndNode(node)
	return node
end

function META:ParseLocalAnalyzerFunctionStatement()
	if
		not (
			self:IsValue("local") and
			self:IsValue("analyzer", 1) and
			self:IsValue("function", 2)
		)
	then
		return
	end

	local node = self:StartNode("statement", "local_analyzer_function")
	node.tokens["local"] = self:ExpectValue("local")
	node.tokens["analyzer"] = self:ExpectValue("analyzer")
	node.tokens["function"] = self:ExpectValue("function")
	node.tokens["identifier"] = self:ExpectType("letter")
	self:ParseAnalyzerFunctionBody(node, true)
	node = self:EndNode(node)
	return node
end

function META:ParseLocalTypeFunctionStatement()
	if
		not (
			self:IsValue("local") and
			self:IsValue("function", 1) and
			(
				self:IsValue("<|", 3) or
				self:IsValue("!", 3)
			)
		)
	then
		return
	end

	local node = self:StartNode("statement", "local_type_function")
	node.tokens["local"] = self:ExpectValue("local")
	node.tokens["function"] = self:ExpectValue("function")
	node.tokens["identifier"] = self:ExpectType("letter")
	self:ParseTypeFunctionBody(node)
	node = self:EndNode(node)
	return node
end

function META:ParseBreakStatement()
	if not self:IsValue("break") then return nil end

	local node = self:StartNode("statement", "break")
	node.tokens["break"] = self:ExpectValue("break")
	node = self:EndNode(node)
	return node
end

function META:ParseDoStatement()
	if not self:IsValue("do") then return nil end

	local node = self:StartNode("statement", "do")
	node.tokens["do"] = self:ExpectValue("do")
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["do"])
	node = self:EndNode(node)
	return node
end

function META:ParseGenericForStatement()
	if not self:IsValue("for") then return nil end

	local node = self:StartNode("statement", "generic_for")
	node.tokens["for"] = self:ExpectValue("for")
	node.identifiers = self:ParseMultipleValues(nil, self.ParseIdentifier)
	node.tokens["in"] = self:ExpectValue("in")
	node.expressions = self:ParseMultipleValues(math.huge, self.ExpectRuntimeExpression, 0)
	node.tokens["do"] = self:ExpectValue("do")
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["do"])
	node = self:EndNode(node)
	return node
end

function META:ParseGotoLabelStatement()
	if not self:IsValue("::") then return nil end

	local node = self:StartNode("statement", "goto_label")
	node.tokens["::"] = self:ExpectValue("::")
	node.tokens["identifier"] = self:ExpectType("letter")
	node.tokens["::"] = self:ExpectValue("::")
	node = self:EndNode(node)
	return node
end

function META:ParseGotoStatement()
	if not self:IsValue("goto") or not self:IsType("letter", 1) then return nil end

	local node = self:StartNode("statement", "goto")
	node.tokens["goto"] = self:ExpectValue("goto")
	node.tokens["identifier"] = self:ExpectType("letter")
	node = self:EndNode(node)
	return node
end

function META:ParseIfStatement()
	if not self:IsValue("if") then return nil end

	local node = self:StartNode("statement", "if")
	node.expressions = {}
	node.statements = {}
	node.tokens["if/else/elseif"] = {}
	node.tokens["then"] = {}

	for i = 1, self:GetLength() do
		local token

		if i == 1 then
			token = self:ExpectValue("if")
		else
			token = self:ParseValues({
				["else"] = true,
				["elseif"] = true,
				["end"] = true,
			})
		end

		if not token then return end -- TODO: what happens here? :End is never called
		node.tokens["if/else/elseif"][i] = token

		if token.value ~= "else" then
			node.expressions[i] = self:ExpectRuntimeExpression(0)
			node.tokens["then"][i] = self:ExpectValue("then")
		end

		node.statements[i] = self:ParseStatements({
			["end"] = true,
			["else"] = true,
			["elseif"] = true,
		})

		if self:IsValue("end") then break end
	end

	node.tokens["end"] = self:ExpectValue("end")
	node = self:EndNode(node)
	return node
end

function META:ParseLocalAssignmentStatement()
	if not self:IsValue("local") then return end

	local node = self:StartNode("statement", "local_assignment")
	node.tokens["local"] = self:ExpectValue("local")

	if self.TealCompat and self:IsValue(",", 1) then
		node.left = self:ParseMultipleValues(nil, self.ParseIdentifier, false)

		if self:IsValue(":") then
			self:Advance(1)
			local expressions = self:ParseMultipleValues(nil, self.ParseTealExpression, 0)

			for i, v in ipairs(node.left) do
				v.type_expression = expressions[i]
				v.tokens[":"] = self:NewToken("symbol", ":")
			end
		end
	else
		node.left = self:ParseMultipleValues(nil, self.ParseIdentifier)
	end

	if self:IsValue("=") then
		node.tokens["="] = self:ExpectValue("=")
		node.right = self:ParseMultipleValues(nil, self.ExpectRuntimeExpression, 0)
	end

	node = self:EndNode(node)
	return node
end

function META:ParseNumericForStatement()
	if not (self:IsValue("for") and self:IsValue("=", 2)) then return nil end

	local node = self:StartNode("statement", "numeric_for")
	node.tokens["for"] = self:ExpectValue("for")
	node.identifiers = self:ParseMultipleValues(1, self.ParseIdentifier)
	node.tokens["="] = self:ExpectValue("=")
	node.expressions = self:ParseMultipleValues(3, self.ExpectRuntimeExpression, 0)
	node.tokens["do"] = self:ExpectValue("do")
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["do"])
	node = self:EndNode(node)
	return node
end

function META:ParseRepeatStatement()
	if not self:IsValue("repeat") then return nil end

	local node = self:StartNode("statement", "repeat")
	node.tokens["repeat"] = self:ExpectValue("repeat")
	node.statements = self:ParseStatements({["until"] = true})
	node.tokens["until"] = self:ExpectValue("until")
	node.expression = self:ExpectRuntimeExpression()
	node = self:EndNode(node)
	return node
end

function META:ParseSemicolonStatement()
	if not self:IsValue(";") then return nil end

	local node = self:StartNode("statement", "semicolon")
	node.tokens[";"] = self:ExpectValue(";")
	node = self:EndNode(node)
	return node
end

function META:ParseReturnStatement()
	if not self:IsValue("return") then return nil end

	local node = self:StartNode("statement", "return")
	node.tokens["return"] = self:ExpectValue("return")
	node.expressions = self:ParseMultipleValues(nil, self.ParseRuntimeExpression, 0)
	node = self:EndNode(node)
	return node
end

function META:ParseWhileStatement()
	if not self:IsValue("while") then return nil end

	local node = self:StartNode("statement", "while")
	node.tokens["while"] = self:ExpectValue("while")
	node.expression = self:ExpectRuntimeExpression()
	node.tokens["do"] = self:ExpectValue("do")
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["do"])
	node = self:EndNode(node)
	return node
end

function META:ParseContinueStatement()
	if not self:IsValue("continue") then return nil end

	local node = self:StartNode("statement", "continue")
	node.tokens["continue"] = self:ExpectValue("continue")
	node = self:EndNode(node)
	return node
end

function META:ParseDebugCodeStatement()
	if self:IsType("analyzer_debug_code") then
		local node = self:StartNode("statement", "analyzer_debug_code")
		node.lua_code = self:ParseValueExpressionType("analyzer_debug_code")
		node = self:EndNode(node)
		return node
	elseif self:IsType("parser_debug_code") then
		local token = self:ExpectType("parser_debug_code")
		assert(loadstring("local parser = ...;" .. token.value:sub(3)))(self)
		local node = self:StartNode("statement", "parser_debug_code")
		local code = self:StartNode("expression", "value")
		code.value = token
		code = self:EndNode(code)
		node.lua_code = code
		node = self:EndNode(node)
		return node
	end
end

function META:ParseLocalTypeAssignmentStatement()
	if
		not (
			self:IsValue("local") and
			self:IsValue("type", 1) and
			runtime_syntax:GetTokenType(self:GetToken(2)) == "letter"
		)
	then
		return
	end

	local node = self:StartNode("statement", "local_assignment")
	node.tokens["local"] = self:ExpectValue("local")
	node.tokens["type"] = self:ExpectValue("type")
	node.left = self:ParseMultipleValues(nil, self.ParseIdentifier)
	node.environment = "typesystem"

	if self:IsValue("=") then
		node.tokens["="] = self:ExpectValue("=")
		self:PushParserEnvironment("typesystem")
		node.right = self:ParseMultipleValues(nil, self.ExpectTypeExpression, 0)
		self:PopParserEnvironment()
	end

	node = self:EndNode(node)
	return node
end

function META:ParseTypeAssignmentStatement()
	if not (self:IsValue("type") and (self:IsType("letter", 1) or self:IsValue("^", 1))) then
		return
	end

	local node = self:StartNode("statement", "assignment")
	node.tokens["type"] = self:ExpectValue("type")
	node.left = self:ParseMultipleValues(nil, self.ExpectTypeExpression, 0)
	node.environment = "typesystem"

	if self:IsValue("=") then
		node.tokens["="] = self:ExpectValue("=")
		self:PushParserEnvironment("typesystem")
		node.right = self:ParseMultipleValues(nil, self.ExpectTypeExpression, 0)
		self:PopParserEnvironment()
	end

	node = self:EndNode(node)
	return node
end

function META:ParseCallOrAssignmentStatement()
	local start = self:GetToken()
	self:SuppressOnNode()
	local left = self:ParseMultipleValues(math.huge, self.ExpectRuntimeExpression, 0)

	if
		(
			self:IsValue("+") or
			self:IsValue("-") or
			self:IsValue("*") or
			self:IsValue("/") or
			self:IsValue("%") or
			self:IsValue("^") or
			self:IsValue("..")
		) and
		self:IsValue("=", 1)
	then
		-- roblox compound assignment
		local op_token = self:ParseToken()
		local eq_token = self:ParseToken()
		local bop = self:StartNode("expression", "binary_operator")
		bop.left = left[1]
		bop.value = op_token
		bop.right = self:ExpectRuntimeExpression(0)
		self:EndNode(bop)
		local node = self:StartNode("statement", "assignment", left[1])
		node.tokens["="] = eq_token
		node.left = left

		for i, v in ipairs(node.left) do
			v.is_left_assignment = true
		end

		node.right = {bop}
		self:ReRunOnNode(node.left)
		node = self:EndNode(node)
		return node
	end

	if self:IsValue("=") then
		local node = self:StartNode("statement", "assignment", left[1])
		node.tokens["="] = self:ExpectValue("=")
		node.left = left

		for i, v in ipairs(node.left) do
			v.is_left_assignment = true
		end

		node.right = self:ParseMultipleValues(math.huge, self.ExpectRuntimeExpression, 0)
		self:ReRunOnNode(node.left)
		node = self:EndNode(node)
		return node
	end

	if left[1] and (left[1].kind == "postfix_call") and not left[2] then
		local node = self:StartNode("statement", "call_expression", left[1])
		node.value = left[1]
		node.tokens = left[1].tokens
		self:ReRunOnNode(left)
		node = self:EndNode(node)
		return node
	end

	self:Error(
		"expected assignment or call expression got $1 ($2)",
		start,
		self:GetToken(),
		self:GetToken().type,
		self:GetToken().value
	)
end