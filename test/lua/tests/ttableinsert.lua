local tbl = {}

profiler.StartTimer("table.insert")
for i = 1, 10000000 do
	table.insert(tbl, i)
	--tbl[#tbl + 1] = i
end
profiler.StopTimer()