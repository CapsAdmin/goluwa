do
	_G[jit.os:upper()] = true
	_G.OS = jit.os:lower()

	_G[jit.arch:upper()] = true
	_G.ARCH = jit.arch:lower()

	local ffi = require("ffi")
	if WINDOWS then
		ffi.cdef([[
			unsigned long GetCurrentDirectoryA(unsigned long length, char *buffer);
			bool SetCurrentDirectoryA(const char *path);
			int _putenv_s(const char *var_name, const char *new_value);
		]])

		function ps(s)
			os.setenv("pstemp", s)
			local p = io.popen("powershell -noprofile -noninteractive Invoke-Expression 'Invoke-Expression $Env:pstemp'")
			local out = p:read("*all")
			p:close()
			print(out)
			return out
		end
	else
		ffi.cdef([[
			char *getcwd(char *buf, size_t size);
			int chdir(const char *path);
			int setenv(const char *name, const char *value, int overwrite);
		]])
	end

	function os.execute2(cmd, async)
		if async then
			os.execute(cmd .. " &")
		else
			return io.popen(cmd):read("*all")
		end
	end

	function os.checkexecute(cmd)
		local code = os.execute2(cmd .. " && printf %s $?")

		return code:sub(#code ) == "0"
	end

	do
		local cache = {}
		function os.iscmd(cmd)
			if cache[cmd] ~= nil then return cache[cmd] end
			local res
			if WINDOWS then
				res = os.execute2("WHERE " .. cmd) ~= ""
			else
				res = os.execute2("command -v " .. cmd) ~= ""
			end
			cache[cmd] = res
			return res
		end
	end

	function os.ls(path)
		local out = {}
		for dir in os.execute2("for dir in "..path.."*; do printf \"%s\n\" \"${dir}\"; done"):gmatch("(.-)\n") do
			table.insert(out, dir)
		end
		return out
	end

	if WINDOWS then
		function os.setenv(key, val) ffi.C._putenv_s(key, val) end
	else
		function os.setenv(key, val) ffi.C.setenv(key, val, 0) end
	end
	function os.appendenv(key, val) os.setenv(key, (os.getenv(key) or "") .. val) end
	function os.prependenv(key, val) os.setenv(key, val .. (os.getenv(key) or "")) end

	function os.isdir(dir)
		if WINDOWS then
			dir = os.getcd() .. "\\" .. dir
			dir = dir:gsub("/", "\\")
			return ps("Test-Path \"" .. dir .. "\" -PathType Container"):sub(1, 5) == "True"
		else
			return os.execute2('[ -d "'..dir..'" ] && printf "1"') == "1"
		end
	end

	function os.isfile(dir)
		if WINDOWS then
			dir = os.getcd() .. "\\" .. dir
			dir = dir:gsub("/", "\\")
			return ps("Test-Path \"" .. dir .. "\" -PathType Leaf"):sub(1, 4) == "True"
		else
			return os.execute2('[ -f "'..dir..'" ] && printf "1"') == "1"
		end
	end

	function os.makedir(dir)
		if WINDOWS then
			return ps("New-Item -ItemType Directory -Force -Path \""..dir.."\" | Out-Null")
		end

		return os.execute2("mkdir -p " .. dir)
	end

	function download(url, to, async)
		if WINDOWS then
			if to then
				to = os.getcd() .. "\\" .. to
				return ps("(New-Object System.Net.WebClient).DownloadFile('"..url.."', '"..to.."')") == ""
			end
			to = os.getcd() .. "\\" .. "temp_download"
			ps("(New-Object System.Net.WebClient).DownloadFile('"..url.."', '"..to.."')")
			local content = io.readfile(to)
			os.remove(to)
			return content
		else
			if to then
				if os.iscmd("wget") then
					return os.execute2("wget -O \""..to.."\" \""..url.."\" && printf $?", async) == "0"
				elseif os.iscmd("curl") then
					return os.execute2("curl -L --url \""..url.."\" --output \""..to.."\" && printf $?", async) == "0"
				end
			end

			if os.iscmd("wget") then
				return os.execute2("wget -qO- \""..url.."\"", async)
			elseif os.iscmd("curl") then
				return os.execute2("curl -vv -L --url \""..url.."\"", async)
			end
		end
	end

	function os.cd(path)
		if (WINDOWS and ffi.C.SetCurrentDirectoryA or ffi.C.chdir)(path) ~= 0 then
			return nil, "unable change directory to " .. path
		end

		return true
	end

	function os.getcd()
		if WINDOWS then
			local buf = ffi.new("uint8_t[256]")
			ffi.C.GetCurrentDirectoryA(256, buf)
			return ffi.string(buf)
		end

		local buf = ffi.new("uint8_t[256]")
		ffi.C.getcwd(buf, 256)
		return ffi.string(buf)
	end

	function io.readfile(path)
		local f = assert(io.open(path))
		local str = f:read("*all")
		f:close()
		return str
	end

	function has_tmux_session()
		return os.execute2("tmux has-session -t goluwa; printf $?") == "0"
	end
end

local arg_line = ...
local args = {} (arg_line .. " "):gsub("(%S+)", function(chunk) table.insert(args, chunk) end)

local root_dir = os.execute2("printf %s $PWD")
local bin_dir = "data/bin/" .. OS .. "_" .. ARCH .. "/"

local ARCHIVE_EXT = WINDOWS and ".zip" or ".tar.gz"

os.cd("../../../")

if args[1] == "update" or not os.isfile("core/lua/init.lua") and false then
	if os.iscmd("git") then
		os.execute2("git pull")
	else
		download("https://gitlab.com/CapsAdmin/goluwa/repository/master/archive" .. ARCHIVE_EXT, "temp" .. ARCHIVE_EXT)
		if WINDOWS then

		else
			os.execute2([[
			tar -xvzf temp.tar.gz
			cp -r goluwa-master/* .
			rm temp.tar.gz
			rm -rf goluwa-master
			]])
		end
	end

	if args[1] == "update" then
		os.exit(1)
	end
end

if jit.os ~= "Windows" then
	if args[1] == "build" then
		assert(os.cd("framework/lua/build/"))

		if args[2] == "all" then
			os.cd("luajit")
			os.execute("make")
			os.cd("..")

			for _, dir in ipairs(os.ls("")) do
				if os.isdir(dir) then
					os.cd(dir)
					os.execute("make &")
					os.cd("..")
				end
			end
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
			end

			os.exit()
		end
	end

	if args[1] == "tmux" then
		assert(os.iscmd("tmux"), "tmux is not installed")

		if not has_tmux_session() then
			os.execute2([[
			tmux new-session -d -s goluwa
			tmux send-keys -t goluwa "export GOLUWA_TMUX=1" C-m
			tmux send-keys -t goluwa "./goluwa launch" C-m
			]])
		end

		os.execute2("tmux attach-session -t goluwa")

		os.exit()
	end

	if args[2] == "attach" and has_tmux_session() then
		os.execute2("tmux attach-session -t goluwa")
	end
end

if args[1] ~= "launch" then
	if not args[1] then
		if os.execute2("printf %s ${DISPLAY+x}") == "" then
			CLIENT = true
		elseif args[1] == "ide" or os.isfile("engine/lua/zerobrane/config.lua") then
			IDE = true
		end
	elseif os.iscmd("tmux") and has_tmux_session() then
		if args[1] == "attach" or args[1] == "tmux" then
			os.execute2("tmux attach-session -t goluwa")
		elseif args[1] ~= "launch" then
			local magic_start = "TMUX_EXECUTE_START_" .. tostring({}) .. "__"
			local magic_stop = "TMUX_EXECUTE_STOP_" .. tostring({}) .. "__"

			local prev = io.readfile("data/tmux_log.txt")

			os.execute2("tmux send-keys -t goluwa \"echo  " .. magic_start .. "\" C-m")
			os.execute2("tmux send-keys -t goluwa '" .. arg_line .. "' C-m")
			os.execute2("tmux send-keys -t goluwa \"echo " .. magic_stop .. "\" C-m")

			local timeout = os.clock() + 1

			while true do
				cur = io.readfile("data/tmux_log.txt")
				local start = cur:find(magic_start, nil, true)
				local stop = cur:find(magic_stop, nil, true)

				if start and stop then
					print(cur:sub(start + #magic_start + 1, stop - 2))
					break
				end

				if timeout < os.clock() then
					print("no resposne from goluwa")
					break
				end
			end
		end

		os.exit()
	end
end

if IDE then
	if os.iscmd("git") then
		if os.isdir("data/ide") then
			os.execute2("git -C data/ide pull")
		else
			os.execute2("git clone https://github.com/pkulchenko/ZeroBraneStudio.git data/ide --depth 1;")
		end
	else
		download("https://github.com/pkulchenko/ZeroBraneStudio/archive/master" .. ARCHIVE_EXT, "temp" .. ARCHIVE_EXT)
		if WINDOWS then

		else
			os.execute2([[
			mkdir -p data/ide
			tar -xvzf temp.tar.gz -C "data/ide/"
			mv ide/ZeroBraneStudio-master/* data/ide/
			rm -rf ZeroBraneStudio-master
			rm temp.tar.gz
			]])
		end
	end

	assert(os.cd("data/ide"), "unable to download ide?")

	os.execute2("./zbstudio.sh -cfg ../../engine/lua/zerobrane/config.lua")

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
if not os.isfile(bin_dir .. "binaries_downloaded") then
	os.makedir(bin_dir)
	for i = 1, 3 do
		if
			os.isfile("binaries_temp" .. ARCHIVE_EXT) or
			download("https://gitlab.com/CapsAdmin/goluwa-binaries/repository/"..OS.."_"..ARCH.."/archive" .. ARCHIVE_EXT, "binaries_temp" .. ARCHIVE_EXT)
		then
			local extract_ok = false

			if WINDOWS then
				ps(([[
					function Extract($file, $location) {
						Write-Host -NoNewline "$file >> '$location' ... "

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


						Move-Item -Confirm:$false -Force -Path "$location\*\data\bin\windows_]]..ARCH..[[\*" -Destination "$location"

						Write-Host "OK"
					}

					Extract "%s" "%s"
				]]):format(
					((os.getcd() .. "\\binaries_temp" .. ARCHIVE_EXT):gsub("/", "\\")),
					((os.getcd() .. "\\" .. bin_dir):gsub("/", "\\"))
				))
				io.open(bin_dir .. "binaries_downloaded", "w"):close()
			else
				if os.checkexecute("tar -xvzf binaries_temp.tar.gz -C \"" .. bin_dir .. "\"") then
					local found

					for k,v in pairs(os.ls(bin_dir)) do
						if v:find("goluwa-binaries", nil, true) then
							os.execute2("cp -rf " .. v .. "/" .. bin_dir .. "* " .. bin_dir)
							os.execute2("rm -rf " .. v .. "/")
							os.remove("binaries_temp" .. ARCHIVE_EXT)
							found = true
							break
						end
					end

					if found then
						io.open(bin_dir .. "binaries_downloaded", "w"):close()
						break
					else
						print("unable to find 'goluwa-binaries' folder")
						os.exit()
					end
				else
					print("failed to extract archive")
					os.remove("binaries_temp.tar.gz")
					os.exit()
				end
			end
		else
			print("failed to download archive. trying again")
		end
	end
end

os.cd(bin_dir)

if not WINDOWS then
	os.setenv("LD_LIBRARY_PATH", ".")
end

local initlua = "../../../core/lua/init.lua"

GOLUWA_EXECUTABLE = (os.getenv("GOLUWA_EXECUTABLE") or "") .. "luajit"

if args[2] == "branch" then
	GOLUWA_EXECUTABLE = "luajit_" .. args[3]
end

if not WINDOWS and os.getenv("GOLUWA_DEBUG") or args[4] == "debug" then
	assert(os.iscmd("gdb"), "gdb is not installed")
	assert(os.iscmd("valgrind"), "valgrind is not installed")
	assert(os.iscmd("git"), "git is not installed")

	local utils = os.execute2("pwd -P"):sub(0,-2) .. "/openresty-gdb-utils"

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
	if WINDOWS then
		os.execute(GOLUWA_EXECUTABLE .. ".exe " .. initlua)
	else
		os.execute("./" .. GOLUWA_EXECUTABLE .. " " .. initlua)
	end
end
