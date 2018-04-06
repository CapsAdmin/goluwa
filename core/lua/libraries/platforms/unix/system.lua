local system = ... or _G.system
local ffi = require("ffi")

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

do
	local posix = require("syscall")

	local ts = posix.t.timespec()

	function system.GetTime()
		posix.clock_gettime("MONOTONIC", ts)
		return tonumber(ts.tv_sec * 1000000000 + ts.tv_nsec) * 1e-9
	end
end

do
	if CURSES then
		local iowrite = _OLD_G.io.write

		function system.SetConsoleTitleRaw(str)
			return iowrite and iowrite('\27]0;', str, '\7') or nil
		end
	elseif CLI then
		local last
		function system.SetConsoleTitleRaw(str)
			if str ~= last then
				for i, v in ipairs(str:split("|")) do
					local s = v:trim()
					if s ~= "" then
						logn(s)
					end
				end
				last = str
			end
		end
	else
		function system.SetConsoleTitleRaw(str)

		end
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

do
	function system.SetSharedLibraryPath(path)
		os.setenv("LD_LIBRARY_PATH", path)
	end

	function system.GetSharedLibraryPath()
		return os.getenv("LD_LIBRARY_PATH") or ""
	end
end

function system._OSCommandExists(cmd)
	if io.popen("command -v " .. cmd):read("*all") ~= "" then
		return true
	end
end