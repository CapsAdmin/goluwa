console.AddCommand("profile", function(line, time)
	profiler.SetClockFunction(glfw.GetTime)
	profiler.SetReadFileFunction(vfs.Read)

	time = tonumber(time)
	
	profiler.Start()
	
	logn("starting profiler for ", time, " seconds")
	
	if time > 2 then
		timer.Create("profile_status", 1, time-1, function()
			logn("profiling...")
		end)
	end
	
	timer.Simple(time, function()
		profiler.Stop()
		
		local benchmark = profiler.GetBenchmark()
		local top = {}
		
		for k,v in pairs(benchmark) do
			if v.times_called > 50 and v.average_time > 0 then
				table.insert(top, v)
			end
		end
		
		table.sort(top, function(a, b)
			return a.average_time > b.average_time
		end)
		
		local max = 0
		local max2 = 0
		for k, v in pairs(top) do
			if #v.name > max then
				max = #v.name
			end
			
			v.average_time = tostring(v.average_time * 100)
			
			if #v.average_time > max2 then
				max2 = #v.average_time
			end
		end
		
		
		
		logn(("_"):rep(max+max2+11+10))
		logn("| NAME:", (" "):rep(max-4), "| MS:", (" "):rep(max2-2), "| CALLS:")
		logn("|", ("_"):rep(max+2), "|", ("_"):rep(max2+2), "|", ("_"):rep(4+10))
		for k,v in pairs(top) do
			logf("| %s%s | %s%s | %s", v.name, (" "):rep(max-#v.name), v.average_time, (" "):rep(max2 - #v.average_time), v.times_called) 
		end
		logn("")
		
	end)	
end)