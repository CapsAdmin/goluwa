local love = ... or _G.love
local ENV = love._lovemu_env

love.joystick = love.joystick or {}

function love.joystick.getJoysticks() --partial
	return {}
end

function love.joystick.close() --partial

end
function love.joystick.getAxes() --partial
	return 0
end
function love.joystick.getAxis() --partial
	return 0
end
function love.joystick.getBall() --partial
	return 0
end
function love.joystick.getHat() --partial
	return 0
end
function love.joystick.getName() --partial
	return "hello_world"
end
function love.joystick.getNumAxes() --partial
	return 2
end
function love.joystick.getNumBalls() --partial
	return 2
end
function love.joystick.getNumButtons() --partial
	return 2
end
function love.joystick.getNumHats() --partial
	return 2
end
function love.joystick.getNumJoysticks() --partial
	return 0
end
function love.joystick.isDown() --partial
	return false
end
function love.joystick.isOpen() --partial
	return true
end
function love.joystick.open() --partial

end