math.randomseed(os.time())
math.random()
math.random()
math.random()

vil = {}

local pic1 = {}
local pic2 = {}
local pic3 = {}

loadShops = false
loadVil = false
loadKeepers = false

function vil:load()
pic1[1] = love.graphics.newImage('pics/villagers/1L.png')
pic1[1]:setFilter('nearest','nearest')
pic1[2] = love.graphics.newImage('pics/villagers/1L2.png')
pic1[2]:setFilter('nearest','nearest')
pic1[3] = love.graphics.newImage('pics/villagers/1L3.png')
pic1[3]:setFilter('nearest','nearest')
pic1[4] = love.graphics.newImage('pics/villagers/1L4.png')
pic1[4]:setFilter('nearest','nearest')

pic1[5] = love.graphics.newImage('pics/villagers/1R.png')
pic1[5]:setFilter('nearest','nearest')
pic1[6] = love.graphics.newImage('pics/villagers/1R2.png')
pic1[6]:setFilter('nearest','nearest')
pic1[7] = love.graphics.newImage('pics/villagers/1R3.png')
pic1[7]:setFilter('nearest','nearest')
pic1[8] = love.graphics.newImage('pics/villagers/1R4.png')
pic1[8]:setFilter('nearest','nearest')

	
pic2[1] = love.graphics.newImage('pics/villagers/2L.png')
pic2[1]:setFilter('nearest','nearest')
pic2[2] = love.graphics.newImage('pics/villagers/2L2.png')
pic2[2]:setFilter('nearest','nearest')
pic2[3] = love.graphics.newImage('pics/villagers/2L3.png')
pic2[3]:setFilter('nearest','nearest')
pic2[4] = love.graphics.newImage('pics/villagers/2L4.png')
pic2[4]:setFilter('nearest','nearest')

pic2[5] = love.graphics.newImage('pics/villagers/2R.png')
pic2[5]:setFilter('nearest','nearest')
pic2[6] = love.graphics.newImage('pics/villagers/2R2.png')
pic2[6]:setFilter('nearest','nearest')
pic2[7] = love.graphics.newImage('pics/villagers/2R3.png')
pic2[7]:setFilter('nearest','nearest')
pic2[8] = love.graphics.newImage('pics/villagers/2R4.png')
pic2[8]:setFilter('nearest','nearest')


pic3[1] = love.graphics.newImage('pics/villagers/3L.png')
pic3[1]:setFilter('nearest','nearest')
pic3[2] = love.graphics.newImage('pics/villagers/3L2.png')
pic3[2]:setFilter('nearest','nearest')
pic3[3] = love.graphics.newImage('pics/villagers/3L3.png')
pic3[3]:setFilter('nearest','nearest')
pic3[4] = love.graphics.newImage('pics/villagers/3L4.png')
pic3[4]:setFilter('nearest','nearest')

pic3[5] = love.graphics.newImage('pics/villagers/3R.png')
pic3[5]:setFilter('nearest','nearest')
pic3[6] = love.graphics.newImage('pics/villagers/3R2.png')
pic3[6]:setFilter('nearest','nearest')
pic3[7] = love.graphics.newImage('pics/villagers/3R3.png')
pic3[7]:setFilter('nearest','nearest')
pic3[8] = love.graphics.newImage('pics/villagers/3R4.png')
pic3[8]:setFilter('nearest','nearest')	

shop1 = love.graphics.newImage('pics/shops/shop1.png')
shop1:setFilter('nearest','nearest')
shop2 = love.graphics.newImage('pics/shops/shop2.png')
shop2:setFilter('nearest','nearest')
shop3 = love.graphics.newImage('pics/shops/shop3.png')
shop3:setFilter('nearest','nearest')

end

function vil:spawn(x,y,kind)
	table.insert(vil,{x=x,y=y,pic=pic1[1],kind=kind,animtime=0,speed=math.random(25,35),w=16,h=16,dir=math.random(0,2),godir=0,stilldir=math.random(1,2)})	
end

function vil:onelogic(dt)
	for i,v in ipairs(vil) do 
		if v.kind == 1 then 
			if v.dir == 1 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = pic1[1]
			end
			if v.animtime > .4 then 
				v.pic = pic1[2]
			end
			if v.animtime > .6 then 
				v.pic = pic1[3]
			end
			if v.animtime > .8 then 
				v.pic = pic1[4]
				v.animtime = 0
			end
			v.x = v.x - v.speed*dt
			--map bounding
			if v.x < -30  then v.x = 1400 end
		end
		if v.dir == 2 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = pic1[5]
			end
			if v.animtime > .4 then 
				v.pic = pic1[6]
			end
			if v.animtime > .6 then 
				v.pic = pic1[7]
			end
			if v.animtime > .8 then 
				v.pic = pic1[8]
				v.animtime = 0
			end
			v.x = v.x + v.speed*dt
			--map bounding
			if v.x > 1400  then v.x = -30 end
			end
		end

		--dont let them walk like zombies
		if v.dir == 1 then 
			v.godir = v.godir + dt
			if v.godir > math.random(6,9) - math.random(1,2) then 
				v.dir = 0
				v.godir = 0
			end
		end

		if v.dir == 2 then 
			v.godir = v.godir + dt
			if v.godir > math.random(6,8) - math.random(1,2) then 
				v.dir = 0
				v.godir = 0
			end
		end

		if v.dir == 0 then
			v.godir = v.godir + dt 
			if v.godir > math.random(2,4) then 
				v.stilldir = math.random(1,2)
				v.dir = math.random(0,2)
				v.godir = 0
			end
		end

		if v.dir == 0 then 
			if v.stilldir == 1 then 
				if v.kind == 1 then 
					v.pic = pic1[1]
				end
			end
			if v.stilldir == 2 then 
				if v.kind == 1 then 
					v.pic = pic1[5]
				end
			end
		end

	end
end

function vil:twologic(dt)
	for i,v in ipairs(vil) do 
		if v.kind == 2 then 
			if v.dir == 1 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = pic2[1]
			end
			if v.animtime > .4 then 
				v.pic = pic2[2]
			end
			if v.animtime > .6 then 
				v.pic = pic2[3]
			end
			if v.animtime > .8 then 
				v.pic = pic2[4]
				v.animtime = 0
			end
			v.x = v.x - v.speed*dt
			--map bounding
			if v.x < -30  then v.x = 1400 end
		end
		if v.dir == 2 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = pic2[5]
			end
			if v.animtime > .4 then 
				v.pic = pic2[6]
			end
			if v.animtime > .6 then 
				v.pic = pic2[7]
			end
			if v.animtime > .8 then 
				v.pic = pic2[8]
				v.animtime = 0
			end
			v.x = v.x + v.speed*dt
			--map bounding
			if v.x > 1400  then v.x = -30 end
			end
		end

		--dont let them walk like zombies
		if v.dir == 1 then 
			v.godir = v.godir + dt
			if v.godir > math.random(8,12) - math.random(1,2) then 
				v.dir = 0
				v.godir = 0
			end
		end

		if v.dir == 2 then 
			v.godir = v.godir + dt
			if v.godir > math.random(8,10) - math.random(1,2) then 
				v.dir = 0
				v.godir = 0
			end
		end

		if v.dir == 0 then
			v.godir = v.godir + dt 
			if v.godir > math.random(2,4) then 
				v.stilldir = math.random(1,2)
				v.dir = math.random(0,2)
				v.godir = 0
			end
		end

		if v.dir == 0 then 
			if v.stilldir == 1 then 
				if v.kind == 2 then 
					v.pic = pic2[1]
				end
			end
			if v.stilldir == 2 then 
				if v.kind == 2 then 
					v.pic = pic2[5]
				end
			end
		end

	end
end

function vil:threelogic(dt)
	for i,v in ipairs(vil) do 
		if v.kind == 3 then 
			if v.dir == 1 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = pic3[1]
			end
			if v.animtime > .4 then 
				v.pic = pic3[2]
			end
			if v.animtime > .6 then 
				v.pic = pic3[3]
			end
			if v.animtime > .8 then 
				v.pic = pic3[4]
				v.animtime = 0
			end
			v.x = v.x - v.speed*dt
			--map bounding
			if v.x < -30  then v.x = 1400 end
		end
		if v.dir == 2 then 
			v.animtime = v.animtime + dt
			if v.animtime > .2 then 
				v.pic = pic3[5]
			end
			if v.animtime > .4 then 
				v.pic = pic3[6]
			end
			if v.animtime > .6 then 
				v.pic = pic3[7]
			end
			if v.animtime > .8 then 
				v.pic = pic3[8]
				v.animtime = 0
			end
			v.x = v.x + v.speed*dt
			--map bounding
			if v.x > 1400  then v.x = -30 end
			end
		end

		--dont let them walk like zombies
		if v.dir == 1 then 
			v.godir = v.godir + dt
			if v.godir > math.random(6,9) - math.random(1,2) then 
				v.dir = 0
				v.godir = 0
			end
		end

		if v.dir == 2 then 
			v.godir = v.godir + dt
			if v.godir > math.random(6,8) - math.random(1,2) then 
				v.dir = 0
				v.godir = 0
			end
		end

		if v.dir == 0 then
			v.godir = v.godir + dt 
			if v.godir > math.random(2,4) then 
				v.stilldir = math.random(1,2)
				v.dir = math.random(0,2)
				v.godir = 0
			end
		end

		if v.dir == 0 then 
			if v.stilldir == 1 then 
				if v.kind == 3 then 
					v.pic = pic3[1]
				end
			end
			if v.stilldir == 2 then 
				if v.kind == 3 then 
					v.pic = pic3[5]
				end
			end
		end

	end
end

function vil:update(dt)
	if loadShops then
	vil:onelogic(dt)
	vil:twologic(dt)
	vil:threelogic(dt)
	end
end

building = {}
function building:shopBuildingSpawn(x,y,kind)
	table.insert(building,{x=x,y=y,kind=kind})
end

function vil:draw()
for i,v in ipairs(building) do 
	if loadShops then 
		if v.kind == 1 then 
		love.graphics.draw(shop1,v.x,v.y)
		end
		if v.kind == 2 then 
		love.graphics.draw(shop2,v.x,v.y)
		end
		if v.kind == 3 then 
		love.graphics.draw(shop3,v.x,v.y)
			end
		end
	end
	for i,v in ipairs(vil) do 
		if loadVil then 
		love.graphics.draw(v.pic,v.x,v.y,0,1.2,1.2)
		end
	end
end
















