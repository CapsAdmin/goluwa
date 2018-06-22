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
]])

fs.open = ffi.C.fopen
fs.read = ffi.C.fread
fs.write = ffi.C.fwrite
fs.seek = ffi.C.fseek
fs.tell = ffi.C.ftell
fs.close = ffi.C.fclose
fs.eof = ffi.C.feof

local size = 4096*64
local buf = ffi.new("char[?]", size)


if jit.os == "OSX" then
	ffi.cdef([[
		struct dirent { // NOTE: 64bit version
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
		struct dirent { // NOTE: 64bit version
			uint64_t        d_ino;
			int64_t         d_off;
			unsigned short  d_reclen;
			unsigned char   d_type;
			char            d_name[256];
		};
	]])
end

ffi.cdef([[
	typedef struct DIR DIR;
	DIR *opendir(const char *name);
	struct dirent *readdir(DIR *dirp);
	int closedir(DIR *dirp);
]])

function fs.find(name)
	local out = {}

	local ptr = ffi.C.opendir(name)

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

if jit.os == "OSX" then
	ffi.cdef([[
		struct goluwa_stat {
		  dev_t           st_dev;
		  mode_t          st_mode;
		  nlink_t         st_nlink;
		  ino64_t         st_ino;
		  uid_t           st_uid;
		  gid_t           st_gid;
		  dev_t           st_rdev;
		  struct timespec st_atimespec;
		  struct timespec st_mtimespec;
		  struct timespec st_ctimespec;
		  struct timespec st_birthtimespec;
		  off_t           st_size;
		  blkcnt_t        st_blocks;
		  blksize_t       st_blksize;
		  uint32_t        st_flags;
		  uint32_t        st_gen;
		  int32_t         st_lspare;
		  int64_t         st_qspare[2];
		};
	]])
else
	ffi.cdef([[
		struct goluwa_stat {
		  unsigned long   st_dev;
		  unsigned long   st_ino;
		  unsigned long   st_nlink;
		  unsigned int    st_mode;
		  unsigned int    st_uid;
		  unsigned int    st_gid;
		  unsigned int    __pad0;
		  unsigned long   st_rdev;
		  long            st_size;
		  long            st_blksize;
		  long            st_blocks;
		  unsigned long   st_atime;
		  unsigned long   st_atime_nsec;
		  unsigned long   st_mtime;
		  unsigned long   st_mtime_nsec;
		  unsigned long   st_ctime;
		  unsigned long   st_ctime_nsec;
		  long            __unused[3];
		};
	]])
end

ffi.cdef([[
	long syscall(int number, ...);
]])

local DIRECTORY = 0x4000

function fs.getattributes(path)
	local buff = ffi.new("struct goluwa_stat[1]")

	if ffi.C.syscall(jit.arch == "x64" and 4 or 195, path, buff) == 0 then
		local buff = buff[0]

		return {
			last_accessed = tonumber(buff.st_atime),
			last_changed = tonumber(buff.st_ctime),
			last_modified = tonumber(buff.st_mtime),
			type = bit.band(buff.st_mode, DIRECTORY) ~= 0 and "directory" or "file",
			size = tonumber(buff.st_size),
		}
	end

	return false
end

return fs
