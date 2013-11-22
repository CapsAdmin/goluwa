console.AddCommand("start_server", function()
	SERVER = true
	addons.Reload()
	include("lua/platforms/glw/libraries/network/init.lua")
end)

console.AddCommand("start_client", function()
	CLIENT = true
	addons.Reload()
	include("lua/platforms/glw/libraries/network/init.lua")
end)

console.AddCommand("trace_calls", function(_, line, ...)
	line = "_G." .. line
	local ok, old_func = assert(pcall(assert(loadstring("return " .. line))))

	if ok and old_func then
		local table_index, key = line:match("(.+)%.(.+)")
		local idx_func = assert(loadstring(("%s[%q] = ..."):format(table_index, key)))
		
		local args = {...}
		
		for k, v in pairs(args) do
			args[k] = select(2, assert(pcall(assert(loadstring("return " .. v)))))
		end
				
		idx_func(function(...)	
			
			if #args > 0 then
				local found = false
				
				for i = 1, select("#", ...) do
					local v = select(i, ...)
					if args[i] then
						if args[i] == v then
							found = true
						else
							found = false
							break
						end
					end
				end
				
				if found then
					debug.trace()	
				end
			else
				debug.trace()
			end
			
			return old_func(...)
		end)
		
		timer.Delay(1, function()
			idx_func(old_func)
		end)
	end
end)

console.AddCommand("debug", function(line, lib)
	local tbl = _G[lib]
	
	if type(tbl) == "table" then
		tbl.debug = not tbl.debug
		
		if tbl.EnableDebug then
			tbl.EnableDebug(tbl.debug)
		end
		
		if tbl.debug then
			logn(lib, " debugging enabled")
		else
			logn(lib, " debugging disabled")
		end
	end
end)

console.AddCommand("profile", function(line, time)
	profiler.SetClockFunction(glfw.GetTime)
	profiler.SetReadFileFunction(vfs.Read)

	time = tonumber(time)
	
	profiler.Start()
	
	logn("starting profiler for ", time, " seconds")
	
	if time > 2 then
		timer.Create("profile_status", 1, time-1, function()
			logn("profiling...")
		end)
	end
	
	timer.Delay(time, function()
		profiler.Stop()
		
		local benchmark = profiler.GetBenchmark()
		local top = {}
		
		for k,v in pairs(benchmark) do
			if v.times_called > 50 and v.average_time > 0 then
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
			logf("| %s%s | %s%s | %s", v.name, (" "):rep(max-#v.name), v.average_time, (" "):rep(max2 - #v.average_time), v.times_called) 
		end
		logn("")
		
	end)	
end)

do
	local done = {}

	local skip =
	{
		UTIL_REMAKES = true,
		ffi = true,
	}

	local keywords =
	{
		AND = function(a, func, x,y) return func(a, x) and func(a, y) end	
	}

	local function args_call(a, func, ...)
		local tbl = {...}
		
		for i = 1, #tbl do
			local val = tbl[i]
			
			if not keywords[val] then
				local keyword = tbl[i+1]
				if keywords[keyword] and tbl[i+2] then
					local ret = keywords[keyword](a, func, val, tbl[i+2])
					if ret ~= nil then
						return ret
					end
				else
					local ret = func(a, val)
					if ret ~= nil then
						return ret
					end
				end
			end
		end
	end

	local function strfind(str, ...)
		return args_call(str, string.compare, ...) or args_call(str, string.find, ...)
	end

	local function find(tbl, name, level, ...)
		if level > 3 then return end
			
		for key, val in pairs(tbl) do	
			local T = type(val)
			key = tostring(key)
				
			if not skip[key] and T == "table" and not done[val] then
				done[val] = true
				find(val, name .. "." .. key, level + 1, ...)
			else
				if (T == "function" or T == "number") and (strfind(key, ...) or strfind(name, ...)) then
					if T == "function" then
						val = "(" .. table.concat(debug.getparams(val), ", ") .. ")"
					elseif T ~= "table" then
						val = luadata.ToString(val)
					else
						val = tostring(val)	
					end
					
					if name == "_G" or name == "_M" then
						logf("\t%s = %s", key, val)
					else
						name = name:gsub("_G%.", "")
						name = name:gsub("_M%.", "")
						if T == "function" then
							logf("\t%s.%s%s", name, key, val)
						else
							logf("\t%s.%s = %s", name, key, val)
						end
					end
				end
			end
		end
	end

	console.AddCommand("find", function(line, ...)			
		done = 
		{
			[_G] = true,
			[_R] = true,
			[package] = true,
			[_OLD_G] = true,
		}
			
		logf("searched for %q", table.concat(tostring_args(...), ", "))
		logn("globals:")
		find(_G, "_G", 1, ...)
		logn("metatables:")
		find(utilities.GetMetaTables(), "_M", 1, ...)
	end)
end