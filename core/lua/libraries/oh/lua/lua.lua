local oh = ... or _G.oh

local lua = {}
lua.syntax = oh.SetupSyntax(runfile("syntax.lua", oh))

do
	local Tokenizer = runfile("tokenizer.lua", lua, oh)

	local function on_error(self, msg, start, stop)
		table.insert(self.errors, {msg = msg, start = start, stop = stop})
	end

	function lua.Tokenizer(code)
		local self = Tokenizer(code)
		self.errors = {}

		self:ResetState()

		return self
	end
end

do
	local function on_error(self, msg, start, stop)
		table.insert(self.errors, {msg = msg, start = start, stop = stop})
	end
	local Parser = runfile("parser.lua", lua, oh)

	function lua.Parser(tokens)
		local self = Parser()
		self.errors = {}

		if tokens then
			return self:BuildAST(tokens)
		end

		return self
	end

end

do
	local LuaEmitter = runfile("lua_code_emitter.lua", lua, oh)

	function lua.ASTToCode(ast, config)
		config = config or {}

		if config.preserve_whitespace == nil then
			config.preserve_whitespace = true
		end

		local self = LuaEmitter(config)
		return self:BuildCode(ast)
	end
end

do
	local JSEmitter = runfile("js_code_emitter.lua", lua, oh)

	function lua.ASTToJSCode(ast, config)
		config = config or {}

		if config.preserve_whitespace == nil then
			config.preserve_whitespace = true
		end

		local self = JSEmitter(config)
		return self:BuildCode(ast)
	end
end

function lua.CodeToAST(code, name, start, stop)
	name = name or "unknown"

	local tokenizer = lua.Tokenizer(code)
	local tokens = tokenizer:GetTokens()

	if tokenizer.errors[1] then
		local str = ""
		for _, err in ipairs(tokenizer.errors) do
			str = str .. oh.FormatError(code, name, err.msg, err.start, err.stop) .. "\n"
		end
		return nil, str
	end

	local parser = lua.Parser()
	local ast = parser:BuildAST(tokens)
	if parser.errors[1] then
		local str = ""
		for _, err in ipairs(parser.errors) do
			str = str .. oh.FormatError(code, name, err.msg, err.start, err.stop) .. "\n"
		end
		return nil, str
	end

	return ast, tokens
end

function lua.loadstring(code, name)
	local ast, err = lua.ASTToCode(ast)

	if not ast then return err end

	code = lua.ASTToCode(ast)

	return loadstring(code, name)
end

function lua.runfile(path, ...)
	return assert(oh.lua.loadstring(vfs.Read(path), "@" .. R(path)))(...)
end

if RELOAD then
	if oh then
		oh.lua = lua
	end
end

return lua