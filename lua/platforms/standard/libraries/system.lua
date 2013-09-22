local system = system or {}

local function not_implemented() debug.trace() logn("this function is not yet implemented!") end

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
	
	function system.SetWindowTitle(title, id)
		if id then
			titles[id] = title
			str = table.concat(titles, " | ")
			system.SetWindowTitleRaw(str)
		else
			str = title
			system.SetWindowTitleRaw(title)
		end
	end
	
	function system.GetWindowTitle()
		return str
	end
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
			typedef void* HKEY;
			long RegOpenKeyEx(HKEY, const char*, unsigned, unsigned, HKEY*);
			long RegCloseKey(HKEY);
		]])

		--local advapi = ffi.load("advapi32")

		--local key = advapi.RegOpenKeyEx()

		--local path = "Software/Valve/Steam/SteamPath"
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

return system
