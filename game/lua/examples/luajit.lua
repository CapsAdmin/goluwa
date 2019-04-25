local sdl = require("SDL2")
local ffi = require("ffi")
local C = ffi.C


local serialize_code = [==[
local ffi = require("ffi")
ffi.cdef[[
void free(void *ptr);
void *malloc(size_t size);
]]

local msgpack = loadfile("]==].."/home/caps/goluwa/core/lua/modules/msgpack.lua"..[==[")()
local serialize = {}

function serialize.save(data)

	if type(data) == "function" then
		data = {str = string.dump(data), is_string_dumped = true}
	end

   local code = msgpack.encode(data)
   local sz = #code
   local code_p = ffi.cast('char*', ffi.C.malloc(sz)) -- ffi.C.malloc(sz+1))
   assert(code_p ~= nil, 'allocation error during serialization')
--   code_p[sz] = 0
   ffi.copy(code_p, ffi.cast('const char*', code), sz)
   return code_p, sz
end

function serialize.load(code_p, sz)
   local code = ffi.string(code_p, sz)
   ffi.C.free(ffi.cast('void*', code_p))
   local data = msgpack.decode(code)

	if type(data) == "table" and data.is_string_dumped then
		data = load(data.str)
	end

	return data
end

return serialize
]==]

local serialize = assert(loadstring(serialize_code))()

local worker_code = [==[
ffi.cdef([[

struct THCode {
  const char *data;
  int size;
};

struct THWorker {
  void *mutex;
  void *notfull;
  void *notempty;
  int head;
  int tail;
  int isempty;
  int isfull;
  int runningjobs;
  int maxjobs;

  struct THCode *callbacks;
  struct THCode *args;
};

]])

local serialize = (function() ]==]..serialize_code..[==[ end)()

local mt = {
   __index = {
      addjob =
         function(worker, callback, ...)
            sdl.LockMutex(worker.mutex)
            while worker.isfull == 1 do
               sdl.CondWait(worker.notfull, worker.mutex)
            end

            local args = {...}
            worker.callbacks[worker.tail].data, worker.callbacks[worker.tail].size = serialize.save(callback)
            worker.args[worker.tail].data, worker.args[worker.tail].size = serialize.save(args)

            worker.tail = worker.tail + 1
            if worker.tail == worker.maxjobs then
               worker.tail = 0
            end
            if worker.tail == worker.head then
               worker.isfull = 1
            end
            worker.isempty = 0

            worker.runningjobs = worker.runningjobs + 1

            sdl.UnlockMutex(worker.mutex)
            sdl.CondSignal(worker.notempty)
         end,

      dojob =
         function(worker)
            sdl.LockMutex(worker.mutex)
            while worker.isempty == 1 do
               sdl.CondWait(worker.notempty, worker.mutex)
            end
            local callback = serialize.load(worker.callbacks[worker.head].data, worker.callbacks[worker.head].size)
            local args = serialize.load(worker.args[worker.head].data, worker.args[worker.head].size)

            worker.head = worker.head + 1
            if worker.head == worker.maxjobs then
               worker.head = 0
            end
            if worker.head == worker.tail then
               worker.isempty = 1
            end
            worker.isfull = 0
            sdl.UnlockMutex(worker.mutex)
            sdl.CondSignal(worker.notfull)

            local res = {callback(unpack(args))} -- note: args is a table for sure

            sdl.LockMutex(worker.mutex)
            worker.runningjobs = worker.runningjobs - 1
            sdl.UnlockMutex(worker.mutex)

            return unpack(res)
         end
   },

   __gc = function(worker)
             ffi.C.free(worker.callbacks)
             ffi.C.free(worker.args)
          end
}
]==]

local __Worker = assert(loadstring([[
	local sdl = require("SDL2")
	local ffi = require("ffi")
	]] .. worker_code .. [[return ffi.metatype("struct THWorker", mt)]]
))()

local function Worker(N, callbackWorker)
   local worker = __Worker()
   worker.mutex = sdl.CreateMutex()
   worker.notfull = sdl.CreateCond()
   worker.notempty = sdl.CreateCond()
   worker.maxjobs = N

   worker.head = 0
   worker.tail = 0
   worker.isempty = 1
   worker.isfull = 0
   worker.runningjobs = 0

   worker.callbacks = C.malloc(ffi.sizeof('struct THCode')*N)
   worker.args = C.malloc(ffi.sizeof('struct THCode')*N)

   assert(worker.callbacks ~= nil, 'allocation errors for callback list')
   assert(worker.args ~= nil, 'allocation errors for argument list')

   return worker
end

local lua = require("luajit")
local LUA_GLOBALSINDEX = -10002;

local Threads = {__index=Threads, name="worker"}

setmetatable(Threads, Threads)

local function checkL(L, status)
   if not status then
      local msg = ffi.string(C.lua_tolstring(L, -1, nil))
      print(msg)
   end
end

function Threads:__call(N, ...)
   local self = {N=N, endcallbacks={n=0}, errors={}}
   local funcs = {...}
   local initres = {}

   setmetatable(self, {__index=Threads})

   self.mainworker = Worker(N)
   self.threadworker = Worker(N)

   self.threads = {}
   for i=1,N do
      local L = C.luaL_newstate()
      assert(L ~= nil, string.format('%d-th lua state creation failed', i))
      C.luaL_openlibs(L)

      for j=1,#funcs do
         local code_p, sz = serialize.save(funcs[j])
         if j < #funcs then
            checkL(L, C.luaL_loadstring(L, string.format([[
              local serialize = (function() ]]..serialize_code..[[ end)()
              local ffi = require 'ffi'
              local code = serialize.load(ffi.cast('const char*', %d), %d)
              code(%d)
            ]], tonumber(ffi.cast('intptr_t', code_p)), sz, i)))
         else
            checkL(L, C.luaL_loadstring(L, string.format([[
              local serialize = (function() ]]..serialize_code..[[ end)()
              local ffi = require 'ffi'
              local code = serialize.load(ffi.cast('const char*', %d), %d)
              __threadid = %d
              __workerinitres_p, __workerinitres_sz = serialize.save{code(%d)}
              __workerinitres_p = tonumber(ffi.cast('intptr_t', __workerinitres_p))
            ]], tonumber(ffi.cast('intptr_t', code_p)), sz, i, i)))
         end
         checkL(L, C.lua_pcall(L, 0, 0, 0) == 0)
      end

      C.lua_getfield(L, LUA_GLOBALSINDEX, '__workerinitres_p')
      local workerinitres_p = C.lua_tointeger(L, -1)
      C.lua_getfield(L, LUA_GLOBALSINDEX, '__workerinitres_sz')
      local workerinitres_sz = C.lua_tointeger(L, -1)
      C.lua_settop(L, -3)
      table.insert(initres, serialize.load(ffi.cast('const char*', workerinitres_p), workerinitres_sz))

      checkL(L, C.luaL_loadstring(L, [[
		local ffi = require("ffi")
		local sdl = pcall(require, "SDL2") and require("SDL2") or _G.SDL or loadfile("]]..R("lua/build/SDL2/SDL2.lua")..[[")()
		_G.SDL = sdl

		]]..worker_code..[[

		ffi.metatype("struct THWorker", mt)

		local function workerloop(data)
		 local workers = ffi.cast('struct THWorker**', data)
		 local mainworker = workers[0]
		 local threadworker = workers[1]
		 local threadid = __threadid

		 while __worker_running do
			local status, res, endcallbackid = threadworker:dojob()
			mainworker:addjob(function()
				return status, res, endcallbackid, threadid
			end)
		 end

			return 0
		end

		__worker_running = true
		__workerloop_ptr = tonumber(ffi.cast('intptr_t', ffi.cast('int (*)(void *)', workerloop)))
]]
) == 0)
      checkL(L, C.lua_pcall(L, 0, 0, 0) == 0)
      C.lua_getfield(L, LUA_GLOBALSINDEX, '__workerloop_ptr')
      local workerloop_ptr = C.lua_tointeger(L, -1)
      C.lua_settop(L, -2);

      local workers = ffi.new('struct THWorker*[2]', {self.mainworker, self.threadworker}) -- note: GCed
      local thread = sdl.CreateThread(ffi.cast('int(*)(void*)', workerloop_ptr), string.format("%s%.2d", Threads.name, i), workers)
      assert(thread ~= nil, string.format('%d-th thread creation failed', i))
      table.insert(self.threads, {thread=thread, L=L})
   end

   return self, initres
end

function Threads:dojob()
   local endcallbacks = self.endcallbacks
   local callstatus, args, endcallbackid, threadid = self.mainworker:dojob()
   if callstatus then
      local endcallstatus, msg = pcall(endcallbacks[endcallbackid], unpack(args))
      if not endcallstatus then
         table.insert(self.errors, string.format('[thread %d endcallback] %s', threadid, msg))
      end
   else
      table.insert(self.errors, string.format('[thread %d callback] %s', threadid, args[1]))
   end
   endcallbacks[endcallbackid] = nil
   endcallbacks.n = endcallbacks.n - 1
end

function Threads:addjob(callback, endcallback, ...) -- endcallback is passed with returned values of callback
   if #self.errors > 0 then self:synchronize() end -- if errors exist, sync immediately.
   local endcallbacks = self.endcallbacks

   -- first finish running jobs if any
   while self.mainworker.isempty ~= 1 do
      self:dojob()
   end

   -- now add a new endcallback in the list
   local endcallbackid = table.getn(endcallbacks)+1
   endcallbacks[endcallbackid] = endcallback or function() end
   endcallbacks.n = endcallbacks.n + 1

   local func = function(...)
      local res = {pcall(callback, ...)}
      local status = table.remove(res, 1)
      return status, res, endcallbackid
   end

   self.threadworker:addjob(func, ...)
end

function Threads:synchronize()

   while self.mainworker.runningjobs > 0 or self.threadworker.runningjobs > 0 or self.endcallbacks.n > 0 do
      self:dojob()
   end

   if #self.errors > 0 then
      local msg = string.format('\n%s', table.concat(self.errors, '\n'))
      self.errors = {}
      error(msg)
   end
end

function Threads:terminate()
   -- terminate the threads
   for i=1,self.N do
      self:addjob(function()
                     __worker_running = false
                  end)
   end

   -- terminate all jobs
   self:synchronize()

   -- wait for threads to exit (and free them)
   local pvalue = ffi.new('int[1]')
   for i=1,self.N do
      sdl.WaitThread(self.threads[i].thread, pvalue)
      C.lua_close(self.threads[i].L)
   end
end

local nthread = 4
local njob = 10
local msg = "hello from a satellite thread"
-- init the thread system
-- one lua state is created for each thread

-- the function takes several callbacks as input, which will be executed
-- sequentially on each newly created lua state
local threads = Threads(nthread,
                        -- typically the first callback requires modules
                        -- necessary to serialize other callbacks
                        function()
                           gsdl = (pcall(require, "SDL2") and require("SDL2")) or _G.SDL or loadfile("/home/caps/goluwa/framework/lua/build/SDL2/SDL2.lua")()
                        end,

                        -- other callbacks (one is enough in general!) prepare stuff
                        -- you need to run your program
                        function(idx)
                           print('starting a new thread/state number:', idx)
                           gmsg = msg -- we copy here an upvalue of the main thread
                        end)

-- now add jobs
local jobdone = 0
for i=1,njob do
   threads:addjob(
                  -- the job callback
                  function()
                     local id = tonumber(gsdl.threadID())
                     print(string.format('%s -- thread ID is %x', gmsg, id))

                     -- return a value to the end callback
                     return id
					end,

                  -- the end callback
                  -- ran in the main thread
                  function(id)
                     print(string.format("task %d finished (ran on thread ID %x)", i, id))

                     -- note that we can manipulate upvalues of the main thread
                     -- as this callback is ran in the main thread!
                     jobdone = jobdone + 1
                  end)
end

-- wait for all jobs to finish
threads:synchronize()

print(string.format('%d jobs done', jobdone))

-- of course, one can run more jobs if necessary!

-- terminate threads
threads:terminate()
