local gl = require("lj-opengl") -- OpenGL
local glfw = require("lj-glfw") -- Window Manager
local render = _G.render or {}

local render=render

local event=event
local gl=gl
local assert=assert
local loadstring=loadstring
local ffi=ffi
local math = math
local string = string
local table = table
local tostring = tostring
local tonumber = tonumber

render.top_left = true

local function SETUP_CACHED_UNIFORM(name, func, arg_count)	
	local lua = [[
	local func = ...
	local last_program, __LAST_LOCALS__

	function render.__NAME__(__ARGUMENTS__)

		if 
			render.current_program == last_program and 
			__COMPARE__ 
		then return end
		
		func(__ARGUMENTS__)
		
		last_program = render.current_program
		__ASSIGN__
	end
	]]
		
	local last_locals = ""
	local arguments = ""
	local compare = ""
	local assign = ""
		
	for i = 1, arg_count do
		last_locals =  last_locals .. "last_" .. i
		arguments = arguments .. "_" .. i
		compare = compare .. "_" .. i .. " == last_" .. i
		assign = assign .. "last_" .. i .. " = _" .. i .. "\n"
		
		if i ~= arg_count then
			last_locals = last_locals .. ", "
			arguments = arguments .. ", "
			compare = compare .. " and \n"
		end
	end
	
	lua = lua:gsub("__LAST_LOCALS__", last_locals)
	lua = lua:gsub("__ARGUMENTS__", arguments)
	lua = lua:gsub("__COMPARE__", compare)
	lua = lua:gsub("__NAME__", name)
	lua = lua:gsub("__ASSIGN__", assign)
	
	assert(loadstring(lua))(func)
end

function render.Initialize(w, h, window)		
	check(w, "number")
	check(h, "number")
		
	for path in vfs.Iterate("lua/decoders/image/", nil, true) do
		include(path)
	end

	glfw.Init()

	window = window or render.CreateWindow(w, h)
	
	if render.debug then
		render.EnableDebug(true)
	end

	SETUP_CACHED_UNIFORM("Uniform4f", gl.Uniform4f, 5)
	SETUP_CACHED_UNIFORM("Uniform3f", gl.Uniform3f, 4)
	SETUP_CACHED_UNIFORM("Uniform2f", gl.Uniform2f, 3)
	SETUP_CACHED_UNIFORM("Uniform1f", gl.Uniform1f, 2)
	SETUP_CACHED_UNIFORM("Uniform1i", gl.Uniform1i, 2)
	SETUP_CACHED_UNIFORM("UniformMatrix4fv", gl.UniformMatrix4fv, 4)

	render.current_window = NULL 
	render.frame = 0
	
	render.w = w
	render.h = h
	render.camera.w = w
	render.camera.h = h
	
	gl.Enable(gl.e.GL_BLEND)
	gl.Enable(gl.e.GL_TEXTURE_2D)

	gl.BlendFunc(gl.e.GL_SRC_ALPHA, gl.e.GL_ONE_MINUS_SRC_ALPHA)
	gl.Disable(gl.e.GL_DEPTH_TEST)
	
	if gl.DepthRangef then
		gl.DepthRangef(1, 0)
	end

	if gl.SwapIntervalEXT then
		gl.SwapIntervalEXT(0)
	end
	
	render.SetClearColor(0.25, 0.25, 0.25, 0.5)
	
	render.InitializeDeffered()
	
	if surface then
		surface.Initialize()
	end
	
	event.Call("RenderContextInitialized")
		
	system.SetWindowTitle("OpenGL " .. render.GetVersion(), "glversion")
	
	return window
end

function render.Shutdown()	
	glfw.Terminate()
end

local last_w
local last_h

function render.Start(window)
	glfw.MakeContextCurrent(window.__ptr) 
		
	render.current_window = window
	local w, h = window:GetSize():Unpack()
	render.w = w
	render.h = h
	render.SetViewport(0, 0, w, h)
	
	if w ~= last_w or h ~= last_h then
		event.Call("OnResized", window, w, h)
		last_w = w
		last_h = h
	end
end

function render.End()

	if render.current_window:IsValid() then
		glfw.SwapBuffers(render.current_window.__ptr)
	end

	render.frame = render.frame + 1	
end

function render.GetFrameNumber()
	return render.frame
end

function render.GetScreenSize()
	if render.current_window:IsValid() then
		return render.current_window:GetSize():Unpack()
	end
	
	return 0, 0
end

function render.GetVersion()		
	return ffi.string(gl.GetString(gl.e.GL_VERSION))
end

function render.GetVendor()		
	return ffi.string(gl.GetString(gl.e.GL_VENDOR))
end

function render.CheckSupport(func)
	if not gl[func] then
		logf("%s: the function gl.%s does not exist\n", debug.getinfo(2).func:name(), func)
		return false
	end
	
	return true
end

function render.SetClearColor(r,g,b,a)
	gl.ClearColor(r,g,b, a or 1)
end

function render.Clear(flag, ...)
	flag = flag or gl.e.GL_COLOR_BUFFER_BIT
	gl.Clear(bit.bor(flag, ...))
end

function render.ScissorRect(x, y, w, h)
	if not x then
		gl.Disable(gl.e.GL_SCISSOR_TEST)
	else
		gl.Scissor(x, y, w, h)
		gl.Enable(gl.e.GL_SCISSOR_TEST)
	end
end

function render.SetAdditive(b)
	if b then
		gl.BlendFunc(gl.e.GL_SRC_ALPHA, gl.e.GL_ONE)
	else
		gl.BlendFunc(gl.e.GL_SRC_ALPHA, gl.e.GL_ONE_MINUS_SRC_ALPHA)
		
	end
end

function render.GetAdditive(b)
	return render.additive
end
 
do
	local data = ffi.new("float[3]")

	function render.ReadPixels(x, y, w, h)
		w = w or 1
		h = h or 1
		
		gl.ReadPixels(x, y, w, h, gl.e.GL_RGBA, gl.e.GL_FLOAT, data)
			
		return data[0], data[1], data[2], data[3]
	end
end

include("enum_translate.lua", render)
include("generated_textures.lua", render)
include("matrices.lua", render)
include("scene.lua", render)
include("texture.lua", render)
include("framebuffer.lua", render)
include("shaders.lua", render)
include("deferred.lua", render)
include("model.lua", render)

include("super_shader.lua", render)
include("mesh_util.lua", render)

include("window.lua", render)

include("cvars.lua", render)
include("globals.lua", render)
include("debug.lua", render)

return render