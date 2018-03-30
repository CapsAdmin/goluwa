function system.ExecuteArgs(args)
	args = args or _G.ARGS

	local skip_lua = nil

	if not args then
		local str = os.getenv("GOLUWA_ARGS")

		if str then
			if str:startswith("--") then
				args = str:split("--", true)
				table.remove(args, 1) -- uh
				skip_lua = true
			else
				local func, err = loadstring("return " .. str)

				if func then
					local ok, tbl = pcall(func)

					if not ok then
						logn("failed to execute ARGS: ", tbl)
						return
					end

					if type(tbl) ~= "table" then
						logn("table expected in ARGS, got ",type(tbl),": return ", str)
						return
					end

					args = tbl
				else
					logn("failed to execute ARGS: ", err)
				end
			end
		end
	end

	if args then
		for _, arg in ipairs(args) do
			commands.RunString(tostring(arg), skip_lua, true)
		end
	end
end

do
	local show = pvars.Setup("system_fps_show", true, nil, "show fps in titlebar")
	local total = 0
	local count = 0

	function system.UpdateTitlebarFPS(dt)
		if not show:Get() then return end

		total = total + dt
		count = count + 1

		if wait(1) then
			system.current_fps = math.round(1/(total / count))
			system.SetConsoleTitle(("FPS: %i"):format(system.current_fps), "fps")
			system.SetConsoleTitle(("GARBAGE: %s"):format(utility.FormatFileSize(collectgarbage("count") * 1024)), "garbage")

			if GRAPHICS then
				window.SetTitle(system.GetConsoleTitle())
			end

			total = 0
			count = 0
		end
	end
end