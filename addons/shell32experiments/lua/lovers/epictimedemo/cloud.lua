

cloud = {}
cloud.pic = {}

cloud.pic[1] = love.graphics.newImage('pics/env/cloud1.png')
cloud.pic[1]:setFilter('nearest','nearest')
cloud.pic[2] = love.graphics.newImage('pics/env/cloud2.png')
cloud.pic[2]:setFilter('nearest','nearest')
cloud.pic[3] = love.graphics.newImage('pics/env/cloud3.png')
cloud.pic[3]:setFilter('nearest','nearest')

local minNumber = 3
local maxNumber = 9
loadClouds = true

function cloud:spawn(x,y)
	table.insert(cloud,{x=x,y=y,pic=math.random(1,3),speed=math.random(10,30),dir=math.random(0,2),stilldir=6,newdir=math.random(1,2)})
end

function cloud:load()
	for numberOfClouds = minNumber ,maxNumber do 
	cloud:spawn(100+math.random(110,700),2-math.random(5,10)+math.random(10,30))
	end
end

function cloud:draw()
love.graphics.setColor(255,255,255,250)
if isday or setday or loadClouds then 
	for i,v in ipairs(cloud) do 
		love.graphics.setColor(255,255,255)
		if v.pic == 1 then 
			love.graphics.draw(cloud.pic[1],v.x,v.y)
		end
		if v.pic == 2 then 
			love.graphics.draw(cloud.pic[2],v.x,v.y)
		end
		if v.pic == 3 then 
			love.graphics.draw(cloud.pic[3],v.x,v.y)
			end
		end
	end
end

function cloud:update(dt)
if isday or setday or loadClouds then 
	for i,v in ipairs(cloud) do 
		if v.dir == 0 then 
			v.stilldir = v.stilldir - dt
			if v.stilldir <= 0 then 
				v.dir = 1 
				v.stilldir = 0
			end
		end
		if v.dir == 1 then 
			v.x = v.x + v.speed*dt
		end
		if v.dir == 2 then 
			v.x = v.x - v.speed*dt
		end

		--map bounds
		if v.x < -50 then 
			table.remove(cloud,i)
			cloud:spawn(100+math.random(110,700),2-math.random(5,10)+math.random(10,30))
		end
		if v.x > 1300 then 
			table.remove(cloud,i)
			cloud:spawn(100+math.random(110,700),2-math.random(5,10)+math.random(10,24))
			end
		end
	end
end