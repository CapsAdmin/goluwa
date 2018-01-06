local ffi = require("ffi")
local lua = require("luajit")
local sdl = require("SDL2")

ffi.cdef("void* malloc(size_t size); void *memcpy(void*, void*, size_t);")

local message_type = "struct {uint8_t*to_ptr; size_t to_len; uint8_t*from_ptr; size_t from_len; uint8_t from_ready;}"

local state = lua.L.newstate()
lua.L.openlibs(state)

local ok = lua.L.loadstring(state, [[
	local ffi = require("ffi")

	ffi.cdef("void* malloc(size_t size); void *memcpy(void*, void*, size_t);")

	main = function(data)
		local ok, msg = pcall(function()
			data = ffi.cast("]] .. message_type .. [[ *", data)

			local ret = load(ffi.string(data.to_ptr, data.to_len))(sdl)

			local ret_chars = ffi.C.malloc(#ret)
			ffi.C.memcpy(ret_chars, ffi.cast("uint8_t *", ret), #ret)

			data.from_ptr = ret_chars
			data.from_len = #ret
			data.from_ready = 1
		end)

		if not ok then
			io.write(msg)
			return 1
		end

		return 0
	end

	return tonumber(ffi.cast("intptr_t", ffi.cast("int (*)(void *)", main)))
]])

if ok ~= 0 then
	print(ffi.string(lua.tolstring(state, -1, nil)))
	lua.close(state)
	return
end

lua.pcall(state, 0, 1, 0)

local thread_func = ffi.cast("int (*)(void *)", lua.tointeger(state, -1))

local func_str = [[
	local sleep = os.clock() + 1
	while true do
		if os.clock() > sleep then
			break
		end
	end

	print("a")

	return "hello from thread"
]]
local func_chars = ffi.C.malloc(#func_str)
ffi.C.memcpy(func_chars, ffi.cast("uint8_t *", func_str), #func_str)

local thread_data = ffi.cast(message_type .. "*", ffi.C.malloc(ffi.sizeof(message_type)))

thread_data.to_ptr = func_chars
thread_data.to_len = #func_str

thread_data.from_ptr = nil
thread_data.from_len = 0
thread_data.from_ready = 0

local thread = sdl.CreateThread(thread_func, "test", ffi.cast("void *", thread_data))
sdl.DetachThread(thread)

event.AddListener("Update", thread, function()
	if thread_data.from_ready == 1 then
		local ret = ffi.string(thread_data.from_ptr, thread_data.from_len)

		print(ret)

		lua.close(state)

		ffi.C.free(thread_data.to_ptr)
		ffi.C.free(thread_data.from_ptr)
		ffi.C.free(thread_data)

		return event.destroy_tag
	end
end)