if not gl then
	curses = include("ffi_binds/curses/init.lua")

	gl = include("ffi_binds/gl.lua")
	al = include("ffi_binds/al/al.lua")
	alc = include("ffi_binds/al/alc.lua")
	glu = include("ffi_binds/glu.lua")
	glfw = include("ffi_binds/glfw.lua")
	freeimage = include("ffi_binds/freeimage.lua")
	freetype = include("ffi_binds/freetype.lua")
	ftgl = include("ffi_binds/ftgl.lua")
	soundfile = include("ffi_binds/soundfile/soundfile.lua")	
end

include("libraries/console.lua")

include("libraries/render/init.lua")
include("libraries/surface.lua")
include("libraries/entities/entities.lua")

include("libraries/audio.lua")
include("libraries/font.lua")
include("libraries/window.lua")

include("libraries/network/init.lua")

entities.LoadAllEntities()
addons.AutorunAll()

include("libraries/find.lua")

glw = glw or {}

function glw.OpenWindow(w, h, title)
	if glw.window and glw.window:IsValid() then return glw.window end

	w = w or 640
	h = h or 480
	title = title or "no title"

	local window = Window(w, h, title)
	window.w = w
	window.h = h
		
	for name in pairs(window.availible_callbacks) do
		window[name] = function(...)
			if event.Call(name, ...) ~= false and glw[name] then
				glw[name](...)
			end
		end	
	end
	
	glw.window = window
	
	return window
end

function glw.SetWindowSize(x, y)
	glfw.SetWindowSize(glw.window.__ptr, x, y)
end

function glw.GetWindowSize()
	local x, y = ffi.new("int[1]"), ffi.new("int[1]")
	glfw.GetWindowSize(glw.window.__ptr, x, y)
	
	return Vec2(x[0], y[0])
end

function glw.OnWindowFocus(b)
	glw.focused = b
end

function glw.HasFocus()
	return glw.focused
end

local last
 
function glw.UpdateMouseMove()	
	local border_size = 140

	if input.mouse_trapped and glw.HasFocus() and not input.IsKeyDown("escape") then
		local size = glw.GetWindowSize() - border_size*2
		local pos = input.GetMousePos() - border_size

		input.mouse_delta = (pos - (last or pos)) 
				
		last = pos
		
		input.ShowCursor(false)
		
		if pos.x > size.x then
			input.SetMousePos(Vec2(0, pos.y) + border_size)
			last.x = 0
		elseif pos.x < 0 then
			input.SetMousePos(Vec2(size.x, pos.y) + border_size)
			last.x = size.x 
		end 
		
		if pos.y > size.y then
			input.SetMousePos(Vec2(pos.x, 0) + border_size)
			last.y = 0
		elseif pos.y < 0 then
			input.SetMousePos(Vec2(pos.x, size.y) + border_size)
			last.y = size.y
		end	
	else 
		input.ShowCursor(true)
		last = nil
		input.mouse_delta = Vec2()
	end 
end

function glw.OnWindowClose(params)
	glw.window:Remove()
end

function glw.GetWindow()
	return glw.window
end

do
	local temp = {}

	for key, val in pairs(_E) do
		if key:sub(1, 4) == "EVT_" then
			temp[val] = key
		end
	end

	local events = {}

	for k,v in pairs(temp) do
		v = "On" .. v:gsub("EVT(.+)", function(str)
			return str:lower():gsub("(_.)", function(char)
				return char:sub(2):upper()
			end)
		end)
		
		events[k] = v
		events[v] = {v = k, k = v}
	end

	function glw.HandleEvent(params)
		local name = events[tonumber(params.type)]
		if name and event.Call(name, params) ~= false then
			if glw[name] then
				glw[name](params)
			end
		end
	end
end

include("extensions/input.lua")
include("console_commands.lua")

function glw.Update(dt)	
	glfw.PollEvents()
		
	luasocket.Update()
	timer.Update()
	
	event.Call("OnUpdate", dt)

	if glw.window and glw.window:IsValid() then
		glw.UpdateMouseMove()	
	
		render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)

		render.Start(glw.window)		
			event.Call("PreDisplay", dt)
			
			render.Start3D()
			event.Call("OnDraw3D", dt)
			
			render.Start2D()
			event.Call("OnDraw2D", dt)
			
			event.Call("PostDisplay", dt)
		render.End()
	end
end

local function main()
	event.Call("Initialize")
		
	local rate_cvar = console.CreateVariable("max_fps", 120)
	
	local next_update = 0
	local last_time = 0
	local smooth_fps = 0
	
	while true do
		local time = glfw.GetTime()
		
		if next_update < time then
			local dt = time - (last_time or 0)
			
			local ok = glw.Update(dt)
		
			last_time = time
			
			local fps = 1/dt
			smooth_fps = smooth_fps + ((fps - smooth_fps) * dt)
							
			system.SetWindowTitle(("FPS: %i"):format(smooth_fps), 1)
			
			local rate = rate_cvar:Get()
			
			rate = 1/rate
			
			next_update = time + rate
		end
	end

	event.Call("ShutDown")
end

event.AddListener("Initialized", "main", main)
