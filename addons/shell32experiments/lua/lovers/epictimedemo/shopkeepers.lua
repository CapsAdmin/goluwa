
keeper = {}

local pic = {}

function keeper:load() 
loadKeepers = false

pic[1] = love.graphics.newImage('pics/shopkeepers/bakerL.png')
pic[1]:setFilter('nearest','nearest')
pic[2] = love.graphics.newImage('pics/shopkeepers/bakerR.png')
pic[2]:setFilter('nearest','nearest')

pic[3] = love.graphics.newImage('pics/shopkeepers/blackSmithL.png')
pic[3]:setFilter('nearest','nearest')
pic[4] = love.graphics.newImage('pics/shopkeepers/blackSmithR.png')
pic[4]:setFilter('nearest','nearest')	

pic[5] = love.graphics.newImage('pics/shopkeepers/innL.png')
pic[5]:setFilter('nearest','nearest')
pic[6] = love.graphics.newImage('pics/shopkeepers/innR.png')
pic[6]:setFilter('nearest','nearest')

pic[7] = love.graphics.newImage('pics/shopkeepers/shopKeeperL.png')
pic[7]:setFilter('nearest','nearest')
pic[8] = love.graphics.newImage('pics/shopkeepers/shopKeeperR.png')
pic[8]:setFilter('nearest','nearest')	
end

function keeper:spawn(x,y,kind)
	table.insert(keeper,{x = x,y = y,kind = kind,pic = pic,direction = "" })
end

function keeper:draw()
if loadKeepers then 
	for i,v in ipairs(keeper) do 
		love.graphics.draw(v.pic,v.x,v.y,0,1.2,1.2)
		end
	end
end

function keeper:update(dt)
if loadKeepers then 
	for i,v in ipairs(keeper) do
		--view directions 
		if v.kind == 'baker' then 
			if player.x + player.w <= v.x then 
				v.pic = pic[1]
			end	

			if player.x + player.w >= v.x then 
				v.pic = pic[2]
			end

			--after some distance dont look anymore at player
			if player.x + 120 <= v.x then 
				v.pic = pic[2]
			end		

			if player.x + player.w >= v.x + 80 then 
				v.pic = pic[1]
			end
		end

		if v.kind == 'blackSmith' then 
			if player.x + player.w <= v.x then 
				v.pic = pic[3]
			end
			if player.x + player.w >= v.x then 
				v.pic = pic[4]
			end
		end

		if v.kind == 'innL' then 
			if player.x + player.w <= v.x then 
				v.pic = pic[6]
			end
			if player.x + player.w >= v.x then 
				v.pic = pic[5]
			end
		end

		if v.kind == 'shopKeeperL' then 
			if player.x + player.w <= v.x then 
				v.pic = pic[7]
			end
			if player.x + player.w >= v.x then 
				v.pic = pic[8]
			end
		end

		end
	end
end