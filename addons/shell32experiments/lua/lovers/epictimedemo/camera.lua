
camera = { }
	camera.x = love.graphics.getWidth()
	camera.y = love.graphics.getHeight()
	elapsed = 80

function camera:draw()
	camera.xvel = player.xvel
	camera.yvel = player.yvel
	cameraViewX = ((-player.x + camera.x/9) + math.sin(player.xvel)/24)
	cameraViewY = (player.y)/24-6

	--sprint effect
	--love.graphics.translate((-player.x - (camera.xvel*8))/24,(player.y)/24-6)
	love.graphics.translate(cameraViewX,cameraViewY)
end

function camera:update(dt)
	elapsed = elapsed + 800*dt
end

function camera:scale(scaleX,scaleY)
	love.graphics.scale(scaleX, scaleY)
end