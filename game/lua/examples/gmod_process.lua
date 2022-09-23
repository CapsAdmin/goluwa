local ffi = require("ffi")
ffi.cdef("int ioctl(int fd, unsigned long request, ...);")
local p = assert(io.popen("sleep 1; echo 'aaa'"))
local fd = ffi.C.fileno(p)
local int = ffi.new("size_t[1]")

event.AddListener("Update", "", function()
	if ffi.C.ioctl(fd, 21531, int) == 0 and int[0] > 0 then
		print(p:read(tonumber(int[0])))
	end
end)

LOL = p
local p = assert(io.popen([[read -p "input:" test; sleep 1; echo "INPUT IS: $test"]], "w"))

timer.Delay(1, function()
	p:write("test!\n")
end)

local fd = ffi.C.fileno(p)
local int = ffi.new("size_t[1]")

event.AddListener("Update", "", function()
	if ffi.C.ioctl(fd, 21531, int) == 0 and int[0] > 0 then
		print("|" .. p:read(tonumber(int[0])) .. "|")
	end
end)

LOL2 = p --local gmod = assert(steam.FindSourceGame("gmod"))
--  print(gmod.game_dir)
