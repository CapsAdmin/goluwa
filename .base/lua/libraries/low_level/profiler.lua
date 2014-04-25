--[[

basic instrumental and statistical profiler which only provides the raw data
the statistical profiler is wip and is for luajit 2.1 alpha only
garbage details may not be accurate (i think garbage can be collected in between??)

times are probably in microsecond so * 100 and get rid of around 5 decimals

BASIC USE
	profiler.Start()
	-- enjoy the lag

	local tbl = profiler.GetBenchmark()
	-- parse the table how you want it
	
	profiler.Stop()
	
for every function called, tbl[i] looks like this:
{
	["total_time"] = 33.787754476143,
	["debug_info"] = {
		["linedefined"] = 131,
		["isvararg"] = false,
		["namewhat"] = "",
		["lastlinedefined"] = 156,
		["nups"] = 4,
		["what"] = "Lua",
		["nparams"] = 0,
	},
	["path"] = "X:/dropbox/goluwa/.base/lua/glw/init.lua",
	["times_called"] = 292,
	["average_time"] = 0.115711487932,
	["sample_duration"] = 34.010924339816,
	["line"] = 131,
	["name"] = "window.Update()",
}

]]

local profiler = _G.profiler or {}

profiler.type = "statistical"
profiler.enabled = true

local vmdef = require("jit.vmdef")

local clock = os.clock -- see SetClockFunction

local function fix_path(path) 
	return path:gsub("\\", "/"):gsub("(/+)", "/"):gsub("^%s*(.-)%s*$", "%1" )
end

local function getparams(func) 
    local params = {}
	
	for i = 1, math.huge do
		local key = debug.getlocal(func, i)
		if key then
			table.insert(params, key)
		else
			break
		end
	end

    return params
end

profiler.data = profiler.data or {}

local active = false
local data = profiler.data
local read_file


if jit.version_num >= 20100 then
	profiler.jitpf = require("jit.profile")
	profiler.default_mode = "l"
	profiler.dump_depth = 10
	profiler.dump_format = "pl\n"
end

if glfw then 
	clock = timer.clock
	read_file = vfs.Read
elseif gmod then
	clock = SysTime
end

-- call this with timer.clock or something after glfw is loaded
function profiler.SetClockFunction(func)
	clock = func
	profiler.Restart()
end

function profiler.SetReadFileFunction(func)
	read_file = func
end

do
	local function statistical_callback(thread, samples, vmstate, ...)
		if not active or not profiler.enabled then
			profiler.Stop()
		return end
						
		local str = profiler.jitpf.dumpstack(thread, profiler.dump_format, profiler.dump_depth)
		local children = {}
		
		for line in str:gmatch("(.-)\n") do
			local path, line_number = line:match("(.+):(%d+)")
			
			if not path and not line_number then
				line = line:gsub("%[builtin#(%d+)%]", function(x)
				  return vmdef.ffnames[tonumber(x)]
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
		data[path][line] = data[path][line] or {total_time = 0, samples = 0, children = {}, parents = {}, statistical = true, ready = false}
		
		data[path][line].samples = data[path][line].samples + samples
		data[path][line].start_time = data[path][line].start_time or clock()	
		
		local parent = data[path][line]
				
		for _, info in pairs(children) do
			local path = info.path or info.name
			local line = tonumber(info.line) or -1
				
			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {total_time = 0, samples = 0, children = {}, parents = {}, statistical = true, ready = false}
			
			data[path][line].samples = data[path][line].samples + samples
			data[path][line].start_time = data[path][line].start_time or clock()	
			
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
		data[path][line].start_time = data[path][line].start_time or clock()
		
		if type == "call" then
			data[path][line].call_time = clock()
			data[path][line].call_garbage = collectgarbage("count")
		elseif type == "return" and data[path][line].call_time then
			data[path][line].total_time = data[path][line].total_time + (clock() - data[path][line].call_time)
			data[path][line].total_garbage = data[path][line].total_garbage + (collectgarbage("count") - data[path][line].call_garbage)
		end
	end

	function profiler.Start(type)
		type = type or profiler.type
		
		if not profiler.enabled then return end
						
		if type == "statistical" then
			profiler.jitpf.start(profiler.default_mode, function(...) 
				local ok, err = xpcall(statistical_callback, goluwa.OnError, ...)
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
		profiler.jitpf.stop()
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

function profiler.GetBenchmark(type)
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
		
			if read_file then
				local content = read_file(path)
				
				if content then
					name = content:explode("\n")[line]
					if name then
						name = name:gsub("function ", "")
						name = name:trim()			
					end
				end

		
				name = name or "unknown(file not found)"
				
				name = name:trim()
				
			elseif data.func then		
				name = ("%s(%s)"):format(data.func_name, table.concat(getparams(data.func), ", "))
			end

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
											
			data.sample_duration = clock() - data.start_time
			data.times_called = data.samples
			
			table.insert(out, data)
		end
	end
	
	return out
end

return profiler