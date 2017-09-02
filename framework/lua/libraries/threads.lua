local ffi = require("ffi")
local lua = require("luajit")
local sdl = require("SDL2")

local threads = {}
threads.active = threads.active or {}

local META = prototype.CreateTemplate("thread")

function threads.CreateThread(on_start, on_finish)
	if type(on_start) == "string" then
		local func, err = loadstring(on_start)
		if not on_start then error(err, 2) end
		on_start = func
	end

	local self = META:CreateObject()

	if on_start then self.OnStart = on_start end
	if on_finish then self.OnFinish = function(_, ...) on_finish(...) end end

	if on_start then
		self:Start()
	end

	return self
end

ffi.cdef("void* malloc(size_t size); void *memcpy(void*, void*, size_t);")

local message_type = "struct {uint8_t*to_ptr; size_t to_len; uint8_t*from_ptr; size_t from_len; uint8_t from_ready;}"
local message_type_ptr = ffi.typeof(message_type .. "*")

local thread_init = [[
	local ffi = require("ffi")

	main = function(data)
		local ok, msg = pcall(function()
			_G.arg = {}
			THREAD = true
			loadfile("../../../core/lua/init.lua")()

			ffi.cdef("void* malloc(size_t size); void *memcpy(void*, void*, size_t);")

			data = ffi.cast("]] .. message_type .. [[ *", data)

			local tbl = serializer.Decode("msgpack", ffi.string(data.to_ptr, data.to_len))

			local tbl = {load(tbl.func_str)(nil, unpack(tbl.args))}

			local tbl_str = serializer.Encode("msgpack", tbl)
			local tbl_chars = ffi.C.malloc(#tbl_str)
			ffi.C.memcpy(tbl_chars, ffi.cast("uint8_t *", tbl_str), #tbl_str)

			data.from_ptr = tbl_chars
			data.from_len = #tbl_str

			data.from_ready = 1
		end)

		if not ok then
			io.write(msg)
			return 1
		end

		return 0
	end

	return tonumber(ffi.cast("intptr_t", ffi.cast("int (*)(void *)", main)))
]]

local sdl_thread_func = ffi.typeof("int (*)(void *)")

function META:Start(...)
	local state = lua.L.newstate()
	lua.L.openlibs(state)

	local ok = lua.L.loadstring(state, thread_init)

	if ok ~= 0 then
		local msg = ffi.string(lua.tolstring(state, -1, nil))
		lua.close(state)
		error(msg)
		return
	end

	lua.pcall(state, 0, 1, 0)

	local thread_func = ffi.cast(sdl_thread_func, lua.tointeger(state, -1))

	local thread_data = ffi.cast(message_type_ptr, ffi.C.malloc(ffi.sizeof(message_type)))

	local data_str = serializer.Encode("msgpack", {func_str = string.dump(self.OnStart), args = {...}})
	local data_chars = ffi.C.malloc(#data_str)
	ffi.C.memcpy(data_chars, ffi.cast("uint8_t *", data_str), #data_str)

	thread_data.to_ptr = data_chars
	thread_data.to_len = #data_str

	thread_data.from_ptr = nil
	thread_data.from_len = 0
	thread_data.from_ready = 0

	local thread = sdl.CreateThread(thread_func, "test", ffi.cast("void *", thread_data))
	sdl.DetachThread(thread)

	self.thread = thread
	self.state = state
	self.data = thread_data

	table.insert(threads.active, self)
end

event.AddListener("Update", "threads", function()
	for i, thread in ipairs(threads.active) do
		if thread.data.from_ready == 1 then
			local ret = serializer.Decode("msgpack", ffi.string(thread.data.from_ptr, thread.data.from_len))

			thread:OnFinish(unpack(ret))

			lua.close(thread.state)

			ffi.C.free(thread.data.to_ptr)
			ffi.C.free(thread.data.from_ptr)
			ffi.C.free(thread.data)

			table.remove(threads.active, i)
		end
	end
end)

function META:OnStart() end
function META:OnFinish() end

META:Register()

if RELOAD then
	P""
	local thread = threads.CreateThread()
	function thread:OnStart(a,b,c)
		print(a,b,c)
		return a+3,b+3,c+3
	end

	function thread:OnFinish(a,b,c)
		print(a,b,c)
	end
	thread:Start(1,2,3)
	P""
end

return threads