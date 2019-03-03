local system = ... or _G.system
local ffi = require("ffi")

function system.LastOSError(num)
	num = num or ffi.errno()
	local err = ffi.string(ffi.C.strerror(num))
	return err == "" and tostring(num) or err
end

do
	local attempts = {
		"sensible-browser",
		"xdg-open",
		"kde-open",
		"gnome-open",
	}

	function system.OpenURL(url)
		for _, cmd in ipairs(attempts) do
			if os.execute(cmd .. " " .. url) then
				return
			end
		end

		wlog("don't know how to open an url (tried: %s)", table.concat(attempts, ", "), 2)
	end
end

do
	ffi.cdef("void usleep(unsigned int ns);")
	function system.Sleep(ms)
		ffi.C.usleep(ms*1000)
	end
end

if ffi.os == "OSX" then
	ffi.cdef([[
		struct mach_timebase_info {
			uint32_t	numer;
			uint32_t	denom;
		};
		int mach_timebase_info(struct mach_timebase_info *info);
		uint64_t mach_absolute_time(void);
	]])

	local tb = ffi.new("struct mach_timebase_info")
	ffi.C.mach_timebase_info(tb)
	local orwl_timebase = tb.numer
	local orwl_timebase = tb.denom
	local orwl_timestart = ffi.C.mach_absolute_time()

	function system.GetTime()
		local diff = (ffi.C.mach_absolute_time() - orwl_timestart) * orwl_timebase
		diff = tonumber(diff) / 1000000000
		return diff
	end
else
	ffi.cdef([[
		struct timespec {
			long int tv_sec;
			long tv_nsec;
		};
		int clock_gettime(int clock_id, struct timespec *tp);
	]])

	local ts = ffi.new("struct timespec")
	local enum = 1
	local func = ffi.C.clock_gettime

	function system.GetTime()
		func(enum, ts)
		return tonumber(ts.tv_sec) + tonumber(ts.tv_nsec) * 0.000000001
	end
end

do
	local iowrite = _OLD_G.io.write

	function system.SetConsoleTitleRaw(str)
		if repl and repl.SetConsoleTitle then
			return repl.SetConsoleTitle(str)
		end
		return iowrite and iowrite('\27]0;', str, '\7') or nil
	end
end

do
	local text_editors = {
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

	function system.FindFirstTextEditor(os_execute, with_args)
		for _, v in pairs(text_editors) do

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

function system._OSCommandExists(cmd)
	if io.popen("command -v " .. cmd):read("*all") ~= "" then
		return true
	end
end