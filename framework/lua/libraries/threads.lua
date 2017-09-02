local ffi = require("ffi")
local lua = require("luajit")
local sdl = require("SDL2")

local threads = _G.threads or {}
threads.active = threads.active or {}


do -- thread safe queue
	local ffi = require("ffi")

	ffi.cdef([[
		void* malloc(size_t size);
		void *memcpy(void*, void*, size_t);
	]])

	local item = ffi.typeof([[
		struct {
			uint8_t *ptr;
			size_t len;
			uint8_t ready;
		}
	]])

	local queue = ffi.typeof([[
		struct {
			$ queue[1024];
			uint16_t i;
			uint16_t count;
		}
	]], item)

	local META = {}
	META.__index = META

	function META:Push(str)
		if self.count == 1024 then error("queue is full", 2) end

		local size = #str
		local buffer = ffi.C.malloc(size)
		ffi.C.memcpy(buffer, ffi.cast("uint8_t *", str), size)

		self.queue[self.count].ptr = buffer
		self.queue[self.count].len = size
		self.queue[self.count].ready = 1

		self.count = self.count + 1
	end

	function META:Pop()
		if self.count == 0 or self.count == 1024 then return end

		if self.queue[self.i].ready ~= 1 then return end

		local ptr = self.queue[self.i].ptr
		local len = self.queue[self.i].len

		self.i = self.i + 1
		self.count = self.count - 1

		if self.count == 0 then
			self.i = 0
		end

		return ffi.string(ptr, len)
	end

	function META:GetCount()
		return self.count
	end

	ffi.metatype(queue, META)

	local ctype = ffi.typeof("struct {$ thread; $ main;}", queue, queue)
	local ctype_ptr = ffi.typeof("$*", ctype)

	function threads.create_thread_queue(ptr)
		if ptr then
			return ffi.cast(ctype_ptr, ptr)
		end

		local ptr = ffi.C.malloc(ffi.sizeof(ctype))
		local q = ffi.cast(ctype_ptr, ptr)

		q.thread.count = 0
		q.thread.i = 0
		q.main.count = 0
		q.main.i = 0

		return q
	end
end

local META = prototype.CreateTemplate("thread")

function threads.CreateThread(on_start, ...)
	if type(on_start) == "string" then
		local func, err = loadstring(on_start)
		if not on_start then error(err, 2) end
		on_start = func
	end

	local self = META:CreateObject()

	if on_start then self.RunFunction = on_start end

	if on_start then
		self:Start(...)
	end

	return self
end

local thread_init = [[
	local ffi = require("ffi")

	main = function(userdata)
		local ok, msg = pcall(function()

			-- replace this with something more lightweight
			do -- we do this only to get threads
				THREAD = true
				GRAPHICS = false
				PHYSICS = false
				SOUND = false
				dofile("../../../core/lua/init.lua")
				vfs.MountAddon(e.ROOT_FOLDER .. "framework/")
				vfs.InitAddons()
			end

			local self = prototype.GetRegistered("thread"):CreateObject()

			local queues = threads.create_thread_queue(userdata)

			self.queues = queues
			self.send_queue = self.queues.main
			self.receive_queue = self.queues.thread

			-- first message is always the init
			local tbl = serializer.Decode("msgpack", self.receive_queue:Pop())

			load(tbl.func_str)(self, unpack(tbl.args))

			self:Remove()
		end)

		if not ok then
			io.write(msg)
			return 1
		end

		return 0
	end

	return tonumber(ffi.cast("intptr_t", ffi.cast("int (*)(void *)", main)))
]]

function META:Run(...)
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

	local thread_func = ffi.cast("int (*)(void *)", lua.tointeger(state, -1))

	local queues = threads.create_thread_queue()

	self.state = state
	self.queues = queues
	self.send_queue = self.queues.thread
	self.receive_queue = self.queues.main

	self.send_queue:Push(serializer.Encode("msgpack", {type = "init", func_str = string.dump(self.RunFunction), args = {...}}))

	local thread = sdl.CreateThread(thread_func, "luajit_thread", ffi.cast("void *", self.queues))
	sdl.DetachThread(thread)
	self.thread = thread

	table.insert(threads.active, self)
end

function META:Send(...)
	self.send_queue:Push(serializer.Encode("msgpack", {type = "msg", args = {...}}))
end

local function receive(self)
	if self.receive_queue:GetCount() ~= 0 then
		local str = self.receive_queue:Pop()
		if str then
			return serializer.Decode("msgpack", str)
		end
	end
end

function META:Receive()
	local tbl = receive(self)
	if tbl and tbl.type == "msg" then
		return unpack(tbl.args)
	end
end

function META:OnRemove()
	if self.thread then
		lua.close(self.state)
		ffi.C.free(self.queues)
		print("freed thread")
	else
		self.send_queue:Push(serializer.Encode("msgpack", {type = "kill"}))
	end
end

event.AddListener("Update", "threads", function()
	for i, thread in ipairs(threads.active) do
		local remove = false

		if thread:IsValid() then
			for i = 1, 1024 do
				local ret = receive(thread)

				if not ret then break end

				if ret.type == "msg" then
					thread:OnMessage(unpack(ret.args))
				elseif ret.type == "kill" then
					thread:Remove()
					break
				end
			end
		else
			remove = true
		end

		if remove or thread.remove_me then
			table.remove(threads.active, i)
		end
	end
end)

function META:RunFunction() end

META:Register()

if RELOAD then
	local thread = threads.CreateThread()

	function thread:RunFunction(a, b, c)
		-- thread env
		self:Send("test", "hello from thread", {1,2,3})
		print(a,b,c)
		print(self:Receive())

		self:Send("res", a+3, b+3, c+3)
		self:Send("res", a+3, b+3, c+3)

		while true do
			local one_last_message = self:Receive()
			if one_last_message then
				print(one_last_message)
				break
			end
		end
	end

	function thread:OnMessage(...)
		print(...)
		self:Send("got message")
	end

	thread:Run(1, 2, 3)
	thread:Send("hello from main", 888)

	--thread:Remove()
end

return threads