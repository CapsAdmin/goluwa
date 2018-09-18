local oh = {}

runfile("parser/parser.lua", oh)
runfile("code_emitter.lua", oh)

function oh.Transpile(code, path)
	local tokens = oh.Tokenize(code, path)
	local body = tokens:Block()
	local output = oh.DumpAST(body)
	return output
end

function oh.Transpile2(code, path)
	collectgarbage()
	profiler.StartTimer("total")
		profiler.StartTimer("tokenize")
			local tokens = oh.Tokenize(code, path)
		profiler.StopTimer()

		profiler.StartTimer("parse")
			local body = tokens:Block()
		profiler.StopTimer()

		profiler.StartTimer("emit")
			local output = oh.DumpAST(body)
		profiler.StopTimer()
	profiler.StopTimer()
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

commands.Add("tokenize=arg_line", function(str)
	oh.Tokenize(str):Dump()
end)

commands.Add("oh=arg_line", function(str)
	print(oh.Transpile(str))
end)

function oh.TestAllFiles()
	local paths = io.popen("find " .. e.ROOT_FOLDER .. " -name \"*.lua\""):read("*all")
	oh.failed_tests = oh.failed_tests or {}
	local use_failed_tests = oh.failed_tests[1]

	local statistics = {passed = 0, failed = 0, skipped = 0}

	local total_time = 0

	for _, path in ipairs(use_failed_tests and oh.failed_tests or paths:split("\n")) do
		local code, err = vfs.Read(path)
		if err then error(err) end

		if code then
			if path:find("lua-5.4.0", nil, true) then
				code = code:gsub("//", "/")
			end

			if path:find("love_games", nil, true) then
				code = code:gsub("continue", "CONTINUE")
			end

			local name = path:sub(#e.ROOT_FOLDER + 1)

			profiler.EnableStatisticalProfiling(true)
			local time = system.GetTime()
			local func, err = oh.loadstring(code, name)
			total_time = total_time + time - system.GetTime()
			profiler.EnableStatisticalProfiling(false)

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
					logn("SKIP - ", name, " ", err2)
				else
					statistics.failed = statistics.failed + 1
					logn("FAIL - ", name, " ", err)
					if not use_failed_tests then
						table.insert(oh.failed_tests, path)
					end
				end
			end
		end
	end
	profiler.PrintStatistical(0)

	logn("spent ", total_time, " seconds in oh.loadstring")

	logn(statistics.passed, " files were successfully parsed")
	logn(statistics.skipped, " files were were skipped as loadstring didn't work")
	logn(statistics.failed, " failed to parse")
end

_G.oh = oh

_G.oh.TestAllFiles()

return oh