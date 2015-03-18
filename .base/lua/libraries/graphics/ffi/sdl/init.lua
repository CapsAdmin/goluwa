local header = include("header.lua") 
local enums = include("enums.lua")

ffi.cdef(header)
  
local lib = assert(ffi.load("SDL2"))

local sdl = {
	e = enums,
	header = header,
	lib = lib,
}

-- put all the functions in the sdl table
for line in header:gmatch("(.-)\n") do
	local name = line:match("extern __attribute__%(%(dllexport%)%).-SDL_(%S-)%(")
	if name then
		local ok, err = pcall(function()
			local func = lib["SDL_" .. name]
			
			if DEBUG then				
				sdl[name] = function(...) 
					local res = func(...)
					
					if name ~= "GetError" then
						local err = ffi.string(sdl.GetError())
						if err ~= "" then
							sdl.ClearError()
							error(err, 2)
						end
						
						if sdl.logcalls then
							setlogfile("sdl_calls")			
								local args = {}
								for i =  1, select("#", ...) do
									local val = select(i, ...)
									if type(val) == "number" and sdl.reverse_enums[val] and val > 10 then
										args[#args+1] = sdl.reverse_enums[val]
									else
										args[#args+1] = serializer.GetLibrary("luadata").ToString(val)
									end
								end
								
								if not val then
									logf("SDL_%s(%s)\n", name, table.concat(args, ", "))
								else
									local val = val
									if sdl.reverse_enums[val] then
										val = sdl.reverse_enums[val]
									end
									
									logf("%s = SDL_%s(%s)\n", val, name, table.concat(args, ", "))
								end
							setlogfile()
						end
					end
					
					return res
				end
			else
				sdl[name] = func
			end
		end)
		
		if not ok then
			--print(err)
		end
	end
end

do
	local reverse_enums = {}

	for k,v in pairs(enums) do
		local nice = k:lower():sub(#("SDL_"))
		reverse_enums[v] = nice
	end

	function sdl.EnumToString(num)
		return reverse_enums[num]
	end
	
	sdl.reverse_enums = reverse_enums
end

function sdl.GenerateHeader()
	-- this requires mingw installed
	os.execute("gcc -E " .. R("lua/libraries/low_level/ffi_binds/sdl/include/sdl.h") .. " -o gcc_output.h")
	local content = vfs.Read("gcc_output.h")

	
	-- this is kinda stupid because of the SDLKey enums that are defined like " SDLK_SEMICOLON = ';' "
	-- which would be replaced with "';\n'" and thus breaking luajit's c header parser 
	-- so we have to use [^'] to make an exception for that
	
	content = content:gsub("# .-\n", "") -- remove the line directive comments
	content = content:gsub("%s+", " ") -- remove excessive newlines
	content = content:gsub(";[^']", ";\n")
	content = content:gsub("({.-})", function(str) return str:gsub(",[^']", ",\n") end)
	
	vfs.Write(e.ROOT_FOLDER .. "/.base/lua/libraries/low_level/ffi_binds/sdl/header.lua", "return [[" .. content .. "]]") 
	
	-- eww
	local enums = ""
	for enum in content:gmatch("typedef enum {(.-)}") do
		if not enum:find("=") then
			local new = ""
			local i = 0
			for key in enum:gmatch("(.-),") do
				key = key:trim()
				if key ~= "" then
					new = new .. key .. " = " .. i .. ",\n"
					i = i + 1
				end
			end
			new = new:sub(0,-3)
			enum = new
		end
		
		if enum ~= "" then
			enums = enums .. enum .. ",\n"
		end
	end
 
	vfs.Write(e.ROOT_FOLDER .. "/.base/lua/libraries/low_level/sdl/enums.lua", "return {" .. enums .. "}") 
end
 
sdl.events = {
	SDL_QUIT = 0x100,
	SDL_APP_TERMINATING = 0x101,
	SDL_APP_LOWMEMORY = 0x102,
	SDL_APP_WILLENTERBACKGROUND = 0x103,
	SDL_APP_DIDENTERBACKGROUND = 0x104,
	SDL_APP_WILLENTERFOREGROUND = 0x105,
	SDL_APP_DIDENTERFOREGROUND = 0x106,
	SDL_WINDOWEVENT = 0x200,
	SDL_SYSWMEVENT = 0x201,
	SDL_KEYDOWN = 0x300,
	SDL_KEYUP = 0x301,
	SDL_TEXTEDITING = 0x302,
	SDL_TEXTINPUT = 0x303,
	SDL_MOUSEMOTION = 0x400,
	SDL_MOUSEBUTTONDOWN = 0x401,
	SDL_MOUSEBUTTONUP = 0x402,
	SDL_MOUSEWHEEL = 0x403,
	SDL_JOYAXISMOTION = 0x600,
	SDL_JOYBALLMOTION = 0x601,
	SDL_JOYHATMOTION = 0x602,
	SDL_JOYBUTTONDOWN = 0x603,
	SDL_JOYBUTTONUP = 0x604,
	SDL_JOYDEVICEADDED = 0x605,
	SDL_JOYDEVICEREMOVED = 0x606,
	SDL_CONTROLLERAXISMOTION = 0x650,
	SDL_CONTROLLERBUTTONDOWN = 0x651,
	SDL_CONTROLLERBUTTONUP = 0x652,
	SDL_CONTROLLERDEVICEADDED = 0x653,
	SDL_CONTROLLERDEVICEREMOVED = 0x654,
	SDL_CONTROLLERDEVICEREMAPPED = 0x655,
	SDL_FINGERDOWN = 0x700,
	SDL_FINGERUP = 0x701,
	SDL_FINGERMOTION = 0x702,
	SDL_DOLLARGESTURE = 0x800,
	SDL_DOLLARRECORD = 0x801,
	SDL_MULTIGESTURE = 0x802,
	SDL_CLIPBOARDUPDATE = 0x900,
	SDL_DROPFILE = 0x1000,
	SDL_USEREVENT = 0x8000,
}
 
sdl.window_events = {
	SDL_WINDOWEVENT_NONE = 0,
	SDL_WINDOWEVENT_SHOWN = 1,
	SDL_WINDOWEVENT_HIDDEN = 2,
	SDL_WINDOWEVENT_EXPOSED = 3,
	SDL_WINDOWEVENT_MOVED = 4,
	SDL_WINDOWEVENT_RESIZED = 5,
	SDL_WINDOWEVENT_SIZE_CHANGED = 6,
	SDL_WINDOWEVENT_MINIMIZED = 7,
	SDL_WINDOWEVENT_MAXIMIZED = 8,
	SDL_WINDOWEVENT_RESTORED = 9,
	SDL_WINDOWEVENT_ENTER = 10,
	SDL_WINDOWEVENT_LEAVE = 11,
	SDL_WINDOWEVENT_FOCUS_GAINED = 12,
	SDL_WINDOWEVENT_FOCUS_LOST = 13,
	SDL_WINDOWEVENT_CLOSE = 14,
}
 
--sdl.GenerateHeader()
 
return sdl