package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

ffibuild.BuildSharedLibrary(
	"SDL2",
	"https://github.com/spurious/SDL-mirror.git",
	"./autogen.sh && mkdir build && cd build && ../configure && make && cd ../"
)

local header = ffibuild.BuildCHeader([[


typedef enum  {
	SDL_INIT_TIMER = 0x00000001,
	SDL_INIT_AUDIO = 0x00000010,
	SDL_INIT_VIDEO = 0x00000020,
	SDL_INIT_JOYSTICK = 0x00000200,
	SDL_INIT_HAPTIC = 0x00001000,
	SDL_INIT_GAMECONTROLLER = 0x00002000,
	SDL_INIT_EVENTS = 0x00004000,
	SDL_INIT_NOPARACHUTE = 0x00100000,
	SDL_INIT_EVERYTHING = SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_EVENTS | SDL_INIT_JOYSTICK | SDL_INIT_HAPTIC | SDL_INIT_GAMECONTROLLER,

	SDL_WINDOWPOS_UNDEFINED_MASK  =  0x1FFF0000,
	SDL_WINDOWPOS_UNDEFINED_DISPLAY  = SDL_WINDOWPOS_UNDEFINED_MASK,
	SDL_WINDOWPOS_UNDEFINED       =  SDL_WINDOWPOS_UNDEFINED_DISPLAY,
	SDL_WINDOWPOS_CENTERED_MASK   = 0x2FFF0000,
	SDL_WINDOWPOS_CENTERED        = SDL_WINDOWPOS_CENTERED_MASK
} SDL_grrrrrr;

	#include "SDL.h"
    #include "SDL_syswm.h"

]], "-I./repo/include")

header = "struct SDL_BlitMap {};\n" .. header

local meta_data = ffibuild.GetMetaData(header)
meta_data.functions.SDL_main = nil
local header = meta_data:BuildMinimalHeader(function(name) return name:find("^SDL_") end, function(name) return name:find("^SDL_") or name:find("^KMOD_") end, true, true)

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^SDL_(.+)")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^SDL_(.+)")

ffibuild.EndLibrary(lua, header)
