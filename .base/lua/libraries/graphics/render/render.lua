local gl = require("lj-opengl") -- OpenGL
gl.debug = true

local render = _G.render or {}

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

function render.Initialize()		
	
	if not render.context_created then error("a window must exist before the renderer can be initialized", 2) end

	logf("opengl version: %s\n", render.GetVersion())
	logf("opengl glsl version: %s\n", render.GetShadingLanguageVersion())
	logf("vendor: %s\n", render.GetVendor())
	
	if render.GetVersion():find("OpenGL ES") then
		OPENGL_ES = true
	end
	
	local vendor = render.GetVendor()
	
	vfs.Write("info/gpu_vendor", vendor)
	vfs.Write("info/gl_version", render.GetVersion())
	
	if vendor:lower():find("nvidia") then
		NVIDIA = true
	elseif vendor:lower():find("ati") or vendor:lower():find("amd") then
		ATI = true
		-- AMD = true grr cpus
	end		

	if WINDOWS and X64 and NVIDIA then
		system.MessageBox("fatal error!!!!!", "Nvidia on x64 is not supported because for some weird reason it freezes.\nThe next time you launch it will launch the x86 version instead.\nPress OK to relaunch.")
		system.Restart()
		return
	end
		
	if render.debug then
		render.EnableDebug(true)
	end
	
	for path in vfs.Iterate("lua/decoders/image/", nil, true) do
		include(path)
	end
	
	SETUP_CACHED_UNIFORM("Uniform4f", gl.Uniform4f, 5)
	SETUP_CACHED_UNIFORM("Uniform3f", gl.Uniform3f, 4)
	SETUP_CACHED_UNIFORM("Uniform2f", gl.Uniform2f, 3)
	SETUP_CACHED_UNIFORM("Uniform1f", gl.Uniform1f, 2)
	SETUP_CACHED_UNIFORM("Uniform1i", gl.Uniform1i, 2)
	SETUP_CACHED_UNIFORM("UniformMatrix4fv", gl.UniformMatrix4fv, 4)
	
	render.frame = 0
		
	gl.Enable(gl.e.GL_BLEND)
	gl.Enable(gl.e.GL_SCISSOR_TEST)
	
	gl.BlendFunc(gl.e.GL_SRC_ALPHA, gl.e.GL_ONE_MINUS_SRC_ALPHA)
	gl.Disable(gl.e.GL_DEPTH_TEST)
	
	if gl.DepthRangef then
		gl.DepthRangef(1, 0)
	end
	
	render.SetClearColor(0.25, 0.25, 0.25, 0.5)
	system.SetWindowTitle("OpenGL " .. render.GetVersion(), "glversion")
	
	include("libraries/graphics/render/super_shader.lua", render)
	
	event.Delay(function()
		event.Call("RenderContextInitialized")	
	end)
end

do
	local vsync = 0
	
	function render.SetVSync(b)
		if gl.SwapIntervalEXT then
			gl.SwapIntervalEXT(b == true and 1 or b == "adaptive" and -1 or 0)
			vsync = b
		elseif window and window.IsOpen() then
			window.SwapInterval(b and 1 or 0) -- works on linux
		end
	end

	function render.GetVSync(b)
		return vsync
	end
end
 
function render.Shutdown()	

end

function render.GetVersion()		
	return ffi.string(gl.GetString(gl.e.GL_VERSION))
end

function render.GetShadingLanguageVersion()		
	return ffi.string(gl.GetString(gl.e.GL_SHADING_LANGUAGE_VERSION))
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

do
	local X, Y, W, H = 0,0,0,0
	
	function render.SetScissor(x,y,w,h)
		--render.ScissorRect(x,y,w,h)  
		--surface.StartClipping(x, y, w, h)

		local sw, sh = render.GetScreenSize()
		
		x=x or 0
		y=y or 0
		w=w or sw
		h=h or sh
		
		gl.Scissor(x, sh - (y + h), w, h)
		
		X = x
		Y = y
		W = w
		H = h
	end

	function render.GetScissor()
		return X,Y,W,H
	end
end

do
	local MODE = "alpha"

	function render.SetBlendMode(mode)
		gl.AlphaFunc(gl.e.GL_GEQUAL, 0)
		
		if mode == "alpha" then
			gl.BlendFunc(gl.e.GL_SRC_ALPHA, gl.e.GL_ONE_MINUS_SRC_ALPHA)
		elseif mode == "multiplicative" then
			gl.BlendFunc(gl.e.GL_DST_COLOR, gl.e.GL_ONE_MINUS_SRC_ALPHA)
		elseif mode == "premultiplied" then
			gl.BlendFunc(gl.e.GL_ONE, gl.e.GL_ONE_MINUS_SRC_ALPHA)
		else
			gl.BlendFunc(gl.e.GL_SRC_ALPHA, gl.e.GL_ONE)
		end
		
		MODE = mode
	end
	
	function render.GetBlendMode()
		return MODE
	end
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

include("mesh_util.lua", render)

if USE_SDL then
	include("sdl_window.lua", render)
else
	include("glfw_window.lua", render)
end

include("cvars.lua", render)
include("globals.lua", render)
include("debug.lua", render)

return render