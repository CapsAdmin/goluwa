math.randomseed(os.time())
math.random()
math.random()
math.random()

env = {}

local bush = { }
 flower = { }
mountain = { }
local layer = {}
layer[1] = {speed = 12}

env.pic = {}
env.pic[1] = love.graphics.newImage('pics/env/bush1.png')
env.pic[1]:setFilter('nearest','nearest')
env.pic[2] = love.graphics.newImage('pics/env/bush2.png')
env.pic[2]:setFilter('nearest','nearest')

env.pic[3] = love.graphics.newImage('pics/env/flower1.png')
env.pic[3]:setFilter('nearest','nearest')
env.pic[4] = love.graphics.newImage('pics/env/flower2.png')
env.pic[4]:setFilter('nearest','nearest')
env.pic[5] = love.graphics.newImage('pics/env/flower3.png')
env.pic[5]:setFilter('nearest','nearest')
env.pic[6] = love.graphics.newImage('pics/env/flower4.png')
env.pic[6]:setFilter('nearest','nearest')

env.pic[7] = love.graphics.newImage('pics/env/mountain1.png')
env.pic[7]:setFilter('nearest','nearest')
env.pic[8] = love.graphics.newImage('pics/env/mountain2.png')
env.pic[8]:setFilter('nearest','nearest')
env.pic[9] = love.graphics.newImage('pics/env/mountain3.png')
env.pic[9]:setFilter('nearest','nearest')

parallex = true
loadParalex = true

function bush:spawn(x,y)
	table.insert(bush,{x=x,y=y,pic=math.random(1,2)})
end

function flower:spawn(x,y)
	table.insert(flower,{x=x,y=y,pic=math.random(1,4)})
end

function mountain:spawn(x,y,layer,pic)
	table.insert(mountain,{x=x,y=y,layer=layer,pic=pic})
end

function env:load()
if loadParalex then 
	for i = 4 , math.random(5,12) do 
		bush:spawn(50 + math.random(200,400) + math.random(30,1000) + 39,100)
	end
	for i = 8 , math.random(10,18) do 
		flower:spawn(math.random(200,600) + math.random(330,1400) - math.random(200,300),119)
	end
	--munte
	mountain:spawn(-140,-15,3,env.pic[9])
	mountain:spawn(0,-15,3,env.pic[9])
	mountain:spawn(175+env.pic[9]:getWidth(),-15,3,env.pic[9])
	mountain:spawn(675+env.pic[9]:getWidth(),-15,3,env.pic[9])

	--deal
	mountain:spawn(-140,55,2,env.pic[8])
	mountain:spawn(0,55,2,env.pic[8])
	mountain:spawn(150+env.pic[8]:getWidth(),55,2,env.pic[8])
	mountain:spawn(350+env.pic[8]:getWidth(),55,2,env.pic[8])
	mountain:spawn(760+env.pic[8]:getWidth(),55,2,env.pic[8])

	--deal mare
	mountain:spawn(0,82,1,env.pic[7])
	mountain:spawn(0+env.pic[7]:getWidth(),82,1,env.pic[7])
	mountain:spawn(300+env.pic[7]:getWidth(),82,1,env.pic[7])
	mountain:spawn(600+env.pic[7]:getWidth(),82,1,env.pic[7])
	mountain:spawn(900+env.pic[7]:getWidth(),82,1,env.pic[7])

	if mapnum == 6 then 
			--munte
	mountain:spawn(-140,-15,3,env.pic[9])
	mountain:spawn(0,-15,3,env.pic[9])
	mountain:spawn(175+env.pic[9]:getWidth(),-15,3,env.pic[9])
	mountain:spawn(675+env.pic[9]:getWidth(),-15,3,env.pic[9])

	--deal
	mountain:spawn(-140,55,2,env.pic[8])
	mountain:spawn(0,55,2,env.pic[8])
	mountain:spawn(150+env.pic[8]:getWidth(),55,2,env.pic[8])
	mountain:spawn(350+env.pic[8]:getWidth(),55,2,env.pic[8])
	mountain:spawn(760+env.pic[8]:getWidth(),55,2,env.pic[8])

	--deal mare
	mountain:spawn(0,82,1,env.pic[7])
	mountain:spawn(0+env.pic[7]:getWidth(),82,1,env.pic[7])
	mountain:spawn(300+env.pic[7]:getWidth(),82,1,env.pic[7])
	mountain:spawn(600+env.pic[7]:getWidth(),82,1,env.pic[7])
	mountain:spawn(900+env.pic[7]:getWidth(),82,1,env.pic[7])
	end

end

end

function env:draw()
if loadParalex then 
	if gamestate == 'play' then 
	love.graphics.setBackgroundColor(bg_r,bg_g,bg_b,250)
	love.graphics.setColor(sky_r,sky_g,sky_b,250)
	end
	for i,v in ipairs(mountain) do
		if v.layer == 1 then
			love.graphics.draw(v.pic, v.x, v.y,0,1.2,1.2)
		end
		if v.layer == 2 then
			love.graphics.draw(v.pic, v.x, v.y,0,1.6,1.6)
		end
		if v.layer == 3 then
			love.graphics.draw(v.pic,v.x,v.y,0,1.3,1.3)
		end
	end
	for i,v in ipairs(bush) do 
		if v.pic == 1 then 
			love.graphics.draw(env.pic[1],v.x,v.y+1)
		end
		if v.pic == 2 then 
			love.graphics.draw(env.pic[2],v.x,v.y-7)
		end
	end
	for i,v in ipairs(flower) do 
		if v.pic == 1 then 
			love.graphics.draw(env.pic[3],v.x,v.y-7)
		end
		if v.pic == 2 then 
			love.graphics.draw(env.pic[4],v.x,v.y-7)
		end
		if v.pic == 3 then 
			love.graphics.draw(env.pic[5],v.x,v.y-7)
		end
		if v.pic == 4 then 
			love.graphics.draw(env.pic[6],v.x,v.y-7)
		end
	end
	
	end
end

function env:update(dt)
if parallex or loadParalex then 
	for i,v in ipairs(mountain) do 
		if v.layer == 2 then 
			if player.xvel > 20 then  
				v.x = v.x + 20 * dt
			end
			if player.xvel < -20 then  
				v.x = v.x - 20 * dt
			end
		end
		if v.layer == 3 then 
			if player.xvel > 20 then  
				v.x = v.x + 20 * dt
			end
			if player.xvel < -20 then  
				v.x = v.x - 20 * dt
				end
			end
		end
	end
end