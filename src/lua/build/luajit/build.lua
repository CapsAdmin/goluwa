package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

local function execute(str)
	print("os.execute: " .. str)
	os.execute(str)
end

local bin_dir = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower()

os.execute("mkdir -p " .. bin_dir)

execute("cp repo/src/luajit \"" .. bin_dir .. "/.\"")
execute("cp repo/src/jit/* \"" .. bin_dir .. "/jit/\"")
