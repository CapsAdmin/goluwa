local surface=surface

--love table
love={}
local love=love
love._version="0.9.0"

lovemu={}
local lovemu=lovemu
lovemu.demoname="" --internal, demo folder name
lovemu.delta=0 --frametime

local modules={
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
		"lovemu/love/timer.lua"
	}

--load modules
for i=1,#modules do
	include(modules[i])
end

lovemu.supported={}
for _,v in pairs(lovemu.listFiles(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/lua/lovemu/","lua")) do
	for _,l in pairs(string.split(vfs.Read(v),"\n")) do
		if string.find(l,"love.") then
			if string.match(l,"(.-)%b()") then
				local isPARTIAL=false
				if string.find(l,"--partial") then
					isPARTIAL=true
				end
				local x1,x2=string.find(l,"love.")
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

	table.insert(err, "Error\n")
	table.insert(err, msg.."\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

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
end

lovemu.errored=false
lovemu.error_msg=""
event.AddListener("OnDraw2D", "lovemu", function(dt)
	love.graphics.clear()
	lovemu.delta=dt
	surface.white_texture:Bind()
	if lovemu.errored==false then
		local err,msg=pcall(run)
		if err==false then
			print("\nERROR\n")
			print(msg)
			lovemu.errored=true
			lovemu.error_msg=msg
			love.errhand(lovemu.error_msg)
		end
	else
		love.errhand(lovemu.error_msg)
	end
end)

function love.load()
end

function love.update(dt)
end	

function love.draw()
end	

console.AddCommand("lovemu", function(line)
	local param=string.split(line," ")
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
		
	elseif param[1]=="check" then
		if param[2] then
			local functions_list={}
			for _,v in pairs(lovemu.listFiles(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/"..param[2].."/","lua")) do
				for _,l in pairs(string.split(vfs.Read(v),"\n")) do
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
		print("\tversion    <version>            //change internal love version, default: 0.9.0")
	end
end)
