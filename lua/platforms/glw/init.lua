-- internal libraries
if not gl then
	-- console input
	curses = include("ffi_binds/curses/init.lua")
	
	-- model decoder
	assimp = include("ffi_binds/assimp/assimp.lua")
	
	-- image decoder
	freeimage = include("ffi_binds/freeimage.lua")
	
	-- font decoder
	freetype = include("ffi_binds/freetype.lua")
	
	-- sound decoder
	soundfile = include("ffi_binds/soundfile/soundfile.lua")

	-- OpenGL
	gl = include("ffi_binds/gl/gl.lua")
	glu = include("ffi_binds/glu.lua")
	
	-- window manager
	glfw = include("ffi_binds/glfw.lua")
	
	-- OpenAL
	al = include("ffi_binds/al/al.lua")
	alc = include("ffi_binds/al/alc.lua")
end

-- high level implementation of curses
include("libraries/console.lua")

-- high level implementation of OpenGL
include("libraries/render/init.lua")

-- high level implementation of OpenAl
include("libraries/audio.lua")

-- high level implementation of render 3d mesh
include("libraries/model.lua")

-- high level implementation of luasocket
include("libraries/network/init.lua")

-- entities
include("libraries/entities/entities.lua")

-- helper commands
include("console_commands.lua")

-- high level window implementation
include("libraries/window.lua")

include("extensions/input.lua")


entities.LoadAllEntities()
addons.AutorunAll()

local main
local rate_cvar = console.CreateVariable("max_fps", 120)

-- main loop

function main()
	event.Call("Initialize")
			
	local next_update = 0
	local last_time = 0
	local smooth_fps = 0
	
	local function update(dt)
		luasocket.Update(dt)
		timer.Update(dt)
		
		event.Call("OnUpdate", dt)
	end
	
	while true do
		local time = glfw.GetTime()
		
		if next_update < time then
			local dt = time - (last_time or 0)
						
			local ok, err = xpcall(update, mmyy.OnError, dt)
			
			if not ok then				
				logn("shutting down")
				
				event.Call("ShutDown")
				return 
			end
		
			last_time = time
			
			local fps = dt
			smooth_fps = smooth_fps + ((fps - smooth_fps) * dt)
							
			system.SetWindowTitle(("FPS: %i"):format(1/smooth_fps), 1)
			
			if 1/smooth_fps < 30 then
				system.SetWindowTitle(("MS: %f"):format(smooth_fps*100), 3)
			else
				system.SetWindowTitle(nil, 3)
			end
			

			if gl.call_count then
				system.SetWindowTitle(("gl calls: %i"):format(gl.call_count), 2)
				gl.call_count = 0
			end
			
			local rate = rate_cvar:Get()
			
			rate = 1/rate
			
			next_update = time + rate
		end
	end
end

event.AddListener("Initialized", "main", main)
