local love = (...) or _G.lovemu.love

local threads = {}

love.thread = {}

function love.thread.newThread(name)
	local obj = lovemu.NewObject("thread")
	
	threads[name] = obj
		
	function obj:start() end
	function obj:wait() end
	function obj:set() end
	function obj:send() end
	function obj:receive() end
	function obj:peek() end
	function obj:kill() end
	function obj:getName() return name end
	function obj:getKeys() return {} end
	function obj:get() return end
	function obj:demand() return end
		
	return obj
end

function love.thread.getThread(name)
	return threads[name]
end

function love.thread.getThreads()
	return threads
end