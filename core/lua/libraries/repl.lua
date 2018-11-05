local repl = {}

repl.buffer = ""
repl.command_history = serializer.ReadFile("luadata", "data/cmd_history.txt") or {}
for k,v in ipairs(repl.command_history) do 
	if type(v) ~= "string" then 
		repl.command_history = {}
		break
	end
end
repl.scroll_command_history = repl.scroll_command_history or 0

function repl.SetConsoleTitle(str)
	llog("NYI: repl.SetConsoleTitle(str)")
end

function repl.SetCaretPosition(x, y)
	llog("NYI: repl.SetCaretPosition(x, y)")
end

function repl.GetCaretPosition()
	llog("NYI: repl.GetCaretPosition()")
	return 0, 0
end

function repl.MoveCaret(ox, oy)
	local x, y = repl.GetCaretPosition()
	repl.SetCaretPosition(x + ox, y + oy)
end

function repl.WriteStringToScreen(x,y, str)
	llog("NYI: repl.WriteString(x,y, str)")
end

function repl.GetConsoleSize()
	llog("NYI: repl.GetConsoleSize()")
	return 0, 0
end

function repl.Update()
	llog("NYI: repl.Update()")
end

function repl.RenderInput()
	local w, h = repl.GetConsoleSize()
	local x,y = repl.GetCaretPosition()
	repl.SetCaretPosition(0,y)
	repl.Print(repl.buffer)
	repl.WriteStringToScreen(repl.buffer:ulen() + 1, y, (" "):rep(w))
	repl.SetCaretPosition(x,y)
	--repl.WriteStringToScreen(0, h, repl.buffer)
end

function repl.CharInput(str)
	local x, y = repl.GetCaretPosition()
	repl.buffer = repl.buffer:usub(0, x - 1) .. str .. repl.buffer:usub(x + str:ulen() - 1, -1)
	repl.MoveCaret(str:ulen(), 0)
	repl.RenderInput()
end

function repl.GetCaretDecoration()
	return "> "
end

function repl.SetForegroundColor(r,g,b)

end

function repl.SetBackgroundColor(r,g,b)

end

local set_color

do
	do
		local suppress_print = false

		function repl.CanPrint(str)
			if suppress_print then return end

			if event then
				suppress_print = true

				if event.Call("ReplPrint", str) == false then
					suppress_print = false
					return false
				end

				suppress_print = false
			end

			return true
		end
	end

	local tokenize = require("lua_tokenizer")

	local keywords = {
		"and", "break", "do", "else", "elseif", "end",
		"false", "for", "function", "if", "in", "local",
		"nil", "not", "or", "repeat", "return", "then",
		"true", "until", "while", "goto", "...",
	}
	local temp = {}
	for k,v in ipairs(keywords) do 
		temp[v] = true 
	end 
	keywords = temp

	local colors = {
		comment = "#8e908c",
		number = "#4453da",
		letter = "#d6d7d8",
		symbol = "#da4453",
		error = "#da4453",
		keyword = "#2980b9",
		string = "#27ae60",
	}

	for key, hex in pairs(colors) do
		local r,g,b = hex:match("#?(..)(..)(..)")
		r = tonumber("0x" .. r)
		g = tonumber("0x" .. g)
		b = tonumber("0x" .. b)
		colors[key] = {r/255,g/255,b/255}
	end
	
	set_color = function(what)
		repl.SetForegroundColor(unpack(colors[what]))
	end

	function repl.Print(str)
		str:replace("\t", "    ")

		local start = 0
		local tokens = tokenize({code = str, path = ""}):GetTokens()

		LAST_TOKENS = tokens
		
		for i, v in ipairs(tokens) do

			for i,v in ipairs(v.whitespace) do
				if v.type == "line_comment" or v.type == "multiline_comment" then
					set_color("comment")
				else
					set_color("letter")
				end

				io.write(str:usub(v.start, v.stop))
			end

			if v.type == "symbol" then
				set_color("symbol")
			elseif v.type == "number" then
				set_color("number")
			elseif v.type == "string" then
				set_color("string")
			elseif v.type == "letter" then
				if keywords[v.value] then
					set_color("keyword")
				else
					set_color("letter")
				end
			else
				set_color("letter")
			end
			io.write(str:usub(v.start, v.stop))
		end

		set_color("letter")
	end
end

local function find_next_word(buffer, x, dir)
    local str = dir == "left" and buffer:usub(0, x-1):reverse() or buffer:usub(x+1, -1)

    if str:find("^%s", 0) then
        return str:find("%S")
    elseif str:find("^%p", 0) then
        return str:find("%P", 0) or str:find("^%p+$", 0)
    end
    
    return str:find("%s", 0) or str:find("%p", 0) or str:ulen() + 1
end

function repl.KeyPressed(key)
	local x, y = repl.GetCaretPosition()
	local w, h = repl.GetConsoleSize()

	if key == "enter" then
		repl.SetCaretPosition(0, y)
		repl.Print("> " .. repl.buffer)
		repl.SetCaretPosition(x, y)
		io.write("\n") -- create a new line
		
		if repl.buffer == "clear" then
			os.execute("clear")
		elseif repl.buffer:startswith("exit") then
			system.ShutDown(tonumber(repl.buffer:match("exit (%d+)")) or 0)
		else
			if commands and commands.RunString then
				commands.RunString(repl.buffer)
			else
				local func, err = loadstring(repl.buffer)
				if func then
					local func, res = pcall(func)
					if not func then
						set_color("error")
						io.write(res, "\n")
						set_color("letter")
					end
				else
					set_color("error")
					io.write(err, "\n") 
					set_color("letter")
				end
			end
		end

		x, y = repl.GetCaretPosition()
		y = y - 1

		-- write the buffer
		
		for i, str in ipairs(repl.command_history) do
			if str == buffer then
				table.remove(repl.command_history, i)
			end
		end

		table.insert(repl.command_history, repl.buffer)
		serializer.WriteFile("luadata", "data/cmd_history.txt", repl.command_history)
		repl.scroll_command_history = 0

		repl.buffer = ""
		repl.SetCaretPosition(0, y + 1)
	elseif key == "delete" then
		repl.buffer = repl.buffer:usub(0, x-1) .. repl.buffer:usub(x+1, -1)
	elseif key == "up" or key == "down" then
		if key == "up" then
			repl.scroll_command_history = repl.scroll_command_history - 1
		else
			repl.scroll_command_history = repl.scroll_command_history + 1
		end
		local str = repl.command_history[repl.scroll_command_history%#repl.command_history+1]
		if str then
			repl.buffer = str
			repl.SetCaretPosition(repl.buffer:ulen() + 1, y)
		end
	elseif key == "left" then
		repl.MoveCaret(-1, 0)
	elseif key == "right" then
		repl.MoveCaret(1, 0)
	elseif key == "home" then
		repl.SetCaretPosition(1, y)
	elseif key == "end" then
		repl.SetCaretPosition(repl.buffer:ulen() + 1, y)
	elseif key == "ctrl_right" then
		local offset = find_next_word(repl.buffer, x, "right")
		if offset then
			repl.MoveCaret(offset + 1, 0)
		end
	elseif key == "ctrl_left" then
		local offset = find_next_word(repl.buffer, x, "left")
                
		if offset then
			repl.MoveCaret(-offset + 1, 0)
		end
	elseif key == "backspace" then
		repl.buffer = repl.buffer:usub(0, math.max(x - 2, 0)) .. repl.buffer:usub(x, -1)
		repl.MoveCaret(-1, 0)
	elseif key == "ctrl_backspace" then
		local offset = find_next_word(repl.buffer, x, "left")
		if offset then
			repl.buffer = repl.buffer:usub(0, x - offset) .. repl.buffer:usub(x, -1)
			repl.SetCaretPosition(x - offset + 1, y)
		end
	elseif key == "ctrl_delete" then
		local offset = find_next_word(repl.buffer, x, "right")

		if offset then
			repl.buffer = repl.buffer:usub(0, x - 1) .. repl.buffer:usub(x + offset, -1)
		end
	elseif key ~= "ctrl_c" then
		llog("unhandled key %s", key)
	end

	if key == "ctrl_c" then
		repl.SetCaretPosition(0, y)
		io.write(repl.buffer, "\n")
		repl.buffer = ""
		repl.SetCaretPosition(0, y)
		repl.RenderInput()
		repl.SetCaretPosition(0, y)

		if repl.ctrl_c_exit then
			if repl.ctrl_c_exit > system.GetTime() then
				system.ShutDown(0)
			else
				repl.ctrl_c_exit = nil
			end
		else
			repl.ctrl_c_exit = system.GetTime() + 0.5
			io.write("ctrl+c again to exit\n")
		end
	else
		repl.ctrl_c_exit = nil
	end

	local x, y = repl.GetCaretPosition()
	x = math.min(x, repl.buffer:ulen() + 1)
	repl.SetCaretPosition(x, y)

	repl.RenderInput()
	
	return true
end

local ffi = require("ffi")

if jit.os ~= "Windows" then
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
		
		int usleep(uint32_t);
	]])
	
	local ISIG = 0000001
	local ICANON = 0000002
	local ECHO = 0000010
	local VMIN = 6
	local VTIME = 5
	local TCSANOW = 0
	local stdin = 0

	local old_attributes
	
	function repl.Start()
		if not old_attributes then
			old_attributes = ffi.new("struct termios[1]")
			ffi.C.tcgetattr(stdin, old_attributes)
		end
		local attr = ffi.new("struct termios[1]")

		ffi.C.tcgetattr(stdin, attr)

		attr[0].c_lflag = bit.band(attr[0].c_lflag, bit.bnot(bit.bor(ICANON, ECHO, ISIG)))
		attr[0].c_cc[VMIN] = 0
		attr[0].c_cc[VTIME] = 0
		
		ffi.C.tcsetattr(stdin, TCSANOW, attr)
	end

	function repl.Stop()
		ffi.C.tcsetattr(stdin, TCSANOW, old_attributes)
		old_attributes = nil
	end

	function repl.SetConsoleTitle(str)
		io.write("\27]0;", str, "\7")
	end
	
	function repl.GetCaretPosition()
		io.write("\x1b[6n")
	
		local x,y = 0, 0
	
		while true do
			local str = io.read()
			if str and str:usub(1, 2) == "\27[" then
				y,x = str:match("\27%[(%d+);(%d+)R")
				break
			end
		end
	
		return tonumber(x) or 0, tonumber(y) or 0
	end
	
	function repl.SetCaretPosition(x, y)
		io.write("\27[",y,";",x,"f")
	end
	
	local function push_caret()
		io.write("\27[s")
	end
	
	local function pop_caret()
		io.write("\27[u")
	end
	
	function repl.GetConsoleSize()
		push_caret()
		repl.SetCaretPosition(99999999,99999999)
		local w,h = repl.GetCaretPosition()
		pop_caret()
		return w,h
	end
	
	function repl.WriteStringToScreen(x, y, str)
		io.write("\27[s ", "\27[", y, ";", x, "H", "\27[K", str, "\27[u")
	end
	
	function repl.SetForegroundColor(r,g,b)
		r = math.floor(r * 255)
		g = math.floor(g * 255)
		b = math.floor(b * 255)
		io.write("\27[38;2;", r, ";", g, ";", b, "m")
	end
	
	function repl.SetBackgroundColor(r,g,b)
		r = math.floor(r * 255)
		g = math.floor(g * 255)
		b = math.floor(b * 255)
		io.write("\27[48;2;", r, ";", g, ";", b, "m")
	end
	
	function repl.Update()	
		local str = io.read()
		
		if str then
			if str == "" or str == "\n" or str == "\r" then -- newline/enter?
				repl.KeyPressed("enter")
			elseif str:byte() >= 32 and str:byte() < 127 then -- asci chars
				repl.CharInput(str)
			elseif str:usub(1,2) == "\27[" then
				local seq = str:usub(3, str:ulen())
	
				if seq == "3~" then
					repl.KeyPressed("delete")
				elseif seq == "D" then
					repl.KeyPressed("left")
				elseif seq == "C" then
					repl.KeyPressed("right")
				elseif seq == "A" then
					repl.KeyPressed("up")
				elseif seq == "B" then
					repl.KeyPressed("down")
				elseif seq == "H" then
					repl.KeyPressed("home")
				elseif seq == "F" then
					repl.KeyPressed("end")
				elseif seq == "1;5C" then
					repl.KeyPressed("ctrl_right")
				elseif seq == "1;5D" then
					repl.KeyPressed("ctrl_left")
				else
					print("ansi escape sequence: " .. seq)
				end
			else
				if #str == 1 then
					local byte = str:byte()
					if byte == 3 then -- ctrl c
						repl.KeyPressed("ctrl_c")
						return false
					elseif byte == 127 then -- backspace
						repl.KeyPressed("backspace")
					elseif byte == 23 then -- ctrl backspace
						repl.KeyPressed("ctrl_backspace")
					else
						print("byte: " .. byte)
					end
				elseif str:byte() < 127 then
					if str == "\27\68" then -- ctrl delete
						repl.KeyPressed("ctrl_delete")
					else
						print("char sequence: " .. table.concat({str:byte(1, str:ulen())}, ", ") .. " (" .. str:ulen() .. ")")
					end
				else -- unicode ?
					repl.CharInput(str)
				end
			end
		end
	
		return true
	end	
else
	local STD_INPUT_HANDLE = -10
	local STD_OUTPUT_HANDLE = -11
	local ENABLE_VIRTUAL_TERMINAL_INPUT = 0x0200
	local DISABLE_NEWLINE_AUTO_RETURN = 0x0008
	local ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004

	ffi.cdef([[
		struct COORD {
			short X;
			short Y;
			};

			struct KEY_EVENT_RECORD {
			int  bKeyDown;
			unsigned short  wRepeatCount;
			unsigned short  wVirtualKeyCode;
			unsigned short  wVirtualScanCode;
			union {
				wchar_t UnicodeChar;
				char  AsciiChar;
			} uChar;
			unsigned long dwControlKeyState;
			};
			
			struct MOUSE_EVENT_RECORD {
			struct COORD dwMousePosition;
			unsigned long dwButtonState;
			unsigned long dwControlKeyState;
			unsigned long dwEventFlags;
			};

			struct WINDOW_BUFFER_SIZE_RECORD {
			struct COORD dwSize;
			};

			struct MENU_EVENT_RECORD {
			unsigned int dwCommandId;
			};

			struct FOCUS_EVENT_RECORD {
			int bSetFocus;
			};

			struct INPUT_RECORD {
			unsigned short  EventType;
			union {
				struct KEY_EVENT_RECORD KeyEvent;
				struct MOUSE_EVENT_RECORD MouseEvent;
				struct WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
				struct MENU_EVENT_RECORD MenuEvent;
				struct FOCUS_EVENT_RECORD FocusEvent;
			} Event;
			};

		
			int PeekConsoleInputA(
				void* hConsoleInput,
				struct INPUT_RECORD* lpBuffer,
				unsigned long nLength,
				unsigned long * lpNumberOfEventsRead
			);
			
			int ReadConsoleInputA(
				void* hConsoleInput,
				struct INPUT_RECORD* lpBuffer,
				unsigned long nLength,
				unsigned long * lpNumberOfEventsRead
			);

			struct SMALL_RECT {
				uint16_t Left;
				uint16_t Top;
				uint16_t Right;
				uint16_t Bottom;
			  };
			  

			struct CONSOLE_SCREEN_BUFFER_INFO {
				struct COORD      dwSize;
				struct COORD      dwCursorPosition;
				uint16_t       wAttributes;
				struct SMALL_RECT srWindow;
				struct COORD      dwMaximumWindowSize;
			};
			
			int GetConsoleScreenBufferInfo(
				void* hConsoleOutput,
				struct CONSOLE_SCREEN_BUFFER_INFO* lpConsoleScreenBufferInfo
			);

			int SetConsoleCursorPosition(
  				void* hConsoleOutput,
  				struct COORD  dwCursorPosition
			);

		int SetConsoleMode(void*, uint16_t);
		int GetConsoleMode(void*, uint16_t*);
		void* GetStdHandle(unsigned long nStdHandle);
		int SetConsoleTitleA(const char*);

		int _getch_nolock();
		unsigned short _getwch_nolock();
		int _kbhit();
	
		uint32_t GetLastError();
		uint32_t FormatMessageA(
			uint32_t dwFlags,
			const void* lpSource,
			uint32_t dwMessageId,
			uint32_t dwLanguageId,
			char* lpBuffer,
			uint32_t nSize,
			va_list *Arguments
		);

		int PeekNamedPipe(
			void*  hNamedPipe,
			void*  lpBuffer,
			unsigned long   nBufferSize,
			unsigned long* lpBytesRead,
			unsigned long* lpTotalBytesAvail,
			unsigned long* lpBytesLeftThisMessage
		);

		int WideCharToMultiByte(
			unsigned int CodePage,
			unsigned long dwFlags,
			const wchar_t* lpWideCharStr,
			int cchWideChar,
			char * lpMultiByteStr,
			int cbMultiByte,
			char* lpDefaultChar,
			int* lpUsedDefaultChar
);

unsigned long WaitForSingleObject(
void* hHandle,
  unsigned long  dwMilliseconds
);

int ReadConsoleA(
				void*  hConsoleInput,
				void*  lpBuffer,
				unsigned long nNumberOfCharsToRead,
				unsigned long* lpNumberOfCharsRead,
				void*  pInputControl
			);
	]])

	local error_str = ffi.new("uint8_t[?]", 1024)
	local ENABLE_ECHO_INPUT = 0x0004;
	local FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
	local ENABLE_WINDOW_INPUT = 0x0008;
	local FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200;
	local ENABLE_INSERT_MODE = 0x0020;
	local error_flags = bit.bor(FORMAT_MESSAGE_FROM_SYSTEM, FORMAT_MESSAGE_IGNORE_INSERTS)
	local function throw_error()
		local code = ffi.C.GetLastError()
		local numout = ffi.C.FormatMessageA(error_flags, nil, code, 0, error_str, 1023, nil)
		local err = numout ~= 0 and ffi.string(error_str, numout)
		if err and err:sub(-2) == "\r\n" then
			return err:sub(0, -3)
		end
		return err
	end

	local old_flags = {}
	
	local function add_flags(handle, ...)
		local ptr = ffi.C.GetStdHandle(handle)
		if ptr == nil then throw_error() end

		local flags = ffi.new("uint16_t[1]")
		if ffi.C.GetConsoleMode(ptr, flags) == 0 then
			throw_error()
		end

		old_flags[handle] = flags[0]

		flags[0] = bit.bor(flags[0], ...)

		if ffi.C.SetConsoleMode(ptr, flags[0]) == 0 then
			throw_error()
		end
	end

	local function revert_flags(handle)
		local ptr = ffi.C.GetStdHandle(handle)
		if ptr == nil then throw_error() end

		if ffi.C.SetConsoleMode(ptr, old_flags[handle]) == 0 then
			throw_error()
		end
	end

	function repl.Start()
		add_flags(STD_INPUT_HANDLE, ENABLE_VIRTUAL_TERMINAL_INPUT, ENABLE_WINDOW_INPUT, ENABLE_INSERT_MODE, ENABLE_ECHO_INPUT)
		add_flags(STD_OUTPUT_HANDLE, ENABLE_VIRTUAL_TERMINAL_PROCESSING, DISABLE_NEWLINE_AUTO_RETURN)
	end
	
	function repl.Stop()
		revert_flags(STD_INPUT_HANDLE)
		revert_flags(STD_OUTPUT_HANDLE)
	end

	local stdin = ffi.C.GetStdHandle(STD_INPUT_HANDLE)
	local stdout = ffi.C.GetStdHandle(STD_OUTPUT_HANDLE)
 
	local function read()
		local events = ffi.new("unsigned long[1]")
		local rec = ffi.new("struct INPUT_RECORD[128]")

		if ffi.C.PeekConsoleInputA(stdin, rec, 128, events) == 0 then
			error(throw_error())
		end
		if events[0] > 0 then
			local rec = ffi.new("struct INPUT_RECORD[?]", events[0])
			if ffi.C.ReadConsoleInputA(stdin, rec, events[0], events) == 0 then
				error(throw_error())
			end
			
			return rec[0]
		end
	end
	
	function repl.GetCaretPosition()
		local out = ffi.new("struct CONSOLE_SCREEN_BUFFER_INFO[1]")
		ffi.C.GetConsoleScreenBufferInfo(stdout, out)
		return out[0].dwCursorPosition.X, out[0].dwCursorPosition.Y
	end

	function repl.SetCaretPosition(x, y)
		local w,h = repl.GetConsoleSize()
		x = math.clamp(x-1, 0, w)
		y = math.clamp(y-1, 0, h)
		ffi.C.SetConsoleCursorPosition(stdout, ffi.new("struct COORD", {X = x, Y = y}))
	end

	function repl.SetConsoleTitle(str)
		ffi.C.SetConsoleTitleA(str)
	end

	function repl.GetConsoleSize()
		local out = ffi.new("struct CONSOLE_SCREEN_BUFFER_INFO[1]")
		ffi.C.GetConsoleScreenBufferInfo(stdout, out)
		return out[0].dwSize.X, out[0].dwSize.Y
	end
	
	function repl.WriteStringToScreen(x, y, str)
		local x_,y_ = repl.GetCaretPosition()

		repl.SetCaretPosition(x,y)
		io.write(str)

		repl.SetCaretPosition(x_,y_)
	end
	
	function repl.SetForegroundColor(r,g,b)
		r = math.floor(r * 255)
		g = math.floor(g * 255)
		b = math.floor(b * 255)
		io.write("\27[38;2;", r, ";", g, ";", b, "m")
	end
	
	function repl.SetBackgroundColor(r,g,b)
		r = math.floor(r * 255)
		g = math.floor(g * 255)
		b = math.floor(b * 255)
		io.write("\27[48;2;", r, ";", g, ";", b, "m")
	end

	local keys = {
		MOD_ALT   =  0x0001,
		MOD_CONTROL =  0x0002,
		MOD_SHIFT     =  0x0004,
		MOD_WIN       =  0x0008,
		MOD_NOREPEAT  =  0x4000,
	
		VK_LBUTTON = 0x01,
		VK_RBUTTON = 0x02,
		VK_CANCEL = 0x03,
		VK_MBUTTON = 0x04,
		VK_XBUTTON1 = 0x05,
		VK_XBUTTON2 = 0x06,
		VK_BACK = 0x08,
		VK_TAB = 0x09,
		VK_CLEAR = 0x0C,
		VK_RETURN = 0x0D,
		VK_SHIFT = 0x10,
		VK_CONTROL = 0x11,
		VK_MENU = 0x12,
		VK_PAUSE = 0x13,
		VK_CAPITAL = 0x14,
		VK_KANA = 0x15,
		VK_JUNJA = 0x17,
		VK_FINAL = 0x18,
		VK_KANJI = 0x19,
		VK_ESCAPE = 0x1B,
		VK_CONVERT = 0x1C,
		VK_NONCONVERT = 0x1D,
		VK_ACCEPT = 0x1E,
		VK_MODECHANGE = 0x1F,
		VK_SPACE = 0x20,
		VK_PRIOR = 0x21,
		VK_NEXT = 0x22,
		VK_END = 0x23,
		VK_HOME = 0x24,
		VK_LEFT = 0x25,
		VK_UP = 0x26,
		VK_RIGHT = 0x27,
		VK_DOWN = 0x28,
		VK_SELECT = 0x29,
		VK_PRINT = 0x2A,
		VK_EXECUTE = 0x2B,
		VK_SNAPSHOT = 0x2C,
		VK_INSERT = 0x2D,
		VK_DELETE = 0x2E,
		VK_HELP = 0x2F,
		VK_LWIN = 0x5B,
		VK_RWIN = 0x5C,
		VK_APPS = 0x5D,
		VK_SLEEP = 0x5F,
		VK_NUMPAD0 = 0x60,
		VK_NUMPAD1 = 0x61,
		VK_NUMPAD2 = 0x62,
		VK_NUMPAD3 = 0x63,
		VK_NUMPAD4 = 0x64,
		VK_NUMPAD5 = 0x65,
		VK_NUMPAD6 = 0x66,
		VK_NUMPAD7 = 0x67,
		VK_NUMPAD8 = 0x68,
		VK_NUMPAD9 = 0x69,
		VK_MULTIPLY = 0x6A,
		VK_ADD = 0x6B,
		VK_SEPARATOR = 0x6C,
		VK_SUBTRACT = 0x6D,
		VK_DECIMAL = 0x6E,
		VK_DIVIDE = 0x6F,
		VK_F1 = 0x70,
		VK_F2 = 0x71,
		VK_F3 = 0x72,
		VK_F4 = 0x73,
		VK_F5 = 0x74,
		VK_F6 = 0x75,
		VK_F7 = 0x76,
		VK_F8 = 0x77,
		VK_F9 = 0x78,
		VK_F10 = 0x79,
		VK_F11 = 0x7A,
		VK_F12 = 0x7B,
		VK_F13 = 0x7C,
		VK_F14 = 0x7D,
		VK_F15 = 0x7E,
		VK_F16 = 0x7F,
		VK_F17 = 0x80,
		VK_F18 = 0x81,
		VK_F19 = 0x82,
		VK_F20 = 0x83,
		VK_F21 = 0x84,
		VK_F22 = 0x85,
		VK_F23 = 0x86,
		VK_F24 = 0x87,
		VK_NUMLOCK = 0x90,
		VK_SCROLL = 0x91,
		VK_OEM_NEC_EQUAL = 0x92,
		VK_LSHIFT = 0xA0,
		VK_RSHIFT = 0xA1,
		VK_LCONTROL = 0xA2,
		VK_RCONTROL = 0xA3,
		VK_LMENU = 0xA4,
		VK_RMENU = 0xA5,
		VK_BROWSER_BACK = 0xA6,
		VK_BROWSER_FORWARD = 0xA7,
		VK_BROWSER_REFRESH = 0xA8,
		VK_BROWSER_STOP = 0xA9,
		VK_BROWSER_SEARCH = 0xAA,
		VK_BROWSER_FAVORITES = 0xAB,
		VK_BROWSER_HOME = 0xAC,
		VK_VOLUME_MUTE = 0xAD,
		VK_VOLUME_DOWN = 0xAE,
		VK_VOLUME_UP = 0xAF,
		VK_MEDIA_NEXT_TRACK = 0xB0,
		VK_MEDIA_PREV_TRACK = 0xB1,
		VK_MEDIA_STOP = 0xB2,
		VK_MEDIA_PLAY_PAUSE = 0xB3,
		VK_LAUNCH_MAIL = 0xB4,
		VK_LAUNCH_MEDIA_SELECT = 0xB5,
		VK_LAUNCH_APP1 = 0xB6,
		VK_LAUNCH_APP2 = 0xB7,
		VK_OEM_1 = 0xBA,
		VK_OEM_PLUS = 0xBB,
		VK_OEM_COMMA = 0xBC,
		VK_OEM_MINUS = 0xBD,
		VK_OEM_PERIOD = 0xBE,
		VK_OEM_2 = 0xBF,
		VK_OEM_3 = 0xC0,
		VK_OEM_4 = 0xDB,
		VK_OEM_5 = 0xDC,
		VK_OEM_6 = 0xDD,
		VK_OEM_7 = 0xDE,
		VK_OEM_8 = 0xDF,
		VK_OEM_AX = 0xE1,
		VK_OEM_102 = 0xE2,
		VK_ICO_HELP = 0xE3,
		VK_ICO_00 = 0xE4,
		VK_PROCESSKEY = 0xE5,
		VK_ICO_CLEAR = 0xE6,
		VK_PACKET = 0xE7,
		VK_OEM_RESET = 0xE9,
		VK_OEM_JUMP = 0xEA,
		VK_OEM_PA1 = 0xEB,
		VK_OEM_PA2 = 0xEC,
		VK_OEM_PA3 = 0xED,
		VK_OEM_WSCTRL = 0xEE,
		VK_OEM_CUSEL = 0xEF,
		VK_OEM_ATTN = 0xF0,
		VK_OEM_FINISH = 0xF1,
		VK_OEM_COPY = 0xF2,
		VK_OEM_AUTO = 0xF3,
		VK_OEM_ENLW = 0xF4,
		VK_OEM_BACKTAB = 0xF5,
		VK_ATTN = 0xF6,
		VK_CRSEL = 0xF7,
		VK_EXSEL = 0xF8,
		VK_EREOF = 0xF9,
		VK_PLAY = 0xFA,
		VK_ZOOM = 0xFB,
		VK_NONAME = 0xFC,
		VK_PA1 = 0xFD,
		VK_OEM_CLEAR = 0xFE,
	}
	
	function repl.Update()
		local evt = read()
		if evt then
			if evt.Event.KeyEvent.bKeyDown ~= 0 then return end
			local str = string.char(evt.Event.KeyEvent.uChar.AsciiChar)
			local key = evt.Event.KeyEvent.wVirtualKeyCode
			local CTRL = evt.Event.KeyEvent.dwControlKeyState == 264

			if key == keys.VK_RETURN then
				repl.KeyPressed("enter")
			elseif key == keys.VK_DELETE then
				repl.KeyPressed("delete")
			elseif key == keys.VK_LEFT then
				repl.KeyPressed("left")
			elseif key == keys.VK_RIGHT then
				repl.KeyPressed("right")
			elseif key == keys.VK_UP then
				repl.KeyPressed("up")
			elseif key == keys.VK_DOWN then
				repl.KeyPressed("down")
			elseif key == keys.VK_HOME then
				repl.KeyPressed("home")
			elseif key == keys.VK_END then
				repl.KeyPressed("end")
			elseif key == keys.VK_RIGHT and CTRL then
				repl.KeyPressed("ctrl_right")
			elseif key == keys.VK_LEFT and CTRL then
				repl.KeyPressed("ctrl_left")
			elseif key == keys.VK_BACK then
				repl.KeyPressed("backspace")
			elseif key == keys.VK_BACK and CTRL then
				repl.KeyPressed("ctrl_backspace")
			elseif key == keys.VK_DELETE and CTRL then
				repl.KeyPressed("ctrl_delete")
			elseif str == "C" and CTRL then
				repl.KeyPressed("ctrl_c")
				return false
			else
				repl.CharInput(str)
			end
		end
	
		return true
	end	
end

function repl.MainLoop()
	repl.Start()
	while system.run == true do
		--system.Sleep(0.1)
		local ok, err = system.pcall(repl.Update)
		if not ok then
			print(err)
			break
		end
	end
	repl.Stop()
end

return repl