--DONT_ANALYZE
local Compiler = require("nattlua.compiler").New
local helpers = require("nattlua.other.helpers")
local b64 = require("nattlua.other.base64")
local Union = require("nattlua.types.union").Union
local Table = require("nattlua.types.table").Table
local runtime_syntax = require("nattlua.syntax.runtime")
local typesystem_syntax = require("nattlua.syntax.typesystem")
local lsp = {}
lsp.methods = {}
local TextDocumentSyncKind = {None = 0, Full = 1, Incremental = 2}
local DiagnosticSeverity = {
	error = 1,
	fatal = 1, -- from lexer and parser
	warning = 2,
	information = 3,
	hint = 4,
}
local SymbolKind = {
	File = 1,
	Module = 2,
	Namespace = 3,
	Package = 4,
	Class = 5,
	Method = 6,
	Property = 7,
	Field = 8,
	Constructor = 9,
	Enum = 10,
	Interface = 11,
	Function = 12,
	Variable = 13,
	Constant = 14,
	String = 15,
	Number = 16,
	Boolean = 17,
	Array = 18,
	Object = 19,
	Key = 20,
	Null = 21,
	EnumMember = 22,
	Struct = 23,
	Event = 24,
	Operator = 25,
	TypeParameter = 26,
}
local SemanticTokenTypes = {
	-- identifiers or reference
	"class", -- a class type. maybe META or Meta?
	"typeParameter", -- local type >foo< = true
	"parameter", -- function argument: function foo(>a<)
	"variable", -- a local or global variable.
	"property", -- a member property, member field, or member variable.
	"enumMember", -- an enumeration property, constant, or member. uppercase variables and global non tables? local FOO = true ?
	"event", --  an event property.
	"function", -- local or global function: local function >foo<
	"method", --  a member function or method: string.>bar<()
	"type", -- misc type
	-- tokens
	"comment", -- 
	"string", -- 
	"keyword", -- 
	"number", -- 
	"regexp", -- regular expression literal.
	"operator", --
	"decorator", -- decorator syntax, maybe for @Foo in tables, $ and §
	-- other identifiers or references
	"namespace", -- namespace, module, or package.
	"enum", -- 
	"interface", --
	"struct", -- 
	"decorator", -- decorators and annotations.
	"macro", --  a macro.
	"label", --  a label. ??
}
local SemanticTokenModifiers = {
	"declaration", -- For declarations of symbols.
	"definition", -- For definitions of symbols, for example, in header files.
	"readonly", -- For readonly variables and member fields (constants).
	"static", -- For class members (static members).
	"private", -- For class members (static members).
	"deprecated", -- For symbols that should no longer be used.
	"abstract", -- For types and member functions that are abstract.
	"async", -- For functions that are marked async.
	"modification", -- For variable references where the variable is assigned to.
	"documentation", -- For occurrences of symbols in documentation.
	"defaultLibrary", -- For symbols that are part of the standard library.
}

local function find_type_from_token(token)
	local found_parents = {}

	do
		local node = token.parent

		while node and node.parent do
			table.insert(found_parents, node)
			node = node.parent
		end
	end

	local scope

	for _, node in ipairs(found_parents) do
		if node.scope then
			scope = node.scope

			break
		end
	end

	local union = Union({})

	for _, node in ipairs(found_parents) do
		local found = false

		for _, obj in ipairs(node:GetTypes()) do
			if type(obj) ~= "table" then
				print("UH OH", obj, node, "BAD VALUE IN GET TYPES")
			else
				if obj.Type == "string" and obj:GetData() == token.value then

				else
					if obj.Type == "table" then obj = obj:GetMutatedFromScope(scope) end

					union:AddType(obj)
					found = true
				end
			end
		end

		if found then break end
	end

	if union:IsEmpty() then return nil, found_parents, scope end

	if union:GetLength() == 1 then
		return union:GetData()[1], found_parents, scope
	end

	return union, found_parents, scope
end

local function token_to_type_mod(token)
	if token.type == "symbol" and token.parent.kind == "function_signature" then
		return {[token] = {"keyword"}}
	end

	if
		runtime_syntax:IsNonStandardKeyword(token) or
		typesystem_syntax:IsNonStandardKeyword(token)
	then
		-- check if it's used in a statement, because foo.type should not highlight
		if token.parent and token.parent.type == "statement" then
			return {[token] = {"keyword"}}
		end
	end

	if runtime_syntax:IsKeywordValue(token) or typesystem_syntax:IsKeywordValue(token) then
		return {[token] = {"type"}}
	end

	if
		token.value == "." or
		token.value == ":" or
		token.value == "=" or
		token.value == "or" or
		token.value == "and" or
		token.value == "not"
	then
		return {[token] = {"operator"}}
	end

	if runtime_syntax:IsKeyword(token) or typesystem_syntax:IsKeyword(token) then
		return {[token] = {"keyword"}}
	end

	if
		runtime_syntax:GetTokenType(token):find("operator") or
		typesystem_syntax:GetTokenType(token):find("operator")
	then
		return {[token] = {"operator"}}
	end

	if token.type == "symbol" then return {[token] = {"keyword"}} end

	do
		local obj = find_type_from_token(token)

		if obj then
			local mods = {}

			if obj:IsLiteral() then table.insert(mods, "readonly") end

			if obj.Type == "union" then
				if obj:IsTypeExceptNil("number") then
					return {[token] = {"number", mods}}
				elseif obj:IsTypeExceptNil("string") then
					return {[token] = {"string", mods}}
				elseif obj:IsTypeExceptNil("symbol") then
					return {[token] = {"enumMember", mods}}
				end

				return {[token] = {"event"}}
			end

			if obj.Type == "number" then
				return {[token] = {"number", mods}}
			elseif obj.Type == "string" then
				return {[token] = {"string", mods}}
			elseif obj.Type == "tuple" or obj.Type == "symbol" then
				return {[token] = {"enumMember", mods}}
			elseif obj.Type == "any" then
				return {[token] = {"regexp", mods}}
			end

			if obj.Type == "function" then return {[token] = {"function", mods}} end

			local parent = obj:GetParent()

			if parent then
				if obj.Type == "function" then
					return {[token] = {"macro", mods}}
				else
					if obj.Type == "table" then return {[token] = {"class", mods}} end

					return {[token] = {"property", mods}}
				end
			end

			if obj.Type == "table" then return {[token] = {"class", mods}} end
		end
	end

	if token.type == "number" then
		return {[token] = {"number"}}
	elseif token.type == "string" then
		return {[token] = {"string"}}
	end

	if
		token.parent.kind == "value" and
		token.parent.parent.kind == "binary_operator" and
		(
			token.parent.parent.value and
			token.parent.parent.value.value == "." or
			token.parent.parent.value.value == ":"
		)
	then
		if token.value:sub(1, 1) == "@" then return {[token] = {"decorator"}} end
	end

	if token.type == "letter" and token.parent.kind:find("function", nil, true) then
		return {[token] = {"function"}}
	end

	if
		token.parent.kind == "value" and
		token.parent.parent.kind == "binary_operator" and
		(
			token.parent.parent.value and
			token.parent.parent.value.value == "." or
			token.parent.parent.value.value == ":"
		)
	then
		return {[token] = {"property"}}
	end

	if token.parent.kind == "table_key_value" then
		return {[token] = {"property"}}
	end

	if token.parent.standalone_letter then
		if token.parent.environment == "typesystem" then
			return {[token] = {"type"}}
		end

		if _G[token.value] then return {[token] = {"namespace"}} end

		return {[token] = {"variable"}}
	end

	if token.parent.is_identifier then
		if token.parent.environment == "typesystem" then
			return {[token] = {"typeParameter"}}
		end

		return {[token] = {"variable"}}
	end

	do
		return {[token] = {"comment"}}
	end
end

local working_directory

local function get_range(code, start, stop)
	local data = helpers.SubPositionToLinePosition(code:GetString(), start, stop)
	return {
		start = {
			line = data.line_start - 1,
			character = data.character_start - 1,
		},
		["end"] = {
			line = data.line_stop - 1,
			character = data.character_stop, -- not sure about this
		},
	}
end

local function find_token_from_line_character(
	tokens--[[#: {[number] = Token}]],
	code--[[#: string]],
	line--[[#: number]],
	char--[[#: number]]
)
	local sub_pos = helpers.LinePositionToSubPosition(code, line, char)

	for _, token in ipairs(tokens) do
		if sub_pos >= token.start and sub_pos <= token.stop then
			return token, helpers.SubPositionToLinePosition(code, token.start, token.stop)
		end
	end
end

local function get_analyzer_config()
	--[[#£ parser.dont_hoist_next_import = true]]

	local f, err = loadfile("./nlconfig.lua")
	local cfg = {}

	if f then cfg = f("get-analyzer-config") or cfg end

	if cfg.type_annotations == nil then cfg.type_annotations = true end

	return cfg
end

local function get_emitter_config()
	--[[#£ parser.dont_hoist_next_import = true]]

	local f, err = loadfile("./nlconfig.lua")
	local cfg = {
		preserve_whitespace = false,
		string_quote = "\"",
		no_semicolon = true,
		comment_type_annotations = true,
		type_annotations = "explicit",
		force_parenthesis = true,
		skip_import = true,
	}

	if f then cfg = f("get-emitter-config") or cfg end

	return cfg
end

local BuildBaseEnvironment = require("nattlua.runtime.base_environment").BuildBaseEnvironment
local runtime_env, typesystem_env = BuildBaseEnvironment()
local cache = {}
local temp_files = {}

local function find_file(uri)
	if not cache[uri] then
		print("no such file loaded ", uri)

		for k, v in pairs(cache) do
			print(k)
		end
	end

	return cache[uri]
end

local function store_file(uri, code, tokens)
	cache[uri] = {
		code = code,
		tokens = tokens,
	}
end

local function find_temp_file(uri)
	return temp_files[uri]
end

local function store_temp_file(uri, content)
	print("storing ", uri, #content)
	temp_files[uri] = content
end

local function clear_temp_file(uri)
	print("clearing ", uri)
	temp_files[uri] = nil
end

local function recompile(uri)
	local responses = {}
	local compiler
	local entry_point
	local cfg

	if working_directory then
		cfg = get_analyzer_config()
		entry_point = cfg.entry_point

		if not entry_point and uri then
			entry_point = uri:gsub(working_directory .. "/", "")
		end

		if not entry_point then return false end

		cfg.inline_require = false
		cfg.on_read_file = function(parser, path)
			responses[path] = responses[path] or
				{
					method = "textDocument/publishDiagnostics",
					params = {uri = working_directory .. "/" .. path, diagnostics = {}},
				}
			return find_temp_file(working_directory .. "/" .. path)
		end
		compiler = Compiler([[return import("./]] .. entry_point .. [[")]], "file://" .. entry_point, cfg)
	else
		compiler = Compiler(find_temp_file(uri), uri)
		responses[uri] = responses[uri] or
			{
				method = "textDocument/publishDiagnostics",
				params = {uri = uri, diagnostics = {}},
			}
	end

	compiler.debug = true
	compiler:SetEnvironments(runtime_env, typesystem_env)

	do
		function compiler:OnDiagnostic(code, msg, severity, start, stop, node, ...)
			local range = get_range(code, start, stop)

			if not range then return end

			local name = code:GetName()
			print("error: ", name, msg, severity, ...)
			responses[name] = responses[name] or
				{
					method = "textDocument/publishDiagnostics",
					params = {uri = working_directory .. "/" .. name, diagnostics = {}},
				}
			table.insert(
				responses[name].params.diagnostics,
				{
					severity = DiagnosticSeverity[severity],
					range = range,
					message = helpers.FormatMessage(msg, ...),
				}
			)
		end

		if compiler:Parse() then
			if compiler.SyntaxTree.imports then
				for _, root_node in ipairs(compiler.SyntaxTree.imports) do
					local root = root_node.RootStatement

					if root_node.RootStatement then
						if not root_node.RootStatement.parser then
							root = root_node.RootStatement.RootStatement
						end

						store_file(
							working_directory .. "/" .. root.parser.config.file_path,
							root.code,
							root.lexer_tokens
						)
					end
				end
			else
				store_file(uri, compiler.Code, compiler.Tokens)
			end

			local should_analyze = true

			if cfg then
				if entry_point then
					local code = assert(io.open((cfg.working_directory or "") .. entry_point, "r")):read("*all")
					should_analyze = code:find("-" .. "-ANALYZE", nil, true)
				end

				if not should_analyze and uri and uri:find("%.nlua$") then
					should_analyze = true
				end
			end

			if should_analyze then
				print("RECOMPILE")
				local ok, err = compiler:Analyze()

				if not ok then
					local name = compiler:GetCode():GetName()
					responses[name] = responses[name] or
						{
							method = "textDocument/publishDiagnostics",
							params = {uri = working_directory .. "/" .. name, diagnostics = {}},
						}
					table.insert(
						responses[name].params.diagnostics,
						{
							severity = DiagnosticSeverity["fatal"],
							range = get_range(compiler:GetCode(), 1, compiler:GetCode():GetByteSize()),
							message = err,
						}
					)
				end

				print(ok, err)
			end

			lsp.Call({method = "workspace/semanticTokens/refresh", params = {}})
		end

		for _, resp in pairs(responses) do
			lsp.Call(resp)
		end
	end

	return true
end

lsp.methods["initialize"] = function(params)
	working_directory = params.workspaceFolders[1].uri
	return {
		clientInfo = {name = "NattLua", version = "1.0"},
		capabilities = {
			textDocumentSync = {
				openClose = true,
				change = TextDocumentSyncKind.Full,
			},
			semanticTokensProvider = {
				legend = {
					tokenTypes = SemanticTokenTypes,
					tokenModifiers = SemanticTokenModifiers,
				},
				full = true,
				range = false,
			},
			hoverProvider = true,
			publishDiagnostics = {
				relatedInformation = true,
				tagSupport = {1, 2},
			},
			inlayHintProvider = {
				resolveProvider = true,
			},
			definitionProvider = true,
		-- for symbols like all functions within a file
		-- documentSymbolProvider = {label = "NattLua"},
		-- highlighting equal upvalues
		-- documentHighlightProvider = true, 
		--[[completionProvider = {
				resolveProvider = true,
				triggerCharacters = { ".", ":" },
			},
			signatureHelpProvider = {
				triggerCharacters = { "(" },
			},
			definitionProvider = true,
			referencesProvider = true,
			
			workspaceSymbolProvider = true,
			codeActionProvider = true,
			codeLensProvider = {
				resolveProvider = true,
			},
			documentFormattingProvider = true,
			documentRangeFormattingProvider = true,
			documentOnTypeFormattingProvider = {
				firstTriggerCharacter = "}",
				moreTriggerCharacter = { "end" },
			},
			renameProvider = true,
			]] },
	}
end
lsp.methods["initialized"] = function(params)
	recompile()
end
lsp.methods["nattlua/format"] = function(params)
	local config = get_emitter_config()
	config.comment_type_annotations = params.path:sub(-#".lua") == ".lua"
	config.transpile_extensions = params.path:sub(-#".lua") == ".lua"
	local compiler = Compiler(params.code, "@" .. params.path, config)
	local code, err = compiler:Emit()
	return {code = b64.encode(code)}
end
lsp.methods["nattlua/syntax"] = function(params)
	local data = require("nattlua.syntax.monarch_language")
	print("SENDING SYNTAX", #data)
	return {data = b64.encode(data)}
end
lsp.methods["shutdown"] = function(params)
	print("SHUTDOWN")
	table.print(params)
end

do -- semantic tokens
	local tokenTypeMap = {}
	local tokenModifiersMap = {}

	for i, v in ipairs(SemanticTokenTypes) do
		tokenTypeMap[v] = i - 1
	end

	for i, v in ipairs(SemanticTokenModifiers) do
		tokenModifiersMap[v] = i - 1
	end

	lsp.methods["textDocument/semanticTokens/range"] = function(params)
		print("SEMANTIC TOKENS RANGE")
		table.print(params)

		do
			return
		end

		local textDocument = params.textDocument
		local range = params
	end
	lsp.methods["textDocument/semanticTokens/full"] = function(params)
		local data = find_file(params.textDocument.uri)
		print("SEMANTIC TOKENS FULL REFRESH", data)

		if not data then return end

		local integers = {}
		local last_y = 0
		local last_x = 0
		local mods = {}

		for _, token in ipairs(data.tokens) do
			if token.type ~= "end_of_file" and token.parent then
				local modified_tokens = token_to_type_mod(token)

				if modified_tokens then
					for token, flags in pairs(modified_tokens) do
						mods[token] = flags
					end
				end
			end
		end

		for _, token in ipairs(data.tokens) do
			if mods[token] then
				local type, modifiers = unpack(mods[token])
				local data = helpers.SubPositionToLinePosition(data.code:GetString(), token.start, token.stop)
				local len = #token.value
				local y = (data.line_start - 1) - last_y
				local x = (data.character_start - 1) - last_x

				-- x is not relative when there's a new line
				if y ~= 0 then x = data.character_start - 1 end

				if type and x >= 0 and y >= 0 then
					table.insert(integers, y)
					table.insert(integers, x)
					table.insert(integers, len)
					assert(tokenTypeMap[type], "invalid type " .. type)
					table.insert(integers, tokenTypeMap[type])
					local result = 0

					if modifiers then
						for _, mod in ipairs(modifiers) do
							assert(tokenModifiersMap[mod], "invalid modifier " .. mod)
							result = bit.bor(result, bit.lshift(1, tokenModifiersMap[mod])) -- TODO, doesn't seem to be working
						end
					end

					table.insert(integers, result)
					last_y = data.line_start - 1
					last_x = data.character_start - 1
				end
			end
		end

		return {data = integers}
	end
end

lsp.methods["$/cancelRequest"] = function(params)
	do
		return
	end

	print("cancelRequest")
	table.print(params)
end
lsp.methods["workspace/didChangeConfiguration"] = function(params)
	print("configuration changed")
	table.print(params)
end
lsp.methods["textDocument/didOpen"] = function(params)
	store_temp_file(params.textDocument.uri, params.textDocument.text)
	recompile(params.textDocument.uri)
end
lsp.methods["textDocument/didClose"] = function(params)
	clear_temp_file(params.textDocument.uri)
end
lsp.methods["textDocument/didChange"] = function(params)
	store_temp_file(params.textDocument.uri, params.contentChanges[1].text)
	recompile(params.textDocument.uri)
end
lsp.methods["textDocument/didSave"] = function(params)
	clear_temp_file(params.textDocument.uri)
	recompile(params.textDocument.uri)
end

local function find_token(uri, line, character)
	local data = find_file(uri)

	if not data then
		print("unable to find token", uri, line, character)
		return
	end

	local token, data = find_token_from_line_character(data.tokens, data.code:GetString(), line + 1, character + 1)
	return token, data
end

local function find_token_from_line_character_range(
	uri--[[#: string]],
	lineStart--[[#: number]],
	charStart--[[#: number]],
	lineStop--[[#: number]],
	charStop--[[#: number]]
)
	local data = find_file(uri)

	if not data then
		print(
			"unable to find requested token range",
			uri,
			lineStart,
			charStart,
			lineStop,
			charStop
		)
		return
	end

	local sub_pos_start = helpers.LinePositionToSubPosition(data.code, lineStart, charStart)
	local sub_pos_stop = helpers.LinePositionToSubPosition(data.code, lineStop, charStop)
	local found = {}

	for _, token in ipairs(tokens) do
		if token.start >= sub_pos_start and token.stop <= sub_pos_stop then
			table.insert(found, token)
		end
	end

	return found
end

local function has_value(tbl, str)
	for _, v in ipairs(tbl) do
		if v == str then return true end
	end

	return false
end

local function find_parent(token, type, kind)
	local node = token.parent

	if not node then return nil end

	while node.parent do
		if node.type == type and node.kind == kind then return node end

		node = node.parent
	end

	return nil
end

local function find_nodes(tokens, type, kind)
	local nodes = {}
	local done = {}

	for _, token in ipairs(tokens) do
		local node = find_parent(token, type, kind)

		if node and not done[node] then
			table.insert(nodes, node)
			done[node] = true
		end
	end

	return nodes
end

lsp.methods["textDocument/inlayHint"] = function(params)
	local tokens = find_token_from_line_character_range(
		params.textDocument.uri,
		params.start.line - 1,
		params.start.character - 1,
		params["end"].line - 1,
		params["end"].character - 1
	)

	if not tokens then return end

	local hints = {}
	local assignments = find_nodes(tokens, "statement", "local_assignment")

	for _, assingment in ipairs(find_nodes(tokens, "statement", "assignment")) do
		table.insert(assignments, assingment)
	end

	for _, assignment in ipairs(assignments) do
		if assignment.environment == "runtime" then
			for i, left in ipairs(assignment.left) do
				if not left.tokens[":"] and assignment.right and assignment.right[i] then
					local types = left:GetTypes()

					if
						types and
						(
							assignment.right[i].kind ~= "value" or
							assignment.right[i].value.value.type == "letter"
						)
					then
						local data = helpers.SubPositionToLinePosition(compiler.Code:GetString(), left:GetStartStop())
						local label = tostring(Union(types))

						if #label > 20 then label = label:sub(1, 20) .. "..." end

						table.insert(
							hints,
							{
								label = ": " .. label,
								tooltip = tostring(Union(types)),
								position = {
									lineNumber = data.line_stop,
									column = data.character_stop + 1,
								},
								kind = 1, -- type
							}
						)
					end
				end
			end
		end
	end

	return hints
end
lsp.methods["textDocument/rename"] = function(params)
	do
		return
	end

	local token, data = find_token(params.textDocument.uri, params.position.line, params.position.character)

	if not token or not data or not token.parent then return end

	local obj = find_type_from_token(token)
	local upvalue = obj:GetUpvalue()
	local changes = {}

	if upvalue and upvalue.mutations then
		for i, v in ipairs(upvalue.mutations) do
			local node = v.value:GetNode()

			if node then
				changes[params.textDocument.uri] = changes[params.textDocument.uri] or
					{
						textDocument = {
							version = nil,
						},
						edits = {},
					}
				local edits = changes[params.textDocument.uri].edits
				table.insert(
					edits,
					{
						range = get_range(node.Code, node:GetStartStop()),
						newText = params.newName,
					}
				)
			end
		end
	end

	return {
		changes = changes,
	}
end
lsp.methods["textDocument/definition"] = function(params)
	local token, data = find_token(params.textDocument.uri, params.position.line, params.position.character)

	if not token or not data or not token.parent then return end

	local obj = find_type_from_token(token)

	if not obj or not obj:GetUpvalue() then return end

	local node = obj:GetUpvalue():GetNode()

	if not node then return end

	local data = find_file(params.textDocument.uri)
	return {
		uri = params.textDocument.uri,
		range = get_range(data.code, node:GetStartStop()),
	}
end
lsp.methods["textDocument/hover"] = function(params)
	local token, data = find_token(params.textDocument.uri, params.position.line, params.position.character)

	if not token or not data or not token.parent then return end

	local markdown = ""

	local function add_line(str)
		markdown = markdown .. str .. "\n\n"
	end

	local function add_code(str)
		add_line("```lua\n" .. tostring(str) .. "\n```")
	end

	local obj, found_parents, scope = find_type_from_token(token)

	if obj then
		add_code(tostring(obj))
		local upvalue = obj:GetUpvalue()

		if upvalue then
			add_code(tostring(upvalue))

			if upvalue:HasMutations() then
				local code = ""

				for i, mutation in ipairs(upvalue.Mutations) do
					code = code .. "-- " .. i .. "\n"
					code = code .. "\tvalue = " .. tostring(mutation.value) .. "\n"
					code = code .. "\tscope = " .. tostring(mutation.scope) .. "\n"
					code = code .. "\ttracking = " .. tostring(mutation.from_tracking) .. "\n"
				end

				add_code(code)
			end
		end
	end

	if found_parents[1] then
		local min, max = found_parents[1]:GetStartStop()

		if min then
			local temp = helpers.SubPositionToLinePosition(found_parents[1].Code:GetString(), min, max)

			if temp then data = temp end
		end
	end

	local limit = 5000

	for i = 1, #found_parents do
		local min, max = found_parents[i]:GetStartStop()
		add_code(tostring(found_parents[i]) .. " len=" .. tostring(max - min))
	end

	if scope then markdown = markdown .. "\n" .. tostring(scope) end

	if #markdown > limit then markdown = markdown:sub(0, limit) .. "\n```\n..." end

	markdown = markdown:gsub("\\", "BSLASH_")
	return {
		contents = markdown,
		range = {
			start = {
				line = data.line_start - 1,
				character = data.character_start - 1,
			},
			["end"] = {
				line = data.line_stop - 1,
				character = data.character_stop,
			},
		},
	}
end

do
	local MessageType = {error = 1, warning = 2, info = 3, log = 4}

	function lsp.ShowMessage(type, msg)
		lsp.Call(
			{
				method = "window/showMessage",
				params = {
					type = assert(MessageType[type]),
					message = msg,
				},
			}
		)
	end

	function lsp.LogMessage(type, msg)
		lsp.Call(
			{
				method = "window/logMessage",
				params = {
					type = assert(MessageType[type]),
					message = msg,
				},
			}
		)
	end
end

-- this can be overriden
function lsp.Call(params)
	if lsp.methods[params.method] then lsp.methods[params.method](params) end
end

return lsp