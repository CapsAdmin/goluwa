local header = include("header.lua") 
local enums = include("enums.lua")

ffi.cdef("typedef uint64_t chtype;")
ffi.cdef(header)

local lib = assert(ffi.load(jit.os == "Windows" and "pdcurses" or "ncursesw"))

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
	-- use pdcurses for real windows!
	
	curses.COLOR_BLACK = 0
	
	curses.COLOR_RED = 4
	curses.COLOR_GREEN = 2
	curses.COLOR_YELLOW = 6

	curses.COLOR_BLUE = 1
	curses.COLOR_MAGENTA = 5
	curses.COLOR_CYAN = 3
	
	curses.COLOR_WHITE = 7	

	curses.A_REVERSE = 67108864ULL
	curses.A_BOLD = 268435456ULL
	curses.A_DIM = 2147483648ULL
	curses.A_STANDOUT = bit.bor(curses.A_REVERSE, curses.A_BOLD)
	
	function curses.COLOR_PAIR(x)
		return bit.band(bit.lshift(ffi.cast("chtype", x), 33), 18446744065119617024ULL)
	end
else	
	curses.COLOR_BLACK = 0
	curses.COLOR_RED = 1
	curses.COLOR_GREEN = 2
	curses.COLOR_YELLOW = 3
	curses.COLOR_BLUE = 4
	curses.COLOR_MAGENTA = 5
	curses.COLOR_CYAN = 6
	curses.COLOR_WHITE = 7
	
	curses.A_DIM = 2 ^ 12
	curses.A_BOLD = 2 ^ 13
	curses.A_STANDOUT = 2 ^ 8
end

setmetatable(curses, {__index = lib})

return curses
