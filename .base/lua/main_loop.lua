local rate_cvar = console.CreateVariable("max_fps", 0, "-1\t=\trun as fast as possible\n0\t=\tvsync\n+1\t=\t/try/ to run at this framerate (using sleep)")

local fps_cvar = console.CreateVariable("show_fps", true)

local avg_fps = 1

local function calc_fps(dt)	
	local fps = 1/dt
	
	avg_fps = avg_fps + ((fps - avg_fps) * dt)
	
	if wait(1/30) then
		console.SetTitle(("FPS: %i"):format(avg_fps), "fps")
		
		if utility and utility.FormatFileSize then
			console.SetTitle(("GARBAGE: %s"):format(utility.FormatFileSize(collectgarbage("count") * 1024)), "garbage")
		end
		
		if GRAPHICS then
			window.SetTitle(console.GetTitle())
		end
	end
end

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
		if (collectgarbage("count")*1024) > 1024*1024*1024 then 
			if wait(1) then
				warning("emergency collect! memory > 1 gb") 
			end
			collectgarbage()
		end
	
		local rate = rate_cvar:Get()
		local time = system.GetTime()
		
		local dt = time - (last_time or 0)
		
		system.SetFrameTime(dt)
		system.SetFrameNumber(i)
		system.SetElapsedTime(system.GetElapsedTime() + dt)
		i = i + 1
					
		local ok, err = pcall(update_, dt)
		
		if not ok then				
			system.MessageBox("fatal error", tostring(err))
			os.exit()
			return false
		end
	
		last_time = time
		
		if fps_cvar:Get() then
			calc_fps(dt)
		end
		
		if rate > 0 then
			system.Sleep(math.floor(1/rate * 1000))
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
	
	if OnUpdate then
		function OnUpdate()
			if update() == false or not system.run then 
				event.Call("ShutDown")
				OnUpdate = nil
				--os.realexit(system.run)
			end
		end
	else
		while system.run == true do
			if update() == false then
				return
			end
		end
	end
end

main()
if not OnUpdate then
	event.Call("ShutDown")
	os.realexit(system.run)
end