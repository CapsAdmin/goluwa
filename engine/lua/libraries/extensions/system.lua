function system.ExecuteArgs()
	local str = os.getenv("GOLUWA_ARG_LINE")

	if not str or str:trim() == "" then return end

	local args = str:split("--", true)

	if args then
		for _, arg in ipairs(args) do
			if arg:trim() ~= "" then commands.RunString(arg, true, true) end
		end
	end
end

commands.Add("cli", function() end)

commands.Add("verbose", function() end)

commands.Add("tmux", function() end)

commands.Add("gdb", function() end)

commands.Add("test", function() end)

do
	local show = pvars.Setup("system_fps_show", true, nil, "show fps in titlebar")
	local total = 0
	local count = 0
	local total2 = 0
	local count2 = 0

	function system.UpdateTitlebarFPS()
		if not show:Get() then return end

		total = total + system.GetFrameTime()
		count = count + 1
		total2 = total2 + system.GetInternalFrameTime()
		count2 = count2 + 1

		if wait(1) then
			system.current_fps = 1 / (total / count)
			system.current_fps2 = 1 / (total2 / count2) --math.round(1/(total2 / count2))
			system.SetConsoleTitle(("FPS: %i / %i"):format(system.current_fps, system.current_fps2), "fps")
			system.SetConsoleTitle(
				("GARBAGE: %s"):format(utility.FormatFileSize(collectgarbage("count") * 1024)),
				"garbage"
			)

			if GRAPHICS then window.SetTitle(system.GetConsoleTitle()) end

			total = 0
			count = 0
			total2 = 0
			count2 = 0
		end
	end
end