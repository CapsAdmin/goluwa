--techdemo

local text=[[
 LINE WRAP TEST! ~~~~~~~~~~

 The classic hello world program can be written as follows:

	print 'Hello World!'

 Comments use the following syntax, similar to that of Ada, Eiffel, Haskell, SQL and VHDL:

	-- A comment in Lua.
	

 The factorial function is implemented as a function in this example:

	function factorial(n)
        local x = 1
        for i = 2,n do
			x = x * i
        end
        return x
	end
	
Lua's treatment of functions as first-class values is shown in the following example, where the print function's behavior is modified:

	do
		local oldprint = print
		function print(s)
			if s == "foo" then
				oldprint("bar")
			else
				oldprint(s)
			end
		end
	end
.....................................................
]]
	

	
function love.update(dt)
end	

local time_now=love.timer.getTime()

local spaceship1=love.graphics.newImage("graphics/spaceship.png")
local spaceship2=love.graphics.newImage("graphics/spaceship2.png")
local spaceship3=love.graphics.newImage("graphics/spaceship3.png")
local spaceship4=love.graphics.newImage("graphics/spaceship4.png")
spaceship_r=0
spaceship_h=0

local spaceship_anim={}
spaceship_anim[1]=spaceship1
spaceship_anim[2]=spaceship2
spaceship_anim[3]=spaceship3
spaceship_anim[4]=spaceship4

local spaceship_anim_time=love.timer.getTime()
local spaceship_anim_step=0.05
local spaceship_anim_number=1


local sky=love.graphics.newImage("graphics/sky.png")
local bottom1=love.graphics.newImage("graphics/background_bottom1.png")
local bottom2=love.graphics.newImage("graphics/background_bottom2.png")

local clouds1=love.graphics.newImage("graphics/cloud1.png")
local clouds2=love.graphics.newImage("graphics/cloud2.png")

local star=love.graphics.newImage("graphics/star.png")

local platform=love.graphics.newImage("graphics/platform.png")
local platform_x=(1280/2)-(platform:getWidth()/2)

clouds_table={}

stars_table={}


--[[local effect = audio.CreateEffect(e.AL_EFFECT_EAXREVERB)
effect:SetParam(e.AL_EAXREVERB_DECAY_TIME, 10)  
effect:BindToChannel(1)
]]
music = love.audio.newSource("/music/results.ogg")
music:play()
 
 
--stuff goes here
local font = love.graphics.newFont("fonts/easycode.ttf",12)
love.graphics.setFont(font)
local speed=10
local bottom_x=0

local PHASE=0
local PHASE_TIME=love.timer.getTime()

local wrap_size=640
local wrap_last_time=0
local characters_wrote=0

local fade_color_multi=1
local insert=table.insert
local random=math.random
local ceil=math.ceil
local cos=math.cos
local sin=math.sin
local sub=string.sub
function love.draw()
	bottom_x=bottom_x+speed
	if bottom_x>bottom1:getWidth()*2 then
		bottom_x=bottom_x-(bottom1:getWidth()*2)
	end
	
	love.graphics.setColor(255*fade_color_multi,255*fade_color_multi,255*fade_color_multi,255*fade_color_multi)
	love.graphics.draw(sky,0,(-((1024*5)-720))+spaceship_h,0,1280/256,5)
	
	love.graphics.draw(bottom1,bottom_x-(bottom1:getWidth()*2),720-bottom2:getHeight()+spaceship_h)
	love.graphics.draw(bottom2,bottom_x-bottom2:getWidth(),720-bottom2:getHeight()+spaceship_h)
	love.graphics.draw(bottom1,bottom_x,720-bottom1:getHeight()+spaceship_h)
	love.graphics.draw(bottom2,bottom_x+bottom2:getWidth(),720-bottom2:getHeight()+spaceship_h)
	
	if random(1,1000)<speed*5 then
		if random(1,2)==1 then
			insert(clouds_table,{clouds1,-512,720-random(512,1080)})
		else
			insert(clouds_table,{clouds2,-512,720-random(512,1080)})
		end 
	end
	
	if random(1,1000)<speed*5 then
		insert(stars_table,{star,-512,720-random(1560,3072),math.random()})
	end
	
	love.graphics.setColor(255*2*fade_color_multi,255*2*fade_color_multi,255*2*fade_color_multi,255*fade_color_multi)
	for k,v in pairs(stars_table) do
		love.graphics.draw(v[1],v[2],v[3]+spaceship_h,v[4])
		v[2]=v[2]+speed
		if v[2]>1280+512 then
			stars_table[k]=nil
		end
	end 
	
	love.graphics.setColor(255*fade_color_multi,255*fade_color_multi,255*fade_color_multi,255*fade_color_multi)
	for k,v in pairs(clouds_table) do
		love.graphics.draw(v[1],v[2],v[3]+spaceship_h)
		v[2]=v[2]+speed
		if v[2]>1280+512 then
			clouds_table[k]=nil
		end
	end 

	
	if PHASE==0 then
		spaceship_h=0
		speed=0
		platform_x=(1280/2)-(platform:getWidth()/2)
		love.graphics.draw(platform,platform_x,720-platform:getHeight())
		love.graphics.draw(spaceship1,(1280/2)-(spaceship1:getWidth()/2),((720/2)-(spaceship1:getHeight()/2))+155)
		fade_color_multi=(love.timer.getTime()-PHASE_TIME)/2.5
		if fade_color_multi>1 then
			fade_color_multi=1
		end
		if love.timer.getTime()-PHASE_TIME>5 then
			fade_color_multi=1
			PHASE_TIME=love.timer.getTime()
			PHASE=1
		end
	elseif PHASE==1 then
		speed=0
		platform_x=(1280/2)-(platform:getWidth()/2) 
		love.graphics.draw(platform,platform_x,720-platform:getHeight())
		love.graphics.draw(spaceship1,(1280/2)-(spaceship1:getWidth()/2),(((720/2)-(spaceship1:getHeight()/2))+155)-((love.timer.getTime()-PHASE_TIME)*30))
		if ((love.timer.getTime()-PHASE_TIME)*30)>155 then
			PHASE_TIME=love.timer.getTime()
			PHASE=2
		end
	elseif PHASE==2 then
		platform_x=platform_x+speed
		love.graphics.draw(platform,platform_x,720-platform:getHeight())
		if love.timer.getTime()-spaceship_anim_time>spaceship_anim_step+((10-speed)/(speed*10)) then
			spaceship_anim_number=spaceship_anim_number+1
			if spaceship_anim_number>=4 then
				spaceship_anim_number=2
			end
			spaceship_anim_time=love.timer.getTime()
		end
		love.graphics.draw(spaceship_anim[spaceship_anim_number],((1280/2)-(spaceship_anim[spaceship_anim_number]:getWidth()/2))+(math.sin(love.timer.getTime()*5)*10*(speed/10)),((720/2)-(spaceship_anim[spaceship_anim_number]:getHeight()/2))+(math.cos(love.timer.getTime()*2))*15*(speed/10))
		speed=love.timer.getTime()-PHASE_TIME
		if speed>20 then 
			PHASE_TIME=love.timer.getTime()
			PHASE=3
			speed=20 
		end
	elseif PHASE==3 then
		if love.timer.getTime()-spaceship_anim_time>spaceship_anim_step+((10-speed)/(speed*10)) then
			spaceship_anim_number=spaceship_anim_number+1
			if spaceship_anim_number>=4 then
				spaceship_anim_number=2
			end
			spaceship_anim_time=love.timer.getTime()
		end
		spaceship_r=(love.timer.getTime()-PHASE_TIME)*0.2 
		if spaceship_r>0.785398163 then
			spaceship_r=0.785398163
		end
		spaceship_h=spaceship_h+(speed*spaceship_r) 
		speed=20-(spaceship_r*5)
		love.graphics.draw(spaceship_anim[spaceship_anim_number],((1280/2)-(spaceship_anim[spaceship_anim_number]:getWidth()/2))+(sin(love.timer.getTime()*5)*10*(speed/10)),((720/2)-(spaceship_anim[spaceship_anim_number]:getHeight()/2))+(cos(love.timer.getTime()*2))*15*(speed/10),spaceship_r)
		if (love.timer.getTime()-time_now)*12>#text then
			PHASE_TIME=love.timer.getTime()
			PHASE=4
		end
	elseif PHASE==4 then
		love.graphics.draw(spaceship_anim[spaceship_anim_number],(((1280/2)-(spaceship_anim[spaceship_anim_number]:getWidth()/2))+(sin(love.timer.getTime()*5)*10*(speed/10)))-((1280/2)*((love.timer.getTime()-PHASE_TIME)/5)),(((720/2)-(spaceship_anim[spaceship_anim_number]:getHeight()/2))+(cos(love.timer.getTime()*2))*15*(speed/10))-((720/2)*((love.timer.getTime()-PHASE_TIME)/4)),spaceship_r)
		fade_color_multi=1-((love.timer.getTime()-PHASE_TIME)/5)
		if love.timer.getTime()-PHASE_TIME>5 then
			time_now=love.timer.getTime()
			PHASE_TIME=love.timer.getTime()
			PHASE=0
		end
	end
	
	love.graphics.setColor(0*fade_color_multi,0*fade_color_multi,255*fade_color_multi,255*fade_color_multi)
	if ceil((love.timer.getTime()*12)-time_now)>characters_wrote then
		characters_wrote=ceil((love.timer.getTime()*12)-time_now)
		--local last_char=string.sub(text,(love.timer.getTime()-time_now)*12,(love.timer.getTime()-time_now)*12)
		--[[if last_char~="\t" and last_char~="\n" and last_char~=" " and last_char~="" then
			click:Rewind()
			click:SetPitch(math.random(200,210)/100)
			click:SetGain(math.random(10,25)/100)
			click:Play()
		end]]
	end
	
	if ceil((love.timer.getTime()-time_now))%2==0 and ceil((love.timer.getTime()-time_now))~=wrap_last_time then
		wrap_last_time=ceil((love.timer.getTime()-time_now))
		wrap_size=random(512,768)
		if wrap_size<512 then 
			wrap_size=512
		elseif wrap_size>768 then
			wrap_size=768
		end
	end
	
	love.graphics.printf(string.sub(text,1,(love.timer.getTime()-time_now)*12),(1280/2)-(640/2),0,wrap_size)
end

if lovemu then return end

function love.run()
	math.randomseed(os.time())
	math.random() math.random()
	local loading=true
	while loading do
		if love and love.audio and love.event and love.filesystem and love.font and love.graphics and love.image
		and love.joystick and love.keyboard and love.mouse and love.physics and love.sound and love.thread
		and love.timer then
			if love.load then
				love.load()
			end
			loading=false
		end
	end
	local getTime=love.timer.getTime
	local dt=getTime()
	local update=love.update
	local draw=love.draw
	local present=love.graphics.present
	local clear=love.graphics.clear
	local origin=love.graphics.origin
	local sleep=love.timer.sleep
	local pump=love.event.pump
	local poll=love.event.poll
	local step=love.timer.step
	local hostSleep=1
	local time=0
	while true do
		time=getTime()
		step()
		pump()
		for e,a,b,c,d in poll() do
			if e == "quit" then
				if not love.quit or not love.quit() then
					love.audio.stop()
					return
				end
			end
			love.handlers[e](a,b,c,d)
		end
		update(time-dt)
		clear()
		origin()
		draw()
		present()
		dt=time
	end
end