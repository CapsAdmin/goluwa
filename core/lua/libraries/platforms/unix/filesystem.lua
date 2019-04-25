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

local S = require("syscall")

local size = 4096*64
local buf = S.t.buffer(size)

function fs.find(name)
	local out = {}

	local fd, err = S.open(name, "directory, rdonly")

	if not fd then
		print(fd, err)
		return {}
	end

	local get_dir_info, err = fd:getdents(buf, size)
	if not get_dir_info then
		fd:close()
		error(err)
	end

	local i = 1
	while true do
		local dir_info = get_dir_info()

		if not dir_info then break end

		if dir_info.name ~= "." and dir_info.name ~= ".." then
			out[i] = dir_info.name
			i = i + 1
		end
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
	return S.mkdir(path, "rwxu")
end

local buff = S.stat()

function fs.getattributes(path)
	buff = S.stat(path, buff)

	if buff then
		return {
			last_accessed = buff.access,
			last_changed = buff.change,
			last_modified = buff.modification,
			type = buff.typename,
			size = buff.size,
		}
	end

	return false
end

return fs