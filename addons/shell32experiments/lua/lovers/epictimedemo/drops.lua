
drops = {}

local pic = {}
pic[1] = love.graphics.newImage("pics/coin.png")
pic[1]:setFilter('nearest','nearest')

superjumpPic = love.graphics.newImage("pics/power/superjump.png")
superjumpPic:setFilter('nearest','nearest')
superJumpShow = false

superspeedPic = love.graphics.newImage("pics/power/superspeed.png")
superspeedPic:setFilter('nearest','nearest')
superSpeedShow = false

local superJumpTimer = 0
local superSpeedTimer = 0

function drops:spawn(x,y,kind,direction)
	table.insert(drops,{x = x,y = y,kind = kind,direction = direction,xvel = 0,yvel = -50,grav = 120,speed = 130,friction = 120,w = 16,h = 16})
end

function drops:load()
	
end

function drops:draw()
	for i,v in ipairs(drops) do 
		love.graphics.setBackgroundColor(bg_r,bg_g,bg_b,250)
		love.graphics.setColor(sky_r,sky_g,sky_b,250)
		if v.kind == 'coin' then 
			love.graphics.draw(pic[1],v.x,v.y,0,.6,.6)
		end
		if v.kind == 'superJump' then 
			love.graphics.draw(superjumpPic,v.x,v.y,0,1,1)
		end
		if v.kind == 'superSpeed' then 
			love.graphics.draw(superspeedPic,v.x,v.y,0,1,1)
		end
	end
end

function drops:update(dt)
	for i,v in ipairs(drops) do 
		if v.kind == 'coin' then 
			v.x = v.x + v.xvel * dt
			v.y = v.y + v.yvel * dt
			v.yvel = v.yvel + v.grav * dt
			if v.direction == 'left' then 
				v.xvel = v.xvel - v.speed * dt
			end
			if v.direction == 'right' then 
				v.xvel = v.xvel + v.speed * dt
			end
			if v.xvel > 0 then 
				v.xvel = v.xvel - v.friction * dt 
			end
			if v.xvel < 0 then 
				v.xvel = v.xvel + v.friction * dt 
			end
			if player.x + player.w >= v.x and 
				player.x <= v.x + v.w and 
				player.y + player.y >= v.y and 
				player.y <= v.y + v.h then  
				table.remove(drops,i)
				player.coins = player.coins + 1
				sound:play("coin")
			end
		for ii,vv in ipairs(solid) do 
			if v.y + v.h >= vv.y and
			v.y + (v.h * .5) <= vv.y + (vv.h * .5) and
			v.x + v.w*.5 >= vv.x + extra and
			v.x + extra <= vv.x + vv.w*.5 then
			v.yvel = 0
			v.y = vv.y - 3
			v.xvel = 0
				end
			end
		end --
		if v.kind == 'superJump' then 
			v.y = v.y + v.yvel * dt
			v.yvel = v.yvel + v.grav * dt
			if player.x + player.w >= v.x and 
				player.x <= v.x + v.w and 
				player.y + player.y >= v.y and 
				player.y <= v.y + v.h then 
				table.remove(drops,i)
				sound:play("powers")
				text:add(player.x,player.y - 40,"Super Jump",'power')
				player.jumpHeight = 300
				superJumpShow = true 
			end
		for ii,vv in ipairs(solid) do 
			if v.x + v.w*.5 >= vv.x and 
				v.x <= vv.x + vv.w*.5 and 
				v.y + v.h*.5 >= vv.y and 
				v.y <= vv.y + vv.h*.5 then 
			v.yvel = 0
			v.y = vv.y - v.h*.5
			v.xvel = 0
				end
			end
		end
	if superJumpShow then 
		superSpeedTimer = 6
		superJumpTimer = superJumpTimer + dt 
		if superJumpTimer > 6 then 
			superJumpShow = false 
			superJumpTimer = 0
			player.jumpHeight = 200
	end
end--
	if v.kind == 'superSpeed' then 
			v.y = v.y + v.yvel * dt
			v.yvel = v.yvel + v.grav * dt
			if player.x + player.w >= v.x and 
				player.x <= v.x + v.w and 
				player.y + player.y >= v.y and 
				player.y <= v.y + v.h then 
				table.remove(drops,i)
				sound:play("powers")
				text:add(player.x,player.y - 40,"Super Speed",'power')
				player.speed = 4400
				maxspeed = 500
				superSpeedShow = true 
				superJumpTimer = 0
			end
		for ii,vv in ipairs(solid) do 
			if v.x + v.w*.5 >= vv.x and 
				v.x <= vv.x + vv.w*.5 and 
				v.y + v.h*.5 >= vv.y and 
				v.y <= vv.y + vv.h*.5 then 
			v.yvel = 0
			v.y = vv.y - v.h*.5
			v.xvel = 0
				end
			end
		end
	end
	if superSpeedShow then 
		superJumpTimer = 6
		superSpeedTimer = superSpeedTimer + dt 
		if superSpeedTimer > 6 then 
			superSpeedShow = false 
			superSpeedTimer = 0
			player.speed = 1200
			maxspeed = 130
		end
	end
end