local rate_cvar = console.CreateVariable("max_fps", 120)

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
		
		if rate <= 0 or next_update < time then
			local dt = time - (last_time or 0)
			
			timer.SetFrameTime(dt)
			timer.SetElapsedTime(timer.GetElapsedTime() + dt)
						
			local ok, err = xpcall(update, system.OnError, dt)
			
			if not ok and err then				
				log("shutting down (", err, ")\n")
				
				event.Call("ShutDown")
				return 
			end
		
			last_time = time
			
			if fps_cvar:Get() then
				calc_fps(dt)
			end
			
			next_update = time + (1/rate)
		end
	end
end

main()