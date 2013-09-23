love.timer={}

function love.timer.getDelta()
	return lovemu.delta
end

function love.timer.getFPS()
	return 1/lovemu.delta
end

function love.timer.getMicroTime()
	return glfw.GetTime()
end

function love.timer.getTime()
	return glfw.GetTime()
end