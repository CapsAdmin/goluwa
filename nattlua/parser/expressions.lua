local META = ...
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local math_huge = math.huge
local runtime_syntax = require("nattlua.syntax.runtime")
local typesystem_syntax = require("nattlua.syntax.typesystem")
local profiler = require("nattlua.other.profiler")

--[[#local type { Node } = import("~/nattlua/parser/nodes.nlua")]]

function META:ParseAnalyzerFunctionExpression()
	if not (self:IsValue("analyzer") and self:IsValue("function", 1)) then return end

	local node = self:StartNode("expression", "analyzer_function")
	node.tokens["analyzer"] = self:ExpectValue("analyzer")
	node.tokens["function"] = self:ExpectValue("function")
	self:ParseAnalyzerFunctionBody(node)
	node = self:EndNode(node)
	return node
end

function META:ParseFunctionExpression()
	if not self:IsValue("function") then return end

	local node = self:StartNode("expression", "function")
	node.tokens["function"] = self:ExpectValue("function")
	self:ParseFunctionBody(node)
	node = self:EndNode(node)
	return node
end

function META:ParseIndexSubExpression(left_node--[[#: Node]])
	if not (self:IsValue(".") and self:IsType("letter", 1)) then return end

	local node = self:StartNode("expression", "binary_operator")
	node.value = self:ParseToken()
	node.right = self:ParseValueExpressionType("letter")
	node.left = left_node
	node = self:EndNode(node)
	return node
end

function META:IsCallExpression(offset--[[#: number]])
	return self:IsValue("(", offset) or
		self:IsValue("<|", offset) or
		self:IsValue("{", offset) or
		self:IsType("string", offset) or
		(
			self:IsValue("!", offset) and
			self:IsValue("(", offset + 1)
		)
end

function META:ParseSelfCallSubExpression(left_node--[[#: Node]])
	if not (self:IsValue(":") and self:IsType("letter", 1) and self:IsCallExpression(2)) then
		return
	end

	local node = self:StartNode("expression", "binary_operator", left_node)
	node.value = self:ParseToken()
	node.right = self:ParseValueExpressionType("letter")
	node.left = left_node
	node = self:EndNode(node)
	return node
end

do -- typesystem
	function META:ParseParenthesisOrTupleTypeExpression()
		if not self:IsValue("(") then return end

		local pleft = self:ExpectValue("(")
		local node = self:ParseTypeExpression(0)

		if not node or self:IsValue(",") then
			local first_expression = node
			local node = self:StartNode("expression", "tuple", first_expression)

			if self:IsValue(",") then
				first_expression.tokens[","] = self:ExpectValue(",")
				node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			else
				node.expressions = {}
			end

			if first_expression then
				table.insert(node.expressions, 1, first_expression)
			end

			node.tokens["("] = pleft
			node.tokens[")"] = self:ExpectValue(")", pleft)
			node = self:EndNode(node)
			return node
		end

		node.tokens["("] = node.tokens["("] or {}
		table_insert(node.tokens["("], pleft)
		node.tokens[")"] = node.tokens[")"] or {}
		table_insert(node.tokens[")"], self:ExpectValue(")"))
		return node
	end

	function META:ParsePrefixOperatorTypeExpression()
		if not typesystem_syntax:IsPrefixOperator(self:GetToken()) then return end

		local node = self:StartNode("expression", "prefix_operator")
		node.value = self:ParseToken()
		node.tokens[1] = node.value

		if node.value.value == "expand" then
			self:PushParserEnvironment("runtime")
		end

		node.right = self:ParseRuntimeExpression(math_huge)

		if node.value.value == "expand" then self:PopParserEnvironment() end

		node = self:EndNode(node)
		return node
	end

	function META:ParseValueTypeExpression()
		if not (self:IsValue("...") and self:IsType("letter", 1)) then return end

		local node = self:StartNode("expression", "vararg")
		node.tokens["..."] = self:ExpectValue("...")
		node.value = self:ParseTypeExpression(0)
		node = self:EndNode(node)
		return node
	end

	function META:ParseTypeSignatureFunctionArgument(expect_type)
		if self:IsValue(")") then return end

		if
			expect_type or
			(
				(
					self:IsType("letter") or
					self:IsValue("...")
				) and
				self:IsValue(":", 1)
			)
		then
			local identifier = self:ParseToken()
			local token = self:ExpectValue(":")
			local exp = self:ExpectTypeExpression(0)
			exp.tokens[":"] = token
			exp.identifier = identifier
			return exp
		end

		return self:ExpectTypeExpression(0)
	end

	function META:ParseFunctionSignatureExpression()
		if not (self:IsValue("function") and self:IsValue("=", 1)) then return end

		local node = self:StartNode("expression", "function_signature")
		node.tokens["function"] = self:ExpectValue("function")
		node.tokens["="] = self:ExpectValue("=")
		node.tokens["arguments("] = self:ExpectValue("(")
		node.identifiers = self:ParseMultipleValues(nil, self.ParseTypeSignatureFunctionArgument)
		node.tokens["arguments)"] = self:ExpectValue(")")
		node.tokens[">"] = self:ExpectValue(">")
		node.tokens["return("] = self:ExpectValue("(")
		node.return_types = self:ParseMultipleValues(nil, self.ParseTypeSignatureFunctionArgument)
		node.tokens["return)"] = self:ExpectValue(")")
		node = self:EndNode(node)
		return node
	end

	function META:ParseTypeFunctionExpression()
		if not (self:IsValue("function") and self:IsValue("<|", 1)) then return end

		local node = self:StartNode("expression", "type_function")
		node.tokens["function"] = self:ExpectValue("function")
		self:ParseTypeFunctionBody(node)
		node = self:EndNode(node)
		return node
	end

	function META:ParseKeywordValueTypeExpression()
		if not typesystem_syntax:IsValue(self:GetToken()) then return end

		local node = self:StartNode("expression", "value")
		node.value = self:ParseToken()
		node = self:EndNode(node)
		return node
	end

	do
		function META:read_type_table_entry(i--[[#: number]])
			if self:IsValue("[") then
				local node = self:StartNode("sub_statement", "table_expression_value")
				node.tokens["["] = self:ExpectValue("[")
				node.key_expression = self:ParseTypeExpression(0)
				node.tokens["]"] = self:ExpectValue("]")
				node.tokens["="] = self:ExpectValue("=")
				node.value_expression = self:ParseTypeExpression(0)
				node = self:EndNode(node)
				return node
			elseif self:IsType("letter") and self:IsValue("=", 1) then
				local node = self:StartNode("sub_statement", "table_key_value")
				node.tokens["identifier"] = self:ExpectType("letter")
				node.tokens["="] = self:ExpectValue("=")
				node.value_expression = self:ParseTypeExpression(0)
				node = self:EndNode(node)
				return node
			end

			local node = self:StartNode("sub_statement", "table_index_value")
			local spread = self:read_table_spread()

			if spread then
				node.spread = spread
			else
				node.key = i
				node.value_expression = self:ParseTypeExpression(0)
			end

			node = self:EndNode(node)
			return node
		end

		function META:ParseTableTypeExpression()
			if not self:IsValue("{") then return end

			local tree = self:StartNode("expression", "type_table")
			tree.tokens["{"] = self:ExpectValue("{")
			tree.children = {}
			tree.tokens["separators"] = {}

			for i = 1, math_huge do
				if self:IsValue("}") then break end

				local entry = self:read_type_table_entry(i)

				if entry.spread then tree.spread = true end

				tree.children[i] = entry

				if not self:IsValue(",") and not self:IsValue(";") and not self:IsValue("}") then
					self:Error(
						"expected $1 got $2",
						nil,
						nil,
						{",", ";", "}"},
						(self:GetToken() and self:GetToken().value) or "no token"
					)

					break
				end

				if not self:IsValue("}") then
					tree.tokens["separators"][i] = self:ParseToken()
				end
			end

			tree.tokens["}"] = self:ExpectValue("}")
			tree = self:EndNode(tree)
			return tree
		end
	end

	function META:ParseStringTypeExpression()
		if not (self:IsType("$") and self:IsType("string", 1)) then return end

		local node = self:StartNode("expression", "type_string")
		node.tokens["$"] = self:ParseToken("...")
		node.value = self:ExpectType("string")
		return node
	end

	function META:ParseEmptyUnionTypeExpression()
		if not self:IsValue("|") then return end

		local node = self:StartNode("expression", "empty_union")
		node.tokens["|"] = self:ParseToken("|")
		node = self:EndNode(node)
		return node
	end

	function META:ParseAsSubExpression(node--[[#: Node]])
		if not self:IsValue("as") then return end

		node.tokens["as"] = self:ExpectValue("as")
		node.type_expression = self:ParseTypeExpression(0)
	end

	function META:ParsePostfixTypeOperatorSubExpression(left_node--[[#: Node]])
		if not typesystem_syntax:IsPostfixOperator(self:GetToken()) then return end

		local node = self:StartNode("expression", "postfix_operator")
		node.value = self:ParseToken()
		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParseTypeCallSubExpression(left_node--[[#: Node]], primary_node--[[#: Node]])
		if not self:IsCallExpression(0) then return end

		local node = self:StartNode("expression", "postfix_call")
		local start = self:GetToken()

		if self:IsValue("{") then
			node.expressions = {self:ParseTableTypeExpression()}
		elseif self:IsType("string") then
			node.expressions = {self:ParseValueExpressionToken()}
		elseif self:IsValue("<|") then
			node.tokens["call("] = self:ExpectValue("<|")
			node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			node.tokens["call)"] = self:ExpectValue("|>")
		else
			node.tokens["call("] = self:ExpectValue("(")
			node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			node.tokens["call)"] = self:ExpectValue(")")
		end

		if primary_node.kind == "value" then
			local name = primary_node.value.value

			if name == "import" then
				self:HandleImportExpression(node, name, node.expressions[1].value.string_value, start)
			elseif name == "import_data" then
				self:HandleImportDataExpression(node, node.expressions[1].value.string_value, start)
			end
		end

		node.left = left_node
		node.type_call = true
		node = self:EndNode(node)
		return node
	end

	function META:ParsePostfixTypeIndexExpressionSubExpression(left_node--[[#: Node]])
		if not self:IsValue("[") then return end

		local node = self:StartNode("expression", "postfix_expression_index")
		node.tokens["["] = self:ExpectValue("[")
		node.expression = self:ExpectTypeExpression(0)
		node.tokens["]"] = self:ExpectValue("]")
		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParseTypeSubExpression(node--[[#: Node]])
		for _ = 1, self:GetLength() do
			local left_node = node
			local found = self:ParseIndexSubExpression(left_node) or
				self:ParseSelfCallSubExpression(left_node) or
				self:ParsePostfixTypeOperatorSubExpression(left_node) or
				self:ParseTypeCallSubExpression(left_node, node) or
				self:ParsePostfixTypeIndexExpressionSubExpression(left_node) or
				self:ParseAsSubExpression(left_node)

			if not found then break end

			if left_node.value and left_node.value.value == ":" then
				found.parser_call = true
			end

			node = found
		end

		return node
	end

	function META:ParseTypeExpression(priority--[[#: number]])
		if self.TealCompat then return self:ParseTealExpression(priority) end

		profiler.PushZone("ParseTypeExpression")
		self:PushParserEnvironment("typesystem")
		local node
		local force_upvalue

		if self:IsValue("^") then
			force_upvalue = true
			self:Advance(1)
		end

		node = self:ParseParenthesisOrTupleTypeExpression() or
			self:ParseEmptyUnionTypeExpression() or
			self:ParsePrefixOperatorTypeExpression() or
			self:ParseAnalyzerFunctionExpression() or -- shared
			self:ParseFunctionSignatureExpression() or
			self:ParseTypeFunctionExpression() or -- shared
			self:ParseFunctionExpression() or -- shared
			self:ParseValueTypeExpression() or
			self:ParseKeywordValueTypeExpression() or
			self:ParseTableTypeExpression() or
			self:ParseStringTypeExpression()
		local first = node

		if node then
			node = self:ParseTypeSubExpression(node)

			if
				first.kind == "value" and
				(
					first.value.type == "letter" or
					first.value.value == "..."
				)
			then
				first.standalone_letter = node
				first.force_upvalue = force_upvalue
			end
		end

		while
			typesystem_syntax:GetBinaryOperatorInfo(self:GetToken()) and
			typesystem_syntax:GetBinaryOperatorInfo(self:GetToken()).left_priority > priority
		do
			local left_node = node
			node = self:StartNode("expression", "binary_operator", left_node)
			node.value = self:ParseToken()
			node.left = left_node
			node.right = self:ParseTypeExpression(typesystem_syntax:GetBinaryOperatorInfo(node.value).right_priority)
			node = self:EndNode(node)
		end

		self:PopParserEnvironment()
		profiler.PopZone()
		return node
	end

	function META:IsTypeExpression()
		local token = self:GetToken()
		return not (
			not token or
			token.type == "end_of_file" or
			token.value == "}" or
			token.value == "," or
			token.value == "]" or
			(
				typesystem_syntax:IsKeyword(token) and
				not typesystem_syntax:IsPrefixOperator(token)
				and
				not typesystem_syntax:IsValue(token)
				and
				token.value ~= "function"
			)
		)
	end

	function META:ExpectTypeExpression(priority--[[#: number]])
		if not self:IsTypeExpression() then
			local token = self:GetToken()
			self:Error(
				"expected beginning of expression, got $1",
				nil,
				nil,
				token and token.value ~= "" and token.value or token.type
			)
			return
		end

		return self:ParseTypeExpression(priority)
	end
end

do -- runtime
	local ParseTableExpression

	do
		function META:read_table_spread()
			if
				not (
					self:IsValue("...") and
					(
						self:IsType("letter", 1) or
						self:IsValue("{", 1) or
						self:IsValue("(", 1)
					)
				)
			then
				return
			end

			local node = self:StartNode("expression", "table_spread")
			node.tokens["..."] = self:ExpectValue("...")
			node.expression = self:ExpectRuntimeExpression()
			node = self:EndNode(node)
			return node
		end

		function META:read_table_entry(i--[[#: number]])
			if self:IsValue("[") then
				local node = self:StartNode("sub_statement", "table_expression_value")
				node.tokens["["] = self:ExpectValue("[")
				node.key_expression = self:ExpectRuntimeExpression(0)
				node.tokens["]"] = self:ExpectValue("]")
				node.tokens["="] = self:ExpectValue("=")
				node.value_expression = self:ExpectRuntimeExpression(0)
				node = self:EndNode(node)
				return node
			elseif self:IsType("letter") and self:IsValue("=", 1) then
				local node = self:StartNode("sub_statement", "table_key_value")
				node.tokens["identifier"] = self:ExpectType("letter")
				node.tokens["="] = self:ExpectValue("=")
				local spread = self:read_table_spread()

				if spread then
					node.spread = spread
				else
					node.value_expression = self:ExpectRuntimeExpression()
				end

				node = self:EndNode(node)
				return node
			end

			local node = self:StartNode("sub_statement", "table_index_value")
			local spread = self:read_table_spread()

			if spread then
				node.spread = spread
			else
				node.value_expression = self:ExpectRuntimeExpression()
			end

			node.key = i
			node = self:EndNode(node)
			return node
		end

		function META:ParseTableExpression()
			if not self:IsValue("{") then return end

			local tree = self:StartNode("expression", "table")
			tree.tokens["{"] = self:ExpectValue("{")
			tree.children = {}
			tree.tokens["separators"] = {}

			for i = 1, self:GetLength() do
				if self:IsValue("}") then break end

				local entry = self:read_table_entry(i)

				if entry.kind == "table_index_value" then
					tree.is_array = true
				else
					tree.is_dictionary = true
				end

				if entry.spread then tree.spread = true end

				tree.children[i] = entry

				if not self:IsValue(",") and not self:IsValue(";") and not self:IsValue("}") then
					self:Error(
						"expected $1 got $2",
						nil,
						nil,
						{",", ";", "}"},
						(self:GetToken() and self:GetToken().value) or "no token"
					)

					break
				end

				if not self:IsValue("}") then
					tree.tokens["separators"][i] = self:ParseToken()
				end
			end

			tree.tokens["}"] = self:ExpectValue("}")
			tree = self:EndNode(tree)
			return tree
		end
	end

	function META:ParsePostfixOperatorSubExpression(left_node--[[#: Node]])
		if not runtime_syntax:IsPostfixOperator(self:GetToken()) then return end

		local node = self:StartNode("expression", "postfix_operator")
		node.value = self:ParseToken()
		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParseCallSubExpression(left_node--[[#: Node]], primary_node--[[#: Node]])
		if not self:IsCallExpression(0) then return end

		if primary_node and primary_node.kind == "function" then
			if not primary_node.tokens[")"] then return end
		end

		local node = self:StartNode("expression", "postfix_call", left_node)
		local start = self:GetToken()

		if self:IsValue("{") then
			node.expressions = {self:ParseTableExpression()}
		elseif self:IsType("string") then
			node.expressions = {self:ParseValueExpressionToken()}
		elseif self:IsValue("<|") then
			node.tokens["call("] = self:ExpectValue("<|")
			node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			node.tokens["call)"] = self:ExpectValue("|>")
			node.type_call = true

			if self:IsValue("(") then
				local lparen = self:ExpectValue("(")
				local expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
				local rparen = self:ExpectValue(")")
				node.expressions_typesystem = node.expressions
				node.expressions = expressions
				node.tokens["call_typesystem("] = node.tokens["call("]
				node.tokens["call_typesystem)"] = node.tokens["call)"]
				node.tokens["call("] = lparen
				node.tokens["call)"] = rparen
			end
		elseif self:IsValue("!") then
			node.tokens["!"] = self:ExpectValue("!")
			node.tokens["call("] = self:ExpectValue("(")
			node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			node.tokens["call)"] = self:ExpectValue(")")
			node.type_call = true
		else
			node.tokens["call("] = self:ExpectValue("(")
			node.expressions = self:ParseMultipleValues(nil, self.ParseRuntimeExpression, 0)
			node.tokens["call)"] = self:ExpectValue(")")
		end

		if
			primary_node.kind == "value" and
			node.expressions[1] and
			node.expressions[1].value and
			node.expressions[1].value.string_value
		then
			local name = primary_node.value.value

			if
				name == "import" or
				name == "dofile" or
				name == "loadfile" or
				name == "require"
			then
				self:HandleImportExpression(node, name, node.expressions[1].value.string_value, start)
			elseif name == "import_data" then
				self:HandleImportDataExpression(node, node.expressions[1].value.string_value, start)
			end
		end

		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParsePostfixIndexExpressionSubExpression(left_node--[[#: Node]])
		if not self:IsValue("[") then return end

		local node = self:StartNode("expression", "postfix_expression_index")
		node.tokens["["] = self:ExpectValue("[")
		node.expression = self:ExpectRuntimeExpression()
		node.tokens["]"] = self:ExpectValue("]")
		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParseSubExpression(node--[[#: Node]])
		for _ = 1, self:GetLength() do
			local left_node = node

			if
				self:IsValue(":") and
				(
					not self:IsType("letter", 1) or
					not self:IsCallExpression(2)
				)
			then
				node.tokens[":"] = self:ExpectValue(":")
				node.type_expression = self:ExpectTypeExpression(0)
			elseif self:IsValue("as") then
				node.tokens["as"] = self:ExpectValue("as")
				node.type_expression = self:ExpectTypeExpression(0)
			elseif self:IsValue("is") then
				node.tokens["is"] = self:ExpectValue("is")
				node.type_expression = self:ExpectTypeExpression(0)
			end

			local found = self:ParseIndexSubExpression(left_node) or
				self:ParseSelfCallSubExpression(left_node) or
				self:ParseCallSubExpression(left_node, node) or
				self:ParsePostfixOperatorSubExpression(left_node) or
				self:ParsePostfixIndexExpressionSubExpression(left_node)

			if not found then break end

			if left_node.value and left_node.value.value == ":" then
				found.parser_call = true
			end

			node = found
		end

		return node
	end

	function META:ParsePrefixOperatorExpression()
		if not runtime_syntax:IsPrefixOperator(self:GetToken()) then return end

		local node = self:StartNode("expression", "prefix_operator")
		node.value = self:ParseToken()
		node.tokens[1] = node.value
		node.right = self:ExpectRuntimeExpression(math.huge)
		node = self:EndNode(node)
		return node
	end

	function META:ParseParenthesisExpression()
		if not self:IsValue("(") then return end

		local pleft = self:ExpectValue("(")
		local node = self:ExpectRuntimeExpression(0)
		node.tokens["("] = node.tokens["("] or {}
		table_insert(node.tokens["("], pleft)
		node.tokens[")"] = node.tokens[")"] or {}
		table_insert(node.tokens[")"], self:ExpectValue(")"))
		return node
	end

	function META:ParseValueExpression()
		if not runtime_syntax:IsValue(self:GetToken()) then return end

		return self:ParseValueExpressionToken()
	end

	local function resolve_import_path(self--[[#: META.@Self]], path--[[#: string]])
		local working_directory = self.config.working_directory or ""

		if path:sub(1, 1) == "~" then
			path = path:sub(2)

			if path:sub(1, 1) == "/" then path = path:sub(2) end
		elseif path:sub(1, 2) == "./" then
			working_directory = self.config.file_path and
				self.config.file_path:match("(.+/)") or
				working_directory
			path = path:sub(3)
		end

		return working_directory .. path
	end

	local function resolve_require_path(require_path--[[#: string]])
		local paths = package.path .. ";"
		paths = paths .. "./?/init.lua;"
		require_path = require_path:gsub("%.", "/")

		for package_path in paths:gmatch("(.-);") do
			local lua_path = package_path:gsub("%?", require_path)
			local f = io.open(lua_path, "r")

			if f then
				f:close()
				return lua_path
			end
		end

		return nil
	end

	function META:HandleImportExpression(node--[[#: Node]], name--[[#: string]], str--[[#: string]], start--[[#: number]])
		if self.config.skip_import then return end

		if self.dont_hoist_next_import then
			self.dont_hoist_next_import = nil
			return
		end

		local path

		if name == "require" then
			path = resolve_require_path(str)
		else
			path = resolve_import_path(self, str)
		end

		if not path then return end

		local dont_hoist_import = _G.dont_hoist_import and _G.dont_hoist_import > 0
		node.import_expression = true
		node.path = path
		local key = name == "require" and str or path
		local root_node = self.config.root_statement_override_data or
			self.config.root_statement_override or
			self.RootStatement
		root_node.imported = root_node.imported or {}
		local imported = root_node.imported
		node.key = key

		if imported[key] == nil then
			imported[key] = node
			local root, err = self:ParseFile(
				path,
				{
					root_statement_override_data = self.config.root_statement_override_data or self.RootStatement,
					root_statement_override = self.RootStatement,
					path = node.path,
					working_directory = self.config.working_directory,
					inline_require = not root_node.data_import,
					on_node = self.config.on_node,
					on_read_file = self.config.on_read_file,
				}
			)

			if not root then
				self:Error("error importing file: $1", start, start, err)
			end

			node.RootStatement = root
		else
			-- ugly way of dealing with recursive require
			node.RootStatement = imported[key]
		end

		if root_node.data_import and dont_hoist_import then
			root_node.imports = root_node.imports or {}
			table.insert(root_node.imports, node)
			return
		end

		if name == "require" and not self.config.inline_require then
			root_node.imports = root_node.imports or {}
			table.insert(root_node.imports, node)
			return
		end

		self.RootStatement.imports = self.RootStatement.imports or {}
		table.insert(self.RootStatement.imports, node)
	end

	function META:HandleImportDataExpression(node--[[#: Node]], path--[[#: string]], start--[[#: number]])
		if self.config.skip_import then return end

		node.import_expression = true
		node.path = resolve_import_path(self, path)
		self.imported = self.imported or {}
		local key = "DATA_" .. node.path
		node.key = key
		local root_node = self.config.root_statement_override_data or
			self.config.root_statement_override or
			self.RootStatement
		root_node.imported = root_node.imported or {}
		local imported = root_node.imported
		root_node.data_import = true
		local data
		local err

		if imported[key] == nil then
			imported[key] = node

			if node.path:sub(-4) == "lua" or node.path:sub(-5) ~= "nlua" then
				local root, err = self:ParseFile(
					node.path,
					{
						root_statement_override_data = self.config.root_statement_override_data or self.RootStatement,
						path = node.path,
						working_directory = self.config.working_directory,
						on_node = self.config.on_node,
						on_read_file = self.config.on_read_file,
					--inline_require = true,
					}
				)

				if not root then
					self:Error("error importing file: $1", start, start, err .. ": " .. node.path)
				end

				data = root:Render(
					{
						preserve_whitespace = false,
						comment_type_annotations = false,
						type_annotations = true,
						inside_data_import = true,
					}
				)
			else
				local f
				f, err = io.open(node.path, "rb")

				if f then
					data = f:read("*all")
					f:close()
				end
			end

			if not data then
				self:Error("error importing file: $1", start, start, err .. ": " .. node.path)
			end

			node.data = data
		else
			node.data = imported[key].data
		end

		if _G.dont_hoist_import and _G.dont_hoist_import > 0 then return end

		self.RootStatement.imports = self.RootStatement.imports or {}
		table.insert(self.RootStatement.imports, node)
		return node
	end

	function META:check_integer_division_operator(node--[[#: Node]])
		if node and not node.idiv_resolved then
			for i, token in ipairs(node.whitespace) do
				if token.value:find("\n", nil, true) then break end

				if token.type == "line_comment" and token.value:sub(1, 2) == "//" then
					table_remove(node.whitespace, i)
					local tokens = self:LexString("/idiv" .. token.value:sub(2))

					for _, token in ipairs(tokens) do
						self:check_integer_division_operator(token)
					end

					self:AddTokens(tokens)
					node.idiv_resolved = true

					break
				end
			end
		end
	end

	function META:ParseRuntimeExpression(priority--[[#: number]])
		if self:GetCurrentParserEnvironment() == "typesystem" then
			return self:ParseTypeExpression(priority)
		end

		profiler.PushZone("ParseRuntimeExpression")
		priority = priority or 0
		local node = self:ParseParenthesisExpression() or
			self:ParsePrefixOperatorExpression() or
			self:ParseAnalyzerFunctionExpression() or
			self:ParseFunctionExpression() or
			self:ParseValueExpression() or
			self:ParseTableExpression()
		local first = node

		if node then
			node = self:ParseSubExpression(node)

			if
				first.kind == "value" and
				(
					first.value.type == "letter" or
					first.value.value == "..."
				)
			then
				first.standalone_letter = node
			end
		end

		self:check_integer_division_operator(self:GetToken())

		while
			(
				runtime_syntax:GetBinaryOperatorInfo(self:GetToken()) and
				not self:IsValue("=", 1)
			)
			and
			runtime_syntax:GetBinaryOperatorInfo(self:GetToken()).left_priority > priority
		do
			local left_node = node
			node = self:StartNode("expression", "binary_operator", left_node)
			node.value = self:ParseToken()
			node.left = left_node

			if node.left then node.left.parent = node end

			node.right = self:ExpectRuntimeExpression(runtime_syntax:GetBinaryOperatorInfo(node.value).right_priority)
			node = self:EndNode(node)

			if not node.right then
				local token = self:GetToken()
				self:Error(
					"expected right side to be an expression, got $1",
					nil,
					nil,
					token and token.value ~= "" and token.value or token.type
				)
				return
			end
		end

		if node then node.first_node = first end

		profiler.PopZone("ParseRuntimeExpression")
		return node
	end

	function META:IsRuntimeExpression()
		local token = self:GetToken()
		return not (
			token.type == "end_of_file" or
			token.value == "}" or
			token.value == "," or
			token.value == "]" or
			token.value == ")" or
			(
				(
					runtime_syntax:IsKeyword(token) or
					runtime_syntax:IsNonStandardKeyword(token)
				) and
				not runtime_syntax:IsPrefixOperator(token)
				and
				not runtime_syntax:IsValue(token)
				and
				token.value ~= "function"
			)
		)
	end

	function META:ExpectRuntimeExpression(priority--[[#: number]])
		if not self:IsRuntimeExpression() then
			local token = self:GetToken()
			self:Error(
				"expected beginning of expression, got $1",
				nil,
				nil,
				token and token.value ~= "" and token.value or token.type
			)
			return
		end

		return self:ParseRuntimeExpression(priority)
	end
end