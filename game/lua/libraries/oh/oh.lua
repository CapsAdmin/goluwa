local oh = {}

runfile("parser/parser.lua", oh)
runfile("code_emitter.lua", oh)

function oh.Transpile(code)
	local tokens = oh.Tokenize(code, path)
	local body = tokens:ReadBody()
	return oh.DumpAST(body)
end

function oh.loadstring(code, path)
	local code, err = oh.Transpile(code)
	if not code then return nil, err end
	local func, err = loadstring(code, path)

	if not func then
		local line = tonumber(err:match("%b[]:(%d+):"))
		local lines = str:split("\n")
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

commands.Add("tokenize=arg_line", function(str)
	oh.Tokenize(str):Dump()
end)

commands.Add("oh=arg_line", function(str)
	print(oh.Transpile(str))
end)

function oh.Test()
	for _, path in ipairs(vfs.GetFilesRecursive(e.ROOT_FOLDER, {"lua"}, nil, {"%.git"})) do
		local code = assert(vfs.Read(path))
		if code then
			print(path)
			local func, err = oh.loadstring(code, path)
			if not func then
				print(err)
			end
		end
	end
end

oh.Test()

return oh