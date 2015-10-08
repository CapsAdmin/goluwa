local system = _G.system or {}

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

local function not_implemented() debug.trace() logn("this function is not yet implemented!") end

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

do -- cursor
	local set = not_implemented
	local get = not_implemented

	if WINDOWS then
		require("winapi.cursor")
		local winapi = require("winapi")

		local lib = ffi.load("user32.dll")
		local cache = {}

		local enums = {
			arrow = 32512,
			ibeam = 32513,
			wait = 32514,
			cross = 32515,
			uparrow = 32516,
			size = 32640,
			icon = 32641,
			sizenwse = 32642,
			sizenesw = 32643,
			sizewe = 32644,
			sizens = 32645,
			sizeall = 32646,
			no = 32648,
			hand = 32649,
			appstarting = 32650,
			help = 32651,
			contexthelp = 30977, -- context sensitive help
			magnify = 30978, -- print preview zoom
			smallarrows = 30979, -- splitter
			hsplitbar = 30980, -- splitter
			vsplitbar = 30981, -- splitter
			nodropcrsr = 30982, -- no drop cursor
			tracknwse = 30983, -- tracker
			tracknesw = 30984, -- tracker
			trackns = 30985, -- tracker
			trackwe = 30986, -- tracker
			track4way = 30987, -- tracker
			move4way = 30988, -- resize bar (server only)
			mouse_pan_nw = 30998, -- pan east
			mouse_pan_n = 30999, -- pan northeast
			mouse_pan_ne = 31000, -- pan north
			mouse_pan_w = 31001, -- pan northwest
			mouse_pan_hv = 31002, -- pan both axis
			mouse_pan_e = 31003, -- pan west
			mouse_pan_sw = 31004, -- pan south-west
			mouse_pan_s = 31005, -- pan south
			mouse_pan_se = 31006, -- pan south-east
			mouse_pan_horz = 31007, -- pan x-axis
			mouse_pan_vert = 31008, -- pan y-axis

		}

		local current

		local last

		set = function(id)
			id = id or "arrow"

			cache[id] = cache[id] or winapi.LoadCursor(enums[id] or enums.arrow)

			--if last ~= id then
				current = id
				winapi.SetCursor(cache[id])
			--	last = id
			--end
		end

		get = function()
			return current
		end
	else
		get = function() end
		set = get
	end

	system.SetCursor = set
	system.GetCursor = get

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

do -- fonts
	local get = not_implemented

	if WINDOWS then
		--[==[ffi.cdef[[

		typedef struct LOGFONT {
		  long  lfHeight;
		  long lfWidth;
		  long  lfEscapement;
		  long  lfOrientation;
		  long  lfWeight;
		  char  lfItalic;
		  char  lfUnderline;
		  char  lfStrikeOut;
		  char  lfCharSet;
		  char  lfOutPrecision;
		  char  lfClipPrecision;
		  char  lfQuality;
		  char  lfPitchAndFamily;
		  char lfFaceName[LF_FACESIZE];
		} LOGFONT;


		int EnumFontFamiliesEx(void *, LOGFONT *)
		]]]==]

		get = function()

		end
	elseif LINUX then
		ffi.cdef([[
			typedef struct {} Display;
			Display* XOpenDisplay(const char*);
			void XCloseDisplay(Display*);
			char** XListFonts(Display* display, const char* pattern, int max_names, int* actual_names);
		]])

		local X11 = ffi.load("X11")

		if X11 then
			local display = X11.XOpenDisplay(nil)

			if display ~= nil then
				local count = ffi.new("int[1]")
				local names = X11.XListFonts(display, "*", 65535, count)
				count = count[0]

				for i = 1, count do
					local name = ffi.string(names[i - 1])
				end

				X11.XCloseDisplay(display)
			else
				warning("NO X DISPLAY FOUND BUT WHATEVER")
				--return
			end
		end
	end

	system.GetInstalledFonts = get

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

do -- clipboard
	local set = not_implemented
	local get = not_implemented

	system.SetClipboard = set
	system.GetClipboard = get
end

function system.DebugJIT(b)
	if b then
		jit.v.on(R"%DATA%/logs/jit_verbose_output.txt")
	else
		jit.v.off(R"%DATA%/logs/jit_verbose_output.txt")
	end
end

do
	local current = {
		maxtrace = 1000*60, -- Max. number of traces in the cache						default = 1000		min = 1	 max = 65535
		maxrecord = 4000*5, -- Max. number of recorded IR instructions                default = 4000
		maxirconst = 500*5, -- Max. number of IR constants of a trace                default = 500
		maxside = 100, -- Max. number of side traces of a root trace                default = 100
		maxsnap = 500, -- Max. number of snapshots for a trace                     default = 500
		minstitch = 0, -- Min. # of IR ins for a stitched trace.					default = 0
		hotloop = 56*100, -- Number of iterations to detect a hot loop or hot call     default = 56
		hotexit = 10, -- Number of taken exits to start a side trace                 default = 10
		tryside = 4, -- Number of attempts to compile a side trace                  default = 4
		instunroll = 4*999, -- Max. unroll factor for instable loops                  default = 4
		loopunroll = 15*999, -- Max. unroll factor for loop ops in side traces         default = 15
		callunroll = 3*999, -- Max. unroll factor for pseudo-recursive calls          default = 3
		recunroll = 2*0, -- Min. unroll factor for true recursion                     default = 2
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

return system
