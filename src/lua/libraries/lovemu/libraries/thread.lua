local love = ... or love

love.thread = {}

local threads = {}
local threads2 = {}

local Thread = {}
Thread.Type = "Thread"

function Thread:start() end
function Thread:wait() end
function Thread:set(key, val) self.vars[key] = val end
function Thread:send() end
function Thread:receive() end
function Thread:peek() end
function Thread:kill() end
function Thread:getName() return self.name end
function Thread:getKeys() return {} end
function Thread:get() return end
function Thread:demand(name) return self.vars[name] end

function love.thread.newThread(name, script_path)
	local self = lovemu.CreateObject(Thread)

	self.vars = {}

	local env = getfenv(2)
	local func = love.filesystem.load(script_path or name)
	local thread = tasks.CreateTask()
	function thread:OnStart()
		setfenv(func, env)
		self:Wait()
		func()
		self:Wait()
	end
	thread:Start()

	function thread:OnFinish()
		logn("[lovemu] thread ", name ," finished")
	end

	self.thread = thread
	threads[name] = self
	threads2[thread.co] = self

	self.name = name

	logn("[lovemu] creating thread ", name)

	return self
end

function love.thread.getThread(name)
	if not name then
		return threads2[coroutine.running()]
	end
	return threads[name]
end

function love.thread.getThreads()
	return threads
end