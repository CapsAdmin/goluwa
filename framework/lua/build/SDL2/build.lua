package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")


local header = ffibuild.NixBuild({
	name = "SDL2",
	custom = [[
		SDL2 = SDL2.overrideAttrs (old: { configureFlags = old.configureFlags ++ [ "--disable-audio" ]; });
	]],
	src = [[
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

	typedef struct wl_display {} wl_display;
	typedef struct wl_surface {} wl_surface;
	typedef struct wl_shell_surface {} wl_shell_surface;

    #include "SDL2/SDL_video.h"
    #include "SDL2/SDL_shape.h"
	#include "SDL2/SDL.h"
    #include "SDL2/SDL_syswm.h"

]]})

--[==[
ffibuild.BuildSharedLibrary(
	"SDL2",
	"https://hg.libsdl.org/SDL",
	"./autogen.sh && mkdir build && cd build && ../configure --disable-audio --disable-render --disable-haptic --disable-filesystem --disable-file && make && cd ../"
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

    #include "SDL_video.h"
    #include "SDL_shape.h"
	#include "SDL.h"
    #include "SDL_syswm.h"

]], "-I./repo/include")
]==]
header = "struct SDL_BlitMap {};\n" .. header

local meta_data = ffibuild.GetMetaData(header)
meta_data.functions.SDL_main = nil

meta_data.structs["struct SDL_WindowShapeMode"] = nil
meta_data.functions.SDL_SetWindowShape.arguments[3] = ffibuild.CreateType("type", "void *")
meta_data.functions.SDL_GetShapedWindowMode.arguments[2] = ffibuild.CreateType("type", "void *")

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^SDL_") end, function(name) return name:find("^SDL_") or name:find("^KMOD_") end, true, true)

header = header:gsub("struct VkSurfaceKHR_T {};\n", "")
header = header:gsub("struct VkInstance_T {};\n", "")

header = header:gsub("struct VkInstance_T", "void")
header = header:gsub("struct VkSurfaceKHR_T", "void")

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^SDL_(.+)")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^SDL_(.+)", {"./include/SDL2/SDL_hints.h"}, "SDL_")

lua = lua .. [[
function library.CreateVulkanSurface(window, instance)
	local box = ffi.new("struct VkSurfaceKHR_T * [1]")

	if library.Vulkan_CreateSurface(window, instance, ffi.cast("void**", box)) == nil then
		return nil, ffi.string(library.GetError())
	end

	return box[0]
end

function library.GetRequiredInstanceExtensions(wnd, extra)
	local count = ffi.new("uint32_t[1]")

	if library.Vulkan_GetInstanceExtensions(wnd, count, nil) == 0 then
		return nil, ffi.string(library.GetError())
	end

	local array = ffi.new("const char *[?]", count[0])

	if library.Vulkan_GetInstanceExtensions(wnd, count, array) == 0 then
		return nil, ffi.string(library.GetError())
	end

	local out = {}
	for i = 0, count[0] - 1 do
		table.insert(out, ffi.string(array[i]))
	end

	if extra then
		for i,v in ipairs(extra) do
			table.insert(out, v)
		end
	end

	return out
end
]]

ffibuild.EndLibrary(lua, header)
