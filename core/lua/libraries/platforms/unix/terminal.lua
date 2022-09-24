local ffi = require("ffi")
local terminal = {}

if jit.os ~= "OSX" then
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
    ]])
else
	ffi.cdef([[
        struct termios
        {
            unsigned long c_iflag;		/* input mode flags */
            unsigned long c_oflag;		/* output mode flags */
            unsigned long c_cflag;		/* control mode flags */
            unsigned long c_lflag;		/* local mode flags */
            unsigned char c_cc[20];		/* control characters */
            unsigned long c_ispeed;		/* input speed */
            unsigned long c_ospeed;		/* output speed */
        };
    ]])
end

ffi.cdef([[
    int tcgetattr(int, struct termios *);
    int tcsetattr(int, int, const struct termios *);

    typedef struct FILE FILE;
    size_t fwrite(const char *ptr, size_t size, size_t nmemb, FILE *stream);
    size_t fread( char * ptr, size_t size, size_t count, FILE * stream );

    ssize_t read(int fd, void *buf, size_t count);
    int fileno(FILE *stream);

    int ferror(FILE*stream);
]])
local VMIN = 6
local VTIME = 5
local TCSANOW = 0
local flags

if jit.os ~= "OSX" then
	flags = {
		ECHOCTL = 512,
		EXTPROC = 65536,
		ECHOK = 32,
		NOFLSH = 128,
		FLUSHO = 4096,
		ECHONL = 64,
		ECHOE = 16,
		ECHOKE = 2048,
		ECHO = 8,
		ICANON = 2,
		IEXTEN = 32768,
		PENDIN = 16384,
		XCASE = 4,
		ECHOPRT = 1024,
		TOSTOP = 256,
		ISIG = 1,
	}
else
	VMIN = 16
	VTIME = 17
	flags = {
		ECHOKE = 0x00000001,
		ECHOE = 0x00000002,
		ECHOK = 0x00000004,
		ECHO = 0x00000008,
		ECHONL = 0x00000010,
		ECHOPRT = 0x00000020,
		ECHOCTL = 0x00000040,
		ISIG = 0x00000080,
		ICANON = 0x00000100,
		ALTWERASE = 0x00000200,
		IEXTEN = 0x00000400,
		EXTPROC = 0x00000800,
		TOSTOP = 0x00400000,
		FLUSHO = 0x00800000,
		NOKERNINFO = 0x02000000,
		PENDIN = 0x20000000,
		NOFLSH = 0x80000000,
	}
end

local stdin = 0
local old_attributes

function terminal.Initialize()
	io.stdin:setvbuf("no")
	io.stdout:setvbuf("no")

	if not old_attributes then
		old_attributes = ffi.new("struct termios[1]")
		ffi.C.tcgetattr(stdin, old_attributes)
	end

	local attr = ffi.new("struct termios[1]")

	if ffi.C.tcgetattr(stdin, attr) ~= 0 then error(ffi.strerror(), 2) end

	attr[0].c_lflag = bit.band(
		tonumber(attr[0].c_lflag),
		bit.bnot(
			bit.bor(
				flags.ICANON,
				flags.ECHO,
				flags.ISIG,
				flags.ECHOE,
				flags.ECHOCTL,
				flags.ECHOKE,
				flags.ECHOK
			)
		)
	)
	attr[0].c_cc[VMIN] = 0
	attr[0].c_cc[VTIME] = 0

	if ffi.C.tcsetattr(stdin, TCSANOW, attr) ~= 0 then error(ffi.strerror(), 2) end

	if ffi.C.tcgetattr(stdin, attr) ~= 0 then error(ffi.strerror(), 2) end

	if attr[0].c_cc[VMIN] ~= 0 or attr[0].c_cc[VTIME] ~= 0 then
		terminal.Shutdown()
		error("unable to make stdin non blocking", 2)
	end

	terminal.EnableCaret(true)
end

function terminal.Shutdown()
	if old_attributes then
		ffi.C.tcsetattr(stdin, TCSANOW, old_attributes)
		old_attributes = nil
	end
end

function terminal.EnableCaret(b) end

function terminal.Clear()
	os.execute("clear")
end

do
	local buff = ffi.new("char[512]")
	local buff_size = ffi.sizeof(buff)

	function terminal.Read()
		do
			return io.read()
		end

		local len = ffi.C.read(stdin, buff, buff_size)

		if len > 0 then return ffi.string(buff, len) end
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
	--terminal.Write("\27[s\27[0;0f" .. str .. "\27[u")
	io.write(str, "\n")
end

function terminal.SetCaretPosition(x, y)
	x = math.max(math.floor(x), 0)
	y = math.max(math.floor(y), 0)
	terminal.Write("\27[" .. y .. ";" .. x .. "f")
end

local function add_event(...)
	list.insert(terminal.event_buffer, {...})
end

local function process_input(str)
	if str == "" then
		add_event("enter")
		return
	end

	local buf = utility.CreateBuffer(str)
	buf:SetPosition(0)

	while true do
		local c = buf:ReadChar()

		if not c then break end

		if c:byte() < 32 then
			if c == "\27" then
				local c = buf:ReadChar()

				if c == "[" then
					local c = buf:ReadChar()

					if c == "D" then
						add_event("left")
					elseif c == "1" then
						local c = buf:ReadString(3)

						if c == ";5D" then
							add_event("ctrl_left")
						elseif c == ";5C" then
							add_event("ctrl_right")
						elseif c == ";5F" then
							add_event("home")
						elseif c == ";5H" then
							add_event("end")
						end
					elseif c == "C" then
						add_event("right")
					elseif c == "A" then
						add_event("up")
					elseif c == "B" then
						add_event("down")
					elseif c == "H" then
						add_event("home")
					elseif c == "F" then
						add_event("end")
					elseif c == "3" then
						add_event("delete")
						local c = buf:ReadChar()

						if c == ";" then
							-- prevents alt and meta delete key from spilling ;9 and ;3
							buf:Advance(2)
						elseif c ~= "~" then
							-- spill all other keys except ~
							buf:Advance(-1)
						end
					elseif c == "2" then
						add_event("backspace")
					else
						wlog("unhandled control character %q", c)
					end
				elseif c == "b" then
					add_event("ctrl_left")
				elseif c == "f" then
					add_event("ctrl_right")
				elseif c == "d" then
					add_event("ctrl_delete")
				else
					wlog("unhandled control character %q", c)
				end
			elseif c == "\r" or c == "\n" then
				add_event("enter")
			elseif c == "\3" then
				add_event("ctrl_c")
			elseif c == "\23" or c == "\8" then -- ctrl backspace
				add_event("ctrl_backspace")
			elseif c == "\22" then
				add_event("ctrl_v")
			elseif c == "\1" then
				add_event("home")
			elseif c == "\5" then
				add_event("end")
			elseif c == "\21" then
				add_event("ctrl_backspace")
			else
				wlog("unhandled control character %q", c)
			end
		elseif c == "\127" then
			add_event("backspace")
		elseif utf8.byte_length(c) then
			buf:Advance(-1)
			add_event("string", buf:ReadString(utf8.byte_length(c)))
		end

		if buf:GetPosition() >= buf:GetSize() then break end
	end
end

local function read_coordinates()
	while true do
		local str = terminal.Read()

		if str then
			local a, b = str:match("^\27%[(%d+);(%d+)R$")

			if a then return tonumber(a), tonumber(b) end
		end
	end
end

do
	local _x, _y = 0, 0

	function terminal.GetCaretPosition()
		terminal.WriteNow("\x1b[6n")
		local y, x = read_coordinates()

		if y then _x, _y = x, y end

		return _x, _y
	end
end

do
	local STDOUT_FILENO = 1
	ffi.cdef([[
        struct terminal_winsize
        {
            unsigned short int ws_row;
            unsigned short int ws_col;
            unsigned short int ws_xpixel;
            unsigned short int ws_ypixel;
        };
    
        int ioctl(int fd, unsigned long int req, ...);    
    ]])
	local TIOCGWINSZ = 0x5413

	if jit.os == "OSX" then TIOCGWINSZ = 0x40087468 end

	local size = ffi.new("struct terminal_winsize[1]")

	function terminal.GetSize()
		ffi.C.ioctl(STDOUT_FILENO, TIOCGWINSZ, size)
		return size[0].ws_col, size[0].ws_row
	end
end

function terminal.WriteStringToScreen(x, y, str)
	terminal.Write("\27[s\27[" .. y .. ";" .. x .. "f" .. str .. "\27[u")
end

function terminal.ForegroundColor(r, g, b)
	r = math.floor(r * 255)
	g = math.floor(g * 255)
	b = math.floor(b * 255)
	terminal.Write("\27[38;2;" .. r .. ";" .. g .. ";" .. b .. "m")
end

function terminal.ForegroundColorFast(r, g, b)
	terminal.Write(string.format("\27[38;2;%i;%i;%im", r, g, b))
end

function terminal.BackgroundColor(r, g, b)
	r = math.floor(r * 255)
	g = math.floor(g * 255)
	b = math.floor(b * 255)
	terminal.Write("\27[48;2;" .. r .. ";" .. g .. ";" .. b .. "m")
end

function terminal.ResetColor()
	terminal.Write("\27[0m")
end

terminal.event_buffer = {}

function terminal.ReadEvents()
	local str = terminal.Read()

	if str then process_input(str) end

	return terminal.event_buffer
end

return terminal