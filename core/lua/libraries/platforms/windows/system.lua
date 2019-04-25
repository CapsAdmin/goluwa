local system = ... or _G.system
local ffi = require("ffi")

do
	local FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000
	local FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200
	local flags = bit.bor(FORMAT_MESSAGE_IGNORE_INSERTS, FORMAT_MESSAGE_FROM_SYSTEM)

	ffi.cdef("int GetLastError();")

	function system.LastOSError(num)
		num = num or ffi.C.GetLastError()
		local buffer = ffi.new("char[512]")
		ffi.C.FormatMessageA(flags, nil, num, 0, buffer, ffi.sizeof(buffer), nil)
		return string.sub(ffi.string(buffer), 1, -3).." ("..num..")" -- remove last crlf
	end
end

function system.OpenURL(url)
	os.execute(([[explorer "%s"]]):format(url))
end

ffi.cdef("void Sleep(uint32_t);")
function system.Sleep(ms)
	ffi.C.Sleep(ms * 1000)
end

do
	ffi.cdef([[
		int QueryPerformanceFrequency(int64_t *lpFrequency);
		int QueryPerformanceCounter(int64_t *lpPerformanceCount);
	]])

	local q = ffi.new("int64_t[1]")
	ffi.C.QueryPerformanceFrequency(q)
	local freq = tonumber(q[0])

	local start_time = ffi.new("int64_t[1]")
	ffi.C.QueryPerformanceCounter(start_time)

	function system.GetTime()
		local time = ffi.new("int64_t[1]")
		ffi.C.QueryPerformanceCounter(time)

		time[0] = time[0] - start_time[0]
		return tonumber(time[0]) / freq
	end
end

do
	ffi.cdef("int SetConsoleTitleA(const char* blah);")
	function system.SetConsoleTitleRaw(str)
		return ffi.C.SetConsoleTitleA(str)
	end
end

do
	local text_editors = {
		["ZeroBrane.Studio"] = "%PATH%:%LINE%",
		["notepad++.exe"] = "\"%PATH%\" -n%LINE%",
		["notepad2.exe"] = "/g %LINE% %PATH%",
		["sublime_text.exe"] = "%PATH%:%LINE%",
		["notepad.exe"] = "/A %PATH%",
	}

	function system.FindFirstTextEditor(os_execute, with_args)
		local app = system.GetRegistryValue("ClassesRoot/.lua/default")
		if app then
			local path = system.GetRegistryValue("ClassesRoot/" .. app .. "/shell/edit/command/default")
			if path then
				path = path and path:match("(.-) %%") or path:match("(.-) \"%%")
				if path then
					if os_execute then
						path = "start \"\" " .. path
					end

					if with_args and text_editors[app] then
						path = path .. " " .. text_editors[app]
					end

					return path
				end
			end
		end
	end
end

do
	ffi.cdef([[
		typedef unsigned goluwa_hkey;
		long RegGetValueA(goluwa_hkey, const char*, const char*, unsigned long, unsigned long*, void*, unsigned long*);
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

	function system.GetRegistryValue(str)
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

function system._OSCommandExists(cmd)
	return false, "NYI"
end