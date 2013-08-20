local function lookat(eye_x,eye_y,eye_z,target_x,target_y,target_z,up_x,up_y,up_z)
	local z_x,z_y,z_z=eye_x-target_x,eye_y-target_y,eye_z-target_z
	local a=(z_x*z_x + z_y*z_y + z_z*z_z)^0.5
	if a==0 then
		z_x,z_y,z_z=0,0,0
	else
		z_x,z_y,z_z=z_x/a,z_y/a,z_z/a
	end
	
	local x_x,x_y,x_z = up_y*z_z-z_y*up_z, up_z*z_x-z_z*up_x, up_x*z_y-z_x*up_y
	local y_x,y_y,y_z =  z_y*x_z-x_y* z_z,  z_z*x_x-x_z* z_x,  z_x*x_y-x_x* z_y
	a=(x_x*x_x + x_y*x_y + x_z*x_z)^0.5
	if a~=0 then
		x_x,x_y,x_z=x_x/a, x_y/a, x_z/a
	end
	a=(y_x*y_x + y_y*y_y + y_z*y_z)^0.5
	if a~=0 then
		y_x,y_y,y_z=y_x/a, y_y/a, y_z/a
	end
	return {{x_x, y_x, z_x, 0},
			{x_y, y_y, z_y, 0},
			{x_z, y_z, z_z, 0},
			{(x_x * -eye_x) + (x_y * -eye_y) + (x_z * -eye_z),
			(y_x * -eye_x) + (y_y * -eye_y) + (y_z * -eye_z),
			(z_x * -eye_x) + (z_y * -eye_y) + (z_z * -eye_z),1}}
end

local pi=math.pi
local tan=math.tan
local function perspectiveFov(fov, aspect, near, far)
	local D2R = pi / 180.0
    local yScale = 1.0 / tan(D2R * fov / 2)
    local xScale = yScale / aspect
    local nearmfar = near - far
	return 	{{xScale,	   0,						  0,		0},
			 {	   0, yScale,						  0,		0},
			 {	   0,	   0,	(far + near) / nearmfar,	   -1},
			 {	   0,	   0,	  2*far*near / nearmfar,		0}}
end

local love=love
love.graphics.setDefaultFilter("nearest", "nearest")
local model =  {{1,0,0,0},
				{0,1,0,0},
				{0,0,1,0},
				{0,0,0,1}}
local ScrW=1280
local ScrH=768
local view = lookat(0,1,0,0,1,0,0,1,0)
local projection = perspectiveFov( 55, ScrW/ScrH, 0.1, 100 )

local drawg=love.graphics.draw

function newHeightMap(img,ground_img)
	local map={}
	map.img=love.graphics.newImage(ground_img)
	img_map=love.graphics.newImage(img)
	local rat_scale_divisor=32
	map.vertex={}
	local counter=1
	for h=2,20 do
		for w=2,20 do
			--local r,g,b=img_map:getPixel(w,h)
			map.vertex[counter]=love.graphics.newGeometry({
							{ 0, 0, 0, 0,(w*255)/rat_scale_divisor		 ,0,((h*255)-255)/rat_scale_divisor , 255 },
							{ 0, 0, 0, 1,((w*255)-255)/rat_scale_divisor ,0,((h*255)-255)/rat_scale_divisor , 255 },
							{ 0, 0, 1, 1,((w*255)-255)/rat_scale_divisor ,0,(h*255)/rat_scale_divisor	    , 255 },
							{ 0, 0, 1, 0,(w*255)/rat_scale_divisor 		 ,0,(h*255)/rat_scale_divisor	    , 255 },
							})
			counter=counter+1
		end
	end
	function map:draw()
		for i=1,table.getn(self.vertex) do
			drawg(self.img, self.vertex[i], 0, 0)
		end
	end
	return map
end

function newCube(img)
	local left = {
	{ 0, 0, 0, 0, 000, 255, 000, 255 },
	{ 0, 0, 0, 1, 000, 000, 000, 255 },
	{ 0, 0, 1, 1, 000, 000, 255, 255 },
	{ 0, 0, 1, 0, 000, 255, 255, 255 },
	}

	local right = {
	{ 0, 0, 0, 0, 255, 255, 255, 255 },
	{ 0, 0, 0, 1, 255, 000, 255, 255 },
	{ 0, 0, 1, 1, 255, 000, 000, 255 },
	{ 0, 0, 1, 0, 255, 255, 000, 255 },
	}

	local top = {
	{ 0, 0, 0, 0, 000, 255, 000, 255 },
	{ 0, 0, 0, 1, 000, 255, 255, 255 },
	{ 0, 0, 1, 1, 255, 255, 255, 255 },
	{ 0, 0, 1, 0, 255, 255, 000, 255 },
	}

	local bottom = {
	{ 0, 0, 0, 0, 000, 000, 255, 255 },
	{ 0, 0, 0, 1, 000, 000, 000, 255 },
	{ 0, 0, 1, 1, 255, 000, 000, 255 },
	{ 0, 0, 1, 0, 255, 000, 255, 255 },
	}

	local front = {
	{ 0, 0, 0, 0, 000, 255, 255, 255 },
	{ 0, 0, 0, 1, 000, 000, 255, 255 },
	{ 0, 0, 1, 1, 255, 000, 255, 255 },
	{ 0, 0, 1, 0, 255, 255, 255, 255 },
	}

	local back = {
	{ 0, 0, 0, 0, 255, 255, 000, 255 },
	{ 0, 0, 0, 1, 255, 000, 000, 255 },
	{ 0, 0, 1, 1, 000, 000, 000, 255 },
	{ 0, 0, 1, 0, 000, 255, 000, 255 },
	}

	local cube={}
	cube.img = love.graphics.newImage(img)
	cube.draw = function (self)
		drawg(self.img, self.left, 0, 0)
		drawg(self.img, self.right, 0, 0)
		drawg(self.img, self.top, 0, 0)
		drawg(self.img, self.bottom, 0, 0)
		drawg(self.img, self.front, 0, 0)
		drawg(self.img, self.back, 0, 0)
	end
	cube.left = love.graphics.newGeometry(left)
	cube.right = love.graphics.newGeometry(right)
	cube.top = love.graphics.newGeometry(top)
	cube.bottom = love.graphics.newGeometry(bottom)
	cube.front = love.graphics.newGeometry(front)
	cube.back = love.graphics.newGeometry(back)
	return cube
end
--cube=newHeightMap("heightmap.png","love.png")
cube=newCube("love.png")

local shader=nil
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.window.setTitle("Industrial secret")
	local flags={}
	flags.fullscreen=false
	flags.vsync=false
	flags.fsaa=2
	flags.centered=true
	flags.resizable=false
	flags.borderless=false
	love.window.setMode(ScrW,ScrH,flags)

	vs = [[
		uniform mat4 Model;
		uniform mat4 View;
		uniform mat4 Projection;
		vec4 position(mat4 mvp, vec4 position)
		{
			return Projection * View * Model * VertexColor;
		}
	]]
	fs = [[
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			return Texel(texture,texture_coords)*vec4(1,1,1,1.0*float(gl_FrontFacing));
		}
	]]

	shader = love.graphics.newShader(vs, fs)
	shader:send("Projection", projection)
	shader:send("View", view)
	shader:send("Model", model)
end

local x=0.34
local y=2
local z=0.32
local lx=0
local lz=-1
local ang_x=0
local ang_y=0
local deltamove=0
local sensitive=512
local fraction=0.0025
local setShader=love.graphics.setShader

local sin=math.sin
local cos=math.cos
--local tan=math.tan

local isDown=love.keyboard.isDown
local hasFocus=love.window.hasFocus
local setPosition=love.mouse.setPosition
local gprint=love.graphics.print
local first=0
function love.update(dt)
	if hasFocus()==true then
		if first<100 then
			first=first+1
		else
			ang_x=ang_x+((love.mouse.getX()-(ScrW/2))/sensitive)
			ang_y=ang_y+((love.mouse.getY()-(ScrH/2))/sensitive)
		end
		lx=sin(ang_x)
		lz=-cos(ang_x)
		ly=-tan(ang_y)
		setPosition(ScrW/2,ScrH/2)
		if isDown("escape")==true then
			love.event.push('quit')
		end
		if isDown("up")==true or isDown("w")==true then
			x=x+lx*fraction
			z=z+lz*fraction
		elseif isDown("down")==true or isDown("s")==true then
			x=x-lx*fraction
			z=z-lz*fraction
		end
		if isDown("a")==true or isDown("left")==true then
			x=x+lz*fraction
			z=z-lx*fraction
		elseif isDown("d")==true or isDown("right")==true then
			x=x-lz*fraction
			z=z+lx*fraction
		end
		if isDown("lctrl")==true then
			y=y-fraction
		elseif isDown(" ")==true then
			y=y+fraction
		end
	end
	shader:send("View", lookat(x   ,  y,z,
							   x+lx, ly,z+lz,
							   0   ,  1,0))
	
	--[[shader:send("View", lookat(x,y,z,
							   x+lx,-1024,z+lz,
							   0,1,0))]]
end

local format=string.format
function love.draw()
	setShader(shader)
	cube:draw()
	setShader()
	--[[gprint(math.ceil(x),0,0)
	gprint("5",32,0)
	gprint(math.ceil(z),64,0)
	
	gprint(math.ceil(x+lx),0,16)
	gprint(math.ceil(ly),32,16)
	gprint(math.ceil(z+lz),64,16)
	
	gprint("0",0,32)
	gprint("1",32,32)
	gprint("0",64,32)]]
	
	gprint(format("%.2f",x),0,0)
	gprint(format("%.2f",y),64,0)
	gprint(format("%.2f",z),128,0)
	
	gprint(format("%.2f",x+lx),0,16)
	gprint(format("%.2f",-32),64,16)
	gprint(format("%.2f",z+lz),128,16)
	
	gprint("0",0,32)
	gprint("1",64,32)
	gprint("0",128,32)
	
	gprint(format("x: %.2f",x),0,48)
	gprint(format("y: %.2f",y),0,64)
	gprint(format("z: %.2f",z),0,80)
	gprint(format("lx: %.2f",lx),0,96)
	gprint(format("lz: %.2f",lz),0,112)
end

function love.run()
	math.randomseed(os.time())
	math.random() math.random()
	engine={}
	local engine=engine
	local loading=true
	while loading do
		if love and love.audio and love.event and love.filesystem and love.font and love.graphics and love.image
		and love.joystick and love.keyboard and love.mouse and love.physics and love.sound and love.thread
		and love.timer then
			love.load(arg)
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
	local getFPS=love.timer.getFPS
	local maxIntFPS=5000
	local maxFps=1/maxIntFPS
	function engine.setMaxFPS(FPS)
		maxIntFPS=FPS
		maxFps=1/FPS
	end
	function engine.getMaxFPS()
		return maxIntFPS
	end
	local time=0
	while true do
		time=getTime()
		if time-dt>=maxFps then
			step()
			pump()
			engine.FPS=getFPS()
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
end