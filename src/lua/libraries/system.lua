local system = _G.system or {}

local ffi = require("ffi")

do -- console title
	if not system.SetConsoleTitleRaw then
		local set_title

		if WINDOWS then
			ffi.cdef("int SetConsoleTitleA(const char* blah);")

			set_title = function(str)
				return ffi.C.SetConsoleTitleA(str)
			end
		end

		if not CURSES then
			set_title = function()
				-- hmmm
			end
		elseif LINUX then
			local iowrite = _OLD_G.io.write
			set_title = function(str)
				return iowrite and iowrite('\27]0;', str, '\7') or nil
			end
		end

		system.SetConsoleTitleRaw = set_title
	end

	local titles = {}
	local str = ""
	local last_title

	local lasttbl = {}

	function system.SetConsoleTitle(title, id)
		local time = system.GetElapsedTime()

		if not lasttbl[id] or lasttbl[id] < time then
			if id then
				titles[id] = title
				str = "| "
				for _, v in pairs(titles) do
					str = str ..  v .. " | "
				end
				if str ~= last_title then
					system.SetConsoleTitleRaw(str)
				end
			else
				str = title
				if str ~= last_title then
					system.SetConsoleTitleRaw(title)
				end
			end
			last_title = str
			lasttbl[id] = system.GetElapsedTime() + 0.05
		end
	end

	function system.GetConsoleTitle()
		return str
	end
end

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
	local show = pvars.Setup("system_fps_show", true, "show fps in titlebar")
	local total = 0
	local count = 0

	function system.UpdateTitlebarFPS(dt)
		if not show:Get() then return end

		total = total + dt
		count = count + 1

		if wait(1) then
			system.SetConsoleTitle(("FPS: %i"):format(1/(total / count)), "fps")
			system.SetConsoleTitle(("GARBAGE: %s"):format(utility.FormatFileSize(collectgarbage("count") * 1024)), "garbage")

			if GRAPHICS then
				window.SetTitle(system.GetConsoleTitle())
			end

			total = 0
			count = 0
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
			commands.RunString(tostring(arg))
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
			for _, cmd in ipairs(attempts) do
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
			for _, v in pairs(editors) do

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

function system.Restart(run_on_launch)
	run_on_launch = run_on_launch or ""
	vfs.SetWorkingDirectory("../../../")

	if LINUX then
		if CLIENT then
			os.execute("./client.bash " .. run_on_launch .. "&")
		else
			os.execute("./server.bash " .. run_on_launch .. "&")
		end
	end

	if WINDOWS then
		if CLIENT then
			os.execute("start \"\" \"client.bat\" \"" .. run_on_launch .. "\"")
		else
			os.execute("start \"\" \"server.bat\" \"" .. run_on_launch .. "\"")
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
		if suppress then logn("error in system.OnError: ", msg, ...) logn(debug.traceback())  return end
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

			if last_openfunc < system.GetElapsedTime() then
				debug.openfunction(info.func, info.currentline)
				last_openfunc = system.GetElapsedTime() + 3
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
		for _, val in pairs(system.lua_environment_sockets) do
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
			for _, v in pairs(queue) do
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
			system.SetConsoleTitle(TITLE, "env")

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

local sdl = desire("libSDL2") -- window manager

if sdl then
	local META = prototype.CreateTemplate("render_window")

	function META:OnRemove()
		event.RemoveListener("OnUpdate", self)

		sdl.DestroyWindow(self.sdl_wnd)
		system.sdl_windows[self.sdl_window_id] = nil
	end

	function META:GetPosition()
		return self.position
	end

	function META:SetPosition(pos)
		sdl.SetWindowPosition(self.sdl_wnd, pos:Unpack())
	end

	function META:GetSize()
		return self.size
	end

	function META:SetSize(pos)
		sdl.SetWindowSize(self.sdl_wnd, pos:Unpack())
	end

	function META:Maximize()
		sdl.MaximizeWindow(self.sdl_wnd)
	end

	function META:Minimize()
		sdl.MinimizeWindow(self.sdl_wnd)
	end

	function META:Restore()
		sdl.RestoreWindow(self.sdl_wnd)
	end

	function META:SetTitle(title)
		sdl.SetWindowTitle(self.sdl_wnd, tostring(title))
	end

	if sdl.GetGlobalMouseState then
		local x, y = ffi.new("int[1]"), ffi.new("int[1]")
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
		local x, y = ffi.new("int[1]"), ffi.new("int[1]")
		function META:GetMousePosition()
			sdl.GetMouseState(x, y)
			return Vec2(x[0], y[0])
		end
	end

	function META:SetMousePosition(pos)
		sdl.WarpMouseInWindow(self.sdl_wnd, pos:Unpack())
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

		sdl.SetWindowGrab(self.sdl_wnd, b and 1 or 0)
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
			local x, y = ffi.new("int[1]"), ffi.new("int[1]")
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
		sdl.GL_MakeCurrent(self.sdl_wnd, system.gl_context)
	end

	local gl = require("libopengl")

	function META:SwapBuffers()
		--gl.Flush()
		sdl.GL_SwapWindow(self.sdl_wnd)
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
			arrow = sdl.e.SYSTEM_CURSOR_ARROW,
			ibeam = sdl.e.SYSTEM_CURSOR_IBEAM,
			wait = sdl.e.SYSTEM_CURSOR_WAIT,
			crosshair = sdl.e.SYSTEM_CURSOR_CROSSHAIR,
			waitarrow = sdl.e.SYSTEM_CURSOR_WAITARROW,
			sizenwse = sdl.e.SYSTEM_CURSOR_SIZENWSE,
			sizenesw = sdl.e.SYSTEM_CURSOR_SIZENESW,
			sizewe = sdl.e.SYSTEM_CURSOR_SIZEWE,
			sizens = sdl.e.SYSTEM_CURSOR_SIZENS,
			sizeall = sdl.e.SYSTEM_CURSOR_SIZEALL,
			no = sdl.e.SYSTEM_CURSOR_NO,
			hand = sdl.e.SYSTEM_CURSOR_HAND,
		}

		local current
		local last
		local cache = {}

		function META:SetCursor(id)
			id = id or "arrow"

			cache[id] = cache[id] or sdl.CreateSystemCursor(enums[id] or enums.arrow)
			if last ~= id then
				current = id
				sdl.SetCursor(cache[id])
				last = id
			end
		end

		function META:GetCursor()
			return current
		end

	end

	do
		local cache = {}

		for k,v in pairs(_G) do
			if type(k) == "string" and type(v) == "boolean" and k:sub(1, 3)  == "GL_" then
				cache[k] = v
			end
		end

		function system.IsOpenGLExtensionSupported(str)
			if cache[str] == nil then
				cache[str] = sdl.GL_ExtensionSupported(str) == 1
			end
			return cache[str]
		end
	end

	prototype.Register(META)

	local flags_to_enums = {}

	for k,v in pairs(sdl.e) do
		local friendly = k:match("WINDOW_(.+)")
		if friendly then
			friendly = friendly:lower()
			flags_to_enums[friendly] = v
		end
	end

	function system.CreateWindow(width, height, title, flags)
		title = title or ""

		if not sdl.video_init then
			sdl.Init(sdl.e.INIT_VIDEO)
			sdl.video_init = true
		end

		flags = flags or {"shown", "resizable"}

		if OPENGL then
			table.insert(flags, "opengl")
			sdl.GL_SetAttribute(sdl.e.GL_DEPTH_SIZE, 0)
			--sdl.GL_SetAttribute(sdl.e.GL_DOUBLEBUFFER, 0)
		end

		local bit_flags = 0

		for _, v in pairs(flags) do
			bit_flags = bit.bor(bit_flags, flags_to_enums[v])
		end

		if not width or not height then
			local info = ffi.new("struct SDL_DisplayMode[1]")
			sdl.GetCurrentDisplayMode(0, info)
			width = width or info[0].w / 2
			height = height or info[0].h / 2
		end

		local sdl_wnd = sdl.CreateWindow(title, sdl.e.WINDOWPOS_CENTERED, sdl.e.WINDOWPOS_CENTERED, width, height, bit_flags)

		if sdl_wnd == nil then
			error("sdl.CreateWindow failed: " .. ffi.string(sdl.GetError()), 2)
		end

		if OPENGL then
			if not system.gl_context then
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_MAJOR_VERSION, 3)
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_MINOR_VERSION, 3)
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_PROFILE_MASK, sdl.e.GL_CONTEXT_PROFILE_CORE)

				--sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_FLAGS, sdl.e.GL_CONTEXT_ROBUST_ACCESS_FLAG)
				--sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_PROFILE_MASK, sdl.e.GL_CONTEXT_PROFILE_COMPATIBILITY)

				local context = sdl.GL_CreateContext(sdl_wnd)

				if context == nil then
					error("sdl.GL_CreateContext failed: " .. ffi.string(sdl.GetError()), 2)
				end

				sdl.GL_MakeCurrent(sdl_wnd, context)

				local gl = require("libopengl")

				-- this needs to be initialized once after a context has been created
				gl.GetProcAddress = sdl.GL_GetProcAddress

				gl.Initialize()

				if NULL_OPENGL then
					for k,v in pairs(gl) do
						if type(v) == "cdata" then
							gl[k] = function() return 0 end
						end
					end

					function gl.CheckNamedFramebufferStatus()
						return 36053
					end

					function gl.GetString()
						return nil
					end
				end

				system.gl_context = context
			end
		end

		llog("sdl version: %s", ffi.string(sdl.GetRevision()))

		local self = META:CreateObject()


		local x, y = ffi.new("int[1]"), ffi.new("int[1]")
		sdl.GetWindowPosition(sdl_wnd, x, y)
		self.position = Vec2(x[0], y[0])

		sdl.GetWindowSize(sdl_wnd, x, y)
		self.size = Vec2(x[0], y[0])

		self.last_mpos = Vec2()
		self.mouse_delta = Vec2()
		self.sdl_wnd = sdl_wnd

		system.sdl_windows = system.sdl_windows or {}
		self.sdl_window_id = sdl.GetWindowID(self.sdl_wnd)
		system.sdl_windows[self.sdl_window_id] = self

		local event_name_translate = {}
		local key_translate = {
			["left_ctrl"] = "left_control",
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

		local event = ffi.new("union SDL_Event")
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

				if event.type == sdl.e.WINDOWEVENT and window then
					local case = event.window.event

					if case == sdl.e.WINDOWEVENT_SHOWN then
						call(window, "OnShow")

					elseif case == sdl.e.WINDOWEVENT_HIDDEN then
						call(window, "OnHide")

					elseif case == sdl.e.WINDOWEVENT_MOVED then
						window.position.x = event.window.data1
						window.position.y = event.window.data2
						call(window, "OnMove", window.position.x, window.position.y)

					elseif case == sdl.e.WINDOWEVENT_RESIZED then
						window.size.x = event.window.data1
						window.size.y = event.window.data2
						call(window, "OnResize", window.size.x, window.size.y)

					elseif case == sdl.e.WINDOWEVENT_MINIMIZED then
						call(window, "OnMinimize")

					elseif case == sdl.e.WINDOWEVENT_MAXIMIZED then
						call(window, "OnMaximize")

					elseif case == sdl.e.WINDOWEVENT_RESTORED then
						call(window, "OnRefresh")

					elseif case == sdl.e.WINDOWEVENT_ENTER then
						call(window, "OnCursorEnter", false)

					elseif case == sdl.e.WINDOWEVENT_LEAVE then
						call(window, "OnCursorEnter", true)

					elseif case == sdl.e.WINDOWEVENT_FOCUS_GAINED then
						call(window, "OnFocus", true)
						window.focused = true

					elseif case == sdl.e.WINDOWEVENT_FOCUS_LOST then
						call(window, "OnFocus", false)
						window.focused = false

					elseif case == sdl.e.WINDOWEVENT_CLOSE then
						call(window, "OnClose")

					end
				elseif event.type == sdl.e.KEYDOWN or event.type == sdl.e.KEYUP then
					local window = system.sdl_windows[event.key.windowID]
					local key = ffi.string(sdl.GetKeyName(event.key.keysym.sym)):lower():gsub(" ", "_")

					key = key_translate[key] or key

					if event.key["repeat"] == 0 then
						if call(
							window,
							"OnKeyInput",
							key,
							event.type == sdl.e.KEYDOWN,

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
						event.type == sdl.e.KEYDOWN,

						event.key.state,
						event.key.keysym.mod,
						ffi.string(sdl.GetScancodeName(event.key.keysym.scancode)):lower(),
						event.key.keysym
					)
				elseif event.type == sdl.e.TEXTINPUT then
					if suppress_char_input then suppress_char_input = false return end
					local window = system.sdl_windows[event.edit.windowID]

					call(window, "OnCharInput", ffi.string(event.edit.text), event.edit.start, event.edit.length)
				elseif event.type == sdl.e.TEXTEDITING then
					local window = system.sdl_windows[event.text.windowID]

					call(window, "OnTextEditing", ffi.string(event.text.text))
				elseif event.type == sdl.e.MOUSEMOTION then
					local window = system.sdl_windows[event.motion.windowID]
					if window then
						self.mouse_delta.x = event.motion.xrel
						self.mouse_delta.y = event.motion.yrel
						call(window, "OnCursorPosition", event.motion.x, event.motion.y, event.motion.xrel, event.motion.yrel, event.motion.state, event.motion.which)
					end
				elseif event.type == sdl.e.MOUSEBUTTONDOWN or event.type == sdl.e.MOUSEBUTTONUP then
					local window = system.sdl_windows[event.button.windowID]
					call(window, "OnMouseInput", mbutton_translate[event.button.button], event.type == sdl.e.MOUSEBUTTONDOWN, event.button.x, event.button.y)
				elseif event.type == sdl.e.MOUSEWHEEL then
					local window = system.sdl_windows[event.button.windowID]
					call(window, "OnMouseScroll", event.wheel.x, event.wheel.y, event.wheel.which)
				elseif event.type == sdl.e.DROPFILE then
					for _, window in pairs(system.sdl_windows) do
						call(window, "OnFileDrop", ffi.string(event.drop.file))
					end
				elseif event.type == sdl.e.QUIT then
					system.ShutDown()
				else print("unknown event", event.type) end
			end
		end)

		if not system.current_window:IsValid() then
			system.current_window = self
		end

		return self
	end
end

return system
