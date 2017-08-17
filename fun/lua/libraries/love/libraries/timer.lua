local love = ... or _G.love
local ENV = love._line_env

love.timer = love.timer or {}

function love.timer.step()

end

function love.timer.getDelta()
	return system.GetFrameTime()
end

function love.timer.getFPS()
	return math.ceil(1/system.GetFrameTime() or 0)
end

function love.timer.getMicroTime()
	return system.GetTime()
end

function love.timer.getTime()
	if love._version_minor == 8 then
		return math.ceil(system.GetElapsedTime())
	else
		return system.GetTime()
	end
end

function love.timer.getAverageDelta()
	return love.timer.getDelta()
end

function love.timer.sleep(ms)
	local thread = love.thread.getThread()

	if thread then
		if tasks.coroutine_lookup[thread.thread] then
			thread.thread:Wait(ms)
		end
	end
end
