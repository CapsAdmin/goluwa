do
	-- some usage

	console.AddCommand("say", function(line)
		chat.Say(line)
	end)

	console.AddCommand("lua_run", function(line)
		console.SetLuaEnvironmentVariable("me", clients.GetLocalClient()) 
		console.RunLua(line)
	end)

	console.AddCommand("lua_open", function(line)
		include(line)
	end)

	console.AddServerCommand("lua_run_sv", function(client, line)
		logn(client:GetNick(), " ran ", line)
		console.SetLuaEnvironmentVariable("me", client) 
		concat.RunLua(line)
	end)

	console.AddServerCommand("lua_open_sv", function(client, line)
		logn(client:GetNick(), " opened ", line)
		include(line)
	end)


	local default_ip = "*"
	local default_port = 1234

	if CLIENT then
		local ip_cvar = console.CreateVariable("cl_ip", default_ip)
		local port_cvar = console.CreateVariable("cl_port", default_port)
		
		local last_ip
		local last_port
		
		console.AddCommand("retry", function()
			if last_ip then
				network.Connect(last_ip, last_port)
			end
		end)
		
		console.AddCommand("connect", function(line, ip, port)		
			ip = ip or ip_cvar:Get()
			port = tonumber(port) or port_cvar:Get()
			
			logf("connecting to %s:%i\n", ip, port)
			
			last_ip = ip
			last_port = port
			
			network.Connect(ip, port)
		end)

		console.AddCommand("disconnect", function(line)	
			network.Disconnect(line)
		end)
	end

	if SERVER then
		local ip_cvar = console.CreateVariable("sv_ip", default_ip)
		local port_cvar = console.CreateVariable("sv_port", default_port)
				
		console.AddCommand("host", function(line, ip, port)
			ip = ip or ip_cvar:Get()
			port = tonumber(port) or port_cvar:Get()
			
			logf("hosting at %s:%i\n", ip, port)
			
			network.Host(ip, port)
		end)
	end
end

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
		
		event.Delay(1, function()
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
	profiler.SetClockFunction(timer.GetSystemTime)
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
	
	event.CreateTimer("profile_status", 1, time, function(i)
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


local tries = {
	"lua/?",
	"?",
	"lua/tests/?",
	"lua/libraries/?",
}

console.AddCommand("source", function(line, ...)

	for i, try in pairs(tries) do
		local path = try:gsub("?", line)
		if vfs.Exists(path) then
			debug.openscript(path, tonumber((...)) or 0)
			return
		end
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
		logf("function %q could not be found in _G or in added commands\n", line)
	end
	
	if #data > 0 then
		
		if #data < 10 then
			logf("also found:\n")
			
			for k,v in pairs(data) do
				logn("\t", v.nice_name) 
			end
		else
			logf("%i results were also found\n", #data)
		end
	end
end)

local tries = {
	"?.lua",
	"?",
	"tests/?.lua",
}

console.AddCommand("open", function(line)
	local tried = {}
	
	for i, try in pairs(tries) do
		local path = try:gsub("?", line)
		if vfs.Exists(path) then
			include(path)
			return
		end
		if vfs.Exists("lua/" .. path) then
			include(path)
			return
		end
		table.insert(tried, "\t" .. path)
	end	
	
	return false, "no such file:\n" .. table.concat(tried, "\n")
end, "opens a lua file with some helpers (ie trying to append .lua or prepend lua/)")