local love=love
local lovemu=lovemu

local hasWindow=false

local getn=table.getn

local function run()
	love.update(lovemu.delta)
	love.draw()
	lovemu.translate_x=0
	lovemu.translate_y=0
	lovemu.scale_x=1
	lovemu.scale_y=1
	lovemu.angle=0
end

function lovemu.boot(folder)
	--reload modules
	for i=1,getn(lovemu.modules) do
		include(lovemu.modules[i])
	end
	lovemu.errored=false
	lovemu.error_msg=""
	if hasWindow==false then
		window.Open(800, 600)
	end

	lovemu.demoname=folder
	package.path=package.path..";"..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/lovemu/lovers/"..lovemu.demoname.."/?.lua","/","\\")
	package.path=package.path..";"..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/lovemu/lovers/"..lovemu.demoname.."/?/init.lua","/","\\")
	package.path=package.path..";"..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/lovemu/lovers/"..lovemu.demoname.."/?/?.lua","/","\\")
	
	lovemu.delta=0
	lovemu.translate_x,lovemu.translate_y=0,0
	lovemu.scale_x,lovemu.scale_y=1,1
	lovemu.stack={}
	lovemu.stack_index=1
	
	function love.load()
	end

	function love.update(dt)
	end	

	function love.draw()
	end
	
	function love.mousepressed()
	end
	
	function love.mousereleased()
	end
	
	function love.keypressed()
	end
	
	function love.keyreleased()
	end
	
	lovemu.conf={}
	function love.conf(t) --partial
		t.screen={}
		t.window={}
		t.modules={}
		t.screen.height = 600      
		t.screen.width = 800  
		t.title = "LovEmu - The Love2D for GOLUWA"      
		t.author = "Shell32"
	end
	love.conf(lovemu.conf)

	if vfs.Exists(R("lovers/"..lovemu.demoname.."/conf.lua"))==true then
		print("LOADING CONF.LUA")
		include("lovers/"..folder.."/conf.lua")
	end
	love.conf(lovemu.conf)
	if not lovemu.conf.screen then
		lovemu.conf.screen={}
	end
	local w=lovemu.conf.screen.width or 800
	local h=lovemu.conf.screen.height or 600
	local title=lovemu.conf.title or "LovEmu - The Love2D for GOLUWA"
	love.window.setMode(w,h)
	love.window.setTitle(title)
	
	include("lovers/"..folder.."/main.lua")
	love.load()
	
	event.AddListener("OnDraw2D", "lovemu", function(dt)
		love.graphics.clear()
		lovemu.delta=dt
		surface.SetTexture()
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
	love.graphics.setBackgroundColor(0,0,0)
end