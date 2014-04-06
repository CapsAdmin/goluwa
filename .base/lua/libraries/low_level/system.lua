local system = _G.system or {}

local function not_implemented() debug.trace() logn("this function is not yet implemented!") end

do -- message box
	local set = not_implemented
	
	if WINDOWS then		
		ffi.cdef("int MessageBoxA(void *w, const char *txt, const char *cap, int type);")
		
		set = function(title, message)
			ffi.C.MessageBoxA(nil, message, title, 0)
		end
	end
	
	system.MessageBox = set
end

do -- title
	local set_title
	if WINDOWS then
		ffi.cdef("int SetConsoleTitleA(const char* blah);")

		set_title = function(str)
			return ffi.C.SetConsoleTitleA(str)
		end
	end

	if LINUX then
		set_title = function(str)
			return io.old_write and io.old_write('\27]0;', str, '\7') or nil
		end
	end
	
	system.SetWindowTitleRaw = set_title
	
	local titles = {}
	local str = ""
	local last = 0
	local last_title
	
	local lasttbl = {}
	
	function system.SetWindowTitle(title, id)
		local time = os.clock()
		
		if not lasttbl[id] or lasttbl[id] < time then
			if id then
				titles[id] = title
				str = "| "
				for k,v in pairs(titles) do
					str = str ..  v .. " | "
				end
				if str ~= last_title then
					system.SetWindowTitleRaw(str)
				end
			else
				str = title
				if str ~= last_title then
					system.SetWindowTitleRaw(title)
				end
			end
			last_title = str
			lasttbl[id] = os.clock() + 0.05
		end
	end
	
	function system.GetWindowTitle()
		return str
	end
end

do -- cursor
	local set = not_implemented
	local get = not_implemented

	if WINDOWS then
		ffi.cdef[[
			void* SetCursor(void *);
			void* LoadCursorA(void*, uint16_t);
		]]
		
		local lib = ffi.load("user32.dll")
		local cache = {}

		
		--[[arrow = IDC_ARROW, 
		ibeam = IDC_IBEAM, 
		wait = IDC_WAIT, 
		cross = IDC_CROSS, 
		uparrow = IDC_UPARROW, 
		size = IDC_SIZE, 
		icon = IDC_ICON, 
		sizenwse = IDC_SIZENWSE, 
		sizenesw = IDC_SIZENESW, 
		sizewe = IDC_SIZEWE, 
		sizens = IDC_SIZENS, 
		sizeall = IDC_SIZEALL, 
		no = IDC_NO, 
		hand = IDC_HAND, 
		appstarting = IDC_APPSTARTING, 		
		help = IDC_HELP,]]
		
		e.IDC_ARROW = 32512
		e.IDC_IBEAM = 32513
		e.IDC_WAIT = 32514
		e.IDC_CROSS = 32515
		e.IDC_UPARROW = 32516
		e.IDC_SIZE = 32640
		e.IDC_ICON = 32641
		e.IDC_SIZENWSE = 32642
		e.IDC_SIZENESW = 32643
		e.IDC_SIZEWE = 32644
		e.IDC_SIZENS = 32645
		e.IDC_SIZEALL = 32646
		e.IDC_NO = 32648
		e.IDC_HAND = 32649
		e.IDC_APPSTARTING = 32650
		e.IDC_HELP = 32651
		
		local current
		
		local last 
		
		set = function(id)
			id = id or e.IDC_ARROW
			cache[id] = cache[id] or lib.LoadCursorA(nil, id)
			
			--if last ~= id then
				current = id
				lib.SetCursor(cache[id])
			--	last = id
			--end
		end
		
		get = function()
			return current
		end
	end
	
	system.SetCursor = set
	system.GetCursor = get
	
end

do -- dll paths
	local set, get = not_implemented, not_implemented
	
	if WINDOWS then		
		ffi.cdef[[
			int SetDllDirectoryA(const char *path);
			unsigned long GetDllDirectoryA(unsigned long length, char *path);
		]]
		
		set = function(path)
			ffi.C.SetDllDirectoryA(path or "")
		end
		
		local str = ffi.new("char[1024]")
		
		get = function()
			ffi.C.GetDllDirectoryA(1024, str)
			
			return ffi.string(str)
		end
	end
	
	system.SetDLLDirectory = set
	system.GetDLLDirectory = get
end

do -- fonts
	local get = not_implemented
	
	if WINDOWS then
		--[==[ffi.cdef[[
				
		typedef struct LOGFONT {
		  long  lfHeight;
		  long lfWidth;
		  long  lfEscapement;
		  long  lfOrientation;
		  long  lfWeight;
		  char  lfItalic;
		  char  lfUnderline;
		  char  lfStrikeOut;
		  char  lfCharSet;
		  char  lfOutPrecision;
		  char  lfClipPrecision;
		  char  lfQuality;
		  char  lfPitchAndFamily;
		  char lfFaceName[LF_FACESIZE];
		} LOGFONT;

		
		int EnumFontFamiliesEx(void *, LOGFONT *)
		]]]==]
	
		get = function()
			
		end
	elseif LINUX then
		ffi.cdef([[
			typedef struct {} Display;
			Display* XOpenDisplay(const char*);
			void XCloseDisplay(Display*);
			char** XListFonts(Display* display, const char* pattern, int max_names, int* actual_names);
		]])

		local X11 = ffi.load("X11")

		local display = X11.XOpenDisplay(nil)

		if display == nil then
			print("cricket")
			return
		end

		local count = ffi.new("int[1]")
		local names = X11.XListFonts(display, "*", 65535, count)
		count = count[0]

		for i = 1, count do
			local name = ffi.string(names[i - 1])
		end

		X11.XCloseDisplay(display)
	end

	system.GetInstalledFonts = get

end

do -- registry
	local set = not_implemented
	local get = not_implemented

	if WINDOWS then
		ffi.cdef([[
			typedef unsigned HKEY;
			long __stdcall RegGetValueA(HKEY, const char*, const char*, unsigned, unsigned*, void*, unsigned*);
		]])

		local advapi = ffi.load("advapi32")

		local HKEY_CLASSES_ROOT  = 0x80000000
		local HKEY_CURRENT_USER = 0x80000001
		local HKEY_LOCAL_MACHINE = 0x80000002
		local HKEY_CURRENT_CONFIG = 0x80000005

		local RRF_RT_REG_SZ = 0x00000002
		local RRF_RT_ANY = 0x0000ffff

		local REG_NONE = 0
		local REG_SZ = 1

		local ERROR_SUCCESS = 0x0

		get = function(key, key2)
			local value = ffi.new("char[4096]")
			local value_size = ffi.new("unsigned[1]")
			value_size[0] = 4096
			local grr = advapi.RegGetValueA(HKEY_CURRENT_USER, key, key2, RRF_RT_REG_SZ, nil, value, value_size)

			if grr ~= ERROR_SUCCESS then
				return
			end

			return ffi.string(value)
		end
	end
	
	if LINUX then
		-- return empty values
	end
	
	system.GetRegistryKey = get
	system.SetRegistryKey = set
end

do 
local get = not_implemented
	
	if WINDOWS then
		ffi.cdef("int GetTickCount();")
		
		get = function() return ffi.C.GetTickCount() end
	end
	
	if LINUX then
		ffi.cdef[[	
			typedef long time_t;
			typedef long suseconds_t;

			struct timezone {
				int tz_minuteswest;     /* minutes west of Greenwich */
				int tz_dsttime;         /* type of DST correction */
			};
			
			struct timeval {
				time_t      tv_sec;     /* seconds */
				suseconds_t tv_usec;    /* microseconds */
			};
			
			int gettimeofday(struct timeval *tv, struct timezone *tz);
		]]
		
		local temp = ffi.new("struct timeval[1]")
		get = function() ffi.C.gettimeofday(temp, nil) return temp[0].tv_usec*100 end
	end
	
	system.GetTickCount = get
end

do -- time in ms
	local get = not_implemented
	
	if WINDOWS then
		ffi.cdef("int timeGetTime();")
		
		get = function() return ffi.C.timeGetTime() end
	end
	
	if LINUX then
		ffi.cdef[[	
			int gettimeofday(struct timeval *tv, struct timezone *tz);
		]]
		
		local temp = ffi.new("struct timeval[1]")
		get = function() ffi.C.gettimeofday(temp, nil) return temp[0].tv_usec*100 end
	end
	
	system.GetTimeMS = get
end

do -- sleep
	local sleep = not_implemented
	
	if WINDOWS then
		ffi.cdef("void Sleep(int ms)")
		sleep = function(ms) ffi.C.Sleep(ms) end
	end

	if LINUX then
		ffi.cdef("void usleep(unsigned int ns)")
		sleep = function(ms) ffi.C.usleep(ms*1000) end
	end
	
	system.Sleep = sleep
end

do -- clipboard
	local set = not_implemented
	local get = not_implemented
		
	system.SetClipboard = set
	system.GetClipboard = get	
end

do -- transparent window
	local set = not_implemented

	if WINDOWS then
		set = function(window, b)
			-- http://stackoverflow.com/questions/4052940/how-to-make-an-opengl-rendering-context-with-transparent-background
		
			ffi.cdef([[
				typedef unsigned char BYTE;
				typedef unsigned short WORD;
				typedef unsigned long DWORD;
				
				typedef struct {
					WORD  nSize;
					WORD  nVersion;
					DWORD dwFlags;
					BYTE  iPixelType;
					BYTE  cColorBits;
					BYTE  cRedBits;
					BYTE  cRedShift;
					BYTE  cGreenBits;
					BYTE  cGreenShift;
					BYTE  cBlueBits;
					BYTE  cBlueShift;
					BYTE  cAlphaBits;
					BYTE  cAlphaShift;
					BYTE  cAccumBits;
					BYTE  cAccumRedBits;
					BYTE  cAccumGreenBits;
					BYTE  cAccumBlueBits;
					BYTE  cAccumAlphaBits;
					BYTE  cDepthBits;
					BYTE  cStencilBits;
					BYTE  cAuxBuffers;
					BYTE  iLayerType;
					BYTE  bReserved;
					DWORD dwLayerMask;
					DWORD dwVisibleMask;
					DWORD dwDamageMask;
				} PIXELFORMATDESCRIPTOR;
			
				typedef struct {
					int x,y,w,h;
				} HRGN;
				
				typedef struct {
					unsigned long dwFlags;
					int  fEnable;
					HRGN  hRgnBlur;
					int  fTransitionOnMaximized;
				} DWM_BLURBEHIND;
				
				void* GetDC(void*);
				
				int ChoosePixelFormat(
				  void *,
				  const PIXELFORMATDESCRIPTOR *ppfd
				);
			
				long GetWindowLongA(void*, int);
				long SetWindowLongA(void*, int, long);
				long DwmEnableBlurBehindWindow(void*, DWM_BLURBEHIND);
								
				HRGN CreateRectRgn(int,int,int,int);
				int SetPixelFormat(
				  void *hdc,
				  int iPixelFormat,
				  const PIXELFORMATDESCRIPTOR *ppfd
				);
				DWORD GetLastError();
			]])
			
			local GWL_STYLE = -16
			local WS_OVERLAPPEDWINDOW = 0x00CF0000
			local WS_POPUP = 0x80000000
			local DWM_BB_ENABLE = 0x00000001
			local DWM_BB_BLURREGION = 0x00000002
			
			local lib = ffi.load("dwmapi.dll")
			
			local style = ffi.C.GetWindowLongA(window, GWL_STYLE)
			style = bit.band(style, bit.bnot(WS_OVERLAPPEDWINDOW))
			style = bit.bor(style, WS_POPUP)
			
			ffi.C.SetWindowLongA(window, GWL_STYLE, style)
			
			local bb = ffi.new("DWM_BLURBEHIND",0)
			bb.dwFlags = bit.bor(DWM_BB_ENABLE, DWM_BB_BLURREGION)
			bb.fEnable = true
			bb.hRgnBlur = ffi.load("Gdi32.dll").CreateRectRgn(0,0,1,1)
			bb.fTransitionOnMaximized = 0
			lib.DwmEnableBlurBehindWindow(window, bb)		
			
			local PFD_TYPE_RGBA = 0
			local PFD_MAIN_PLANE = 0
			local PFD_DOUBLEBUFFER = 1
			local PFD_DRAW_TO_WINDOW = 4
			local PFD_SUPPORT_OPENGL = 32
			local PFD_SUPPORT_COMPOSITION = 0x00008000
			
			local pfd = ffi.new("PIXELFORMATDESCRIPTOR", {
				ffi.sizeof("PIXELFORMATDESCRIPTOR"),
				1,                                -- Version Number
				bit.bor(
					PFD_DRAW_TO_WINDOW      ,     -- Format Must Support Window
					PFD_SUPPORT_OPENGL      ,     -- Format Must Support OpenGL
					PFD_SUPPORT_COMPOSITION       -- Format Must Support Composition
				),
				PFD_DOUBLEBUFFER,                 -- Must Support Double Buffering
				PFD_TYPE_RGBA,                    -- Request An RGBA Format
				32,                               -- Select Our Color Depth
				0, 0, 0, 0, 0, 0,                 -- Color Bits Ignored
				8,                                -- An Alpha Buffer
				0,                                -- Shift Bit Ignored
				0,                                -- No Accumulation Buffer
				0, 0, 0, 0,                       -- Accumulation Bits Ignored
				24,                               -- 16Bit Z-Buffer (Depth Buffer)
				8,                                -- Some Stencil Buffer
				0,                                -- No Auxiliary Buffer
				PFD_MAIN_PLANE,                   -- Main Drawing Layer
				0,                                -- Reserved
				0, 0, 0                           -- Layer Masks Ignored
			})
			
			local hdc = ffi.C.GetDC(window)
			print(ffi.C.GetLastError(), window, hdc)
			local pxfmt = ffi.load("Gdi32.dll").ChoosePixelFormat(hdc, pfd)
			ffi.load("Gdi32.dll").SetPixelFormat(hdc, pxfmt, pfd)
			gl.Enable(e.GL_BLEND)
			gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)
			
			render.SetClearColor(0,0,0,0)
		end
	end

	system.EnableWindowTransparency = set
end

function system.DebugJIT(b)
	if b then
		jit.v.on(R"%DATA%/logs/jit_verbose_output.txt")
	else
		jit.v.off(R"%DATA%/logs/jit_verbose_output.txt")
	end
end

return system
