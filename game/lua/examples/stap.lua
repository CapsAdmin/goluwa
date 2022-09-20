local ffi = require("ffi")
ffi.cdef("uint32_t getppid()")
local pid = ffi.C.getppid()
local dir = R("temp/stapxx/")

if not dir then
	assert(vfs.CreateDirectory("os:temp/stapxx"))
	dir = R("temp/stapxx/")
	os.execute("git clone https://github.com/openresty/stapxx " .. dir .. " --depth 1")
end

local cmd = "slow-vfs-reads"
fs.PushWorkingDirectory(dir)

pcall(function()
	os.execute("./stap++ -I ./tapset -x " .. pid .. " --arg limit=10 samples/" .. cmd .. ".sxx")
end)

fs.PopWorkingDirectory()