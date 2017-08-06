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
		ffi.gc = ffi.gc_dbg_gc
	else
		ffi.new = ffi_new
		ffi.gc = ffi.gc
	end
end

function ffi.gc_dbg_gc(cdata, finalizer)
	return ffi.gc(cdata, function(...) logn("ffi.gc: ", ...) return finalizer(...) end)
end

function ffi.new_dbg_gc(...)
	local obj = ffi_new(...)
	pcall(function() ffi.gc(obj, function(...) logn("ffi.new: ", ...) end) end)
	return obj
end

local where = {
	"bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/",
	"lua/modules/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/",
}


local function warn_pcall(func, ...)
	local res = {pcall(func, ...)}
	if not res[1] then
		logn(res[2]:trim())
	end

	return unpack(res, 2)
end

local function handle_stupid(path, clib, err, ...)
	if WINDOWS and clib then
		return setmetatable({}, {
			__index = function(s, k)
				if k == "Type" then return "ffi" end
				local ok, msg = pcall(function() return clib[k] end)
				if not ok then
					if  msg:find("cannot resolve symbol", nil, true)  then
						logf("[%s] could not find function %q in shared library\n", path, msg:match("cannot resolve symbol '(.-)': "))
						return nil
					else
						error(msg, 2)
					end
				end
				return msg
			end,
			__newindex = clib,
		})
	end
	return clib, err, ...
end

local function indent_error(str)
	local last_line
	str = "\n" .. str .. "\n"
	str = str:gsub("(.-\n)", function(line)
		line = "\t" .. line:trim() .. "\n"
		if line == last_line then
			return ""
		end
		last_line = line
		return line
	end)
	str= str:gsub("\n\n", "\n")
	return str
end

-- make ffi.load search using our file system
ffi.load = function(path, ...)
	local args = {pcall(_OLD_G.ffi_load, path, ...)}

	if WINDOWS and not args[1] then
		args = {pcall(_OLD_G.ffi_load, "lib" .. path, ...)}
	end

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
							return handle_stupid(path, select(2, unpack(args)))
						end

						-- if not try the default OS specific dll directories
						args = {pcall(_OLD_G.ffi_load, full_path, ...)}
						if args[1] then
							return handle_stupid(path, select(2, unpack(args)))
						end
					end
				end
			end
		end

		if system then
			args[2] = args[2] .. "\n" .. system.GetLibraryDependencies(path)
		end

		error(indent_error(args[2]), 2)
	end

	return handle_stupid(path, args[2])
end

ffi.cdef("void* malloc(size_t size); void free(void* ptr);")

function ffi.malloc(t, size)
	size = size * ffi.sizeof(t)
	local ptr = ffi.gc(ffi.C.malloc(size), ffi.C.free)

	return ffi.cast(ffi.typeof("$ *", t), ptr), ptr
end

local function warn_pcall(func, ...)
	local res = {pcall(func, ...)}
	if not res[1] then
		logn(res[2]:trim())
	end

	return unpack(res, 2)
end

function ffi.cdef(str, ...)
	return warn_pcall(_OLD_G.ffi.cdef, str, ...)
end

function ffi.metatype(str, ...)
	return warn_pcall(_OLD_G.ffi.metatype, str, ...)
end