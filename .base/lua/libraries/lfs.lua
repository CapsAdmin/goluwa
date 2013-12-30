ffi.cdef([[
	bool chdir(const char *path);
	char *getcwd(char *buf, size_t size);
]])

local LFS_MAXPATHLEN

if jit.os == "Windows" then
	LFS_MAXPATHLEN = 260
else
	LFS_MAXPATHLEN = 512 -- ????????????????
end

local lfs = {}

function lfs.chdir()
	if not ffi.C.chdir(path) then
		return nil, ("Unable to change working directory to '%s'\n%s\n"):format(path, "chdir_error")
	end
	
	return true
end

function lfs.currentdir()
	local buf = ffi.new("char[?]", LFS_MAXPATHLEN)
	local path = ffi.C.getcwd(buff, LFS_MAXPATHLEN)
	
	return ffi.string(path)
end

-- SNORE