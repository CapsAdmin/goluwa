local ffi = require("ffi")
local lua = require("luajit")
local sdl = require("SDL2")

local message_type = "struct {uint8_t*to_ptr; size_t to_len; uint8_t*from_ptr; size_t from_len;} *"

local state = lua.L.newstate()
lua.L.openlibs(state)

local ok = lua.L.loadstring(state, [[
	local ffi = require("ffi")

	ffi.cdef("void* malloc(size_t size);")

	local main = function(data)
		local ok, msg = pcall(function()
			data = ffi.cast("]] .. message_type .. [[", data)

			local ret = load(ffi.string(data.to_ptr, data.to_len))(sdl)

			local ret_chars = ffi.C.malloc(#ret)
			ffi.copy(ret_chars, ret)

			data.from_ptr = ret_chars
			data.from_len = #ret
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
ffi.copy(func_chars, func_str)

local thread_func = ffi.cast("int (*)(void *)", lua.tointeger(state, -1))
local thread_data = ffi.cast(message_type, ffi.C.malloc(ffi.sizeof(message_type)))

thread_data.to_ptr = func_chars
thread_data.to_len = #func_str

thread_data.from_ptr = nil
thread_data.from_len = 0

local thread = sdl.CreateThread(thread_func, "test", ffi.cast("void *", thread_data))

event.AddListener("Update", "", function()
	if thread_data.from_ptr ~= nil then
		local status = ffi.new("int[1]")
		sdl.WaitThread(thread, status)

		local ret = ffi.string(thread_data.from_ptr, thread_data.from_len)

		print(ret, status[0])
		lua.close(state)

		return event.destroy_tag
	end
end)