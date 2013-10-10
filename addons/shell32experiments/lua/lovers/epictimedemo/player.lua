math.randomseed(os.time())
math.random()
math.random()
math.random()

player = {}

local hud = {}
local hudbox = love.graphics.newImage("pics/interface/hudbox.png")
hudbox:setFilter('nearest','nearest')
local heart = love.graphics.newImage("pics/interface/heart.png")
heart:setFilter('nearest','nearest')
local heart_empty = love.graphics.newImage('pics/interface/noheart.png')
heart_empty:setFilter('nearest','nearest')
local heart_half = love.graphics.newImage('pics/interface/heartHalf.png')
heart_half:setFilter("nearest",'nearest')
local itemBox = love.graphics.newImage('pics/interface/itemBox.png')
itemBox:setFilter("nearest",'nearest')
local bar = love.graphics.newImage('pics/interface/bar.png')
bar:setFilter("nearest",'nearest')
local coin = love.graphics.newImage("pics/coin.png")
coin:setFilter('nearest','nearest')

local a1 = love.graphics.newFont("fonts/3a.ttf", 10);
local fontS = love.graphics.newFont("fonts/1a.ttf", 18);


function player:load()
	player.pic = {} 
	player.pic[1] = love.graphics.newImage("pics/bow/playerRempty.png")
	player.pic[1]:setFilter('nearest','nearest')
	player.pic[2] = love.graphics.newImage("pics/bow/playerRempty2.png")
	player.pic[2]:setFilter('nearest','nearest')
	player.pic[3] = love.graphics.newImage("pics/bow/playerRempty3.png")
	player.pic[3]:setFilter('nearest','nearest')
	player.pic[4] = love.graphics.newImage("pics/bow/playerRempty4.png")
	player.pic[4]:setFilter('nearest','nearest')

	player.pic[5] = love.graphics.newImage("pics/bow/playerLempty.png")
	player.pic[5]:setFilter('nearest','nearest')
	player.pic[6] = love.graphics.newImage("pics/bow/playerLempty2.png")
	player.pic[6]:setFilter('nearest','nearest')
	player.pic[7] = love.graphics.newImage("pics/bow/playerLempty3.png")
	player.pic[7]:setFilter('nearest','nearest')
	player.pic[8] = love.graphics.newImage("pics/bow/playerLempty4.png")
	player.pic[8]:setFilter('nearest','nearest')

	player.punch = {}
	player.punch[1] = love.graphics.newImage("pics/bow/punch2/playerLpunch2.png")
	player.punch[1]:setFilter('nearest','nearest')
	player.punch[2] = love.graphics.newImage("pics/bow/punch2/playerL2punch2.png")
	player.punch[2]:setFilter('nearest','nearest')
	player.punch[3] = love.graphics.newImage("pics/bow/punch2/playerL3punch2.png")
	player.punch[3]:setFilter('nearest','nearest')

	player.punch[4] = love.graphics.newImage("pics/bow/punch2/playerRpunch2.png")
	player.punch[4]:setFilter('nearest','nearest')
	player.punch[5] = love.graphics.newImage("pics/bow/punch2/playerR2punch2.png")
	player.punch[5]:setFilter('nearest','nearest')
	player.punch[6] = love.graphics.newImage("pics/bow/punch2/playerR3punch2.png")
	player.punch[6]:setFilter('nearest','nearest')

	extra = 2

	player.x = respawnX 
	player.y = respawnY 
	player.w = 16
	player.h = 16
	player.xvel = 0
	player.yvel = 0
	player.speed = 1200
	player.rot = 0
	player.scale = 1.2
	player.state = "idleR"
	player.currentPic = player.pic[1]
	player.animtime = 0
	player.grav = 666
	
	player.givepunch = false
	player.givepunchdamage = 2
	player.givepunchKnockBack = 6
	
	player.bownum = 3
	player.arrownum = 1

	player.inAir = true
	player.jumpHeight = 200

	player.health = 10

	player.coins = 0

	player.isAttacked = false -- draw knock
	player.hide = false	
	player.hide_pic = love.graphics.newImage('pics/text/stealth.png')
	player.hide_pic:setFilter('nearest','nearest')

end

function hud.draw()
	expand = 4;
	edge_space = 50;

	love.graphics.draw(hudbox,player.x + edge_space - 135,love.graphics.getHeight() - edge_space - hudbox:getHeight() * expand - 310,0,1.2,1.1)
	love.graphics.draw(itemBox,player.x + edge_space - 70,love.graphics.getHeight() - edge_space - hudbox:getHeight() * expand - 305)
	love.graphics.draw(bar,player.x + edge_space - 130,love.graphics.getHeight() - edge_space - hudbox:getHeight() * expand - 295)
	love.graphics.draw(coin,player.x + edge_space - 85,love.graphics.getHeight() - edge_space - hudbox:getHeight() * expand - 295,0,.7,.7)
		if superJumpShow then 
			love.graphics.draw(superjumpPic,player.x + edge_space - 68,160,0,1.2,1.2)
		end
		if superSpeedShow then 
			love.graphics.draw(superspeedPic,player.x + edge_space - 68,160,0,1.2,1.2)
		end
	love.graphics.setFont(a1)
	love.graphics.print(""..player.coins,player.x + edge_space - 78,love.graphics.getHeight() - edge_space - hudbox:getHeight() * expand - 296)
	love.graphics.setFont(fontS)
	for i=1,10 do
		love.graphics.draw(heart_empty, player.x + i * heart_empty:getWidth() * (expand - 3.4) - 90,love.graphics.getHeight() - edge_space - hudbox:getHeight() * (expand - 0.9) - 325,0,0.9,0.9)
	end
	if player.health == 9.5 or player.health == 8.5 or player.health == 7.5 or player.health == 6.5 or player.health == 5.5 or player.health == 4.5 or player.health == 3.5 or player.health == 2.5 or player.health == 1.5 or player.health == 0.5 then
		for i=1,player.health + 1 do
			love.graphics.draw(heart_half,player.x + 2 + i * heart_empty:getWidth() * (expand - 3.4) - 90,love.graphics.getHeight() - edge_space - hudbox:getHeight() * (expand - 0.9) - 325,0,0.9,0.9)
		end
	end
	for i=1,player.health do
		love.graphics.draw(heart,player.x + i * heart_empty:getWidth() * (expand - 3.4) - 90,love.graphics.getHeight() - edge_space - hudbox:getHeight() * (expand - 0.9) - 325,0,0.9,0.9)
	end
end	

function player:draw() 
	if gamestate == 'play' or gamestate == 'loading' then 
		love.graphics.setBackgroundColor(bg_r,bg_g,bg_b,250)
		love.graphics.setColor(sky_r,sky_g,sky_b,250)
		hud.draw()
		love.graphics.draw(player.currentPic,player.x,player.y,player.rot,player.scale,player.scale)
		if player.hide then 
			love.graphics.draw(player.hide_pic,player.x+2,player.y-(player.hide_pic:getHeight()+player.hide_pic:getHeight()*.5))
		end
	end
end

function player:update(dt)
	if gamestate == 'play' or gamestate == 'loading' then 
	player:Punch(dt)
	
	local maxGrav = 330
	local maxspeed = 130
	local friction = 320

	player.x = player.x + player.xvel*dt
	player.y = player.y + player.yvel*dt
	player.yvel = player.yvel + player.grav*dt
	if math.abs(player.yvel) < 2 then
		player.yvel = 0
	end
	--stealth settings
	if love.keyboard.isDown('lctrl') then 
		player.hide = true
		charging = false
	else 
		player.hide = false
	end
	if player.hide then 
		player.speed = 220
		maxspeed = 60
		friction = 190
	else 
		player.speed = 1200
		friction = 320
		maxspeed = 130
	end
	--limit his speed
	if player.xvel > maxspeed then player.xvel = maxspeed end
	if player.xvel < -maxspeed then player.xvel = -maxspeed end 
	--friction stuff
	if player.xvel > 0 then 
		player.xvel = player.xvel - friction * dt
	end
	if player.xvel < 0 then 
		player.xvel = player.xvel + friction * dt
	end
	--grav limit
	if player.yvel > maxGrav then player.yvel = maxGrav end 

	if love.keyboard.isDown('right') then 
		player.state = "right"
		charging = false
		player.givepunch = false
		player.xvel = player.xvel + player.speed*dt
		elseif love.keyboard.isDown('left') then 
			player.state = "left"
			charging = false
			player.givepunch = false
			player.xvel = player.xvel - player.speed*dt
	end
	player:anim(dt)

	--map bounds and parallex
	if player.x <= 90 then 
		player.x = 90
		parallex = false
		elseif player.x >= 100 then 
		parallex = true 
	end

	end
end

function player:dead(dt)
	if player.health <= 0 then 
		gamestate = 'menu'
	end
end

function player:Punch(dt)
	if player.state == 'idleR' and player.givepunch then 
		player.animtime = player.animtime + dt 
		if player.animtime > .1 then 
			player.currentPic = player.punch[4]
		end
		if player.animtime > .2 then 
			player.currentPic = player.punch[5]
		end 
		if player.animtime > .3 then 
			player.currentPic = player.punch[6]
		end
		if player.animtime >= .4 then
			player.currentPic = player.pic[1]
			player.animtime = 0
			player.givepunch = false
		end
	end
	if player.state == 'idleL' and player.givepunch then 
		player.animtime = player.animtime + dt 
		if player.animtime > .1 then 
			player.currentPic = player.punch[1]
		end
		if player.animtime > .2 then 
			player.currentPic = player.punch[2]
		end 
		if player.animtime > .3 then 
			player.currentPic = player.punch[3]
		end
		if player.animtime >= .4 then
			player.currentPic = player.pic[5]
			player.animtime = 0
			player.givepunch = false
		end
	end
end

function player:anim(dt)
	if player.state == "right" then 
		player.animtime = player.animtime + dt
		if player.animtime > .0 then 
			player.currentPic = player.pic[1]
		end
		if player.animtime > .2 then 
			player.currentPic = player.pic[2]
		end 
		if player.animtime > .4 then 
			player.currentPic = player.pic[3]
		end
		if player.animtime > .6 then 
			player.currentPic = player.pic[4]
			player.animtime = 0.0
		end
	end 

	if player.state == "left" then 
		player.animtime = player.animtime + dt
		if player.animtime > .0 then 
			player.currentPic = player.pic[5]
		end
		if player.animtime > .2 then 
			player.currentPic = player.pic[6]
		end 
		if player.animtime > .4 then 
			player.currentPic = player.pic[7]
		end
		if player.animtime > .6 then 
			player.currentPic = player.pic[8]
			player.animtime = 0.0
		end
	end

	if player.state == "left" and player.xvel >= -2 and player.xvel <= 4.6 then 
		player.currentPic = player.pic[5]
		player.animtime = 0
		player.xvel = 0
		player.state = 'idleL'
	end

	if player.state == "right" and player.xvel >= 0.0 and player.xvel <= 4.6  then 
		player.currentPic = player.pic[1]
		player.animtime = 0
		player.xvel = 0
		player.state = 'idleR'
	end
end

function player:keypressed(key)
	if key == 'z' then 
		player.givepunch = true
		bownum = nil
	end
	if key == 'x' then 
		bownum = 1
	end
	if not player.inAir then
		if key == "up" then
			player.yvel = -player.jumpHeight 
			player.inAir = true
			sound:play('jump')
		end
	end
end

function player:keyrelased(key)
end














