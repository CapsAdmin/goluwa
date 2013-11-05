local rate_cvar = console.CreateVariable("max_fps", 120)

-- main loop

local function main()
	event.Call("Initialize")
			
	local next_update = 0
	local last_time = 0
	local smooth_fps = 0
	
	local function update(dt)
		luasocket.Update(dt)
		timer.Update(dt)
		
		event.Call("OnUpdate", dt)
	end
	
	while true do
		local rate = rate_cvar:Get()
		local time = glfw.GetTime()
		
		if rate <= 0 or next_update < time then
			local dt = time - (last_time or 0)
						
			local ok, err = xpcall(update, mmyy.OnError, dt)
			
			if not ok then				
				logn("shutting down")
				
				event.Call("ShutDown")
				return 
			end
		
			last_time = time
			
			local fps = dt
			
			if fps < 0.0083 then
				smooth_fps = smooth_fps + ((fps - smooth_fps) * dt)
			
				system.SetWindowTitle(("FPS: %i"):format(1/smooth_fps), 1)
			else
				system.SetWindowTitle(("FPS: %i"):format(1/fps), 1)
			end
			
			if 1/smooth_fps < 30 then
				system.SetWindowTitle(("MS: %f"):format(smooth_fps*100), 3)
			else
				system.SetWindowTitle(nil, 3)
			end
			

			if gl.call_count then
				system.SetWindowTitle(("gl calls: %i"):format(gl.call_count), 2)
				gl.call_count = 0
			end
		
			next_update = time + (1/rate)
		end
	end
end

event.AddListener("Initialized", "main", main)