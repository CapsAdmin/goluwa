local love = ... or _G.love
local ENV = love._lovemu_env

love.timer = love.timer or {}

function love.timer.getDelta()
	return system.GetFrameTime() or 0
end

function love.timer.getFPS()
	return math.ceil(1/system.GetFrameTime() or 0)
end

function love.timer.getMicroTime()
	return system.GetElapsedTime()
end

function love.timer.getTime()
	if lovemu.version == "0.8.0" then
		return math.ceil(system.GetElapsedTime())
	else
		return system.GetElapsedTime()
	end
end

function love.timer.getAverageDelta() -- partial
	return love.timer.getDelta()
end

function love.timer.sleep(ms)
	local thread = love.thread.getThread()

	if thread then
		thread.thread:Wait(ms)
	end
end