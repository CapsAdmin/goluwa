local calllbacks = {}

for line in glfw.header:gmatch("(.-)\n") do
	local name = line:match("(glfwSet.-Callback)")
	if name then
		local nice = "On" .. name:match("glfwSet(.-)Callback")
		
		calllbacks[nice] = glfw.lib[name]
	end
end

calllbacks.OnError(function(code, str) logn("[glfw] ", ffi.string(str)) end)
calllbacks.OnError = nil

calllbacks.OnMonitor(function() events.Call("OnMonitorConnected") end)
calllbacks.OnMonitor = nil

do -- window meta
	local META = {}
	META.__index = META
	META.Type = "glfw window"

	function META:Remove()
		event.RemoveListener("OnUpdate", self)
		glfw.DestroyWindow(self.__ptr)
		utilities.MakeNULL(self)
	end

	function META:IsValid()
		return true
	end

	local x = ffi.new("int[1]")
	local y = ffi.new("int[1]")
	
	function META:GetSize()
		glfw.GetWindowSize(self.__ptr, x, y)
		return Vec2(x[0], y[0])
	end
		
	function META:SetSize(pos)
		glfw.SetWindowSize(self.__ptr, pos:Unpack())
	end

	function META:SetTitle(title)
		glfw.SetWindowTitle(self.__ptr, title)
	end
	
	local x, y = ffi.new("double[1]"), ffi.new("double[1]")
	
	function META:GetMousePos()
		glfw.GetCursorPos(self.__ptr, x, y)			
		return Vec2(x[0], y[0])
	end

	function META:SetMousePos(pos)
		glfw.SetCursorPos(self.__ptr, pos:Unpack())
	end

	function META:OnWindowFocus(b)
		self.focused = b
	end
	
	function META:HasFocus()
		return self.focused
	end
	
	function META:ShowCursor(b)
		if b then
			glfw.SetInputMode(self.__ptr, e.GLFW_CURSOR, e.GLFW_CURSOR_NORMAL)
		else
			glfw.SetInputMode(self.__ptr, e.GLFW_CURSOR, e.GLFW_CURSOR_HIDDEN)
		end
	end	

	function META:SetMouseTrapped(b)
		self.mouse_trapped = b
		glfw.SetInputMode(self.__ptr, e.GLFW_CURSOR, b and e.GLFW_CURSOR_DISABLED or e.GLFW_CURSOR_NORMAL)
	end

	function META:GetMouseDelta()
		return self.mouse_delta or Vec2()
	end
	
	local last
	 
	function META:UpdateMouseTrap(dt)
		local size = self:GetSize()
		local pos = self:GetMousePos()

		self.mouse_delta = (pos - (last or pos)) * dt * 25
		
		last = pos
	end


	function META:OnUpdate(dt)
		glfw.PollEvents()
		
		self:UpdateMouseTrap(dt)

		render.DrawScene(self)
	end
	
	function render.CreateWindow(width, height, title)	
		width = width or 680
		height = height or 440
		title = title or ""
		
		--glfw.WindowHint(e.GLFW_CONTEXT_VERSION_MAJOR, 4)
		--glfw.WindowHint(e.GLFW_CONTEXT_VERSION_MINOR, 3)
		glfw.WindowHint(e.GLFW_SAMPLES, 4)

		local ptr = glfw.CreateWindow(width, height, title, nil, nil)
		glfw.MakeContextCurrent(ptr)
		gl.Enable(e.GL_MULTISAMPLE)

		logn("glfw version: ", ffi.string(glfw.GetVersionString()))
		logf("opengl version: %s", render.GetVersion())
		
		-- this needs to be initialized once after a context has been created..
		if gl and gl.InitMiniGlew and not gl.gl_init then
			gl.InitMiniGlew()
			
			render.Initialize(width, height, title)
			
			gl.gl_init = true
		end
			
		local self = setmetatable({}, META)
		
		self.__ptr = ptr

		self.availible_callbacks = {}
		
		for nice, func in pairs(calllbacks) do
			self.availible_callbacks[nice] = nice		
			func(ptr, function(ptr, ...)
				if event.Call(nice, ...) ~= false and self[nice] then 
					self[nice](self, ...)
				end
			end)
		end
		
		event.AddListener("OnUpdate", self, nil, mmyy.OnError)
		
		local trigger = input.SetupInputEvent("Key")

		function self:OnKey(key, scancode, action, mods)
			if action == e.GLFW_REPEAT then return end
			
			trigger(glfw.KeyToString(key), action == e.GLFW_PRESS)
		end

		local trigger = input.SetupInputEvent("Mouse")

		function self:OnMouseButton(button, action, mods)
			trigger(glfw.MouseToString(button), action == e.GLFW_PRESS)
		end
		
		return self
	end 
end