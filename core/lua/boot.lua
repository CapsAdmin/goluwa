local start_time = os.clock()
local session_id = os.getenv("GOLUWA_TMUX_SESSION_ID") or "goluwa"
local ffi = require("ffi")

do
	_G[jit.os:upper()] = true
	_G.OS = jit.os:lower()
	_G[jit.arch:upper()] = true
	_G.ARCH = jit.arch:lower()
	UNIX = not WINDOWS
	ARCHIVE_EXT = WINDOWS and ".zip" or ".tar.gz"
	SHARED_LIBRARY_EXT = UNIX and ".so" or ".dll"

	if OSX then SHARED_LIBRARY_EXT = ".dylib" end

	function absolute_path(path)
		if not path:find(os.getcd(), 1, true) then
			path = os.getcd() .. "/" .. path
		end

		return path
	end

	function winpath(path)
		return (path:gsub("/", "\\"))
	end

	if WINDOWS then
		function jscript(str)
			local tmp_name = os.getenv("TEMP") .. "\\lua_one_click_jscript_download.js"
			local f = assert(io.open(tmp_name, "wb"))
			f:write(str)
			f:close()
			os.execute("cscript /Nologo /E:JScript " .. tmp_name)
			os.remove(tmp_name)
		end
	end

	function os.readexecute(cmd)
		local p = assert(io.popen(cmd))
		str = p:read("*all")
		p:close()
		return str
	end

	do
		local cache = {}

		function os.iscmd(cmd)
			if cache[cmd] ~= nil then return cache[cmd] end

			local res

			if WINDOWS then
				res = os.readexecute("WHERE " .. cmd .. " 2>nul") ~= ""
			else
				res = os.readexecute("command -v " .. cmd) ~= ""
			end

			cache[cmd] = res
			return res
		end
	end

	function os.removedir(path)
		path = absolute_path(path)

		if UNIX then
			os.execute("rm -rf \"" .. path .. "\"")
		else
			os.execute("rmdir /Q /S \"" .. winpath(path) .. "\"")
		end
	end

	function os.copyfiles(a, b)
		a = absolute_path(a)
		b = absolute_path(b)

		if a:sub(#a, #a) ~= "/" then a = a .. "/" end

		if b:sub(#b, #b) ~= "/" then b = b .. "/" end

		if WINDOWS then
			os.execute("xcopy /H /C /E /Y /F \"" .. winpath(a) .. ".\" \"" .. winpath(b) .. ".\"")
		else
			os.execute("cp -rf \"" .. a .. ".\" \"" .. b .. "\"")
		end
	end

	function os.copyfile(a, b)
		a = absolute_path(a)
		b = absolute_path(b)

		if WINDOWS then
			os.execute("xcopy /H /C /Y /F \"" .. winpath(a) .. "\" \"" .. winpath(b) .. "\"")
		else
			os.execute("cp \"" .. a .. "\" \"" .. b .. "\"")
		end
	end

	if UNIX then
		ffi.cdef("char *getcwd(char *buf, size_t size);")

		function os.getcd()
			local buf = ffi.new("uint8_t[256]")
			ffi.C.getcwd(buf, 256)
			return ffi.string(buf)
		end
	else
		ffi.cdef("unsigned long GetCurrentDirectoryA(unsigned long length, char *buffer);")

		function os.getcd()
			local buf = ffi.new("uint8_t[256]")
			ffi.C.GetCurrentDirectoryA(256, buf)
			return ffi.string(buf):gsub("\\", "/")
		end
	end

	if UNIX then
		function os.ls(path)
			path = absolute_path(path)
			local out = {}

			for dir in os.readexecute("for dir in " .. path .. "*; do printf \"%s\n\" \"${dir}\"; done"):gmatch("(.-)\n") do
				list.insert(out, dir:sub(#path + 1))
			end

			return out
		end
	else
		function os.ls(path)
			if path:sub(#path, #path) ~= "/" then path = path .. "/" end

			path = absolute_path(path)
			local out = {}

			for name in os.readexecute("dir \"" .. winpath(path) .. "\" /B"):gmatch("(.-)\n") do
				list.insert(out, name)
			end

			return out
		end
	end

	if UNIX then
		ffi.cdef([[
			int setenv(const char *var_name, const char *new_value, int change_flag);
			int unsetenv(const char *name);
		]])

		function os.setenv(key, val)
			if not val then
				ffi.C.unsetenv(key)
			else
				ffi.C.setenv(key, val, 1)
			end
		end
	else
		ffi.cdef([[
			int SetEnvironmentVariableA(const char *key, const char *val);
		]])

		function os.setenv(key, val)
			ffi.C.SetEnvironmentVariableA(key, val or nil)
		end
	end

	if UNIX then
		function os.pathtype(path)
			path = absolute_path(path)

			if os.readexecute("[ -d \"" .. path .. "\" ] && printf \"1\"") == "1" then
				return "directory"
			elseif os.readexecute("[ -f \"" .. path .. "\" ] && printf \"1\"") == "1" then
				return "file"
			end

			return nil
		end
	else
		ffi.cdef([[
			typedef struct goluwa_file_time {
				unsigned long high;
				unsigned long low;
			} goluwa_file_time;

			typedef struct goluwa_file_attributes {
				unsigned long dwFileAttributes;
				goluwa_file_time ftCreationTime;
				goluwa_file_time ftLastAccessTime;
				goluwa_file_time ftLastWriteTime;
				unsigned long nFileSizeHigh;
				unsigned long nFileSizeLow;
			} goluwa_file_attributes;
			bool GetFileAttributesExA(const char*, int, goluwa_file_attributes*);
		]])
		local directory_flag = 0x10

		function os.pathtype(path)
			path = absolute_path(path)
			local info = ffi.new("goluwa_file_attributes[1]")

			if ffi.C.GetFileAttributesExA(winpath(path), 0, info) then
				if bit.band(info[0].dwFileAttributes, directory_flag) == directory_flag then
					return "directory"
				end

				return "file"
			end
		end
	end

	function os.isdir(dir)
		return os.pathtype(dir) == "directory"
	end

	function os.isfile(dir)
		return os.pathtype(dir) == "file"
	end

	if UNIX then
		function os.makedir(dir)
			dir = absolute_path(dir)
			return os.readexecute("mkdir -p " .. dir)
		end
	else
		ffi.cdef("int SHCreateDirectoryExA(void *,const char *path, void *);")
		local lib = ffi.load("Shell32.dll")

		function os.makedir(dir)
			dir = absolute_path(dir)
			return lib.SHCreateDirectoryExA(nil, winpath(dir), nil)
		end
	end

	function os.download(url, to)
		to = absolute_path(to)

		if WINDOWS then
			os.execute("goluwa.cmd _DL \"" .. url .. "\" \"" .. to .. "\"")
		else
			os.execute("./goluwa _DL \"" .. url .. "\" \"" .. to .. "\"")
		end

		return os.isfile(to)
	end

	if UNIX then
		ffi.cdef("int chdir(const char *path);")

		function os.cd(path)
			path = absolute_path(path)

			if ffi.C.chdir(path) ~= 0 then
				return nil, "unable change directory to " .. path
			end

			return true
		end
	else
		ffi.cdef("bool SetCurrentDirectoryA(const char *path);")

		function os.cd(path)
			path = absolute_path(path)

			if ffi.C.SetCurrentDirectoryA(winpath(path)) == 0 then
				return nil, "unable change directory to " .. path
			end

			return true
		end
	end

	function io.readfile(path)
		local f = assert(io.open(path, "rb"))
		local str = f:read("*all")
		f:close()
		return str
	end

	function has_tmux_session()
		if os.iscmd("tmux") then
			return os.readexecute("tmux has-session -t " .. session_id .. " 2> /dev/null; printf $?") == "0"
		end
	end

	function os.extract(from, to, move_out)
		from = absolute_path(from)
		to = absolute_path(to)

		if to:sub(#to, #to) ~= "/" then to = to .. "/" end

		local extract_dir = to .. "temp/"
		os.makedir(extract_dir)

		if UNIX then
			os.readexecute("tar -xvzf " .. from .. " -C \"" .. extract_dir .. "\"")
		else
			jscript(
				[[
				var file = "]] .. from:gsub("/", "\\\\") .. [["
				var location = "]] .. extract_dir:gsub("/", "\\\\") .. [["

				var shell = new ActiveXObject("Shell.Application")

				shell.NameSpace(location).CopyHere(shell.NameSpace(file).Items())
			]]
			)
		end

		if move_out then
			if move_out:sub(#move_out, #move_out) ~= "/" then
				move_out = move_out .. "/"
			end

			if move_out:sub(1, 1) ~= "/" then move_out = "/" .. move_out end

			repeat
				local ok = false
				local str, count = move_out:gsub("(.-)/%*/(.*)", function(left, right)
					for k, v in ipairs(os.ls(extract_dir .. left)) do
						ok = true

						if os.isdir(extract_dir .. left .. v) then
							return left .. v .. right .. "/"
						end
					end
				end)
				move_out = str			
			until count == 0 or ok == false

			move_out = extract_dir .. move_out
			io.write("copying files ", move_out, "** -> ", to, "\n")
			os.copyfiles(move_out, to)
			os.removedir(extract_dir)
		end

		return true -- TODO
	end

	function extract_git_project(domain, location, branch, to)
		io.write("extracting project\n")
		branch = branch or "master"

		if os.iscmd("git") then
			if os.isdir(to) and os.isdir(to .. "/.git") then
				local cmd = "git -C " .. absolute_path(to) .. " pull"
				io.write(cmd, "\n")
				os.execute(cmd)
			else
				if to ~= "" and to:sub(#to, #to) ~= "/" then to = to .. "/" end

				local extract_dir = to .. "temp"
				extract_dir = absolute_path(extract_dir)
				to = absolute_path(to)
				local cmd = "git clone https://" .. domain .. ".com/" .. location .. ".git \"" .. extract_dir .. "\" --depth 1"
				io.write(cmd, "\n")
				local ok, err = os.execute(cmd)
				os.copyfiles(extract_dir, to)
				os.removedir(extract_dir)
				return ok, err
			end

			return true
		else
			local url

			if domain == "gitlab" then
				url = "https://" .. domain .. ".com/" .. location .. "/repository/" .. branch .. "/archive" .. ARCHIVE_EXT
			else
				url = "https://" .. domain .. ".com/" .. location .. "/archive/" .. branch .. ARCHIVE_EXT
			end

			io.write("downloading ", url, " -> ", "temp", ARCHIVE_EXT, "\n")

			if os.download(url, "temp" .. ARCHIVE_EXT) then
				io.write("extracting ", "temp", ARCHIVE_EXT, " -> ", to, "\n")
				local ok = os.extract("temp" .. ARCHIVE_EXT, to, "*/")
				os.remove(absolute_path("temp" .. ARCHIVE_EXT))
				return ok
			end
		end
	end
end

local STORAGE_PATH = "storage"
local ARG_LINE = os.getenv("GOLUWA_ARG_LINE") or ""
local SCRIPT_PATH = os.getenv("GOLUWA_SCRIPT_PATH")
local BRANCH = os.getenv("GOLUWA_BRANCH")
local RAN_FROM_FILEBROWSER = os.getenv("GOLUWA_RAN_FROM_FILEBROWSER")
local BINARY_DIR = "core/bin/" .. OS .. "_" .. ARCH .. "/"
local lua_exec = UNIX and "luajit" or "luajit.exe"
local instructions_path = "storage/shared/copy_binaries_instructions"

if ARG_LINE:sub(0, #"nattlua") == "nattlua" then
	local args = {}

	for str in (ARG_LINE .. " "):gmatch("[^%s]+") do
		list.insert(args, str)
	end

	list.remove(args, 1)
	assert(loadfile("core/lua/modules/nattlua/build_output.lua"))(unpack(args))
	return
end

if os.isfile(instructions_path) then
	for from, to in io.readfile(instructions_path):gmatch("(.-);(.-)\n") do
		io.write("copying ", from, " to ", to, "\n")
		os.copyfile(from, to)
	end

	os.remove(instructions_path)
end

do -- tmux
	if ARG_LINE:sub(0, #"tmux") == "tmux" then
		assert(os.iscmd("tmux"), "tmux is not installed")

		if not has_tmux_session() then
			os.readexecute("tmux new-session -d -s " .. session_id)
			os.readexecute("tmux send-keys -t " .. session_id .. " \"export GOLUWA_TMUX=1\" C-m")
			os.readexecute(
				"tmux send-keys -t " .. session_id .. " 'while true; do ./goluwa; if [ $? -eq 0 ]; then break; fi; done' C-m"
			)
		end

		os.readexecute("tmux attach-session -t " .. session_id)
		os.exit()
	end

	if ARG_LINE == "attach" and has_tmux_session() then
		os.readexecute("tmux attach-session -t " .. session_id)
		return
	end

	if not os.getenv("GOLUWA_TMUX") and has_tmux_session() and ARG_LINE ~= "" then
		local prev = io.readfile("storage/shared/tmux_log.txt")
		os.readexecute("tmux send-keys -t " .. session_id .. " \"" .. ARG_LINE .. "__ENTERHACK__\"")
		local timeout = os.clock() + 1

		while true do
			cur = io.readfile("storage/shared/tmux_log.txt")

			if cur ~= prev and cur:sub(#prev):gsub("%s+", "") ~= "" then
				io.write(cur:sub(#prev), "\n")

				break
			end

			if timeout < os.clock() then
				io.write("no resposne from goluwa\n")

				break
			end
		end

		return
	end
end

if ARG_LINE == "update" or not os.isfile("core/lua/init.lua") then
	if not os.isfile("core/lua/init.lua") then
		io.write("missing core/lua/init.lua\n")
	end

	if
		ARG_LINE == "update" and
		os.isfile(".git/config") and
		io.readfile(".git/config"):find("goluwa") and
		os.iscmd("git")
	then
		io.write("updating from git repository\n")
		os.execute("git pull")
	else
		if ARG_LINE == "update" then
			for _, name in ipairs(os.ls(".")) do
				if os.isdir(name) and name ~= STORAGE_PATH then
					os.removedir(name)
				elseif name ~= "goluwa" and name ~= "goluwa.cmd" then
					os.remove(name)
				end
			end
		end

		extract_git_project("gitlab", "CapsAdmin/goluwa", BRANCH, "")

		if not os.isfile("core/lua/init.lua") then
			io.write("still missing core/lua/init.lua\n")
			os.exit(1)
		end
	end
end

if ARG_LINE == "update" then os.exit(0) end

local initlua = "core/lua/init.lua"
local executable = "luajit"

do
	local what = "ljv"
	local start, stop = ARG_LINE:find("^" .. what .. " (%S+)")

	if start then
		local arg = ARG_LINE:sub(#what + 2, stop)

		if os.isfile(BINARY_DIR .. "/luajit_" .. arg .. (WINDOWS and ".exe" or "")) then
			executable = "luajit_" .. arg
		else
			io.write("\"luajit_" .. arg, "\" is not an executable\n")
			os.exit(1)
		end
	end
end

if not os.getenv("GOLUWA_SKIP_LIBTLS") then
	local base_url = "https://gitlab.com/CapsAdmin/goluwa-binaries/raw/master/core/bin/" .. OS .. "_" .. ARCH .. "/"
	local files = {
		"libtls",
		"libcrypto",
		"libssl",
	}

	for _, name in ipairs(files) do
		name = name .. SHARED_LIBRARY_EXT

		if not os.isfile(BINARY_DIR .. name) then
			os.download(base_url .. name, BINARY_DIR .. name)
		end
	end

	local cert_pem = STORAGE_PATH .. "/shared/cert.pem"

	if not os.isfile(cert_pem) then
		os.makedir(STORAGE_PATH .. "/shared/")
		os.download(
			"https://raw.githubusercontent.com/libressl-portable/openbsd/master/src/lib/libcrypto/cert.pem",
			cert_pem
		)
	end
end

os.setenv("GOLUWA_BOOT_TIME", tostring(os.clock() - start_time))
local lua = require("core/bin/shared/luajit")
local signals = {
	SIGSEGV = 11,
}
ffi.cdef([[
	typedef void (*sighandler_t)(int32_t);
	sighandler_t signal(int32_t signum, sighandler_t handler);
	uint32_t getpid();
	int backtrace (void **buffer, int size);
	char ** backtrace_symbols_fd(void *const *buffer, int size, int fd);
	int kill(uint32_t pid, int sig);
]])
local LUA_GLOBALSINDEX = -10002
local state = lua.L.newstate()

for _, what in ipairs({"SIGSEGV"}) do
	local enum = signals[what]

	ffi.C.signal(enum, function(int)
		io.write("received signal ", what, "\n")

		if what == "SIGSEGV" then
			io.write("C stack traceback:\n")
			local max = 64
			local array = ffi.new("void *[?]", max)
			local size = ffi.C.backtrace(array, max)
			ffi.C.backtrace_symbols_fd(array, size, 0)
			io.write()
			local header = "========== attempting lua traceback =========="
			io.write("\n\n", header, "\n")
			lua.L.traceback(state, state, nil, 0)
			local len = ffi.new("uint64_t[1]")
			local ptr = lua.tolstring(state, -1, len)
			io.write(ffi.string(ptr, len[0]))
			io.write("\n", ("="):rep(#header), "\n")
			ffi.C.signal(int, nil)
			ffi.C.kill(ffi.C.getpid(), int)
		end
	end)
end

lua.L.openlibs(state)

local function check_error(ok)
	if ok ~= 0 then
		error(initlua .. " errored: \n" .. ffi.string(lua.tolstring(state, -1, nil)))
		lua.close(state)
	end
end

check_error(lua.L.loadfile(state, initlua))
check_error(lua.pcall(state, 0, 0, 0))
os.exit(0)