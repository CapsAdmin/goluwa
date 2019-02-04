local oh = ... or _G.oh

local lua = {}
lua.syntax = oh.SetupSyntax(runfile("syntax.lua", oh))

do
	local Tokenizer = runfile("tokenizer.lua", lua, oh)

	function lua.Tokenizer(code)
		local errors = {}

		local self = Tokenizer(code, function(_, msg, start, stop)
			table.insert(errors, {msg = msg, start = start, stop = stop})
		end)

		self.errors = errors

		self:ResetState()

		return self
	end
end

do
	local Parser = runfile("parser.lua", lua, oh)

	function lua.Parser(tokens)
		local errors = {}

		local self = Parser(function(_, msg, start, stop)
			table.insert(errors, {msg = msg, start = start, stop = stop})
		end)

		self.errors = errors

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

function lua.loadstring(code, name)
	name = name or "unkknown"

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

	code = lua.ASTToCode(ast)
print(code)
	return loadstring(code, name)
end

function lua.runfile(path, ...)
	return assert(oh.lua.loadstring(vfs.Read(path), "@" .. R(path)))(...)
end

return lua