-- internal libraries
if not gl then
	-- console input
	curses = include("ffi_binds/curses/init.lua")
	
	-- model decoder
	assimp = include("ffi_binds/assimp/init.lua")
	
	-- image decoder
	freeimage = include("ffi_binds/freeimage.lua")
	
	-- font decoder
	freetype = include("ffi_binds/freetype.lua")
	
	-- sound decoder
	soundfile = include("ffi_binds/soundfile/init.lua")

	-- OpenGL
	gl = include("ffi_binds/gl/init.lua")
	glu = include("ffi_binds/glu.lua")
	
	-- window manager
	glfw = include("ffi_binds/glfw.lua")
	
	-- window manager
	--sdl = include("ffi_binds/sdl/init.lua")
	
	-- OpenAL
	al = include("ffi_binds/al/init.lua")
	alc = include("ffi_binds/alc.lua")
end

-- high level implementation of curses
include("goluwa/libraries/console.lua")
-------- ^grr^^

-- OpenGL abstraction
include("libraries/render/init.lua")

-- high level 2d rendering of the render library
include("libraries/surface.lua")

-- high level implementation of OpenAl
include("libraries/audio.lua")

-- particles
include("libraries/particles.lua")

-- high level implementation of render 3d mesh
include("libraries/model.lua")

-- high level implementation of luasocket
include("libraries/network/init.lua")

-- entities
include("libraries/entities/entities.lua")

-- high level window implementation
include("libraries/window.lua")

include("extensions/input.lua")

include("libraries/image.lua")
include("libraries/gif.lua")


entities.LoadAllEntities()
addons.AutorunAll()
timer.clock = glfw.GetTime

include("main_loop.lua")