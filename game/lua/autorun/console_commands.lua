commands.Add("bootime", function()
	if e.CLI_TIME > -1 then
		logn("spent ", e.CLI_TIME, " seconds in ./goluwa", WINDOWS and ".cmd" or "")
	end
	if e.BOOT_TIME > -1 then
		logn("spent ", e.BOOT_TIME, " seconds in core/lua/boot.lua")
	end
	logn("spent ", e.INIT_TIME, " seconds in core/lua/init.lua")
	logn("spent ", os.clock() - e.BOOTIME, " seconds from core/lua/init.lua to this command")
end)

commands.Add("exit=number[0]", function(exit_code)
	system.ShutDown(exit_code)
end)

commands.Add("gc", function()
	collectgarbage()
	logn(utility.FormatFileSize(collectgarbage("count")*1024))
end)

commands.Add("test_mem=number", function(limit)
	limit = limit * 1024 * 1024 * 1024
	local tbl = {}
	for i = 1, math.huge do
		if (collectgarbage("count") * 1024) > limit then
			logn(i)
			break
		end
		tbl[i] = {1,2,3}
	end
	_G.TEST_MEM = tbl
end)

do
	local sigh = {}

	commands.Add("luacheck=arg_line", function(what)
		table.clear(sigh)
		table.insert(sigh, "--no-color")
		for path in pairs(vfs.GetLoadedLuaFiles()) do
			if path:find(what) then
				table.insert(sigh, path)
			end
		end
		_G.arg = sigh
		runfile("lua/modules/luacheck/main.lua")
		_G.arg = nil
	end)
end

do -- url monitoring
	commands.Add("monitor_url=string,number[0.5]", function(url, interval)
		local last_modified
		local busy

		event.Timer("monitor_" .. url, interval, 0, function()
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

	commands.Add("unmonitor_url=arg_line", function(url)
		event.RemoveTimer("monitor_" .. url)

		logf("%s stop monitoring\n", url)
	end)
end

commands.Add("trace_calls=string", function(line, ...)
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

commands.Add("debug=string", function(lib)
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

commands.Add("find", function(...)
	local data = utility.FindValue(...)

	for _, v in pairs(data) do
		logn("\t", v.nice_name)
	end
end)

commands.Add("lfind=string", function(what)
	for path, lines in pairs(utility.FindInLoadedLuaFiles(what)) do
		logn(path)
		for _, info in ipairs(lines) do
			local str = info.str
			str = str:gsub("\t", " ")
			--str = str:sub(0, info.start-1) ..  ">>>" .. str:sub(info.start, info.stop) .. "<<<" .. str:sub(info.stop+1)
			logf("\t%d: %s\n", info.line, str)
			logn((" "):rep(#tostring(info.line) + 5 + info.start), ("^"):rep(info.stop - info.start + 1))
		end
	end
end)

local tries = {
	"lua/?",
	"?",
	"lua/examples/?",
	"lua/libraries/?",
}

commands.Add("source=string,number|nil", function(path, line_number, ...)

	if path:find(":") then
		local a,b = path:match("(.+):(%d+)")
		path = a or path
		line_number = b or line_number
	end

	for _, try in pairs(tries) do
		local path = try:gsub("?", path)
		if vfs.Exists(path) and vfs.GetLoadedLuaFiles()[R(path)] then
			debug.openscript(path, tonumber(line_number) or 0)
			return
		end
	end

	for loaded_path in pairs(vfs.GetLoadedLuaFiles()) do
		if loaded_path:compare(path) then
			debug.openscript(loaded_path, line_number)
			return
		end
	end

	local data = utility.FindValue(path, line_number, ...)

	local func
	local name

	for _, v in pairs(data) do
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
			logn(debug.getprettysource(func, true))
		end
	else
		logf("function %q could not be found in _G or in added commands\n", path)
	end

	if #data > 0 then
		if #data < 10 then
			logf("also found:\n")

			for _, v in pairs(data) do
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
	"examples/?.lua",
}

commands.Add("open=arg_line", function(line)
	local tried = {}

	for _, try in pairs(tries) do
		local path = try:gsub("?", line)
		if vfs.IsFile(path) then
			runfile(path)
			return
		end
		if vfs.IsFile("lua/" .. path) then
			runfile("lua/" .. path)
			return
		end
		table.insert(tried, "\t" .. path)
	end

	return false, "no such file:\n" .. table.concat(tried, "\n")
end, "opens a lua file with some helpers (ie trying to append .lua or prepend lua/)")

if GRAPHICS or PHYSICS then
	local tries = {
		{path = "__MAPNAME__"},
		{path = "maps/__MAPNAME__.obj"},
		{path = "__MAPNAME__/__MAPNAME__.obj", callback =  function(ent) ent:SetSize(0.01) ent:SetRotation(Quat(-1,0,0,1)) end},
	}

	commands.Add("map=string_trim", function(name)
		utility.PushTimeWarning()
		for _, info in pairs(tries) do
			local path = info.path:gsub("__MAPNAME__", name)
			if vfs.IsFile(path) then
				OBJ_WORLD = OBJ_WORLD or entities.CreateEntity("visual")
				OBJ_WORLD:SetName(name)
				OBJ_WORLD:SetModelPath(path)
				OBJ_WORLD.world = OBJ_WORLD.world or entities.CreateEntity("world")
				if info.callback then
					info.callback(OBJ_WORLD)
				end
				return
			end
		end

		steam.SetMap(name)

		utility.PopTimeWarning("map " .. name, nil, "cmd")
	end)
end