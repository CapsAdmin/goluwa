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

return system