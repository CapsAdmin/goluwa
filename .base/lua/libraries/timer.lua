local timer = _G.timer or {} 

timer.clock = timer.clock or os.clock
timer.GetTime = timer.clock
timer.total_time = 0

function timer.GetFrameTime()
	return timer.frame_time or 0.1
end

function timer.GetTotalTime()
	return timer.total_time
end

return timer