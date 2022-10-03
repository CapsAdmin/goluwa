local runtime_syntax = require("nattlua.syntax.runtime")
local characters = require("nattlua.syntax.characters")
local class = require("nattlua.other.class")
local print = _G.print
local error = _G.error
local debug = _G.debug
local tostring = _G.tostring
local pairs = _G.pairs
local table = _G.table
local ipairs = _G.ipairs
local assert = _G.assert
local type = _G.type
local setmetatable = _G.setmetatable
local B = string.byte
local META = class.CreateTemplate("emitter")

--[[#local type { ParserConfig } = import("./../config.nlua")]]

local translate_binary = {
	["&&"] = "and",
	["||"] = "or",
	["!="] = "~=",
}
local translate_prefix = {
	["!"] = "not ",
}

do -- internal
	function META:Whitespace(str--[[#: string]], force--[[#: boolean]])
		if self.config.preserve_whitespace == nil and not force then return end

		if str == "\t" then
			if self.config.no_newlines then
				self:Emit(" ")
			else
				self:Emit(("\t"):rep(self.level))
				self.last_indent_index = #self.out
			end
		elseif str == " " then
			self:Emit(" ")
		elseif str == "\n" then
			self:Emit(self.config.no_newlines and " " or "\n")
			self.last_newline_index = #self.out
		else
			error("unknown whitespace " .. ("%q"):format(str))
		end
	end

	function META:Emit(str)
		if type(str) ~= "string" then
			error(debug.traceback("attempted to emit a non string " .. tostring(str)))
		end

		if str == "" then return end

		self.out[self.i] = str or ""
		self.i = self.i + 1
	end

	function META:EmitNonSpace(str--[[#: string]])
		self:Emit(str)
		self.last_non_space_index = #self.out
	end

	function META:EmitSpace(str--[[#: string]])
		self:Emit(str)
	end

	function META:Indent()
		self.level = self.level + 1
	end

	function META:Outdent()
		self.level = self.level - 1
	end

	function META:GetPrevChar()
		local prev = self.out[self.i - 1]
		local char = prev and prev:sub(-1)
		return char and char:byte() or 0
	end

	function META:EmitWhitespace(token--[[#: Token]])
		if self.config.preserve_whitespace == false and token.type == "space" then
			return
		end

		self:EmitToken(token)

		if token.type ~= "space" then
			self:Whitespace("\n")
			self:Whitespace("\t")
		end
	end

	function META:EmitToken(node--[[#: Node]], translate--[[#: any]])
		if
			self.config.extra_indent and
			self.config.preserve_whitespace == false and
			self.inside_call_expression
		then
			self.tracking_indents = self.tracking_indents or {}

			if type(self.config.extra_indent[node.value]) == "table" then
				self:Indent()
				local info = self.config.extra_indent[node.value]

				if type(info.to) == "table" then
					for to in pairs(info.to) do
						self.tracking_indents[to] = self.tracking_indents[to] or {}
						table.insert(self.tracking_indents[to], {info = info, level = self.level})
					end
				else
					self.tracking_indents[info.to] = self.tracking_indents[info.to] or {}
					table.insert(self.tracking_indents[info.to], {info = info, level = self.level})
				end
			elseif self.tracking_indents[node.value] then
				for _, info in ipairs(self.tracking_indents[node.value]) do
					if info.level == self.level or info.level == self.pre_toggle_level then
						self:Outdent()
						local info = self.tracking_indents[node.value]

						for key, val in pairs(self.tracking_indents) do
							if info == val.info then self.tracking_indents[key] = nil end
						end

						if self.out[self.last_indent_index] then
							self.out[self.last_indent_index] = self.out[self.last_indent_index]:sub(2)
						end

						if self.toggled_indents then
							self:Outdent()
							self.toggled_indents = {}

							if self.out[self.last_indent_index] then
								self.out[self.last_indent_index] = self.out[self.last_indent_index]:sub(2)
							end
						end

						break
					end
				end
			end

			if self.config.extra_indent[node.value] == "toggle" then
				self.toggled_indents = self.toggled_indents or {}

				if not self.toggled_indents[node.value] then
					self.toggled_indents[node.value] = true
					self.pre_toggle_level = self.level
					self:Indent()
				elseif self.toggled_indents[node.value] then
					if self.out[self.last_indent_index] then
						self.out[self.last_indent_index] = self.out[self.last_indent_index]:sub(2)
					end
				end
			end
		end

		if node.whitespace then
			if self.config.preserve_whitespace == false then
				for i, token in ipairs(node.whitespace) do
					if token.type == "line_comment" then
						local start = i

						for i = self.i - 1, 1, -1 do
							if not self.out[i]:find("^%s+") then
								local found_newline = false

								for i = start, 1, -1 do
									local token = node.whitespace[i]

									if token.value:find("\n") then
										found_newline = true

										break
									end
								end

								if not found_newline then
									self.i = i + 1
									self:Emit(" ")
								end

								break
							end
						end

						self:EmitToken(token)

						if node.whitespace[i + 1] then
							self:Whitespace("\n")
							self:Whitespace("\t")
						end
					elseif token.type == "multiline_comment" then
						self:EmitToken(token)
						self:Whitespace(" ")
					end
				end
			else
				for _, token in ipairs(node.whitespace) do
					if token.type ~= "comment_escape" then self:EmitWhitespace(token) end
				end
			end
		end

		if self.TranslateToken then
			translate = self:TranslateToken(node) or translate
		end

		if translate then
			if type(translate) == "table" then
				self:Emit(translate[node.value] or node.value)
			elseif type(translate) == "function" then
				self:Emit(translate(node.value))
			elseif translate ~= "" then
				self:Emit(translate)
			end
		else
			self:Emit(node.value)
		end

		if
			node.type ~= "line_comment" and
			node.type ~= "multiline_comment" and
			node.type ~= "space"
		then
			self.last_non_space_index = #self.out
		end
	end

	function META:Initialize()
		self.level = 0
		self.out = {}
		self.i = 1
	end

	function META:Concat()
		return table.concat(self.out)
	end

	do
		function META:PushLoop(node--[[#: Node]])
			self.loop_nodes = self.loop_nodes or {}
			table.insert(self.loop_nodes, node)
		end

		function META:PopLoop()
			local node = table.remove(self.loop_nodes)

			if node.on_pop then node:on_pop() end
		end

		function META:GetLoopNode()
			if self.loop_nodes then return self.loop_nodes[#self.loop_nodes] end

			return nil
		end
	end
end

do -- newline breaking
	do
		function META:PushForcedLineBreaking(b--[[#: boolean]])
			self.force_newlines = self.force_newlines or {}
			table.insert(self.force_newlines, b)
		end

		function META:PopForcedLineBreaking()
			table.remove(self.force_newlines)
		end

		function META:IsLineBreaking()
			if self.force_newlines then return self.force_newlines[#self.force_newlines] end
		end
	end

	function META:ShouldLineBreakNode(node--[[#: Node]])
		if node.kind == "table" or node.kind == "type_table" then
			for _, exp in ipairs(node.children) do
				if exp.value_expression and exp.value_expression.kind == "function" then
					return true
				end
			end

			if #node.children > 0 and #node.children == #node.tokens["separators"] then
				return true
			end
		end

		if node.kind == "function" then return #node.statements > 1 end

		if node.kind == "if" then
			for i = 1, #node.statements do
				if #node.statements[i] > 1 then return true end
			end
		end

		return node:GetLength() > self.config.max_line_length
	end

	function META:EmitLineBreakableExpression(node--[[#: Node]])
		local newlines = self:ShouldLineBreakNode(node)

		if newlines then
			self:Indent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		else
			self:Whitespace(" ")
		end

		self:PushForcedLineBreaking(newlines)
		self:EmitExpression(node)
		self:PopForcedLineBreaking()

		if newlines then
			self:Outdent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		else
			self:Whitespace(" ")
		end
	end

	function META:EmitLineBreakableList(tbl, func)
		local newline = self:ShouldBreakExpressionList(tbl)
		self:PushForcedLineBreaking(newline)

		if newline then
			self:Indent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		end

		func(self, tbl)

		if newline then
			self:Outdent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		end

		self:PopForcedLineBreaking()
	end

	function META:EmitExpressionList(tbl)
		self:EmitNodeList(tbl, self.EmitExpression)
	end

	function META:EmitIdentifierList(tbl)
		self:EmitNodeList(tbl, self.EmitIdentifier)
	end
end

local function encapsulate_module(content, name, method)
	if method == "loadstring" then
		local len = 6

		content:gsub("%[[=]*%[", function(s)
			len = math.max(len, #s - 2)
		end)

		local eq = ("="):rep(len + 1)
		return "assert((loadstring or load)([" .. eq .. "[ return " .. content .. " ]" .. eq .. "], '" .. name .. "'))()"
	end

	return content
end

function META:BuildCode(block)
	if block.imports then
		self.done = {}
		self:EmitNonSpace("_G.IMPORTS = _G.IMPORTS or {}\n")

		for i, node in ipairs(block.imports) do
			if not self.done[node.key] then
				if node.data then
					self:Emit(
						"IMPORTS['" .. node.key .. "'] = function() return [===" .. "===[ " .. node.data .. " ]===" .. "===] end\n"
					)
				else
					-- ugly way of dealing with recursive import
					local root = node.RootStatement

					if root and root.kind ~= "root" then root = root.RootStatement end

					if root then
						if node.left.value.value == "loadfile" then
							self:Emit(
								"IMPORTS['" .. node.key .. "'] = " .. encapsulate_module(
										"function(...) " .. root:Render(self.config or {}) .. " end",
										"@" .. node.path,
										self.config.module_encapsulation_method
									) .. "\n"
							)
						elseif node.left.value.value == "require" then
							self:Emit(
								"do local __M; IMPORTS[\"" .. node.key .. "\"] = function(...) __M = __M or (" .. encapsulate_module(
										"function(...) " .. root:Render(self.config or {}) .. " end",
										"@" .. node.path,
										self.config.module_encapsulation_method
									) .. ")(...) return __M end end\n"
							)
						elseif self.config.inside_data_import then
							self:Emit(
								"IMPORTS['" .. node.key .. "'] = function() " .. root:Render(self.config or {}) .. " end\n"
							)
						else
							self:Emit(
								"IMPORTS['" .. node.key .. "'] = " .. encapsulate_module(
										"function() " .. root:Render(self.config or {}) .. " end",
										"@" .. node.path,
										self.config.module_encapsulation_method
									) .. "\n"
							)
						end
					end
				end

				self.done[node.key] = true
			end
		end
	end

	self:EmitStatements(block.statements)
	return self:Concat()
end

function META:OptionalWhitespace()
	if self.config.preserve_whitespace == nil then return end

	if
		characters.IsLetter(self:GetPrevChar()) or
		characters.IsNumber(self:GetPrevChar())
	then
		self:EmitSpace(" ")
	end
end

do
	local function escape_string(str--[[#: string]], quote--[[#: string]])
		local new_str = {}

		for i = 1, #str do
			local c = str:sub(i, i)

			if c == quote then
				local escape_length = 0

				for i = i - 1, 1, -1 do
					if str:sub(i, i) == "\\" then
						escape_length = escape_length + 1
					else
						break
					end
				end

				if escape_length % 2 == 0 then
					new_str[i] = "\\" .. c
				else
					new_str[i] = c
				end
			else
				new_str[i] = c
			end
		end

		return table.concat(new_str)
	end

	function META:EmitStringToken(token--[[#: Token]])
		if self.config.string_quote then
			local current = token.value:sub(1, 1)
			local target = self.config.string_quote

			if current == "\"" or current == "'" then
				local contents = escape_string(token.value:sub(2, -2), target)
				self:EmitToken(token, target .. contents .. target)
				return
			end
		end

		local needs_space = token.value:sub(1, 1) == "[" and self:GetPrevChar() == B("[")

		if needs_space then self:Whitespace(" ") end

		self:EmitToken(token)

		if needs_space then self:Whitespace(" ") end
	end
end

function META:EmitNumberToken(token--[[#: Token]])
	self:EmitToken(token)
end

function META:EmitFunctionSignature(node--[[#: Node]])
	self:EmitToken(node.tokens["function"])
	self:EmitToken(node.tokens["="])
	self:EmitToken(node.tokens["arguments("])
	self:EmitLineBreakableList(node.identifiers, self.EmitIdentifierList)
	self:EmitToken(node.tokens["arguments)"])
	self:EmitToken(node.tokens[">"])
	self:EmitToken(node.tokens["return("])
	self:EmitLineBreakableList(node.return_types, self.EmitExpressionList)
	self:EmitToken(node.tokens["return)"])
end

function META:EmitExpression(node--[[#: Node]])
	local emitted_invalid_code = false
	local newlines = self:IsLineBreaking()

	if node.tokens["("] then
		for i = #node.tokens["("], 1, -1 do
			self:EmitToken(node.tokens["("][i])
		end

		if node.tokens["("] and newlines then
			self:Indent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		end
	end

	if node.kind == "lsx" then
		if self.config.transpile_extensions then
			self:EmitTranspiledLSXExpression(node)
		else
			self:EmitLSXExpression(node)
		end
	elseif node.kind == "binary_operator" then
		self:EmitBinaryOperator(node)
	elseif node.kind == "function" then
		self:EmitAnonymousFunction(node)
	elseif node.kind == "analyzer_function" then
		emitted_invalid_code = self:EmitInvalidLuaCode("EmitAnalyzerFunction", node)
	elseif node.kind == "table" then
		self:EmitTable(node)
	elseif node.kind == "prefix_operator" then
		self:EmitPrefixOperator(node)
	elseif node.kind == "postfix_operator" then
		self:EmitPostfixOperator(node)
	elseif node.kind == "postfix_call" then
		if node.import_expression then
			if not node.path or node.type_call then
				emitted_invalid_code = self:EmitInvalidLuaCode("EmitImportExpression", node)
			else
				self:EmitImportExpression(node)
			end
		elseif node.require_expression then
			self:EmitImportExpression(node)
		elseif node.expressions_typesystem then
			self:EmitCall(node)
		elseif node.type_call then
			emitted_invalid_code = self:EmitInvalidLuaCode("EmitCall", node)
		else
			self:EmitCall(node)
		end
	elseif node.kind == "postfix_expression_index" then
		self:EmitExpressionIndex(node)
	elseif node.kind == "value" then
		if node.tokens["is"] then
			self:EmitToken(node.value, tostring(node.result_is))
		else
			if node.value.type == "string" then
				self:EmitStringToken(node.value)
			elseif node.value.type == "number" then
				self:EmitNumberToken(node.value)
			else
				self:EmitToken(node.value)
			end
		end
	elseif node.kind == "require" then
		self:EmitRequireExpression(node)
	elseif node.kind == "type_table" then
		self:EmitTableType(node)
	elseif node.kind == "table_expression_value" then
		self:EmitTableExpressionValue(node)
	elseif node.kind == "table_key_value" then
		self:EmitTableKeyValue(node)
	elseif node.kind == "empty_union" then
		self:EmitEmptyUnion(node)
	elseif node.kind == "tuple" then
		self:EmitTuple(node)
	elseif node.kind == "type_function" then
		emitted_invalid_code = self:EmitInvalidLuaCode("EmitTypeFunction", node)
	elseif node.kind == "function_signature" then
		emitted_invalid_code = self:EmitInvalidLuaCode("EmitFunctionSignature", node)
	elseif node.kind == "vararg" then
		self:EmitVararg(node)
	else
		error("unhandled token type " .. node.kind)
	end

	if node.tokens[")"] and newlines then
		self:Outdent()
		self:Whitespace("\n")
		self:Whitespace("\t")
	end

	if not node.tokens[")"] then
		if self.config.type_annotations and node.tokens[":"] then
			self:EmitInvalidLuaCode("EmitColonAnnotationExpression", node)
		end

		if self.config.type_annotations and node.tokens["as"] then
			self:EmitInvalidLuaCode("EmitAsAnnotationExpression", node)
		end
	else
		local colon_expression = false
		local as_expression = false

		for _, token in ipairs(node.tokens[")"]) do
			if not colon_expression then
				if
					self.config.type_annotations and
					node.tokens[":"] and
					node.tokens[":"].stop < token.start
				then
					self:EmitInvalidLuaCode("EmitColonAnnotationExpression", node)
					colon_expression = true
				end
			end

			if not as_expression then
				if
					self.config.type_annotations and
					node.tokens["as"] and
					node.tokens["as"].stop < token.start
				then
					self:EmitInvalidLuaCode("EmitAsAnnotationExpression", node)
					as_expression = true
				end
			end

			self:EmitToken(token)
		end

		if not colon_expression then
			if self.config.type_annotations and node.tokens[":"] then
				self:EmitInvalidLuaCode("EmitColonAnnotationExpression", node)
			end
		end

		if not as_expression then
			if self.config.type_annotations and node.tokens["as"] then
				self:EmitInvalidLuaCode("EmitAsAnnotationExpression", node)
			end
		end
	end

	if
		emitted_invalid_code and
		not self.is_call_expression and
		(
			self.config.comment_type_annotations or
			self.config.omit_invalid_code
		)
	then
		self:EmitNonSpace("nil")
	end
end

function META:EmitVarargTuple(node--[[#: Node]])
	self:Emit(tostring(node:GetLastType()))
end

function META:EmitExpressionIndex(node--[[#: Node]])
	self:EmitExpression(node.left)
	self:EmitToken(node.tokens["["])
	self:EmitExpression(node.expression)
	self:EmitToken(node.tokens["]"])
end

function META:EmitCall(node--[[#: Node]])
	local multiline_string = false

	if #node.expressions == 1 and node.expressions[1].kind == "value" then
		multiline_string = node.expressions[1].value.value:sub(1, 1) == "["
	end

	-- this will not work for calls with functions that contain statements
	self.inside_call_expression = true
	self:EmitExpression(node.left)

	if node.expressions_typesystem and not self.config.omit_invalid_code then
		local emitted = self:StartEmittingInvalidLuaCode()
		self:EmitToken(node.tokens["call_typesystem("])
		self:EmitExpressionList(node.expressions_typesystem)
		self:EmitToken(node.tokens["call_typesystem)"])
		self:StopEmittingInvalidLuaCode(emitted)
	end

	if node.tokens["call("] then
		self:EmitToken(node.tokens["call("])
	else
		if self.config.force_parenthesis and not multiline_string then
			self:EmitNonSpace("(")
		end
	end

	local newlines = self:ShouldBreakExpressionList(node.expressions)

	if multiline_string then newlines = false end

	local last = node.expressions[#node.expressions]

	if last and last.kind == "function" and #node.expressions < 4 then
		newlines = false
	end

	if node.tokens["call("] and newlines then
		self:Indent()
		self:Whitespace("\n")
		self:Whitespace("\t")
	end

	self:PushForcedLineBreaking(newlines)
	self:EmitExpressionList(node.expressions)
	self:PopForcedLineBreaking()

	if newlines then self:Outdent() end

	if node.tokens["call)"] then
		if newlines then
			self:Whitespace("\n")
			self:Whitespace("\t")
		end

		self:EmitToken(node.tokens["call)"])
	else
		if self.config.force_parenthesis and not multiline_string then
			if newlines then
				self:Whitespace("\n")
				self:Whitespace("\t")
			end

			self:EmitNonSpace(")")
		end
	end

	self.inside_call_expression = false
end

function META:EmitBinaryOperator(node--[[#: Node]])
	local func_chunks = node.environment == "runtime" and
		runtime_syntax:GetFunctionForBinaryOperator(node.value)

	if func_chunks then
		self:Emit(func_chunks[1])

		if node.left then self:EmitExpression(node.left) end

		self:Emit(func_chunks[2])

		if node.right then self:EmitExpression(node.right) end

		self:Emit(func_chunks[3])
		self.operator_transformed = true
	else
		if node.left then self:EmitExpression(node.left) end

		if node.value.value == "." or node.value.value == ":" then
			self:EmitToken(node.value)
		elseif
			node.value.value == "and" or
			node.value.value == "or" or
			node.value.value == "||" or
			node.value.value == "&&"
		then
			if self:IsLineBreaking() then
				if
					self:GetPrevChar() == B(")") and
					node.left.kind ~= "postfix_call" and
					(
						node.left.kind == "binary_operator" and
						node.left.right.kind ~= "postfix_call"
					)
				then
					self:Whitespace("\n")
					self:Whitespace("\t")
				else
					self:Whitespace(" ")
				end

				self:EmitToken(node.value, translate_binary[node.value.value])

				if node.right then
					self:Whitespace("\n")
					self:Whitespace("\t")
				end
			else
				self:Whitespace(" ")
				self:EmitToken(node.value, translate_binary[node.value.value])
				self:Whitespace(" ")
			end
		else
			self:Whitespace(" ")
			self:EmitToken(node.value, translate_binary[node.value.value])
			self:Whitespace(" ")
		end

		if node.right then self:EmitExpression(node.right) end
	end
end

do
	function META:EmitFunctionBody(node--[[#: Node]])
		if node.identifiers_typesystem and not self.config.omit_invalid_code then
			local emitted = self:StartEmittingInvalidLuaCode()
			self:EmitToken(node.tokens["arguments_typesystem("])
			self:EmitExpressionList(node.identifiers_typesystem)
			self:EmitToken(node.tokens["arguments_typesystem)"])
			self:StopEmittingInvalidLuaCode(emitted)
		end

		self:EmitToken(node.tokens["arguments("])
		self:EmitLineBreakableList(node.identifiers, self.EmitIdentifierList)
		self:EmitToken(node.tokens["arguments)"])
		self:EmitFunctionReturnAnnotation(node)

		if #node.statements == 0 then
			self:Whitespace(" ")
		else
			self:Whitespace("\n")
			self:EmitBlock(node.statements)
			self:Whitespace("\n")
			self:Whitespace("\t")
		end
	end

	function META:EmitAnonymousFunction(node--[[#: Node]])
		self:EmitToken(node.tokens["function"])
		local distance = (node.tokens["end"].start - node.tokens["arguments)"].start)
		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitLocalFunction(node--[[#: Node]])
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["identifier"])
		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitLocalAnalyzerFunction(node--[[#: Node]])
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["analyzer"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["identifier"])
		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitLocalTypeFunction(node--[[#: Node]])
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["identifier"])
		self:EmitFunctionBody(node, true)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitTypeFunction(node--[[#: Node]])
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")

		if node.expression or node.identifier then
			self:EmitExpression(node.expression or node.identifier)
		end

		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitFunction(node--[[#: Node]])
		if node.tokens["local"] then
			self:EmitToken(node.tokens["local"])
			self:Whitespace(" ")
		end

		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitExpression(node.expression or node.identifier)
		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitAnalyzerFunctionStatement(node--[[#: Node]])
		if node.tokens["local"] then
			self:EmitToken(node.tokens["local"])
			self:Whitespace(" ")
		end

		if node.tokens["analyzer"] then
			self:EmitToken(node.tokens["analyzer"])
			self:Whitespace(" ")
		end

		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")

		if node.tokens["^"] then self:EmitToken(node.tokens["^"]) end

		if node.expression or node.identifier then
			self:EmitExpression(node.expression or node.identifier)
		end

		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end
end

function META:EmitTableExpressionValue(node--[[#: Node]])
	self:EmitToken(node.tokens["["])
	self:EmitExpression(node.key_expression)
	self:EmitToken(node.tokens["]"])
	self:Whitespace(" ")
	self:EmitToken(node.tokens["="])
	self:Whitespace(" ")
	self:EmitExpression(node.value_expression)
end

function META:EmitTableKeyValue(node--[[#: Node]])
	self:EmitToken(node.tokens["identifier"])
	self:Whitespace(" ")
	self:EmitToken(node.tokens["="])
	self:Whitespace(" ")
	local break_binary = node.value_expression.kind == "binary_operator" and
		self:ShouldLineBreakNode(node.value_expression)

	if break_binary then self:Indent() end

	self:PushForcedLineBreaking(break_binary)
	self:EmitExpression(node.value_expression)
	self:PopForcedLineBreaking()

	if break_binary then self:Outdent() end
end

function META:EmitEmptyUnion(node--[[#: Node]])
	self:EmitToken(node.tokens["|"])
end

function META:EmitTuple(node--[[#: Node]])
	self:EmitToken(node.tokens["("])
	self:EmitExpressionList(node.expressions)

	if #node.expressions == 1 then
		if node.expressions[1].tokens[","] then
			self:EmitToken(node.expressions[1].tokens[","])
		end
	end

	self:EmitToken(node.tokens[")"])
end

function META:EmitVararg(node--[[#: Node]])
	self:EmitToken(node.tokens["..."])
	self:EmitExpression(node.value)
end

function META:EmitTable(tree--[[#: Node]])
	if tree.spread then
		if self.config.omit_invalid_code then
			self:EmitNonSpace("table.mergetables")
		end
	end

	local during_spread = false
	self:EmitToken(tree.tokens["{"])
	local newline = self:ShouldLineBreakNode(tree)

	if newline then
		self:Whitespace("\n")
		self:Indent()
	end

	if tree.children[1] then
		for i, node in ipairs(tree.children) do
			if newline then self:Whitespace("\t") end

			if node.kind == "table_index_value" then
				if node.spread then
					if not self.config.omit_invalid_code then
						self:EmitToken(node.spread.tokens["..."])
						self:EmitExpression(node.spread.expression)
					else
						if during_spread then
							self:EmitNonSpace("},")
							during_spread = false
						end

						self:EmitExpression(node.spread.expression)
					end
				else
					self:EmitExpression(node.value_expression)
				end
			elseif node.kind == "table_key_value" then
				if self.config.omit_invalid_code and tree.spread and not during_spread then
					during_spread = true
					self:EmitNonSpace("{")
				end

				self:EmitTableKeyValue(node)
			elseif node.kind == "table_expression_value" then
				self:EmitTableExpressionValue(node)
			end

			if tree.tokens["separators"][i] then
				self:EmitToken(tree.tokens["separators"][i])
			else
				if newline then self:EmitNonSpace(",") end
			end

			if newline then
				self:Whitespace("\n")
			else
				if i ~= #tree.children then self:Whitespace(" ") end
			end
		end
	end

	if during_spread then self:EmitNonSpace("}") end

	if newline then
		self:Outdent()
		self:Whitespace("\t")
	end

	self:EmitToken(tree.tokens["}"])
end

function META:EmitPrefixOperator(node--[[#: Node]])
	local func_chunks = node.environment == "runtime" and
		runtime_syntax:GetFunctionForPrefixOperator(node.value)

	if self.TranslatePrefixOperator then
		func_chunks = self:TranslatePrefixOperator(node) or func_chunks
	end

	if func_chunks then
		self:Emit(func_chunks[1])
		self:EmitExpression(node.right)
		self:Emit(func_chunks[2])
		self.operator_transformed = true
	else
		if
			runtime_syntax:IsKeyword(node.value) or
			runtime_syntax:IsNonStandardKeyword(node.value)
		then
			self:OptionalWhitespace()
			self:EmitToken(node.value, translate_prefix[node.value.value])
			self:OptionalWhitespace()
			self:EmitExpression(node.right)
		else
			self:EmitToken(node.value, translate_prefix[node.value.value])
			self:OptionalWhitespace()
			self:EmitExpression(node.right)
		end
	end
end

function META:EmitPostfixOperator(node--[[#: Node]])
	local func_chunks = node.environment == "runtime" and
		runtime_syntax:GetFunctionForPostfixOperator(node.value)
	-- no such thing as postfix operator in lua,
	-- so we have to assume that there's a translation
	assert(func_chunks)
	self:Emit(func_chunks[1])
	self:EmitExpression(node.left)
	self:Emit(func_chunks[2])
	self.operator_transformed = true
end

function META:EmitBlock(statements--[[#: List<|Node|>]])
	self:PushForcedLineBreaking(false)
	self:Indent()
	self:EmitStatements(statements)
	self:Outdent()
	self:PopForcedLineBreaking()
end

function META:EmitIfStatement(node--[[#: Node]])
	local short = not self:ShouldLineBreakNode(node)

	for i = 1, #node.statements do
		if node.expressions[i] then
			if not short and i > 1 then
				self:Whitespace("\n")
				self:Whitespace("\t")
			end

			self:EmitToken(node.tokens["if/else/elseif"][i])
			self:EmitLineBreakableExpression(node.expressions[i])
			self:EmitToken(node.tokens["then"][i])
		elseif node.tokens["if/else/elseif"][i] then
			if not short then
				self:Whitespace("\n")
				self:Whitespace("\t")
			end

			self:EmitToken(node.tokens["if/else/elseif"][i])
		end

		if short then self:Whitespace(" ") else self:Whitespace("\n") end

		if #node.statements[i] == 1 and short then
			self:EmitStatement(node.statements[i][1])
		else
			self:EmitBlock(node.statements[i])
		end

		if short then self:Whitespace(" ") end
	end

	if not short then
		self:Whitespace("\n")
		self:Whitespace("\t")
	end

	self:EmitToken(node.tokens["end"])
end

function META:EmitGenericForStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["for"])
	self:Whitespace(" ")
	self:EmitIdentifierList(node.identifiers)
	self:Whitespace(" ")
	self:EmitToken(node.tokens["in"])
	self:Whitespace(" ")
	self:EmitExpressionList(node.expressions)
	self:Whitespace(" ")
	self:EmitToken(node.tokens["do"])
	self:PushLoop(node)
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:PopLoop()
	self:EmitToken(node.tokens["end"])
end

function META:EmitNumericForStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["for"])
	self:PushLoop(node)
	self:Whitespace(" ")
	self:EmitIdentifierList(node.identifiers)
	self:Whitespace(" ")
	self:EmitToken(node.tokens["="])
	self:Whitespace(" ")
	self:EmitExpressionList(node.expressions)
	self:Whitespace(" ")
	self:EmitToken(node.tokens["do"])
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:PopLoop()
	self:EmitToken(node.tokens["end"])
end

function META:EmitWhileStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["while"])
	self:EmitLineBreakableExpression(node.expression)
	self:EmitToken(node.tokens["do"])
	self:PushLoop(node)
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:PopLoop()
	self:EmitToken(node.tokens["end"])
end

function META:EmitRepeatStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["repeat"])
	self:PushLoop(node)
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\t")
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:PopLoop()
	self:EmitToken(node.tokens["until"])
	self:Whitespace(" ")
	self:EmitExpression(node.expression)
end

function META:EmitLabelStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["::"])
	self:EmitToken(node.tokens["identifier"])
	self:EmitToken(node.tokens["::"])
end

function META:EmitGotoStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["goto"])
	self:Whitespace(" ")
	self:EmitToken(node.tokens["identifier"])
end

function META:EmitBreakStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["break"])
end

function META:EmitContinueStatement(node--[[#: Node]])
	local loop_node = self.config.transpile_extensions and self:GetLoopNode()

	if loop_node then
		self:EmitToken(node.tokens["continue"], "goto __CONTINUE__")
		loop_node.on_pop = function()
			self:EmitNonSpace("::__CONTINUE__::;")
		end
	else
		self:EmitToken(node.tokens["continue"])
	end
end

function META:EmitDoStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["do"])
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:EmitToken(node.tokens["end"])
end

function META:EmitReturnStatement(node--[[#: Node]])
	self:EmitToken(node.tokens["return"])

	if node.expressions[1] then
		self:Whitespace(" ")
		self:PushForcedLineBreaking(self:ShouldLineBreakNode(node))
		self:EmitExpressionList(node.expressions)
		self:PopForcedLineBreaking()
	end
end

function META:EmitSemicolonStatement(node--[[#: Node]])
	if self.config.no_semicolon then
		self:EmitToken(node.tokens[";"], "")
	else
		self:EmitToken(node.tokens[";"])
	end
end

function META:EmitAssignment(node--[[#: Node]])
	if node.tokens["local"] then
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
	end

	if node.tokens["type"] then
		self:EmitToken(node.tokens["type"])
		self:Whitespace(" ")
	end

	if node.tokens["local"] then
		self:EmitIdentifierList(node.left)
	else
		self:EmitExpressionList(node.left)
	end

	if node.tokens["="] then
		self:Whitespace(" ")
		self:EmitToken(node.tokens["="])
		self:Whitespace(" ")
		self:PushForcedLineBreaking(self:ShouldBreakExpressionList(node.right))
		self:EmitExpressionList(node.right)
		self:PopForcedLineBreaking()
	end
end

function META:EmitStatement(node--[[#: Node]])
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
		self:EmitInvalidLuaCode("EmitAnalyzerFunctionStatement", node)
	elseif node.kind == "function" then
		self:EmitFunction(node)
	elseif node.kind == "local_function" then
		self:EmitLocalFunction(node)
	elseif node.kind == "local_analyzer_function" then
		self:EmitInvalidLuaCode("EmitLocalAnalyzerFunction", node)
	elseif node.kind == "local_type_function" then
		if node.identifiers_typesystem then
			self:EmitLocalTypeFunction(node)
		else
			self:EmitInvalidLuaCode("EmitLocalTypeFunction", node)
		end
	elseif node.kind == "type_function" then
		self:EmitInvalidLuaCode("EmitTypeFunction", node)
	elseif
		node.kind == "destructure_assignment" or
		node.kind == "local_destructure_assignment"
	then
		if self.config.comment_type_annotations or node.environment == "typesystem" then
			self:EmitInvalidLuaCode("EmitDestructureAssignment", node)
		elseif self.config.transpile_extensions then
			self:EmitTranspiledDestructureAssignment(node)
		else
			self:EmitDestructureAssignment(node)
		end
	elseif node.kind == "assignment" or node.kind == "local_assignment" then
		if node.environment == "typesystem" and self.config.comment_type_annotations then
			self:EmitInvalidLuaCode("EmitAssignment", node)
		else
			self:EmitAssignment(node)

			if node.kind == "assignment" then self:Emit_ENVFromAssignment(node) end
		end
	elseif node.kind == "call_expression" then
		self.is_call_expression = true
		self:EmitExpression(node.value)
		self.is_call_expression = false
	elseif node.kind == "shebang" then
		self:EmitToken(node.tokens["shebang"])
	elseif node.kind == "continue" then
		self:EmitContinueStatement(node)
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
		self:BuildCode(node)
	elseif node.kind == "analyzer_debug_code" then
		self:EmitInvalidLuaCode("EmitExpression", node.lua_code)
	elseif node.kind == "parser_debug_code" then
		self:EmitInvalidLuaCode("EmitExpression", node.lua_code)
	elseif node.kind then
		error("unhandled statement: " .. node.kind)
	else
		for k, v in pairs(node) do
			print(k, v)
		end

		error("invalid statement: " .. tostring(node))
	end

	if self.OnEmitStatement then
		if node.kind ~= "end_of_file" then self:OnEmitStatement() end
	end
end

local function general_kind(self--[[#: META.@Self]], node--[[#: Node]])
	if node.kind == "call_expression" then
		for i, v in ipairs(node.value.expressions) do
			if v.kind == "function" then return "other" end
		end
	end

	if
		node.kind == "call_expression" or
		node.kind == "local_assignment" or
		node.kind == "assignment" or
		node.kind == "return"
	then
		return "expression_statement"
	end

	return "other"
end

function META:EmitStatements(tbl--[[#: List<|Node|>]])
	for i, node in ipairs(tbl) do
		if i > 1 and general_kind(self, node) == "other" and node.kind ~= "end_of_file" then
			self:Whitespace("\n")
		end

		self:Whitespace("\t")
		self:EmitStatement(node)

		if
			node.kind ~= "semicolon" and
			node.kind ~= "end_of_file" and
			tbl[i + 1] and
			tbl[i + 1].kind ~= "end_of_file"
		then
			self:Whitespace("\n")
		end

		if general_kind(self, node) == "other" then
			if tbl[i + 1] and general_kind(self, tbl[i + 1]) == "expression_statement" then
				self:Whitespace("\n")
			end
		end
	end
end

function META:ShouldBreakExpressionList(tbl--[[#: List<|Node|>]])
	if self.config.preserve_whitespace == false then
		if #tbl == 0 then return false end

		local first_node = tbl[1]
		local last_node = tbl[#tbl]
		--first_node = first_node:GetStatement()
		--last_node = last_node:GetStatement()
		local start = first_node.code_start
		local stop = last_node.code_stop
		return (stop - start) > self.config.max_line_length
	end

	return false
end

function META:EmitNodeList(tbl--[[#: List<|Node|>]], func--[[#: Function]])
	for i = 1, #tbl do
		self:PushForcedLineBreaking(self:ShouldLineBreakNode(tbl[i]))
		local break_binary = self:IsLineBreaking() and tbl[i].kind == "binary_operator"

		if break_binary then self:Indent() end

		func(self, tbl[i])

		if break_binary then self:Outdent() end

		self:PopForcedLineBreaking()

		if i ~= #tbl then
			self:EmitToken(tbl[i].tokens[","])

			if self:IsLineBreaking() then
				self:Whitespace("\n")
				self:Whitespace("\t")
			else
				self:Whitespace(" ")
			end
		end
	end
end

function META:HasTypeNotation(node--[[#: Node]])
	return node.type_expression or node:GetLastType() or node.return_types
end

function META:EmitFunctionReturnAnnotationExpression(node, analyzer_function)
	if node.tokens["return:"] then
		self:EmitToken(node.tokens["return:"])
	else
		self:EmitNonSpace(":")
	end

	self:Whitespace(" ")

	if node.return_types then
		for i, exp in ipairs(node.return_types) do
			self:EmitTypeExpression(exp)

			if i ~= #node.return_types then self:EmitToken(exp.tokens[","]) end
		end
	elseif node:GetLastType() and self.config.type_annotations ~= "explicit" then
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

		if str[1] then self:EmitNonSpace(table.concat(str, ", ")) end
	end
end

function META:EmitFunctionReturnAnnotation(node--[[#: Node]], analyzer_function--[[#: Node]])
	if not self.config.type_annotations then return end

	if self:HasTypeNotation(node) and node.tokens["return:"] then
		self:EmitInvalidLuaCode("EmitFunctionReturnAnnotationExpression", node, analyzer_function)
	end
end

function META:EmitAnnotationExpression(node--[[#: Node]])
	if node.type_expression then
		self:EmitTypeExpression(node.type_expression)
	elseif node:GetLastType() and self.config.type_annotations ~= "explicit" then
		self:Emit(tostring(node:GetLastType():GetContract() or node:GetLastType()))
	end
end

function META:EmitAsAnnotationExpression(node--[[#: Node]])
	self:OptionalWhitespace()
	self:Whitespace(" ")
	self:EmitToken(node.tokens["as"])
	self:Whitespace(" ")
	self:EmitAnnotationExpression(node)
end

function META:EmitColonAnnotationExpression(node--[[#: Node]])
	if node.tokens[":"] then
		self:EmitToken(node.tokens[":"])
	else
		self:EmitNonSpace(":")
	end

	self:Whitespace(" ")
	self:EmitAnnotationExpression(node)
end

function META:EmitAnnotation(node--[[#: Node]])
	if not self.config.type_annotations then return end

	if self:HasTypeNotation(node) and not node.tokens["as"] then
		self:EmitInvalidLuaCode("EmitColonAnnotationExpression", node)
	end
end

function META:EmitIdentifier(node--[[#: Node]])
	if node.identifier then
		self:EmitToken(node.identifier)

		if not self.config.omit_invalid_code then
			local ok = self:StartEmittingInvalidLuaCode()
			self:EmitToken(node.tokens[":"])
			self:Whitespace(" ")
			self:EmitTypeExpression(node)
			self:StopEmittingInvalidLuaCode(ok)
		end

		return
	end

	self:EmitExpression(node)
end

do -- types
	function META:EmitTypeBinaryOperator(node--[[#: Node]])
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

	function META:EmitType(node--[[#: Node]])
		self:EmitToken(node.value)
		self:EmitAnnotation(node)
	end

	function META:EmitTableType(node--[[#: Node]])
		local tree = node
		self:EmitToken(tree.tokens["{"])
		local newline = self:ShouldLineBreakNode(tree)

		if newline then
			self:Indent()
			self:Whitespace("\n")
		end

		if tree.children[1] then
			for i, node in ipairs(tree.children) do
				if newline then self:Whitespace("\t") end

				if node.kind == "table_index_value" then
					if node.spread then
						self:EmitToken(node.spread.tokens["..."])
						self:EmitExpression(node.spread.expression)
					else
						self:EmitTypeExpression(node.value_expression)
					end
				elseif node.kind == "table_key_value" then
					self:EmitToken(node.tokens["identifier"])
					self:Whitespace(" ")
					self:EmitToken(node.tokens["="])
					self:Whitespace(" ")
					self:EmitTypeExpression(node.value_expression)
				elseif node.kind == "table_expression_value" then
					self:EmitToken(node.tokens["["])
					self:EmitTypeExpression(node.key_expression)
					self:EmitToken(node.tokens["]"])
					self:Whitespace(" ")
					self:EmitToken(node.tokens["="])
					self:Whitespace(" ")
					self:EmitTypeExpression(node.value_expression)
				end

				if tree.tokens["separators"][i] then
					self:EmitToken(tree.tokens["separators"][i])
				else
					if newline then self:EmitNonSpace(",") end
				end

				if newline then
					self:Whitespace("\n")
				else
					if i ~= #tree.children then self:Whitespace(" ") end
				end
			end
		end

		if newline then
			self:Outdent()
			self:Whitespace("\t")
		end

		self:EmitToken(tree.tokens["}"])
	end

	function META:EmitAnalyzerFunction(node--[[#: Node]])
		if node.tokens["analyzer"] then
			self:EmitToken(node.tokens["analyzer"])
			self:Whitespace(" ")
		end

		self:EmitToken(node.tokens["function"])

		if node.tokens["^"] then self:EmitToken(node.tokens["^"]) end

		self:EmitToken(node.tokens["arguments("])

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
					self:Whitespace(" ")
				end

				self:EmitTypeExpression(exp)
			end

			if i ~= #node.identifiers then
				if exp.tokens[","] then
					self:EmitToken(exp.tokens[","])
					self:Whitespace(" ")
				end
			end
		end

		self:EmitToken(node.tokens["arguments)"])

		if node.tokens[":"] then
			self:EmitToken(node.tokens[":"])
			self:Whitespace(" ")

			for i, exp in ipairs(node.return_types) do
				self:EmitTypeExpression(exp)

				if i ~= #node.return_types then
					self:EmitToken(exp.tokens[","])
					self:Whitespace(" ")
				end
			end
		end

		if node.statements then
			self:Whitespace("\n")
			self:EmitBlock(node.statements)
			self:Whitespace("\n")
			self:Whitespace("\t")
			self:EmitToken(node.tokens["end"])
		end
	end

	function META:EmitTypeExpression(node--[[#: Node]])
		if node.tokens["("] then
			for i = #node.tokens["("], 1, -1 do
				self:EmitToken(node.tokens["("][i])
			end
		end

		if node.kind == "binary_operator" then
			self:EmitTypeBinaryOperator(node)
		elseif node.kind == "analyzer_function" then
			self:EmitAnalyzerFunction(node)
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
		elseif node.kind == "table_expression_value" then
			self:EmitTableExpressionValue(node)
		elseif node.kind == "table_key_value" then
			self:EmitTableKeyValue(node)
		elseif node.kind == "empty_union" then
			self:EmitEmptyUnion(node)
		elseif node.kind == "tuple" then
			self:EmitTuple(node)
		elseif node.kind == "type_function" then
			self:EmitTypeFunction(node)
		elseif node.kind == "function" then
			self:EmitAnonymousFunction(node)
		elseif node.kind == "function_signature" then
			self:EmitFunctionSignature(node)
		elseif node.kind == "vararg" then
			self:EmitVararg(node)
		else
			error("unhandled token type " .. node.kind)
		end

		if node.tokens["as"] then
			self:Whitespace(" ")
			self:EmitToken(node.tokens["as"])
			self:Whitespace(" ")
		end

		if node.type_expression then
			self:EmitTypeExpression(node.type_expression)
		end

		if node.tokens[")"] then
			for _, node in ipairs(node.tokens[")"]) do
				self:EmitToken(node)
			end
		end

		if node.tokens[")"] and newlines then
			self:Outdent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		end
	end

	function META:StartEmittingInvalidLuaCode()
		local emitted = false

		if self.config.comment_type_annotations then
			if not self.during_comment_type or self.during_comment_type == 0 then
				self:EmitNonSpace("--[[#")
				emitted = #self.out
			end

			self.during_comment_type = self.during_comment_type or 0
			self.during_comment_type = self.during_comment_type + 1
		end

		return emitted
	end

	function META:StopEmittingInvalidLuaCode(emitted--[[#: boolean]])
		if emitted then
			if self:GetPrevChar() == B("]") then self:Whitespace(" ") end

			local needs_escape = false

			for i = emitted, #self.out do
				local str = self.out[i]

				if str:find("]]", nil, true) then
					self.out[emitted] = "--[=[#"
					needs_escape = true

					break
				end
			end

			if needs_escape then
				self:EmitNonSpace("]=]")
			else
				self:EmitNonSpace("]]")
			end
		end

		if self.config.comment_type_annotations then
			self.during_comment_type = self.during_comment_type - 1
		end
	end

	function META:EmitInvalidLuaCode(func--[[#: ref keyof<|META|>]], ...--[[#: ref ...any]])
		if self.config.omit_invalid_code then return true end

		local i = self.i
		local emitted = self:StartEmittingInvalidLuaCode()
		self[func](self, ...)
		self:StopEmittingInvalidLuaCode(emitted)

		if self.config.blank_invalid_code then
			for i = self.i, i, -1 do
				if self.out[i] then self.out[i] = self.out[i]:gsub("%S+", "") end
			end
		end

		return emitted
	end
end

do -- extra
	function META:EmitTranspiledDestructureAssignment(node--[[#: Node]])
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
		self:EmitNonSpace("table.destructure(")
		self:EmitExpression(node.right)
		self:EmitNonSpace(",")
		self:EmitSpace(" ")
		self:EmitNonSpace("{")

		for i, v in ipairs(node.left) do
			self:EmitNonSpace("\"")
			self:Emit(v.value.value)
			self:EmitNonSpace("\"")

			if i ~= #node.left then
				self:EmitNonSpace(",")
				self:EmitSpace(" ")
			end
		end

		self:EmitNonSpace("}")

		if node.default then
			self:EmitNonSpace(",")
			self:EmitSpace(" ")
			self:EmitNonSpace("true")
		end

		self:EmitNonSpace(")")
	end

	function META:EmitDestructureAssignment(node--[[#: Node]])
		if node.tokens["local"] then self:EmitToken(node.tokens["local"]) end

		if node.tokens["type"] then
			self:Whitespace(" ")
			self:EmitToken(node.tokens["type"])
		end

		self:Whitespace(" ")
		self:EmitToken(node.tokens["{"])
		self:Whitespace(" ")
		self:EmitLineBreakableList(node.left, self.EmitIdentifierList)
		self:PopForcedLineBreaking()
		self:Whitespace(" ")
		self:EmitToken(node.tokens["}"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["="])
		self:Whitespace(" ")
		self:EmitExpression(node.right)
	end

	function META:Emit_ENVFromAssignment(node--[[#: Node]])
		for i, v in ipairs(node.left) do
			if v.kind == "value" and v.value.value == "_ENV" then
				if node.right[i] then
					local key = node.left[i]
					local val = node.right[i]
					self:EmitNonSpace(";setfenv(1, _ENV);")
				end
			end
		end
	end

	function META:EmitImportExpression(node--[[#: Node]])
		if not node.path then
			self:EmitToken(node.left.value)

			if node.tokens["call("] then
				self:EmitToken(node.tokens["call("])
			elseif self.config.force_parenthesis then
				self:EmitNonSpace("(")
			end

			self:EmitExpressionList(node.expressions)

			if node.tokens["call)"] then
				self:EmitToken(node.tokens["call)"])
			elseif self.config.force_parenthesis then
				self:EmitNonSpace(")")
			end

			return
		end

		if node.left.value.value == "loadfile" then
			self:EmitToken(node.left.value, "IMPORTS['" .. node.key .. "']")
		else
			self:EmitToken(node.left.value, "IMPORTS['" .. node.key .. "']")

			if node.tokens["call("] then
				self:EmitToken(node.tokens["call("])
			elseif self.config.force_parenthesis then
				self:EmitNonSpace("(")
			end

			self:EmitExpressionList(node.expressions)

			if node.tokens["call)"] then
				self:EmitToken(node.tokens["call)"])
			elseif self.config.force_parenthesis then
				self:EmitNonSpace(")")
			end
		end
	end

	function META:EmitRequireExpression(node--[[#: Node]])
		self:EmitToken(node.tokens["require"])
		self:EmitToken(node.tokens["arguments("])
		self:EmitExpressionList(node.expressions)
		self:EmitToken(node.tokens["arguments)"])
	end
end

do
	function META:EmitLSXExpression(node)
		self:EmitToken(node.tokens["<"])
		self:EmitExpression(node.tag)

		for _, prop in ipairs(node.props) do
			if prop.kind == "table_spread" then
				self:Whitespace(" ")
				self:EmitToken(prop.tokens["{"])
				self:EmitToken(prop.tokens["..."])
				self:EmitExpression(prop.expression)
				self:EmitToken(prop.tokens["}"])
			else
				self:Whitespace(" ")
				self:EmitToken(prop.tokens["identifier"])
				self:EmitToken(prop.tokens["="])

				if prop.tokens["{"] then
					self:EmitToken(prop.tokens["{"])
					self:EmitExpression(prop.value_expression)
					self:EmitToken(prop.tokens["}"])
				else
					self:EmitToken(prop.val)
				end
			end
		end

		if node.children[1] then
			self:EmitToken(node.tokens[">"])
			self:Indent()
			self:Whitespace("\n")
			self:Whitespace("\t")

			for _, child in ipairs(node.children) do
				if child.kind == "value" then
					self:EmitExpression(child)
				elseif child.type == "expression" and child.kind == "lsx" then
					self:EmitLSXExpression(child)
				else
					self:EmitToken(child.tokens["lsx{"])
					self:EmitExpression(child)
					self:EmitToken(child.tokens["lsx}"])
				end
			end

			self:Outdent()
			self:Whitespace("\n")
			self:Whitespace("\t")
			self:EmitToken(node.tokens["<2"])
			self:EmitToken(node.tokens["/"])
			self:EmitToken(node.tokens["type2"])
			self:EmitToken(node.tokens[">2"])
			self:Whitespace("\n")
			self:Whitespace("\t")
		else
			self:EmitToken(node.tokens["/"])
			self:EmitToken(node.tokens[">"])
		end
	end

	function META:EmitTranspiledLSXExpression(node)
		self:EmitToken(node.tokens["<"], "LSX(")
		self:EmitExpression(node.tag)
		self:Emit(",")
		self:Emit("{")

		for i, prop in ipairs(node.props) do
			if prop.kind == "table_spread" then
				self:Whitespace(" ")
				self:EmitToken(prop.tokens["{"])
				self:EmitToken(prop.tokens["..."])
				self:EmitExpression(prop.expression)
				self:EmitToken(prop.tokens["}"])
			else
				self:Whitespace(" ")
				self:EmitToken(prop.key, "{k=")
				self:EmitNonSpace("\"")
				self:EmitNonSpace(prop.key.value)
				self:EmitNonSpace("\"")
				self:EmitToken(prop.tokens["="], ",")
				self:EmitNonSpace("v=")

				if prop.tokens["{"] then
					self:EmitToken(prop.tokens["{"], "")
					self:EmitExpression(prop.val)
					self:EmitToken(prop.tokens["}"], "")
				else
					self:EmitToken(prop.val)
				end

				self:Emit("}")
			end

			if i ~= #node.props then self:Emit(",") end
		end

		if node.children[1] then
			self:EmitToken(node.tokens[">"], "},{")
			self:Indent()
			self:Whitespace("\n")
			self:Whitespace("\t")

			for i, child in ipairs(node.children) do
				if child.kind == "value" then
					self:EmitExpression(child)
				elseif child.type == "expression" and child.kind == "lsx" then
					self:EmitTranspiledLSXExpression(child)
				else
					self:EmitToken(child.tokens["lsx{"], "")
					self:EmitExpression(child)
					self:EmitToken(child.tokens["lsx}"], "")
				end

				if i ~= #node.children then self:Emit(",") end
			end

			self:Outdent()
			self:Whitespace("\n")
			self:Whitespace("\t")
			self:EmitToken(node.tokens["<2"], "")
			self:EmitToken(node.tokens["/"], "")
			self:EmitToken(node.tokens["type2"], "")
			self:EmitToken(node.tokens[">2"], "})")
			self:Whitespace("\n")
			self:Whitespace("\t")
		else
			self:EmitToken(node.tokens["/"], "")
			self:EmitToken(node.tokens[">"], "})")
		end
	end
end

function META.New(config--[[#: TranspilerConfig]])
	local self = setmetatable({}, META)
	self.config = config or {}
	self.config.max_argument_length = self.config.max_argument_length or 5
	self.config.max_line_length = self.config.max_line_length or 80

	if self.config.comment_type_annotations == nil then
		self.config.comment_type_annotations = true
	end

	self:Initialize()
	return self
end

return META