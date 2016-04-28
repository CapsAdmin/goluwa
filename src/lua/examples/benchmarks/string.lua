math.randomseed(20)

local str = string.random(10000000) -- 10000000 characters between 32 and 126

profiler.MeasureFunction(function()
	assert(str:reverse():find("/", 0, true) == 60)
end, 1000, "reverse")
-- reverse: average: 0.000079 total: 0.078945

profiler.MeasureFunction(function()
	for i = 1, #str, -1 do
		if str:sub(i, i) == "/" then
			assert(i == 60)
			break
		end
	end
end, 1000, "for loop")
-- for loop: average: 0.000000 total: 0.000224

profiler.MeasureFunction(function()
	local _, i = str:find(".*/")
	assert(#str - i + 1 == 60)
end, 1000, "pattern")
-- pattern: average: 0.011039 total: 11.039442
