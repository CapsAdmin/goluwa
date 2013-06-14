glfw.Init()

local calllbacks = {}

for line in glfw.header:gmatch("(.-)\n") do
	local name = line:match("(glfwSet.-Callback)")
	if name then
		local nice = "On" .. name:match("glfwSet(.-)Callback")
		
		calllbacks[nice] = glfw.lib[name]
	end
end

calllbacks.OnError(function(code, str) logn(ffi.string(str)) end)
calllbacks.OnError = nil

calllbacks.OnMonitor(function() events.Call("OnMonitorConnected") end)
calllbacks.OnMonitor = nil

function Window(width, height, title)

	local window = glfw.CreateWindow(width or 680, height or 440, time or "", nil, nil)
	local obj = {Type = "glfw window"}

	obj.ptr = window	
	obj.availible_callbacks = {}
	
	for nice, func in pairs(calllbacks) do
		obj.availible_callbacks[nice] = nice		
		func(window, function(self, ...)
			if obj[nice] then 
				obj[nice](...)
			end
		end)
	end

	function obj:Remove()
		glfw.DestroyWindow(window)
		utilities.MakeNULL(self)
	end
	
	function obj:IsValid()
		return true
	end
	
	return obj
end 