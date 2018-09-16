local oh = {}

runfile("parser/parser.lua", oh)
runfile("code_emitter.lua", oh)

function oh.Transpile(code, path)
	local tokens = oh.Tokenize(code, path)
	local body = tokens:ReadBody()
	return oh.DumpAST(body)
end

function oh.loadstring(code, path)
	local ok, code = pcall(oh.Transpile, code, path)
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

commands.Add("tokenize=arg_line", function(str)
	oh.Tokenize(str):Dump()
end)

commands.Add("oh=arg_line", function(str)
	print(oh.Transpile(str))
end)

function oh.Test()
	local code = [=====[
			lol = "a\"b" .. wow
	]=====]

	code = vfs.Read("/home/caps/goluwa/data/linux_x64/main.lua")
	if #code > 100000 or code:trim() ~= "" then
		local func, err = oh.loadstring(code, path)
		if not func then
			print(func)
			print(err)
		end
		print(func)
		return
	end

	vfs.GetFilesRecursive("/home/caps/goluwa/__gmod_addons/addons/", {"lua"}, function(path)
		local code, err = vfs.Read(path)
		if not code and err then error(err) end
		if code then
			local func, err = oh.loadstring(code, path:gsub("os:", ""):gsub(e.ROOT_FOLDER, ""))
			if not func then
				print(err)
			end
		end
	end, {"%.git", "gmod_wire_expression2"})
end

_G.oh = oh

oh.Test()

return oh