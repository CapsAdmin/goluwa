local window = ... or _G.window

local sdl = system.GetFFIBuildLibrary("SDL2") -- window manager
local ffi = require("ffi")

if not sdl then return end

local META = prototype.CreateTemplate("render_window")

function META:OnRemove()
	event.RemoveListener("OnUpdate", self)

	sdl.DestroyWindow(self.sdl_wnd)
	window.windowobjects[self.sdl_windowid] = nil
end

function META:GetPosition()
	return self.position
end

function META:SetPosition(pos)
	sdl.SetWindowPosition(self.sdl_wnd, pos:Unpack())
end

function META:GetSize()
	return self.size
end

function META:SetSize(size)
	sdl.SetWindowSize(self.sdl_wnd, size:Unpack())

	local x, y = ffi.new("int[1]"), ffi.new("int[1]")
	sdl.GetWindowSize(self.sdl_wnd, x, y)
	self.size = Vec2(x[0], y[0])
end

function META:Maximize()
	sdl.MaximizeWindow(self.sdl_wnd)
end

function META:Minimize()
	sdl.MinimizeWindow(self.sdl_wnd)
end

function META:Restore()
	sdl.RestoreWindow(self.sdl_wnd)
end

function META:SetTitle(title)
	sdl.SetWindowTitle(self.sdl_wnd, tostring(title))
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
	sdl.WarpMouseInWindow(self.sdl_wnd, pos:Unpack())
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

	sdl.SetWindowGrab(self.sdl_wnd, b and 1 or 0)
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
		local x, y = ffi.new("int[1]"), ffi.new("int[1]")
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

function META:SetClipboard(str)
	sdl.SetClipboardText(tostring(str))
end

function META:GetClipboard()
	return ffi.string(sdl.GetClipboardText())
end

function META:GetBatteryLevel()
	if (self.last_check_battery_level or 0) < system.GetElapsedTime() then
		self.last_check_battery_level = system.GetElapsedTime() + 1
		local percent = ffi.new("uint32_t[1]")
		sdl.GetPowerInfo(nil, percent)
		self.battery_level = tonumber(percent[0]) / 100
	end

	return self.battery_level
end

do
	local on_battery = sdl.e.POWERSTATE_ON_BATTERY
	function META:IsUsingBattery()
		if (self.last_check_using_battery or 0) < system.GetElapsedTime() then
			self.last_check_using_battery = system.GetElapsedTime() + 1
			self.power_info = sdl.GetPowerInfo(nil, nil)
		end

		return self.power_info == on_battery
	end
end

if system then
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
		arrow = sdl.e.SYSTEM_CURSOR_ARROW,
		ibeam = sdl.e.SYSTEM_CURSOR_IBEAM,
		wait = sdl.e.SYSTEM_CURSOR_WAIT,
		crosshair = sdl.e.SYSTEM_CURSOR_CROSSHAIR,
		waitarrow = sdl.e.SYSTEM_CURSOR_WAITARROW,
		sizenwse = sdl.e.SYSTEM_CURSOR_SIZENWSE,
		sizenesw = sdl.e.SYSTEM_CURSOR_SIZENESW,
		sizewe = sdl.e.SYSTEM_CURSOR_SIZEWE,
		sizens = sdl.e.SYSTEM_CURSOR_SIZENS,
		sizeall = sdl.e.SYSTEM_CURSOR_SIZEALL,
		no = sdl.e.SYSTEM_CURSOR_NO,
		hand = sdl.e.SYSTEM_CURSOR_HAND,
	}

	local current
	local last
	local cache = {}

	function META:SetCursor(id)
		id = id or "arrow"

		cache[id] = cache[id] or sdl.CreateSystemCursor(enums[id] or enums.arrow)
		if last ~= id then
			current = id
			sdl.SetCursor(cache[id])
			last = id
		end
	end

	function META:GetCursor()
		return current
	end

end

META:Register()

local flags_to_enums = {}

for k,v in pairs(sdl.e) do
	local friendly = k:match("WINDOW_(.+)")
	if friendly then
		friendly = friendly:lower()
		flags_to_enums[friendly] = v
	end
end

function window.CreateWindow(width, height, title, flags)
	title = title or ""

	if WINDOWS then
		ffi.cdef("int SetProcessDPIAware();")
		ffi.C.SetProcessDPIAware()
	end

	if not sdl.video_init then
		sdl.Init(sdl.e.INIT_VIDEO)
		sdl.SetHint(sdl.e.HINT_MOUSE_FOCUS_CLICKTHROUGH, "1")
		sdl.video_init = true
	end

	flags = flags or {"shown", "resizable"}

	render.PreWindowSetup(flags)

	local bit_flags = 0

	for _, v in pairs(flags) do
		bit_flags = bit.bor(bit_flags, tonumber(flags_to_enums[v]))
	end

	if not width or not height then
		local info = ffi.new("struct SDL_DisplayMode[1]")
		sdl.GetCurrentDisplayMode(0, info)
		width = width or info[0].w / 2
		height = height or info[0].h / 2
	end

	local sdl_wnd = sdl.CreateWindow(title, sdl.e.WINDOWPOS_CENTERED, sdl.e.WINDOWPOS_CENTERED, width, height, bit_flags)

	if sdl_wnd == nil then
		error("sdl.CreateWindow failed: " .. ffi.string(sdl.GetError()), 2)
	end

	render.PostWindowSetup(sdl_wnd)

	--llog("sdl version: %s", ffi.string(sdl.GetRevision()))

	local self = META:CreateObject()


	local x, y = ffi.new("int[1]"), ffi.new("int[1]")
	sdl.GetWindowPosition(sdl_wnd, x, y)
	self.position = Vec2(x[0], y[0])

	sdl.GetWindowSize(sdl_wnd, x, y)
	self.size = Vec2(x[0], y[0])

	self.last_mpos = Vec2()
	self.mouse_delta = Vec2()
	self.sdl_wnd = sdl_wnd

	window.windowobjects = window.windowobjects or {}
	self.sdl_windowid = sdl.GetWindowID(self.sdl_wnd)
	window.windowobjects[self.sdl_windowid] = self

	local event_name_translate = {}
	local key_translate = {
		["left_ctrl"] = "left_control",
		["keypad_-"] = "kp_subtract",
		["keypad_+"] = "kp_add",
		["return"] = "enter",
	}
	for i = 1, 9 do
		key_translate["keypad_" .. i] = "kp_" .. i
	end

	local function call(self, name, ...)
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

	local event = ffi.new("union SDL_Event")
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
			local wnd
			if event.window and event.window.windowID then
				wnd = window.windowobjects[event.window.windowID]
			end

			if event.type == sdl.e.WINDOWEVENT and wnd then
				local case = event.window.event

				if case == sdl.e.WINDOWEVENT_SHOWN then
					call(wnd, "OnShow")

				elseif case == sdl.e.WINDOWEVENT_HIDDEN then
					call(wnd, "OnHide")

				elseif case == sdl.e.WINDOWEVENT_MOVED then
					wnd.position.x = event.window.data1
					wnd.position.y = event.window.data2
					call(wnd, "OnMove", wnd.position.x, wnd.position.y)

				elseif case == sdl.e.WINDOWEVENT_RESIZED then
					wnd.size.x = event.window.data1
					wnd.size.y = event.window.data2
					call(wnd, "OnResize", wnd.size.x, wnd.size.y)

				elseif case == sdl.e.WINDOWEVENT_MINIMIZED then
					call(wnd, "OnMinimize")

				elseif case == sdl.e.WINDOWEVENT_MAXIMIZED then
					call(wnd, "OnMaximize")

				elseif case == sdl.e.WINDOWEVENT_RESTORED then
					call(wnd, "OnRefresh")

				elseif case == sdl.e.WINDOWEVENT_ENTER then
					call(wnd, "OnCursorEnter", false)

				elseif case == sdl.e.WINDOWEVENT_LEAVE then
					call(wnd, "OnCursorEnter", true)

				elseif case == sdl.e.WINDOWEVENT_FOCUS_GAINED then
					call(wnd, "OnFocus", true)
					wnd.focused = true

				elseif case == sdl.e.WINDOWEVENT_FOCUS_LOST  then
					call(wnd, "OnFocus", false)
					wnd.focused = false

				elseif case == sdl.e.WINDOWEVENT_CLOSE then
					call(wnd, "OnClose")

				elseif case == sdl.e.WINDOWEVENT_TAKE_FOCUS then
					call(wnd, "OnTakeFocus")

				elseif case == sdl.e.WINDOWEVENT_EXPOSED then
					call(wnd, "OnExposed")

				else
					for k,v in pairs(sdl.e) do
						if k:startswith("WINDOWEVENT") and v == case then
							llog("unhandled window event: ", k)
						end
					end
				end
			elseif event.type == sdl.e.KEYDOWN or event.type == sdl.e.KEYUP then
				local window = window.windowobjects[event.key.windowID]
				local key = ffi.string(sdl.GetKeyName(event.key.keysym.sym)):lower():gsub(" ", "_")

				key = key_translate[key] or key

				if event.key["repeat"] == 0 then
					if call(
						window,
						"OnKeyInput",
						key,
						event.type == sdl.e.KEYDOWN,

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
					event.type == sdl.e.KEYDOWN,

					event.key.state,
					event.key.keysym.mod,
					ffi.string(sdl.GetScancodeName(event.key.keysym.scancode)):lower(),
					event.key.keysym
				)
			elseif event.type == sdl.e.TEXTINPUT then
				if suppress_char_input then suppress_char_input = false return end
				local window = window.windowobjects[event.edit.windowID]

				call(window, "OnCharInput", ffi.string(event.edit.text), event.edit.start, event.edit.length)
			elseif event.type == sdl.e.TEXTEDITING then
				local window = window.windowobjects[event.text.windowID]

				call(window, "OnTextEditing", ffi.string(event.text.text))
			elseif event.type == sdl.e.MOUSEMOTION then
				local window = window.windowobjects[event.motion.windowID]
				if window then
					self.mouse_delta.x = event.motion.xrel
					self.mouse_delta.y = event.motion.yrel
					call(window, "OnCursorPosition", event.motion.x, event.motion.y, event.motion.xrel, event.motion.yrel, event.motion.state, event.motion.which)
				end
			elseif event.type == sdl.e.MOUSEBUTTONDOWN or event.type == sdl.e.MOUSEBUTTONUP then
				local window = window.windowobjects[event.button.windowID] or sdl.last_window
				call(window, "OnMouseInput", mbutton_translate[event.button.button], event.type == sdl.e.MOUSEBUTTONDOWN, event.button.x, event.button.y)
				sdl.last_window = window
			elseif event.type == sdl.e.MOUSEWHEEL then
				local window = window.windowobjects[event.button.windowID]
				call(window, "OnMouseScroll", event.wheel.x, event.wheel.y, event.wheel.which)
			elseif event.type == sdl.e.DROPFILE then
				for _, window in pairs(window.windowobjects) do
					call(window, "OnFileDrop", ffi.string(event.drop.file))
				end
			elseif event.type == sdl.e.QUIT and system then
				system.ShutDown()
			else print("unknown event", event.type) end
		end
	end)

	return self
end