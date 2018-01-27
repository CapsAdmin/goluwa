package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

ffibuild.NixBuild({
	name = "luajitPackages.luasocket",
	libname = "lua/5.1/*"
})

ffibuild.NixBuild({
	name = "luajitPackages.luasec",
	libname = "lua/5.1/*"
})

local bin_dir = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/"

os.execute("mkdir -p " .. bin_dir .. "socket")


local files = {
	"socket/core.so",
	"socket/unix.so",
	"socket/serial.so",
	"mime/core.so",
	"ssl.so",
}

for _, path in ipairs(files) do
	local dir = path:match("(.+)/")
	if dir then
		os.execute("mkdir -p " .. bin_dir .. dir)
	end
	os.execute("cp " .. path .. " " .. bin_dir .. path)
end