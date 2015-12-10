local system = _G.system or {}

local ffi = require("ffi")

do
	system.run = true

	function system.ShutDown(code)
		code = code or 0
		logn("shutting down with code ", code)
		system.run = code
	end

	local old = os.exit

	function os.exit(code)
		warning("os.exit() called with code %i", 2, code or 0)
		--system.ShutDown(code)
	end

	function os.realexit(code)
		old(code)
	end
end

do
	local show = console.CreateVariable("system_fps_show", true, "show fps in titlebar")
	local avg_fps = 1

	function system.UpdateTitlebarFPS(dt)
		if not show:Get() then return end

		local fps = 1/dt

		avg_fps = avg_fps + ((fps - avg_fps) * dt)

		if wait(0.25) then
			console.SetTitle(("FPS: %i"):format(avg_fps), "fps")

			if utility and utility.FormatFileSize then
				console.SetTitle(("GARBAGE: %s"):format(utility.FormatFileSize(collectgarbage("count") * 1024)), "garbage")
			end

			if render.draw_calls then
				console.SetTitle(("DRAW CALLS: %s"):format(render.draw_calls), "drawcalls")
			end

			if render.vertices_drawn then
				console.SetTitle(("VERTICES: %s"):format(render.vertices_drawn), "vertices")
			end

			if GRAPHICS then
				window.SetTitle(console.GetTitle())
			end
		end
	end
end

local function not_implemented() debug.trace() logn("this function is not yet implemented!") end

function system.ExecuteArgs(args)
	args = args or _G.ARGS

	if not args and os.getenv("ARGS") then
		local func, err = loadstring("return " .. os.getenv("ARGS"))

		if func then
			local ok, tbl = pcall(func)

			if not ok then
				logn("failed to execute ARGS: ", tbl)
			end

			args = tbl
		else
			logn("failed to execute ARGS: ", err)
		end
	end

	if args then
		for _, arg in pairs(args) do
			console.RunString(tostring(arg))
		end
	end
end

do -- frame time
	local frame_time = 0.1

	function system.GetFrameTime()
		return frame_time
	end

	-- used internally in main_loop.lua
	function system.SetFrameTime(dt)
		frame_time = dt
	end
end

do -- frame number
	local frame_number = 0

	function system.GetFrameNumber()
		return frame_number
	end

	-- used internally in main_loop.lua
	function system.SetFrameNumber(num)
		frame_number = num
	end
end

do -- elapsed time (avanved from frame time)
	local elapsed_time = 0

	function system.GetElapsedTime()
		return elapsed_time
	end

	-- used internally in main_loop.lua
	function system.SetElapsedTime(num)
		elapsed_time = num
	end
end

do -- server time (synchronized across client and server)
	local server_time = 0

	function system.SetServerTime(time)
		server_time = time
	end

	function system.GetServerTime()
		return server_time
	end
end
do -- time in ms
	local get = not_implemented

	if WINDOWS then
		require("winapi.time")

		local winapi = require("winapi")

		local freq = tonumber(winapi.QueryPerformanceFrequency().QuadPart)
		local start_time = winapi.QueryPerformanceCounter()

		get = function()
			local time = winapi.QueryPerformanceCounter()

			time.QuadPart = time.QuadPart - start_time.QuadPart
			return tonumber(time.QuadPart) / freq
		end
	end

	if LINUX then
		local posix = require("syscall")

		local ts = posix.t.timespec()

		get = function()
			posix.clock_gettime("MONOTONIC", ts)
			return tonumber(ts.tv_sec * 1000000000 + ts.tv_nsec) * 1e-9
		end
	end

	system.GetTime = get
end

do -- sleep
	local sleep = not_implemented

	if WINDOWS then
		ffi.cdef("VOID Sleep(DWORD dwMilliseconds);")
		sleep = function(ms) ffi.C.Sleep(ms) end
	end

	if LINUX then
		ffi.cdef("void usleep(unsigned int ns);")
		sleep = function(ms) ffi.C.usleep(ms*1000) end
	end

	system.Sleep = sleep
end

do -- openurl
	local func = not_implemented

	if WINDOWS then
		func = function(url) os.execute(([[explorer "%s"]]):format(url)) end
	else
		local attempts = {
			"sensible-browser",
			"xdg-open",
			"kde-open",
			"gnome-open",
		}

		func = function(url)
			for i, cmd in ipairs(attempts) do
				if os.execute(cmd .. " " .. url) then
					return
				end
			end

			warning("don't know how to open an url (tried: %s)", 2, table.concat(attempts, ", "))
		end
	end

	system.OpenURL = func
end

do -- arg is made from luajit.exe
	local arg = _G.arg
	_G.arg = nil

	function system.GetStartupArguments()
		return arg
	end
end

do -- memory
	if WINDOWS then

		ffi.cdef([[
			typedef struct _PROCESS_MEMORY_COUNTERS {
				DWORD  cb;
				DWORD  PageFaultCount;
				SIZE_T PeakWorkingSetSize;
				SIZE_T WorkingSetSize;
				SIZE_T QuotaPeakPagedPoolUsage;
				SIZE_T QuotaPagedPoolUsage;
				SIZE_T QuotaPeakNonPagedPoolUsage;
				SIZE_T QuotaNonPagedPoolUsage;
				SIZE_T PagefileUsage;
				SIZE_T PeakPagefileUsage;
			} PROCESS_MEMORY_COUNTERS, *PPROCESS_MEMORY_COUNTERS;

			BOOL GetProcessMemoryInfo(HANDLE Process, PPROCESS_MEMORY_COUNTERS ppsmemCounters, DWORD cb);
		]])

		local lib = ffi.load("psapi")
		local pmc = ffi.new("PROCESS_MEMORY_COUNTERS[1]")
		local size = ffi.sizeof(pmc)

		function system.GetMemoryInfo()
			lib.GetProcessMemoryInfo(nil, pmc, size)
			local pmc = pmc[0]

			return {
				page_fault_count = pmc.PageFaultCount,
				peak_working_set_size = pmc.PeakWorkingSetSize,
				working_set_size = pmc.WorkingSetSize,
				qota_peak_paged_pool_usage = pmc.QuotaPeakPagedPoolUsage,
				quota_paged_pool_usage = pmc.QuotaPagedPoolUsage,
				quota_peak_non_paged_pool_usage = pmc.QuotaPeakNonPagedPoolUsage,
				quota_non_paged_pool_usage = pmc.QuotaNonPagedPoolUsage,
				page_file_usage = pmc.PagefileUsage,
				peak_page_file_usage = pmc.PeakPagefileUsage,
			}
		end
	end

	if LINUX then
		system.GetMemoryInfo = not_implemented
	end
end

do -- editors
	if WINDOWS then
		local editors = {
			["ZeroBrane.Studio"] = "%PATH%:%LINE%",
			["notepad++.exe"] = "\"%PATH%\" -n%LINE%",
			["notepad2.exe"] = "/g %LINE% %PATH%",
			["sublime_text.exe"] = "%PATH%:%LINE%",
			["notepad.exe"] = "/A %PATH%",
		}

		function system.FindFirstEditor(os_execute, with_args)
			local app = system.GetRegistryValue("ClassesRoot/.lua/default")
			if app then
				local path = system.GetRegistryValue("ClassesRoot/" .. app .. "/shell/edit/command/default")
				if path then
					path = path and path:match("(.-) %%") or path:match("(.-) \"%%")
					if path then
						if os_execute then
							path = "start \"\" " .. path
						end

						if with_args and editors[app] then
							path = path .. " " .. editors[app]
						end

						return path
					end
				end
			end
		end
	else
		local editors = {
			{
				name = "atom",
				args = "%PATH%:%LINE%",
			},
			{
				name = "scite",
				args = "%PATH% -goto:%LINE%",
			},
			{
				name = "emacs",
				args = "+%LINE% %PATH%",
				terminal = true,
			},
			{
				name = "vim",
				args = "%PATH%:%LINE%",
				terminal = true,
			},
			{
				name = "kate",
				args = "-l %LINE% %PATH%",
			},
			{
				name = "gedit",
				args = "+%LINE% %PATH%",
			},
			{
				name = "nano",
				args = "+%LINE% %PATH%",
				terminal = true,
			},
		}

		function system.FindFirstEditor(os_execute, with_args)
			for k, v in pairs(editors) do

				if io.popen("command -v " .. v.name):read() then
					local cmd = v.name

					if v.terminal then
						cmd = "x-terminal-emulator -e " .. cmd
					end

					if with_args then
						cmd = cmd .. " " .. v.args

					end

					if os_execute then
						cmd = cmd .. " &"
					end

					return cmd
				end
			end
		end
	end
end

do -- dll paths
	local set, get = not_implemented, not_implemented

	if WINDOWS then
		ffi.cdef[[
			BOOL SetDllDirectoryA(LPCTSTR lpPathName);
			DWORD GetDllDirectoryA(DWORD nBufferLength, LPTSTR lpBuffer);
		]]

		set = function(path)
			ffi.C.SetDllDirectoryA(path or "")
		end

		local str = ffi.new("char[1024]")

		get = function()
			ffi.C.GetDllDirectoryA(1024, str)

			return ffi.string(str)
		end
	end

	if LINUX then
		set = function(path)
			os.setenv("LD_LIBRARY_PATH", path)
		end

		get = function()
			return os.getenv("LD_LIBRARY_PATH") or ""
		end
	end

	system.SetSharedLibraryPath = set
	system.GetSharedLibraryPath = get
end

do -- registry
	local set = not_implemented
	local get = not_implemented

	if WINDOWS then
		ffi.cdef([[
			typedef unsigned goluwa_hkey;
			LONG RegGetValueA(goluwa_hkey, LPCTSTR, LPCTSTR, DWORD, LPDWORD, PVOID, LPDWORD);
		]])

		local advapi = ffi.load("advapi32")

		local ERROR_SUCCESS = 0
		local HKEY_CLASSES_ROOT  = 0x80000000
		local HKEY_CURRENT_USER = 0x80000001
		local HKEY_LOCAL_MACHINE = 0x80000002
		local HKEY_CURRENT_CONFIG = 0x80000005

		local RRF_RT_REG_SZ = 0x00000002

		local translate = {
			HKEY_CLASSES_ROOT  = 0x80000000,
			HKEY_CURRENT_USER = 0x80000001,
			HKEY_LOCAL_MACHINE = 0x80000002,
			HKEY_CURRENT_CONFIG = 0x80000005,

			ClassesRoot  = 0x80000000,
			CurrentUser = 0x80000001,
			LocalMachine = 0x80000002,
			CurrentConfig = 0x80000005,
		}

		get = function(str)
			local where, key1, key2 = str:match("(.-)/(.+)/(.*)")

			if where then
				where, key1 = str:match("(.-)/(.+)/")
			end

			where = translate[where] or where
			key1 = key1:gsub("/", "\\")
			key2 = key2 or ""

			if key2 == "default" then key2 = nil end

			local value = ffi.new("char[4096]")
			local value_size = ffi.new("unsigned[1]")
			value_size[0] = 4096

			local err = advapi.RegGetValueA(where, key1, key2, RRF_RT_REG_SZ, nil, value, value_size)

			if err ~= ERROR_SUCCESS then
				return
			end

			return ffi.string(value)
		end
	end

	if LINUX then
		-- return empty values
	end

	system.GetRegistryValue = get
	system.SetRegistryValue = set
end

do -- jit debug
	function system.DebugJIT(b)
		if b then
			jit.v.on(R"%DATA%/logs/jit_verbose_output.txt")
		else
			jit.v.off(R"%DATA%/logs/jit_verbose_output.txt")
		end
	end
end
do -- jit options
	local current = {
		maxtrace = 65535, -- Max. number of traces in the cache						default = 1000		min = 1	 max = 65535
		maxrecord = 4000*5, -- Max. number of recorded IR instructions 		1		default = 4000
		maxirconst = 500*5, -- Max. number of IR constants of a trace       		default = 500
		maxside = 100, -- Max. number of side traces of a root trace        		default = 100
		maxsnap = 500, -- Max. number of snapshots for a trace              		default = 500
		minstitch = 0, -- Min. # of IR ins for a stitched trace.					default = 0
		hotloop = 56*100, -- Number of iterations to detect a hot loop or hot call  default = 56
		hotexit = 10, -- Number of taken exits to start a side trace                default = 10
		tryside = 4, -- Number of attempts to compile a side trace                  default = 4
		instunroll = 4*999, -- Max. unroll factor for instable loops                default = 4
		loopunroll = 15*999, -- Max. unroll factor for loop ops in side traces      				default = 15
		callunroll = 3*999, -- Max. unroll factor for pseudo-recursive calls        				default = 3
		recunroll = 2*0, -- Min. unroll factor for true recursion                   				default = 2
		--sizemcode = X64 and 64 or 32, -- Size of each machine code area in KBytes (Windows: 64K)
		maxmcode = 512*16, -- Max. total size of all machine code areas in KBytes     default = 512
	}

	function system.GetJITOptions()
		return current
	end

	local sshh
	local last = {}

	function system.SetJITOption(option, num)
		if not current[option] then error("not a valid option", 2) end

		current[option] = num

		if last[option] ~= num then
			local options = {}

			if not sshh then
				logn("jit option ", option, " = ", num)
			end

			for k, v in pairs(current) do
				table.insert(options, k .. "=" .. v)
			end

			require("jit.opt").start(unpack(options))
			jit.flush()

			last[option] = num
		end
	end
	sshh = true
	for k,v in pairs(current) do
		system.SetJITOption(k, v)
	end
	sshh = nil
end

function system.Restart(run_on_launch)
	run_on_launch = run_on_launch or ""
	vfs.SetWorkingDirectory("../../../")

	if LINUX then
		if CLIENT then
			os.execute("./launch_client.sh " .. run_on_launch .. "&")
		else
			os.execute("./launch_server.sh " .. run_on_launch .. "&")
		end
	end

	if WINDOWS then
		if CLIENT then
			os.execute("start \"\" \"launch_client.bat\" \"" .. run_on_launch .. "\"")
		else
			os.execute("start \"\" \"launch_server.bat\" \"" .. run_on_launch .. "\"")
		end
	end

	system.ShutDown()
end

do
	-- this should be used for xpcall
	local suppress = false
	local last_openfunc = 0
	function system.OnError(msg, ...)
		logsection("lua error", true)
		msg = msg or "no error"
		if suppress then logn("error in system.OnError: ", msg, ...) for i = 3, 100 do local t = debug.getinfo(i) if t then table.print(t) else break end end return end
		suppress = true
		if LINUX and msg == "interrupted!\n" then return end

		if event.Call("LuaError", msg) == false then return end

		if msg:find("stack overflow") then
			logn(msg)
			table.print(debug.getinfo(3))
			return
		end

		logn("STACK TRACE:")
		logn("{")

		local base_folder = e.ROOT_FOLDER:gsub("%p", "%%%1")
		local data = {}

		for level = 3, 100 do
			local info = debug.getinfo(level)
			if info then
				if info.currentline >= 0 then
					local args = {}

					for arg = 1, info.nparams do
						local key, val = debug.getlocal(level, arg)
						if type(val) == "table" then
							val = tostring(val)
						else
							val = serializer.GetLibrary("luadata").ToString(val)
							if val and #val > 200 then
								val = val:sub(0, 200) .. "...."
							end
						end
						table.insert(args, ("%s = %s"):format(key, val))
					end

					info.arg_line = table.concat(args, ", ")

					info.name = info.name or "unknown"

					table.insert(data, info)
				end
			else
				break
			end
		end

		local function resize_field(tbl, field)
			local length = 0

			for _, info in pairs(tbl) do
				local str = tostring(info[field])
				if str then
					if #str > length then
						length = #str
					end
					info[field] = str
				end
			end

			for _, info in pairs(tbl) do
				local str = info[field]
				if str then
					local diff = length - #str

					if diff > 0 then
						info[field] = str .. (" "):rep(diff)
					end
				end
			end
		end

		table.insert(data, {currentline = "LINE:", source = "SOURCE:", name = "FUNCTION:", arg_line = " ARGUMENTS "})

		resize_field(data, "currentline")
		resize_field(data, "source")
		resize_field(data, "name")

		for _, info in npairs(data) do
			logf("  %s   %s   %s  (%s)\n", info.currentline, info.source, info.name, info.arg_line)
		end

		table.clear(data)

		logn("}")
		logn("LOCALS: ")
		logn("{")
		for _, param in pairs(debug.getparamsx(4)) do
			--if not param.key:find("(",nil,true) then
				local val

				if type(param.val) == "table" then
					val = tostring(param.val)
				elseif type(param.val) == "string" then
					val = param.val:sub(0, 10)

					if val ~= param.val then
						val = val .. " .. " .. utility.FormatFileSize(#param.val)
					end
				else
					val = serializer.GetLibrary("luadata").ToString(param.val)
				end

				table.insert(data, {key = param.key, value = val})
			--end
		end

		table.insert(data, {key = "KEY:", value = "VALUE:"})

		resize_field(data, "key")
		resize_field(data, "value")

		for _, info in npairs(data) do
			logf("  %s   %s\n", info.key, info.value)
		end
		logn("}")

		logn("ERROR:")
		logn("{")
		local source, _msg = msg:match("(.+): (.+)")

		if source then
			source = source:trim()

			local info

			-- this should be replaced with some sort of configuration
			-- gl.lua never shows anything useful but the level above does..
			if source:find("ffi_bind") then
				info = debug.getinfo(4)
			else
				info = debug.getinfo(2)
			end

			if last_openfunc < os.clock() then
				debug.openfunction(info.func, info.currentline)
				last_openfunc = os.clock() + 3
			else
				--logf("debug.openfunction(%q)\n", source)
			end

			logn("  ", source)
			logn("  ", _msg:trim())
		else
			logn(msg)
		end

		logn("}")
		logn("")

		suppress = false
		logsection("lua error", false)
	end

	function system.pcall(func, ...)
		return xpcall(func, system.OnError, ...)
	end
end

do -- environment

	if system.lua_environment_sockets then
		for key, val in pairs(system.lua_environment_sockets) do
			utility.SafeRemove(val)
		end
	end

	function system.StartLuaInstance(...)
		local args = {...}
		local arg_line = ""

		for k,v in pairs(args) do
			arg_line = arg_line .. serializer.GetLibrary("luadata").ToString(v)
			if #args ~= k then
				arg_line = arg_line .. ", "
			end
		end

		arg_line = arg_line:gsub('"', "'")

		local arg = ([[-e ARGS={%s}loadfile('%sinit.lua')()]]):format(arg_line, e.SRC_FOLDER .. "lua/")

		if WINDOWS then
			os.execute([[start "" "luajit" "]] .. arg .. [["]])
		elseif LINUX then
			os.execute([[luajit "]] .. arg .. [[" &]])
		end
	end

	system.lua_environment_sockets = {}

	function system.CreateLuaEnvironment(title, globals, id)
		check(globals, "table", "nil")
		id = id or title

		local socket = system.lua_environment_sockets[id] or NULL

		if socket:IsValid() then
			socket:Remove()
		end

		local socket = sockets.CreateServer()
		socket:Host("*", 0)

		system.lua_environment_sockets[id] = socket

		local arg = ""

		globals = globals or {}

		globals.PLATFORM = _G.PLATFORM or globals.PLATFORM
		globals.PORT = socket:GetPort()
		globals.CREATED_ENV = true
		globals.TITLE = tostring(title)

		for key, val in pairs(globals) do
			arg = arg .. key .. "=" .. serializer.GetLibrary("luadata").ToString(val) .. ";"
		end

		arg = arg:gsub([["]], [[']])
		arg = ([[-e %sloadfile('%sinit.lua')()]]):format(arg, e.SRC_FOLDER .. "lua/")

		if WINDOWS then
			os.execute([[start "" "luajit" "]] .. arg .. [["]])
		elseif LINUX then
			os.execute([[luajit "]] .. arg .. [[" &]])
		end

		local env = {}

		function env:OnReceive(line)
			local func, msg = loadstring(line)
			if func then
				local ok, msg = system.pcall(func)
				if not ok then
					logn("runtime error:", client, msg)
				end
			else
				logn("compile error:", client, msg)
			end
		end

		local queue = {}

		function env:Send(line)
			if not socket:HasClients() then
				table.insert(queue, line)
			else
				socket:Broadcast(line, true)
			end
		end

		function env:Remove()
			self:Send("os.exit()")
			socket:Remove()
		end

		socket.OnClientConnected = function(self, client)
			for k,v in pairs(queue) do
				socket:Broadcast(v, true)
			end

			table.clear(queue)

			return true
		end

		socket.OnReceive = function(self, line)
			env:OnReceive(line)
		end

		env.socket = socket

		return env
	end

	function system._CheckCreatedEnv()
		if CREATED_ENV then
			console.SetTitle(TITLE, "env")

			utility.SafeRemove(ENV_SOCKET)

			ENV_SOCKET = sockets.CreateClient()

			ENV_SOCKET:Connect("localhost", PORT)
			ENV_SOCKET:SetTimeout()

			ENV_SOCKET.OnReceive = function(self, line)
				local func, msg = loadstring(line)

				if func then
					local ok, msg = system.pcall(func)
					if not ok then
						logn("runtime error:", client, msg)
					end
				else
					logn("compile error:", client, msg)
				end

				event.Delay(0, function() event.Call("ConsoleEnvReceive", line) end)
			end
		end
	end

	function system.CreateConsole(title)
		if CONSOLE then return logn("tried to create a console in a console!!!") end
		local env = system.CreateLuaEnvironment(title, {CONSOLE = true})

		env:Send([[
			local __stop__

			local function clear()
				logn(("\n"):rep(1000)) -- lol
			end

			local function exit()
				__stop__ = true
				os.exit()
			end

			clear()

			ENV_SOCKET.OnClose = function() exit() end

			event.AddListener("ConsoleEnvReceive", TITLE, function()
				::again::

				local str = io.read()

				if str == "exit" then
					exit()
				elseif str == "clear" then
					clear()
				end

				if str and #str:trim() > 0 then
					ENV_SOCKET:Send(str, true)
				else
					goto again
				end
			end)

			event.AddListener("ShutDown", TITLE, function()
				ENV_SOCKET:Remove()
			end)
		]])

		event.AddListener("Print", title .. "_console_output", function(...)
			local line = tostring_args(...)
			env:Send(string.format("logn(%q)", line))
		end)


		function env:Remove()
			self:Send("os.exit()")
			utility.SafeRemove(self.socket)
			event.RemoveListener("Print", title .. "_console_output")
		end


		return env
	end
end



local sdl = desire("graphics.ffi.sdl") -- window manager
if sdl then
	local META = prototype.CreateTemplate("render_window")

	function META:OnRemove()
		event.RemoveListener("OnUpdate", self)

		sdl.DestroyWindow(self.__ptr)
		system.sdl_windows[self.sdl_window_id] = nil
	end

	local x = ffi.new("int[1]")
	local y = ffi.new("int[1]")

	function META:GetPosition()
		sdl.GetWindowPosition(self.__ptr, x, y)
		return Vec2(x[0], y[0])
	end

	function META:SetPosition(pos)
		sdl.SetWindowPosition(self.__ptr, pos:Unpack())
	end

	function META:GetSize()
		sdl.GetWindowSize(self.__ptr, x, y)
		return Vec2(x[0], y[0])
	end

	function META:SetSize(pos)
		sdl.SetWindowSize(self.__ptr, pos:Unpack())
	end

	function META:SetTitle(title)
		sdl.SetWindowTitle(self.__ptr, title)
	end

	local x, y = ffi.new(sdl and "int[1]" or "double[1]"), ffi.new(sdl and "int[1]" or "double[1]")

	if sdl.GetGlobalMouseState then
		function META:GetMousePosition()
			if self.global_mouse then
				sdl.GetGlobalMouseState(x, y)
				return Vec2(x[0], y[0])
			else
				sdl.GetGlobalMouseState(x, y)
				return Vec2(x[0], y[0]) - self:GetPosition()
			end
		end
	else
		function META:GetMousePosition()
			sdl.GetMouseState(x, y)
			return Vec2(x[0], y[0])
		end
	end

	function META:SetMousePosition(pos)
		sdl.WarpMouseInWindow(self.__ptr, pos:Unpack())
	end

	function META:HasFocus()
		return self.focused
	end

	function META:ShowCursor(b)
		sdl.ShowCursor(b and 1 or 0)
		self.cursor_visible = b
	end

	function META:IsCursorVisible()
		return self.cursor_visible
	end

	function META:SetMouseTrapped(b)
		self.mouse_trapped = b

		sdl.SetWindowGrab(self.__ptr, b and 1 or 0)
		self:ShowCursor(not b)
		sdl.SetRelativeMouseMode(b and 1 or 0)

		self.mouse_trapped_start = true
	end

	function META:GetMouseTrapped()
		return self.mouse_trapped
	end

	function META:GetMouseDelta()
		if self.mouse_trapped_start then
			self.mouse_trapped_start = nil
			return Vec2()
		end
		if self.mouse_trapped then
			sdl.GetRelativeMouseState(x, y)
			return Vec2(x[0], y[0])
		end
		return self.mouse_delta or Vec2()
	end

	function META:UpdateMouseDelta()
		local pos = self:GetMousePosition()

		if self.last_mpos then
			self.mouse_delta = (pos - self.last_mpos)
		end

		self.last_mpos = pos
	end

	function META:MakeContextCurrent()
		sdl.GL_MakeCurrent(self.__ptr, system.gl_context)
	end

	function META:SwapBuffers()
		sdl.GL_SwapWindow(self.__ptr)
	end

	function META:SwapInterval(b)
		sdl.GL_SetSwapInterval(b and 1 or 0)
	end

	function META:OnUpdate(delta)

	end

	function META:OnFocus(focused)

	end

	function META:OnShow()

	end

	function META:OnClose()

	end

	function META:OnCursorPosition(x, y)

	end

	function META:OnFileDrop(paths)
		print(paths, "dropped!")
	end

	function META:OnCharInput(str)

	end

	function META:OnKeyInput(key, press)

	end

	function META:OnKeyInputRepeat(key, press)

	end

	function META:OnMouseInput(key, press)

	end

	function META:OnMouseScroll(x, y)

	end

	function META:OnCursorEnter()

	end

	function META:OnRefresh()

	end

	function META:OnFramebufferResized(width, height)

	end

	function META:OnMove(x, y)

	end

	function META:OnIconify()

	end

	function META:OnResize(width, height)

	end

	function META:OnTextEditing(str)

	end

	function META:IsFocused()
		return self.focused
	end
	
	function META:SetClipboard(str)
		sdl.SetClipboardText(tostring(str))
	end

	function META:GetClipboard()
		return ffi.string(sdl.GetClipboardText())
	end

	do
		local freq = tonumber(sdl.GetPerformanceFrequency())
		local start_time = sdl.GetPerformanceCounter()

		function system.GetTime()
			local time = sdl.GetPerformanceCounter()

			time = time - start_time

			return tonumber(time) / freq
		end
	end

	do

		local enums = {
			arrow = sdl.e.SDL_SYSTEM_CURSOR_ARROW,
			ibeam = sdl.e.SDL_SYSTEM_CURSOR_IBEAM,
			wait = sdl.e.SDL_SYSTEM_CURSOR_WAIT,
			crosshair = sdl.e.SDL_SYSTEM_CURSOR_CROSSHAIR,
			waitarrow = sdl.e.SDL_SYSTEM_CURSOR_WAITARROW,
			sizenwse = sdl.e.SDL_SYSTEM_CURSOR_SIZENWSE,
			sizenesw = sdl.e.SDL_SYSTEM_CURSOR_SIZENESW,
			sizewe = sdl.e.SDL_SYSTEM_CURSOR_SIZEWE,
			sizens = sdl.e.SDL_SYSTEM_CURSOR_SIZENS,
			sizeall = sdl.e.SDL_SYSTEM_CURSOR_SIZEALL,
			no = sdl.e.SDL_SYSTEM_CURSOR_NO,
			hand = sdl.e.SDL_SYSTEM_CURSOR_HAND,
		}

		local current
		local last
		local cache = {}

		function META:SetCursor(id)
			id = id or "arrow"

			cache[id] = cache[id] or sdl.CreateSystemCursor(enums[id] or enums.arrow)
			--if last ~= id then
				current = id
				sdl.SetCursor(cache[id])
			--	last = id
			--end
		end

		function META:GetCursor()
			return current
		end

	end

	do
		local cache = {}

		for k,v in pairs(_G) do
			if type(k) == "string" and k:sub(1, 3)  == "GL_" then
				cache[k] = v
			end
		end

		function META:IsExtensionSupported(str)
			if cache[str] == nil then
				cache[str] = sdl.GL_ExtensionSupported(str) == 1
			end
			return cache[str]
		end
	end

	prototype.Register(META)

	local flags_to_enums = {
		fullscreen = sdl.e.SDL_WINDOW_FULLSCREEN, -- fullscreen window
		fullscreen_desktop = sdl.e.SDL_WINDOW_FULLSCREEN_DESKTOP, -- fullscreen window at the current desktop resolution
--		opengl = sdl.e.SDL_WINDOW_OPENGL, -- window usable with OpenGL context
		hidden = sdl.e.SDL_WINDOW_HIDDEN, -- window is not visible
		borderless = sdl.e.SDL_WINDOW_BORDERLESS, -- no window decoration
		resizable = sdl.e.SDL_WINDOW_RESIZABLE, -- window can be resized
		minimized = sdl.e.SDL_WINDOW_MINIMIZED, -- window is minimized
		maximized = sdl.e.SDL_WINDOW_MAXIMIZED, -- window is maximized
		input_grabbed = sdl.e.SDL_WINDOW_INPUT_GRABBED, -- window has grabbed input focus
		allow_highdpi = sdl.e.SDL_WINDOW_ALLOW_HIGHDPI, -- window should be created in high-DPI mode if supported (>= SDL 2.0.1)
	}

	function system.CreateWindow(width, height, title, flags, reset_flags)
		width = width or 800
		height = height or 600
		title = title or ""

		if not system.gl_context then
			sdl.Init(sdl.e.SDL_INIT_VIDEO)
			sdl.video_init = true

			sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_MAJOR_VERSION, 3)
			sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_MINOR_VERSION, 3)
			sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_PROFILE_MASK, sdl.e.SDL_GL_CONTEXT_PROFILE_CORE)

			--sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_FLAGS, sdl.e.SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG)
			--sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_PROFILE_MASK, sdl.e.SDL_GL_CONTEXT_PROFILE_COMPATIBILITY)
		end

		local bit_flags = bit.bor(sdl.e.SDL_WINDOW_OPENGL, sdl.e.SDL_WINDOW_SHOWN, sdl.e.SDL_WINDOW_RESIZABLE)

		if flags then
			bit_flags = sdl.e.SDL_WINDOW_OPENGL

			for k,v in pairs(flags) do
				bit_flags = bit.bor(bit_flags, flags_to_enums[v])
			end
		end

		local ptr = sdl.CreateWindow(
			title,
			sdl.e.SDL_WINDOWPOS_CENTERED,
			sdl.e.SDL_WINDOWPOS_CENTERED,
			width,
			height,
			bit_flags
		)

		if ptr == nil then
			error("sdl.CreateWindow failed: " .. ffi.string(sdl.GetError()), 2)
		end

		if not system.gl_context then
			local context = sdl.GL_CreateContext(ptr)

			if context == nil then
				error("sdl.GL_CreateContext failed: " .. ffi.string(sdl.GetError()), 2)
			end
			sdl.GL_MakeCurrent(ptr, context)

			llog("sdl version: %s", ffi.string(sdl.GetRevision()))

			local gl = require("graphics.ffi.opengl")

			-- this needs to be initialized once after a context has been created
			gl.GetProcAddress = sdl.GL_GetProcAddress

			gl.Initialize()

			if not gl.GetString then
				error("gl.Initialize failed! (gl.GetString not found)", 2)
			end

			system.gl_context = context
		end

		local self = prototype.CreateObject(META)

		self.last_mpos = Vec2()
		self.mouse_delta = Vec2()
		self.__ptr = ptr

		system.sdl_windows = system.sdl_windows or {}
		local id = sdl.GetWindowID(ptr)
		self.sdl_window_id = id
		system.sdl_windows[id] = self

		local event_name_translate = {}
		local key_translate = {
			left_ctrl = "left_control",
			["keypad_-"] = "kp_subtract",
			["keypad_+"] = "kp_add",
			["return"] = "enter",
		}
		for i = 1, 9 do
			key_translate["keypad_" .. i] = "kp_" .. i
		end

		local function call(self, name, ...)
			if not self then print(name, ...) return end

			if not event_name_translate[name] then
				event_name_translate[name] = name:gsub("^On", "Window")
			end

			local b

			if self[name] then
				if self[name](self, ...) ~= false then
					b = event.Call(event_name_translate[name], self, ...)
				end
			end

			return b
		end

		local event = ffi.new("SDL_Event")
		local mbutton_translate = {}
		for i = 1, 8 do mbutton_translate[i] = "button_" .. i end
		mbutton_translate[3] = "button_2"
		mbutton_translate[2] = "button_3"

		local suppress_char_input = false

		_G.event.AddListener("Update", self, function(dt)
			if not self:IsValid() or not sdl.video_init then
				sdl.PollEvent(event) -- this needs to be done or windows thinks the application froze..
				return
			end

			self.mouse_delta:Zero()
			self:UpdateMouseDelta()
			self:OnUpdate(dt)

			while sdl.PollEvent(event) ~= 0 do
				local window
				if event.window and event.window.windowID then
					window = system.sdl_windows[event.window.windowID]
				end

				if event.type == sdl.e.SDL_WINDOWEVENT and window then
					local case = event.window.event

					if case == sdl.e.SDL_WINDOWEVENT_SHOWN then
						call(window, "OnShow")
					elseif case == sdl.e.SDL_WINDOWEVENT_HIDDEN then
						call(window, "OnHide")
					elseif case == sdl.e.SDL_WINDOWEVENT_EXPOSED then
						call(window, "OnFramebufferResized", self:GetSize():Unpack())
					elseif case == sdl.e.SDL_WINDOWEVENT_SIZE_CHANGED then
						call(window, "OnFramebufferResized", event.window.data1, event.window.data2)
					elseif case == sdl.e.SDL_WINDOWEVENT_MOVED then
						call(window, "OnMove", event.window.data1, event.window.data2)
					elseif case == sdl.e.SDL_WINDOWEVENT_RESIZED then
						call(window, "OnResize", event.window.data1, event.window.data2)
						call(window, "OnFramebufferResized", event.window.data1, event.window.data2)
					elseif case == sdl.e.SDL_WINDOWEVENT_MINIMIZED then
						call(window, "OnMinimize")
					elseif case == sdl.e.SDL_WINDOWEVENT_MAXIMIZED then
						call(window, "OnResize", self:GetSize():Unpack())
						call(window, "OnFramebufferResized", self:GetSize():Unpack())
					elseif case == sdl.e.SDL_WINDOWEVENT_RESTORED then
						call(window, "OnRefresh")
					elseif case == sdl.e.SDL_WINDOWEVENT_ENTER then
						call(window, "OnCursorEnter", false)
					elseif case == sdl.e.SDL_WINDOWEVENT_LEAVE then
						call(window, "OnCursorEnter", true)
					elseif case == sdl.e.SDL_WINDOWEVENT_FOCUS_GAINED then
						call(window, "OnFocus", true)
						window.focused = true
					elseif case == sdl.e.SDL_WINDOWEVENT_FOCUS_LOST then
						call(window, "OnFocus", false)
						window.focused = false
					elseif case == sdl.e.SDL_WINDOWEVENT_CLOSE then
						call(window, "OnClose")
					else print("unknown window event", case) end
				elseif event.type == sdl.e.SDL_KEYDOWN or event.type == sdl.e.SDL_KEYUP then
					local window = system.sdl_windows[event.key.windowID]
					local key = ffi.string(sdl.GetKeyName(event.key.keysym.sym)):lower():gsub(" ", "_")

					key = key_translate[key] or key

					if event.key["repeat"] == 0 then
						if call(
							window,
							"OnKeyInput",
							key,
							event.type == sdl.e.SDL_KEYDOWN,

							event.key.state,
							event.key.keysym.mod,
							ffi.string(sdl.GetScancodeName(event.key.keysym.scancode)):lower(),
							event.key.keysym
						) == false then suppress_char_input = true return end
					end

					call(
						window,
						"OnKeyInputRepeat",
						key,
						event.type == sdl.e.SDL_KEYDOWN,

						event.key.state,
						event.key.keysym.mod,
						ffi.string(sdl.GetScancodeName(event.key.keysym.scancode)):lower(),
						event.key.keysym
					)
				elseif event.type == sdl.e.SDL_TEXTINPUT then
					if suppress_char_input then suppress_char_input = false return end
					local window = system.sdl_windows[event.edit.windowID]

					call(window, "OnCharInput", ffi.string(event.edit.text), event.edit.start, event.edit.length)
				elseif event.type == sdl.e.SDL_TEXTEDITING then
					local window = system.sdl_windows[event.text.windowID]

					call(window, "OnTextEditing", ffi.string(event.text.text))
				elseif event.type == sdl.e.SDL_MOUSEMOTION then
					local window = system.sdl_windows[event.motion.windowID]
					if window then
						self.mouse_delta.x = event.motion.xrel
						self.mouse_delta.y = event.motion.yrel
						call(window, "OnCursorPosition", event.motion.x, event.motion.y, event.motion.xrel, event.motion.yrel, event.motion.state, event.motion.which)
					end
				elseif event.type == sdl.e.SDL_MOUSEBUTTONDOWN or event.type == sdl.e.SDL_MOUSEBUTTONUP then
					local window = system.sdl_windows[event.button.windowID]
					call(window, "OnMouseInput", mbutton_translate[event.button.button], event.type == sdl.e.SDL_MOUSEBUTTONDOWN, event.button.x, event.button.y)
				elseif event.type == sdl.e.SDL_MOUSEWHEEL then
					local window = system.sdl_windows[event.button.windowID]
					call(window, "OnMouseScroll", event.wheel.x, event.wheel.y, event.wheel.which)
				elseif event.type == sdl.e.SDL_DROPFILE then
					for _, window in pairs(system.sdl_windows) do
						call(window, "OnFileDrop", ffi.string(event.drop.file))
					end
				elseif event.type == sdl.e.SDL_QUIT then
					system.ShutDown()
				else print("unknown event", event.type) end
			end
		end, {on_error = function(...) system.OnError(...) end})

		if not system.current_window:IsValid() then
			system.current_window = self
		end

		return self
	end
end

return system
