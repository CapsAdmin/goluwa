local surface=surface
local gl=gl

--love table
love={}
local love=love
love._version="0.9.0"
love.demoname="" --internal, demo folder name for the custom require functio

local modules={
		"lovemu/extras/util.lua",
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
		"lovemu/love/thread.lua",
		"lovemu/love/timer.lua"
	}

for i=1,#modules do
	include(modules[i])
end

local delta=0
function love.timer.getFPS()
	return 1/delta
end

local loaded=false

event.AddListener("OnDraw2D", "lovemu", function(dt)
	love.graphics.clear()
	if loaded==false then
		loaded=true
		love.load()
	end
	delta=dt
	surface.SetWhiteTexture()
	love.update(dt)
	love.draw()
end)

function love.load()
end

function love.update(dt)
end	

function love.draw()
end	


local package_cache={}
console.AddCommand("lovemu", function(line, time)

	local window = glw.OpenWindow(1280, 720)

	love.demoname=line
	if not package_cache[love.demoname] and love.demoname~="" then
		package_cache[love.demoname]=true
		package.path=package.path..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/"..love.demoname.."/?.lua","/","\\")..";"
		package.path=package.path..string.replace(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/"..love.demoname.."/?/init.lua","/","\\")..";"
	end
	loaded=false
	delta=0
	function love.load()
	end

	function love.update(dt)
	end	

	function love.draw()
	end
	
	include("demos/"..line.."/main.lua")
end)