local runtime_syntax = require("nattlua.syntax.runtime")
local ipairs = ipairs
local assert = assert
local META = loadfile("nattlua/transpiler/emitter.lua")()

function META:EmitExpression(node)
	if node.tokens["("] then
		for i = #node.tokens["("], 1, -1 do
			self:EmitToken(node.tokens["("][i])
		end
	end

	if node.kind == "binary_operator" then
		self:EmitBinaryOperator(node)
	elseif node.kind == "function" then
		self:EmitAnonymousFunction(node)
	elseif node.kind == "analyzer_function" then
		self:EmitTypeFunction(node)
	elseif node.kind == "table" then
		self:EmitTable(node)
	elseif node.kind == "prefix_operator" then
		self:EmitPrefixOperator(node)
	elseif node.kind == "postfix_operator" then
		self:EmitPostfixOperator(node)
	elseif node.kind == "postfix_call" then
		self:EmitCall(node)
	elseif node.kind == "postfix_expression_index" then
		self:EmitExpressionIndex(node)
	elseif node.kind == "value" then
		if node.value.type == "letter" then
			self:EmitToken(node.value, "")
			node.value.whitespace = nil

			if not node:GetLastType() or not node:GetLastType():GetUpvalue() then
				self:Emit("globalThis.")
			end

			self:EmitToken(node.value)
		elseif node.value.value == "..." then
			self:EmitToken(node.value, "__args")
		else
			if node.tokens["is"] then
				self:EmitToken(node.value, tostring(node.result_is))
			else
				self:EmitToken(node.value)
			end
		end
	elseif node.kind == "import" then
		self:EmitImportExpression(node)
	elseif node.kind == "type_table" then
		self:EmitTableType(node)
	else
		error("unhandled token type " .. node.kind)
	end

	if node.tokens[")"] then
		for _, node in ipairs(node.tokens[")"]) do
			self:EmitToken(node)
		end
	end
end

function META:EmitVarargTuple(node)
	self:Emit(tostring(node:GetLastType()))
end

function META:EmitExpressionIndex(node)
	self:Emit("OP['.']")
	self:EmitToken(node.tokens["["], "(")
	self:EmitExpression(node.left)
	self:Emit(",")
	self:EmitExpression(node.expression)
	self:EmitToken(node.tokens["]"], ")")
end

function META:EmitCall(node)
	self:Emit("OP['call']")
	self:Emit("(")
	self:EmitExpression(node.left)

	if node.expressions[1] then
		self:Emit(",")

		if node.tokens["call("] then self:EmitToken(node.tokens["call("], "") end

		self:EmitExpressionList(node.expressions)

		if node.tokens["call)"] then self:EmitToken(node.tokens["call)"], "") end
	end

	self:Emit(")")
end

local translate = {
	["and"] = "&&",
	["or"] = "||",
	[".."] = "+",
	["~="] = "!=",
}

function META:EmitBinaryOperator(node)
	local func_chunks = runtime_syntax:GetFunctionForBinaryOperator(node.value)

	if func_chunks then
		self:Emit(func_chunks[1])

		if node.left then self:EmitExpression(node.left) end

		self:Emit(func_chunks[2])

		if node.right then self:EmitExpression(node.right) end

		self:Emit(func_chunks[3])
		self.operator_transformed = true
	else
		-- move whitespace
		if node.left and node.left.value then
			self:EmitToken(node.left.value, "")
			node.left.value.whitespace = nil
		end

		self:Emit("OP['")
		self:Emit(node.value.value)
		self:Emit("'](")

		if node.left then self:EmitExpression(node.left) end

		self:Emit(",")

		if node.right then
			if node.value.value == "." or node.value.value == ":" then
				self:EmitToken(node.right, "")
				self:Emit("'")
				self:EmitToken(node.right.value)
				self:Emit("'")
			else
				self:EmitExpression(node.right)
			end
		end

		self:Emit(")")
	end
end

do
	local function emit_function_body(self, node, analyzer_function)
		self:EmitToken(node.tokens["arguments("])

		if node.self_call then
			self:Emit("self")

			if #node.identifiers >= 1 then self:Emit(", ") end
		end

		self:EmitIdentifierList(node.identifiers)
		self:EmitToken(node.tokens["arguments)"])
		self:Emit(" => {")

		if self.config.type_annotations and node:GetLastType() and not analyzer_function then
			--self:Emit(" --[[ : ")
			local str = {}
			-- this iterates the first return tuple
			local obj = node:GetLastType():GetContract() or node:GetLastType()

			if obj.Type == "function" then
				for i, v in ipairs(obj:GetOutputSignature():GetData()) do
					str[i] = tostring(v)
				end
			else
				str[1] = tostring(obj)
			end

			if str[1] then
				self:Emit(": ")
				self:Emit(table.concat(str, ", "))
			end
		--self:Emit(" ]] ")
		end

		self:Whitespace("\n")
		self:EmitBlock(node.statements)
		self:Whitespace("\t")
		self:EmitToken(node.tokens["end"], "}")
	end

	function META:EmitAnonymousFunction(node)
		emit_function_body(self, node)
	end

	function META:EmitLocalFunction(node)
		self:Whitespace("\t")
		self:EmitToken(node.tokens["function"], "")
		self:EmitToken(node.tokens["local"], "let")
		self:EmitToken(node.tokens["identifier"])
		self:Emit(";")
		self:EmitToken(node.tokens["identifier"])
		self:Emit("=")
		emit_function_body(self, node)
	end

	function META:EmitLocalTypeFunction(node)
		self:Whitespace("\t")
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["type"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitIdentifier(node.identifier)
		emit_function_body(self, node)
	end

	function META:EmitLocalGenericsTypeFunction(node)
		self:Whitespace("\t")
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitIdentifier(node.identifier)
		emit_function_body(self, node, true)
	end

	function META:EmitFunction(node)
		self:Whitespace("\t")

		if node.tokens["local"] then
			self:EmitToken(node.tokens["local"])
			self:Whitespace(" ")
		end

		self:EmitToken(node.tokens["function"], "")
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"], "")

		if
			node.expression and
			node.expression.value.value == "." or
			node.expression.value.value == ":"
		then
			self:Emit("OP['='](")
			self:EmitExpression(node.expression.left)
			self:Emit(",")
			self:Emit("'")
			self:EmitExpression(node.expression.right)
			self:Emit("'")
			self:Emit(",")
		else
			self:EmitExpression(node.expression or node.identifier)
			self:Emit(" = ")
		end

		emit_function_body(self, node)
		self:Emit(")")
	end

	function META:EmitTypeFunctionStatement(node)
		self:Whitespace("\t")

		if node.tokens["local"] then
			self:EmitToken(node.tokens["local"])
			self:Whitespace(" ")
		end

		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitExpression(node.expression or node.identifier)
		emit_function_body(self, node)
	end
end

function META:EmitTable(tree)
	if tree.spread then self:Emit("table.mergetables") end

	local is_array = tree:GetLastType() and tree:GetLastType():IsNumericallyIndexed()
	local during_spread = false

	if is_array then
		self:EmitToken(tree.tokens["{"], "[")
	else
		self:EmitToken(tree.tokens["{"])
	end

	if tree.children[1] then
		self:Whitespace("\n")
		self:Whitespace("\t+")

		for i, node in ipairs(tree.children) do
			self:Whitespace("\t")

			if node.kind == "table_index_value" then
				if node.spread then
					if during_spread then
						self:Emit("},")
						during_spread = false
					end

					self:EmitExpression(node.spread.expression)
				else
					self:EmitExpression(node.value_expression)
				end
			elseif node.kind == "table_key_value" then
				if tree.spread and not during_spread then
					during_spread = true
					self:Emit("{")
				end

				self:EmitToken(node.tokens["identifier"])
				self:EmitToken(node.tokens["="], ":")
				self:EmitExpression(node.value_expression)
			elseif node.kind == "table_expression_value" then
				self:EmitToken(node.tokens["["])
				self:Whitespace("(")
				self:EmitExpression(node.expressions[1])
				self:Whitespace(")")
				self:EmitToken(node.tokens["]"])
				self:EmitToken(node.tokens["="], ":")
				self:EmitExpression(node.expressions[2])
			end

			if tree.tokens["separators"][i] then
				self:EmitToken(tree.tokens["separators"][i])
			else
				self:Whitespace(",")
			end

			self:Whitespace("\n")
		end

		self:Whitespace("\t-")
		self:Whitespace("\t")
	end

	if during_spread then self:Emit("}") end

	if is_array then
		self:EmitToken(tree.tokens["}"], "]")
	else
		self:EmitToken(tree.tokens["}"])
	end
end

local translate = {
	["not"] = "!",
}

function META:EmitPrefixOperator(node)
	local func_chunks = runtime_syntax:GetFunctionForPrefixOperator(node.value)

	if self.TranslatePrefixOperator then
		func_chunks = self:TranslatePrefixOperator(node) or func_chunks
	end

	if func_chunks then
		self:Emit(func_chunks[1])
		self:EmitExpression(node.right)
		self:Emit(func_chunks[2])
		self.operator_transformed = true
	else
		if runtime_syntax:IsKeyword(node.value) then
			self:Whitespace("?")

			if translate[node.value.value] then
				self:EmitToken(node.value, translate[node.value.value])
			else
				self:EmitToken(node.value)
			end

			self:Whitespace("?")
			self:EmitExpression(node.right)
		else
			if node.value.value == "#" then
				self:Emit("OP['")
				self:Emit(node.value.value)
				self:Emit("'](")
				self:EmitExpression(node.right)
				self:Emit(")")
			else
				if translate[node.value.value] then
					self:EmitToken(node.value, translate[node.value.value])
				else
					self:EmitToken(node.value)
				end

				self:EmitExpression(node.right)
			end
		end
	end
end

function META:EmitPostfixOperator(node)
	local func_chunks = runtime_syntax:GetFunctionForPostfixOperator(node.value)
	-- no such thing as postfix operator in lua,
	-- so we have to assume that there's a translation
	assert(func_chunks)
	self:Emit(func_chunks[1])
	self:EmitExpression(node.left)
	self:Emit(func_chunks[2])
	self.operator_transformed = true
end

function META:EmitBlock(statements)
	self:Whitespace("\t+")
	self:EmitStatements(statements)
	self:Whitespace("\t-")
end

function META:TranslateToken(token)
	if token.type == "line_comment" then
		return "//" .. token.value:sub(3)
	elseif token.type == "multiline_comment" then
		local content = token.value:sub(5, -3):gsub("%*/", "* /"):gsub("/%*", "/ *")
		return "/*" .. content .. "*/"
	end
end

function META:EmitIfStatement(node)
	for i = 1, #node.statements do
		self:Whitespace("\t")

		if node.expressions[i] then
			if node.tokens["if/else/elseif"][i].value == "if" then
				self:EmitToken(node.tokens["if/else/elseif"][i], "if")
			elseif node.tokens["if/else/elseif"][i].value == "elseif" then
				self:EmitToken(node.tokens["if/else/elseif"][i], "else if")
			end

			if not node.expressions[i].tokens["("] then self:Emit("(") end

			self:EmitExpression(node.expressions[i])

			if not node.expressions[i].tokens[")"] then self:Emit(")") end

			self:EmitToken(node.tokens["then"][i], "{")
		elseif node.tokens["if/else/elseif"][i] then
			self:EmitToken(node.tokens["if/else/elseif"][i])
			self:Whitespace(" ")
			self:Emit("{")
		end

		self:Whitespace("\n")
		self:Whitespace("\t")
		self:EmitBlock(node.statements[i])
		self:Whitespace("\t")

		if i ~= #node.statements then self:Emit("}") end
	end

	self:Whitespace("\t")
	self:EmitToken(node.tokens["end"], "}")
end

function META:EmitGenericForStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["for"])
	self:Emit("(")
	self:Emit("let ")
	self:Emit("[")
	self:Whitespace(" ")
	self:EmitIdentifierList(node.identifiers)
	self:Whitespace(" ")
	self:Emit("]")
	self:EmitToken(node.tokens["in"], "of")
	self:Whitespace(" ")
	self:Emit("(")
	self:EmitExpressionList(node.expressions)
	self:Emit(")")
	self:Whitespace(" ")
	self:Emit(")")
	self:EmitToken(node.tokens["do"], "{")
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["end"], "}")
end

function META:EmitNumericForStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["for"])
	self:Emit("(")
	self:Emit("let")
	self:Whitespace(" ")
	self:EmitIdentifier(node.identifiers[1])
	self:Whitespace(" ")
	self:EmitToken(node.tokens["="])
	self:Whitespace(" ")
	self:EmitExpression(node.expressions[1])
	self:EmitToken(node.expressions[1].tokens[","], ";")
	self:EmitIdentifier(node.identifiers[1])
	self:Emit("<=")
	self:EmitExpression(node.expressions[2])

	if node.expressions[2].tokens[","] then
		self:EmitToken(node.expressions[2].tokens[","], ";")
	else
		self:Emit(";")
	end

	self:EmitIdentifier(node.identifiers[1])

	if node.expressions[3] then
		self:Emit(" ")
		self:Emit("+")
		self:Emit("=")
		self:EmitExpression(node.expressions[3])
	else
		self:Emit("++")
	end

	self:Whitespace(" ")
	self:Emit(")")
	self:EmitToken(node.tokens["do"], "{")
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["end"], "}")
end

function META:EmitWhileStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["while"])
	self:Whitespace(" ")
	self:Emit("(")
	self:EmitExpression(node.expression)
	self:Emit(")")
	self:Whitespace(" ")
	self:EmitToken(node.tokens["do"], "{")
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["end"], "}")
end

function META:EmitRepeatStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["repeat"], "while (true) {")
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\t")
	self:Emit(";if (")
	self:EmitExpression(node.expression)
	self:Emit(") break;")
	self:EmitToken(node.tokens["until"], "}")
end

function META:EmitLabelStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["::"][1])
	self:EmitToken(node.tokens["identifier"])
	self:EmitToken(node.tokens["::"][2])
end

function META:EmitGotoStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["goto"])
	self:Whitespace(" ")
	self:EmitToken(node.tokens["identifier"])
end

function META:EmitBreakStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["break"])
end

function META:EmitDoStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["do"], "{")
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["end"], "}")
end

function META:EmitReturnStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["return"])
	self:Whitespace(" ")
	self:EmitExpressionList(node.expressions)
end

function META:EmitSemicolonStatement(node)
	self:EmitToken(node.tokens[";"])
end

function META:EmitLocalAssignment(node)
	if node.environment == "typesystem" then return end

	self:Whitespace("\t")

	if node.environment == "typesystem" then
		self:EmitToken(node.tokens["type"])
	end

	self:Whitespace(" ")
	self:EmitToken(node.tokens["local"], "let")

	for i, left in ipairs(node.left) do
		local right = node.right and node.right[i]
		self:EmitIdentifier(left)

		if right then
			self:EmitToken(node.tokens["="])
			self:EmitExpression(right)

			if right.tokens[","] then self:EmitToken(right.tokens[","], "") end
		end

		if left.tokens[","] then self:EmitToken(left.tokens[","]) end
	end
end

function META:EmitAssignment(node)
	if node.environment == "typesystem" then return end

	self:Whitespace("\t")

	if node.environment == "typesystem" then
		self:EmitToken(node.tokens["type"])
	end

	for i, left in ipairs(node.left) do
		local right = node.right[i]

		if left.kind == "binary_operator" then
			self:Emit("OP['='](")

			if
				left.kind == "binary_operator" and
				(
					left.value.value == "." or
					left.value.value == ":"
				)
			then
				self:EmitExpression(left.left)
				self:Emit(",")
				self:Emit("'")
				self:EmitExpression(left.right)
				self:Emit("'")
			else
				self:EmitExpression(left)
			end

			if right then
				self:Emit(",")
				self:EmitExpression(right)
			end

			self:Emit(");")
		elseif left.kind == "postfix_expression_index" then
			self:Emit("OP['='](")
			self:EmitExpression(left.left)
			self:Emit(",")
			self:EmitExpression(left.expression)

			if right then
				self:Emit(",")
				self:EmitExpression(right)
			end

			self:Emit(");")
		else
			self:EmitExpression(left)
			self:Emit("=")
			self:EmitExpression(right)
		end
	end
end

function META:EmitStatement(node)
	if node.kind == "if" then
		self:EmitIfStatement(node)
	elseif node.kind == "goto" then
		self:EmitGotoStatement(node)
	elseif node.kind == "goto_label" then
		self:EmitLabelStatement(node)
	elseif node.kind == "while" then
		self:EmitWhileStatement(node)
	elseif node.kind == "repeat" then
		self:EmitRepeatStatement(node)
	elseif node.kind == "break" then
		self:EmitBreakStatement(node)
	elseif node.kind == "return" then
		self:EmitReturnStatement(node)
	elseif node.kind == "numeric_for" then
		self:EmitNumericForStatement(node)
	elseif node.kind == "generic_for" then
		self:EmitGenericForStatement(node)
	elseif node.kind == "do" then
		self:EmitDoStatement(node)
	elseif node.kind == "analyzer_function" then
		self:EmitTypeFunctionStatement(node)
	elseif node.kind == "function" then
		self:EmitFunction(node)
	elseif node.kind == "local_function" then
		self:EmitLocalFunction(node)
	elseif node.kind == "local_analyzer_function" then
		self:EmitLocalTypeFunction(node)
	elseif node.kind == "destructure_assignment" then
		self:EmitDestructureAssignment(node)
	elseif node.kind == "assignment" then
		self:EmitAssignment(node)
		self:Emit_ENVFromAssignment(node)
	elseif node.kind == "local_assignment" then
		self:EmitLocalAssignment(node)
	elseif node.kind == "local_destructure_assignment" then
		self:EmitLocalDestructureAssignment(node)
	elseif node.kind == "import" then
		self:Emit("local ")
		self:EmitIdentifierList(node.left)
		self:Emit(" = ")
		self:EmitImportExpression(node)
	elseif node.kind == "call_expression" then
		self:Whitespace("\t")
		self:EmitExpression(node.value)
	elseif node.kind == "shebang" then
		self:EmitToken(node.tokens["shebang"])
	elseif node.kind == "semicolon" then
		self:EmitSemicolonStatement(node)

		if self.config.preserve_whitespace == false then
			if self.out[self.i - 2] and self.out[self.i - 2] == "\n" then
				self.out[self.i - 2] = ""
			end
		end
	elseif node.kind == "end_of_file" then
		self:EmitToken(node.tokens["end_of_file"])
	elseif node.kind == "root" then
		self:EmitStatements(node.statements)
	else
		error("unhandled statement: " .. node.kind)
	end

	self:Emit(";")

	if self.OnEmitStatement then
		if node.kind ~= "end_of_file" then self:OnEmitStatement() end
	end
end

function META:EmitStatements(tbl)
	for _, node in ipairs(tbl) do
		self:EmitStatement(node)
		self:Whitespace("\n")
	end
end

function META:EmitExpressionList(tbl, delimiter)
	for i = 1, #tbl do
		self:EmitExpression(tbl[i])

		if i ~= #tbl then
			self:EmitToken(tbl[i].tokens[","], delimiter)
			self:Whitespace(" ")
		end
	end
end

function META:EmitIdentifier(node)
	self:EmitToken(node.value)

	if node.value.value == "..." then self:Emit("__args") end

	if self.config.type_annotations then
		if node.type_expression then
			self:EmitToken(node.tokens[":"])
			self:EmitTypeExpression(node.type_expression)
		elseif node:GetLastType() then
			self:Emit(": ")
			self:Emit(tostring((node:GetLastType():GetContract() or node:GetLastType())))
		end
	end
end

function META:EmitIdentifierList(tbl)
	for i = 1, #tbl do
		self:EmitIdentifier(tbl[i])

		if i ~= #tbl then
			self:EmitToken(tbl[i].tokens[","])
			self:Whitespace(" ")
		end
	end
end

do -- types
	function META:EmitTypeBinaryOperator(node)
		if node.left then self:EmitTypeExpression(node.left) end

		if node.value.value == "." or node.value.value == ":" then
			self:EmitToken(node.value)
		else
			self:Whitespace(" ")
			self:EmitToken(node.value)
			self:Whitespace(" ")
		end

		if node.right then self:EmitTypeExpression(node.right) end
	end

	function META:EmitType(node)
		self:EmitToken(node.value)

		if node.type_expression then
			self:EmitToken(node.tokens[":"])
			self:EmitTypeExpression(node.type_expression)
		end
	end

	function META:EmitTypeList(node)
		self:EmitToken(node.tokens["["])

		for i = 1, #node.types do
			self:EmitTypeExpression(node.types[i])

			if i ~= #node.types then
				self:EmitToken(node.types[i].tokens[","])
				self:Whitespace(" ")
			end
		end

		self:EmitToken(node.tokens["]"])
	end

	function META:EmitListType(node)
		self:EmitTypeExpression(node.left)
		self:EmitTypeList(node)
	end

	function META:EmitTableType(node)
		local tree = node
		self:EmitToken(node.tokens["{"])

		if node.children[1] then
			self:Whitespace("\n")
			self:Whitespace("\t+")

			for i, node in ipairs(node.children) do
				self:Whitespace("\t")

				if node.kind == "table_index_value" then
					self:EmitTypeExpression(node.value_expression)
				elseif node.kind == "table_key_value" then
					self:EmitToken(node.tokens["identifier"])
					self:EmitToken(node.tokens["="], ":")
					self:EmitTypeExpression(node.value_expression)
				elseif node.kind == "table_expression_value" then
					self:EmitToken(node.tokens["["])
					self:Whitespace("(")
					self:EmitTypeExpression(node.key_expression)
					self:Whitespace(")")
					self:EmitToken(node.tokens["]"])
					self:EmitToken(node.tokens["="], ":")
					self:EmitTypeExpression(node.value_expression)
				end

				if tree.tokens["separators"][i] then
					self:EmitToken(tree.tokens["separators"][i])
				else
					self:Whitespace(",")
				end

				self:Whitespace("\n")
			end

			self:Whitespace("\t-")
			self:Whitespace("\t")
		end

		self:EmitToken(node.tokens["}"])
	end

	function META:EmitTypeFunction(node)
		self:EmitToken(node.tokens["function"])

		if node.tokens["("] then self:EmitToken(node.tokens["("]) end

		for i, exp in ipairs(node.identifiers) do
			if not self.config.type_annotations and node.statements then
				if exp.identifier then
					self:EmitToken(exp.identifier)
				else
					self:EmitTypeExpression(exp)
				end
			else
				if exp.identifier then
					self:EmitToken(exp.identifier)
					self:EmitToken(exp.tokens[":"])
				end

				self:EmitTypeExpression(exp)
			end

			if i ~= #node.identifiers then
				if exp.tokens[","] then self:EmitToken(exp.tokens[","]) end
			end
		end

		if node.tokens[")"] then self:EmitToken(node.tokens[")"]) end

		if node.tokens[":"] then
			self:EmitToken(node.tokens[":"])

			for i, exp in ipairs(node.return_types) do
				self:EmitTypeExpression(exp)

				if i ~= #node.return_types then self:EmitToken(exp.tokens[","]) end
			end
		else
			self:Whitespace("\n")
			self:EmitBlock(node.statements)
			self:Whitespace("\t")
			self:EmitToken(node.tokens["end"])
		end
	end

	function META:EmitTypeExpression(node)
		if node.tokens["("] then
			for i = #node.tokens["("], 1, -1 do
				self:EmitToken(node.tokens["("][i])
			end
		end

		if node.kind == "binary_operator" then
			self:EmitTypeBinaryOperator(node)
		elseif node.kind == "analyzer_function" then
			self:EmitTypeFunction(node)
		elseif node.kind == "table" then
			self:EmitTable(node)
		elseif node.kind == "prefix_operator" then
			self:EmitPrefixOperator(node)
		elseif node.kind == "postfix_operator" then
			self:EmitPostfixOperator(node)
		elseif node.kind == "postfix_call" then
			self:EmitCall(node)
		elseif node.kind == "postfix_expression_index" then
			self:EmitExpressionIndex(node)
		elseif node.kind == "value" then
			self:EmitToken(node.value)
		elseif node.kind == "type_table" then
			self:EmitTableType(node)
		else
			error("unhandled token type " .. node.kind)
		end

		if node.tokens[")"] then
			for _, node in ipairs(node.tokens[")"]) do
				self:EmitToken(node)
			end
		end
	end
end

do -- extra
	function META:EmitDestructureAssignment(node)
		self:Whitespace("\t")
		self:EmitToken(node.tokens["{"], "")

		if node.default then
			self:EmitToken(node.default.value)
			self:EmitToken(node.default_comma)
		end

		self:EmitToken(node.tokens["{"], "")
		self:Whitespace(" ")
		self:EmitIdentifierList(node.left)
		self:EmitToken(node.tokens["}"], "")
		self:Whitespace(" ")
		self:EmitToken(node.tokens["="])
		self:Whitespace(" ")
		self:Emit("table.destructure(")
		self:EmitExpression(node.right)
		self:Emit(", ")
		self:Emit("{")

		for i, v in ipairs(node.left) do
			self:Emit("\"")
			self:Emit(v.value.value)
			self:Emit("\"")

			if i ~= #node.left then self:Emit(", ") end
		end

		self:Emit("}")

		if node.default then self:Emit(", true") end

		self:Emit(")")
	end

	function META:EmitLocalDestructureAssignment(node)
		self:Whitespace("\t")
		self:EmitToken(node.tokens["local"])
		self:EmitDestructureAssignment(node)
	end

	function META:Emit_ENVFromAssignment(node)
		for i, v in ipairs(node.left) do
			if v.kind == "value" and v.value.value == "_ENV" then
				if node.right[i] then
					local key = node.left[i]
					local val = node.right[i]
					self:Emit(";setfenv(1, _ENV);")
				end
			end
		end
	end

	function META:EmitImportExpression(node)
		self:Emit(" IMPORTS['" .. node.path .. "'](")
		self:EmitExpressionList(node.expressions)
		self:Emit(")")
	end
end

function META.New(config)
	local self = setmetatable({}, META)
	self.config = config or {}
	self:Initialize()
	return self
end

return META
