local rate_cvar = console.CreateVariable("max_fps", 0, "-1\t=\trun as fast as possible\n0\t=\tvsync\n+1\t=\t/try/ to run at this framerate (using sleep)")

local fps_cvar = console.CreateVariable("show_fps", true)

local fps_add = 0
local avg_fps = 1
local count = 0

local gl = require("lj-opengl") -- OpenGL

local function calc_fps(dt)	
	local fps = 1/dt
	
	if count >= avg_fps / 10 then
		avg_fps = fps_add / count
		fps_add = 0
		count = 0
	else
		fps_add = fps_add + fps
		count = count + 1
	end

	system.SetWindowTitle(("FPS: %i"):format(avg_fps), "fps")
	
	if utilities and utilities.FormatFileSize then
		system.SetWindowTitle(("GARBAGE: %s"):format(utilities.FormatFileSize(collectgarbage("count") * 1024)), "garbage")
	end

	if gl.call_count then
		system.SetWindowTitle(("gl calls: %i"):format(gl.call_count), "glcalls")
		gl.call_count = 0
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
		
	while true do
		local rate = rate_cvar:Get()
		local time = timer.GetSystemTime()
		
		local dt = time - (last_time or 0)
		
		timer.SetFrameTime(dt)
		timer.SetElapsedTime(timer.GetElapsedTime() + dt)
					
		local ok, err = xpcall(update, system.OnError, dt)
		
		if not ok and err then				
			logn("shutting down (", err, ")")				
			event.Call("ShutDown")
			return 
		end
	
		last_time = time
		
		if fps_cvar:Get() then
			calc_fps(dt)
		end
		
		if rate > 0 then
			system.Sleep(math.floor(1/rate * 1000))
			if render.context_created and render.GetVSync() then
				render.SetVSync(false)
			end
		elseif rate == 0 then
			if render.context_created and not render.GetVSync() then
				render.SetVSync(true)
			end
		else
			if render.context_created and render.GetVSync() then
				render.SetVSync(false)
			end
		end
	end
end

main()