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

do

	ffi.cdef("void* malloc(size_t size); void free(void* ptr);")

	function ffi.malloc(t, size)
		size = size * ffi.sizeof(t)
		local ptr = ffi.gc(ffi.C.malloc(size), ffi.C.free)

		return ffi.cast(ffi.typeof("$ *", t), ptr), ptr
	end
end

do
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
end

local metatable_lookup = {}

function ffi.metatype(ct, meta)
	metatable_lookup[tostring((ct))] = meta
	return _OLD_G.ffi.metatype(ct, meta)
end

function ffi.getmetatable(ct)
	return metatable_lookup[tostring((ct))]
end