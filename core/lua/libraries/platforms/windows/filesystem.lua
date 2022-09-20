local fs = _G.fs or {}
local ffi = require("ffi")
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
	int FindNextFileA(void *handle, goluwa_find_data *find_data);
	int FindClose(void *);

	unsigned long GetCurrentDirectoryA(unsigned long length, char *buffer);
	int SetCurrentDirectoryA(const char *path);

	int CreateDirectoryA(const char *path, void *lpSecurityAttributes);

	typedef struct goluwa_file_attributes {
		unsigned long dwFileAttributes;
		goluwa_file_time ftCreationTime;
		goluwa_file_time ftLastAccessTime;
		goluwa_file_time ftLastWriteTime;
		unsigned long nFileSizeHigh;
		unsigned long nFileSizeLow;
	} goluwa_file_attributes;

	int GetFileAttributesExA(
	  const char *lpFileName,
	  int fInfoLevelId,
	  goluwa_file_attributes *lpFileInformation
	);

	long GetFileAttributesA(const char *);


	uint32_t GetLastError();
	uint32_t FormatMessageA(
		uint32_t dwFlags,
		const void* lpSource,
		uint32_t dwMessageId,
		uint32_t dwLanguageId,
		char* lpBuffer,
		uint32_t nSize,
		va_list *Arguments
	);
	
	int CreateSymbolicLinkA(const char *from, const char *to, int16_t flags);
	int CreateHardLinkA(const char *from, const char *to, void *lpSecurityAttributes);
	int CopyFileA(const char *from, const char *to, int fail_if_exists);
	int DeleteFileA(const char *path);
	int RemoveDirectoryA(const char *path);

]])
local error_str = ffi.new("uint8_t[?]", 1024)
local FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000

local FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200

local error_flags = bit.bor(FORMAT_MESSAGE_FROM_SYSTEM, FORMAT_MESSAGE_IGNORE_INSERTS)

local function error_string()
	local code = ffi.C.GetLastError()
	local numout = ffi.C.FormatMessageA(error_flags, nil, code, 0, error_str, 1023, nil)
	local err = numout ~= 0 and ffi.string(error_str, numout)

	if err and err:sub(-2) == "\r\n" then return err:sub(0, -3) end

	return err
end

local data = ffi.new("goluwa_find_data[1]")
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

	for k, v in pairs(flags) do
		out[k] = bit.bor(bits, v) == v
	end

	return out
end

local time_type = ffi.typeof("uint64_t *")
local ffi_cast = ffi.cast
local tonumber = tonumber
local POSIX_TIME = function(ptr)
	return tonumber(ffi_cast(time_type, ptr)[0] / 10000000 - 11644473600)
end

function fs.get_attributes(path)
	local info = ffi.new("goluwa_file_attributes[1]")

	if ffi.C.GetFileAttributesExA(path, 0, info) == 0 then
		return nil, error_string()
	end

	return {
		raw_info = info[0],
		creation_time = POSIX_TIME(info[0].ftCreationTime),
		last_accessed = POSIX_TIME(info[0].ftLastAccessTime),
		last_modified = POSIX_TIME(info[0].ftLastWriteTime),
		last_changed = -1, -- last permission changes
		size = info[0].nFileSizeLow,
		type = bit.band(info[0].dwFileAttributes, flags.directory) == flags.directory and
			"directory" or
			"file",
	}
end

do
	local info = ffi.new("goluwa_file_attributes[1]")

	function fs.get_type(path)
		if ffi.C.GetFileAttributesExA(path, 0, info) == 0 then return nil end

		return bit.band(info[0].dwFileAttributes, flags.directory) == flags.directory and
			"directory" or
			"file"
	end
end

do
	do
		local dot = string.byte(".")

		local function is_dots(ptr)
			if ptr[0] == dot then
				if ptr[1] == dot and ptr[2] == 0 then return true end

				if ptr[1] == 0 then return true end
			end

			return false
		end

		local FindFirstFileA = ffi.C.FindFirstFileA
		local FindClose = ffi.C.FindClose
		local FindNextFileA = ffi.C.FindNextFileA
		local ffi_cast = ffi.cast
		local ffi_string = ffi.string
		local INVALID_FILE = ffi.cast("void *", 0xffffffffffffffffULL)

		function fs.get_files(dir)
			if path == "" then path = "." end

			if dir:sub(-1) ~= "/" then dir = dir .. "/" end

			local handle = FindFirstFileA(dir .. "*", data)

			if handle == nil then return nil, error_string() end

			local out = {}

			if handle ~= INVALID_FILE then
				local i = 1

				repeat
					if not is_dots(data[0].cFileName) then
						out[i] = ffi_string(data[0].cFileName)
						i = i + 1
					end				
				until FindNextFileA(handle, data) == 0

				if FindClose(handle) == 0 then return nil, error_string() end
			end

			return out
		end

		local function walk(path, tbl, errors)
			local handle = FindFirstFileA(path .. "*", data)

			if handle == nil then
				table.insert(errors, {path = path, error = error_string()})
				return
			end

			tbl[tbl[0]] = path
			tbl[0] = tbl[0] + 1

			if handle ~= INVALID_FILE then
				local i = 1

				repeat
					if not is_dots(data[0].cFileName) then
						local name = path .. ffi_string(data[0].cFileName)

						if bit.band(data[0].dwFileAttributes, flags.directory) == flags.directory then
							walk(name .. "/", tbl, errors)
						else
							tbl[tbl[0]] = name
							tbl[0] = tbl[0] + 1
						end
					end				
				until FindNextFileA(handle, data) == 0

				if FindClose(handle) == 0 then return nil, error_string() end
			end

			return tbl
		end

		function fs.get_files_recursive(path)
			if path == "" then path = "." end

			if not path:sub(-1) ~= "/" then path = path .. "/" end

			local out = {}
			local errors = {}
			out[0] = 1

			if not walk(path, out, errors) then return nil, errors[1].error end

			out[0] = nil
			return out, errors[1] and errors or nil
		end
	end
end

function fs.get_current_directory()
	local buffer = ffi.new("char[260]")
	local length = ffi.C.GetCurrentDirectoryA(260, buffer)
	return ffi.string(buffer, length):gsub("\\", "/")
end

function fs.set_current_directory(path)
	if ffi.C.SetCurrentDirectoryA(path) == 0 then return nil, error_string() end

	return true
end

function fs.create_directory(path)
	if ffi.C.CreateDirectoryA(path, nil) == 0 then return nil, error_string() end

	return true
end

function fs.setcustomattribute(path, data)
	local f = io.open(path .. ":goluwa_attributes", "wb")

	if not f then return nil, err end

	f:write(data)
	f:close()
end

function fs.getcustomattribute(path)
	local f, err = io.open(path .. ":goluwa_attributes", "rb")

	if not f then return "" end

	local data = f:read("*all")
	f:close()
	return data
end

do
	local queue = {}

	function fs.watch(path, mask)
		local self = {}

		function self:Read() end

		function self:Remove() end

		return self
	end
end

function fs.link(from, to, symbolic)
	if ffi.C.CreateHardLinkA(to, from, nil) == 0 then
		return nil, error_string()
	end

	return true
end

function fs.copy(from, to)
	if ffi.C.CopyFileA(from, to, 1) == 0 then return nil, error_string() end

	return true
end

function fs.remove_file(path)
	if ffi.C.DeleteFileA(path) == 0 then return nil, error_string() end

	return true
end

function fs.remove_directory(path)
	if ffi.C.RemoveDirectoryA(path) == 0 then return nil, error_string() end

	return true
end

if RELOAD then  --print(fs.link("goluwa.cmd", "TEST", true))
end

return fs