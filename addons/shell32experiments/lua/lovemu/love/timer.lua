local love=love
local lovemu=lovemu
love.timer={}

local lovemu=lovemu
local ceil=math.ceil

function love.timer.getDelta()
	return lovemu.delta
end

function love.timer.getFPS()
	return ceil(1/lovemu.delta)
end

function love.timer.getMicroTime()
	return glfw.GetTime()
end

function love.timer.getTime()
	if lovemu.version=="0.8.0" then
		return ceil(glfw.GetTime())
	else
		return glfw.GetTime()
	end
end