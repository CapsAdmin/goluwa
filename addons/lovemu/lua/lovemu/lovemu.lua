local surface=surface

--love table
love={}
local love=love
love._version="0.9.0"

lovemu={}
local lovemu=lovemu
lovemu.demoname="" --internal, demo folder name
lovemu.delta=0 --frametime

include("realboot.lua")

local getn=table.getn
local pairs=pairs
local find=string.find
local tostring=tostring
local insert=table.insert
local concat=table.concat
local gsub=string.gsub

lovemu.modules={
		"lovemu/extras/util.lua",
		"lovemu/boot.lua",
		"lovemu/love/audio.lua",
		"lovemu/love/event.lua",
		"lovemu/love/filesystem.lua",
		"lovemu/love/font.lua",
		"lovemu/love/graphics.lua",
		"lovemu/love/image.lua",
		"lovemu/love/keyboard.lua",
		"lovemu/love/mouse.lua",
		"lovemu/love/physics.lua",
		"lovemu/love/sound.lua",
		"lovemu/love/system.lua",
		"lovemu/love/thread.lua",
		"lovemu/love/timer.lua",
		"lovemu/love/window.lua"
	}

--load modules
for i=1,getn(lovemu.modules) do
	include(lovemu.modules[i])
end

lovemu.supported={}
for _,v in pairs(lovemu.listFiles(R("lovemu/"),"lua")) do
	for _,l in pairs(string.explode(vfs.Read(v),"\n")) do
		if find(l,"love.") then
			if string.match(l,"(.-)%b()") then
				local isPARTIAL=false
				if find(l,"--partial") then
					isPARTIAL=true
				end
				local x1,x2=find(l,"love.")
				l=l:sub(x2,#l)
				l=string.match(l,"(.-)%b()")
				if l then
					if isPARTIAL==true then
						lovemu.supported[l]=1
					else
						lovemu.supported[l]=2
					end
				end
			end
		end
	end
end

local font = love.graphics.newFont(8)
function love.errhand(msg)
	love.graphics.setFont(font)
	msg = tostring(msg)
	love.graphics.setBackgroundColor(89, 157, 220)
	love.graphics.setColor(255, 255, 255, 255)
	
	local trace = debug.traceback()

	local err = {}

	insert(err, "Error\n")
	insert(err, msg.."\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = gsub(l, "stack traceback:", "Traceback\n")
			insert(err, l)
		end
	end

	local p = concat(err, "\n")

	p = gsub(p, "\t", "")
	p = gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
		love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
	end
	
	draw()
end

lovemu.translate_x,lovemu.translate_y=0,0
lovemu.scale_x,lovemu.scale_y=1,1
lovemu.angle=0
lovemu.stack={}
lovemu.stack_index=1
local function run()
	love.update(lovemu.delta)
	love.draw()
	lovemu.translate_x=0
	lovemu.translate_y=0
	lovemu.scale_x=1
	lovemu.scale_y=1
	lovemu.angle=0
	love.graphics.clear()
end

lovemu.errored=false
lovemu.error_msg=""

function love.load()
end

function love.update(dt)
end	

function love.draw()
end

console.AddCommand("lovemu", function(line)
	local param=string.explode(line," ")
	if param[1]=="run" then
		if param[2] then
			local str=""
			for i=2,#param do
				str=str..param[i]
			end
			if str=="" then
				print("Usage: lovemu run <folder name>")
			else
				lovemu.boot(str)
			end
		else
			print("Usage: lovemu run <folder name>")
		end
		
	elseif param[1]=="runreal" then
		if param[2] then
			local str=""
			for i=2,#param do
				str=str..param[i]
			end
			if str=="" then
				print("Usage: lovemu runreal <folder name>")
			else
				lovemu.bootreal(str)
			end
		else
			print("Usage: lovemu runreal <folder name>")
		end
	elseif param[1]=="check" then
		if param[2] then
			local functions_list={}
			for _,v in pairs(lovemu.listFiles(R("lovers/"..param[2].."/"),"lua")) do
				for _,l in pairs(string.explode(vfs.Read(v),"\n")) do
					if string.find(l,"love.") then
						if string.match(l,"(.-)%b()") then
							local x1,x2=string.find(l,"love.")
							l=l:sub(x2,#l)
							l=string.match(l,"(.-)%b()")
							if l then
								if l:sub(1,1)=="." then
									functions_list[l]=true
								end
							end
						end
					end
				end
			end
			for k in pairs(functions_list) do
				if not lovemu.supported[k] then
					print("NOT SUPPORTED: love"..k)
				else
					if lovemu.supported[k]==1 then
						print("PARTIAL:       love"..k)
					else
						--print("SUPPORTED:     love"..k)
					end
				end
			end
		else
			print("Usage: lovemu check <folder name>")
		end
	elseif param[1]=="version" then
		if param[2] then
			love._version=param[2]
			print("Changed internal version to "..param[2])
		else
			print("Usage: lovemu version <version>")
		end
		
	else
		print("Usage:")
		print("\tlovemu <command> <params>\n\nCommands:\n")
		print("\tcheck      <folder name>        //check game compatibility with lovemu")
		print("\trun        <folder name>        //runs a game  ")
		print("\trunreal    <folder name>        //runs a game on real love2d ")
		print("\tversion    <version>            //change internal love version, default: 0.9.0")
	end
end)
