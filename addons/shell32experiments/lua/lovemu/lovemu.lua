local surface=surface
local gl=gl

--love table
love={}
local love=love
love._version="0.9.0"
love.demoname="top_gear_results" --internal, demo folder name for the custom require function

function require(str)
	if str:sub(1,1)=="/" or str:sub(1,1)=="\\" then
		str=str:sub(2,#str)
	end
	if string.find(str,".") then
		local tab=string.split(str,".")
		str=""
		for _,v in pairs(tab) do
			str=str..v.."/"
		end
		str=str:sub(1,#str-1)
		if not vfs.Exists(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/".. love.demoname .. "/"..str..".lua") then
			str=str.."/init.lua"
		end
	end
	
	print("Attempt to load: "..e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/".. love.demoname .. "/"..str)
	include(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/".. love.demoname .. "/"..str)
end

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
	if loaded==false then
		loaded=true
		love.load()
	end
	delta=dt
	surface.SetWhiteTexture()
	love.draw()
	love.graphics.reset()
end)

event.AddListener("OnUpdate", "lovemu", function(dt)
	love.update(dt)
end)

function love.load()
end

function love.update(dt)
end	

function love.draw()
end	

console.AddCommand("lovemu", function(line, time)

	local window = glw.OpenWindow(1280, 720)

	love.demoname=line
	print(love.demoname)
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