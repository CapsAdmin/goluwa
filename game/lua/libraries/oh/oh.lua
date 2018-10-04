local oh = {}

oh.USE_FFI = false

RELOAD = nil

runfile("parser/tokenizer.lua", oh)
runfile("parser/parser.lua", oh)
runfile("lua_code_emitter.lua", oh)
runfile("validate.lua", oh)

function oh.Transpile(code, path)
	local tokenizer = oh.Tokenizer(code, path)
	local parser = oh.Parser(tokenizer:GetTokens(), code, path)
	local ast = parser:GetAST()
	local output = oh.BuildLuaCode(ast, code)
	return output
end

function oh.loadstring(code, path)
	local ok, code = system.pcall(oh.Transpile, code, path)
	if not ok then return nil, code end
	local func, err = loadstring(code, path)

	if not func then
		local line = tonumber(err:match("%b[]:(%d+):"))
		local lines = code:split("\n")
		for i = -1, 1 do
			if lines[line + i] then
				err = err .. "\t" .. lines[line + i]
				if i == 0 then
					err = err .. " --<<< "
				end
				err = err .. "\n"
			end
		end

		return nil, err
	end

	return func
end

commands.Add("luaformat=arg_line", function(str)
	local paths = utility.CLIPathInputToTable(str, {"lua"})

	for i, path in ipairs(paths) do
		print(path)
		if path == "stdin" or path == "-" then

		else
			local code, err = vfs.Read(path)
			if code then
				local newcode = oh.Transpile(code, path)
				local ok, err = loadstring(newcode)
				if ok then
					vfs.Write(path .. "2", newcode)
				end
			end

			if err then
				logn(path, ": ", err or "empty file?")
			end
		end
	end
end)

_G.oh = oh

return oh