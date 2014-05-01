console.AddCommand("l", function(line)
	console.RunString(line)
end)

console.AddCommand("print", function(line)
	console.RunString(("log(%s)"):format(line))
end)

console.AddCommand("table", function(line)
	console.RunString(("table.print(%s)"):format(line))
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

console.AddCommand("profile", function(line, time, ptype)
	profiler.SetClockFunction(timer.clock)
	profiler.SetReadFileFunction(vfs.Read)

	time = tonumber(time) or 1
	
	if type(ptype) == "string" then
		if ptype:sub(1,1) == "i" then 
			ptype = "instrumental"
		elseif ptype:sub(1,1) == "s" then 
			ptype = "statistical"
		end
	else
		ptype = profiler.type
	end
	
	profiler.Start(nil, ptype)
	
	logn("starting profiler for ", time, " seconds")
	
	timer.Create("profile_status", 1, time, function(i)
		logn("profiling...")
		if time ~= i+1 then return end
		
		profiler.Stop(ptype)

		profiler.PrintBenchmark(profiler.GetBenchmark(), ptype)
	end)
end)

console.AddCommand("find", function(line, ...)
	local data = utilities.FindValue(...)
	
	for k,v in pairs(data) do
		logn("\t", v.nice_name) 
	end
end)

console.AddCommand("source", function(line, ...)

	if vfs.Exists(line) then
		debug.openscript(line)
		return
	end

	local data = utilities.FindValue(...)
		
	local func
	local name
	
	for k,v in pairs(data) do
		if type(v.val) == "function" then
			func = v.val
			name = v.nice_name
			break
		end
	end
	
	if func then
		logn("--> ", name)
		
		table.remove(data, 1)
		
		if not debug.openfunction(func) then
			print(func:src())
		end
	else
		logf("function %q could not be found in _G or in added commands", line)
	end
	
	if #data > 0 then
		
		if #data < 10 then
			logf("also found:")
			
			for k,v in pairs(data) do
				logn("\t", v.nice_name) 
			end
		else
			logf("%i results were also found", #data)
		end
	end
end)

console.AddCommand("open", function(line)
	if vfs.Exists("lua/" .. line .. ".lua") then 
		include(line .. ".lua")
	elseif vfs.Exists("lua/tests/" .. line .. ".lua") then
		include("tests/" .. line .. ".lua")  
	else
		return false, ("lua/%s.lua and lua/tests/%s.lua was not found"):format(line, line)
	end
end, "calls include(*input*.lua) or include(tests/*input*.lua) if the former failed")