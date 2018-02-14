local system = ... or _G.system
local ffi = require("ffi")

function system.OpenURL(url)
	os.execute(([[explorer "%s"]]):format(url))
end

ffi.cdef("VOID Sleep(DWORD dwMilliseconds);")
function system.Sleep(ms)
	ffi.C.Sleep(ms)
end

do
	require("winapi.time")

	local winapi = require("winapi")

	local freq = tonumber(winapi.QueryPerformanceFrequency().QuadPart)
	local start_time = winapi.QueryPerformanceCounter()

	function system.GetTime()
		local time = winapi.QueryPerformanceCounter()

		time.QuadPart = time.QuadPart - start_time.QuadPart
		return tonumber(time.QuadPart) / freq
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
	ffi.cdef[[
		BOOL SetDllDirectoryA(LPCTSTR lpPathName);
		DWORD GetDllDirectoryA(DWORD nBufferLength, LPTSTR lpBuffer);
	]]

	function system.SetSharedLibraryPath(path)
		ffi.C.SetDllDirectoryA(path or "")
	end

	local str = ffi.new("char[1024]")

	function system.GetSharedLibraryPath()
		ffi.C.GetDllDirectoryA(1024, str)

		return ffi.string(str)
	end
end

do
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