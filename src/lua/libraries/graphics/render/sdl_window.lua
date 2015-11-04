local ffi = require("ffi")
local gl = desire("graphics.ffi.opengl") -- OpenGL
local sdl = desire("graphics.ffi.sdl") -- window manager

if not gl or not sdl then return end

local render = (...) or _G.render

do -- window meta
	local META = prototype.CreateTemplate("render_window")

	function META:OnRemove()
		event.RemoveListener("OnUpdate", self)

		sdl.DestroyWindow(self.__ptr)
		render.sdl_windows[self.sdl_window_id] = nil
	end

	local x = ffi.new("int[1]")
	local y = ffi.new("int[1]")

	function META:GetPosition()
		sdl.GetWindowPosition(self.__ptr, x, y)
		return Vec2(x[0], y[0])
	end

	function META:SetPosition(pos)
		sdl.SetWindowPosition(self.__ptr, pos:Unpack())
	end

	function META:GetSize()
		sdl.GetWindowSize(self.__ptr, x, y)
		return Vec2(x[0], y[0])
	end

	function META:SetSize(pos)
		sdl.SetWindowSize(self.__ptr, pos:Unpack())
	end

	function META:SetTitle(title)
		sdl.SetWindowTitle(self.__ptr, title)
	end

	local x, y = ffi.new(sdl and "int[1]" or "double[1]"), ffi.new(sdl and "int[1]" or "double[1]")

	if sdl.GetGlobalMouseState then
		function META:GetMousePosition()
			if self.global_mouse then
				sdl.GetGlobalMouseState(x, y)
				return Vec2(x[0], y[0])
			else
				sdl.GetGlobalMouseState(x, y)
				return Vec2(x[0], y[0]) - self:GetPosition()
			end
		end
	else
		function META:GetMousePosition()
			sdl.GetMouseState(x, y)
			return Vec2(x[0], y[0])
		end
	end

	function META:SetMousePosition(pos)
		sdl.WarpMouseInWindow(self.__ptr, pos:Unpack())
	end

	function META:HasFocus()
		return self.focused
	end

	function META:ShowCursor(b)
		sdl.ShowCursor(b and 1 or 0)
		self.cursor_visible = b
	end

	function META:IsCursorVisible()
		return self.cursor_visible
	end

	function META:SetMouseTrapped(b)
		self.mouse_trapped = b

		sdl.SetWindowGrab(self.__ptr, b and 1 or 0)
		self:ShowCursor(not b)
		sdl.SetRelativeMouseMode(b and 1 or 0)

		self.mouse_trapped_start = true
	end

	function META:GetMouseTrapped()
		return self.mouse_trapped
	end

	function META:GetMouseDelta()
		if self.mouse_trapped_start then
			self.mouse_trapped_start = nil
			return Vec2()
		end
		if self.mouse_trapped then
			sdl.GetRelativeMouseState(x, y)
			return Vec2(x[0], y[0])
		end
		return self.mouse_delta or Vec2()
	end

	function META:UpdateMouseDelta()
		local pos = self:GetMousePosition()

		if self.last_mpos then
			self.mouse_delta = (pos - self.last_mpos)
		end

		self.last_mpos = pos
	end

	function META:MakeContextCurrent()
		sdl.GL_MakeCurrent(self.__ptr, render.gl_context)
	end

	function META:SwapBuffers()
		sdl.GL_SwapWindow(self.__ptr)
	end

	function META:SwapInterval(b)
		sdl.GL_SetSwapInterval(b and 1 or 0)
	end

	function META:OnUpdate(delta)

	end

	function META:OnFocus(focused)

	end

	function META:OnShow()

	end

	function META:OnClose()

	end

	function META:OnCursorPosition(x, y)

	end

	function META:OnFileDrop(paths)
		print(paths, "dropped!")
	end

	function META:OnCharInput(str)

	end

	function META:OnKeyInput(key, press)

	end

	function META:OnKeyInputRepeat(key, press)

	end

	function META:OnMouseInput(key, press)

	end

	function META:OnMouseScroll(x, y)

	end

	function META:OnCursorEnter()

	end

	function META:OnRefresh()

	end

	function META:OnFramebufferResized(width, height)

	end

	function META:OnMove(x, y)

	end

	function META:OnIconify()

	end

	function META:OnResize(width, height)

	end

	function META:OnTextEditing(str)

	end

	function META:IsFocused()
		return self.focused
	end

	prototype.Register(META)

	local flags_to_enums = {
		fullscreen = sdl.e.SDL_WINDOW_FULLSCREEN, -- fullscreen window
		fullscreen_desktop = sdl.e.SDL_WINDOW_FULLSCREEN_DESKTOP, -- fullscreen window at the current desktop resolution
--		opengl = sdl.e.SDL_WINDOW_OPENGL, -- window usable with OpenGL context
		hidden = sdl.e.SDL_WINDOW_HIDDEN, -- window is not visible
		borderless = sdl.e.SDL_WINDOW_BORDERLESS, -- no window decoration
		resizable = sdl.e.SDL_WINDOW_RESIZABLE, -- window can be resized
		minimized = sdl.e.SDL_WINDOW_MINIMIZED, -- window is minimized
		maximized = sdl.e.SDL_WINDOW_MAXIMIZED, -- window is maximized
		input_grabbed = sdl.e.SDL_WINDOW_INPUT_GRABBED, -- window has grabbed input focus
		allow_highdpi = sdl.e.SDL_WINDOW_ALLOW_HIGHDPI, -- window should be created in high-DPI mode if supported (>= SDL 2.0.1)
	}

	function render.CreateWindow(width, height, title, flags, reset_flags)
		width = width or 800
		height = height or 600
		title = title or ""

		if not render.gl_context then
			sdl.Init(sdl.e.SDL_INIT_VIDEO)
			sdl.video_init = true

			sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_MAJOR_VERSION, 3)
			sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_MINOR_VERSION, 3)
			sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_PROFILE_MASK, sdl.e.SDL_GL_CONTEXT_PROFILE_CORE)

			--sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_FLAGS, sdl.e.SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG)
			--sdl.GL_SetAttribute(sdl.e.SDL_GL_CONTEXT_PROFILE_MASK, sdl.e.SDL_GL_CONTEXT_PROFILE_COMPATIBILITY)
		end

		local bit_flags = bit.bor(sdl.e.SDL_WINDOW_OPENGL, sdl.e.SDL_WINDOW_SHOWN, sdl.e.SDL_WINDOW_RESIZABLE)

		if flags then
			bit_flags = sdl.e.SDL_WINDOW_OPENGL

			for k,v in pairs(flags) do
				bit_flags = bit.bor(bit_flags, flags_to_enums[v])
			end
		end

		local ptr = sdl.CreateWindow(
			title,
			sdl.e.SDL_WINDOWPOS_CENTERED,
			sdl.e.SDL_WINDOWPOS_CENTERED,
			width,
			height,
			bit_flags
		)

		if ptr == nil then
			error("sdl.CreateWindow failed: " .. ffi.string(sdl.GetError()), 2)
		end

		if not render.gl_context then
			local context = sdl.GL_CreateContext(ptr)

			if context == nil then
				error("sdl.GL_CreateContext failed: " .. ffi.string(sdl.GetError()), 2)
			end
			sdl.GL_MakeCurrent(ptr, context)

			llog("sdl version: %s", ffi.string(sdl.GetRevision()))

			-- this needs to be initialized once after a context has been created
			gl.GetProcAddress = sdl.GL_GetProcAddress

			gl.Initialize()

			if not gl.GetString then
				error("gl.Initialize failed! (gl.GetString not found)", 2)
			end

			render.gl_context = context
		end

		local self = prototype.CreateObject(META)

		self.last_mpos = Vec2()
		self.mouse_delta = Vec2()
		self.__ptr = ptr

		render.sdl_windows = render.sdl_windows or {}
		local id = sdl.GetWindowID(ptr)
		self.sdl_window_id = id
		render.sdl_windows[id] = self

		local event_name_translate = {}
		local key_translate = {
			left_ctrl = "left_control",
			["keypad_-"] = "kp_subtract",
			["keypad_+"] = "kp_add",
			["return"] = "enter",
		}
		for i = 1, 9 do
			key_translate["keypad_" .. i] = "kp_" .. i
		end

		local function call(self, name, ...)
			if not self then print(name, ...) return end

			if not event_name_translate[name] then
				event_name_translate[name] = name:gsub("^On", "Window")
			end

			local b

			if self[name] then
				if self[name](self, ...) ~= false then
					b = event.Call(event_name_translate[name], self, ...)
				end
			end

			return b
		end

		local event = ffi.new("SDL_Event")
		local mbutton_translate = {}
		for i = 1, 8 do mbutton_translate[i] = "button_" .. i end
		mbutton_translate[3] = "button_2"
		mbutton_translate[2] = "button_3"

		local suppress_char_input = false

		_G.event.AddListener("Update", self, function(dt)
			if not self:IsValid() or not sdl.video_init then
				sdl.PollEvent(event) -- this needs to be done or windows thinks the application froze..
				return
			end

			self.mouse_delta:Zero()
			self:UpdateMouseDelta()
			self:OnUpdate(dt)

			while sdl.PollEvent(event) ~= 0 do
				local window
				if event.window and event.window.windowID then
					window = render.sdl_windows[event.window.windowID]
				end

				if event.type == sdl.e.SDL_WINDOWEVENT and window then
					local case = event.window.event

					if case == sdl.e.SDL_WINDOWEVENT_SHOWN then
						call(window, "OnShow")
					elseif case == sdl.e.SDL_WINDOWEVENT_HIDDEN then
						call(window, "OnHide")
					elseif case == sdl.e.SDL_WINDOWEVENT_EXPOSED then
						call(window, "OnFramebufferResized", self:GetSize():Unpack())
					elseif case == sdl.e.SDL_WINDOWEVENT_SIZE_CHANGED then
						call(window, "OnFramebufferResized", event.window.data1, event.window.data2)
					elseif case == sdl.e.SDL_WINDOWEVENT_MOVED then
						call(window, "OnMove", event.window.data1, event.window.data2)
					elseif case == sdl.e.SDL_WINDOWEVENT_RESIZED then
						call(window, "OnResize", event.window.data1, event.window.data2)
						call(window, "OnFramebufferResized", event.window.data1, event.window.data2)
					elseif case == sdl.e.SDL_WINDOWEVENT_MINIMIZED then
						call(window, "OnMinimize")
					elseif case == sdl.e.SDL_WINDOWEVENT_MAXIMIZED then
						call(window, "OnResize", self:GetSize():Unpack())
						call(window, "OnFramebufferResized", self:GetSize():Unpack())
					elseif case == sdl.e.SDL_WINDOWEVENT_RESTORED then
						call(window, "OnRefresh")
					elseif case == sdl.e.SDL_WINDOWEVENT_ENTER then
						call(window, "OnCursorEnter", false)
					elseif case == sdl.e.SDL_WINDOWEVENT_LEAVE then
						call(window, "OnCursorEnter", true)
					elseif case == sdl.e.SDL_WINDOWEVENT_FOCUS_GAINED then
						call(window, "OnFocus", true)
						window.focused = true
					elseif case == sdl.e.SDL_WINDOWEVENT_FOCUS_LOST then
						call(window, "OnFocus", false)
						window.focused = false
					elseif case == sdl.e.SDL_WINDOWEVENT_CLOSE then
						call(window, "OnClose")
					else print("unknown window event", case) end
				elseif event.type == sdl.e.SDL_KEYDOWN or event.type == sdl.e.SDL_KEYUP then
					local window = render.sdl_windows[event.key.windowID]
					local key = ffi.string(sdl.GetKeyName(event.key.keysym.sym)):lower():gsub(" ", "_")

					key = key_translate[key] or key

					if event.key["repeat"] == 0 then
						if call(
							window,
							"OnKeyInput",
							key,
							event.type == sdl.e.SDL_KEYDOWN,

							event.key.state,
							event.key.keysym.mod,
							ffi.string(sdl.GetScancodeName(event.key.keysym.scancode)):lower(),
							event.key.keysym
						) == false then suppress_char_input = true return end
					end

					call(
						window,
						"OnKeyInputRepeat",
						key,
						event.type == sdl.e.SDL_KEYDOWN,

						event.key.state,
						event.key.keysym.mod,
						ffi.string(sdl.GetScancodeName(event.key.keysym.scancode)):lower(),
						event.key.keysym
					)
				elseif event.type == sdl.e.SDL_TEXTINPUT then
					if suppress_char_input then suppress_char_input = false return end
					local window = render.sdl_windows[event.edit.windowID]

					call(window, "OnCharInput", ffi.string(event.edit.text), event.edit.start, event.edit.length)
				elseif event.type == sdl.e.SDL_TEXTEDITING then
					local window = render.sdl_windows[event.text.windowID]

					call(window, "OnTextEditing", ffi.string(event.text.text))
				elseif event.type == sdl.e.SDL_MOUSEMOTION then
					local window = render.sdl_windows[event.motion.windowID]
					if window then
						self.mouse_delta.x = event.motion.xrel
						self.mouse_delta.y = event.motion.yrel
						call(window, "OnCursorPosition", event.motion.x, event.motion.y, event.motion.xrel, event.motion.yrel, event.motion.state, event.motion.which)
					end
				elseif event.type == sdl.e.SDL_MOUSEBUTTONDOWN or event.type == sdl.e.SDL_MOUSEBUTTONUP then
					local window = render.sdl_windows[event.button.windowID]
					call(window, "OnMouseInput", mbutton_translate[event.button.button], event.type == sdl.e.SDL_MOUSEBUTTONDOWN, event.button.x, event.button.y)
				elseif event.type == sdl.e.SDL_MOUSEWHEEL then
					local window = render.sdl_windows[event.button.windowID]
					call(window, "OnMouseScroll", event.wheel.x, event.wheel.y, event.wheel.which)
				elseif event.type == sdl.e.SDL_DROPFILE then
					for _, window in pairs(render.sdl_windows) do
						call(window, "OnFileDrop", ffi.string(event.drop.file))
					end
				elseif event.type == sdl.e.SDL_QUIT then
					system.ShutDown()
				else print("unknown event", event.type) end
			end
		end, {on_error = function(...) system.OnError(...) end})

		if not render.current_window:IsValid() then
			render.current_window = self
		end

		if not render.context_created then
			render.context_created = true
			render.Initialize()
		end

		return self
	end
end

function system.SetClipboard(str)
	sdl.SetClipboardText(tostring(str))
end

function system.GetClipboard()
	return ffi.string(sdl.GetClipboardText())
end

do
	local freq = tonumber(sdl.GetPerformanceFrequency())
	local start_time = sdl.GetPerformanceCounter()

	function system.GetTime()
		local time = sdl.GetPerformanceCounter()

		time = time - start_time

		return tonumber(time) / freq
	end
end

do

	local enums = {
		arrow = sdl.e.SDL_SYSTEM_CURSOR_ARROW,
		ibeam = sdl.e.SDL_SYSTEM_CURSOR_IBEAM,
		wait = sdl.e.SDL_SYSTEM_CURSOR_WAIT,
		crosshair = sdl.e.SDL_SYSTEM_CURSOR_CROSSHAIR,
		waitarrow = sdl.e.SDL_SYSTEM_CURSOR_WAITARROW,
		sizenwse = sdl.e.SDL_SYSTEM_CURSOR_SIZENWSE,
		sizenesw = sdl.e.SDL_SYSTEM_CURSOR_SIZENESW,
		sizewe = sdl.e.SDL_SYSTEM_CURSOR_SIZEWE,
		sizens = sdl.e.SDL_SYSTEM_CURSOR_SIZENS,
		sizeall = sdl.e.SDL_SYSTEM_CURSOR_SIZEALL,
		no = sdl.e.SDL_SYSTEM_CURSOR_NO,
		hand = sdl.e.SDL_SYSTEM_CURSOR_HAND,
	}

	local current
	local last
	local cache = {}

	function system.SetCursor(id)
		id = id or "arrow"

		cache[id] = cache[id] or sdl.CreateSystemCursor(enums[id] or enums.arrow)
		--if last ~= id then
			current = id
			sdl.SetCursor(cache[id])
		--	last = id
		--end
	end

	function system.GetCursor()
		return current
	end

end

do
	local cache = {}

	function render.IsExtensionSupported(str)
		if cache[str] == nil then
			cache[str] = sdl.GL_ExtensionSupported(str) == 1
		end

		return cache[str]
	end
end
