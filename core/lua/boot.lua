local start_time = os.clock()

do
	_G[jit.os:upper()] = true
	_G.OS = jit.os:lower()

	_G[jit.arch:upper()] = true
	_G.ARCH = jit.arch:lower()

	UNIX = not WINDOWS

	ARCHIVE_EXT = WINDOWS and ".zip" or ".tar.gz"
	SHARED_LIBRARY_EXT = UNIX and ".so" or ".dll"

	local ffi = require("ffi")

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
		function powershell(str, no_return)
			os.setenv("pstemp", str)
			local ps = "powershell -nologo -noprofile -noninteractive -command Invoke-Expression $Env:pstemp"

			if no_return then
				os.execute(ps)
				return
			end

			local p = io.popen(ps)
			local out = p:read("*all")
			p:close()

			return out
		end
	end

	function os.readexecute(cmd)
		return io.popen(cmd):read("*all")
	end

	function os.checkexecute(cmd)
		local code
		if UNIX then
			code = os.readexecute(cmd .. " && printf %s $?")
		else
			code = os.readexecute(cmd .. " & echo %errorlevel%")
		end

		return code:sub(#code ) == "0"
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
			powershell("Remove-Item -Recurse -Force \"" .. path .. "\"")
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
				table.insert(out, dir:sub(#path + 1))
			end

			return out
		end
	else
		function os.ls(path)
			if path:sub(#path, #path) ~= "/" then
				path = path .. "/"
			end

			path = absolute_path(path)

			local out = {}

			for name in os.readexecute("dir \"" .. winpath(path) .. "\" /B"):gmatch("(.-)\n") do
				table.insert(out, name)
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
				ffi.C.setenv(key, val, 0)
			end
		end
	else
		ffi.cdef([[
			int _putenv_s(const char *var_name, const char *new_value);
			int _putenv(const char *var_name);
		]])

		function os.setenv(key, val)
			if not val then
				ffi.C._putenv(key)
			else
				ffi.C._putenv_s(key, val)
			end
		end
	end

	function os.appendenv(key, val)
		os.setenv(key, (os.getenv(key) or "") .. val)
	end

	function os.prependenv(key, val)
		os.setenv(key, val .. (os.getenv(key) or ""))
	end

	if UNIX then
		function os.pathtype(path)
			path = absolute_path(path)

			if os.readexecute('[ -d "'..path..'" ] && printf "1"') == "1" then
				return "directory"
			elseif os.readexecute('[ -f "'..path..'" ] && printf "1"') == "1" then
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

		local flags = {
			archive = 0x20, -- A file or directory that is an archive file or directory. Applications typically use this attribute to mark files for backup or removal .
			compressed = 0x800, -- A file or directory that is compressed. For a file, all of the data in the file is compressed. For a directory, compression is the default for newly created files and subdirectories.
			device = 0x40, -- This value is reserved for system use.
			directory = 0x10, -- The handle that identifies a directory.
			encrypted = 0x4000, -- A file or directory that is encrypted. For a file, all data streams in the file are encrypted. For a directory, encryption is the default for newly created files and subdirectories.
			hidden = 0x2, -- The file or directory is hidden. It is not included in an ordinary directory listing.
			integrity_stream = 0x8000, -- The directory or user data stream is configured with integrity (only supported on ReFS volumes). It is not included in an ordinary directory listing. The integrity setting persists with the file if it's renamed. If a file is copied the destination file will have integrity set if either the source file or destination directory have integrity set.
			normal = 0x80, -- A file that does not have other attributes set. This attribute is valid only when used alone.
			not_content_indexed = 0x2000, -- The file or directory is not to be indexed by the content indexing service.
			no_scrub_data = 0x20000, -- The user data stream not to be read by the background data integrity scanner (AKA scrubber). When set on a directory it only provides inheritance. This flag is only supported on Storage Spaces and ReFS volumes. It is not included in an ordinary directory listing.
			offline = 0x1000, -- The data of a file is not available immediately. This attribute indicates that the file data is physically moved to offline storage. This attribute is used by Remote Storage, which is the hierarchical storage management software. Applications should not arbitrarily change this attribute.
			readonly = 0x1, -- A file that is read-only. Applications can read the file, but cannot write to it or delete it. This attribute is not honored on directories. For more information, see You cannot view or change the Read-only or the System attributes of folders in Windows Server 2003, in Windows XP, in Windows Vista or in Windows 7.
			reparse_point = 0x400, -- A file or directory that has an associated reparse point, or a file that is a symbolic link.
			sparse_file = 0x200, -- A file that is a sparse file.
			system = 0x4, -- A file or directory that the operating system uses a part of, or uses exclusively.
			temporary = 0x100, -- A file that is being used for temporary storage. File systems avoid writing data back to mass storage if sufficient cache memory is available, because typically, an application deletes a temporary file after the handle is closed. In that scenario, the system can entirely avoid writing the data. Otherwise, the data is written after the handle is closed.
			virtual = 0x10000, -- This value is reserved for system use.
		}

		function os.pathtype(path)
			path = absolute_path(path)

			local info = ffi.new("goluwa_file_attributes[1]")

			if ffi.C.GetFileAttributesExA(winpath(path), 0, info) then
				if bit.band(info[0].dwFileAttributes, flags.directory) == flags.directory then
					return "directory"
				end

				return "file"
			end
		end
	end

	function os.isdir(dir) return os.pathtype(dir) == "directory" end
	function os.isfile(dir) return os.pathtype(dir) == "file" end

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
			powershell([[
				[Net.ServicePointManager]::Expect100Continue = {$true}

				[System.Net.ServicePointManager]::SecurityProtocol =
					[System.Net.SecurityProtocolType]::Tls11 -bor
					[System.Net.SecurityProtocolType]::Tls12 -bor
					[System.Net.SecurityProtocolType]::Tls13;

				(New-Object System.Net.WebClient).DownloadFile(']] .. url .. [[', ']] .. winpath(to) .. [[')
			]], true)
			return os.isfile(to)
		else
			if os.iscmd("wget") then
				return os.readexecute("wget -O \""..to.."\" \""..url.."\" && printf $?") == "0"
			elseif os.iscmd("curl") then
				return os.readexecute("curl -L --url \""..url.."\" --output \""..to.."\" && printf $?") == "0"
			end
		end
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

	function io.writefile(path, str)
		local f = assert(io.open(path, "wb"))
		f:write(str)
		f:close()
	end

	local session_id = os.getenv("GOLUWA_TMUX_SESSION_ID") or "goluwa"

	function has_tmux_session()
		if os.iscmd("tmux") then
			return os.readexecute("tmux has-session -t "..session_id.." 2> /dev/null; printf $?") == "0"
		end
	end

	function os.extract(from, to, move_out)
		from = absolute_path(from)
		to = absolute_path(to)

		if to:sub(#to, #to) ~= "/" then
			to = to .. "/"
		end

		local extract_dir = to .. "temp/"

		os.makedir(extract_dir)

		if UNIX then
			os.readexecute('tar -xvzf ' .. from .. ' -C "' .. extract_dir .. '"')
		else
			powershell([[
				$file = "]]..from:gsub("/", "\\")..[["
				$location = "]]..extract_dir:gsub("/", "\\")..[["

				$shell = New-Object -Com Shell.Application

				$zip = $shell.NameSpace("$file")

				if (!$zip) {
					Write-Error "could open zip archive $file!"
				}
				else
				{
					foreach($item in $zip.items()) {
						Write-Host "extracting $($item.Name) -> $location"
						$shell.Namespace("$location").CopyHere($item, 0x14)
					}
				}
			]], true)
		end

		if move_out then
			if move_out:sub(#move_out, #move_out) ~= "/" then
				move_out = move_out .. "/"
			end

			if move_out:sub(1, 1) ~= "/" then
				move_out = "/" .. move_out
			end

			repeat
				local ok = false
				local str, count = move_out:gsub("(.-)/%*/(.*)", function(left, right)
					for k,v in ipairs(os.ls(extract_dir .. left)) do
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

	function get_github_project(name, to, domain, delete)
        domain = domain or "github"
		if os.iscmd("git") then
			if os.isdir(to) and os.isdir(to .. "/.git") then
				os.readexecute("git -C "..absolute_path(to).." pull")
			else
				if to ~= "" and to:sub(#to, #to) ~= "/" then
					to = to .. "/"
				end

				local extract_dir = to .. "temp"

				extract_dir = absolute_path(extract_dir)
				to = absolute_path(to)

				local ok, err = os.execute("git clone https://"..domain..".com/"..name..".git \""..extract_dir.."\" --depth 1")

				os.copyfiles(extract_dir, to)
				os.removedir(extract_dir)

				return ok, err
			end
			return true
		else
			local url
			if domain == "gitlab" then
				url = "https://"..domain..".com/"..name.."/repository/master/archive" .. ARCHIVE_EXT
			else
				url = "https://"..domain..".com/"..name.."/archive/master" .. ARCHIVE_EXT
			end

			io.write("downloading ", url, " -> ", os.getcd(), "/temp", ARCHIVE_EXT, "\n")

			if os.download(url, "temp" .. ARCHIVE_EXT) then
				io.write("extracting ", os.getcd(), "/temp", ARCHIVE_EXT, " -> ", os.getcd(), "/", to, "\n")
				local ok = os.extract("temp" .. ARCHIVE_EXT, to, "*/")

				os.remove(absolute_path("temp" .. ARCHIVE_EXT))

				return ok
			end
		end
	end
end

local STORAGE_PATH = os.getenv("GOLUWA_STORAGE_PATH")
local ARG_LINE = os.getenv("GOLUWA_ARG_LINE") or ""
local SCRIPT_PATH = os.getenv("GOLUWA_SCRIPT_PATH")
local RAN_FROM_FILEBROWSER = os.getenv("GOLUWA_RAN_FROM_FILEBROWSER")
local BINARY_DIR = "core/bin/" .. OS .. "_" .. ARCH .. "/"

local lua_exec = UNIX and "luajit" or "luajit.exe"

if not os.isfile(BINARY_DIR .. lua_exec) then
	os.makedir(BINARY_DIR)
	os.copyfiles(STORAGE_PATH .. "/bin/" .. OS .. "_" .. ARCH .. "/", BINARY_DIR)

	if UNIX then
		os.execute("chmod +x " .. BINARY_DIR .. lua_exec)
	end
end

local instructions_path = "storage/shared/copy_binaries_instructions"
if os.isfile(instructions_path) then
	for from, to in io.readfile(instructions_path):gmatch("(.-);(.-)\n") do
		io.write("copying ", from, " to ", to, "\n")
		os.copyfile(from, to)
	end
	os.remove(instructions_path)
end

do -- tmux
	if ARG_LINE == "tmux" then
		assert(os.iscmd("tmux"), "tmux is not installed")

		if not has_tmux_session() then
			os.readexecute([[
				tmux new-session -d -s ]]..session_id..[[
				tmux send-keys -t ]]..session_id..[[ "export GOLUWA_TMUX=1" C-m
				tmux send-keys -t ]]..session_id..[[ "./goluwa" C-m
			]])
		end

		os.readexecute("tmux attach-session -t "..session_id)

		os.exit()
	end

	if ARG_LINE == "attach" and has_tmux_session() then
		os.readexecute("tmux attach-session -t "..session_id)

		return
	end

	if not os.getenv("GOLUWA_TMUX") and has_tmux_session() then
		local prev = io.readfile("storage/shared/tmux_log.txt")

		print(prev)

		os.readexecute("tmux send-keys -t "..session_id.." '" .. ARG_LINE .. "' C-j")

		local timeout = os.clock() + 1

		while true do
			cur = io.readfile("storage/shared/tmux_log.txt")

			if cur ~= prev then
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

	if os.isfile(".git/config") and io.readfile(".git/config"):find("goluwa") and os.iscmd("git") then
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

		get_github_project("CapsAdmin/goluwa", "", "gitlab")

		if not os.isfile("core/lua/init.lua") then
			io.write("still missing core/lua/init.lua\n")
			os.exit(1)
		end
	end
end

if ARG_LINE == "update" then
	os.exit(1)
end

local initlua = "core/lua/init.lua"
local executable = "luajit"

do
	local what = "ljv"
	local start, stop = ARG_LINE:find("^"..what.." (%S+)")
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

do
	local base_url = "https://gitlab.com/CapsAdmin/goluwa-binaries/raw/master/core/bin/"..OS.."_"..ARCH.."/"

	local files = {
		"libtls",
		"libcrypto",
		"libssl",
		"libtls",
	}

	for _, name in ipairs(files) do
		name = name .. SHARED_LIBRARY_EXT
		if not os.isfile(BINARY_DIR .. name) then
			os.download(base_url .. name, BINARY_DIR .. name)
		end
	end
end

os.setenv("GOLUWA_BOOT_TIME", tostring(os.clock() - start_time))

if UNIX then

	if ARG_LINE == "gdb" then
		assert(os.iscmd("gdb"), "gdb is not installed")
		assert(os.iscmd("valgrind"), "valgrind is not installed")
		assert(os.iscmd("git"), "git is not installed")

		local utils = os.readexecute("pwd -P"):sub(0,-2) .. "/storage/temp/openresty-gdb-utils"

		if not os.isdir(utils) then
			os.execute("git clone https://github.com/openresty/openresty-gdb-utils.git " .. utils .. " --depth 1;")
		end

		local gdb = "gdb "
		gdb = gdb .. "--ex 'py import sys' "
		gdb = gdb .. "--ex 'py sys.path.append(\""..utils.."\")' "
		gdb = gdb .. "--ex 'source openresty-gdb-utils/luajit21.py' "
		gdb = gdb .. "--ex 'set non-stop off' "
		gdb = gdb .. "--ex 'target remote | vgdb' "
		gdb = gdb .. "--ex 'monitor leak_check' "
		gdb = gdb .. "--ex 'run' --args " .. BINARY_DIR .. "/"..executable .. " " .. initlua

		local valgrind = "valgrind "
		valgrind = valgrind .. "--vgdb=yes "
		valgrind = valgrind .. "--vgdb-error=1 "
		valgrind = valgrind .. "--tool=memcheck "
		valgrind = valgrind .. "--leak-check=full "
		valgrind = valgrind .. "--leak-resolution=high "
		valgrind = valgrind .. "--show-reachable=yes "
		valgrind = valgrind .. "--read-var-info=yes "
		valgrind = valgrind .. "--suppressions=lj.supp "
		valgrind = valgrind .. "./" .. BINARY_DIR .. "/"..executable .. " " .. initlua

		os.execute("xterm -hold -e " .. valgrind .. " &")
		os.execute("xterm -hold -e " .. gdb)
	else
		os.exit(os.execute("./" .. BINARY_DIR .. "/"..executable.." " .. initlua))
	end
else
	os.exit(os.execute(winpath(BINARY_DIR .. "\\"..executable..".exe " .. os.getcd():gsub("\\", "/") .. "/" .. initlua)))
end
