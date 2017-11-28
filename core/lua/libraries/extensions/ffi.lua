--_G.ffi = require("ffi")
local ffi = require("ffi")

ffi.cdef("char *strerror(int)")

function ffi.strerror()
	local num = ffi.errno()
	local err = ffi.string(ffi.C.strerror(num))
	return err == "" and tostring(num) or err
end

if DEBUG_GC then
	local hooked = table.weak()

	local real_gc = ffi.gc
	local real_new = ffi.new

	function ffi.gc(cdata, finalizer)
		hooked[cdata] = finalizer
		return cdata
	end

	function ffi.new(...)
		local obj = real_new(...)

		logn("ffi.new: ", ...)

		real_gc(obj, function(...)
			logn("ffi.gc: ", ...)

			if hooked[obj] then
				return hooked[obj](...)
			end
		end)

		return obj
	end

	local old = setmetatable
	function setmetatable(tbl, meta)
		if meta then
			local __gc = meta.__gc

			if __gc then
				function meta.__gc(...)
					logn("META:__gc: ", ...)

					local a,b,c = pcall(__gc, ...)

					logn("OK")

					return a,b,c
				end
			end
		end

		return old(tbl, meta)
	end
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
function ffi.load(path, ...)
	local args = {pcall(_OLD_G.ffi.load, path, ...)}

	if WINDOWS and not args[1] then
		args = {pcall(_OLD_G.ffi.load, "lib" .. path, ...)}
	end

	if not args[1] then
		if vfs and system and system.SetSharedLibraryPath then
			for _, where in ipairs(where) do
				for _, full_path in ipairs(vfs.GetFiles({path = where, filter = path, filter_plain = true, full_path = true})) do
					-- look first in the vfs' bin directories
					local old = system.GetSharedLibraryPath()
					system.SetSharedLibraryPath(full_path:match("(.+/)"))
					args = {pcall(_OLD_G.ffi.load, full_path, ...)}
					system.SetSharedLibraryPath(old)

					if args[1] then
						return handle_stupid(path, select(2, unpack(args)))
					end

					args[2] = args[2] .. "\n" .. system.GetLibraryDependencies(full_path)

					-- if not try the default OS specific dll directories
					args = {pcall(_OLD_G.ffi.load, full_path, ...)}
					if args[1] then
						return handle_stupid(path, select(2, unpack(args)))
					end

					args[2] = args[2] .. "\n" .. system.GetLibraryDependencies(full_path)
				end
			end

			error(indent_error(args[2]), 2)
		end
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

	return unpack(res)
end

function ffi.cdef(str, ...)
	return warn_pcall(_OLD_G.ffi.cdef, str, ...)
end

local metatable_lookup = {}

function ffi.metatype(ct, meta)
	metatable_lookup[tostring((ct))] = meta
	return _OLD_G.ffi.metatype(ct, meta)
end

function ffi.getmetatable(ct)
	return metatable_lookup[tostring((ct))]
end