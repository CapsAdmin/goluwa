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

local META = {}
META.__index = META
META.Type = "glfw window"

function META:Remove()
	glfw.DestroyWindow(self.__ptr)
	utilities.MakeNULL(self)
end

function META:IsValid()
	return true
end

function META:GetSize()
	local x = ffi.new("int[1]")
	local y = ffi.new("int[1]")
	glfw.GetWindowSize(self.__ptr, x, y)
	
	return Vec2(x[0], y[0])
end

function Window(width, height, title)	
	width = width or 680
	height = height or 440
	title = title or ""

	glfw.WindowHint(e.GLFW_SAMPLES, 4)
	local ptr = glfw.CreateWindow(width, height, title, nil, nil)
	glfw.MakeContextCurrent(ptr)
	gl.Enable(e.GL_MULTISAMPLE)
	
	-- this needs to be initialized once after a context has been created..
	if gl and gl.InitMiniGlew and not gl.gl_init then
		gl.InitMiniGlew()	
		render.Initialize(width, height)		
		gl.gl_init = true
	end
	
	local self = setmetatable({}, META)
	
	self.__ptr = ptr

	self.availible_callbacks = {}
	
	for nice, func in pairs(calllbacks) do
		self.availible_callbacks[nice] = nice		
		func(ptr, function(ptr, ...)
			if self[nice] then 
				self[nice](...)
			end
		end)
	end
	
	return self
end 
