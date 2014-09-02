local profiler = _G.profiler or {}

profiler.data = profiler.data or {}

profiler.type = "statistical"
profiler.enabled = true

local jit_profiler = require("jit.profile")
local jit_vmdef = require("jit.vmdef")
local jit_util = require("jit.util")

local function fix_path(path) 
	return path:gsub("\\", "/"):gsub("(/+)", "/"):gsub("^%s*(.-)%s*$", "%1" )
end

local active = false
local data = profiler.data

do -- trace abort dump
	local function trace_dump_callback(what, trace_id, func, pc, trace_error_id, trace_error_arg)
		if what == "abort" then
			local info = jit_util.funcinfo(func, pc)
			local reason = jit_vmdef.traceerr[trace_error_id]:format(trace_error_arg)
			
			data[info.source] = files[info.source] or {}
			data[info.source][info.linedefined] = files[info.source][info.linedefined] or {}
			data[info.source][info.linedefined].trace_abort_reasons = data[info.source][info.linedefined].trace_abort_reasons or {}
			data[info.source][info.linedefined].trace_abort_reasons[reason] = (files[info.source][info.linedefined][reason] or 0) + 1
		end
	end
	
	function profiler.StartTraceAbortDump()		
		jit.attach(trace_dump_callback, "trace")
	end
	
	function profiler.StopTraceAbortDump()
		jit.attach(trace_dump_callback)
	end
end

do
	local function statistical_callback(thread, samples, vmstate, ...)
		if not active or not profiler.enabled then
			profiler.Stop()
		return end
						
		local str = jit_profiler.dumpstack(thread, "pl\n", 10)

		local children = {}
		
		for line in str:gmatch("(.-)\n") do
			local path, line_number = line:match("(.+):(%d+)")
			
			if not path and not line_number then
				line = line:gsub("%[builtin#(%d+)%]", function(x)
				  return jit_vmdef.ffnames[tonumber(x)]
				end)
								
				table.insert(children, {name = line, external_function = true})
			else
				table.insert(children, {path = path, line = tonumber(line_number), external_function = false})
			end
		end
		
		local info = children[#children]
		table.remove(children, #children)
		
		local path = info.path or info.name
		local line = tonumber(info.line) or -1
		
		data[path] = data[path] or {}
		data[path][line] = data[path][line] or {total_time = 0, samples = 0, children = {}, parents = {}, statistical = true, ready = false, func_name = path}
		
		data[path][line].samples = data[path][line].samples + samples
		data[path][line].start_time = data[path][line].start_time or timer.GetSystemTime()	
		
		local parent = data[path][line]
				
		for _, info in ipairs(children) do
			local path = info.path or info.name
			local line = tonumber(info.line) or -1
				
			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {total_time = 0, samples = 0, children = {}, parents = {}, statistical = true, ready = false, func_name = path}
			
			data[path][line].samples = data[path][line].samples + samples
			data[path][line].start_time = data[path][line].start_time or timer.GetSystemTime()	
			
			data[path][line].parents[tostring(parent)] = parent
			parent.children[tostring(data[path][line])] = data[path][line]
			
			--table.insert(data[path][line].parents, parent)
			--table.insert(parent.children, data[path][line])
		end
	end
	
	local function instrumental_callback(type)
		if not active or not profiler.enabled then
			profiler.Stop()
		return end
	
		local info = debug.getinfo(2)
		
		if info.linedefined <= 0 then return end
		
		local path = info.source
		local line = info.linedefined
				
		data = data or {}
		data[path] = data[path] or {}
		data[path][line] = data[path][line] or {total_time = 0, samples = 0, total_garbage = 0, func = info.func, func_name = info.name, instrumental = true}
		
		data[path][line].samples = data[path][line].samples + 1
		data[path][line].start_time = data[path][line].start_time or timer.GetSystemTime()
		
		if type == "call" then
			data[path][line].call_time = timer.GetSystemTime()
			data[path][line].call_garbage = collectgarbage("count")
		elseif type == "return" and data[path][line].call_time then
			data[path][line].total_time = data[path][line].total_time + (timer.GetSystemTime() - data[path][line].call_time)
			data[path][line].total_garbage = data[path][line].total_garbage + (collectgarbage("count") - data[path][line].call_garbage)
		end
	end

	function profiler.Start(type)
		type = type or profiler.type
		
		if not profiler.enabled then return end
						
		if type == "statistical" then
			jit_profiler.start("l", function(...) 
				local ok, err = xpcall(statistical_callback, system.OnError, ...)
				if not ok then
					logn(err)
					profiler.Stop()
				end
			end)
		else
			debug.sethook(instrumental_callback, "cr")
		end
		
		active = true
	end
end

function profiler.Stop(type)
	type = type or profiler.type
	
	if not profiler.enabled then return end
	
	if type == "statistical" then
		jit_profiler.stop()
	else
		debug.sethook()
	end
	
	active = false
end

function profiler.Restart()
	profiler.data = {}
	data = profiler.data
end

function profiler.Running() 
	return active
end

function profiler.GetBenchmark(type, dump_line)
	type = type or profiler.type
	
	local out = {}

	for path, lines in pairs(data) do
		for line, data in pairs(lines) do
			
			line =  tonumber(line)
			
			local path = fix_path(path:gsub("%[.-%]", ""):gsub("@", "")) or path
			local name
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
				local content = vfs.Read(path)
				
				if content then
					name = content:explode("\n")[line]
					if name then
						name = name:gsub("function ", "")
						name = name:trim()			
					end
				end
			elseif data.func then		
				name = ("%s(%s)"):format(data.func_name, table.concat(debug.getparams(data.func), ", "))
			elseif data.path and data.line then
				local full_path = R(data.path) or data.path
				full_path = full_path:replace("../../../", e.BASE_FOLDER)
				full_path = full_path:lower():replace(e.ROOT_FOLDER:lower(), "")
				name = full_path .. ":" .. data.line
			else
				name = data.name or "unknown(file not found)"
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
				data.total_time = data.total_time
			end
			
			if data.total_garbage and data.total_garbage > 0 then
				data.average_garbage = math.floor(data.total_garbage / data.samples)
				data.total_garbage = data.total_garbage
			end
											
			data.sample_duration = timer.GetSystemTime() - data.start_time
			data.times_called = data.samples
			
			table.insert(out, data)
		end
	end
	
	return out
end

function profiler.PrintBenchmark(benchmark, type)
	type = type or profiler.type

	local top = {}
	
	if type == "instrumental" then				
		for k,v in pairs(benchmark) do
			if v.times_called > 50 then
				table.insert(top, v)
			end
		end
		
		table.sort(top, function(a, b)
			return a.average_time > b.average_time
		end)
		
		local max = 0
		local max2 = 0
		for k, v in pairs(top) do
			if #v.name > max then
				max = #v.name
			end
			
			v.average_time = tostring(v.average_time * 100)
			
			if #v.average_time > max2 then
				max2 = #v.average_time
			end
		end
			
		logn(("_"):rep(max+max2+11+10))
		logn("| NAME:", (" "):rep(max-4), "| MS:", (" "):rep(max2-2), "| CALLS:")
		logn("|", ("_"):rep(max+2), "|", ("_"):rep(max2+2), "|", ("_"):rep(4+10))
		for k,v in pairs(top) do
			logf("| %s%s | %s%s | %s\n", v.name, (" "):rep(max-#v.name), v.average_time, (" "):rep(max2 - #v.average_time), v.times_called) 
		end
		logn("")
		
	elseif type == "statistical" then
		for k,v in pairs(benchmark) do
			if v.name then
				table.insert(top, v)
			end
		end
		
		table.sort(top, function(a, b)
			return a.times_called > b.times_called
		end)
				
		local max = 0
		local max2 = 0
		for k, v in pairs(top) do
			if #v.name > max then
				max = #v.name
			end
			
			v.percent = tostring(math.round((v.times_called / top[1].times_called) * 100, 2))
						
			if #v.percent > max2 then
				max2 = #v.percent
			end
			
			--[[local sigh = 0
			
			for i, v in pairs(v.children) do
				if v.name then
					if v.name and #v.name > max then
						max = #v.name + i
					end
					sigh = sigh + 1
					v.i = sigh
				end
			end
			
			v.sigh = sigh]]
		end
		
		logn(("_"):rep(max+max2+11+10))
		logn("| NAME:", (" "):rep(max-4), "| CALL %:")
		logn("|", ("_"):rep(max+2), "|", ("_"):rep(4+10))
		for k,v in npairs(top) do
			logf("| %s%s | %s\n", v.name, (" "):rep(max-#v.name), v.percent)
			--[[local sigh = v.sigh
			local max = #v.call_stack
			for i, v in npairs(v.call_stack) do
				if v.line_name and i ~= max then
					logf("| %s%s%s |\n", (" "):rep(-v.i + sigh), v.line_name, (" "):rep(max - #v.line_name + v.i - sigh))
				end
			end]]
		end
		logn("")
		
	end		
end

return profiler