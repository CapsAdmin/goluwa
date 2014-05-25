local header = require("lj-curses.header")
local enums = require("lj-curses.enums")

ffi.cdef("typedef uint32_t chtype;")
ffi.cdef(header)

local lib = ffi.load(jit.os == "Windows" and "pdcurses" or "ncursesw")

local curses = {
	lib = lib, 
	e = enums,
}

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
