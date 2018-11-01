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
	local _, h = repl.GetConsoleSize()
	local x = repl.GetCaretPosition()
	repl.SetCaretPosition(x, h)
	repl.WriteStringToScreen(0, h, repl.buffer)
end

function repl.CharInput(str)
	local x, y = repl.GetCaretPosition()
	repl.buffer = repl.buffer:sub(0, x - 1) .. str .. repl.buffer:sub(x + #str - 1, -1)
	repl.MoveCaret(#str, 0)
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
		
		for i, v in ipairs(tokens) do

			for i,v in ipairs(v.whitespace) do
				if v.type == "line_comment" or v.type == "multiline_comment" then
					set_color("comment")
				else
					set_color("letter")
				end

				io.write(str:sub(v.start, v.stop))
			end

			if v.type == "symbol" then
				set_color("symbol")
			elseif v.type == "number" then
				set_color("number")
			elseif v.type == "letter" then
				if keywords[v.value] then
					set_color("keyword")
				else
					set_color("letter")
				end
			else
				set_color("letter")
			end
			io.write(str:sub(v.start, v.stop))
		end

		set_color("letter")
	end
end

local function find_next_word(buffer, x, dir)
    local str = dir == "left" and buffer:sub(0, x-1):reverse() or buffer:sub(x+1, -1)

    if str:find("^%s", 0) then
        return str:find("%S")
    elseif str:find("^%p", 0) then
        return str:find("%P", 0) or str:find("^%p+$", 0)
    end
    
    return str:find("%s", 0) or str:find("%p", 0) or #str + 1
end

function repl.KeyPressed(key)
	local x, y = repl.GetCaretPosition()
	local w, h = repl.GetConsoleSize()
	
	if key == "enter" then
		repl.SetCaretPosition(0, y)
		io.write("> ", repl.buffer)
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
		repl.buffer = repl.buffer:sub(0, x-1) .. repl.buffer:sub(x+1, -1)
	elseif key == "up" or key == "down" then
		if key == "up" then
			repl.scroll_command_history = repl.scroll_command_history - 1
		else
			repl.scroll_command_history = repl.scroll_command_history + 1
		end
		local str = repl.command_history[repl.scroll_command_history%#repl.command_history+1]
		if str then
			repl.buffer = str
			repl.SetCaretPosition(#repl.buffer + 1, y)
		end
	elseif key == "left" then
		repl.MoveCaret(-1, 0)
	elseif key == "right" then
		repl.MoveCaret(1, 0)
	elseif key == "home" then
		repl.SetCaretPosition(1, y)
	elseif key == "end" then
		repl.SetCaretPosition(#repl.buffer + 1, y)
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
		repl.buffer = repl.buffer:sub(0, math.max(x - 1 - 1, 0)) .. repl.buffer:sub(x, -1)
		repl.MoveCaret(-1, 0)
	elseif key == "ctrl_backspace" then
		local offset = find_next_word(repl.buffer, x, "left")
		if offset then
			repl.buffer = repl.buffer:sub(0, x - offset) .. repl.buffer:sub(x, -1)
			repl.SetCaretPosition(x - offset + 1, y)
		end
	elseif key == "ctrl_delete" then
		local offset = find_next_word(repl.buffer, x, "right")

		if offset then
			repl.buffer = repl.buffer:sub(0, x - 1) .. repl.buffer:sub(x + offset, -1)
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
	x = math.min(x, #repl.buffer + 1)
	repl.SetCaretPosition(x, y)

	repl.RenderInput()
	
	return true
end

local ffi = require("ffi")

if ffi then

	local start
	local stop
	local read

	if jit.os == "Linux" then

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

		end

		function repl.GetCaretPosition()
			io.write("\x1b[6n")

			while true do
				local str = io.read()
				if str and str:sub(1, 2) == "\27[" then
					y,x = str:match("\27%[(%d+);(%d+)R")
					break
				end
			end

			return tonumber(x), tonumber(y)
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
				if str == "" then -- newline/enter?
					repl.KeyPressed("enter")
				elseif str:byte() >= 32 and str:byte() < 127 then -- asci chars
					repl.CharInput(str)
				elseif str:sub(1,2) == "\27[" then
					local seq = str:sub(3, #str)

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
							print("char sequence: " .. table.concat({str:byte(1, #str)}, ", ") .. " (" .. #str .. ")")
						end
					else -- unicode ?
						--repl.CharInput(str)
					end
				end
			end

			return true
		end
	end

	if jit.os == "Windows" then
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
			
			void* GetStdHandle(unsigned long nStdHandle);
			
			int PeekNamedPipe(
				void*  hNamedPipe,
				void*  lpBuffer,
				unsigned long   nBufferSize,
				unsigned long* lpBytesRead,
				unsigned long* lpTotalBytesAvail,
				unsigned long* lpBytesLeftThisMessage
			);
		]])
		
		local  STD_INPUT_HANDLE = -10
		
		local stdin = ffi.C.GetStdHandle(STD_INPUT_HANDLE)
		
		if true then
			read = function()
				local size = ffi.new("unsigned long[1]")
				ffi.C.PeekNamedPipe(stdin, nil,nil,nil, size, nil)
				if size[0] > 0 then
					return io.read()
				end
			end
		else
			local rec = ffi.new("struct INPUT_RECORD[1]")
			local events = ffi.new("unsigned long[1]")
			
			read = function()
				ffi.C.PeekConsoleInputA(stdin, rec, ffi.sizeof(rec), events)
				if events[0] > 0 then
					for i = 1, tonumber(events[0]) do
						ffi.C.ReadConsoleInputA(stdin, rec, ffi.sizeof(rec), events)
						local info = rec[0]
						if info.EventType == 1 and info.Event.KeyEvent.bKeyDown then
							return string.char(info.Event.KeyEvent.uChar.UnicodeChar), info.Event.KeyEvent
						end
					end
				end
			end
		end
	end
end

function repl.MainLoop()
	repl.Start()
	while system.run == true do
		system.Sleep(0.1)
		local ok, err = system.pcall(repl.Update)
		if not ok then
			print(err)
			break
		end
	end
	repl.Stop()
end

return repl