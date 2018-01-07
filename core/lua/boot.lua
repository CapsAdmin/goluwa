local ffi = require("ffi")
ffi.cdef([[
	int chdir(const char *path);
	int setenv(const char *name, const char *value, int overwrite);
]])

local arg_line = ...
local args = {} (arg_line .. " "):gsub("(%S+)", function(chunk) table.insert(args, chunk) end)

local function exec(cmd, args)
	if args then
		cmd = cmd:gsub("LUA{(%S-)}", function(s) return tostring(args[s]) end)
		print(cmd)
	end
	return io.popen(cmd):read("*all")
end

local function okexec(cmd)
	exec(cmd)
	return exec("$?") == 0
end

local function cmd_exists(cmd)
	if jit.os == "Windows" then
		return exec("WHERE " .. cmd) ~= ""
	else
		return exec("command -v " .. cmd) ~= ""
	end
end

local function ls(path)
	local out = {}
	for dir in exec("for dir in "..path.."*; do printf \"%s\n\" \"${dir}\"; done"):gmatch("(.-)\n") do
		table.insert(out, dir)
	end
	return out
end

local function setenv(key, val)
	ffi.C.setenv(key, val, 0)
end

local function is_dir(dir)
	if jit.os == "Windows" then

	else
		return exec('[ -d "'..dir..'" ] && printf "1"') == "1"
	end
end

local function is_file(dir)
	if jit.os == "Windows" then

	else
		return exec('[ -f "'..dir..'" ] && printf "1"') == "1"
	end
end

local function download(url, to)
	if jit.os == "Windows" then

	else
		exec([[
		if command -v wget >/dev/null 2>&1; then
			wget -O "LUA{to}" "LUA{url}"
		elif command -v curl >/dev/null 2>&1; then
			curl -L --url "LUA{url}" --output "LUA{to}"
		else
			echo "unable to find wget or curl"
			exit 1
		fi
		]], {url = url, to = to})

		return exec("$?") == 0
	end
end

local function cd(path)
	if ffi.C.chdir(path) ~= 0 then
		return nil, "unable change directory to " .. path
	end

	return true
end

local function readfile(path)
	local f = assert(io.open("data/tmux_log.txt"))
	local str = f:read("*all")
	f:close()
	return str
end

local root_dir = exec("printf %s $PWD")

cd("../../../")

if args[1] == "update" or not is_file("core/lua/init.lua") and false then
	if cmd_exists("git") then
		exec("git pull")
	else
		download("https://gitlab.com/CapsAdmin/goluwa/repository/master/archive.tar.gz", "temp.tar.gz")
		if jit.os == "Windows" then

		else
			exec([[
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
		assert(cd("framework/lua/build/"))

		if args[2] == "all" then
			cd("luajit")
			os.execute("make")
			cd("..")

			for _, dir in ipairs(ls("")) do
				if is_dir(dir) then
					cd(dir)
					os.execute("make &")
					cd("..")
				end
			end
		elseif args[2] == "clean" then
			for _, dir in ipairs(ls("")) do
				if is_dir(dir) then
					cd(dir)
					os.execute("make clean")
					cd("..")
				end
			end
		else
			cd(args[2])

			if args[3] == "clean" then
				os.execute("make clean")
			else
				os.execute("make " .. (args[3] or ""))
			end

			os.exit()
		end
	end

	if args[1] == "tmux" then
		assert(cmd_exists("tmux"), "tmux is not installed")

		if exec("tmux has-session -t goluwa; printf $?") == "1" then
			exec([[
			tmux new-session -d -s goluwa
			tmux send-keys -t goluwa "export GOLUWA_TMUX=1" C-m
			tmux send-keys -t goluwa "./goluwa launch" C-m
			]])
		end

		exec("tmux attach-session -t goluwa")

		os.exit()
	end

	if args[2] == "attach" and exec("tmux has-session -t goluwa") == "" then
		exec("tmux attach-session -t goluwa")
	end
end

if args[1] ~= "launch" then
	if not args[1] then
		if exec("printf %s ${DISPLAY+x}") == "" then
			CLIENT = true
		elseif args[1] == "ide" or is_file("engine/lua/zerobrane/config.lua") then
			IDE = true
		end
	elseif exec("tmux has-session -t goluwa; printf $?") == "0" then
		if args[1] == "attach" or args[1] == "tmux" then
			exec("tmux attach-session -t goluwa")
		elseif args[1] ~= "launch" then
			local magic_start = "TMUX_EXECUTE_START_" .. tostring({}) .. "__"
			local magic_stop = "TMUX_EXECUTE_STOP_" .. tostring({}) .. "__"

			local prev = readfile("data/tmux_log.txt")

			exec("tmux send-keys -t goluwa \"echo  " .. magic_start .. "\" C-m")
			exec("tmux send-keys -t goluwa '" .. arg_line .. "' C-m")
			exec("tmux send-keys -t goluwa \"echo " .. magic_stop .. "\" C-m")

			local timeout = os.clock() + 1

			while true do
				cur = readfile("data/tmux_log.txt")
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
	if cmd_exists("git") then
		if is_dir("data/ide") then
			exec("git -C data/ide pull")
		else
			exec("git clone https://github.com/pkulchenko/ZeroBraneStudio.git data/ide --depth 1;")
		end
	else
		download("https://github.com/pkulchenko/ZeroBraneStudio/archive/master.tar.gz", "temp.tar.gz")
		if jit.os == "Windows" then

		else
			exec([[
			mkdir -p data/ide
			tar -xvzf temp.tar.gz -C "data/ide/"
			mv ide/ZeroBraneStudio-master/* data/ide/
			rm -rf ZeroBraneStudio-master
			rm temp.tar.gz
			]])
		end
	end

	assert(cd("data/ide"), "unable to download ide?")

	exec("./zbstudio.sh -cfg ../../engine/lua/zerobrane/config.lua")

	os.exit()
end

if CLIENT or args[1] == "client" then
	setenv("GOLUWA_CLIENT", "1")
	setenv("GOLUWA_SERVER", "0")
	setenv("LD_PRELOAD", "libpthread.so.0")
	setenv("__GL_THREADED_OPTIMIZATIONS", "1")
	setenv("multithread_glsl_compiler", "1")
end

if args[1] == "server" then
	setenv("GOLUWA_GRAPHICS", "0")
	setenv("GOLUWA_SOUND", "0")
	setenv("GOLUWA_WINDOW", "0")

	setenv("GOLUWA_SERVER", "1")
	setenv("GOLUWA_CLIENT", "0")
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
	setenv("GOLUWA_CLI", "1")
end

setenv("GOLUWA_ARGS", (os.getenv("GOLUWA_ARGS") or "") .. table.concat(ARGS, " "))

local bin_dir = "data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/"

if not is_file(bin_dir .. "binaries_downloaded") then
	while true do
		if download("https://github.com/CapsAdmin/goluwa/releases/download/"..jit.os:lower().."-binaries/"..jit.arch:lower()..".tar.gz", "temp.tar.gz") then
			if okexec("tar -xvzf temp.tar.gz -C \"" .. bin_dir .. "\"") then
				os.remove("temp.tar.gz")
				print("zip file is maybe corrupt. trying again")
			else
				os.remove("temp.tar.gz")
			end
		else
			print("unable to download binaries. trying again")
		end
	end
	exec("touch " .. bin_dir .. "binaries_downloaded")
end

cd(bin_dir)

setenv("LD_LIBRARY_PATH", ".:" .. (os.getenv("LD_LIBRARY_PATH") or ""))

local initlua = "../../../core/lua/init.lua"

GOLUWA_EXECUTABLE = (os.getenv("GOLUWA_EXECUTABLE") or "") .. "luajit"

if args[2] == "branch" then
	GOLUWA_EXECUTABLE = "luajit_" .. args[3]
end

if os.getenv("GOLUWA_DEBUG") or args[4] == "debug" then
	assert(cmd_exists("gdb"), "gdb is not installed")
	assert(cmd_exists("valgrind"), "valgrind is not installed")
	assert(cmd_exists("git"), "git is not installed")

	local utils_path = exec("pwd -P"):sub(0,-2) .. "/openresty-gdb-utils"

	if not is_dir(utils_path) then
		os.execute("git clone https://github.com/openresty/openresty-gdb-utils.git "..utils_path.." --depth 1;")
	end

	gdb_exec_line="gdb --ex 'py import sys' --ex 'py sys.path.append(\""..utils_path.."\")' --ex 'source openresty-gdb-utils/luajit21.py' --ex 'set non-stop off' --ex 'target remote | vgdb' --ex 'monitor leak_check' --ex 'run' --args " .. GOLUWA_EXECUTABLE .. " " .. initlua	valgrind_exec_line="valgrind --vgdb=yes --vgdb-error=1 --tool=memcheck --leak-check=full --leak-resolution=high --show-reachable=yes --read-var-info=yes --suppressions=lj.supp ./" .. GOLUWA_EXECUTABLE .. " " .. initlua

	os.execute("xterm -hold -e "..valgrind_exec_line.." &")
	os.execute("xterm -hold -e "..gdb_exec_line)
else
	os.execute("./" .. GOLUWA_EXECUTABLE .. " " .. initlua)
end