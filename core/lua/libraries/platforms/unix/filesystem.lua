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
	int closedir(DIR *dirp);
	long syscall(int number, ...);


	ssize_t read(int fd, void *buf, size_t count);

	struct inotify_event
	{
		int wd;
		uint32_t mask;
		uint32_t cookie;
		uint32_t len;
		char name [];
	};
	int inotify_init(void);
	int inotify_init1(int flags);
	int inotify_add_watch(int fd, const char *pathname, uint32_t mask);
	int inotify_rm_watch(int fd, int wd);

	static const uint32_t IN_MODIFY = 0x00000002;
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
		int stat64(const char *path, void *buf);
		typedef size_t time_t;
		struct dirent {
			uint64_t d_ino;
			uint64_t d_seekoff;
			uint16_t d_reclen;
			uint16_t d_namlen;
			uint8_t  d_type;
			char d_name[1024];
		};
		struct dirent *readdir(DIR *dirp) asm("readdir$INODE64");
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
		struct dirent *readdir(DIR *dirp) asm("readdir64");
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

if jit.os == "OSX" then
	stat = function(path, buff) return ffi.C.stat64(path, buff) end
else
	local enum = jit.arch == "x64" and 4 or 195
	stat = function(path, buff) return ffi.C.syscall(enum, path, buff) end
end

function fs.getattributes(path)
	local buff = statbox()
	local ret = stat(path, buff)

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

if jit.os ~= "OSX" then
	local flags = {
		access = 0x00000001, -- File was accessed
		modify = 0x00000002, -- File was modified
		attrib = 0x00000004, -- Metadata changed
		close_write = 0x00000008, -- Writtable file was closed
		close_nowrite = 0x00000010, -- Unwrittable file closed
		open = 0x00000020, -- File was opened
		moved_from = 0x00000040, -- File was moved from X
		moved_to = 0x00000080, -- File was moved to Y
		create = 0x00000100, -- Subfile was created
		delete = 0x00000200, -- Subfile was deleted
		delete_self = 0x00000400, -- Self was deleted
		move_self = 0x00000800, -- Self was moved
		unmount = 0x00002000, -- Backing fs was unmounted
		q_overflow = 0x00004000, -- Event queued overflowed
		ignored = 0x00008000, -- File was ignored
		onlydir = 0x01000000, -- only watch the path if it is a directory
		dont_follow = 0x02000000, -- don't follow a sym link
		excl_unlink = 0x04000000, -- exclude events on unlinked objects
		mask_create = 0x10000000, -- only create watches
		mask_add = 0x20000000, -- add to the mask of an already existing watch
		isdir = 0x40000000, -- event occurred against dir
		oneshot = 0x80000000, -- only send event once
	}
	local IN_NONBLOCK = 2048

	local fd = ffi.C.inotify_init1(IN_NONBLOCK)
	local max_length = 8192
	local length = ffi.sizeof("struct inotify_event")
	local buffer = ffi.new("char[?]", max_length)
	local queue = {}

	function fs.watch(path, mask)
		local wd = ffi.C.inotify_add_watch(fd, path, mask and utility.TableToFlags(mask, flags) or 4095)
		queue[wd] = {}

		local self = {}
		function self:Read()
			local len = ffi.C.read(fd, buffer, length)
			if len >= length then
				local res = ffi.cast("struct inotify_event*", buffer)
				table.insert(queue[res.wd], {
					cookie = res.cookie,
					name = ffi.string(res.name, res.len),
					flags = utility.FlagsToTable(res.mask, flags),
				})
			end

			if queue[wd][1] then
				return table.remove(queue[wd])
			end
		end

		function self:Remove()
			ffi.C.inotify_rm_watch(inotify_fd, wd)
			queue[wd] = nil
		end

		return self
	end
end

return fs
