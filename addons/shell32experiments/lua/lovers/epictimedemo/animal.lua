math.randomseed(os.time())
math.random()
math.random()
math.random()

anim = {}

birdLoad = true
bunnyLoad = true
squirrelLoad = true

bird = {}
bird.pic = {}
bird.pic[1] = love.graphics.newImage("pics/animals/birdL.png")
bird.pic[1]:setFilter('nearest','nearest')
bird.pic[2] = love.graphics.newImage("pics/animals/birdL2.png")
bird.pic[2]:setFilter('nearest','nearest')
bird.pic[3] = love.graphics.newImage("pics/animals/birdR.png")
bird.pic[3]:setFilter('nearest','nearest')
bird.pic[4] = love.graphics.newImage("pics/animals/birdR2.png")
bird.pic[4]:setFilter('nearest','nearest')
bunny = {}
bunny.pic = {}
bunny.pic[1] = love.graphics.newImage("pics/animals/bunnyL.png")
bunny.pic[1]:setFilter('nearest','nearest')
bunny.pic[2] = love.graphics.newImage("pics/animals/bunnyL2.png")
bunny.pic[2]:setFilter('nearest','nearest')
bunny.pic[3] = love.graphics.newImage("pics/animals/bunnyR.png")
bunny.pic[3]:setFilter('nearest','nearest')
bunny.pic[4] = love.graphics.newImage("pics/animals/bunnyR2.png")
bunny.pic[4]:setFilter('nearest','nearest')
squirrel = {}
squirrel.pic = {}
squirrel.pic[1] = love.graphics.newImage("pics/animals/squirrel1L.png")
squirrel.pic[1]:setFilter('nearest','nearest')
squirrel.pic[2] = love.graphics.newImage("pics/animals/squirrel2L.png")
squirrel.pic[2]:setFilter('nearest','nearest')
squirrel.pic[3] = love.graphics.newImage("pics/animals/squirrel1R.png")
squirrel.pic[3]:setFilter('nearest','nearest')
squirrel.pic[4] = love.graphics.newImage("pics/animals/squirrel2R.png")
squirrel.pic[4]:setFilter('nearest','nearest')

local blood = love.graphics.newImage("pics/particules/blood.png")
blood:setFilter('nearest','nearest')

loadAnimal = true

function bird:spawn(x,y)
	table.insert(bird,{x=x,y=y,pic=bird.pic[1],speed=math.random(40,70),dir=math.random(1,2),animtime=0})
end

function bunny:spawn(x,y)
	table.insert(bunny,{x=x,y=y,pic=bunny.pic[1],respawn=0,hit="hit"..math.random(1,4),attackedHeight=math.random(10,20),attacked=false,run=false,runtime=0,runMaxTime=math.random(4,6),runspeed=60,health=math.random(6,8),defense=2,speed=math.random(10,15),dir=math.random(0,2),stilldir=math.random(1,2),takeABreak=0,moveAgain=0,animtime=0,w=bunny.pic[1]:getWidth(),h=bunny.pic[1]:getHeight()})
end

function squirrel:spawn(x,y)
	table.insert(squirrel,{x=x,y=y,pic=squirrel.pic[1],respawn=0,hit="hit"..math.random(1,4),attackedHeight=math.random(10,20),attacked=false,run=false,runtime=0,runMaxTime=math.random(4,6),defense=1,runspeed=90,health=math.random(3,6),speed=math.random(10,15),dir=math.random(0,2),stilldir=math.random(1,2),takeABreak=0,moveAgain=0,animtime=0,w=squirrel.pic[1]:getWidth(),h=squirrel.pic[1]:getHeight()})
end

function anim:load() 
	for bi = 4 , math.random(4,7) do
		if birdLoad then  
		bird:spawn(100+math.random(110,700),2-math.random(5,20)+math.random(14,35))
		end
	end
	for bu = 2 , math.random(3,5) do 
		if bunnyLoad then
		bunny:spawn(math.random(100,250)+math.random(410,600),118)
		end
	end
	for sq = 2 , math.random(3,5) do 
		if squirrelLoad then  
		squirrel:spawn(math.random(200,250)+math.random(430,600),118)
			end
		end
	end

function anim:draw()
if loadAnimal then 
	love.graphics.setColor(sky_r,sky_g,sky_b,250)
	for i,v in ipairs(bird) do 
		love.graphics.draw(v.pic,v.x,v.y)
	end
	for i,v in ipairs(bunny) do 
		love.graphics.draw(v.pic,v.x,v.y,0,0.7,0.7)
	end
	for i,v in ipairs(squirrel) do 
		love.graphics.draw(v.pic,v.x,v.y,0,0.7,0.7)
		end
	end
end

function bird:logic(dt)
	for i,v in ipairs(bird) do 
		if v.dir == 1 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = bird.pic[1]
			end
			if v.animtime > .4 then 
				v.pic = bird.pic[2]
				v.animtime = 0
			end
			v.x = v.x - v.speed*dt
			--map bounding
			if v.x < -30  then v.x = 1400 end
		end
		if v.dir == 2 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = bird.pic[3]
			end
			if v.animtime > .4 then 
				v.pic = bird.pic[4]
				v.animtime = 0
			end
			v.x = v.x + v.speed*dt
			--map bounding
			if v.x > 1400  then v.x = -30 end
		end
	end
end

function bunny:logic(dt)
	for i,v in ipairs(bunny) do 
		local moveAgain = math.random(7,12)
		local takeABreak = math.random(7,15)

		if v.dir == 1 or v.dir == 2 and not v.attacked then 
			v.takeABreak = v.takeABreak + dt
			if v.takeABreak >= takeABreak then 
				v.dir = math.random(0,2)
				v.takeABreak = math.random(-6,-4)
			end
		end

		--stay still for some seconds
		if v.dir == 0 then 
			v.moveAgain = v.moveAgain + dt
			if v.moveAgain > moveAgain then 
				v.moveAgain = 0
				v.dir = math.random(1,2)
			end
		end
		if v.dir == 0 then 
			if v.stilldir == 1 then 
				v.animtime = 0
				v.pic = bunny.pic[1]
			end
			if v.stilldir == 2 then 
				v.animtime = 0
				v.pic = bunny.pic[3]
			end
		end
		if v.dir == 1 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = bunny.pic[1]
			end
			if v.animtime > .4 then 
				v.pic = bunny.pic[2]
				v.animtime = 0
			end
			v.x = v.x - v.speed*dt
			--map bounding
			if v.x < -30  then v.x = 1300 end
		end
		if v.dir == 2 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = bunny.pic[3]
			end
			if v.animtime > .4 then 
				v.pic = bunny.pic[4]
				v.animtime = 0
			end
			v.x = v.x + v.speed*dt
			--map bounding
			if v.x > 1400  then v.x = -30 end
		end
			--arrow damage
		if  a[player.arrownum].x + a[player.arrownum].w >= v.x and 
				a[player.arrownum].y + a[player.arrownum].h >= v.y and 
        		a[player.arrownum].x <= v.x+v.w and 
       			a[player.arrownum].y <= v.y+v.h then
       		v.health = v.health - (a[player.arrownum].damage+bow[player.bownum].damage*.5) + v.defense * dt
       		table.remove(arrow,#arrow - #arrow + 1)
       		sound:play(""..v.hit)
       		if v.health > 0 then 
       			place_effect(v.x,v.y,2,44,44,blood)
       		end
       		if v.health <= 0 then 
       			table.remove(bunny,i)
       			table.remove(arrow,#arrow - #arrow + 1) 
       			bunny_kill = bunny_kill + 1
       			v.respawn = v.respawn + dt
       			place_effect(v.x+v.w*.5,v.y+v.h*.5,2,2,2,blood)
       			if v.respawn > math.random(1,3) then 
       				bunny:spawn(100+math.random(110,700),133)
       			end
       			break 
        	end
    	end 
    	--punch damage
    if player.givepunch then 	
    	if  player.x + player.w+5 >= v.x and 
				player.y + player.h >= v.y and 
        		player.x <= v.x+v.w and 
       			player.y <= v.y+v.h then
       		v.health = v.health - player.givepunchdamage + v.defense * dt
       		place_effect(v.x+v.w*.5,v.y+v.h*.5,4,5,5,blood,2)
       		v.attacked = true
       		if v.health <= 0 then 
       			table.remove(bunny,i) 
       			sound:play(""..v.hit)
       			v.respawn = v.respawn + dt
       			place_effect(v.x,v.y,4,6,6,blood)
       			if v.respawn > math.random(1,3) then 
       				bunny:spawn(100+math.random(110,700),133)
       			end
       			break 
        	end
    	end 
    else 
    	v.attacked = false
    end

    if v.attacked then 
    	if player.state == 'idleL' then 
    		v.x = v.x - 50*dt
    		v.y = v.y - v.attackedHeight*dt
    		v.dir = 1
    		v.run = true
    		place_effect(v.x+v.w*.5,v.y+v.h*.5,145,2,2,blood,60)
    	end
    	if player.state == 'idleR' then 
    		v.x = v.x + 50*dt
    		v.y = v.y - v.attackedHeight*dt
    		v.dir = 2
    		v.run = true
    		place_effect(v.x+v.w*.5,v.y+v.h*.5,45,2,2,blood,60)
    	end
	end

	--after they where attacked make them run
	--left
	if v.run and v.dir == 1 then 
		if v.runtime >= 0 then 
			v.x = v.x - v.runspeed*dt
		else 
			v.runtime = v.runtime + dt
		end
		--stop from running after an ammount of time
		if v.runtime >= v.runMaxTime then 
			v.runtime = 0 
			v.run = false
			end
	end
	--right
	if v.run and v.dir == 2 then 
		if v.runtime >= 0 then 
			v.x = v.x + v.runspeed*dt
		else 
			v.runtime = v.runtime + dt
		end
		--stop from running after an ammount of time
		if v.runtime >= v.runMaxTime then
		 v.runtime = 0 
		 v.run = false 
		end
	end

	if not v.attacked and v.y < 117 then 
    	v.y = v.y + 330*dt
	end

	if not v.attacked and v.y >= 118 then 
		v.y = 118
	end 
	--end give punch
	end
end


function squirrel:logic(dt)
	for i,v in ipairs(squirrel) do 
		local moveAgain = math.random(7,12)
		local takeABreak = math.random(7,15)

		if v.dir == 1 or v.dir == 2 then 
			v.takeABreak = v.takeABreak + dt
			if v.takeABreak >= takeABreak then 
				v.dir = math.random(0,2)
				v.takeABreak = math.random(-6,-4)
			end
		end

		--stay still for some seconds
		if v.dir == 0 and not v.attacked then 
			v.moveAgain = v.moveAgain + dt
			if v.moveAgain > moveAgain then 
				v.moveAgain = 0
				v.dir = math.random(1,2)
			end
		end
		if v.dir == 0 then 
			if v.stilldir == 1 then 
				v.animtime = 0
				v.pic = squirrel.pic[1]
			end
			if v.stilldir == 2 then 
				v.animtime = 0
				v.pic = squirrel.pic[3]
			end
		end
		if v.dir == 1 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = squirrel.pic[1]
			end
			if v.animtime > .4 then 
				v.pic = squirrel.pic[2]
				v.animtime = 0
			end
			v.x = v.x - v.speed*dt
			--map bounding
			if v.x < -30  then v.x = 1400 end
		end
		if v.dir == 2 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = squirrel.pic[3]
			end
			if v.animtime > .4 then 
				v.pic = squirrel.pic[4]
				v.animtime = 0
			end
			v.x = v.x + v.speed*dt
			--map bounding
			if v.x > 1400  then v.x = -30 end
		end
		--arrow kill
		if  a[player.arrownum].x + a[player.arrownum].w >= v.x and 
				a[player.arrownum].y + a[player.arrownum].h >= v.y and 
        		a[player.arrownum].x <= v.x+v.w and 
       			a[player.arrownum].y <= v.y+v.h then

       		v.health = v.health - (a[player.arrownum].damage) + v.defense * dt 
       		table.remove(arrow,#arrow - #arrow + 1)
       		sound:play(""..v.hit)
       		if v.health > 0 then
       			place_effect(v.x+v.w*.5,v.y+v.h*.5,4,5,5,blood)
       		end
       		if v.health <= 0 then 
       			table.remove(squirrel,i) 
       			table.remove(arrow,#arrow - #arrow + 1)
       			v.respawn = v.respawn + dt
       			place_effect(v.x+v.w*.5,v.y+v.h*.5,4,6,6,blood)
       			if v.respawn > math.random(1,3) then 
       				squirrel:spawn(math.random(-40,-20)+math.random(110,700),133)
       			end
       			break 
        	end
    	end
    	--punch damage
    if player.givepunch then 	
    	if  player.x + player.w+5 >= v.x and 
				player.y + player.h >= v.y and 
        		player.x <= v.x+v.w and 
       			player.y <= v.y+v.h then
       		v.health = v.health - player.givepunchdamage + v.defense * dt
       		place_effect(v.x,v.y,5,3,3,blood,2)
       		v.attacked = true
       		if v.health <= 0 then 
       			v.respawn = v.respawn + dt
       			table.remove(squirrel,i) 
       			sound:play(""..v.hit)
       			place_effect(v.x+v.w*.5,v.y+v.h*.5,4,2,2,blood)
       			if v.respawn > math.random(1,3) then 
       				squirrel:spawn(math.random(-40,-20)+math.random(110,700),133)
       			end
       			break 
        	end
    	end 
    else 
    	v.attacked = false
    end

    if v.attacked then 
    	if player.state == 'idleL' then 
    		v.x = v.x - 50*dt
    		v.dir = 1
    		v.y = v.y - v.attackedHeight*dt
    		v.run = true
    		place_effect(v.x+v.w*.5,v.y+v.h*.5,145,2,2,blood,2)
    	end
    	if player.state == 'idleR' then 
    		v.x = v.x + 50*dt
    		v.dir = 2
    		v.y = v.y - v.attackedHeight*dt
    		v.run = true
    		place_effect(v.x+v.w*.5,v.y+v.h*.5,145,2,2,blood,2)
    	end
	end

	if not v.attacked and v.y < 117 then 
    	v.y = v.y + 330*dt
	end

	if not v.attacked and v.y >= 118 then 
		v.y = 118
	end 
	--end give punch

	--after they where attacked make them run
	--left
	if v.run and v.dir == 1 then 
		if v.runtime >= 0 then 
			v.x = v.x - v.runspeed*dt
		else 
			v.runtime = v.runtime + dt
		end
		--stop from running after an ammount of time
		if v.runtime >= v.runMaxTime then 
			v.runtime = 0 
			v.run = false 
		end
	end
	--right
	if v.run and v.dir == 2 then 
		if v.runtime >= 0 then 
			v.x = v.x + v.runspeed*dt
		else 
			v.runtime = v.runtime + dt
		end
		--stop from running after an ammount of time
		if v.runtime >= v.runMaxTime then 
			v.runtime = 0 
			v.run = false 
		end
	end

	end
end

function anim:update(dt)
	if loadAnimal then 
	bird:logic(dt)
	bunny:logic(dt)
	squirrel:logic(dt)
	end
end
