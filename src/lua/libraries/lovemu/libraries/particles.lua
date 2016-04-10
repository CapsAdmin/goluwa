if not GRAPHICS then return end

local love = ... or _G.love
local ENV = love._lovemu_env

local ParticleSystem = lovemu.TypeTemplate("ParticleSystem")

function ParticleSystem:clone()

end
function ParticleSystem:count()

end
function ParticleSystem:emit()

end
function ParticleSystem:getAreaSpread()

end
function ParticleSystem:getBufferSize()

end
function ParticleSystem:getColors()

end
function ParticleSystem:getCount()

end
function ParticleSystem:getDirection()

end
function ParticleSystem:getEmissionRate()

end
function ParticleSystem:getEmitterLifetime()

end
function ParticleSystem:getImage()

end
function ParticleSystem:getInsertMode()

end
function ParticleSystem:getLinearAcceleration()

end
function ParticleSystem:getOffset()

end
function ParticleSystem:getOffsetX()

end
function ParticleSystem:getOffsetY()

end
function ParticleSystem:getParticleLifetime()

end
function ParticleSystem:getPosition()

end
function ParticleSystem:getRadialAcceleration()

end
function ParticleSystem:getRotation()

end
function ParticleSystem:getSizeVariation()

end
function ParticleSystem:getSizes()

end
function ParticleSystem:getSpeed()

end
function ParticleSystem:getSpin()

end
function ParticleSystem:getSpinVariation()

end
function ParticleSystem:getSpread()

end
function ParticleSystem:getTangentialAcceleration()

end
function ParticleSystem:getTexture()

end
function ParticleSystem:getX()

end
function ParticleSystem:getY()

end
function ParticleSystem:hasRelativeRotation()

end
function ParticleSystem:isActive()

end
function ParticleSystem:isEmpty()

end
function ParticleSystem:isFull()

end
function ParticleSystem:isPaused()

end
function ParticleSystem:isStopped()

end
function ParticleSystem:moveTo()

end
function ParticleSystem:pause()

end
function ParticleSystem:reset()

end
function ParticleSystem:setAreaSpread()

end
function ParticleSystem:setBufferSize()

end
function ParticleSystem:setColor()

end
function ParticleSystem:setColors()

end
function ParticleSystem:setDirection()

end
function ParticleSystem:setEmissionRate()

end
function ParticleSystem:setEmitterLifetime()

end
function ParticleSystem:setGravity()

end
function ParticleSystem:setImage()

end
function ParticleSystem:setInsertMode()

end
function ParticleSystem:setLifetime()

end
function ParticleSystem:setLinearAcceleration()

end
function ParticleSystem:setOffset()

end
function ParticleSystem:setParticleLife()

end
function ParticleSystem:setParticleLifetime()

end
function ParticleSystem:setPosition()

end
function ParticleSystem:setRadialAcceleration()

end
function ParticleSystem:setRelativeRotation()

end
function ParticleSystem:setRotation()

end
function ParticleSystem:setSize()

end
function ParticleSystem:setSizeVariation()

end
function ParticleSystem:setSizes()

end
function ParticleSystem:setSpeed()

end
function ParticleSystem:setSpin()

end
function ParticleSystem:setSpinVariation()

end
function ParticleSystem:setSpread()

end
function ParticleSystem:setSprite()

end
function ParticleSystem:setTangentialAcceleration()

end
function ParticleSystem:setTexture()

end
function ParticleSystem:start()

end
function ParticleSystem:stop()

end
function ParticleSystem:update()

end
function love.graphics.newParticleSystem()
	local self = lovemu.CreateObject("ParticleSystem")

	return self
end

lovemu.RegisterType(ParticleSystem)