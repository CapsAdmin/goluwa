

commands.Add("profile_start=string|nil", function(how)
	if not how or how == "st" or how == "s" then
		profiler.EnableStatisticalProfiling(true)
	end

	if not how or how == "se" then
		profiler.EnableSectionProfiling(true)
	end

	if not how or how == "ab" or how == "a" then
		profiler.EnableTraceAbortLogging(true)
	end
end)

commands.Add("profile_stop=string|nil", function(how)
	if not how or how == "st" or how == "s" then
		profiler.EnableStatisticalProfiling(false)
	end

	if not how or how == "se" then
		profiler.EnableSectionProfiling(false)
	end

	if not how or how == "ab" or how == "a" then
		profiler.EnableTraceAbortLogging(false)
	end
end)

commands.Add("profile_restart", function()
	profiler.Restart()
end)

commands.Add("profile_dump=nil,number|nil", function(how, min_samples)
	if how == "" or how == "st" or how == "s" then
		profiler.PrintStatistical(min_samples)
	end

	if how == "" or how == "se" then
		profiler.PrintSections()
	end

	if how == "" or how == "ab" or how == "a" then
		profiler.PrintTraceAborts()
	end
end)

commands.Add("sprofile=number[5],string|nil,string|nil", function(time, file_filter, method)
	profiler.EnableStatisticalProfiling(true)

	event.Delay(time, function()
		profiler.EnableStatisticalProfiling(false)
		profiler.PrintStatistical(0)
	end)
end)

commands.Add("profile=number[5],string|nil,string|nil", function(time, file_filter, method)
	profiler.StartInstrumental(file_filter)

	event.Delay(time, function()
		profiler.StopInstrumental(file_filter, true)
	end)
end)

commands.Add("zbprofile", function()
	os.remove("./zerobrane_statistical.msgpack")
	os.remove("./zerobrane_trace_aborts.msgpack")

	local prf = require("zbprofiler")
	prf.start()
	event.Timer("zbprofiler_save", 3, 0, function() prf.save(0) end)
end)

commands.Add("trace_abort", function()
	jit.flush()
	profiler.EnableRealTimeTraceAbortLogging(true)
end)

commands.Add("loom", function()
	if profiler.ToggleLoom() then
		logn("started loom")
	else
		logn("stopped loom")
	end
end)

do
	local started = false

	function profiler.ToggleLoom()
		if not started then
			jit.loom.start2("html")
			started = true
			return true
		else
			vfs.Write("loom.html", jit.loom.stop())
			system.OpenURL(R("data/loom.html"))
			started = false
			return false
		end
	end
end

if RELOAD then

	profiler.ToggleStatistical()
	for i = 1, 1 do
		steam.UnmountSourceGame("gmod")
		steam.MountSourceGame("gmod")
	end
	profiler.ToggleStatistical()

	do return end

	I""
	for i = 1, 100 do
	local panel = gui.CreatePanel("frame")
	panel:Remove()
	end
	I""
end
