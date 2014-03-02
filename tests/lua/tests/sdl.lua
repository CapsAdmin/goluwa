local sdl = include("libraries/low_level/ffi_binds/sdl/init.lua")

local function sdldie(msg)
    logf("%s: %s\n", msg, sdl.GetError())
    sdl.Quit()
    --os.exit(1)
end
 
if sdl.Init(e.SDL_INIT_VIDEO) < 0 then
	sdldie("Unable to initialize SDL");
end

sdl.GL_SetAttribute(e.SDL_GL_CONTEXT_MAJOR_VERSION, 3)
sdl.GL_SetAttribute(e.SDL_GL_CONTEXT_MINOR_VERSION, 2)

sdl.GL_SetAttribute(e.SDL_GL_DOUBLEBUFFER, 1)
sdl.GL_SetAttribute(e.SDL_GL_DEPTH_SIZE, 24)
 
local mainwindow = sdl.CreateWindow(
	"test", 
	e.SDL_WINDOWPOS_CENTERED, 
	e.SDL_WINDOWPOS_CENTERED,
	512, 
	512, 
	bit.bor(e.SDL_WINDOW_OPENGL, e.SDL_WINDOW_SHOWN)
)

if not mainwindow then
	sdldie("Unable to create window")
end


local maincontext = sdl.GL_CreateContext(mainwindow)

print(maincontext)

sdl.GL_SetSwapInterval(1)

gl.ClearColor(1.0, 0.0, 0.0, 1.0)
gl.Clear(e.GL_COLOR_BUFFER_BIT)
sdl.GL_SwapWindow(mainwindow)
sdl.Delay(2000)

gl.ClearColor(0.0, 1.0, 0.0, 1.0)
gl.Clear(e.GL_COLOR_BUFFER_BIT)
sdl.GL_SwapWindow(mainwindow)
sdl.Delay(2000)

gl.ClearColor(0.0, 0.0, 1.0, 1.0)
gl.Clear(e.GL_COLOR_BUFFER_BIT)
sdl.GL_SwapWindow(mainwindow)
sdl.Delay(2000)
 
sdl.GL_DeleteContext(maincontext)
sdl.DestroyWindow(mainwindow)
sdl.Quit()