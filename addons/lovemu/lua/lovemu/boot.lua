local love=love
local lovemu=lovemu

local getn=table.getn

local function run()
	love.update(lovemu.delta)
	love.draw()
end

function lovemu.boot(folder)
	include("lovemu/love/*")
	
	window.Open(800, 600)
	
	lovemu.errored = false
	lovemu.error_msg = ""
	lovemu.delta = 0
	lovemu.demoname = folder
	
	package.path=package.path..";"..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/lovemu/lovers/"..lovemu.demoname.."/?.lua","/","\\")
	package.path=package.path..";"..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/lovemu/lovers/"..lovemu.demoname.."/?/init.lua","/","\\")
	package.path=package.path..";"..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/lovemu/lovers/"..lovemu.demoname.."/?/?.lua","/","\\")
	
	
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
	
	local w = lovemu.conf.screen.width or 800
	local h = lovemu.conf.screen.height or 600
	local title = lovemu.conf.title or "LovEmu - The Love2D for GOLUWA"
	
	love.window.setMode(w,h)
	love.window.setTitle(title)
	
	include("lovers/"..folder.."/main.lua")
	love.load()
	
	-- disables the gbuffer for better performance since 2d stuff isn't using it
	render.EnableGBuffer(false)
	
	event.AddListener("OnDraw2D", "lovemu", function(dt)
		love.graphics.clear()
		lovemu.delta = dt
		surface.SetWhiteTexture()
		
		if lovemu.errored == false then
			local err, msg = xpcall(run, mmyy.OnError)
			if err == false then
				logn(msg)
				
				lovemu.errored = true
				lovemu.error_msg = msg
				
				love.errhand(lovemu.error_msg)
			end
		else
			love.errhand(lovemu.error_msg)
		end
	end)
	
	love.graphics.setBackgroundColor(0,0,0)
end