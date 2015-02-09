console.AddCommand("clear", console.Clear)

console.AddCommand("dump_object_count", function()
	local found = {}
	
	for obj in pairs(prototype.GetCreated()) do
		found[obj.ClassName] = (found[obj.ClassName] or 0) + 1
	end
	
	table.print(found)
end)

do -- url monitoring
	console.AddCommand("monitor_url", function(_, url, interval)
		interval = tonumber(interval) or 0.5
		
		local last_modified
		local busy
			
		event.CreateTimer("monitor_" .. url, interval, 0, function()
			if busy then return end
			busy = true
			sockets.Request({
				url = url,
				method = "HEAD",
				callback = function(data) 
					busy = false
					local date = data.header["last-modified"] or data.header["date"]
					
					if date ~= last_modified then					
						sockets.Download(url, function(lua)
							local func, err = loadstring(lua)
							if func then
								local ok, err = pcall(func)
								if ok then
									logf("%s reloaded\n", url)
								else
									logf("%s failed: %s\n", url, err)
								end
							else
								logf("%s loadstring failed: %s\n", url, err)
							end
						end)
						
						last_modified = date
					end
				end,
			})
		end)
		
		logf("%s start monitoring\n", url)
	end)

	console.AddCommand("unmonitor_url", function(_, url)
		event.RemoveTimer("monitor_" .. url)
		
		logf("%s stop monitoring\n", url)
	end)
end

do
	input.Bind("e+left_alt", "toggle_focus")

	console.AddCommand("toggle_focus", function()
		if window.GetMouseTrapped() then
			window.SetMouseTrapped(false)
		else
			window.SetMouseTrapped(true)
		end
	end)
end

do
	local source = NULL

	console.AddCommand("play", function(path)
		if source:IsValid() then source:Remove() end
		source = audio.CreateSource(path)
		source:Play()
	end)
end

console.AddCommand("stopsounds", function()
	audio.Panic()
end)

do
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
		console.RunLua(line)
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

console.AddCommand("profile_start", function()	
	profiler.EnableSectionProfiling(true)
	profiler.EnableTraceAbortLogging(true)
	profiler.EnableStatisticalProfiling(true)
end)

console.AddCommand("profile_stop", function()	
	profiler.EnableSectionProfiling(false)
	profiler.EnableTraceAbortLogging(false)
	profiler.EnableStatisticalProfiling(false)
end)

console.AddCommand("profile_dump", function(line)
	if line == "" or line == "st" or line == "s" then
		profiler.PrintStatistical()
	end
	
	if line == "" or line == "se" then
		profiler.PrintSections()
	end
	
	if line == "" or line == "ab" or line == "a" then
		profiler.PrintTraceAborts()
	end
end)

console.AddCommand("profile", function(line, time, file_filter)
	profiler.MeasureInstrumental(tonumber(time) or 5, file_filter)
end)

console.AddCommand("find", function(line, ...)
	local data = utility.FindValue(...)
	
	for k,v in pairs(data) do
		logn("\t", v.nice_name) 
	end
end)

console.AddCommand("lfind", function(line) 
	for path, lines in pairs(utility.FindInLoadedLuaFiles(line)) do
		logn(path)
		for _, info in ipairs(lines) do
			local str = info.str
			str = str:gsub("\t", " ")
			--str = str:sub(0, info.start-1) ..  ">>>" .. str:sub(info.start, info.stop) .. "<<<" .. str:sub(info.stop+1)
			logf("\t%d: %s", info.line, str)
			logn((" "):rep(#tostring(info.line) + 9 + info.start), ("^"):rep(info.stop - info.start + 1))
		end
	end
end)

local tries = {
	"lua/?",
	"?",
	"lua/tests/?",
	"lua/libraries/?",
}

console.AddCommand("source", function(line, path, line_number, ...)

	if path:find(":") then
		local a,b = path:match("(.+):(%d+)")
		path = a or path
		line_number = b or line_number
	end

	for i, try in pairs(tries) do
		local path = try:gsub("?", path)
		if vfs.Exists(path) then
			debug.openscript(path, tonumber(line_number) or 0)
			return
		end
	end	

	for k,v in pairs(vfs.GetLoadedLuaFiles()) do
		if k:compare(path) then
			debug.openscript(k, line_number)
			return
		end
	end

	local data = utility.FindValue(path, line_number, ...)
		
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
			logn(func:src())
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
		if vfs.IsFile(path) then
			include(path)
			return
		end
		if vfs.IsFile("lua/" .. path) then
			include(path)
			return
		end
		table.insert(tried, "\t" .. path)
	end	
	
	return false, "no such file:\n" .. table.concat(tried, "\n")
end, "opens a lua file with some helpers (ie trying to append .lua or prepend lua/)")