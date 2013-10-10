
sun = {}
local moon = {}
local timeday = 0
local timenight = 0

function sun:load()
	sun.pic = love.graphics.newImage('pics/env/sun.png')
	sun.pic:setFilter('nearest','nearest')
	sun.rot = 0
	sun.size = 3.5
	sun.x = screenW-50
	sun.y = 250
	sun.speed = 23
	sun.move = true
	sun.rotation = 0


	moon.pic = love.graphics.newImage('pics/env/moon.png')
	moon.pic:setFilter('nearest','nearest')
	moon.rot = 0
	moon.size = 3
	moon.x = screenW-50
	moon.y = 250
	moon.speed = sun.speed
	moon.move = true

	isday = true
	isnight = false 
 	
 	--only day
	setday = false
	--only night
	setnight = false

	sky_r = 40
	sky_g = 40 
	sky_b = 40 
	bg_r = 0
	bg_g = 0
	bg_b = 0

end

function sun:draw()
	if isday or setday then 
		love.graphics.draw(sun.pic,sun.x,sun.y,sun.rotation,sun.size,sun.size,sun.pic:getWidth()*.5,sun.pic:getHeight()*.5)
	end
	if isnight or setnight then 
		love.graphics.draw(moon.pic,moon.x,moon.y,moon.rot,moon.size,moon.size,moon.pic:getWidth()*.5,moon.pic:getHeight()*.5)
	end
end

function sun:update(dt)
	bg_r = sky_r
	bg_g = sky_g
	bg_b = sky_b

	if sun.move then 
	sun.rot = sun.rot + (dt/sun.speed)
	sun.y = sun.y - ((22*math.sin(sun.rot)*5.3)) * (dt/sun.speed)
	sun.x = sun.x - ((22*math.cos(sun.rot)*26)) * (dt/sun.speed)
	end
	if moon.move then 
	moon.rot = moon.rot + (dt/moon.speed)
	moon.y = moon.y - ((22*math.sin(moon.rot)*5.3)) * (dt/moon.speed)
	moon.x = moon.x - ((22*math.cos(moon.rot)*26)) * (dt/moon.speed)
	end

	if isday or setday then 
		sun.rotation = sun.rotation + dt
	end

	--day colors
if isday then 
	if sun.y < 250 and sun.y > 240 then 
		sky_r = 40
		sky_g = 40
		sky_b = 40
	end
	if sun.y < 240 and sun.y > 230 then  
		sky_r = sky_r + 2 * dt
		sky_g = sky_g + 2 * dt
		sky_b = sky_b + 2 * dt
	end
	if sun.y < 230 and sun.y > 220 then 
		sky_r = sky_r + 4 * dt
		sky_g = sky_g + 4 * dt
		sky_b = sky_b + 4 * dt
	end
	if sun.y < 220 and sun.y > 210 then 
		sky_r = sky_r + 6 * dt
		sky_g = sky_g + 6 * dt
		sky_b = sky_b + 6 * dt
	end
	if sun.y < 210 and sun.y > 200 then 
		sky_r = sky_r 
		sky_g = sky_g 
		sky_b = sky_b 
		
		bg_r = bg_r + 2 * dt
		bg_g = bg_g + 2 * dt
		bg_b = bg_b + 2 * dt
	end
	if sun.y < 200 and sun.y > 190 then 
		sky_r = sky_r 
		sky_g = sky_g 
		sky_b = sky_b 
	end
	if sun.y < 150 and sun.y > 140 then 
		sky_r = sky_r + 7 * dt
		sky_g = sky_g + 7 * dt
		sky_b = sky_b + 7 * dt
	end
	if sun.y < 130 and sun.y > 120 then 
		sky_r = sky_r + 7 * dt
		sky_g = sky_g + 7 * dt
		sky_b = sky_b + 7 * dt	
	end
	if sun.y < 120 and sun.y > 110 then 
		sky_r = sky_r + 7 * dt
		sky_g = sky_g + 7 * dt
		sky_b = sky_b + 7 * dt
	end
	if sun.y < 110 and sun.y > 100 then 
		sky_r = sky_r + 7 * dt
		sky_g = sky_g + 7 * dt
		sky_b = sky_b + 7 * dt
	end
	if sun.y < 100 and sun.y > 90 then 
		sky_r = sky_r + 7 * dt
		sky_g = sky_g + 7 * dt
		sky_b = sky_b + 7 * dt
	end
	if sun.y < 90 and sun.y > 70 then 
		sky_r = sky_r + 17 * dt
		sky_g = sky_g + 17 * dt
		sky_b = sky_b + 17 * dt
	end
end

	
	--night colors
	
if isnight then 

	if moon.y < 250 and moon.y > 240 then 
		sky_r = sky_r - 22 * dt
		sky_g = sky_g - 22 * dt
		sky_b = sky_b - 22 * dt
	end
	if moon.y < 240 and moon.y > 230 then  
		sky_r = sky_r - 28 * dt
		sky_g = sky_g - 28 * dt
		sky_b = sky_b - 28 * dt
	end
	if moon.y < 230 and moon.y > 220 then 
		sky_r = sky_r - 20 * dt
		sky_g = sky_g - 20 * dt
		sky_b = sky_b - 20 * dt
	end
	if moon.y < 220 and moon.y > 210 then 
		sky_r = sky_r - 22 * dt
		sky_g = sky_g - 22 * dt
		sky_b = sky_b - 22 * dt
	end
	if moon.y < 210 and moon.y > 200 then 
		sky_r = sky_r - 12 * dt
		sky_g = sky_g - 12 * dt
		sky_b = sky_b - 12 * dt
	end
	if moon.y < 200 and moon.y > 190 then 
		sky_r = sky_r - 12 * dt
		sky_g = sky_g - 12 * dt
		sky_b = sky_b - 12 * dt
	end
	if moon.y < 150 and moon.y > 140 then 
		sky_r = sky_r - 7 * dt
		sky_g = sky_g - 7 * dt
		sky_b = sky_b - 7 * dt
	end
	if moon.y < 130 and moon.y > 120 then 
		sky_r = sky_r - 8 * dt
		sky_g = sky_g - 8 * dt
		sky_b = sky_b - 8 * dt	
	end
	if moon.y < 120 and moon.y > 110 then 
		sky_r = sky_r - 7 * dt
		sky_g = sky_g - 7 * dt
		sky_b = sky_b - 7 * dt	
	end
	if moon.y < 110 and moon.y > 100 then 
		sky_r = sky_r - 7 * dt
		sky_g = sky_g - 7 * dt
		sky_b = sky_b - 7 * dt
	end
	if moon.y < 100 and moon.y > 90 then 
		sky_r = sky_r - 7 * dt
		sky_g = sky_g - 7 * dt
		sky_b = sky_b - 7 * dt
	end
	if moon.y < 90 and moon.y > 70 then 
		sky_r = sky_r - 7 * dt
		sky_g = sky_g - 7 * dt
		sky_b = sky_b - 7 * dt
	end
	if moon.y < 50 and moon.y > -60 then 
		sky_r = sky_r - 22 * dt
		sky_g = sky_g - 22 * dt
		sky_b = sky_b - 22 * dt
	end
end

	if setday then 
		sky_r = 255
		sky_g = 255
		sky_b = 255
		love.graphics.setBackgroundColor(173,216,230,250)
		sun.move = false
		isday = false
		isnight = false
		sun.x = screenW*.5-sun.pic:getWidth()
		sun.y = 40
	end

	if setnight then 
		sky_r = 40
		sky_g = 40
		sky_b = 40
		bg_r = 40
		bg_g = 40
		bg_b = 40
		love.graphics.setBackgroundColor(40,40,40,250)
		love.graphics.setColor(40,40,40,250)
		moon.move = false
		isday = false
		isnight = false
		moon.x = screenW*.5-moon.pic:getWidth()
		moon.y = 40
	end
	
	if isday then 
		if bg_r >= 173 then bg_r = 173 end
		if bg_g >= 216 then bg_g = 216 end
		if bg_b >= 230 then bg_b = 230 end
		else 
			bg_r = 40
			bg_g = 40
			bg_b = 40
	end

	if (sky_r or sky_g or sky_b or sky_a) >= 255 and isday then 
		sky_r = 40
		sky_g = 40
		sky_b = 40
	end

	if (sky_r or sky_g or sky_b) <= 40 and isnight then 
		sky_r = 40
		sky_g = 40
		sky_b = 40
	end

	--check day/night 
	if isday then 
		timeday = timeday + dt
		if timeday >= 160 then
			isnight = true
			isday = false
			timeday = 0
		end 
	else 
		timenight = timenight + dt
		if timenight >= 160 then
			isday = true
			isnight = false
			timenight = 0
		end
	end
end