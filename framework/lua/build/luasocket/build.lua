package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

ffibuild.NixBuild({
	name = "lua5_1_sockets",
	libname = "lua/5.1/*"
})

ffibuild.NixBuild({
	name = "lua5_sec",
	libname = "lua/5.2/*"
})

local bin_dir = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/."

os.execute("cp -r socket " .. bin_dir)
os.execute("cp -r mime " .. bin_dir)
os.execute("cp ssl.* " .. bin_dir)