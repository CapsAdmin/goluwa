local sdl = desire("SDL2")
if not sdl then return end

local ffi = require("ffi")

local META = ... or prototype.GetRegistered("window")

local flags_to_enums = {}

for k,v in pairs(sdl.e) do
	local friendly = k:match("WINDOW_(.+)")
	if friendly then
		friendly = friendly:lower()
		flags_to_enums[friendly] = v
	end
end

sdl.windowobjects = sdl.windowobjects or {}

function META:Initialize()
	if not sdl.video_init then
		if WINDOWS then
			ffi.cdef("int SetProcessDPIAware();")
			ffi.C.SetProcessDPIAware()
		end

		sdl.Init(sdl.e.INIT_VIDEO)
		sdl.SetHint(sdl.e.HINT_MOUSE_FOCUS_CLICKTHROUGH, "1")
		sdl.video_init = true
	end

	local flags = self.Flags or {"shown", "resizable"}

	self:PreWindowSetup(flags)

	local bit_flags = 0

	for _, v in pairs(flags) do
		bit_flags = bit.bor(bit_flags, tonumber(flags_to_enums[v]))
	end

	local display_info = ffi.new("struct SDL_DisplayMode[1]")
	sdl.GetCurrentDisplayMode(0, display_info)

	local w, h = self.Size:Unpack() -- todo

	if w == 0 then
		w = display_info[0].w
	end

	if h == 0 then
		h = display_info[0].h
	end

	local wnd_ptr = sdl.CreateWindow(self.Title or "", sdl.e.WINDOWPOS_CENTERED, sdl.e.WINDOWPOS_CENTERED, w, h, bit_flags)

	if wnd_ptr == nil then
		error("sdl.CreateWindow failed: " .. ffi.string(sdl.GetError()), 2)
	end

	self.wnd_ptr = wnd_ptr

	self:PostWindowSetup(self.wnd_ptr)

	if not system.disable_window then
		self:AddEvent("Update")
		self:AddEvent("FrameEnd")
	end

	self.sdl_windowid = sdl.GetWindowID(self.wnd_ptr)

	sdl.windowobjects[self.sdl_windowid] = self

	llog("version: %s", ffi.string(sdl.GetRevision()))
end

function META:OnFrameEnd()
	sdl.PumpEvents()
	self:SwapBuffers()
end

do
	local key_translate = {
		["left_ctrl"] = "left_control",
		["keypad_-"] = "kp_subtract",
		["keypad_+"] = "kp_add",
		["return"] = "enter",
	}
	for i = 1, 9 do
		key_translate["keypad_" .. i] = "kp_" .. i
	end

	local mbutton_translate = {}
	for i = 1, 8 do
		mbutton_translate[i] = "button_" .. i
	end
	mbutton_translate[3] = "button_2"
	mbutton_translate[2] = "button_3"

	local suppress_char_input = false

	local max = 20
	local events = ffi.new("union SDL_Event[?]", max)

	function META:OnUpdate(dt)
		self:UpdateMouseDelta()
		self:OnPostUpdate(dt)

		if self.Cursor == "trapped" and self:IsFocused() then
			local pos = self:GetMousePosition()
			local size = self:GetSize()
			local changed = false

			if pos.x <= 1 then pos.x = size.x-2 changed = true end
			if pos.y <= 1 then pos.y = size.y-2 changed = true end

			if pos.x >= size.x-1 then pos.x = 2 changed = true end
			if pos.y >= size.y-1 then pos.y = 2 changed = true end

			if changed then
				self.last_mpos = pos
				self:SetMousePosition(pos)
			end
		end

		local count = sdl.PeepEvents(events, max, "SDL_GETEVENT", sdl.e.FIRSTEVENT, sdl.e.LASTEVENT)

		for i = 0, count - 1 do
			local events = events[i]
			local case = events.window.event

			if events.window.windowID == self.sdl_windowid then
				if case == sdl.e.WINDOWEVENT_MOVED then
					self.cached_pos = nil
					self:CallEvent("PositionChanged", Vec2(events.window.data1, events.window.data2))

				elseif case == sdl.e.WINDOWEVENT_RESIZED or case == sdl.e.WINDOWEVENT_SIZE_CHANGED then
					self.cached_size = nil
					self.cached_fb_size = nil
					self:CallEvent("SizeChanged", Vec2(events.window.data1, events.window.data2))
					self:CallEvent("FramebufferResized", Vec2(events.window.data1, events.window.data2))

				elseif case == sdl.e.WINDOWEVENT_MINIMIZED then
					self:CallEvent("Minimize")

				elseif case == sdl.e.WINDOWEVENT_MAXIMIZED then
					self:CallEvent("Maximize")

				elseif case == sdl.e.WINDOWEVENT_ENTER then
					self:CallEvent("CursorEnter")

				elseif case == sdl.e.WINDOWEVENT_LEAVE then
					self:CallEvent("CursorLeave")

				elseif case == sdl.e.WINDOWEVENT_EXPOSED then
					self:CallEvent("GainedFocus")
					self.Focused = true

				elseif case == sdl.e.WINDOWEVENT_LEAVE then
					self:CallEvent("LostFocus")
					self.Focused = false
print("!!!")
				elseif case == sdl.e.WINDOWEVENT_CLOSE then
					self:CallEvent("Close")

				elseif events.type == sdl.e.KEYDOWN or events.type == sdl.e.KEYUP then
					local key = ffi.string(sdl.GetKeyName(events.key.keysym.sym)):lower():gsub(" ", "_")

					key = key_translate[key] or key

					if events.key["repeat"] == 0 then
						if
							self:CallEvent(
								"KeyInput",
								key,
								events.type == sdl.e.KEYDOWN,

								events.key.state,
								events.key.keysym.mod,
								ffi.string(sdl.GetScancodeName(events.key.keysym.scancode)):lower(),
								events.key.keysym
							) == false
						then
							suppress_char_input = true
							return
						end
					end

					self:CallEvent(
						"KeyInputRepeat",
						key,
						events.type == sdl.e.KEYDOWN,

						events.key.state,
						events.key.keysym.mod,
						ffi.string(sdl.GetScancodeName(events.key.keysym.scancode)):lower(),
						events.key.keysym
					)
				elseif events.type == sdl.e.TEXTINPUT then
					if suppress_char_input then
						suppress_char_input = false
						return
					end

					self:CallEvent("CharInput", ffi.string(events.edit.text), events.edit.start, events.edit.length)

				elseif events.type == sdl.e.MOUSEBUTTONDOWN or events.type == sdl.e.MOUSEBUTTONUP then
					self:CallEvent("MouseInput", mbutton_translate[events.button.button], events.type == sdl.e.MOUSEBUTTONDOWN, events.button.x, events.button.y)

				elseif events.type == sdl.e.MOUSEWHEEL then
					self:CallEvent("MouseScroll", Vec2(events.wheel.x, events.wheel.y), events.wheel.which)

				elseif events.type == sdl.e.DROPFILE then
					self:CallEvent("Drop", ffi.string(events.drop.file))

				else
					--[[print("unknown event", events.type)]]
				end
			end
		end

		if count == max then
			max = max + 1
			events = ffi.new("union SDL_Event[?]", max)
			--llog("max events increased: ", max)
		end
	end
end

function META:OnRemove()
	sdl.DestroyWindow(self.wnd_ptr)
end

function META:Maximize()
	sdl.MaximizeWindow(self.wnd_ptr)
end
function META:Minimize()
	sdl.MinimizeWindow(self.wnd_ptr)
end
function META:Restore()
	sdl.RestoreWindow(self.wnd_ptr)
end


do
	local enums = {
		arrow = sdl.e.SYSTEM_CURSOR_ARROW,
		text_input = sdl.e.SYSTEM_CURSOR_IBEAM,
		crosshair = sdl.e.SYSTEM_CURSOR_CROSSHAIR,
		hand = sdl.e.SYSTEM_CURSOR_HAND,
		horizontal_resize = sdl.e.SYSTEM_CURSOR_SIZEWE,
		vertical_resize = sdl.e.SYSTEM_CURSOR_SIZENS,
	}

	local last
	local cache = {}

	function META:SetCursor(mode)
		if not self.Cursors[mode] then
			mode = "arrow"
		end

		self.Cursor = mode

		if mode == "trapped" then
			if last ~= mode then
				--sdl.ShowCursor(0)
				--sdl.SetWindowGrab(self.wnd_ptr, 1)
				sdl.SetRelativeMouseMode(1)
				last = mode
			end
		elseif mode == "none" then
			if last ~= mode then
				sdl.ShowCursor(0)
				sdl.SetRelativeMouseMode(0)
				last = mode
			end
		else
			cache[mode] = cache[mode] or sdl.CreateSystemCursor(enums[mode] or enums.arrow)

			if last ~= mode then
				sdl.ShowCursor(1)
				sdl.SetCursor(cache[mode])
				sdl.SetRelativeMouseMode(0)
				last = mode
			end
		end
	end
end

function META:GetPosition()
	if not self.cached_pos then
		local x, y = ffi.new("int[1]"), ffi.new("int[1]")
		sdl.GetWindowPosition(self.wnd_ptr, x, y)
		local pos = Vec2(x[0], y[0])

		self.cached_pos = pos
	end

	return self.cached_pos
end

function META:SetPosition(pos)
	self.cached_pos = nil
	sdl.SetWindowPosition(self.wnd_ptr, pos:Unpack())
end

function META:GetSize()
	if not self.cached_size then
		local x, y = ffi.new("int[1]"), ffi.new("int[1]")
		sdl.GetWindowSize(self.wnd_ptr, x, y)
		local size = Vec2(x[0], y[0])
		if size.x == 0 then debug.trace() end
		self.cached_size = size
	end

	return self.cached_size
end

function META:SetSize(size)
	self.cached_size = nil
	self.cached_fb_size = nil
	sdl.SetWindowSize(self.wnd_ptr, size:Unpack())
end

function META:GetFramebufferSize()
	if not self.cached_fb_size then
		local x, y = ffi.new("int[1]"), ffi.new("int[1]")
		SDL.GL_GetDrawableSize(self.wnd_ptr, x, y)
		self.cached_fb_size = Vec2(x[0], y[0])
	end

	return self.cached_fb_size
end
function META:SetTitle(title)
	sdl.SetWindowTitle(self.wnd_ptr, tostring(title))
end

if sdl.GetGlobalMouseState and os.getenv("SDL_VIDEODRIVER") ~= "wayland" then
	local x, y = ffi.new("int[1]"), ffi.new("int[1]")
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
	local x, y = ffi.new("int[1]"), ffi.new("int[1]")
	function META:GetMousePosition()
		sdl.GetMouseState(x, y)
		return Vec2(x[0], y[0])
	end
end

function META:SetMousePosition(pos)
	sdl.WarpMouseInWindow(self.wnd_ptr, pos:Unpack())
end
do
	local last

	function META:SwapInterval(b)
		if last~= b then
			sdl.GL_SetSwapInterval(b and 1 or 0)
			last = b
		end
	end
end

function META:SetClipboard(str)
	sdl.SetClipboardText(tostring(str))
end

function META:GetClipboard()
	return ffi.string(sdl.GetClipboardText())
end

if system then
	do
		local last_check_battery_level = 0
		local battery_level

		function system.GetBatteryLevel()
			if last_check_battery_level < system.GetElapsedTime() then
				last_check_battery_level = system.GetElapsedTime() + 1
				local percent = ffi.new("uint32_t[1]")
				sdl.GetPowerInfo(nil, percent)
				battery_level = tonumber(percent[0]) / 100
			end

			return battery_level
		end
	end

	do
		local on_battery = sdl.e.POWERSTATE_ON_BATTERY
		local power_info
		local last_check_using_battery = 0

		function system.IsUsingBattery()
			if last_check_using_battery < system.GetElapsedTime() then
				last_check_using_battery = system.GetElapsedTime() + 1
				power_info = sdl.GetPowerInfo(nil, nil)
			end

			return power_info == on_battery
		end
	end

	local freq = tonumber(sdl.GetPerformanceFrequency())
	local start_time = tonumber(sdl.GetPerformanceCounter())

	function system.GetTimeSDL()
		local time = tonumber(sdl.GetPerformanceCounter())

		time = time - start_time

		return time / freq
	end
end

if OPENGL and not NULL_OPENGL then
	local gl = require("opengl")

	function META:PreWindowSetup(flags)
		table.insert(flags, "opengl")

		sdl.GL_SetAttribute(sdl.e.GL_DEPTH_SIZE, 16)
		sdl.GL_SetAttribute(sdl.e.GL_STENCIL_SIZE, 8)

		-- workaround for srgb on intel mesa driver
		sdl.GL_SetAttribute(sdl.e.GL_ALPHA_SIZE, 1)
	end

	local attempts = {
		{
			version = 4.6,
			profile_mask = "core",
		},
		{
			version = 4.5,
			profile_mask = "core",
		},
		{
			version = 4.0,
			profile_mask = "core",
		},
		{
			version = 3.3,
			profile_mask = "core",
		},
		{
			version = 3.2,
			profile_mask = "core",
		},
		{
			profile_mask = "core",
		},
	}

	function META:PostWindowSetup(wnd_ptr)
		local context
		local errors = ""

		for _, attempt in ipairs(attempts) do
			sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_PROFILE_MASK, sdl.e["GL_CONTEXT_PROFILE_" .. attempt.profile_mask:upper()])

			if DEBUG_OPENGL then
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_FLAGS, sdl.e.GL_CONTEXT_DEBUG_FLAG)
			end

			if attempt.version then
				local major, minor = math.modf(attempt.version)
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_MAJOR_VERSION, major)
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_MINOR_VERSION, minor * 10)
			end

			context = sdl.GL_CreateContext(wnd_ptr)

			if context ~= nil then
				--llog("successfully created OpenGL context ", attempt.version or "??", " ", attempt.profile_mask)
				break
			else
				local err = ffi.string(sdl.GetError())
				llog("could not requested OpenGL ", attempt.version or "??", " ", attempt.profile_mask, ": ", err)
				errors = errors .. err .. "\n"
			end
		end

		if context == nil then
			error("sdl.GL_CreateContext failed: " .. errors, 2)
		end

		gl.GetProcAddress = sdl.GL_GetProcAddress
		gl.Initialize()

		self:BindContext()

		self.gl_context = context
	end

	function META:BindContext()
		sdl.GL_MakeCurrent(self.wnd_ptr, self.gl_context)
	end

	function META:SwapBuffers()
		sdl.GL_SwapWindow(self.wnd_ptr)
	end

	function META:IsExtensionSupported(str)
		return sdl.GL_ExtensionSupported("GL_" .. str) == 1
	end
end