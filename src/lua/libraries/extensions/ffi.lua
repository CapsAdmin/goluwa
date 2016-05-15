--_G.ffi = require("ffi")
local ffi = require("ffi")

ffi.cdef("char *strerror(int)")

function ffi.strerror()
	local num = ffi.errno()
	local err = ffi.string(ffi.C.strerror(num))
	return err == "" and tostring(num) or err
end

_OLD_G.ffi_load = _OLD_G.ffi_load or ffi.load

local ffi_new = ffi.new

function ffi.debug_gc(b)
	if b then
		ffi.new = ffi.new_dbg_gc
	else
		ffi.new = ffi_new
	end
end

function ffi.new_dbg_gc(...)
	local obj = ffi_new(...)
	ffi.gc(obj, function(...) logn("ffi debug gc: ", ...) end)
	return obj
end

local where = {
	"bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/",
	"lua/modules/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/",
}

-- make ffi.load search using our file system
ffi.load = function(path, ...)
	local args = {pcall(_OLD_G.ffi_load, path, ...)}

	if not args[1] then
		if system and system.SetSharedLibraryPath then
			if vfs then
				for _, where in ipairs(where) do
					for full_path in vfs.Iterate(where .. path, true) do
						-- look first in the vfs' bin directories
						local old = system.GetSharedLibraryPath()
						system.SetSharedLibraryPath(full_path:match("(.+/)"))
						local args = {pcall(_OLD_G.ffi_load, full_path, ...)}
						system.SetSharedLibraryPath(old)

						if args[1] then
							return select(2, unpack(args))
						end

						-- if not try the default OS specific dll directories
						args = {pcall(_OLD_G.ffi_load, full_path, ...)}
						if args[1] then
							return select(2, unpack(args))
						end
					end
				end
			end
		end

		return unpack(args)
	end

	return select(2, unpack(args))
end

ffi.cdef("void* malloc(size_t size); void free(void* ptr);")

function ffi.malloc(t, size)
	size = size * ffi.sizeof(t)

	return ffi.cast(t, ffi.gc(ffi.C.malloc(size), ffi.C.free))
end

local function warn_pcall(func, ...)
	local res = {pcall(func, ...)}
	if not res[1] then
		logn(res[2])
	end

	return unpack(res, 2)
end

-- ffi's cdef is so anti realtime
ffi.cdef = function(str, ...)
	return warn_pcall(_OLD_G.ffi.cdef, str, ...)
end

ffi.metatype = function(str, ...)
	return warn_pcall(_OLD_G.ffi.metatype, str, ...)
end