local ffi = require("ffi")

local terminal = {}

ffi.cdef([[
    struct termios
    {
        unsigned int c_iflag;		/* input mode flags */
        unsigned int c_oflag;		/* output mode flags */
        unsigned int c_cflag;		/* control mode flags */
        unsigned int c_lflag;		/* local mode flags */
        unsigned char c_line;			/* line discipline */
        unsigned char c_cc[32];		/* control characters */
        unsigned int c_ispeed;		/* input speed */
        unsigned int c_ospeed;		/* output speed */
    };

    int tcgetattr(int __fd, struct termios *__termios_p);
    int tcsetattr(int __fd, int __optional_actions, const struct termios *__termios_p);

    typedef struct FILE FILE;
    size_t fwrite(const char *ptr, size_t size, size_t nmemb, FILE *stream);
    size_t fread( char * ptr, size_t size, size_t count, FILE * stream );
]])

local VMIN = 6
local VTIME = 5
local TCSANOW = 0

local function octal(s)
    return tonumber(s, 8)
end

local flags = {
	ISIG = octal("0000001"),
	ICANON = octal("0000002"),
	XCASE = octal("0000004"),
	ECHO = octal("0000010"),
	ECHOE = octal("0000020"),
	ECHOK = octal("0000040"),
	ECHONL = octal("0000100"),
	NOFLSH = octal("0000200"),
	TOSTOP = octal("0000400"),
	ECHOCTL = octal("0001000"),
	ECHOPRT = octal("0002000"),
	ECHOKE = octal("0004000"),
	FLUSHO = octal("0010000"),
	PENDIN = octal("0040000"),
	IEXTEN = octal("0100000"),
	EXTPROC = octal("0200000"),
}

local stdin = 0

local old_attributes

function terminal.Initialize()
    if not old_attributes then
        old_attributes = ffi.new("struct termios[1]")
        ffi.C.tcgetattr(stdin, old_attributes)
    end

    local attr = ffi.new("struct termios[1]")

    ffi.C.tcgetattr(stdin, attr)
	attr[0].c_lflag = bit.band(attr[0].c_lflag, bit.bnot(bit.bor(flags.ICANON, flags.ECHO, flags.ISIG, flags.ECHOE, flags.ECHOCTL, flags.ECHOKE, flags.ECHOK)))
    attr[0].c_cc[VMIN] = 0
    attr[0].c_cc[VTIME] = 0

	ffi.C.tcsetattr(stdin, TCSANOW, attr)

	terminal.EnableCaret(true)
end

function terminal.Shutdown()
    ffi.C.tcsetattr(stdin, TCSANOW, old_attributes)
    old_attributes = nil
end

function terminal.EnableCaret(b)

end

function terminal.Clear()
	os.execute("clear")
end

function terminal.Read()
	local out = ffi.new("char[512]")
    local len = ffi.C.fread(out, 1, ffi.sizeof(out), io.stdin)
    if len > 0 then
        return ffi.string(out, len)
    end
end

function terminal.Write(str)
	if terminal.writing then return end
	terminal.writing = true
	if terminal.OnWrite and terminal.OnWrite(str) ~= false then
		terminal.WriteNow(str)
	end
	terminal.writing = false
end

function terminal.WriteNow(str)
	ffi.C.fwrite(str, 1, #str, io.stdout)
end

function terminal.SetTitle(str)
    terminal.Write("\27]0;" .. str .. "\7")
end

function terminal.SetCaretPosition(x, y)
    x = math.max(math.floor(x), 0)
    y = math.max(math.floor(y), 0)
    terminal.Write("\27[" .. y .. ";" .. x .. "f")
end

local function process_input(str)
    if str == "" or str == "\n" or str == "\r" then
        table.insert(terminal.event_buffer, {"enter"})
    elseif str:byte() >= 32 and str:byte() < 127 then
        table.insert(terminal.event_buffer, {"string", str})
    elseif str:usub(1,2) == "\27[" then
        local seq = str:usub(3, str:ulen())

        if seq == "3~" then
            table.insert(terminal.event_buffer, {"delete"})
        elseif seq == "3;5~" then
            table.insert(terminal.event_buffer, {"ctrl_delete"})
        elseif seq == "D" then
            table.insert(terminal.event_buffer, {"left"})
        elseif seq == "C" then
            table.insert(terminal.event_buffer, {"right"})
        elseif seq == "A" then
            table.insert(terminal.event_buffer, {"up"})
        elseif seq == "B" then
            table.insert(terminal.event_buffer, {"down"})
        elseif seq == "H" then
            table.insert(terminal.event_buffer, {"home"})
        elseif seq == "F" then
            table.insert(terminal.event_buffer, {"end"})
        elseif seq == "1;5C" then
            table.insert(terminal.event_buffer, {"ctrl_right"})
        elseif seq == "1;5D" then
            table.insert(terminal.event_buffer, {"ctrl_left"})
        else
            --print("ansi escape sequence: " .. seq)
        end
    else
        if #str == 1 then
            local byte = str:byte()
            if byte == 3 then -- ctrl c
                table.insert(terminal.event_buffer, {"ctrl_c"})
            elseif byte == 127 then -- backspace
                table.insert(terminal.event_buffer, {"backspace"})
            elseif byte == 23 or byte == 8 then -- ctrl backspace
                table.insert(terminal.event_buffer, {"ctrl_backspace"})
            elseif byte == 22 then
                table.insert(terminal.event_buffer, {"ctrl_v"})
            else
                --print("byte: " .. byte)
            end
        elseif str:byte() < 127 then
            if str == "\27\68" then -- ctrl delete
                table.insert(terminal.event_buffer, {"ctrl_delete"})
            else
                for _, char in ipairs(str:utotable()) do
                    process_input(char)
                end
                --print("char sequence: " .. table.concat({str:byte(1, str:ulen())}, ", ") .. " (" .. str:ulen() .. ")")
            end
        else -- unicode ?
            table.insert(terminal.event_buffer, {"string", str})
        end
    end
end

local function read_coordinates()
	local t = os.clock() + 1
	while true do
		if t < os.clock() then logn("timeout") return end

		local str = terminal.Read()

		if str then
            local a,b = str:match("^\27%[(%d+);(%d+)R$")
            if a then
                return tonumber(a), tonumber(b)
            else
                process_input(str)
            end
            return
        end
    end
end

do
    local _x, _y = 0, 0

    function terminal.GetCaretPosition()
		terminal.WriteNow("\x1b[6n")

        local y,x = read_coordinates()

        if y then
            _x, _y = x, y
        end

        return _x, _y
    end
end

do
    local _w, _h = 0, 0

    function terminal.GetSize()
        terminal.WriteNow("\27[s\27[999;999f\x1b[6n\27[u")

        local h,w = read_coordinates()

        if h then
            _w, _h = w, h
        end

        return _w,_h
    end
end

function terminal.WriteStringToScreen(x, y, str)
	terminal.Write("\27[s\27[" .. y .. ";" .. x .. "f" .. str .. "\27[u")
end

function terminal.ForegroundColor(r,g,b)
    r = math.floor(r * 255)
    g = math.floor(g * 255)
    b = math.floor(b * 255)
    terminal.Write("\27[38;2;" .. r .. ";" .. g .. ";" .. b .. "m")
end

function terminal.BackgroundColor(r,g,b)
    r = math.floor(r * 255)
    g = math.floor(g * 255)
    b = math.floor(b * 255)
    terminal.Write("\27[48;2;" .. r .. ";" .. g .. ";" .. b .. "m")
end

function terminal.ResetColor()
    terminal.Write("\27[0m")
end

terminal.event_buffer = {}

function terminal.ReadEvent()
    local str = terminal.Read()

    if str then
        process_input(str)
	end

    if terminal.event_buffer[1] then
        return unpack(table.remove(terminal.event_buffer))
    end
end

return terminal