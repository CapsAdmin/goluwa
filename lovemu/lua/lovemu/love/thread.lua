local love = (...) or _G.lovemu.love

love.thread = {}

local threads = {}

local Thread = {}
Thread.Type = "Thread"

function Thread:start() end
function Thread:wait() end
function Thread:set() end
function Thread:send() end
function Thread:receive() end
function Thread:peek() end
function Thread:kill() end
function Thread:getName() return self.name end
function Thread:getKeys() return {} end
function Thread:get() return end
function Thread:demand() return end

function love.thread.newThread(name)
	local self = lovemu.CreateObject(Thread)
	
	self.name = name
	
	return self
end

function love.thread.getThread(name)
	return threads[name]
end

function love.thread.getThreads()
	return threads
end