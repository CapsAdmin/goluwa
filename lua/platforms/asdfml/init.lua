include("header_parse/sfml.lua")
--include("header_parse/glew.lua")
include("libraries/gl_enums.lua")
gl, glu = include("libraries/opengl.lua")

addons.AutorunAll()

local window

asdfml = {}

function asdfml.OpenWindow(w, h, title)
	if window and window:IsOpen() then return end

	w = w or 800
	h = h or 600
	title = title or "no title"

	local settings = ContextSettings()

	settings.depthBits = 24
	settings.stencilBits = 8
	settings.antialiasingLevel = 4
	settings.majorVersion = 3
	settings.minorVersion = 0

	window = RenderWindow(VideoMode(w, h, 32), title, bit.bor(e.RESIZE, e.CLOSE), settings)

	return window
end

function asdfml.OnClosed(params)
	window:Close()
	os.exit()
end

do -- input handling
	ffi.cdef[[
		/* Type declarations. */
		typedef struct {
		  int	   y;			/* current pseudo-cursor */
		  int	   x;
		  int      _maxy;			/* max coordinates */
		  int      _maxx;
		  int      _begy;			/* origin on screen */
		  int      _begx;
		  int	   _flags;			/* window properties */
		  int	   _attrs;			/* attributes of written characters */
		  int      _tabsize;			/* tab character size */
		  bool	   _clear;			/* causes clear at next refresh */
		  bool	   _leave;			/* leaves cursor as it happens */
		  bool	   _scroll;			/* allows window scrolling */
		  bool	   _nodelay;			/* input character wait flag */
		  bool	   _keypad;			/* flags keypad key mode active */
		  int    **_line;			/* pointer to line pointer array */
		  int	  *_minchng;			/* First changed character in line */
		  int	  *_maxchng;			/* Last changed character in line */
		  int	   _regtop;			/* Top/bottom of scrolling region */
		  int	   _regbottom;
		} WINDOW;


		typedef void* WINDOW;
		WINDOW *initscr();
		void timeout(int delay);
		int wtimeout(WINDOW *win, int delay);
		void halfdelay(int delay);
		void cbreak();
		void nocbreak();
		void noecho();
		int getch();
		int wgetch(WINDOW *win);

		int idlok(WINDOW *win, bool bf);
		int leaveok(WINDOW *win, bool bf);
		int keypad(WINDOW *win, bool bf);
		int scrollok(WINDOW *win, bool bf);

		int nodelay(WINDOW *win, bool b);
		int notimeout(WINDOW *win, bool b);
		WINDOW *derwin(WINDOW*, int nlines, int ncols, int begin_y, int begin_x);
		int wrefresh(WINDOW *win);
		int box(WINDOW *win, int, int);
		int werase(WINDOW *win);
		int hline(const char *, int);
		int COLS;
		int LINES;
		const char *killchar();
		void keypad(WINDOW*, bool);
		const char *keyname(int c);
		int waddstr(WINDOW *win, const char *chstr);
		int wmove(WINDOW *win, int y, int x);
	]]

	local curses = ffi.load("pdcurses")

	local parent = curses.initscr()
	local line_window = curses.derwin(parent, 1, 128, curses.LINES-1, 0)

	curses.cbreak()
	curses.noecho()
	curses.nodelay(line_window, true)
	curses.wrefresh(line_window)
	curses.keypad(line_window, true);

	local function get_char()
		return curses.wgetch(line_window)
	end

	local function clear(str)
		local y, x = line_window.y, line_window.x
		curses.werase(line_window)
		if str then
			curses.waddstr(line_window, str)
		end
		if str then
			curses.wmove(line_window, y, x)
		else
			curses.wmove(line_window, y, 0)
		end
		curses.wrefresh(line_window)
	end

	local function get_key_name(num)
		return curses.keyname(num)
	end

	local function move_cursor(x)
		return curses.wmove(line_window, line_window.y, line_window.x + x)
	end

	local function set_cursor_pos(x)
		return curses.wmove(line_window, 0, x)
	end

	local line = ""
	local history = {}
	local scroll = 0

	local function insert_char(char)
		if #line == 0 then
			line = line .. char
		elseif subpos == #line then
			line = line .. char
		else
			line = line:sub(1, line_window.x) .. char .. line:sub(line_window.x + 1)
		end

		clear(line)

		move_cursor(1)
	end

	function asdfml.ProcessInput()
		local byte = get_char()

		if byte > 0 then
			if byte > 255 or byte <= 32 then
				local key = get_key_name(byte)

				key = ffi.string(key)

				if key == "KEY_UP" then
					scroll = scroll - 1
					line = history[scroll%#history+1] or line
					set_cursor_pos(#line)
				elseif key == "KEY_DOWN" then
					scroll = scroll + 1
					line = history[scroll%#history+1] or line
					set_cursor_pos(#line)
				end

				if key == "KEY_LEFT" then
					 move_cursor(-1)
				elseif key == "KEY_RIGHT" then
					 move_cursor(1)
				end

				if key == "KEY_HOME" then
					set_cursor_pos(0)
				elseif key == "KEY_END" then
					set_cursor_pos(#line)
				end

				-- space
				if byte == 32 then
					insert_char(" ")
				end

				if byte == 9 then
					local start, stop, last_word = line:find("([_%a%d]-)$")
					if last_word then
						local pattern = "^" .. last_word
						for k,v in pairs(_G) do
							if k:find(pattern) then
								line = line:sub(0, start-1) .. k
								set_cursor_pos(#line)
								break
							end
						end
					end
				end

				-- backspace
				if byte == 8 then
					if line_window.x > 0 then
						line = line:sub(1, line_window.x - 1) .. line:sub(line_window.x + 1)
						move_cursor(-1)
					else
						clear()
					end
				elseif key == "KEY_DC" then
					if line_window.x > 0 then
						line = line:sub(1, line_window.x) .. line:sub(line_window.x + 2)
					else
						clear()
					end
				end

				-- enter
				if byte == 10 or byte == 13 then
					clear()
					io.write(line, "\n")

					if line ~= "" then
						local res, err = loadstring(line)

						if res then
							res, err = pcall(res)
						end

						if not res then
							io.write(err, "\n")
						end

						table.insert(history, line)

						scroll = 0

						line = ""
						clear()
					end
				end

				clear(line)
			else
				local char = string.char(byte)
				insert_char(char)
			end
		end
	end
end

do -- update
	local params = Event()
	local clock = Clock()

	local smooth_fps = 0
	local fps_fmt = "FPS: %i"
	asdfml.max_fps = 120

	-- this sucks
	ffi.cdef("float sfTime_asSeconds(sfTime time)")

	local sleep

	if WINDOWS then
		ffi.cdef("void Sleep(int ms)")
		sleep = function(ms) ffi.C.Sleep(ms) end
	end

	if LINUX then
		ffi.cdef("void usleep(unsigned int ms)")
		sleep = function(ms) ffi.C.usleep(ms/1000) end
	end

	function asdfml.Update()
		sleep(1000/asdfml.max_fps)

		luasocket.Update()
		timer.Update()

		asdfml.ProcessInput()

		local dt = sfsystem.sfTime_asSeconds(clock:Restart()) -- fix me!!!

		smooth_fps = smooth_fps + (((1/dt) - smooth_fps) * dt)

		mmyy.SetWindowTitle(string.format(fps_fmt, smooth_fps))

		event.Call("OnUpdate", dt)

		if window and window:IsOpen() then
			if window:PollEvent(params) then
				asdfml.HandleEvent(params)
			end

			window:Clear(e.BLACK)
				event.Call("OnDraw", dt)
			window:Display()
		end
	end
end

function asdfml.GetWindow()
	return window
end

do
	local temp = {}

	for key, val in pairs(_E) do
		if key:sub(1, 4) == "EVT_" then
			temp[val] = key
		end
	end

	local events = {}

	for k,v in pairs(temp) do
		v = "On" .. v:gsub("EVT(.+)", function(str)
			return str:lower():gsub("(_.)", function(char)
				return char:sub(2):upper()
			end)
		end)

		events[k] = v
		events[v] = {v = k, k = v}
	end

	function asdfml.HandleEvent(params)
		local name = events[tonumber(params.type)]
		if name and event.Call(name, params) ~= false then
			if asdfml[name] then
				asdfml[name](params)
			end
		end
	end
end

local function main()
	event.Call("Initialize")

	while true do
		local ok, err = pcall(asdfml.Update)

		if not ok then
			log(err)
			io.stdin:read("*l")
			break
		end
	end

	event.Call("ShutDown")
end

event.AddListener("Initialized", "main", main)