ffibuild.Build(
	{
		name = "SDL2",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		strip_undefined_symbols = true,
		linux = [[
			FROM ubuntu:20.04

			ARG DEBIAN_FRONTEND=noninteractive
			ENV TZ=America/New_York
			RUN apt-get update
			
			# https://github.com/libsdl-org/SDL/blob/main/.github/workflows/main.yml
			RUN apt-get install -y \
				git \
				wayland-protocols \
				pkg-config \
				ninja-build \
				libasound2-dev \
				libdbus-1-dev \
				libegl1-mesa-dev \
				libgl1-mesa-dev \
				libgles2-mesa-dev \
				libglu1-mesa-dev \
				libibus-1.0-dev \
				libpulse-dev \
				libsdl2-2.0-0 \
				libsndio-dev \
				libudev-dev \
				libwayland-dev \
				libwayland-client++0 \
				wayland-scanner++ \
				libwayland-cursor++0 \
				libx11-dev \
				libxcursor-dev \
				libxext-dev \
				libxi-dev \
				libxinerama-dev \
				libxkbcommon-dev \
				libxrandr-dev \
				libxss-dev \
				libxt-dev \
				libxv-dev \
				libxxf86vm-dev \
				libdrm-dev \
				libgbm-dev\
				libpulse-dev \
				libpango1.0-dev \ 
				autoconf

			RUN apt-get install -y gcc make

			WORKDIR /src

			RUN git clone https://github.com/libsdl-org/SDL --depth 1 .
			RUN ./autogen.sh && mkdir build && cd build && ../configure --disable-video-wayland && make --jobs 32 && cd ../

		]],
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
	]],
		gcc_flags = "-I./include",
		filter_library = function(path)
			if path:ends_with("libSDL2") then return true end
		end,
		process_header = function(header)
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
			local s = [=[
				local ffi = require("ffi")
				local lib = assert(ffi.load("SDL2"))
				ffi.cdef([[]=] .. header .. [=[]])
				local CLIB = setmetatable({}, {__index = function(_, k)
					local ok, val = pcall(function() return lib[k] end)
					if ok then
						return val
					end
				end})
			]=]
			s = s .. "library = " .. meta_data:BuildLuaFunctions("^SDL_(.+)")
			s = s .. "library.e = " .. meta_data:BuildLuaEnums("^SDL_(.+)", {"./include/SDL_hints.h"}, "SDL_")
			s = s .. [[
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
				list.insert(out, ffi.string(array[i]))
			end

			if extra then
				for i,v in ipairs(extra) do
					list.insert(out, v)
				end
			end

			return out
		end
		]]
			s = s .. "library.clib = CLIB\n"
			s = s .. "return library\n"
			return s
		end,
	}
)