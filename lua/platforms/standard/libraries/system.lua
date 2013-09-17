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
	
	local titles = {}
	
	function system.SetWindowTitle(title, id)
		if id then
			titles[id] = title
			set_title(table.concat(titles, " | "))
		else
			set_title(title)
		end
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

return system
