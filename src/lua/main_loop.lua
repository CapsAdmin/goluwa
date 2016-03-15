local rate_cvar = console.CreateVariable(
	"system_fps_max",
	0,
	function(rate)
		if window and window.IsOpen() then
			if rate == 0 then
				window.SwapInterval(true)
			else
				window.SwapInterval(false)
			end
		end
	end,
	"-1\t=\trun as fast as possible\n 0\t=\tvsync\n+1\t=\t/try/ to run at this framerate (using sleep)"
)

-- main loop

local function main()
	event.Call("Initialize")

	local next_update = 0
	local last_time = 0

	local function update_(dt)
		event.UpdateTimers(dt)
		event.Call("Update", dt)
	end

	local i = 0ULL

	local function update()
		local time = system.GetTime()

		local dt = time - (last_time or 0)

		system.SetFrameTime(dt)
		system.SetFrameNumber(i)
		system.SetElapsedTime(system.GetElapsedTime() + dt)
		i = i + 1

		local ok, err = pcall(update_, dt)

		if not ok then
			if system.MessageBox then
				system.MessageBox("fatal error", tostring(err))
			else
				error("fatal error: " .. tostring(err))
			end
			os.exit()
			return false
		end

		last_time = time

		system.UpdateTitlebarFPS(dt)

		local rate = rate_cvar:Get()

		if rate > 0 then
			system.Sleep(math.floor(1/rate * 1000))
		end
	end

	if not LOOP then
		function UpdateGoluwa()
			if update() == false or not system.run then
				event.Call("ShutDown")
				--os.realexit(system.run)
				return false
			end
			return true
		end
	else
		while system.run == true do
			if update() == false then
				return
			end
		end
	end
end

-- when including this file it will get stuck in the while loop so "lua/" is never popped from the stack
-- maybe instead of push popping directories maybe the directory should persist for each file
vfs.PopFromIncludeStack()

main()

if not LOOP then
	event.Call("ShutDown")
	os.realexit(system.run)
end