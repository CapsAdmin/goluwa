local glw=glw
local surface=surface
local gl=gl

local window = glw.OpenWindow(1280, 720)

--love table
love={}
local love=love


love.graphics={}

fonts={}
function love.graphics.newFont(font,siz)
	fonts[font]=siz
	return surface.CreateFont(font, {
		size = siz,
		path = font,
	})
end

local currentFont=""
local currentFontSize=0
function love.graphics.setFont(font)
	currentFont=font
	currentFontSize=fonts[font]
	surface.SetFont(font)
end

local br,bg,bb,ba=0,0,0,0
function love.graphics.setBackgroundColor(r,g,b,a)
	br=r
	bg=g
	bb=b
	ba=a
end

local cr,cg,cb,ca=0,0,0,0
function love.graphics.setColor(r,g,b,a)
	cr=r/255
	cg=g/255
	cb=b/255
	ca=a/255
	surface.Color(cr,cg,cb,ca)
end

function love.graphics.getColor(r,g,b,a)
	return cr,cg,cb,ca
end

function love.graphics.print(text,x,y,r,sx,sy)
	r=r or 0
	r=r/0.0174532925
	sx=sx or 1
	sy=sy or 1
	surface.Scale(sx,sy)
	surface.Rotate(r/0.0174532925)
	for i=1,#text do
		surface.SetTextPos((x+(i*currentFontSize))*sx,y)
		surface.DrawChar(text:sub(i,i))
	end
end

function love.graphics.printf(text,x,y,limit,align,r, sx, sy)
	r=r or 0
	r=r/0.0174532925
	y=y or 0
	limit=limit or 0
	align=align or "left"
	sx=sx or 1
	sy=sy or 1
	surface.Scale(sx,sy)
	
	local accumulator_x,accumulator_y=1,1
	local char=""

	if r==0 then
		for i=1,#text do
			char=text:sub(i,i)
			if char=="\t" then
				accumulator_x=accumulator_x+4
			elseif char=="\n" then
				accumulator_x=1
				accumulator_y=accumulator_y+1.5
			else
				if ((accumulator_x*currentFontSize)*sx)>limit then
					accumulator_x=1
					accumulator_y=accumulator_y+1.5
					surface.SetTextPos(x+((accumulator_x*currentFontSize)*sx),(y+((accumulator_y*currentFontSize))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				else
					surface.SetTextPos(x+((accumulator_x*currentFontSize)*sx),(y+((accumulator_y*currentFontSize))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				end
			end
		end
	else
		surface.Rotate(r)
		for i=1,#text do
			char=text:sub(i,i)
			if char=="\t" then
				accumulator_x=accumulator_x+4
			elseif char=="\n" then
				accumulator_x=1
				accumulator_y=accumulator_y+1.5
			else
				if ((accumulator_x*currentFontSize)*sx)>limit then
					accumulator_x=1
					accumulator_y=accumulator_y+1.5
					surface.SetTextPos(x+((accumulator_x*currentFontSize)*sx),(y+((accumulator_y*currentFontSize))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				else
					surface.SetTextPos(x+((accumulator_x*currentFontSize)*sx),(y+((accumulator_y*currentFontSize))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				end
			end
		end
		surface.Rotate(-r)
	end
end

function love.graphics.line(x1,y1,x2,y2)
	surface.DrawLine(x1,y1,x2,y2,5,true)
end

local DefaultFilter=e.GL_LINEAR
local DefaultMipmapFilter=e.GL_LINEAR_MIPMAP_LINEAR
function love.graphics.setDefaultFilter(filter)
	if filter=="nearest" then
		local DefaultFilter=e.GL_NEAREST
		local DefaultMipmapFilter=e.GL_NEAREST_MIPMAP_NEAREST
	elseif filter=="linear" then
		local DefaultFilter=e.GL_LINEAR
		local DefaultMipmapFilter=e.GL_LINEAR_MIPMAP_LINEAR
	end
end

function setFilter(self,filter)
	if filter=="nearest" then
		DefaultFilter=filter
	elseif filter=="linear" then
		DefaultFilter=filter
	end
end

function love.graphics.newImage(path)
	local w, h, buffer = freeimage.LoadImage(vfs.Read(path, "rb"))
	
	local tex = Texture(
		w, h, buffer, 
		{
			mip_map_levels = 4,  
			mag_filter = e.GL_NEAREST,
			min_filter = e.GL_NEAREST_MIPMAP_LINEAR,
		}  
	) 
	return tex
end

love.timer={}

function love.timer.getTime()
	return glfw.GetTime()
end


function love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
	y=y or 0
	r=r or 0
	r=r/0.0174532925
	sx=sx or 1
	sy=sy or 1
	ox=ox or 0
	oy=oy or 0
	surface.Scale(1,1)
	if r==0 then
		if type(drawable)=="table" and drawable.id then
			surface.SetTexture(drawable)
			surface.FastDrawRect(x,y,drawable.w*sx,drawable.h*sy,nil)
		end
	else
		if type(drawable)=="table" and drawable.id then
			surface.SetTexture(drawable)
			surface.FastDrawRect(x,y,drawable.w*sx,drawable.h*sy,r)
		end
	end
end

local delta=0
function love.timer.getFPS()
	return 1/delta
end
event.AddListener("OnDisplay", "shell32test", function(dt)
	render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
	gl.ClearColor(br, bg, bb, ba)

	render.Start(window)		
		delta=dt
		surface.Start()	
		surface.SetWhiteTexture()
		love.draw()
	render.End() 
end)

event.AddListener("OnUpdate", "shell32test", function(dt)
	love.update(dt)
end)

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

local spaceship1=love.graphics.newImage("demos/top_gear_results/graphics/spaceship.png")
local spaceship2=love.graphics.newImage("demos/top_gear_results/graphics/spaceship2.png")
local spaceship3=love.graphics.newImage("demos/top_gear_results/graphics/spaceship3.png")
 spaceship4=love.graphics.newImage("demos/top_gear_results/graphics/spaceship4.png")
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


local sky=love.graphics.newImage("demos/top_gear_results/graphics/sky.png")
local bottom1=love.graphics.newImage("demos/top_gear_results/graphics/background_bottom1.png")
local bottom2=love.graphics.newImage("demos/top_gear_results/graphics/background_bottom2.png")

local clouds1=love.graphics.newImage("demos/top_gear_results/graphics/cloud1.png")
local clouds2=love.graphics.newImage("demos/top_gear_results/graphics/cloud2.png")

local platform=love.graphics.newImage("demos/top_gear_results/graphics/platform.png")
local platform_x=(1280/2)-(platform.w/2)

clouds_table={}

local effect = audio.CreateEffect(e.AL_EFFECT_EAXREVERB)
effect:SetParam(e.AL_EAXREVERB_DECAY_TIME, 10)  
effect:BindToChannel(1)

local music = utilities.RemoveOldObject(Sound("demos/top_gear_results/music/results.ogg"),1)
music:Play()
music:SetChannel(1)
music:SetLooping(true)

local click = utilities.RemoveOldObject(Sound("demos/top_gear_results/music/fins_button.wav"),2) 
click:SetChannel(2)
click:SetLooping(false)
 
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
local insert=table.insert
local random=math.random
local ceil=math.ceil
local cos=math.cos
local sin=math.sin
local sub=string.sub
function love.draw()
	bottom_x=bottom_x+speed
	if bottom_x>bottom1.w*2 then
		bottom_x=bottom_x-(bottom1.w*2)
	end
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(sky,0,(-((1024*5)-720))+spaceship_h,0,1280/256,5)
	
	love.graphics.draw(bottom1,bottom_x-(bottom1.w*2),720-bottom2.h+spaceship_h)
	love.graphics.draw(bottom2,bottom_x-bottom2.w,720-bottom2.h+spaceship_h)
	love.graphics.draw(bottom1,bottom_x,720-bottom1.h+spaceship_h)
	love.graphics.draw(bottom2,bottom_x+bottom2.w,720-bottom2.h+spaceship_h)
	
	if random(1,1000)<speed*5 then
		if random(1,2)==1 then
			insert(clouds_table,{clouds1,-512,720-random(512,1080)})
		else
			insert(clouds_table,{clouds2,-512,720-random(512,1080)})
		end 
	end
	
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
		platform_x=(1280/2)-(platform.w/2)
		love.graphics.draw(platform,platform_x,720-platform.h)
		love.graphics.draw(spaceship1,(1280/2)-(spaceship1.w/2),((720/2)-(spaceship1.h/2))+155)
		if love.timer.getTime()-PHASE_TIME>1 then
			PHASE_TIME=love.timer.getTime()
			PHASE=1
		end
	elseif PHASE==1 then
		speed=0
		platform_x=(1280/2)-(platform.w/2) 
		love.graphics.draw(platform,platform_x,720-platform.h)
		love.graphics.draw(spaceship1,(1280/2)-(spaceship1.w/2),(((720/2)-(spaceship1.h/2))+155)-((love.timer.getTime()-PHASE_TIME)*30))
		if ((love.timer.getTime()-PHASE_TIME)*30)>155 then
			PHASE_TIME=love.timer.getTime()
			PHASE=2
		end
	elseif PHASE==2 then
		platform_x=platform_x+speed
		love.graphics.draw(platform,platform_x,720-platform.h)
		if love.timer.getTime()-spaceship_anim_time>spaceship_anim_step+((10-speed)/(speed*10)) then
			spaceship_anim_number=spaceship_anim_number+1
			if spaceship_anim_number>=4 then
				spaceship_anim_number=2
			end
			spaceship_anim_time=love.timer.getTime()
		end
		love.graphics.draw(spaceship_anim[spaceship_anim_number],((1280/2)-(spaceship_anim[spaceship_anim_number].w/2))+(math.sin(love.timer.getTime()*5)*10*(speed/10)),((720/2)-(spaceship_anim[spaceship_anim_number].h/2))+(math.cos(love.timer.getTime()*2))*15*(speed/10))
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
		love.graphics.draw(spaceship_anim[spaceship_anim_number],((1280/2)-(spaceship_anim[spaceship_anim_number].w/2))+(sin(love.timer.getTime()*5)*10*(speed/10)),((720/2)-(spaceship_anim[spaceship_anim_number].h/2))+(cos(love.timer.getTime()*2))*15*(speed/10),spaceship_r)
	
	end
	
	love.graphics.setColor(0,0,255,255)
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
	if (love.timer.getTime()-time_now)*12>#text then
		time_now=love.timer.getTime()
		PHASE=0
	end
	love.graphics.setColor(0,255,255,255)
	love.graphics.line((1280/2)-(640/2)+wrap_size,0,(1280/2)-(640/2)+wrap_size,720)
end
