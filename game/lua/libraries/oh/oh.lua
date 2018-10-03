local oh = {}

oh.USE_FFI = false

RELOAD = nil

runfile("parser/parser.lua", oh)
runfile("lua_code_emitter.lua", oh)
runfile("validate.lua", oh)

function oh.Transpile(code, path)
	local tokenizer = oh.Tokenizer(code, path)
	local parser = oh.Parser(tokenizer:Tokenize(), code, path)
	local body = parser:Block()
	local output = oh.BuildLuaCode(body, code)
	return output
end

function oh.Transpile2(code, path)
	collectgarbage()
	collectgarbage()
	collectgarbage()
	profiler.StartTimer("total")
		profiler.StartTimer("tokenize")
			local tokens = oh.Tokenize(code, path)
		profiler.StopTimer()

		profiler.StartTimer("parse")
			local body = tokens:Block()
		profiler.StopTimer()

		profiler.StartTimer("emit")
			local output = oh.BuildLuaCode(body)
		profiler.StopTimer()
	profiler.StopTimer()
	collectgarbage()
	collectgarbage()
	collectgarbage()

	profiler.StartTimer("loadstring")
		print(loadstring(output))
	profiler.StopTimer()

	return output
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

function oh.TestAllFiles(path_override)
	print("testing all files in " .. path_override)

	local paths = io.popen("find " .. (path_override or e.ROOT_FOLDER) .. " -name \"*.lua\""):read("*all")
	oh.failed_tests = oh.failed_tests or {}
	local use_failed_tests = oh.failed_tests[1]

	local statistics = {passed = 0, failed = 0, skipped = 0}

	local total_time = 0

	for _, path in ipairs(use_failed_tests and oh.failed_tests or paths:split("\n")) do
		local code, err = vfs.Read(path)
		if err then error(err) end

		if code and not code:find("e2function", nil, true) and not path:find("data/users/", nil, true) then
			if path:find("lua-5.4.0", nil, true) or path:find("lua-5.3.0", nil, true) then
				code = code:gsub("//", "/")
			end

			if path:find("love_games", nil, true) then
				code = code:gsub("continue", "CONTINUE")
			end

			local name = path:sub(#e.ROOT_FOLDER + 1)

			--profiler.EnableStatisticalProfiling(true)
			local time = system.GetTime()
			local func, err = oh.loadstring(code, name)
			total_time = total_time + system.GetTime() - time
			--profiler.EnableStatisticalProfiling(false)

			if func then
				statistics.passed = statistics.passed + 1
				--logn("PASS - ", name)
				if _%150 == 0 then
					logn("parsing files..")
				end
				if use_failed_tests then
					table.removevalue(oh.failed_tests, path)
				end
			else
				local ok, err2 = loadstring(code, "@")
				if not ok then
					statistics.skipped = statistics.skipped + 1
					logn("SKIP - ", name, err2)
					logn(err)
				else
					statistics.failed = statistics.failed + 1
					logn("FAIL - ", name, err)
					if not use_failed_tests then
						table.insert(oh.failed_tests, path)
					end
				end
			end
		end
	end
	--profiler.PrintStatistical(0)

	logn("spent ", total_time, " seconds in oh.loadstring")

	logn(statistics.passed, " files were successfully parsed")
	logn(statistics.skipped, " files were were skipped as loadstring didn't work")
	logn(statistics.failed, " failed to parse")
end

function oh.Test() do return end
	oh.TestAllFiles("/home/caps/goluwa/core")
	oh.TestAllFiles("/home/caps/goluwa/framework")
	oh.TestAllFiles("/home/caps/goluwa/engine")
	oh.TestAllFiles("/home/caps/goluwa/game")

	do return end

	local code = vfs.Read"/home/caps/goluwa/lua-5.4.0-w2-tests/code.lua"


	local tokens = oh.Tokenize(code, path)
	local body = tokens:Block()
	oh.ValidateTree(body, code)
	local newcode = oh.BuildLuaCode(body, code)
	--print(code)

	print(newcode)
	print(newcode:count("\n"), code:count("\n"))
	print(loadstring(newcode))

	--utility.MeldDiff(code, newcode)
	--local code = oh.Transpile(vfs.Read"main.lua")
	--print(loadstring(code))
end

commands.Add("tokenize=arg_line", function(str)
	oh.Tokenize(str):Dump()
end)

commands.Add("oh=arg_line", function(str)
	print(oh.Transpile(str))
end)

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

oh.Test()

return oh