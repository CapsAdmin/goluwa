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

if jit.os == "Windows" then
	function curses.COLOR_PAIR(x)
		return bit.lshift(x, 8)
	end
end

setmetatable(curses, {__index = lib})

return curses
