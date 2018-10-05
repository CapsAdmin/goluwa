local oh = ... or _G.oh

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

function oh.Test()
--oh.TestAllFiles("/home/caps/goluwa/core")oh.TestAllFiles("/home/caps/goluwa/framework")oh.TestAllFiles("/home/caps/goluwa/engine")oh.TestAllFiles("/home/caps/goluwa/game") do return end
	local path = "foo.lua"
	local code = [[

local t = (typex or type)(val)

function table.tolist()
	(asdf or lol):test();
	aSDSA()
	line = (">"):rep(string.len(currentline)) .. ":"
end


		]]

	local tokenizer = oh.Tokenizer(code, path)
	local tokens = tokenizer:GetTokens()

	local parser = oh.Parser(tokens, code, path)
	local ast = parser:GetAST()
--table.print(ast)
	local output = oh.BuildLuaCode(ast, code, path)
	print(loadstring(output))
	print(output)

	--print(output)

end

commands.Add("tokenize=arg_line", function(str)
	logn(oh.Tokenizer(str):Dump())
end)

commands.Add("oh=arg_line", function(str)
	print(oh.Transpile(str))
end)

function oh.Transpile2(code, path)
	collectgarbage()
	collectgarbage()
	collectgarbage()
	profiler.StartTimer("total")
		profiler.StartTimer("tokenize")
		local tokenizer = oh.Tokenizer(code, path)
		local tokens = tokenizer:GetTokens()
		profiler.StopTimer()

		profiler.StartTimer("parse")
			local parser = oh.Parser(tokens, code, path)
			local ast = parser:GetAST()
		profiler.StopTimer()

		profiler.StartTimer("emit")
			local output = oh.BuildLuaCode(ast, code, path)
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

if RELOAD then
	oh.Test()
end
