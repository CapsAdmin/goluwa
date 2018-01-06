package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

ffibuild.Clone("https://github.com/diegonehab/luasocket.git", "repo/luasocket")
ffibuild.Clone("https://github.com/brunoos/luasec.git", "repo/luasec")

local target = jit.os == "OSX" and "macosx" or "linux"
local ext = jit.os == "OSX" and ".dylib" or ".so"
local luajit_src = io.popen("echo $(realpath ../luajit/repo/src)", "r"):read("*all"):sub(0,-2)
local luajit_lib = "libluajit.a"
local inc = "-I" .. luajit_src
local lib = "-l:" .. luajit_lib .. " " .. "-L" .. luajit_src
local bin_dir = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower()

local function execute(str)
	print("os.execute: " .. str)
	os.execute(str)
end

execute(("make %s -C repo/luasec INC_PATH=%q LIB_PATH=%q"):format(target, inc, lib))
execute("cp repo/luasec/src/ssl.so \"" .. bin_dir .. "/ssl" .. ext .. "\"")

execute("mkdir -p \"" .. bin_dir .. "/socket\"")
execute("mkdir -p \"" .. bin_dir .. "/mime\"")

execute(("make %s -C repo/luasocket MYCFLAGS=%q MYLDFLAGS=%q"):format(target, inc, lib))

execute("cp repo/luasocket/src/socket*.so \"" .. bin_dir .. "/socket/core" .. ext .. "\"")
execute("cp repo/luasocket/src/mime*.so \"" .. bin_dir .. "/mime/core" .. ext .. "\"")