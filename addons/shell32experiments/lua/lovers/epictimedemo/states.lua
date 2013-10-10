math.randomseed(os.time())
math.random()
math.random()
math.random()

states = {}
gamestate = 'intro'

--button
local b = love.graphics.newImage('pics/interface/button.png')
b:setFilter('nearest','nearest')

local fade = love.graphics.newImage('pics/interface/fade.png')
fade:setFilter('nearest','nearest')

local menubg = love.graphics.newImage('pics/interface/menubg.png')
menubg:setFilter('nearest','nearest')

local loadingpic1_1 = love.graphics.newImage('pics/interface/loading1_1.png')
loadingpic1_1:setFilter('nearest','nearest')
local loadingpic1_2 = love.graphics.newImage('pics/interface/loading1_2.png')
loadingpic1_2:setFilter('nearest','nearest')
local loadingpic1_3 = love.graphics.newImage('pics/interface/loading1_3.png')
loadingpic1_3:setFilter('nearest','nearest')
local loadingpic1_4 = love.graphics.newImage('pics/interface/loading1_4.png')
loadingpic1_4:setFilter('nearest','nearest')
local currentloadingpic = loadingpic1_1
local loadinganimtimer = 0
local loadingtimer = 0
local loadingtime = math.random(1.2,1.3)
local myPic = love.graphics.newImage('pics/interface/myPic.png')
myPic:setFilter('nearest','nearest')
introTime = 0
local name = love.graphics.newImage('pics/interface/name.png')
name:setFilter('nearest','nearest')
local nameX = 150
local nameY = 20
local nametimer = 0

local options = love.graphics.newImage('pics/interface/options.png')
options:setFilter('nearest','nearest')
local showfps = false

local fontS = love.graphics.newFont("fonts/1a.ttf", 20)
local fontM = love.graphics.newFont("fonts/1a.ttf", 30)
local fontL = love.graphics.newFont("fonts/1a.ttf", 60)

local randomText = 0
local randomMusic = 0

pause = false

local button = {}
function button:spawn(x,y,text,id)
	table.insert(button, {x = x, y = y, text = text, id = id, alpha = 255})
end

function states:load()
	if gamestate == 'intro' then sound:play('intro') end
	randomText = math.random(1,11)
	randomMusic = math.random(1,3)
end

function states:button()	
	if gamestate == 'menu' then
		button:spawn(love.graphics.getWidth() / 3 - ((b:getWidth() * 3) * .5),180,"Start","start")        
		button:spawn(love.graphics.getWidth() / 3 - ((b:getWidth() * 3) * .5),(180 + b:getHeight() * 5),"Options","options")
		button:spawn(love.graphics.getWidth() / 1.5 - ((b:getWidth() * 3) * .5) ,180,"Tutorial","tutorial")    
		button:spawn(love.graphics.getWidth() / 1.5 - ((b:getWidth() * 3) * .5),180 + b:getHeight() * 5,"Quit","quit")
	end
	if gamestate == 'options' then 
		button:spawn(love.graphics.getWidth() / 3 - ((b:getWidth() * 3) * .5),180,"Fps:".." "..tostring(showfps),"fps")  
		button:spawn(love.graphics.getWidth() / 3 - ((b:getWidth() * 3) * .5),(180 + b:getHeight() * 5),"Credits","credits")
		button:spawn(love.graphics.getWidth() / 1.5 - ((b:getWidth() * 3) * .5) ,180,"uuuu","ed")    
		button:spawn(love.graphics.getWidth() / 1.5 - ((b:getWidth() * 3) * .5),180 + b:getHeight() * 5,"uu","de")
	end
end

function states:update(dt)
	if gamestate == 'intro' then 
		introTime = introTime + dt
		if introTime >= 4.5 then 
			effect_type = 'black'
		end
		if introTime >= 7 then 
			intro:stop()
		end
		if introTime >= 7.5 then 
			gamestate = 'menu' 
			introTime = 0 
		end
	end

	if gamestate == 'menu' then
		sound:play('music3')

		for i,v in ipairs(button) do 
			mx,my = love.mouse.getPosition()
			if mx >= v.x and
			mx <= v.x + b:getWidth() * 3 and
			my >= v.y and
			my <= v.y + b:getHeight() * 3 then
			v.alpha = 100
		else 
			v.alpha = 255
			end
		end
	end
	if gamestate == 'options' then

		for i,v in ipairs(button) do 
			mx,my = love.mouse.getPosition()
			if mx >= v.x and
			mx <= v.x + b:getWidth() * 3 and
			my >= v.y and
			my <= v.y + b:getHeight() * 3 then
			v.alpha = 100
		else 
			v.alpha = 255
			end
		end
	end
	--logo floating
		nametimer = nametimer + dt
		nameY = nameY - 4*math.sin(nametimer) * dt

	if gamestate == 'loading' then
		sound:stop('music3')
		if randomMusic == 2 then 
			sound:play('music2')
		elseif randomMusic == 1 then
			sound:play('music7')
		elseif randomMusic == 3 then
			sound:play('music8')
 		end
		
		loadingtimer = loadingtimer + dt
		loadinganimtimer = loadinganimtimer + dt
		
		if loadinganimtimer > .2 then 
			currentloadingpic = loadingpic1_4
		end

		if loadinganimtimer > .4 then 
			currentloadingpic = loadingpic1_3
		end

		if loadinganimtimer > .6 then 
			currentloadingpic = loadingpic1_2
		end

		if loadinganimtimer > .8 then 
			currentloadingpic = loadingpic1_1
			loadinganimtimer = 0
		end

		if loadingtimer >= loadingtime then 
			gamestate = 'play'
			loadingtimer = 0
		end
	end
end

function states:draw()
	if gamestate == 'intro' then 
		states:text()
		love.graphics.setBackgroundColor(40,50,60)
		love.graphics.draw(myPic,screenW*.5-myPic:getWidth()*3.5,screenH*.5-myPic:getHeight()*3,0,6,6)
		love.graphics.setFont(fontM)
		love.graphics.print("One man army !",screenW*.5-115,screenH  - (fontL:getHeight() * .5) - 60)
	end

	if gamestate == 'menu' then 
		love.graphics.draw(fade,0,0)
		love.graphics.draw(menubg,0,0)
		love.graphics.draw(name,nameX,nameY)
		for i,v in ipairs(button) do 
		love.graphics.setColor(255,255,255,v.alpha)
		love.graphics.draw(b, v.x,v.y, 0, 3, 3)
		love.graphics.setFont(fontM)
		love.graphics.print(v.text, v.x + 33,v.y + 34  - (fontM:getHeight() * .5))
		love.graphics.setColor(255,255,255,255)
		end
	end
	
	if gamestate == 'options' then 
		love.graphics.draw(fade,0,0)
		love.graphics.draw(menubg,0,0)
		love.graphics.draw(options,180,80)
		for i,v in ipairs(button) do 
		love.graphics.setColor(255,255,255,v.alpha)
		love.graphics.draw(b, v.x,v.y, 0, 3, 3)
		love.graphics.setFont(fontM)
		love.graphics.print(v.text, v.x + 33,v.y + 34  - (fontM:getHeight() * .5))
		love.graphics.setColor(255,255,255,255)
		end
	end

	if gamestate == 'loading' then 
		love.graphics.draw(menubg,0,0)
		love.graphics.draw(currentloadingpic,0,0)
	end
end

function states:click(x,y,bu)
if gamestate == 'menu' then 
	for i,v in ipairs(button) do 
		if x >= v.x and
			x <= v.x + b:getWidth() * 3 and
			y >= v.y and
			y <= v.y + b:getHeight() * 3 then
			if v.id == 'start' then 
				sound:play('click')
				gamestate = 'loading'
				end
			if v.id == 'tutorial' then 
				sound:play('click')
			--	gamestate = 'tutorial'
				end
			if v.id == 'options' then 
				sound:play('click')
			--	gamestate = 'options'
				end
			if v.id == 'quit' then 
				sound:play('click')
				love.event.push("quit")  
				end

			end
		end
	end
	if gamestate == 'menu' then 
	for i,v in ipairs(button) do 
		if x >= v.x and
			x <= v.x + b:getWidth() * 3 and
			y >= v.y and
			y <= v.y + b:getHeight() * 3 then
				if v.id == 'fps' then 
					showfps = true
				end
			end
		end
	end
end

function states:text()
	local text1 = "Loved by Parents!"
	local text2 = "I Bring the Action!"
	local text3 = "Fun to power 2000"
	local text4 = "Enjoy!"
	local text5 = "I know you like it!"
	local text6 = "Coolest thing i`ve ever made!"
	local text7 = "Made with Love"
	local text8 = "I need sleep"
	local text9 = "Murii for President!"
	local text10 = "Loved by my sweet dog!"
	local text11 = "It contains Achivements ! :)"

	if gamestate == 'intro' then
		love.graphics.setFont(fontS) 
		love.graphics.setColor(160,140,170)
		if randomText == 1 then 
		love.graphics.print(""..text1,290,screenH-40)
		end
		if randomText == 2 then 
		love.graphics.print(""..text2,270,screenH-40)
		end
		if randomText == 3 then 
		love.graphics.print(""..text3,270,screenH-40)
		end
		if randomText == 4 then 
		love.graphics.print(""..text4,310,screenH-40)
		end
		if randomText == 5 then 
		love.graphics.print(""..text5,270,screenH-40)
		end
		if randomText == 6 then 
		love.graphics.print(""..text6,270,screenH-40)
		end
		if randomText == 7 then 
		love.graphics.print(""..text7,270,screenH-40)
		end
		if randomText == 8 then 
		love.graphics.print(""..text8,270,screenH-40)
		end
		if randomText == 9 then 
		love.graphics.print(""..text9,275,screenH-40)
		end
		if randomText == 10 then 
		love.graphics.print(""..text10,270,screenH-40)
		end
		if randomText == 11 then 
		love.graphics.print(""..text11,270,screenH-40)
		end
		love.graphics.setColor(255,255,255)
	end
end