local love = ... or _G.love
local ENV = love._lovemu_env

love.joystick = love.joystick or {}

function love.joystick.loadGamepadMappings()

end

function love.joystick.getJoysticks()
	return {}
end

function love.joystick.close()

end
function love.joystick.getAxes()
	return 0
end
function love.joystick.getAxis()
	return 0
end
function love.joystick.getBall()
	return 0
end
function love.joystick.getHat()
	return 0
end
function love.joystick.getName()
	return "hello_world"
end
function love.joystick.getNumAxes()
	return 2
end
function love.joystick.getNumBalls()
	return 2
end
function love.joystick.getNumButtons()
	return 2
end
function love.joystick.getNumHats()
	return 2
end
function love.joystick.getNumJoysticks()
	return 0
end
function love.joystick.isDown()
	return false
end
function love.joystick.isOpen()
	return true
end
function love.joystick.open()

end