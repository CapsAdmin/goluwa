math.randomseed(os.time())
math.random()
math.random()
math.random()

enemy = {}
local alert = {}
alert.pic = love.graphics.newImage('pics/text/alert.png')
alert.pic:setFilter('nearest','nearest')
local blood =  love.graphics.newImage('pics/particules/blood.png')
blood:setFilter('nearest','nearest')

local gravity = 200

function enemy:load()
--Enemy pics
beastR = {}
beastR[1] = love.graphics.newImage('pics/enemies/beastR.png')
beastR[2] = love.graphics.newImage('pics/enemies/beastR2.png')
beastR[1]:setFilter('nearest','nearest')
beastR[2]:setFilter('nearest','nearest')

beastL = {}
beastL[1] = love.graphics.newImage('pics/enemies/beastL.png')
beastL[2] = love.graphics.newImage('pics/enemies/beastL2.png')
beastL[1]:setFilter('nearest','nearest')
beastL[2]:setFilter('nearest','nearest')

blobR = {}
blobR[1] = love.graphics.newImage('pics/enemies/blobR.png')
blobR[2] = love.graphics.newImage('pics/enemies/blobR2.png')
blobR[3] = love.graphics.newImage('pics/enemies/blobR3.png')
blobR[4] = love.graphics.newImage('pics/enemies/blobR4.png')
blobR[1]:setFilter('nearest','nearest')
blobR[2]:setFilter('nearest','nearest')
blobR[3]:setFilter('nearest','nearest')
blobR[4]:setFilter('nearest','nearest')

blobL = {}
blobL[1] = love.graphics.newImage('pics/enemies/blobL.png')
blobL[2] = love.graphics.newImage('pics/enemies/blobL2.png')
blobL[3] = love.graphics.newImage('pics/enemies/blobL3.png')
blobL[4] = love.graphics.newImage('pics/enemies/blobL4.png')
blobL[1]:setFilter('nearest','nearest')
blobL[2]:setFilter('nearest','nearest')
blobL[3]:setFilter('nearest','nearest')
blobL[4]:setFilter('nearest','nearest')

end

function enemy:spawn(x,y,health,id,pic)
	table.insert(enemy, {pic = pic,animtimer = 0,randomove=0,alert_able = true,alerted = false,alert_rad = 130,jumpheight = 150,forget_rad = 225,tracking = false,id = id,x = x,health = health,armor = 0, y = y,knockback = 50,damage = 0,hitable = true,hitimer = 0,yvel = 0, direction = "right",speed = 30,tspeed = math.random(60,80),drop=math.random(1,4),w = 16,h = 16})
end


function enemy:draw()
	for i,v in ipairs(enemy) do
		love.graphics.setBackgroundColor(bg_r,bg_g,bg_b,250)
		love.graphics.setColor(sky_r,sky_g,sky_b,250)
		love.graphics.draw(v.pic,v.x,v.y,0,1.1,1.1)
		if v.tracking == true then
			love.graphics.setColor(255,255,255)
			love.graphics.draw(alert.pic,v.x,v.y - 16)
		end
	end
end
function enemy:update(dt)
	for i,v in ipairs(enemy) do
		if v.id == "beast" then

			v.animtimer = v.animtimer + dt
			if v.direction == "right" then
				if v.animtimer > 0.1 then
					v.pic = beastR[2]
				end
				if v.animtimer > 0.2 then
					v.pic = beastR[1]
					v.animtimer = 0
				end
			end
			if v.direction == "left" then
				if v.animtimer > 0.1 then
					v.pic = beastL[2]
				end
				if v.animtimer > 0.2 then
					v.pic = beastL[1]
					v.animtimer = 0
				end
			end
		end
		if v.id == "blob" then

			v.animtimer = v.animtimer + dt
			if v.direction == "right" then
				if v.animtimer > 0.1 then
					v.pic = blobR[2]
				end
				if v.animtimer > 0.2 then
					v.pic = blobR[3]
				end
				if v.animtimer > 0.3 then
					v.pic = blobR[4]
				end
				if v.animtimer > 0.4 then
					v.pic = blobR[3]
				end
				if v.animtimer > 0.5 then
					v.pic = blobR[2]
				end
				if v.animtimer > 0.6 then
					v.pic = blobR[1]
					v.animtimer = 0
				end
			end
			if v.direction == "left" then
				if v.animtimer > 0.1 then
					v.pic = blobL[2]
				end
				if v.animtimer > 0.2 then
					v.pic = blobL[3]
				end
				if v.animtimer > 0.3 then
					v.pic = blobL[4]
				end
				if v.animtimer > 0.4 then
					v.pic = blobL[3]
				end
				if v.animtimer > 0.5 then
					v.pic = blobL[2]
				end
				if v.animtimer > 0.6 then
					v.pic = blobL[1]
					v.animtimer = 0
				end
			end
		end

		if v.health <= 0 then 
			drops:spawn(v.x,v.y,'coin',v.direction)
			if v.drop == 3 then 
			drops:spawn(v.x,v.y,'superJump',v.direction)
			end
			if v.drop == 2 then
			drops:spawn(v.x,v.y,'superSpeed',v.direction)
			end
			v.hitable = false
			table.remove(enemy, i)
		end

		if v.id == "beast" then
			v.damage = 0.5
			v.armor = .6
			v.knockback = 225
		end
		if v.id == 'blob' then
			v.damage = 1
			v.armor = .3
			v.knockback = 100
		end

		if player.hide == false then -- Add player stealth stat
			if player.x + (player.w * .5) > v.x - v.alert_rad and
			player.x + (player.w * .5) < v.x + v.alert_rad - 16 and
			player.y + player.h * .5 > v.y - v.alert_rad and
			player.y + player.h * .5 < v.y + v.alert_rad then
				v.tracking = true
			end
		end
		if player.hide == true then
			if player.x + (player.w * .5) > v.x - v.alert_rad + 64 and
			player.x + (player.w * .5) < v.x + v.alert_rad - 64 and
			player.y + player.h * .5 > v.y - v.alert_rad + 64 and
			player.y + player.h * .5 < v.y + v.alert_rad - 64 then
				v.tracking = true				
			end
		end
		
		--escape 
		if player.x + player.w * .5 > v.x + v.forget_rad or
		player.x + player.w * .5 < v.x - v.forget_rad then
			v.tracking = false
			
		end
		if v.tracking == true then
			if player.x + player.w * .5 - 4 > v.x + (v.w * .5) then
				v.x = v.x + v.tspeed * dt
				v.direction = "right"
			end
			if player.x + player.w * .5 + 4 < v.x + (v.w * .5) then
				v.x = v.x - v.tspeed * dt
				v.direction = "left"
			end
		end


		if v.tracking == false then
		v.randomove = v.randomove + dt

		if v.randomove >= math.random(2,5) then 
			if math.random(2,4) <= 2 then 
				v.direction = 'left'
			else 
				v.direction = 'right'
			end
			v.randomove = 0
		end

		if v.direction == "right" then
			v.x = v.x + v.speed * dt
		end
		if v.direction == "left" then
			v.x = v.x - v.speed * dt
		end

		end
		v.y = v.y + v.yvel * dt
		v.yvel = v.yvel + gravity * dt
		for i,va in ipairs(solid) do
		if v.x + v.w > va.x and
		v.x + (v.w * .5) < va.x + (va.w * .5) and
		v.y + v.h > va.y + extra and
		v.y + extra < va.y + va.h then
			if v.tracking == false then
				v.direction = "left"
			end
			v.x = va.x - v.w
			v.xvel = 0
		end
		if v.y + v.h > va.y and
		v.y + (v.h * .5) < va.y + (va.h * .5) and
		v.x + v.w > va.x + extra and
		v.x + extra < va.x + va.w then
			v.y = va.y - v.h
			v.yvel = 0
			v.grounded = true
		end
		if v.x < va.x + va.w and
		v.x + (v.w * .5) > va.x + (va.w * .5) and
		v.y + v.h > va.y + extra and
		v.y + extra < va.y + va.h then
			if v.tracking == false then
				v.direction = "right"
			end
			v.x = va.x + va.w
			v.xvael = 0
		end
		if v.y < va.y + va.h and
		v.y + (v.h * .5) > va.y + (va.h * .5) and
		v.x + v.w > va.x + extra and
		v.x + extra < va.x + va.w then
			v.yvael = 0
			v.y = va.y + va.h	
		end
		end
		if v.x + v.w > player.x and
		v.x < player.x + player.w and
		v.y + v.h > player.y and
		v.y < player.y + player.h then
			if v.hitable == true then
				place_effect(v.x,v.y,2,2,2,blood)
				player.health = player.health - v.damage
				
				if player.x + (player.w * .5) < v.x + (v.w * .5) then
					player.xvel = -v.knockback
					player.yvel = -v.knockback * .5
				end
				if player.x + (player.w * .5) > v.x + (v.w * .5) then
					player.xvel = v.knockback
					player.yvel = -v.knockback * .5
				end
				sound:play("hurt")
			end
		end	
		for ia,va in ipairs(arrow) do
			if va.x + va.w > v.x and
			va.x < v.x + v.w and
			va.y + va.h > v.y and
			va.y < v.y + v.h then
			v.tracking = true
				place_effect(v.x,v.y,2,8,8,blood)
				--critical damage
				if math.random(0,8) == 0 then 
					va.damage=va.damage+va.damage*.5 
					text:add(va.x+va.w*.5,va.y+va.h*.5,""..va.damage,'critical',v.direction)
				end 
				v.health = v.health - va.damage + v.armor
				sound:play("hit5")
				text:add(va.x+va.w*.5,va.y+va.h*.5,""..va.damage,'combat',v.direction)
				table.remove(arrow, ia)
			end
			--if he is not attacking me but the arrow hits him then i want to track the player
			if va.x + va.w > v.x and
			va.x < v.x + v.w and
			va.y + va.h > v.y and
			va.y < v.y + v.h and not v.tracking then
				v.tracking = true
			end
		end

		--animal attack
	if v.hitable then 
		for ii,vv in ipairs(bunny) do 
			for ia,va in ipairs(squirrel) do 
				if v.x + v.w >= vv.x and 
					v.x <= vv.x + vv.w and 
					v.y + v.h >= vv.y and 
					v.y <= vv.y + vv.h then 
					vv.run = true
					place_effect(vv.x,vv.y,2,2,2,blood)
					vv.health = vv.health - v.damage

					if vv.health <= 0 then 
						table.remove(bunny,ii)
					end

				end
				if v.x + v.w >= va.x and 
					v.x <= va.x + va.w and 
					v.y + v.h >= va.y and 
					v.y <= va.y + va.h then 
					va.run = true 
					place_effect(va.x,va.y,2,2,2,blood)
					va.health = va.health - v.damage
				
					if vv.health <= 0 then 
						table.remove(squirrel,ia)
						end
					end
				end
			end
		end

	end
end





