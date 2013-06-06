include("header_parse/sfml.lua")
--include("header_parse/glew.lua")
include("libraries/gl_enums.lua")
gl, glu = include("libraries/opengl.lua")

addons.AutorunAll()

local window

asdfml = {}

function asdfml.OnClosed(params)
	window:Close()
	os.exit()
end

do -- input handling
	print(pcall(function()

	ffi.cdef([[
		typedef struct {
			unsigned char *_ptr;
			int     _cnt;
			unsigned char *_base;
			unsigned char *_bufendp;
			short _flag;
			short _file;
			int __stdioid;
			char *__newbase;
			long _unused[1];
		} FILE;

		char *fgetc(FILE *f);
		
		typedef struct timeval {
			long tv_sec;
			long tv_usec;
		} timeval;
		
		typedef struct fd_set {
			unsigned int count;
			int fd[64];
		} fd_set;
		

		int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, const struct timeval *timeout);
		
		int _kbhit();
		const char *_getch();
	]])
		
	if WINDOWS then				
		local line = ""
		local history = {}
		local scroll = 0
				
				
		local function insert_char(char)
			if #line == 0 then
				line = line .. char
			elseif subpos == #line then
				line = line .. char
			else
				line = line:sub(1, curses.getx()) .. char .. line:sub(curses.getx()+1)
			end
						
			curses.clear(line)
		end
		
		function asdfml.ProcessInput()
			--mmyy.SetWindowTitle(tostring(os.clock()))
			local byte = curses.getch()
			
			if byte > 0 then				
				if byte > 255 or byte <= 32 then
					local key = curses.keyname(byte)					
					
					key = ffi.string(key)
					mmyy.SetWindowTitle(tostring(key))
					
					if key == "KEY_UP" then
						scroll = scroll - 1
						line = history[scroll%#history+1] or line
					elseif key == "KEY_DOWN" then
						scroll = scroll + 1
						line = history[scroll%#history+1] or line
					end
										
					if key == "KEY_LEFT" then
						curses.move(0, -1)
					elseif key == "KEY_RIGHT" then
						curses.move(0, 1)
					end
					
					if key == "KEY_HOME" then
						curses.setpos(0, 0)
					elseif key == "KEY_END" then
						curses.setpos(0, #line)
					end
					
					-- space
					if byte == 32 then
						insert_char(" ")
					end
					
					if byte == 9 then
						insert_char("\t")
					end
					
					-- backspace
					if byte == 8 then						
						if curses.getx() > 0 then
							line = line:sub(1, curses.getx() - 1) .. line:sub(curses.getx() + 1)
						else
							curses.clear()
						end
					end	
					
					-- enter
					if byte == 10 or byte == 13 then
						curses.clear()
						io.write("\n")
						
						if line ~= "" then
							local ok, err = console.CallCommandLine(line)
							
							if not ok then
								io.write(err, "\n")
							end
							
							table.insert(history, line)
							
							scroll = 0
							
							line = ""					
							curses.clear()
						end
					end
					
					curses.clear(line)
				else					
					local char = string.char(byte)
					insert_char(char)
				end
			end
		end
	end
		
	if LINUX then
		-- ported from
		-- http://cc.byexamples.com/2007/04/08/non-blocking-user-input-in-loop-without-ncurses/
		
		local fds = ffi.new("struct fd_set")
		fds.count = 0
		
		local tv = ffi.new("struct timeval")
		tv.tv_sec = 0
		tv.tv_usec = 0
		
		local STDIN_FILENO = 0
		
		local clib = ffi.C
		
		local function kbhit()
			if fds.count < 64 then
				fds.fd[fds.count + 1] = 0
			end
			
			clib.select(STDIN_FILENO + 1, fds, nil, nil, tv)
					
			for i = 0, fds.count do
				if fds.fd[i] == STDIN_FILENO then
					return true
				end
			end
			
			return false
		end	
		
		function asdfml.ProcessInput()
			if kbhit() then
				local char = tostring(ffi.C.fgetc(io.stdin))
				--print(char, "!!!!")
			end
		end
	end
	

	
	end))
end

do -- update
	local params = Event()
	local clock = Clock()

	-- this sucks
	ffi.cdef("float sfTime_asSeconds(sfTime time)")
	
	function asdfml.Update()
		luasocket.Update()
		timer.Update()

		asdfml.ProcessInput()
		
		if not window then
			local settings = ContextSettings()

			settings.depthBits = 24
			settings.stencilBits = 8
			settings.antialiasingLevel = 4
			settings.majorVersion = 3
			settings.minorVersion = 0
			
			window = RenderWindow(VideoMode(800, 600, 32), "ASDFML", bit.bor(e.RESIZE, e.CLOSE), settings)
		end
		
		local dt = sfsystem.sfTime_asSeconds(clock:Restart()) -- fix me!!!
		
		if window:IsOpen() then
			if window:PollEvent(params) then
				asdfml.HandleEvent(params)
			end
		end
		
		event.Call("OnUpdate", dt)
		
		window:Clear(e.BLACK)
			event.Call("OnDraw", dt)
		window:Display()
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

function main()
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