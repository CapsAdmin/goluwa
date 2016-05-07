local fs = _G.fs or {}

local ffi = require("ffi")

if WINDOWS then
	ffi.cdef([[
		typedef struct goluwa_file_time {
			unsigned long high;
			unsigned long low;
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

	function fs.find(dir, exclude_dot)
		local out = {}

		if dir:sub(-1) ~= "/" then dir = dir .. "/" end

		local handle = ffi.C.FindFirstFileA(dir .. "*", data)

		if ffi.cast("unsigned long", handle) ~= 0xffffffff then
			local i = 1

			while ffi.C.FindNextFileA(handle, data) do
				local name = ffi.string(data[0].cFileName)
				if not exclude_dot or (name ~= "." and name ~= "..") then
					out[i] = name
					i = i + 1
				end
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

	local flags = {
		archive = 0x20, -- A file or directory that is an archive file or directory. Applications typically use this attribute to mark files for backup or removal .
		compressed = 0x800, -- A file or directory that is compressed. For a file, all of the data in the file is compressed. For a directory, compression is the default for newly created files and subdirectories.
		device = 0x40, -- This value is reserved for system use.
		directory = 0x10, -- The handle that identifies a directory.
		encrypted = 0x4000, -- A file or directory that is encrypted. For a file, all data streams in the file are encrypted. For a directory, encryption is the default for newly created files and subdirectories.
		hidden = 0x2, -- The file or directory is hidden. It is not included in an ordinary directory listing.
		integrity_stream = 0x8000, -- The directory or user data stream is configured with integrity (only supported on ReFS volumes). It is not included in an ordinary directory listing. The integrity setting persists with the file if it's renamed. If a file is copied the destination file will have integrity set if either the source file or destination directory have integrity set.
		normal = 0x80, -- A file that does not have other attributes set. This attribute is valid only when used alone.
		not_content_indexed = 0x2000, -- The file or directory is not to be indexed by the content indexing service.
		no_scrub_data = 0x20000, -- The user data stream not to be read by the background data integrity scanner (AKA scrubber). When set on a directory it only provides inheritance. This flag is only supported on Storage Spaces and ReFS volumes. It is not included in an ordinary directory listing.
		offline = 0x1000, -- The data of a file is not available immediately. This attribute indicates that the file data is physically moved to offline storage. This attribute is used by Remote Storage, which is the hierarchical storage management software. Applications should not arbitrarily change this attribute.
		readonly = 0x1, -- A file that is read-only. Applications can read the file, but cannot write to it or delete it. This attribute is not honored on directories. For more information, see You cannot view or change the Read-only or the System attributes of folders in Windows Server 2003, in Windows XP, in Windows Vista or in Windows 7.
		reparse_point = 0x400, -- A file or directory that has an associated reparse point, or a file that is a symbolic link.
		sparse_file = 0x200, -- A file that is a sparse file.
		system = 0x4, -- A file or directory that the operating system uses a part of, or uses exclusively.
		temporary = 0x100, -- A file that is being used for temporary storage. File systems avoid writing data back to mass storage if sufficient cache memory is available, because typically, an application deletes a temporary file after the handle is closed. In that scenario, the system can entirely avoid writing the data. Otherwise, the data is written after the handle is closed.
		virtual = 0x10000, -- This value is reserved for system use.
	}

	local function flags_to_table(bits)
		local out = {}

		for k,v in pairs(flags) do
			out[k] = bit.bor(bits, v) == v
		end

		return out
	end

	local info = ffi.new("goluwa_file_attributes[1]")

	local COMBINE = function(hi, lo) return bit.band(bit.lshift(hi, 8), lo) end

	function fs.getattributes(path)
		if fs.debug then logn(path) end
		if ffi.C.GetFileAttributesExA(path, 0, info) then
			--local flags = flags_to_table(info[0].dwFileAttributes) -- overkill
			local type

			-- hmmm
			if --[[flags.archive]]
				bit.bor(info[0].dwFileAttributes, flags.archive) == flags.archive or
				bit.bor(info[0].dwFileAttributes, flags.normal) == flags.normal
			then
				type = "file"
			else
				type = "directory"

				-- GRRRR
				-- GRRRR
				local file = io.open(path, "r")
				if file then
					io.close(file)
					type = "file"
				end
				-- GRRRR
				-- GRRRR
			end

			local info = {
				creation_time = COMBINE(info[0].ftCreationTime.high, info[0].ftCreationTime.low),
				last_accessed = COMBINE(info[0].ftLastAccessTime.high, info[0].ftLastAccessTime.low),
				last_modified = COMBINE(info[0].ftLastWriteTime.high, info[0].ftLastWriteTime.low),
				last_changed = -1, -- last permission changes
				size = info[0].nFileSizeLow,--COMBINE(info[0].nFileSizeLow, info[0].nFileSizeHigh),
				type = type,
			---	flags = flags,
			}

			return info
		end
	end
else
	local S = require("syscall")

	local size = 4096*10
	local buf = S.t.buffer(size)

	function fs.find(dir, exclude_dot)
		local out = {}

		local fd, err = S.open(dir, "directory, rdonly")

		if fd then
			local iterator, err = fd:getdents(buf, size)

			local i = 1

			for info in iterator do
				if not exclude_dot or (info.name ~= "." and info.name ~= "..") then
					out[i] = info.name
					i = i + 1
				end
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
		S.mkdir(path, "rwxu")
	end

	--local cache = {}

	function fs.getattributes(path)
		--if cache[path] and cache[path].time < os.clock() then
		--	return cache[path].info
		--end

		local info = S.stat(path)

		--cache[path] = {time = os.clock() + 0.01}

		if info then
			local info = {
				last_accessed = info.access,
				last_changed = info.change,
				last_modified = info.modification,
				type = info.typename,
				size = info.size,
			}
			--cache[path].info = info
			return info
		end
	end
end


ffi.cdef([[
void *fopen(const char *filename, const char *mode);
size_t fread(void *ptr, size_t size, size_t nmemb, void *stream);
size_t fwrite(const void *ptr, size_t size, size_t nmemb, void *stream);
int fseek(void *stream, long offset, int whence);
long int ftell ( void * stream );
int fclose(void *fp);
int feof(void *stream);
]])

fs.open = ffi.C.fopen
fs.read = ffi.C.fread
fs.write = ffi.C.fwrite
fs.seek = ffi.C.fseek
fs.tell = ffi.C.ftell
fs.close = ffi.C.fclose
fs.eof = ffi.C.feof

return fs
