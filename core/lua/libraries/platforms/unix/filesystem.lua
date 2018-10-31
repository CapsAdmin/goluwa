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
	char *getcwd(char *buf, size_t size);
	int chdir (const char *filename);
	int mkdir (const char *filename, uint32_t mode);

	typedef struct DIR DIR;
	DIR *opendir(const char *name);
	struct dirent *readdir(DIR *dirp);
	int closedir(DIR *dirp);
	long syscall(int number, ...);
]])

fs.open = ffi.C.fopen
fs.read = ffi.C.fread
fs.write = ffi.C.fwrite
fs.seek = ffi.C.fseek
fs.tell = ffi.C.ftell
fs.close = ffi.C.fclose
fs.eof = ffi.C.feof

-- NOTE: 64bit version
if jit.os == "OSX" then
	ffi.cdef([[
		struct dirent {
			uint64_t d_ino;
			uint64_t d_seekoff;
			uint16_t d_reclen;
			uint16_t d_namlen;
			uint8_t  d_type;
			char     d_name[1024];
		};
	]])
else
	ffi.cdef([[
		struct dirent {
			uint64_t        d_ino;
			int64_t         d_off;
			unsigned short  d_reclen;
			unsigned char   d_type;
			char            d_name[256];
		};
	]])
end

function fs.find(name)
	local out = {}

	local ptr = ffi.C.opendir(name)

	if ptr == nil then
		return out
	end

	local i = 1
	while true do
		local dir_info = ffi.C.readdir(ptr)

		if dir_info == nil then break end

		local name = ffi.string(dir_info.d_name)

		if name ~= "." and name ~= ".." then
			out[i] = name
			i = i + 1
		end
	end

	ffi.C.closedir(ptr)

	return out
end

function fs.getcd()
	local temp = ffi.new("char[1024]")
	return ffi.string(ffi.C.getcwd(temp, ffi.sizeof(temp)))
end

function fs.setcd(path)
	return ffi.C.chdir(path)
end

function fs.createdir(path)
	return ffi.C.mkdir(path, 448) -- 0700
end

local stat

if jit.os == "OSX" then
	stat = ffi.typeof([[
		struct {
			uint32_t st_dev;
			uint16_t st_mode;
			uint16_t st_nlink;
			uint64_t st_ino;
			uint32_t st_uid;
			uint32_t st_gid;
			uint32_t st_rdev;
			// NOTE: these were `struct timespec`
			time_t   st_atime;
			long     st_atime_nsec;
			time_t   st_mtime;
			long     st_mtime_nsec;
			time_t   st_ctime;
			long     st_ctime_nsec;
			time_t   st_btime; // birth-time i.e. creation time
			long     st_btime_nsec;
			int64_t  st_size;
			int64_t  st_blocks;
			int32_t  st_blksize;
			uint32_t st_flags;
			uint32_t st_gen;
			int32_t  st_lspare;
			int64_t  st_qspare[2];
		}
	]])
else
	if jit.arch == "x64" then
		stat = ffi.typeof([[
			struct {
				uint64_t st_dev;
				uint64_t st_ino;
				uint64_t st_nlink;
				uint32_t st_mode;
				uint32_t st_uid;
				uint32_t st_gid;
				uint32_t __pad0;
				uint64_t st_rdev;
				int64_t  st_size;
				int64_t  st_blksize;
				int64_t  st_blocks;
				uint64_t st_atime;
				uint64_t st_atime_nsec;
				uint64_t st_mtime;
				uint64_t st_mtime_nsec;
				uint64_t st_ctime;
				uint64_t st_ctime_nsec;
				int64_t  __unused[3];
			}
		]])
	else
		stat = ffi.typeof([[
			struct {
				uint64_t st_dev;
				uint8_t  __pad0[4];
				uint32_t __st_ino;
				uint32_t st_mode;
				uint32_t st_nlink;
				uint32_t st_uid;
				uint32_t st_gid;
				uint64_t st_rdev;
				uint8_t  __pad3[4];
				int64_t  st_size;
				uint32_t st_blksize;
				uint64_t st_blocks;
				uint32_t st_atime;
				uint32_t st_atime_nsec;
				uint32_t st_mtime;
				uint32_t st_mtime_nsec;
				uint32_t st_ctime;
				uint32_t st_ctime_nsec;
				uint64_t st_ino;
			}
		]])
	end
end

local statbox = ffi.typeof("$[1]", stat)
local DIRECTORY = 0x4000
local STAT = jit.arch == "x64" and 4 or 195

function fs.getattributes(path)
	local buff = statbox()
	local ret = ffi.C.syscall(STAT, path, buff)
	if ret == 0 then
		return {
			last_accessed = tonumber(buff[0].st_atime),
			last_changed = tonumber(buff[0].st_ctime),
			last_modified = tonumber(buff[0].st_mtime),
			type = bit.band(buff[0].st_mode, DIRECTORY) ~= 0 and "directory" or "file",
			size = tonumber(buff[0].st_size),
		}
	end
	return false
end

return fs
