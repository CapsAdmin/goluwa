--ANALYZE
local logf = function(f, ...)
	io.write((f):format(...))
end
local wlog = print
local logn = print
local log = io.write

local ok, jit_profiler = pcall(require, "jit.profile")
if not ok then jit_profiler = nil end

local get_time = os.clock

local function read_file(path)
    local f, err = io.open(path)
    if not f then return nil, err end
    local s, err = f:read("*a")
    if not s then return nil, "empty file" end
    return s
end

local function math_round(num, idp)
	if idp and idp > 0 then
		local mult = 10 ^ idp
		return math.floor(num * mult + 0.5) / mult
	end

	return math.floor(num + 0.5)
end


local ok, jit_vmdef = pcall(require, "jit.vmdef")
if not ok then jit_vmdef = nil end

local ok, jit_util = pcall(require, "jit.util")
if not ok then jit_util = nil end

local utility = {}

function utility.TableToColumns(title, tbl, columns, check, sort_key)
	local top = {}

	for k, v in pairs(tbl) do
		if not check or check(v) then table.insert(top, {key = k, val = v}) end
	end

	if type(sort_key) == "function" then
		table.sort(top, function(a, b)
			return sort_key(a.val, b.val)
		end)
	else
		table.sort(top, function(a, b)
			return a.val[sort_key] > b.val[sort_key]
		end)
	end

	local max_lengths = {}
	local temp = {}

	for _, column in ipairs(top) do
		for key, data in ipairs(columns) do
			data.tostring = data.tostring or function(...)
				return ...
			end
			data.friendly = data.friendly or data.key
			max_lengths[data.key] = max_lengths[data.key] or 0
			local str = tostring(data.tostring(column.val[data.key], column.val, top))
			column.str = column.str or {}
			column.str[data.key] = str

			if #str > max_lengths[data.key] then max_lengths[data.key] = #str end

			temp[key] = data
		end
	end

	columns = temp
	local width = 0

	for _, v in pairs(columns) do
		if max_lengths[v.key] > #v.friendly then
			v.length = max_lengths[v.key]
		else
			v.length = #v.friendly + 1
		end

		width = width + #v.friendly + max_lengths[v.key] - 2
	end

	local out = " "
	out = out .. ("_"):rep(width - 1) .. "\n"
	out = out .. "|" .. (
			" "
		):rep(width / 2 - math.floor(#title / 2)) .. title .. (
			" "
		):rep(math.floor(width / 2) - #title + math.floor(#title / 2)) .. "|\n"
	out = out .. "|" .. ("_"):rep(width - 1) .. "|\n"

	for _, v in ipairs(columns) do
		out = out .. "| " .. v.friendly .. ": " .. (
				" "
			):rep(-#v.friendly + max_lengths[v.key] - 1) -- 2 = : + |
	end

	out = out .. "|\n"

	for _, v in ipairs(columns) do
		out = out .. "|" .. ("_"):rep(v.length + 2)
	end

	out = out .. "|\n"

	for _, v in ipairs(top) do
		for _, column in ipairs(columns) do
			out = out .. "| " .. v.str[column.key] .. (
					" "
				):rep(-#v.str[column.key] + column.length + 1)
		end

		out = out .. "|\n"
	end

	out = out .. "|"
	out = out .. ("_"):rep(width - 1) .. "|\n"
	return out
end

local function split(self--[[#: string]], separator--[[#: string]])
	local tbl = {}
	local current_pos--[[#: number]] = 1

	for i = 1, #self do
		local start_pos, end_pos = self:find(separator, current_pos, true)

		if not start_pos or not end_pos then break end

		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	if current_pos > 1 then
		tbl[#tbl + 1] = self:sub(current_pos)
	else
		tbl[1] = self
	end

	return tbl
end

local function trim(self--[[#: string]])
	local char = "%s*"
	local _, start = self:find(char, 0)
	local end_start, end_stop = self:reverse():find(char, 0)

	if start and end_start and end_stop then
		return self:sub(start + 1, (end_start - end_stop) - 2)
	elseif start then
		return self:sub(start + 1)
	elseif end_start and end_stop then
		return self:sub(0, (end_start - end_stop) - 2)
	end

	return self
end

local profiler = {}
profiler.data = {sections = {}, statistical = {}, trace_aborts = {}}
profiler.raw_data = {sections = {}, statistical = {}, trace_aborts = {}}
local blacklist = {
	["leaving loop in root trace"] = true,
	["error thrown or hook fed during recording"] = true,
	["too many spill slots"] = true,
}

local function trace_dump_callback(what, trace_id, func, pc, trace_error_id, trace_error_arg)
	if what == "abort" then
		local info = jit_util.funcinfo(func, pc)
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
		local reason = jit_vmdef.traceerr[trace_error_id]

		if not blacklist[reason] then
			if type(trace_error_arg) == "number" and reason:find("bytecode") then
				trace_error_arg = string.sub(jit_vmdef.bcnames, trace_error_arg * 6 + 1, trace_error_arg * 6 + 6)
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

function profiler.EnableTraceAbortLogging(b--[[#: ]]--[[boolean]] )
	if b then
		jit.attach(
			function(...)
				local ok, err = xpcall(trace_dump_callback, error, ...)

				if not ok then
					logn(err)
					profiler.EnableTraceAbortLogging(false)
				end
			end,
			"trace"
		)
	else
		jit.attach(trace_dump_callback)
	end
end

local function parse_raw_statistical_data()
	local data = profiler.data.statistical

	for _ = 1, #profiler.raw_data.statistical do
		local args = table.remove(profiler.raw_data.statistical)
		local str, samples, vmstate = args[1], args[2], args[3]
		local children = {}

		for line in str:gmatch("(.-)\n") do
			local path, line_number = line:match("(.+):(%d+)")

			if not path and not line_number then
				line = line:gsub("%[builtin#(%d+)%]", function(x)
					return jit_vmdef.ffnames[tonumber(x)]
				end)
				table.insert(children, {name = line or -1, external_function = true})
			else
				table.insert(
					children,
					{path = path, line = tonumber(line_number) or -1, external_function = false}
				)
			end
		end

		local info = children[#children]
		table.remove(children, #children)
		local path = info.path or info.name
		local line = tonumber(info.line) or -1
		data[path] = data[path] or {}
		data[path][line] = data[path][line] or
			{
				total_time = 0,
				samples = 0,
				children = {},
				parents = {},
				ready = false,
				func_name = path,
				vmstate = vmstate,
			}
		data[path][line].samples = data[path][line].samples + samples
		data[path][line].start_time = data[path][line].start_time or get_time()
		local parent = data[path][line]

		for _, info in ipairs(children) do
			local path = info.path or info.name
			local line = tonumber(info.line) or -1
			data[path] = data[path] or {}
			data[path][line] = data[path][line] or
				{
					total_time = 0,
					samples = 0,
					children = {},
					parents = {},
					ready = false,
					func_name = path,
					vmstate = vmstate,
				}
			data[path][line].samples = data[path][line].samples + samples
			data[path][line].start_time = data[path][line].start_time or get_time()
			data[path][line].parents[tostring(parent)] = parent
			parent.children[tostring(data[path][line])] = data[path][line]
		--table.insert(data[path][line].parents, parent)
		--table.insert(parent.children, data[path][line])
		end
	end
end

local function statistical_callback(thread, samples, vmstate)
	local str = jit_profiler.dumpstack(thread, "pl\n", 1000)
	table.insert(profiler.raw_data.statistical, {str, samples, vmstate})
end

function profiler.EnableStatisticalProfiling(b)
	if not jit_profiler then
		wlog("jit profiler is not available")
		return
	end

	profiler.busy = b

	if b then
		jit_profiler.start("li0", function(...)
			local ok, err = pcall(statistical_callback, ...)

			if not ok then
				logn(err)
				profiler.EnableStatisticalProfiling(false)
			end
		end)
	else
		jit_profiler.stop()
	end
end

do
	local started = false

	function profiler.ToggleStatistical()
		if not started then
			profiler.EnableStatisticalProfiling(true)
			started = true
		else
			profiler.EnableStatisticalProfiling(false)
			profiler.PrintStatistical(0)
			started = false
			profiler.Restart()
		end
	end
end

function profiler.EasyStart()
	profiler.EnableStatisticalProfiling(true)
	profiler.EnableTraceAbortLogging(true)
end

function profiler.EasyStop()
	profiler.EnableTraceAbortLogging(false)
	profiler.EnableStatisticalProfiling(false)
	profiler.PrintTraceAborts(500)
	profiler.PrintStatistical(500)
	started = false
	profiler.Restart()
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
		local start_time = get_time()
		table.insert(
			stack,
			{
				section_name = section_name,
				start_time = start_time,
				info = info,
				level = #stack,
			}
		)
	end

	function profiler.PopSection()
		if not enabled then return end

		local res = table.remove(stack)

		if res then
			local time = get_time() - res.start_time
			local path, line = res.info.source, res.info.currentline

			if type(res.section_name) == "string" then line = res.section_name end

			local data = profiler.data.sections
			data[path] = data[path] or {}
			data[path][line] = data[path][line] or
				{
					total_time = 0,
					samples = 0,
					name = res.section_name,
					section_name = res.section_name,
					instrumental = true,
					section = true,
				}
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

		if reset then profiler.data.sections = {} end

		stack = {}
	end

	profiler.PushSection()
	profiler.PopSection()
end

do -- timer
	local stack = {}

	function profiler.StartTimer(str, ...)
		table.insert(stack, {str = str and str:format(...), level = #stack})
		local last = stack[#stack]
		last.time = get_time() -- just to make sure there's overhead with table.insert and whatnot
	end

	function profiler.StopTimer(no_print)
		local time = get_time()
		local data = table.remove(stack)
		local delta = time - data.time

		if not no_print then
			logf("%s%s: %1.22f\n", (" "):rep(data.level - 1), data.str, math_round(delta, 5))
		end

		return delta
	end

	function profiler.ToggleTimer(val)
		if started then
			started = false
			return profiler.StopTimer(val == true)
		else
			started = true
			return profiler.StartTimer(val)
		end
	end
end

function profiler.GetBenchmark(type, file, dump_line)
	local benchmark_time

	if profiler.start_time and profiler.stop_time then
		benchmark_time = profiler.stop_time - profiler.start_time
	end

	if type == "statistical" then parse_raw_statistical_data() end

	local out = {}

	for path, lines in pairs(profiler.data[type]) do
		if path:sub(1, 1) == "@" then path = path:sub(2) end

		if not file or path:find(file) then
			for line, data in pairs(lines) do
				line = tonumber(line) or line
				local name = "unknown(file not found)"
				local debug_info

				if data.func then
					debug_info = debug.getinfo(data.func)
					-- remove some useless fields
					debug_info.source = nil
					debug_info.short_src = nil
					debug_info.currentline = nil
					debug_info.func = nil
				end

				if dump_line then
					local content = read_file(path)

					if content then
						name = split(content, "\n")[line]

						if name then
							name = name:gsub("function ", "")
							name = trim(name)
						end
					end
				elseif data.func then
					name = ("%s(%s)"):format(data.func_name, table.concat(debug.getparams(data.func), ", "))
				else
					local full_path = path
					name = full_path .. ":" .. line
				end

				if data.section_name then
					data.section_name = data.section_name:match(".+lua/(.+)") or data.section_name
				end

				if name:find("\n", 1, true) then
					name = name:gsub("\n", "")
					name = name:sub(0, 50)
				end

				name = trim(name)
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

				if benchmark_time then
					data.fraction_time = data.total_time / benchmark_time
				end

				data.start_time = data.start_time or 0
				data.samples = data.samples or 0
				data.sample_duration = get_time() - data.start_time
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
	logn(
		"trace abort reasons for functions that were sampled by the profiler more than ",
		min_samples,
		" times:"
	)
	local blacklist = {
		["NYI: return to lower frame"] = true,
		["inner loop in root trace"] = true,
		["blacklisted"] = true,
	}

	for path, lines in pairs(profiler.data.trace_aborts) do
		path = path:sub(2)
		local s = profiler.data.statistical

		if s[path] or not next(s) then
			local full_path = path
			local temp = {}

			for line, reasons in pairs(lines) do
				if not next(s) or s[path][line] and s[path][line].samples > min_samples then
					local str = "unknown line"
                        local content, err = read_file(path)

                        if content then
                            local lines = split(content, "\n")
                            str = lines[line]
                            str = "\"" .. trim(str) .. "\""
                        else
                            str = err
                        end

					for reason, count in pairs(reasons) do
						if not blacklist[reason] then
							table.insert(temp, "\t\t" .. trim(reason) .. " (x" .. count .. ")")
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
	log(
		utility.TableToColumns(
			"sections",
			profiler.GetBenchmark("sections"),
			{
				{key = "times_called", friendly = "calls"},
				{
					key = "name",
					tostring = function(val, column)
						return ("    "):rep(column.level - 1) .. tostring(val)
					end,
				},
				{
					key = "average_time",
					friendly = "time",
					tostring = function(val)
						return math_round(val * 100 * 100, 3)
					end,
				},
			},
			function(a)
				return a.times_called > 50
			end,
			"i"
		)
	)
end

function profiler.PrintStatistical(min_samples)
	min_samples = min_samples or 100
	local tr = {
		N = "native",
		I = "interpreted",
		G = "garbage collector",
		J = "JIT compiler",
		C = "C",
	}
	log(
		utility.TableToColumns(
			"statistical",
			profiler.GetBenchmark("statistical"),
			{
				{key = "name"},
				{
					key = "times_called",
					friendly = "percent",
					tostring = function(val, column, columns)
						return math_round((val / columns[#columns].val.times_called) * 100, 2)
					end,
				},
				{
					key = "vmstate",
					tostring = function(str)
						return tr[str]
					end,
				},
                {
					key = "samples",
					tostring = function(val)
						return val
					end,
				},
			},
			function(a)
				return a.name and a.times_called > min_samples
			end,
			function(a, b)
				return a.times_called < b.times_called
			end
		)
	)
end

function profiler.StartInstrumental(file_filter, method)
	method = method or "cr"
	profiler.EnableSectionProfiling(true, true)
	profiler.busy = true
	local last_info

	debug.sethook(
		function(what, line)
			local info = debug.getinfo(2)

			if not file_filter or not info.source:find(file_filter, nil, true) then
				if what == "call" then
					if last_info and last_info.what == "C" then profiler.PopSection() end

					local name

					if info.what == "C" then
						name = info.name

						if not name then name = "" end

						local info = debug.getinfo(3)
						name = name .. " " .. info.source .. ":" .. info.currentline
					end

					profiler.PushSection(name)
				elseif what == "return" then
					profiler.PopSection()
				end
			end

			last_info = info
		end,
		method
	)

	profiler.start_time = get_time()
end

function profiler.StopInstrumental(file_filter, show_everything)
	profiler.EnableSectionProfiling(false)
	profiler.stop_time = get_time()
	profiler.busy = false
	debug.sethook()
	profiler.PopSection()
	log(
		utility.TableToColumns(
			"instrumental",
			profiler.GetBenchmark("sections"),
			{
				{key = "times_called", friendly = "calls"},
				{key = "name"},
				{
					key = "average_time",
					friendly = "time",
					tostring = function(val)
						return ("%f"):format(val)
					end,
				},
				{
					key = "total_time",
					friendly = "total time",
					tostring = function(val)
						return ("%f"):format(val)
					end,
				},
				{
					key = "fraction_time",
					friendly = "percent",
					tostring = function(val)
						return math_round(val * 100, 2)
					end,
				},
			},
			function(a)
				return show_everything or a.average_time > 0.5 or (file_filter or a.times_called > 100)
			end,
			function(a, b)
				return a.total_time < b.total_time
			end
		)
	)
end

do
	local started = false

	function profiler.ToggleInstrumental(file_filter, method)
		if file_filter == "" then file_filter = nil end

		if not started then
			profiler.StartInstrumental(file_filter, method)
			started = true
		else
			profiler.StopInstrumental(file_filter, true)
			started = false
		end
	end
end

function profiler.MeasureInstrumental(time, file_filter, show_everything)
	profiler.StartInstrumental(file_filter)

	event.Delay(time, function()
		profiler.StopInstrumental(file_filter, show_everything)
	end)
end

function profiler.DumpZerobraneProfileTree(min, filter)
	min = min or 1
	local huh = serializer.ReadFile("msgpack", "zerobrane_statistical.msgpack")
	local most_samples
	local path, root

	for k, v in pairs(huh) do
		most_samples = most_samples or v

		if v.samples >= most_samples.samples then
			most_samples = v
			path = k
			root = v
		end
	end

	local level = 0

	local function dump(path, node)
		local percent = math_round((node.samples / root.samples) * 100, 3)

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
	["leaving loop in root trace"] = true,
	["blacklisted"] = true,
	["too many spill slots"] = true,
	["down-recursion, restarting"] = true,
}

function profiler.EnableRealTimeTraceAbortLogging(b)
	if not jit.attach then
		wlog("jit profiler is not available")
		return
	end

	if b then
		local last_log

		jit.attach(
			function(what, trace_id, func, pc, trace_error_id, trace_error_arg)
				if what == "abort" then
					local info = jit_util.funcinfo(func, pc)
					local reason = jit_vmdef.traceerr[trace_error_id]

					if not blacklist[reason] then
						if type(trace_error_arg) == "number" and reason:find("bytecode") then
							trace_error_arg = string.sub(jit_vmdef.bcnames, trace_error_arg * 6 + 1, trace_error_arg * 6 + 6)
							reason = reason:gsub("(%%d)", "%%s")
						end

						reason = reason:format(trace_error_arg)
						local path = info.source
						local line = info.currentline or info.linedefined
						local content = read_file(path:sub(2)) or read_file(path:sub(2))
						local str

						if content then
							str = string.format(
								"%s:%s\n%s:--\t%s\n\n",
								path:sub(2),
								line,
								trim(split(content, "\n")[line]),
								reason
							)
						else
							str = string.format("%s:%s:\n\t%s\n\n", path, line, reason)
						end

						if str ~= last_log then
							log(str)
							last_log = str
						end
					end
				end
			end,
			"trace"
		)
	else
		jit.attach(function() end)
	end
end

local system_GetTime = get_time

function profiler.MeasureFunction(func, count, name, no_print)
	count = count or 1
	name = name or "measure result"
	local total_time = 0

	for _ = 1, count do
		local time = system_GetTime()
		jit.tracebarrier()
		func()
		jit.tracebarrier()
		total_time = total_time + system_GetTime() - time
	end

	if not no_print then
		logf("%s: average: %1.22f total: %f\n", name, total_time / count, total_time)
	end

	return total_time, func
end

function profiler.MeasureFunctions(tbl, count)
	local res = {}

	for name, func in pairs(tbl) do
		table.insert(res, {time = profiler.MeasureFunction(func, count, name, true), name = name})
	end

	table.sort(res, function(a, b)
		return a.time < b.time
	end)

	for i, v in ipairs(res) do
		logf("%s: average: %1.22f total: %f\n", v.name, v.time / count, v.time)
	end
end

function profiler.Compare(old, new, count)
	profiler.MeasureFunction(old, count, "OLD")
	profiler.MeasureFunction(new, count, "NEW")
end

profiler.Restart()
return profiler