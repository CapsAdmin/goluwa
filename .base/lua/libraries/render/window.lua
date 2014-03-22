local calllbacks = {}

for line in glfw.header:gmatch("(.-)\n") do
	local name = line:match("(glfwSet.-Callback)")
	
	if name then
		local nice = "On" .. name:match("glfwSet(.-)Callback")
		nice = nice:gsub("Window", "")		
		
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
	META.Type = "render_window"

	function META:Remove()
		if self.OnRemove then self:OnRemove() end
		
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
	
	local x, y = ffi.new(sdl and "int[1]" or "double[1]"), ffi.new(sdl and "int[1]" or "double[1]")
	
	function META:GetMousePos()
		glfw.GetCursorPos(self.__ptr, x, y)			
		return Vec2(x[0], y[0])
	end

	function META:SetMousePos(pos)
		glfw.SetCursorPos(self.__ptr, pos:Unpack())
	end

	function META:OnFocus(b)
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

	function META:GetMouseScrollDelta()
		
	end
		
	function META:GetMouseDelta()
		return self.mouse_delta or Vec2()
	end
		 
	function META:UpdateMouseDelta()	
		local pos = self:GetMousePos()
	
		if self.last_mpos then
			self.mouse_delta = (pos - self.last_mpos)
		end
		
		self.last_mpos = pos
		
		if self.mouse_trapped then
			--self:SetMousePos(self:GetSize() / 2)
		end
	end

	function META:OnUpdate(dt)
		self:UpdateMouseDelta()
		render.DrawScene(self, dt)
	end
	
	function META:OnClose()
		self:Remove()
	end
	
	function META:OnCursorPos()
		if system then system.SetCursor(system.GetCursor()) end
	end
	
	function render.CreateWindow(width, height, title)	
		width = width or 800
		height = height or 600
		title = title or ""
		
		--glfw.WindowHint(e.GLFW_CONTEXT_VERSION_MAJOR, 4)
		--glfw.WindowHint(e.GLFW_CONTEXT_VERSION_MINOR, 3)
		glfw.WindowHint(e.GLFW_SAMPLES, 4)

		local ptr = glfw.CreateWindow(width, height, title, nil, nil)
		glfw.MakeContextCurrent(ptr)
		
		gl.Enable(e.GL_MULTISAMPLE)

		logn("glfw version: ", ffi.string(glfw.GetVersionString()))
		logf("opengl version: %s", render.GetVersion())
		
		gl.GetProcAddress = glfw.GetProcAddress
		
		-- this needs to be initialized once after a context has been created..
		if gl and gl.InitMiniGlew and not gl.gl_init then
			gl.InitMiniGlew()
			render.Initialize(width, height, title)
			gl.gl_init = true
		end
					
		local self = setmetatable({}, META)
		
		self.last_mpos = Vec2()
		self.mouse_delta = Vec2()
						
		timer.Create("glfw_pollevents", 1/60, 0, function() glfw.PollEvents() end)
		
		event.AddListener("OnUpdate", self, nil, mmyy.OnError)
				
		timer.Delay(0, function()
			event.Call("OnFramebufferSize", self, width, height)
		end)
		
		self.__ptr = ptr
		
		do -- calllbacks
			self.availible_callbacks = {}
			
			local key_trigger = input.SetupInputEvent("Key")
			local mouse_trigger = input.SetupInputEvent("Mouse")

			for nice, func in pairs(calllbacks) do
				self.availible_callbacks[nice] = nice
				
				if nice == "OnChar" then			
					func(ptr, function(ptr, uint)
						local char = utf8.char(uint)
						if event.Call(nice, char) ~= false and self[nice] then
							self[nice](self, char)
						end
					end)					
				elseif nice == "OnKey" then
					func(ptr, function(ptr, key, scancode, action, mods)
						event.Call("OnKeyInputRepeat", glfw.KeyToString(key), action == e.GLFW_PRESS or action == e.GLFW_REPEAT)
						
						if action ~= e.GLFW_REPEAT then 
							local key, press = glfw.KeyToString(key), action == e.GLFW_PRESS
							if not self[nice] or self[nice](key, press) ~= false then
								key_trigger(key, press)
							end
						end
					end)
				elseif nice == "OnMouseButton" then
					func(ptr, function(ptr, button, action, mods)
						local button, press = glfw.MouseToString(button), action == e.GLFW_PRESS
						if not self[nice] or self[nice](key, press) ~= false then
							mouse_trigger(button, press)
						end
					end)
				elseif nice == "OnScroll" then
					func(ptr, function(ptr, x, y)
						if self[nice] and self[nice](x, y) == false then return end
						
						if y ~= 0 then
							for i = 1, math.abs(y) do
								if y > 0 then
									mouse_trigger("mwheel_up", true)
								else
									mouse_trigger("mwheel_down", true)
								end
							end
							
							timer.Delay(0, function()
								if y > 0 then
									mouse_trigger("mwheel_up", false)
								else
									mouse_trigger("mwheel_down", false)
								end
							end)
						end
						
						if x ~= 0 then	
							for i = 1, math.abs(x) do
								if x > 0 then
									mouse_trigger("mwheel_left", true)
								else
									mouse_trigger("mwheel_right", true)
								end
							end
							timer.Delay(0, function()
								if x > 0 then
									mouse_trigger("mwheel_left", false)
								else
									mouse_trigger("mwheel_right", false)
								end
							end)
						end
					end)
				else
					func(ptr, function(ptr, ...)
						if event.Call(nice, ...) ~= false and self[nice] then
							self[nice](self, ...)
						end
					end)
				end
			end
		end
		
		return self
	end
end
