-------------------------------------------------
-- LOVE: Passing Clouds Demo								
-- Website: http://love.sourceforge.net			
-- Licence: ZLIB/libpng									
-- Copyright (c) 2006-2009 LOVE Development Team
-------------------------------------------------

function love.load()
	
	-- The amazing music.
	--music = love.audio.newSource("prondisk.xm")
	
	-- The various images used.
	body = love.graphics.newImage("body.png")
	ear = love.graphics.newImage("ear.png")
	face = love.graphics.newImage("face.png")
	logo = love.graphics.newImage("love.png")
	cloud = love.graphics.newImage("cloud_plain.png")

	-- Set the background color to soothing pink.
	love.graphics.setBackgroundColor(0xff, 0xf1, 0xf7)
	
	-- Spawn some clouds.
	for i=1,5 do
		spawn_cloud(math.random(-100, 900), math.random(-100, 700), 80 + math.random(0, 50))
	end
	
	love.graphics.setColor(255, 255, 255, 200)
	
	--love.audio.play(music, 0)
	
end

function love.update(dt)
	try_spawn_cloud(dt)
	
	nekochan:update(dt)
	
	-- Update clouds.
	for k, c in ipairs(clouds) do
		c.x = c.x + c.s * dt
	end
	
end

function love.draw()

	love.graphics.draw(logo, 400, 380, 0, 1, 1, 128, 64)
	
	for k, c in ipairs(clouds) do
		love.graphics.draw(cloud, c.x, c.y)
	end
	
	nekochan:render()
	
end

function love.keypressed(k)
	if k == "r" then
		love.filesystem.load("main.lua")()
	end
end


nekochan = {
	x = 400, 
	y = 250, 
	a = 0
}

function nekochan:update(dt)
		self.a = self.a + 10 * dt	
end

function nekochan:render()
	love.graphics.draw(body, self.x, self.y, 0, 1, 1, 64, 64)
	love.graphics.draw(face, self.x, self.y + math.sin(self.a/5) * 3, 0, 1, 1, 64, 64)
	local r = 1 + math.sin(self.a*math.pi/20)
	for i = 1,10 do
		love.graphics.draw(ear, self.x, self.y, (i * math.pi*2/10) + self.a/10, 1, 1, 16, 64+10*r)
	end
	
end

-- Holds the passing clouds.
clouds = {}

cloud_buffer = 0
cloud_interval = 1

-- Inserts a new cloud.
function try_spawn_cloud(dt)

	cloud_buffer = cloud_buffer + dt
	
	if cloud_buffer > cloud_interval then
		cloud_buffer = 0
		spawn_cloud(-512, math.random(-50, 500), 80 + math.random(0, 50))
	end
		
end

function spawn_cloud(xpos, ypos, speed)
	table.insert(clouds, { x = xpos, y = ypos, s = speed } )
end
