local calllbacks = {}

if glfw then	
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
end

do -- window meta
	local META = {}
	META.__index = META
	META.Type = "context window"

	function META:Remove()
		if self.OnRemove then self:OnRemove() end
		event.RemoveListener("OnUpdate", self)
		if sdl then 	
			sdl.DestroyWindow(self.__ptr)
			render.sdl_windows[self.sdl_windowID] = nil
		else
			glfw.DestroyWindow(self.__ptr)
		end
		utilities.MakeNULL(self)
		
	end

	function META:IsValid()
		return true
	end

	local x = ffi.new("int[1]")
	local y = ffi.new("int[1]")
	
	function META:GetSize()
		if sdl then
			sdl.GetWindowSize(self.__ptr, x, y)
		else
			glfw.GetWindowSize(self.__ptr, x, y)
		end
		return Vec2(x[0], y[0])
	end
		
	function META:SetSize(pos)
		if sdl then
			sdl.SetWindowSize(self.__ptr, pos:Unpack())
		else
			glfw.SetWindowSize(self.__ptr, pos:Unpack())
		end
	end

	function META:SetTitle(title)
		if sdl then
			sdl.SetWindowTitle(self.__ptr, title)
		else
			glfw.SetWindowTitle(self.__ptr, title)
		end
	end
	
	local x, y = ffi.new(sdl and "int[1]" or "double[1]"), ffi.new(sdl and "int[1]" or "double[1]")
	
	function META:GetMousePos()
		if sdl then
			sdl.GetMouseState(x, y)
		else
			glfw.GetCursorPos(self.__ptr, x, y)			
		end
		return Vec2(x[0], y[0])
	end

	function META:SetMousePos(pos)
		if sdl then
			sdl.WarpMouseInWindow(self.__ptr, pos:Unpack())
		else
			glfw.SetCursorPos(self.__ptr, pos:Unpack())
		end
	end

	function META:OnWindowFocus(b)
		self.focused = b
	end
	
	function META:HasFocus()
		return self.focused
	end
	
	function META:ShowCursor(b)
		if sdl then
			sdl.ShowCursor(b and 1 or 0)
		else
			if b then
				glfw.SetInputMode(self.__ptr, e.GLFW_CURSOR, e.GLFW_CURSOR_NORMAL)
			else
				glfw.SetInputMode(self.__ptr, e.GLFW_CURSOR, e.GLFW_CURSOR_HIDDEN)
			end
		end
	end	

	function META:SetMouseTrapped(b)
		self.mouse_trapped = b
		
		if sdl then
			--sdl.SetWindowGrab(self.__ptr, b and 1 or 0)
			sdl.ShowCursor(e.SDL_DISABLE)
			sdl.SetRelativeMouseMode(b)
		else
			glfw.SetInputMode(self.__ptr, e.GLFW_CURSOR, b and e.GLFW_CURSOR_DISABLED or e.GLFW_CURSOR_NORMAL)
		end
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
	
	function META:OnWindowClose()
		self:Remove()
	end
	
	function META:OnCursorPos()
		if system then system.SetCursor(system.GetCursor()) end
	end
	
	function render.CreateWindow(width, height, title)	
		width = width or 800
		height = height or 600
		title = title or ""
		
		if glfw then
			--glfw.WindowHint(e.GLFW_CONTEXT_VERSION_MAJOR, 4)
			--glfw.WindowHint(e.GLFW_CONTEXT_VERSION_MINOR, 3)
			glfw.WindowHint(e.GLFW_SAMPLES, 4)
		end

		local ptr
		
		if sdl then
			sdl.Init(e.SDL_INIT_VIDEO)
			sdl.video_init = true

			ptr = sdl.CreateWindow(
				title, 
				e.SDL_WINDOWPOS_CENTERED, 
				e.SDL_WINDOWPOS_CENTERED,
				width, 
				height, 
				bit.bor(e.SDL_WINDOW_OPENGL, e.SDL_WINDOW_SHOWN, e.SDL_WINDOW_RESIZABLE)
			)
		else
			ptr = glfw.CreateWindow(width, height, title, nil, nil)
		end
		
		if sdl then
			sdl.GL_SetAttribute(e.SDL_GL_CONTEXT_MAJOR_VERSION, 4)
			sdl.GL_SetAttribute(e.SDL_GL_CONTEXT_MINOR_VERSION, 3)
			render.sdl_context = sdl.GL_CreateContext(ptr)			
			sdl.GL_MakeCurrent(ptr, render.sdl_context) 
			
			sdl.GL_SetSwapInterval(1)
		else
			glfw.MakeContextCurrent(ptr)
		end
		gl.Enable(e.GL_MULTISAMPLE)

		if sdl then
			logn("sdl version: ", ffi.string(sdl.GetRevision()))
		else
			logn("glfw version: ", ffi.string(glfw.GetVersionString()))
		end
		
		logf("opengl version: %s", render.GetVersion())
		
		-- this needs to be initialized once after a context has been created..
		if gl and gl.InitMiniGlew and not gl.gl_init then
			gl.InitMiniGlew()
			
			render.Initialize(width, height, title)
			
			gl.gl_init = true
		end
		
		if gl.SwapIntervalEXT then
			gl.SwapIntervalEXT(0)
		end
			
		local self = setmetatable({}, META)
		
		self.__ptr = ptr
		
		if sdl then
			local id = sdl.GetWindowID(ptr)
			self.sdl_windowID = id
			render.sdl_windows[id] = self
			
			local trigger = input.SetupInputEvent("Key")

			function self:OnKey(key, press, state, mod, scancode, repeat_, keysym)
				
				event.Call("OnKeyInputRepeat", key, press)
				
				if not repeat_ then 
					trigger(key, press)
				end
			end

			local trigger = input.SetupInputEvent("Mouse")

			function self:OnMouseButton(button, press, x, y)
				trigger("button_" .. button, press)
			end
			
		else
			self.availible_callbacks = {}
			
			for nice, func in pairs(calllbacks) do
				self.availible_callbacks[nice] = nice
				func(ptr, function(ptr, ...)
					if nice == "OnChar" then
						local char = utf8.char(...)
						if event.Call(nice, char) ~= false and self[nice] then
							self[nice](self, char)
						end
					else
						if event.Call(nice, ...) ~= false and self[nice] then
							self[nice](self, ...)
						end
					end
				end)
			end
			
			local trigger = input.SetupInputEvent("Key")

			function self:OnKey(key, scancode, action, mods)
				
				event.Call("OnKeyInputRepeat", glfw.KeyToString(key), action == e.GLFW_PRESS or action == e.GLFW_REPEAT)
				
				if action ~= e.GLFW_REPEAT then 
					trigger(glfw.KeyToString(key), action == e.GLFW_PRESS)
				end
			end

			local trigger = input.SetupInputEvent("Mouse")

			function self:OnMouseButton(button, action, mods)
				trigger(glfw.MouseToString(button), action == e.GLFW_PRESS)
			end
			
			function self:OnScroll(x, y)
				if y ~= 0 then
					for i = 1, math.abs(y) do
						if y > 0 then
							trigger("mwheel_up", true)
						else
							trigger("mwheel_down", true)
						end
					end
					
					timer.Delay(0, function()
						if y > 0 then
							trigger("mwheel_up", false)
						else
							trigger("mwheel_down", false)
						end
					end)
				end
				
				if x ~= 0 then	
					for i = 1, math.abs(x) do
						if x > 0 then
							trigger("mwheel_left", true)
						else
							trigger("mwheel_right", true)
						end
					end
					timer.Delay(0, function()
						if x > 0 then
							trigger("mwheel_left", false)
						else
							trigger("mwheel_right", false)
						end
					end)
				end
			end
			
			timer.Create("glfw_pollevents", 1/60, 0, function() glfw.PollEvents() end)
		end
		
		event.AddListener("OnUpdate", self, nil, mmyy.OnError)
		
		self.last_mpos = Vec2()
		self.mouse_delta = Vec2()
		
		timer.Delay(0, function()
			event.Call("OnFramebufferSize", self, width, height)
		end)
		
		return self
	end 
	
	if sdl then
		render.sdl_windows = render.sdl_windows or {}
		
		local function call(self, name, ...)
			if not self then return end --Shouldn't need this.. either way it doesn't work :(
			--print(self, name, ...)
			if event.Call(name, ...) ~= false and self[name] then
				self[name](self, ...)
			end
		end
		
		local event = ffi.new("SDL_Event")
		local key_trigger = input.SetupInputEvent("Key")
		local mouse_trigger = input.SetupInputEvent("Mouse")

		timer.Create("sdl_pollevents", 0, 0, function()
			if not sdl.video_init then return end
			
			while sdl.PollEvent(event) ~= 0 do
				local window 
				if event.window and event.window.windowID then
					window = render.sdl_windows[event.window.windowID]
				end
				if event.type == e.SDL_WINDOWEVENT then
					local case = event.window.event
					
					if case == e.SDL_WINDOWEVENT_SHOWN then
						call(window, "OnShow")
					elseif case == e.SDL_WINDOWEVENT_HIDDEN then
						call(window, "OnHide")
					elseif case == e.SDL_WINDOWEVENT_EXPOSED then
						call(window, "OnExpose")
					elseif case == e.SDL_WINDOWEVENT_MOVED then
						call(window, "OnMove", event.window.data1, event.window.data2)
					elseif case == e.SDL_WINDOWEVENT_RESIZED then
						call(window, "OnResize", event.window.data1, event.window.data2)
					elseif case == e.SDL_WINDOWEVENT_MINIMIZED then
						call(window, "OnMinimize")
					elseif case == e.SDL_WINDOWEVENT_MAXIMIZED then
						call(window, "OnMaximize");
					elseif case == e.SDL_WINDOWEVENT_RESTORED then
						call(window, "OnRestored")
					elseif case == e.SDL_WINDOWEVENT_ENTER then
						call(window, "OnMouseEnter")
					elseif case == e.SDL_WINDOWEVENT_LEAVE then
						call(window, "OnMouseLeave")
					elseif case == e.SDL_WINDOWEVENT_FOCUS_GAINED then
						call(window, "OnFocusGained")
					elseif case == e.SDL_WINDOWEVENT_FOCUS_LOST then
						call(window, "OnFocusLost")
					elseif case == e.SDL_WINDOWEVENT_CLOSE then
						call(window, "OnClose")
					end
				elseif event.type == e.SDL_KEYDOWN or event.type == e.SDL_KEYUP then
					local window = render.sdl_windows[event.key.windowID]
					
					call(window, "OnKey", ffi.string(sdl.GetKeyName(event.key.keysym.sym)):lower(), event.type == e.SDL_KEYDOWN, event.key.state, event.key.keysym.mod, ffi.string(sdl.GetScancodeName(event.key.keysym.scancode)):lower(), event.key["repeat"], event.key.keysym)
				elseif event.type == e.SDL_TEXTINPUT then
					local window = render.sdl_windows[event.edit.windowID]

					call(window, "OnChar", ffi.string(event.edit.text), event.edit.start, event.edit.length)
				elseif event.type == e.SDL_TEXTEDITING then
					local window = render.sdl_windows[event.text.windowID]

					call(window, "OnTextEditing", ffi.string(event.text.text))
				elseif event.type == e.SDL_MOUSEMOTION then
					local window = render.sdl_windows[event.motion.windowID]
					call(window, "OnMouseMotion", event.motion.x, event.motion.y, event.motion.xrel, event.motion.yrel, event.motion.state, event.motion.which)
				elseif event.type == e.SDL_MOUSEBUTTONDOWN or event.type == e.SDL_MOUSEBUTTONUP then
					local window = render.sdl_windows[event.button.windowID]
					call(window, "OnMouseButton", event.button.button, event.type == e.SDL_MOUSEBUTTONDOWN, event.button.x, event.button.y)
				end
			end
		end)
	end
end
