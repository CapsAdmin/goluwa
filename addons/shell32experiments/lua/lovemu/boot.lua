local package_cache={}
local hasWindow=false
function lovemu.boot(folder)
	lovemu.errored=false
	lovemu.error_msg=""
	if hasWindow==false then
		local window = glw.OpenWindow(800, 600)
	end

	lovemu.demoname=folder
	if not package_cache[lovemu.demoname] and lovemu.demoname~="" then
		package_cache[lovemu.demoname]=true
		package.path=package.path..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/"..lovemu.demoname.."/?.lua","/","\\")..";"
		package.path=package.path..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/"..lovemu.demoname.."/?/init.lua","/","\\")..";"
	end
	
	lovemu.delta=0
	lovemu.translate_x,lovemu.translate_y=0,0
	lovemu.scale_x,lovemu.scale_y=1,1
	lovemu.angle=0
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
	
	include("demos/"..folder.."/main.lua")
	love.load()
end