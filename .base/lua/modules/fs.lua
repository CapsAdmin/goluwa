local fs = {}

if WINDOWS then
	ffi.cdef([[
		typedef struct goluwa_file_time {
			long high;
			long low;
		} goluwa_file_time;

		typedef struct goluwa_find_data {
		  unsigned long dwFileAttributes;
		  
		  goluwa_file_time ftCreationTime;
		  goluwa_file_time ftLastAccessTime;
		  goluwa_file_time ftLastWriteTime;
		  
		  unsigned long nFileSizeHigh;
		  unsigned long nFileSizeLow;
		  
		  unsigned long dwReserved0;
		  unsigned long dwReserved1;
		  
		  char cFileName[260];
		  char cAlternateFileName[14];
		} goluwa_find_data;

		void *FindFirstFileA(const char *lpFileName, goluwa_find_data *find_data);
		bool FindNextFileA(void *handle, goluwa_find_data *find_data);
		bool FindClose(void *); 
		
		unsigned long GetCurrentDirectoryA(unsigned long length, char *buffer);
		bool SetCurrentDirectoryA(const char *path);
		
		bool CreateDirectoryA(const char *path, void *lpSecurityAttributes);
				
		typedef struct goluwa_file_attributes {
			unsigned long dwFileAttributes;
			goluwa_file_time ftCreationTime;
			goluwa_file_time ftLastAccessTime;
			goluwa_file_time ftLastWriteTime;
			unsigned long nFileSizeHigh;
			unsigned long nFileSizeLow;
		} goluwa_file_attributes;
		
		bool GetFileAttributesExA(
		  const char *lpFileName,
		  int fInfoLevelId,
		  goluwa_file_attributes *lpFileInformation
		);
	]])

	local data = ffi.new("goluwa_find_data[1]")

	function fs.find(dir)
		local out = {}
		
		local handle = ffi.C.FindFirstFileA(dir, data)
		
		if ffi.cast("unsigned long", handle) ~= 0xffffffff then
			for i = 1, math.huge do
				out[i] = ffi.string(data[0].cFileName)
				if not ffi.C.FindNextFileA(handle, data) then break end
			end	
			
			ffi.C.FindClose(handle)
		end
		
		return out
	end
	
	function fs.getcd()
		local buffer = ffi.new("char[260]")
		local length = ffi.C.GetCurrentDirectoryA(260, buffer)
		return ffi.string(buffer, length)
	end
	
	function fs.setcd(path)
		ffi.C.SetCurrentDirectoryA(path)
	end
	
	function fs.createdir(path)
		ffi.C.CreateDirectoryA(path, nil)
	end
	
	local info = ffi.new("goluwa_file_attributes[1]")
	function fs.getattributes(path)	
		if ffi.C.GetFileAttributesExA(path, 0, info) then
			return {
				creation_time = info[0].ftCreationTime.low,
				last_accessed = info[0].ftLastAccessTime.low,
				last_modified = info[0].ftLastWriteTime.low,
				last_changed = -1, -- last permission changes
				size = info[0].nFileSizeLow,
			}
		end
	end
else
	local S = require("syscall")
	
	local size = 4096
	local buf = S.t.buffer(size)
	
	function fs.find(dir)		
		local out = {}
		
		local fd, err = S.open(dir, "directory, rdonly")
		
		if fd then
			local iterator, err = fd:getdents(buf, size)
			
			for i = 1, math.huge do
				local info = iterator()
				if not info then break end
				out[i] = info.name
			end
			
			fd:close()
		end
				
		return out
	end
	
	function fs.getcd()
		return S.getcwd()
	end
	
	function fs.setcd(path)
		S.chdir(path)
	end
	
	function fs.createdir(path)
		S.mkdir(path)
	end
	
	function fs.getattributes(path)
		local info = S.stat(path)
		if info then
			return {
				last_accessed = info.access,
				last_changed = info.change,
				last_modified = info.modification,
				size = info.size,
			}
		end
	end
end

return fs