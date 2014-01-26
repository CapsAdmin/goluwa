local rate_cvar = console.CreateVariable("max_fps", 120)

local fps_cvar = console.CreateVariable("show_fps", false)

local fps_add = 0
local avg_fps = 1
local count = 0

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
		timer.Update(dt)
		
		event.Call("OnUpdate", dt)
	end
	
	while true do
		local rate = rate_cvar:Get()
		local time = timer.clock()
		
		if rate <= 0 or next_update < time then
			local dt = time - (last_time or 0)
			
			timer.ft = dt
						
			local ok, err = xpcall(update, mmyy.OnError, dt)
			
			if not ok then				
				logn("shutting down")
				
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

event.AddListener("Initialized", "main", main)