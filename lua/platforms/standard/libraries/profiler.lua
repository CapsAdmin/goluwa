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
	["path"] = "X:/dropbox/goluwa/lua/platforms/glw/init.lua",
	["times_called"] = 292,
	["average_time"] = 0.115711487932,
	["sample_duration"] = 34.010924339816,
	["line"] = 131,
	["name"] = "window.Update()",
}

]]

local profiler = _G.profiler or {}

profiler.type = "instrumental"
profiler.default_zone = "no zone"
profiler.enabled = true

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
local zone = profiler.default_zone
local data = profiler.data
local read_file


if jit.version_num >= 20100 then
	profiler.jitpf = require("jit.profile")
	profiler.default_mode = "l"
	profiler.dump_depth = 10
	profiler.dump_format = "pl\n"
end

if glfw then 
	clock = glfw.GetTime
	read_file = vfs.Read
elseif gmod then
	clock = SysTime
end

-- call this with glfw.GetTime or something after glfw is loaded
function profiler.SetClockFunction(func)
	time = func
	profiler.Restart()
end

-- call this with glfw.GetTime or something after glfw is loaded
function profiler.SetReadFileFunction(func)
	read_file = func
end

do
	local function statistical_callback(thread, samples, vmstate)
		if not active or not profiler.enabled then
			profiler.Stop()
		return end
		
		profiler.jitpf.dumpstack(thread, profiler.dump_format, profiler.dump_depth):gsub("(.-):(%d+)", function(path, line)
			
			data[zone] = data[zone] or {}
			data[zone][path] = data[zone][path] or {}
			data[zone][path][line] = data[zone][path][line] or {total_time = 0, samples = 0}
			
			data[zone][path][line].samples = data[zone][path][line].samples + samples
			data[zone][path][line].start_time = data[zone][path][line].start_time or clock()
			
		end)
	end
	
	local function instrumental_callback(type)
		if not active or not profiler.enabled then
			profiler.Stop()
		return end
	
		local info = debug.getinfo(2)
		
		if info.linedefined <= 0 then return end
		
		local path = info.source
		local line = info.linedefined
				
		data[zone] = data[zone] or {}
		data[zone][path] = data[zone][path] or {}
		data[zone][path][line] = data[zone][path][line] or {total_time = 0, samples = 0, total_garbage = 0, func = info.func, func_name = info.name}
		
		data[zone][path][line].samples = data[zone][path][line].samples + 1
		data[zone][path][line].start_time = data[zone][path][line].start_time or clock()
		
		if type == "call" then
			data[zone][path][line].call_time = clock()
			data[zone][path][line].call_garbage = collectgarbage("count")
		elseif type == "return" and data[zone][path][line].call_time then
			data[zone][path][line].total_time = data[zone][path][line].total_time + (clock() - data[zone][path][line].call_time)
			data[zone][path][line].total_garbage = data[zone][path][line].total_garbage + (collectgarbage("count") - data[zone][path][line].call_garbage)
		end
	end

	function profiler.Start(zone)
		if not profiler.enabled then return end
				
		if not zone then
			local info = debug.getinfo(2)
			if info then
				zone = info.name
			end
		end
		
		zone = zone or profiler.default_zone
		
		if profiler.type == "statistical" then
			profiler.jitpf.start(profiler.default_mode, statistical_callback)
		elseif profiler.type == "instrumental" then
			debug.sethook(instrumental_callback, "cr")
		end
		
		active = true
	end
end

function profiler.Stop()
	if not profiler.enabled then return end
	
	if profiler.type == "statistical" then
		profiler.jitpf.stop()
	elseif profiler.type == "instrumental" then
		debug.sethook()
	end
	
	active = false
end

function profiler.Restart()
	profiler.data = {}
	data = profiler.data
end

function profiler.GetZone()
	return zone
end

function profiler.GetBenchmark()
	local out = {}
	
	for zone, file_data in pairs(data) do
		for path, lines in pairs(file_data) do
			for line, data in pairs(lines) do
				
				line =  tonumber(line)
				
				local path = fix_path(path:gsub("%[.-%]", ""):gsub("@", ""))
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
						else
							name = "unknown(line not found)"
						end
					else
						name = "unknown(file not found)"
					end
				elseif data.func then		
					name = ("%s(%s)"):format(data.func_name, table.concat(getparams(data.func), ", "))
				end
				
				local temp = {
					zone = zone ~= "no zone" and zone or nil, 
					path = path,
					
					line = line,
					name = name,
					debug_info = debug_info,
				}
				
				if data.total_time then
					temp.average_time = data.total_time / data.samples
					temp.total_time = data.total_time
				end
				
				if data.total_garbage and data.total_garbage > 0 then
					temp.average_garbage = math.floor(data.total_garbage / data.samples)
					temp.total_garbage = data.total_garbage
				end
								
				temp.sample_duration = clock() - data.start_time
				temp.times_called = data.samples
				
				table.insert(out, temp)
			end
		end
	end

	return out
end

return profiler