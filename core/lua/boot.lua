local start_time = os.clock()

do
	_G[jit.os:upper()] = true
	_G.OS = jit.os:lower()

	_G[jit.arch:upper()] = true
	_G.ARCH = jit.arch:lower()

	UNIX = not WINDOWS

	local ffi = require("ffi")

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
				res = os.readexecute("WHERE " .. cmd) ~= ""
			else
				res = os.readexecute("command -v " .. cmd) ~= ""
			end
			cache[cmd] = res
			return res
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
			return ffi.string(buf)
		end
	end

	if UNIX then
		function os.ls(path)
			if path:sub(#path, #path) ~= "/" then
				path = path .. "/"
			end

			local out = {}
			for dir in os.readexecute("for dir in "..path.."*; do printf \"%s\n\" \"${dir}\"; done"):gmatch("(.-)\n") do
				table.insert(out, dir:sub(#path + 1))
			end

			return out
		end
	else
		function os.ls(path)
			if path:sub(#path, #path) ~= "/" then
				path = path .. "/"
			end

			path = os.getcd() .. "\\" .. path
			path = path:gsub("/", "\\")

			local out = {}

			for name in os.readexecute("dir " .. path .. " /B"):gmatch("(.-)\n") do
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
			path = os.getcd() .. "\\" .. path
			path = path:gsub("/", "\\")

			local info = ffi.new("goluwa_file_attributes[1]")

			if ffi.C.GetFileAttributesExA(path, 0, info) then
				if
					bit.bor(info[0].dwFileAttributes, flags.archive) == flags.archive or
					bit.bor(info[0].dwFileAttributes, flags.normal) == flags.normal
				then
					return "file"
				end

				return "directory"
			end
		end
	end

	function os.isdir(dir) return os.pathtype(dir) == "directory" end
	function os.isfile(dir) return os.pathtype(dir) == "file" end

	if UNIX then
		function os.makedir(dir)
			return os.readexecute("mkdir -p " .. dir)
		end
	else
		ffi.cdef("int SHCreateDirectoryExA(void *,const char *path, void *);")
		local lib = ffi.load("Shell32.dll")
		function os.makedir(dir)
			return lib.SHCreateDirectoryExA(nil, dir, nil)
		end
	end

	function os.download(url, to)
		if WINDOWS then
			if to then
				to = os.getcd() .. "\\" .. to
				return powershell("(New-Object System.Net.WebClient).DownloadFile('"..url.."', '"..to.."')") == ""
			end
			to = os.getcd() .. "\\" .. "temp_download"
			powershell("(New-Object System.Net.WebClient).DownloadFile('"..url.."', '"..to.."')", true)
			local content = io.readfile(to)
			os.remove(to)
			return content
		else
			if to then
				if os.iscmd("wget") then
					return os.readexecute("wget -O \""..to.."\" \""..url.."\" && printf $?") == "0"
				elseif os.iscmd("curl") then
					return os.readexecute("curl -L --url \""..url.."\" --output \""..to.."\" && printf $?") == "0"
				end
			end

			if os.iscmd("wget") then
				return os.readexecute("wget -qO- \""..url.."\"")
			elseif os.iscmd("curl") then
				return os.readexecute("curl -vv -L --url \""..url.."\"")
			end
		end
	end

	if UNIX then
		ffi.cdef("int chdir(const char *path);")
		function os.cd(path)
			if ffi.C.chdir(path) ~= 0 then
				return nil, "unable change directory to " .. path
			end

			return true
		end
	else
		ffi.cdef("bool SetCurrentDirectoryA(const char *path);")
		function os.cd(path)
			if ffi.C.SetCurrentDirectoryA(path) == 0 then
				return nil, "unable change directory to " .. path
			end

			return true
		end
	end

	function io.readfile(path)
		local f = assert(io.open(path))
		local str = f:read("*all")
		f:close()
		return str
	end

	function has_tmux_session()
		return os.readexecute("tmux has-session -t goluwa 2> /dev/null; printf $?") == "0"
	end

	function os.extract(from, to, move_out)
		if to:sub(#to, #to) ~= "/" then to = to .. "/" end

		os.makedir(to)

		if UNIX then
			os.readexecute('tar -xvzf '..from..' -C "'..to..'"')
		else
			local to = to == "./" and "" or to
			if false then
			powershell([[
				$file = "]]..os.getcd() .. "\\" .. from..[["
				$location = "]]..os.getcd() .. "\\" .. to..[["

				$shell = New-Object -Com Shell.Application

				$zip = $shell.NameSpace($([System.IO.Path]::GetFullPath("$file")))

				if (!$zip) {
					Write-Error "could not extract $file!"
				}

				if (!(Test-Path $location)) {
					New-Item -ItemType directory -Path $location | Out-Null
				}

				foreach($item in $zip.items()) {
					$shell.Namespace("$location").CopyHere($item, 0x14)
				}
			]], true) end
		end

		if move_out then
			move_out = to .. move_out

			if move_out:sub(#move_out, #move_out) ~= "/" then
				move_out = move_out .. "/"
			end

			repeat
				local str, count = move_out:gsub("(.-/)(%*)(/.*)", function(left, star, right)
					for k,v in ipairs(os.ls(left)) do
						if os.isdir(left .. v) then
							return left .. v .. right
						end
					end
				end)
				move_out = str
			until count == 0

			repeat
				local str, count = move_out:gsub("(.-/)(.-%*)(/.*)", function(left, chunk, right)
					for k,v in ipairs(os.ls(left)) do
						if v:find(chunk:sub(0, -2), 0, true) and os.isdir(left .. v) then
							return left .. v .. right
						end
					end
				end)
				move_out = str
			until count == 0

			if UNIX then
				os.execute("cp -r " .. move_out .. "* " .. to)

				local dir = move_out:sub(#to + 1):match("(.-)/")

				if dir and os.isdir(to .. dir) then
					os.execute("rm -rf " .. to .. dir)
				end
			else
				powershell("Move-Item -Confirm:$false -Force -Path " .. move_out .. "* -Destination " .. to, true)
			end
		end

		return true -- TODO
	end

	function get_github_project(name, to, domain, delete)
        domain = domain or "github"
		if os.iscmd("git") then
			if os.isdir(to) and os.isdir(to .. "/.git") then
				os.readexecute("git -C "..to.." pull")
			else
				local move = false
				if os.isdir(to) then
					to = to .. "_"
					move = true
				end
				os.execute("git clone https://"..domain..".com/"..name..".git "..to.." --depth 1;")
				if move then
					os.execute("mv -f " .. to .. "/* " .. to:sub(0, -2) .. "/")
					os.execute("mv -f " .. to .. "/.* " .. to:sub(0, -2) .. "/")
					os.remove(to)
				end
			end
		elseif os.download("https://"..domain..".com/"..name.."/archive/master" .. ARCHIVE_EXT, "temp" .. ARCHIVE_EXT) then
			os.extract("temp" .. ARCHIVE_EXT, to, "*/*")
		end
	end
end

local arg_line
local args

if WINDOWS then
	args = {...}
	arg_line = table.concat(args, " ")
else
	arg_line = ... or ""
	args = {} (arg_line .. " "):gsub("(%S+)", function(chunk) table.insert(args, chunk) end)
end

local bin_dir = "data/" .. OS .. "_" .. ARCH .. "/"

local ARCHIVE_EXT = WINDOWS and ".zip" or ".tar.gz"

local generic = [[ffibuild.CopyLibraries("{BIN_DIR}")]]
local ffibuild_libraries = {
	assimp = generic,
	enet = generic,
	curses = generic,
	freeimage = generic,
	freetype = generic,
	libarchive = generic,
	libsndfile = generic,
	luajit = [[
		local function execute(str)
			print("os.execute: " .. str)
			os.execute(str)
		end

		os.execute("mkdir -p {BIN_DIR}")
		os.execute("mkdir -p {BIN_DIR}jit")

		execute("cp repo/src/luajit {BIN_DIR}.")
		execute("cp repo/src/jit/* {BIN_DIR}jit/.")
		execute("cp luajit.lua {BIN_DIR}.")
	]],
	luajit_forks = [[
		local function execute(str)
			print("os.execute: " .. str)
			os.execute(str)
		end

		os.execute("mkdir -p {BIN_DIR}")
		os.execute("mkdir -p {BIN_DIR}jit")

		execute("cp luajit_* {BIN_DIR}.")
		execute("cp lj.supp {BIN_DIR}.")
	]],
	luasocket = [[
		os.execute("mkdir -p " .. "{BIN_DIR}" .. "socket")

		local files = {
			"socket/core.so",
			"socket/unix.so",
			"socket/serial.so",
			"mime/core.so",
		}

		for _, path in ipairs(files) do
			local dir = path:match("(.+)/")
			if dir then
				os.execute("mkdir -p " .. "{BIN_DIR}" .. dir)
			end
			os.execute("cp " .. path .. " " .. "{BIN_DIR}" .. path)
		end
	]],
	luasec = generic,
	openal = [[
		ffibuild.SetBuildName("al")
		ffibuild.CopyLibraries("{BIN_DIR}")
		ffibuild.SetBuildName("alc")
		ffibuild.CopyLibraries("{BIN_DIR}")
	]],
	opengl = generic,
	SDL2 = generic,
	steamworks = generic,
	VTFLib = generic,
	vulkan = generic,
}

if OSX then ffibuild_libraries.vulkan = nil end

os.cd("../../")

if args[1] == "update" or not os.isfile("core/lua/init.lua") then
	if not os.isfile("core/lua/init.lua") then
		io.write("missing core/lua/init.lua\n")
	end
	if os.isfile(".git/config") and io.readfile(".git/config"):find("goluwa") and os.iscmd("git") then
		io.write("updating from git repository\n")
		os.execute("git pull")
	else
		io.write("downloading repository archive\n")
		if os.download("https://gitlab.com/CapsAdmin/goluwa/repository/master/archive" .. ARCHIVE_EXT, "temp" .. ARCHIVE_EXT) then
			if os.extract("temp" .. ARCHIVE_EXT, "./", "goluwa-master*/") then
				os.remove("temp" .. ARCHIVE_EXT)
			end
		end
	end

	if args[1] == "update" then
		os.exit(1)
	end
end

if args[1] == "build" then
	get_github_project("capsadmin/ffibuild", "data/ffibuild")
	assert(os.cd("data/ffibuild"), "unable to download ffibuild?")
	local function run_postbuild(code)
		code = code:gsub("{BIN_DIR}", "../../" .. OS .. "_" .. ARCH .. "/")
		os.setenv("templua")
		os.setenv("templua", "local ffibuild = loadfile('../ffibuild.lua')()\n" .. code)
		os.execute("../luajit/repo/src/luajit -e \"loadstring(os.getenv('templua'))()\"")
	end

	if args[2] == "all" then
		os.cd("luajit")
		os.execute("make")
		os.cd("..")

		for dir, post_build in pairs(ffibuild_libraries) do
			if os.isdir(dir) then
				os.cd(dir)
				os.execute("make")
				run_postbuild(post_build)
				os.cd("..")
			end
		end

		os.cd("../../")

		io.open(bin_dir .. "binaries_downloaded", "w"):close()
	elseif args[2] == "clean" then
		for _, dir in ipairs(os.ls("")) do
			if os.isdir(dir) then
				os.cd(dir)
				os.execute("make clean")
				os.cd("..")
			end
		end
	else
		os.cd(args[2])

		if args[3] == "clean" then
			os.execute("make clean")
		else
			os.execute("make " .. (args[3] or ""))
			if ffibuild_libraries[args[2]] then
				run_postbuild(ffibuild_libraries[args[2]])
			end
		end
	end

	os.exit()
end

if args[1] == "bundle_library_dependencies" then

	local blacklist = {
		"statically linked",
		"linux-vdso.so",
		--"libsystemd.so",
		"libwayland",
		"libX",
		-- https://raw.githubusercontent.com/probonopd/AppImages/master/excludelist
		"ld-linux.so",
		"ld-linux-x86-64.so",
		"libanl.so",
		"libBrokenLocale.so",
		"libcidn.so",
		"libcrypt.so",
		"libc.so",
		"libdl.so",
		"libm.so",
		"libmvec.so",
		"libnsl.so",
		"libnss_compat.so",
		"libnss_db.so",
		"libnss_dns.so",
		"libnss_files.so",
		"libnss_hesiod.so",
		"libnss_nisplus.so",
		"libnss_nis.so",
		"libpthread.so",
		"libreso",
		"librt.so",
		"libthread_db.so",
		"libutil.so",
		"libstdc++.so",
		"libGL.so",
		"libdrm.so",
		"libxcb.so",
		"libX11.so",
		"libgio-2.0.so",
		"libaso",
		"libgdk_pixbuf-2.0.so",
		"libfontconfig.so",
		"libcom_err.so",
		"libcrypt.so",
		"libexpat.so",
		"libgcc_s.so",
		"libglib-2.0.so",
		"libgpg-error.so",
		"libICE.so",
		"libkeyutils.so",
		"libp11-kit.so",
		"libSM.so",
		"libusb-1.0.so",
		"libuuid.so",
		"libz.so",
		"libgobject-2.0.so",
		"libpangoft2-1.0.so",
		"libpangocairo-1.0.so",
		"libpango-1.0.so",
		"libgpg-error.so",
		"libjack.so"
	}

	os.cd(bin_dir)

	--os.setenv("LD_LIBRARY_PATH", ".")

	local done = {}
	local found = {}
	local ok = true

	for _, bin in ipairs(os.ls(".")) do
		if bin:find("%.so") then
			local tool = jit.os == "OSX" and "otool -L" or "ldd"
			for line in os.readexecute(tool .. " " .. bin):gmatch("(.-)\n") do
				if not blacklisted then
					local name, location = line:match("(%S-) => (%S-) %b()")
					if not name then
						location = line:match("(%S-) %b()")
						if location then
							name = location:match(".+/(.+)") or location:match("^(%S+)")
						else
							name, location = line:match(".+/(.+)"), line
						end
					end

					if name == location then
						location = "./" .. location
					end

					local blacklisted = false

					for _, str in ipairs(blacklist) do
						if name:find(str, nil, true) then
							blacklisted = true
							if not done[name] then
								print("skipping " .. name .. " (blacklisted)")
								done[name] = true
							end
							break
						end
					end

					if not blacklisted then
						if location:sub(1, 1) == "." or location:sub(1, 1) == "/" then
							found[name] = found[name] or {location = location, bin = bin}
						end
					end
				end
			end
		end
	end

	for k,v in pairs(found) do
		print(v.location .. ":")
		print("\t" .. v.bin)

		os.execute("cp " .. v.location .. " .")
	end

	os.exit()
end

if args[1] == "check_binaries" then

	os.cd(bin_dir)

	os.setenv("LD_LIBRARY_PATH", ".:/usr/lib:/lib")

	local ok = true

	for _, bin in ipairs(os.ls(".")) do
		if bin:find("%.so") then
			if not os.execute([[./luajit -e "require('ffi').load(']]..bin..[[')"]]) then
				ok = false
			end
		end
	end

	if not ok then
		print("errors when calling ffi.load() on one or more libraries")
		os.exit(1)
	end
	print("everything seems ok")
	os.exit()
end

if args[1] == "tmux" then
	assert(os.iscmd("tmux"), "tmux is not installed")

	if not has_tmux_session() then
		os.readexecute([[
		tmux new-session -d -s goluwa
		tmux send-keys -t goluwa "export GOLUWA_TMUX=1" C-m
		tmux send-keys -t goluwa "./goluwa launch" C-m
		]])
	end

	os.readexecute("tmux attach-session -t goluwa")

	os.exit()
end

if args[2] == "attach" and has_tmux_session() then
	os.readexecute("tmux attach-session -t goluwa")
end

if args[1] ~= "launch" then
	if not args[1] then
		if not WINDOWS and not OSX and os.readexecute("printf %s ${DISPLAY+x}") == "" then
			CLIENT = true
		elseif args[1] == "ide" or os.isfile("engine/lua/zerobrane/config.lua") then
			IDE = true
		end
	elseif not WINDOWS and os.iscmd("tmux") and has_tmux_session() then
		if args[1] == "attach" or args[1] == "tmux" then
			os.readexecute("tmux attach-session -t goluwa")
		elseif args[1] ~= "launch" then
			local magic_start = "TMUX_EXECUTE_START_" .. tostring({}) .. "__"
			local magic_stop = "TMUX_EXECUTE_STOP_" .. tostring({}) .. "__"

			local prev = io.readfile("data/tmux_log.txt")

			os.readexecute("tmux send-keys -t goluwa \"echo  " .. magic_start .. "\" C-m")
			os.readexecute("tmux send-keys -t goluwa '" .. arg_line .. "' C-m")
			os.readexecute("tmux send-keys -t goluwa \"echo " .. magic_stop .. "\" C-m")

			local timeout = os.clock() + 1

			while true do
				cur = io.readfile("data/tmux_log.txt")
				local start = cur:find(magic_start, nil, true)
				local stop = cur:find(magic_stop, nil, true)

				if start and stop then
					io.write(cur:sub(start + #magic_start + 1, stop - 2), "\n")
					break
				end

				if timeout < os.clock() then
					io.write("no resposne from goluwa\n")
					break
				end
			end
		end

		os.exit()
	end
end

if IDE then
	get_github_project("pkulchenko/ZeroBraneStudio", "data/ide")
	assert(os.cd("data/ide"), "unable to download ide?")

	if WINDOWS then
		os.execute(os.getcd() .. "\\zbstudio.exe -cfg ../../engine/lua/zerobrane/config.lua")
	else
		os.execute("./zbstudio.sh -cfg ../../engine/lua/zerobrane/config.lua")
	end

	os.exit()
end

if CLIENT or args[1] == "client" then
	os.setenv("GOLUWA_CLIENT", "1")
	os.setenv("GOLUWA_SERVER", "0")
	os.setenv("LD_PRELOAD", "libpthread.so.0")
	os.setenv("__GL_THREADED_OPTIMIZATIONS", "1")
	os.setenv("multithread_glsl_compiler", "1")
end

if args[1] == "server" then
	os.setenv("GOLUWA_GRAPHICS", "0")
	os.setenv("GOLUWA_SOUND", "0")
	os.setenv("GOLUWA_WINDOW", "0")

	os.setenv("GOLUWA_SERVER", "1")
	os.setenv("GOLUWA_CLIENT", "0")
end

if args[1] == "client" or args[1] == "server" or args[1] == "launch" or args[1] == "cli" then
	if args[2] == "branch" then
		if args[4] == "debug" then
			ARGS = {unpack(args, 5)}
		else
			ARGS = {unpack(args, 4)}
		end
	else
		ARGS = {unpack(args, 2)}
	end
else
	ARGS = args
end

if args[1] == "cli" then
	os.setenv("GOLUWA_CLI", "1")
end

os.appendenv("GOLUWA_ARGS", table.concat(ARGS, " "))

if not os.isfile("data/binaries_downloaded") then
	get_github_project("CapsAdmin/goluwa-binaries-" .. OS .. "_" .. ARCH, "data/" .. OS .. "_" .. ARCH, "gitlab", true)
	io.open("data/binaries_downloaded", "w"):close()
end

os.cd(bin_dir)

if UNIX then
	-- we need to fallback to usr/lib or /lib for driver specific libraries such as opengl libraries and audio
	os.setenv("LD_LIBRARY_PATH", ".:/usr/lib:/lib")
end

local initlua = "../../core/lua/init.lua"

GOLUWA_EXECUTABLE = (os.getenv("GOLUWA_EXECUTABLE") or "") .. "luajit"

if args[2] == "branch" then
	GOLUWA_EXECUTABLE = "luajit_" .. args[3]
end

if not WINDOWS and os.getenv("GOLUWA_DEBUG") or args[4] == "debug" then
	assert(os.iscmd("gdb"), "gdb is not installed")
	assert(os.iscmd("valgrind"), "valgrind is not installed")
	assert(os.iscmd("git"), "git is not installed")

	local utils = os.readexecute("pwd -P"):sub(0,-2) .. "/openresty-gdb-utils"

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
	gdb = gdb .. "--ex 'run' --args " .. GOLUWA_EXECUTABLE .. " " .. initlua

	local valgrind = "valgrind "
	valgrind = valgrind .. "--vgdb=yes "
	valgrind = valgrind .. "--vgdb-error=1 "
	valgrind = valgrind .. "--tool=memcheck "
	valgrind = valgrind .. "--leak-check=full "
	valgrind = valgrind .. "--leak-resolution=high "
	valgrind = valgrind .. "--show-reachable=yes "
	valgrind = valgrind .. "--read-var-info=yes "
	valgrind = valgrind .. "--suppressions=lj.supp "
	valgrind = valgrind .. "./" .. GOLUWA_EXECUTABLE .. " " .. initlua

	os.execute("xterm -hold -e " .. valgrind .. " &")
	os.execute("xterm -hold -e " .. gdb)
else
	os.setenv("GOLUWA_BOOT_TIME", tostring(os.clock() - start_time))

	if WINDOWS then
		os.execute(os.getcd() .. "\\" .. GOLUWA_EXECUTABLE .. ".exe " .. os.getcd():gsub("\\", "/") .. "/" .. initlua)
	else
		os.execute("./" .. GOLUWA_EXECUTABLE .. " " .. initlua)
	end
end
