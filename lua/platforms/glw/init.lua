include("curses.lua")

if not gl then
	gl = include("libraries/ffi_binds/gl.lua")
	glu = include("libraries/ffi_binds/glu.lua")
	glfw = include("libraries/ffi_binds/glfw.lua")
	freeimage = include("libraries/ffi_binds/freeimage.lua")
	ftgl = include("libraries/ffi_binds/ftgl.lua")
end

--surface = include("libraries/surface.lua")
render = include("libraries/render.lua")

include("libraries/mesh.lua")
include("extensions/input.lua")

addons.AutorunAll()
 
glw = glw or {}

function glw.OpenWindow(w, h, title)
	if glw.window and glw.window:IsValid() then glw.window:Remove() end

	w = w or 640
	h = h or 480
	title = title or "no title"

	local window = glfw.CreateWindow(w, h, title)
	glfw.MakeContextCurrent(window.ptr)

	if gl and gl.InitMiniGlew then
		gl.InitMiniGlew()
	end
	
	for name in pairs(window.availible_callbacks) do
		window[name] = function(...)
			if event.Call(name, ...) ~= false and glw[name] then
				glw[name](...)
			end
		end	
	end

	if render then
		render.Initialize(w, h)
	end

	glw.window = window
	
	return window
end

do -- input extensions
	local trigger = input.SetupInputEvent("Key")

	function glw.OnKey(key, scancode, action, mods)
		if action == e.GLFW_REPEAT then return end
		
		trigger(glfw.KeyToString(key), action == e.GLFW_PRESS)
	end

	local trigger = input.SetupInputEvent("Mouse")

	function glw.OnMouseButton(button, action, mods)
		trigger(glfw.MouseToString(button), action == e.GLFW_PRESS)
	end
	
	function input.GetMousePos()
		local x, y = ffi.new("double[1]"), ffi.new("double[1]")
		glfw.GetCursorPos(glw.window.ptr, x, y)
		
		return Vec2(x[0], y[0])
	end
	
	function input.SetMousePos(pos)
		glfw.SetCursorPos(glw.window.ptr, pos.x, pos.y)
	end
	
	function input.ShowCursor(b)
		if b then
			glfw.SetInputMode(glw.window.ptr, e.GLFW_CURSOR, e.GLFW_CURSOR_NORMAL)
		else
			glfw.SetInputMode(glw.window.ptr, e.GLFW_CURSOR, e.GLFW_CURSOR_HIDDEN)
		end
	end
	
	
	function input.SetMouseTrapped(b)
		input.mouse_trapped = b
	end

	function input.GetMouseDelta()
		return input.mouse_delta or Vec2()
	end
end

function glw.SetWindowSize(x, y)
	glfw.SetWindowSize(glw.window.ptr, x, y)
end

function glw.GetWindowSize()
	local x, y = ffi.new("int[1]"), ffi.new("int[1]")
	glfw.GetWindowSize(glw.window.ptr, x, y)
	
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

do -- update	
	local smooth_fps = 0
	local fps_fmt = "FPS: %i"
	glw.max_fps = 120

	local sleep

	if WINDOWS then
		ffi.cdef("void Sleep(int ms)")
		sleep = function(ms) ffi.C.Sleep(ms) end
	end

	if LINUX then
		ffi.cdef("void usleep(unsigned int ns)")
		sleep = function(ms) ffi.C.usleep(ms*1000) end
	end
	
	local last = socket.gettime()

	function glw.Update()
		sleep(1000/glw.max_fps)
		
		glfw.PollEvents()
		luasocket.Update()
		timer.Update()

		
		local t = socket.gettime()
		local dt = t - last

		smooth_fps = smooth_fps + (((1/dt) - smooth_fps) * dt)

		mmyy.SetWindowTitle(string.format(fps_fmt, smooth_fps), 1)

		event.Call("OnUpdate", dt) 

		if glw.window and glw.window:IsValid() then
			event.Call("OnDraw", dt)
			glw.UpdateMouseMove()
		end
		
		last = t
	end
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

local function main()
	event.Call("Initialize")

	while true do	
		local ok, err = xpcall(glw.Update, OnError)

		if not ok then
			log(err)
			io.stdin:read("*l")
			break
		end
	end

	event.Call("ShutDown")
end

event.AddListener("Initialized", "main", main)
