local ffi = require("ffi")

--jit.opt.start("loopunroll=9999999", "maxrecord=5000000", "maxmcode=1024000")
--require"jit.dump".on("+a", R"%DATA%/logs/jit_dump.txt")

profiler.StartTimer("aaa")

ffi.cdef [[
	typedef struct
	{ 
		uint8_t r, g, b, a;
	} color;
]]
 
local testCases = 1000000
local sums = ffi.new("long[?]", testCases)
 
for k = 0, testCases - 1 do
	local arr = ffi.new("color[?]", 100)
	local bottom = math.random(1, 50)
 
	for i = 0, 99 do
		arr[i].r = bottom + i
		arr[i].g = bottom + i + 1
		arr[i].b = bottom + i + 2
		arr[i].a = bottom + i + 3
	end
 
	for i = 1, 99 do
		arr[i].a = arr[i - 1].r;
	end
 
	for i = 0, 49 do
		arr[i].g = arr[99 - i].b;
	end
 
	local sum = 0;
 
	for i = 0, 99 do
		sum = sum + arr[i].r + arr[i].g + arr[i].b + arr[i].a
	end
 
	sums[k] = sum
end

profiler.StopTimer()
