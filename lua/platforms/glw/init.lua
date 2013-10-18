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
timer.clock = glfw.GetTime

include("main_loop.lua")