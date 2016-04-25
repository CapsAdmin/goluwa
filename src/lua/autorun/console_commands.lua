commands.Add("dump_gbuffer", function(_, format, depth_format)
	ffi.cdef[[
		void *fopen(const char *filename, const char *mode);
		size_t fwrite(const void *ptr, size_t size, size_t nmemb, void *stream);
		int fclose( void * stream );
	]]

	event.AddListener("GBufferPrePostProcess", function()
		for k,v in pairs(render.gbuffer.textures) do
			local ok, err = pcall(function()
				local format = format
				if k == "depth" then format = depth_format end
				print(format)
				local data = v.tex:Download(nil, format)
				local buffer = data.buffer
				data.buffer = nil
				serializer.WriteFile("luadata", "" .. k .. ".tbl", data)
				local f = ffi.C.fopen(R("data/") .. k .. ".data", "wb")
				ffi.C.fwrite(buffer, 1, data.size, f)
				ffi.C.fclose(f)
			end)
			if ok then
				logf("dumped buffer %s to %s\n", k,  k .. ".tbl and *.data")
			else
				logf("error dumping buffer %s: %s\n", k, err)
			end
		end
	end)
end)

do -- source engine
	commands.Add("getpos", function()
		local pos = render.camera_3d:GetPosition() * (1/0.0254)
		local ang = render.camera_3d:GetAngles():GetDeg()

		logf("setpos %f %f %f;setang %f %f %f", pos.x, pos.y, pos.z, ang.x, ang.y, ang.z)
	end)

	commands.Add("setpos", function(line)
		local x,y,z = unpack(line:match("(.-);"):split(" "))
		x = tonumber(x)
		y = tonumber(y)
		z = tonumber(z)
		render.camera_3d:SetPosition(Vec3(x,y,z) * 0.0254)

		local p,y,r = unpack(line:match("setang (.+)"):split(" "))
		p = tonumber(p)
		y = tonumber(y)
		r = tonumber(r)
		render.camera_3d:SetAngles(Deg3(p,y,r))
	end)
end

commands.Add("clear", commands.Clear)

local tries = {
	{path = "__MAPNAME__"},
	{path = "maps/__MAPNAME__.obj"},
	{path = "__MAPNAME__/__MAPNAME__.obj", callback =  function(ent) ent:SetSize(0.01) ent:SetRotation(Quat(-1,0,0,1)) end},
}

commands.Add("map", function(name)
	for _, info in pairs(tries) do
		local path = info.path:gsub("__MAPNAME__", name)
		if vfs.IsFile(path) then
			OBJ_WORLD = OBJ_WORLD or entities.CreateEntity("visual")
			OBJ_WORLD:SetName(name)
			OBJ_WORLD:SetCull(false)
			OBJ_WORLD:SetModelPath(path)
			OBJ_WORLD.world = OBJ_WORLD.world or entities.CreateEntity("world")
			if info.callback then
				info.callback(OBJ_WORLD)
			end
			return
		end
	end

	steam.SetMap(name)
end)

commands.Add("dump_object_count", function()
	local found = {}

	for obj in pairs(prototype.GetCreated()) do
		local name = obj.ClassName
		if obj.ClassName ~= obj.Type then
			name = obj.Type .. "_" .. name
		end
		found[name] = (found[name] or 0) + 1
	end

	table.print(found)
end)

commands.Add("find_object", function(str)
	local obj = prototype.FindObject(str)
	if obj then
		table.print(obj:GetStorableTable())
	end
end)

do -- url monitoring
	commands.Add("monitor_url", function(_, url, interval)
		interval = tonumber(interval) or 0.5

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

	commands.Add("unmonitor_url", function(_, url)
		event.RemoveTimer("monitor_" .. url)

		logf("%s stop monitoring\n", url)
	end)
end

input.Bind("e+left_alt", "toggle_focus", function()
	if window.GetMouseTrapped() then
		window.SetMouseTrapped(false)
	else
		window.SetMouseTrapped(true)
	end
end)

do
	local source = NULL

	commands.Add("play", function(path)
		if source:IsValid() then source:Remove() end
		source = audio.CreateSource(path)
		source:Play()
	end)
end

commands.Add("stopsounds", function()
	audio.Panic()
end)

do
	commands.Add("say", function(line)
		chat.Say(line)
	end)

	commands.Add("lua_run", function(line)
		commands.SetLuaEnvironmentVariable("me", clients.GetLocalClient())
		commands.RunLua(line)
	end)

	commands.Add("lua_open", function(line)
		include(line)
	end)

	commands.AddServerCommand("lua_run_sv", function(client, line)
		logn(client:GetNick(), " ran ", line)
		commands.SetLuaEnvironmentVariable("me", client)
		commands.RunLua(line)
	end)

	commands.AddServerCommand("lua_open_sv", function(client, line)
		logn(client:GetNick(), " opened ", line)
		include(line)
	end)


	local default_ip = "*"
	local default_port = 1234

	if CLIENT then
		local ip_cvar = pvars.Setup("cl_ip", default_ip)
		local port_cvar = pvars.Setup("cl_port", default_port)

		local last_ip
		local last_port

		commands.Add("retry", function()
			if last_ip then
				network.Connect(last_ip, last_port)
			end
		end)

		commands.Add("connect", function(line, ip, port)
			ip = ip or ip_cvar:Get()
			port = tonumber(port) or port_cvar:Get()

			logf("connecting to %s:%i\n", ip, port)

			last_ip = ip
			last_port = port

			network.Connect(ip, port)
		end)

		commands.Add("disconnect", function(line)
			network.Disconnect(line)
		end)
	end

	if SERVER then
		local ip_cvar = pvars.Setup("sv_ip", default_ip)
		local port_cvar = pvars.Setup("sv_port", default_port)

		commands.Add("host", function(line, ip, port)
			ip = ip or ip_cvar:Get()
			port = tonumber(port) or port_cvar:Get()

			logf("hosting at %s:%i\n", ip, port)

			network.Host(ip, port)
		end)
	end
end

commands.Add("trace_calls", function(_, line, ...)
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

commands.Add("debug", function(line, lib)
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

commands.Add("find", function(line, ...)
	local data = utility.FindValue(...)

	for k,v in pairs(data) do
		logn("\t", v.nice_name)
	end
end)

commands.Add("lfind", function(line)
	for path, lines in pairs(utility.FindInLoadedLuaFiles(line)) do
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

commands.Add("source", function(line, path, line_number, ...)

	if path:find(":") then
		local a,b = path:match("(.+):(%d+)")
		path = a or path
		line_number = b or line_number
	end

	for i, try in pairs(tries) do
		local path = try:gsub("?", path)
		if vfs.Exists(path) and vfs.GetLoadedLuaFiles()[R(path)] then
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
	"examples/?.lua",
}

commands.Add("open", function(line)
	local tried = {}

	for i, try in pairs(tries) do
		local path = try:gsub("?", line)
		if vfs.IsFile(path) then
			include(path)
			return
		end
		if vfs.IsFile("lua/" .. path) then
			include("lua/" .. path)
			return
		end
		table.insert(tried, "\t" .. path)
	end

	return false, "no such file:\n" .. table.concat(tried, "\n")
end, "opens a lua file with some helpers (ie trying to append .lua or prepend lua/)")