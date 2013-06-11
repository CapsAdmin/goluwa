sfml = include("header_parse/sfml.lua")

for k,v in pairs(sfml) do
	if k == "e" then
		for k, v in pairs(v) do
			e[k] = v
		end
	else
		_G[k] = v
	end
end

include("libraries/gl_enums.lua")
gl, glu = include("libraries/opengl.lua")

surface = include("libraries/surface.lua")
render = include("libraries/render.lua")
include("libraries/mesh.lua")

include("extensions/input.lua")

addons.AutorunAll()
 
local window

asdfml = asdfml or {}

function asdfml.OpenWindow(w, h, title)
	if window and window:IsOpen() then return window end

	w = w or 640
	h = h or 480
	title = title or "no title"

	local settings = ContextSettings()

	settings.depthBits = 32
	settings.stencilBits = 8
	settings.antialiasingLevel = 4
	settings.majorVersion = 5
	settings.minorVersion = 3

	window = RenderWindow(VideoMode(w, h, 32), title, bit.bor(e.RESIZE, e.CLOSE), settings)
	
	if gl and gl.InitMiniGlew then
		gl.InitMiniGlew()
	end
	
	if render then
		render.Initialize(w, h)
	end

	return window
end

function asdfml.SetMouseTrapped(b)
	asdfml.mouse_trapped = b
end

function asdfml.GetMouseDelta()
	return asdfml.mouse_delta or Vec2()
end

local last_x
local last_y

function asdfml.UpdateMouseMove()
	if not window then return end
	if asdfml.mouse_trapped and asdfml.HasFocus() and not input.IsKeyDown("escape") then
		local pos = mouse.GetPosition(ffi.cast("sfWindow * ", window))
		
		local dx = (pos.x - (last_x or pos.x)) 
		local dy = (pos.y - (last_y or pos.y))
		
		asdfml.mouse_delta = Vec2(dx, dy)
			
		last_x = pos.x 
		last_y = pos.y
		
		window:SetMouseCursorVisible(false)
		local size = window:GetSize()

		if pos.x > size.x then
			mouse.SetPosition(Vector2i(0, pos.y), ffi.cast("sfWindow * ", window))
			last_x = 0
		elseif pos.x < 0 then
			mouse.SetPosition(Vector2i(size.x, pos.y), ffi.cast("sfWindow * ", window))
			last_x = size.x
		end 
		
		if pos.y > size.y then
			mouse.SetPosition(Vector2i(pos.x, 0), ffi.cast("sfWindow * ", window))
			last_y = 0
		elseif pos.y < 0 then
			mouse.SetPosition(Vector2i(pos.x, size.y), ffi.cast("sfWindow * ", window))
			last_y = size.y
		end	
	else 
		window:SetMouseCursorVisible(true)
		last_x = nil
		last_y = nil
	end 
end

function asdfml.OnGainedFocus()
	asdfml.focused = true
end

function asdfml.OnLostFocus()
	asdfml.focused = false
end

function asdfml.HasFocus()
	return asdfml.focused
end

function asdfml.OnResized(params)
	local view = window:GetDefaultView()
	view = ffi.cast("sfView *", view)
	local w, h = params.size.width, params.size.height
	
	view:SetViewport(FloatRect(0,0, w, h))	
	window:SetView(view)
	
	if render then
		render.Initialize(w, h)
	end
end

function asdfml.OnClosed(params)
	window:Close()
end

do -- input handling
	
	if LINUX then
		ffi.cdef[[
			/* Type declarations. */
		
			typedef struct {
			  short	   y;			/* current pseudo-cursor */
			  short	   x;
			  short      _maxy;			/* max coordinates */
			  short      _maxx;
			  short      _begy;			/* origin on screen */
			  short      _begx;
			  short	   _flags;			/* window properties */
			} WINDOW;
		]]
	end
	
	if WINDOWS then
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
		]]
	end
	
	ffi.cdef[[		
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
		int refresh();
		int box(WINDOW *win, int, int);
		int werase(WINDOW *win);
		int wclear(WINDOW *win);
		int hline(const char *, int);
		int COLS;
		int LINES;
		const char *killchar();
		void keypad(WINDOW*, bool);
		const char *keyname(int c);
		int waddstr(WINDOW *win, const char *chstr);
		int wmove(WINDOW *win, int y, int x);
		int resize_term(int y, int x);
		
		void getyx(WINDOW *win, int y, int x);
	]]
	
	if _E.CURSES_INIT then return end
	
	-- whyyyyyyyyy
	if WINDOWS then
		os.execute("mode con:cols=140 lines=50")
	end
	
	local curses = ffi.load(jit.os == "Linux" and "libncurses.so" or "pdcurses")
	local parent = curses.initscr()
	
	local line_window = curses.derwin(parent, 1, 128, curses.LINES-1, 0)
	
	local function gety()
		return line_window.y
	end
	
	local function getx()	
		return line_window.x
	end
	 
	curses.cbreak()
	curses.noecho()
	curses.nodelay(line_window, true)
	curses.wrefresh(line_window)
	curses.keypad(line_window, true)
	
	
	_E.CURSES_INIT = true
	
	local function get_char()
		return curses.wgetch(line_window)
	end

	local function clear(str)
		local y, x = gety(), getx()
		
		curses.wclear(line_window)
		
		if str then
			curses.waddstr(line_window, str)
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
		curses.wmove(line_window, gety(), getx() + x)
		curses.wrefresh(line_window)
	end

	local function set_cursor_pos(x)
		curses.wmove(line_window, 0, x)
		curses.wrefresh(line_window)
	end

	local function load_history()
		return luadata.ReadFile("%DATA%/cmd_history.txt")
	end
	
	local function save_history(tbl)
		return luadata.WriteFile("%DATA%/cmd_history.txt", tbl)
	end
	
	local line = ""
	local history = load_history()
	local scroll = 0
	
	local function insert_char(char)
		if #line == 0 then
			line = line .. char
		elseif subpos == #line then
			line = line .. char
		else
			line = line:sub(1, getx()) .. char .. line:sub(getx() + 1)
		end

		clear(line)

		move_cursor(1)
	end

	local current_table = _G
	local table_scroll = 0
	local in_function
	
	local translate = 
	{
		[32] = "KEY_SPACE",
		[9] = "KEY_TAB",
		[10] = "KEY_ENTER",
		[8] = "KEY_BACKSPACE",
		[127] = "KEY_BACKSPACE",
	}
	
	function asdfml.ProcessInput()
		local byte = get_char()
		
		if byte < 0 then return end
		
		local key = translate[byte] or ffi.string(get_key_name(byte))
		if not key:find("KEY_") then key = nil end
				
		if key then					
			key = ffi.string(key)
			
			if event.Call("OnConsoleKeyPressed", key) == false then return end
			
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
			if key == "KEY_SPACE" then
				insert_char(" ")
			end

			-- tab
			if key == "KEY_TAB" then
				local start, stop, last_word = line:find("([_%a%d]-)$")
				if last_word then
					local pattern = "^" .. last_word
									
					if (not line:find("%(") or not line:find("%)")) and not line:find("logn") then
						in_function = false
					end
									
					if not in_function then
						current_table = line:explode(".")
												
						local tbl = _G
						
						for k,v in pairs(current_table) do
							if type(tbl[v]) == "table" then
								tbl = tbl[v]
							else
								break
							end
						end
						
						current_table = tbl or _G						
					end
					
					if in_function then
						local start = line:match("(.+%.)")
						if start then
							local tbl = {}
							
							for k,v in pairs(current_table) do
								table.insert(tbl, {k=k,v=v})
							end
							
							if #tbl > 0 then
								table.sort(tbl, function(a, b) return a.k > b.k end)
								table_scroll = table_scroll + 1
								
								local data = tbl[table_scroll%#tbl + 1]
								
								if type(data.v) == "function" then
									line = start .. data.k .. "()"
									set_cursor_pos(#line)
									move_cursor(-1)
									in_function = true
								else
									line = "logn(" .. start .. data.k .. ")"
									set_cursor_pos(#line)
									move_cursor(-1)
								end
							end
						end
					else						
						for k,v in pairs(current_table) do
							k = tostring(k)
							
							if k:find(pattern) then
								line = line:sub(0, start-1) .. k
								if type(v) == "table" then 
									current_table = v 
									line = line .. "."
									set_cursor_pos(#line)
								elseif type(v) == "function" then
									line = line .. "()"
									set_cursor_pos(#line)
									move_cursor(-1)
									in_function = true
								else
									line = "logn(" .. line .. ")"
								end
								break
							end
						end
					end
				end
			end

			-- backspace
			if key == "KEY_BACKSPACE" then
				if getx() > 0 then
					local char = line:sub(1, getx())
					
					if char == "." then
						current_table = previous_table
					end
					
					line = line:sub(1, getx() - 1) .. line:sub(getx() + 1)
					move_cursor(-1)
				else
					clear()
				end
			elseif key == "KEY_DC" then
				if getx() > 0 then
					line = line:sub(1, getx()) .. line:sub(getx() + 2)
				else
					clear()
				end
			end

			-- enter
			if key == "KEY_ENTER" then
				clear()

				if line ~= "" then
					if event.Call("OnLineEntered", line) ~= false then
						log(line, "\n")
						
						local res, err = console.RunString(line)

						if not res then
							log(err, "\n")
						end
					end
					
					for key, str in pairs(history) do
						if str == line then
							table.remove(history, key)
						end
					end
					
					table.insert(history, line)
					save_history(history)

					scroll = 0
					current_table = _G
					in_function = false
					line = ""
					clear()
				end
			end

			clear(line)
		elseif byte < 255 then
			local char = string.char(byte)
			
			if event.Call("OnConsoleCharPressed", char) == false then return end
			
			insert_char(char)
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
		ffi.cdef("void usleep(unsigned int ns)")
		sleep = function(ms) ffi.C.usleep(ms*1000) end
	end

	function asdfml.Update()
		sleep(1000/asdfml.max_fps)

		luasocket.Update()
		timer.Update()

		asdfml.ProcessInput()
		asdfml.UpdateMouseMove()
		
		local dt = clock:Restart():AsSeconds()

		smooth_fps = smooth_fps + (((1/dt) - smooth_fps) * dt)

		mmyy.SetWindowTitle(string.format(fps_fmt, smooth_fps), 1)

		event.Call("OnUpdate", dt) 

		if window and window:IsOpen() then
			if window:PollEvent(params) then
				asdfml.HandleEvent(params)
			end

			--window:Clear(e.BLACK)
				event.Call("OnDraw", dt, window)
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
		local ok, err = xpcall(asdfml.Update, OnError)

		if not ok then
			log(err)
			io.stdin:read("*l")
			break
		end
	end

	event.Call("ShutDown")
end

event.AddListener("Initialized", "main", main)
