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

		return self
	end
end

do
	local LuaEmitter = runfile("lua_code_emitter.lua", lua, oh)

	function lua.ASTToCode(ast, config)
		local self = LuaEmitter(config)
		return self:BuildCode(ast)
	end
end

return lua