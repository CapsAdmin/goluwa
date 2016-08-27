local profiler = _G.profiler or {}

profiler.data = profiler.data or {sections = {}, statistical = {}, trace_aborts = {}}
profiler.raw_data = profiler.raw_data or {sections = {}, statistical = {}, trace_aborts = {}}

local blacklist = {
	["leaving loop in root trace"] = true,
	["error thrown or hook called during recording"] = true,
}

local function trace_dump_callback(what, trace_id, func, pc, trace_error_id, trace_error_arg)
	if what == "abort" then
		local info = jit.util.funcinfo(func, pc)
		table.insert(profiler.raw_data.trace_aborts, {info, trace_error_id, trace_error_arg})
	end
end

local function parse_raw_trace_abort_data()
	local data = profiler.data.trace_aborts

	for _ = 1, #profiler.raw_data.trace_aborts do
		local args = table.remove(profiler.raw_data.trace_aborts)

		local info = args[1]
		local trace_error_id = args[2]
		local trace_error_arg = args[3]

		local reason = jit.vmdef.traceerr[trace_error_id]

		if not blacklist[reason] then
			if type(trace_error_arg) == "number" and reason:find("bytecode") then
				trace_error_arg = string.sub(jit.vmdef.bcnames, trace_error_arg*6+1, trace_error_arg*6+6)
				reason = reason:gsub("(%%d)", "%%s")
			end

			reason = reason:format(trace_error_arg)

			local path = info.source
			local line = info.currentline or info.linedefined

			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {}
			data[path][line][reason] = (data[path][line][reason] or 0) + 1
		end
	end
end

function profiler.EnableTraceAbortLogging(b)
	if b then
		jit.attach(function(...)
			local ok, err = xpcall(type(b) == "function" and b or trace_dump_callback, system.OnError, ...)
			if not ok then
				logn(err)
				profiler.EnableTraceAbortLogging(false)
			end
		end, "trace")
	else
		jit.attach(trace_dump_callback)
	end
end

local function statistical_callback(thread, samples, vmstate)
	local str = jit.profiler.dumpstack(thread, "pl\n", 10)
	table.insert(profiler.raw_data.statistical, {str, samples})
end

local function parse_raw_statistical_data()
	local data = profiler.data.statistical

	for _ = 1, #profiler.raw_data.statistical do
		local args = table.remove(profiler.raw_data.statistical)
		local str, samples = args[1], args[2]
		local children = {}

		for line in str:gmatch("(.-)\n") do
			local path, line_number = line:match("(.+):(%d+)")

			if not path and not line_number then
		line = line:gsub("%[builtin#(%d+)%]", function(x)
			return jit.vmdef.ffnames[tonumber(x)]
		end)

				table.insert(children, {name = line or -1, external_function = true})
			else
				table.insert(children, {path = path, line = tonumber(line_number) or -1, external_function = false})
			end
		end

		local info = children[#children]
		table.remove(children, #children)

		local path = info.path or info.name
		local line = tonumber(info.line) or -1

		data[path] = data[path] or {}
		data[path][line] = data[path][line] or {total_time = 0, samples = 0, children = {}, parents = {}, ready = false, func_name = path}

		data[path][line].samples = data[path][line].samples + samples
		data[path][line].start_time = data[path][line].start_time or system.GetTime()

		local parent = data[path][line]

		for _, info in ipairs(children) do
			local path = info.path or info.name
			local line = tonumber(info.line) or -1

			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {total_time = 0, samples = 0, children = {}, parents = {}, ready = false, func_name = path}

			data[path][line].samples = data[path][line].samples + samples
			data[path][line].start_time = data[path][line].start_time or system.GetTime()

			data[path][line].parents[tostring(parent)] = parent
			parent.children[tostring(data[path][line])] = data[path][line]

			--table.insert(data[path][line].parents, parent)
			--table.insert(parent.children, data[path][line])
	end
	end
end

function profiler.EnableStatisticalProfiling(b)
	profiler.busy = b
	if b then
		jit.profiler.start("l", function(...)
			local ok, err = xpcall(type(b) == "function" and b or statistical_callback, system.OnError, ...)
			if not ok then
				logn(err)
				profiler.EnableStatisticalProfiling(false)
			end
		end)
	else
		jit.profiler.stop()
	end
end

function profiler.Restart()
	profiler.data = {sections = {}, statistical = {}, trace_aborts = {}}
	profiler.raw_data = {sections = {}, statistical = {}, trace_aborts = {}}
end

do
	local stack = {}
	local enabled = false
	local i = 0

	function profiler.PushSection(section_name)
		if not enabled then return end

		local info = debug.getinfo(3)
		local start_time = system.GetTime()

		table.insert(stack, {
			section_name = section_name,
			start_time = start_time,
			info = info,
			level = #stack,
		})
	end

	function profiler.PopSection()
		if not enabled then return end

		local res = table.remove(stack)

		if res then
			local time = system.GetTime() - res.start_time
			local path, line = res.info.source, res.info.currentline
			if type(res.section_name) == "string" then line = res.section_name end

			local data = profiler.data.sections

			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {total_time = 0, samples = 0, name = res.section_name, section_name = res.section_name, instrumental = true, section = true}

			data[path][line].total_time = data[path][line].total_time + time
			data[path][line].samples = data[path][line].samples + 1
			data[path][line].level = res.level
			data[path][line].start_time = res.start_time
			data[path][line].i = i

			i = i + 1

			return time
		end
	end

	function profiler.RemoveSection(name)
		profiler.data.sections[name] = nil
	end

	function profiler.EnableSectionProfiling(b, reset)
		enabled = b
		if reset then table.clear(profiler.data.sections) end
		table.clear(stack)
	end

	profiler.PushSection()
	profiler.PopSection()
end

do -- timer
	local stack = {}

	function profiler.StartTimer(str, ...)
		table.insert(stack, {str = str and str:format(...), level = #stack})
		local last = stack[#stack]
		last.time = system.GetTime() -- just to make sure there's overhead with table.insert and whatnot
	end

	function profiler.StopTimer(no_print)
		local time = system.GetTime()
		local data = table.remove(stack)
		local delta = time - data.time

		if not no_print then
			logf("%s%s: %s\n", (" "):rep(data.level-1), data.str, math.round(delta, 3))
		end

		return delta
	end
end

function profiler.GetBenchmark(type, file, dump_line)

	if type == "statistical" then
	 	parse_raw_statistical_data()
	end

	local out = {}

	for path, lines in pairs(profiler.data[type]) do
		path = path:sub(2)
		if not file or path:find(file) then
			for line, data in pairs(lines) do
				line = tonumber(line) or line

				local name = "unknown(file not found)"

				if data.func then
					debug_info = debug.getinfo(data.func)

					-- remove some useless fields
					debug_info.source = nil
					debug_info.short_src = nil
					debug_info.currentline = nil
					debug_info.func = nil
				end

				if dump_line then
					local content = vfs.Read(path)

					if content then
						name = content:split("\n")[line]
						if name then
							name = name:gsub("function ", "")
							name = name:trim()
						end
					end
				elseif data.func then
					name = ("%s(%s)"):format(data.func_name, table.concat(debug.getparams(data.func), ", "))
				else
					local full_path = R(path) or path
					name = full_path .. ":" .. line
				end

				if data.section_name then
					data.section_name = data.section_name:match(".+lua/(.+)") or data.section_name
				end

				name = name:trim()
				data.path = path
				data.file_name = path:match(".+/(.+)%.") or path
				data.line = line
				data.name = name
				data.debug_info = debug_info
				data.ready = true

				if data.total_time then
					data.average_time = data.total_time / data.samples
					--data.total_time = data.average_time * data.samples
				end

				data.start_time = data.start_time or 0
				data.samples = data.samples or 0

				data.sample_duration = system.GetTime() - data.start_time
				data.times_called = data.samples

				table.insert(out, data)
			end
		end
	end

	return out
end


function profiler.PrintTraceAborts(min_samples)
	min_samples = min_samples or 500

	parse_raw_statistical_data()
	parse_raw_trace_abort_data()

	logn("trace abort reasons for functions that were sampled by the profiler more than ", min_samples, " times:")

	local blacklist = {
		["NYI: return to lower frame"] = true,
		["inner loop in root trace"] = true,
		["blacklisted"] = true,
	}

	for path, lines in pairs(profiler.data.trace_aborts) do
		path = path:sub(2)

		local s = profiler.data.statistical

		if s[path] or not next(s) then
			local full_path = R(path) or path
			full_path = full_path:replace("../../../", e.SRC_FOLDER)
			full_path = full_path:lower():replace(e.ROOT_FOLDER:lower(), "")

			local temp = {}

			for line, reasons in pairs(lines) do
				if not next(s) or s[path][line] and s[path][line].samples > min_samples then
					local str = "unknown line"

					local content, err = vfs.Read(e.ROOT_FOLDER .. path)

					if content then
						local lines = content:split("\n")
						str = lines[line]
						str = "\"" .. str:trim() .. "\""
					else
						str = err
					end

					for reason, count in pairs(reasons) do
						if not blacklist[reason] then
							table.insert(temp, "\t\t" .. reason:trim() .. " (x" .. count .. ")")
							table.insert(temp, "\t\t\t" .. line .. ": " .. str)
						end
					end
				end
			end

			if #temp > 0 then
				logn("\t", full_path)
				logn(table.concat(temp, "\n"))
			end
		end
	end
end

function profiler.PrintSections()
	log(utility.TableToColumns(
		"sections",
		profiler.GetBenchmark("sections"),
		{
			{key = "times_called", friendly = "calls"},
			{key = "name", tostring = function(val, column) return ("    "):rep(column.level - 1) .. tostring(val) end},
			{key = "average_time", friendly = "time", tostring = function(val) return math.round(val * 100 * 100, 3) end},
		},
		function(a) return a.times_called > 50 end,
		"i"
	))
end

function profiler.PrintStatistical()
	log(utility.TableToColumns(
		"statistical",
		profiler.GetBenchmark("statistical"),
		{
			{key = "name"},
			{key = "times_called", friendly = "percent", tostring = function(val, column, columns)  return math.round((val / columns[#columns].val.times_called) * 100, 2) end},
		},
		function(a) return a.name and a.times_called > 100 end,
		function(a, b) return a.times_called < b.times_called end
	))
end

function profiler.StartInstrumental(file_filter, method)
	method = method or "cr"
	profiler.EnableSectionProfiling(true, true)
	profiler.busy = true
	debug.sethook(function(what)
		local info = debug.getinfo(2)
		if info.what == "Lua" then
			if info.source:endswith("profiler.lua") then return end

			if not file_filter or not info.source:find(file_filter, nil, true) then
				if what == "call" then
					profiler.PushSection()
				elseif what == "return" then
					profiler.PopSection()
				end
			end
		end
	end, method)
end

function profiler.StopInstrumental(file_filter)
	profiler.busy = false
	debug.sethook()
	profiler.PopSection()

	log(utility.TableToColumns(
		"instrumental",
		profiler.GetBenchmark("sections"),
		{
			{key = "times_called", friendly = "calls"},
			{key = "section_name"},
			{key = "average_time", friendly = "time", tostring = function(val) return math.round(val * 100 * 100, 3) end},
			{key = "total_time", friendly = "total time", tostring = function(val) return math.round(val * 100 * 100, 3) end},
		},
		function(a) return a.average_time > 0.5 or (file_filter or a.times_called > 100) end,
		function(a, b) return a.total_time < b.total_time end
	))

	profiler.EnableSectionProfiling(false, true)
end

function profiler.MeasureInstrumental(time, file_filter)
	profiler.StartInstrumental(file_filter)

	event.Delay(time, function()
		profiler.StopInstrumental(file_filter)
	end)
end

function profiler.DumpZerobraneProfileTree(min, filter)
	min = min or 1
	local huh = serializer.ReadFile("msgpack", "zerobrane_statistical.msgpack")
	local most_samples
	local path, root
	for k,v in pairs(huh) do
		most_samples = most_samples or v
		if v.samples >= most_samples.samples then
			most_samples = v
			path = k
			root = v
		end
	end

	local level = 0

	local function dump(path, node)
		local percent = math.round((node.samples / root.samples) * 100, 3)
		if percent > min then
			if not filter or path:find(filter) then
				logf("%s%s (%s) %s\n", ("\t"):rep(level), percent, node.samples, path)
			else
				logf("%s%s\n", ("\t"):rep(level), "...")
			end

			for path, child in pairs(node.children) do
				level = level + 1
				dump(path, child)
				level = level - 1
			end
		end
	end

	dump(path, root)
end

function profiler.IsBusy()
	return profiler.busy
end

local blacklist = {
	["NYI: return to lower frame"] = true,
	["inner loop in root trace"] = true,
	["blacklisted"] = true,
}

function profiler.EnableRealTimeTraceAbortLogging(b)
	if b then
		jit.attach(function(what, trace_id, func, pc, trace_error_id, trace_error_arg)
			if what == "abort" then
				local info = jit.util.funcinfo(func, pc)
				local reason = jit.vmdef.traceerr[trace_error_id]

				if not blacklist[reason] then
					if type(trace_error_arg) == "number" and reason:find("bytecode") then
						trace_error_arg = string.sub(jit.vmdef.bcnames, trace_error_arg*6+1, trace_error_arg*6+6)
						reason = reason:gsub("(%%d)", "%%s")
					end

					reason = reason:format(trace_error_arg)

					local path = info.source
					local line = info.currentline or info.linedefined
					local content = vfs.Read(e.ROOT_FOLDER .. path:sub(2))

					if content then
						logf("%s:%s\n%s:--\t%s\n\n", path, line, content:split("\n")[line]:trim(), reason)
					else
						logf("%s:%s:\n\t%s\n\n", path, line, reason)
					end
				end
			end
		end, "trace")
	else
		jit.attach(nil)
	end
end

function profiler.MeasureFunction(func, count, name)
	count = count or 1
	name = name or "measure result"

	local time = 0

	for _ = 1, count do
		profiler.StartTimer()
			func()
		time = time + profiler.StopTimer(true)
	end

	logf("%s: average: %f total: %f\n", name, time / count, time)
end

function profiler.Compare(old, new, count)
	profiler.MeasureFunction(old, count, "OLD")
	profiler.MeasureFunction(new, count, "NEW")
end

profiler.Restart()

commands.Add("profile_start", function(line)
	if line == "" or line == "st" or line == "s" then
		profiler.EnableStatisticalProfiling(true)
	end

	if line == "" or line == "se" then
		profiler.EnableSectionProfiling(true)
	end

	if line == "" or line == "ab" or line == "a" then
		profiler.EnableTraceAbortLogging(true)
	end
end)

commands.Add("profile_stop", function()
	if line == "" or line == "st" or line == "s" then
		profiler.EnableStatisticalProfiling(false)
	end

	if line == "" or line == "se" then
		profiler.EnableSectionProfiling(false)
	end

	if line == "" or line == "ab" or line == "a" then
		profiler.EnableTraceAbortLogging(false)
	end
end)

commands.Add("profile_restart", function()
	profiler.Restart()
end)

commands.Add("profile_dump", function(line, a, b, c)
	if a == "" or a == "st" or a == "s" then
		profiler.PrintStatistical(b, tonumber(c))
	end

	if a == "" or a == "se" then
		profiler.PrintSections()
	end

	if a == "" or a == "ab" or a == "a" then
		profiler.PrintTraceAborts()
	end
end)

commands.Add("profile", function(line, time, file_filter, method)
	profiler.MeasureInstrumental(tonumber(time) or 5, file_filter, method)
end)

commands.Add("zbprofile", function()
	local prf = require("zbprofiler")
	prf.start()
	event.Timer("zbprofiler_save", 3, 0, function() prf.save(0) end)
end)

commands.Add("trace_abort", function()
	jit.flush()
	profiler.EnableRealTimeTraceAbortLogging(true)
end)

return profiler
