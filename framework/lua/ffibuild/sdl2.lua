ffibuild.Build(
	{
		name = "SDL2",
		url = "https://github.com/spurious/SDL-mirror.git", -- --host=x86_64-w64-mingw32
		cmd = "./autogen.sh && mkdir build && cd build && ../configure --disable-video-wayland && make --jobs 32 && cd ../",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		strip_undefined_symbols = true,
		c_source = [[
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
		#include "SDL_video.h"
		#include "SDL_shape.h"
		#include "SDL.h"
		#include "SDL_syswm.h"
		#include "SDL_vulkan.h"
ss
	]],
		gcc_flags = "-I./include",
		filter_library = function(path)
			if path:endswith("libSDL2") then return true end
		end,
		process_header = function(header)
			vfs.Write("rofl.h", header)
			local meta_data = ffibuild.GetMetaData(header)
			meta_data.functions.SDL_main = nil
			meta_data.structs["struct SDL_WindowShapeMode"] = nil
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^SDL_")
				end,
				function(name)
					return name:find("^SDL_") or name:find("^KMOD_")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			header = header:gsub("struct VkSurfaceKHR_T {};\n", "")
			header = header:gsub("struct VkInstance_T {};\n", "")
			header = header:gsub("struct VkInstance_T", "void")
			header = header:gsub("struct VkSurfaceKHR_T", "void")
			local lua = ffibuild.StartLibrary(header, "safe_clib_index")
			lua = lua .. "CLIB = SAFE_INDEX(CLIB)"
			lua = lua .. "library = " .. meta_data:BuildFunctions("^SDL_(.+)")
			lua = lua .. "library.e = " .. meta_data:BuildEnums("^SDL_(.+)", {"./include/SDL_hints.h"}, "SDL_")
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
			return ffibuild.EndLibrary(lua)
		end,
	}
)