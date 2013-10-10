
arrow = {}

arrow.pic1 = {}
arrow.pic1[1] = love.graphics.newImage('pics/arrows/arrowL.png')
arrow.pic1[1]:setFilter('nearest','nearest')
arrow.pic1[2] = love.graphics.newImage('pics/arrows/arrowR.png')
arrow.pic1[2]:setFilter('nearest','nearest')

arrow.pic2 = {}
arrow.pic2[1] = love.graphics.newImage('pics/arrows/arrowRedL.png')
arrow.pic2[1]:setFilter('nearest','nearest')
arrow.pic2[2] = love.graphics.newImage('pics/arrows/arrowRedR.png')
arrow.pic2[2]:setFilter('nearest','nearest')

arrow.pic3 = {}
arrow.pic3[1] = love.graphics.newImage('pics/arrows/arrowStrongL.png')
arrow.pic3[1]:setFilter('nearest','nearest')
arrow.pic3[2] = love.graphics.newImage('pics/arrows/arrowStrongR.png')
arrow.pic3[2]:setFilter('nearest','nearest')

--arrow
a = {}
a[1] = {x=0,y=0,picL=arrow.pic1[1],picR=arrow.pic1[2],sound=false,damage=2,cool=.3,speed=180,yvel=0,w=13,h=4,knockback=20}
a[2] = {x=0,y=0,picL=arrow.pic2[1],picR=arrow.pic2[2],sound=false,damage=4,cool=.2,speed=250,yvel=0,w=13,h=4,knockback=20}
a[3] = {x=0,y=0,picL=arrow.pic3[1],picR=arrow.pic3[2],sound=false,damage=2,cool=.1,speed=200,yvel=0,w=13,h=4,knockback=20}


local arrowspeed = 0
local timer = 0
local shootnow = 0

function arrow:spawn(xvel,x,y,direction)
	table.insert(arrow, {x = x, yvel = a[player.arrownum].yvel, xvel = xvel, y = y, direction = direction,uptime=0,collided = false,w=a[1].w,h=a[1].h,damage=a[player.arrownum].damage})
end

function arrow:update(dt)
	for i,v in ipairs(arrow) do 

	shootnow = a[player.arrownum].cool
	arrowspeed = a[player.arrownum].speed
	v.yvel = a[player.arrownum].yvel
	--effect
	if a[player.arrownum].yvel > 1 then 
	v.yvel = v.yvel + 400 * dt
	end

	v.x = v.x + v.xvel*dt
	v.y = v.y + v.yvel*dt

	--remove arrows
	
	if v.x > 1600 then 
		table.remove(arrow,i)
	end
	if v.x < -150 then 
		table.remove(arrow,i)
	end

	if #arrow >= 3 and a[player.arrownum] == 1 then 
		table.remove(arrow,i) 
	end

	if #arrow >= 6 and a[player.arrownum] == 2 or a[player.arrownum] == 3 then 
		table.remove(arrow,i) 
	end

	if v.direction == "left" then
		v.xvel = v.xvel - 500 * dt
		v.uptime = v.uptime + dt
		if v.uptime > .7 then 
			table.remove(arrow,i)
			v.uptime = 0
		end 
	end

	if v.direction == "right" then
		v.xvel = v.xvel + 500 * dt
		v.uptime = v.uptime + dt
		if v.uptime > .7 then 
			table.remove(arrow,i)
			v.uptime = 0
		end 
	end
	a[player.arrownum].x = v.x
	a[player.arrownum].y = v.y
end

	if charging then 
		if player.state == 'left' or player.state == 'idleL' then 
			timer = timer + dt
			if timer > shootnow then 
				sound:play('shoot')
				arrow:spawn(-arrowspeed,player.x + 3, player.y + 9, 'left')
				timer = 0
				charging = false
			end
		end
		if player.state == 'right' or player.state == 'idleR' then
			timer = timer + dt
			if timer > shootnow then 
				sound:play('shoot')
				arrow:spawn(arrowspeed,player.x + 8 - 5, player.y + 9,'right')	
				timer = 0
				charging = false
			end
		end
	end	
end

function arrow:draw()
	for i,v in ipairs(arrow) do 
		if v.direction == "right" then
			love.graphics.draw(a[player.arrownum].picR,v.x,v.y,0,1.1,1.1)
		end
		if v.direction == "left" then
			love.graphics.draw(a[player.arrownum].picL,v.x,v.y,0,1.1,1.1)
		end
	end
end