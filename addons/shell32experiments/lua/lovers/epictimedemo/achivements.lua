--http://www.dafont.com/bitmap.php?page=2

ach = {}

local one_minute = love.graphics.newImage('pics/achivements/clepsidra.png')
one_minute:setFilter('nearest','nearest')
local one_minute_timer = 0
local one_minute_bool = true
local oneminute = false
local one_minute_rot = 0
local one_minuteX = 0
local one_minuteY = 0

local bunny_kill_pic = love.graphics.newImage('pics/achivements/bunny.png')
bunny_kill_pic:setFilter('nearest','nearest')
local bunny_kill_timer = 0
local bunny_kill_show = false
bunny_kill = 0

local blood = love.graphics.newImage('pics/achivements/blood.png')
blood:setFilter('nearest','nearest')
achievement_takeDamage =  0
takeDamage_draw = false

local timer = 0
local a1 = love.graphics.newFont("fonts/3a.ttf", 12)
local fontM = love.graphics.newFont("fonts/1a.ttf", 30)

function ach:load()
end

function ach:draw()
	if gamestate == 'play' then 
		if oneminute then 
			love.graphics.draw(one_minute,player.x,player.y - one_minute:getHeight(),one_minute_rot,0.5,0.5,one_minute:getWidth()*.5,one_minute:getHeight()*.5)
			love.graphics.setFont(a1)
			love.graphics.print("One Minute!", one_minuteX + 16,one_minuteY - one_minute:getHeight()  - a1:getHeight())
			love.graphics.setFont(fontM)
		end
		if bunny_kill >= 10 and bunny_kill_show then 
			love.graphics.draw(bunny_kill_pic,player.x,player.y - bunny_kill_pic:getHeight()-8,0,.7,.7)
			love.graphics.setFont(a1)
			love.graphics.setColor(45,60,40)
			love.graphics.print("Kill 10 bunnys!", player.x + 16,player.y - bunny_kill_pic:getHeight()  - a1:getHeight())
			love.graphics.setColor(255,255,255)
			love.graphics.setFont(fontM)
		end
		if achievement_takeDamage == 1 then 
			love.graphics.draw(blood,player.x,player.y - blood:getHeight()-16,0,1.1,1.1)
			love.graphics.setFont(a1)
			love.graphics.setColor(45,60,40)
			love.graphics.print("Take Damage!", player.x + 16,player.y - blood:getHeight()  - a1:getHeight() - 6)
			love.graphics.setColor(255,255,255)
			love.graphics.setFont(fontM)
		end
	end
end

function ach:update(dt)
	one_minuteX = player.x 
	one_minuteY = player.y
	if gamestate == 'play' then 
		if one_minute_bool then 
		one_minute_timer = one_minute_timer + dt
		end
		if one_minute_timer >= 60 then 
			oneminute = true
			sound:play("achivement")
		end 
		if oneminute then 
			one_minute_rot = one_minute_rot + dt
			one_minuteX = one_minuteX + 24*math.cos(one_minute_rot)*9 * dt
		end
		if one_minute_timer > 63 then 
			oneminute = false
			one_minute_timer = 0
			one_minute_bool = false
		end
		if bunny_kill >= 10 then
			bunny_kill_show = true
			bunny_kill_timer = bunny_kill_timer + dt
			sound:play("achivement")
		end
		if bunny_kill_timer >= 3 then 
			achivement:stop() 
			bunny_kill_show = false
			bunny_kill_timer = 0
		end
		if achievement_takeDamage == 1 then 
			timer = timer + dt
			sound:play("achivement")
			if timer >= 3.4 then
				achivement:stop()  
				achievement_takeDamage = 2 	
				timer = 0
			end
		end
	end
end