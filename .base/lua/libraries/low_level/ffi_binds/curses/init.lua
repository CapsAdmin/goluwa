local header = include("header.lua")
local enums = include("enums.lua")

ffi.cdef("typedef char chtype;")    

ffi.cdef(header)

local curses = {}

local lib = ffi.load(jit.os == "Windows" and "pdcurses" or "ncursesw")

function curses.freeconsole()
	if jit.os == "Windows" then
		ffi.cdef("int FreeConsole();")
		ffi.C.FreeConsole()
	end
end

setmetatable(curses, {__index = lib})

if false then -- todo: parse
	header = header:gsub("%s+", " ")
	header = header:gsub(";", "%1\n")

	for line in header:gmatch("(.-)\n") do
		if not line:find("typedef") then
			local name = line:match("([%a_%d]-)%(")
			if name then
				local ok, func = pcall(function() return lib[name] end)
				if not ok then print(func) end
				curses[name] = func
				
				if name == "nl" then print(line) end
			end
		end
	end  
end 
 
return curses