local tbl = {}

timer.Start("table.insert")
for i = 1, 10000000 do
	table.insert(tbl, i)
	--tbl[#tbl + 1] = i
end
timer.Stop()