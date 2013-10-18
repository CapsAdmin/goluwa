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
		local time = glfw.GetTime()
		
		if next_update < time then
			local dt = time - (last_time or 0)
						
			local ok, err = xpcall(update, mmyy.OnError, dt)
			
			if not ok then				
				logn("shutting down")
				
				event.Call("ShutDown")
				return 
			end
		
			last_time = time
			
			local fps = dt
			smooth_fps = smooth_fps + ((fps - smooth_fps) * dt)
			
			system.SetWindowTitle(("FPS: %i"):format(1/smooth_fps), 1)
			
			if 1/smooth_fps < 30 then
				system.SetWindowTitle(("MS: %f"):format(smooth_fps*100), 3)
			else
				system.SetWindowTitle(nil, 3)
			end
			

			if gl.call_count then
				system.SetWindowTitle(("gl calls: %i"):format(gl.call_count), 2)
				gl.call_count = 0
			end
			
			local rate = rate_cvar:Get()
			
			rate = 1/rate
			
			next_update = time + rate
		end
	end
end

event.AddListener("Initialized", "main", main)