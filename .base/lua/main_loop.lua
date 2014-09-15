local rate_cvar = console.CreateVariable("max_fps", 0, "-1\t=\trun as fast as possible\n0\t=\tvsync\n+1\t=\t/try/ to run at this framerate (using sleep)")

local fps_cvar = console.CreateVariable("show_fps", true)

local avg_fps = 1

local gl = not SERVER and require("lj-opengl") -- OpenGL

local function calc_fps(dt)	
	local fps = 1/dt
	
	avg_fps = avg_fps + ((fps - avg_fps) * dt)
	
	if wait(1/30) then
		console.SetTitle(("FPS: %i"):format(avg_fps), "fps")
		
		if utility and utility.FormatFileSize then
			console.SetTitle(("GARBAGE: %s"):format(utility.FormatFileSize(collectgarbage("count") * 1024)), "garbage")
		end

		if gl and gl.call_count then
			console.SetTitle(("gl calls: %i"):format(gl.call_count), "glcalls")
			gl.call_count = 0
		end
	end
end

-- main loop

local function main()
	event.Call("Initialize")
			
	local next_update = 0
	local last_time = 0
	
	local function update(dt)
		event.UpdateTimers(dt)
		
		event.Call("Update", dt)
	end
	
	local i = 0ULL
		
	while true do
		local rate = rate_cvar:Get()
		local time = timer.GetSystemTime()
		
		local dt = time - (last_time or 0)
		
		timer.SetFrameTime(dt)
		timer.SetFrameNumber(i)
		timer.SetElapsedTime(timer.GetElapsedTime() + dt)
		i = i + 1
					
		local ok, err = pcall(update, dt)
		
		if not ok then				
			event.Call("ShutDown")
			system.MessageBox("fatal error", tostring(err))
			return 
		end
	
		last_time = time
		
		if fps_cvar:Get() then
			calc_fps(dt)
		end
		
		if rate > 0 then
			timer.Sleep(math.floor(1/rate * 1000))
			if render and render.context_created and render.GetVSync() then
				render.SetVSync(false)
			end
		elseif rate == 0 then
			if render and render.context_created and not render.GetVSync() then
				render.SetVSync(true)
			end
		else
			if render and render.context_created and render.GetVSync() then
				render.SetVSync(false)
			end
		end
	end
end

main()