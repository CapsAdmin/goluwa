local window = _G.window or {}

window.active = window.active or {}

do
	local META = prototype.CreateTemplate("window")

	META:GetSet("Title", "no title")
	META:GetSet("Position", Vec2())
	META:GetSet("Size", Vec2())
	META:GetSet("MousePosition", Vec2())
	META:GetSet("MouseDelta", Vec2())
	META:GetSet("MouseTrapped", false)
	META:GetSet("Clipboard")
	META:GetSet("Flags")
	META:GetSet("Cursor", "arrow")
	META:IsSet("Focused", false)

	META.Cursors = {
		hand = true,
		arrow = true,
		trapped = true,
		hidden = true,
		crosshair = true,
		text_input = true,
		vertical_resize = true,
		horizontal_resize = true,

		horizontal_resize = true,
		vertical_resize = true,

		top_right_resize =  true,
		bottom_left_resize =  true,

		top_left_resize =  true,
		bottom_right_resize =  true,

		all_resize =  true,
	}

	META.Keys = {

	}

	META.Buttons = {

}

	function META:SetMouseTrapped(b)
		self:SetCursor(b and "trapped" or "arrow")
	end

	function META:GetMouseTrapped()
		return self:GetCursor() == "trapped"
	end

	local function nyi()
		local func = debug.getinfo(2).func
		for k, v in pairs(META) do
			if v == func then
				local msg = "function Window:" .. k .. "() is not implemented"
				wlog(msg, 2)
				error(msg, 2)
			end
		end
	end

	function META:Initialize() nyi() end
	function META:PreWindowSetup() nyi() end
	function META:PostWindowSetup() nyi() end
	function META:OnRemove() nyi() end

	function META:Maximize() nyi() end
	function META:Minimize() nyi() end
	function META:Restore() nyi() end

	function META:GetFramebufferSize() nyi() end

	function META:OnUpdate(dt) end

	function META:OnMinimize() end
	function META:OnMaximize() end

	function META:OnGainedFocus() end
	function META:OnLostFocus() end

	function META:OnPositionChanged(pos) end
	function META:OnSizeChanged(size) end
	function META:OnFramebufferResized(size) end

	function META:OnCursorEnter() end
	function META:OnCursorLeave() end

	function META:OnClose() end

	function META:OnCursorPosition(x, y) end
	function META:OnDrop(paths) end

	function META:OnCharInput(str) end

	function META:OnKeyInput(key, press) end
	function META:OnKeyInputRepeat(key, press) end
	function META:OnMouseInput(key, press) end
	function META:OnMouseScroll(x, y) end

	function META:BindContext() end
	function META:SwapBuffers() end

	function META:UpdateMouseDelta()
		local pos = self:GetMousePosition()

		if self.last_mpos then
			self:SetMouseDelta(pos - self.last_mpos)
		end

		self.last_mpos = pos

		if self:OnCursorPosition(self, pos) ~= false then
			event.Call("WindowCursorPosition", self, pos)
		end
	end

	function META:CallEvent(name, ...)
		local b = self["On" .. name](self, ...)

		if b ~= false then
			b = event.Call("Window" .. name, self, ...)
		end

		return b
	end

	function META:OnPostUpdate()
		render.PushWindow(self)
		render.PushViewport(0, 0, self:GetSize():Unpack())

			local dt = system.GetFrameTime()
			local fb = render.GetScreenFrameBuffer()

			fb:Begin()
			fb:ClearAll()

			event.Call("Draw3D", dt)

			if render2d.IsReady() then
				render2d.Start()
				render2d.SetColor(1,1,1,1)
				render.SetCullMode("none")
				render.SetDepth(false)
				render.SetPresetBlendMode("alpha")

				event.Call("PreDrawGUI", dt)
				event.Call("DrawGUI", dt)
				event.Call("PostDrawGUI", dt)

				render2d.End()

				event.Call("PostDrawScene")
			end

			fb:End()
		render.PopWindow()
		render.PopViewport()
	end

	function META:OnClose()
		self:Remove()
		system.ShutDown()
	end

	if WINDOW_IMPLEMENTATION == "sdl2" then
		runfile("implementations/sdl2.lua", META)
	elseif WINDOW_IMPLEMENTATION == "glfw" then
		runfile("implementations/glfw.lua", META)
	end

	function window.CreateWindow(width, height, title, flags)
		local self = META:CreateObject()

		local ok, err = self:Initialize()
		if ok == false then
			return ok, err
		end

		if NULL_OPENGL then
			local gl = require("opengl")

			for k,v in pairs(gl) do
				if type(v) == "cdata" then
					gl[k] = function() return 0 end
				end
			end

			function gl.CheckNamedFramebufferStatus()
				return 36053
			end

			function gl.GetString()
				return nil
			end
		end

		self:SetTitle(title)

		if width and height then
			self:SetSize(Vec2(width, height))
		end
		self:SetFlags(flags)

		table.insert(window.active, self)

		return self
	end

	META:Register()
end

for key, val in pairs(prototype.GetRegistered("window")) do
	if type(val) == "function" then
		window[key] = function(...)
			return val(render.GetWindow(), ...)
		end
	end
end

function window.GetWindows()
	return window.active
end

function window.Open(...)
	if window.IsOpen() then return end

	local ok, wnd = pcall(window.CreateWindow, ...)

	if not ok then wlog(wnd) return ok, wnd end

	wnd:BindContext()

	if not render.initialized then
		render.initialized = true
		render.Initialize(wnd)
	end

	local key_trigger = input.SetupInputEvent("Key")
	local mouse_trigger = input.SetupInputEvent("Mouse")

	local function ADD_EVENT(name, callback)
		local nice = name:sub(7)

		event.AddListener(name, "window_events", function(_wnd, ...)
			--if _wnd == render.GetWindow() then
				if not callback or callback(...) ~= false then
					return event.Call(nice, ...)
				end
			--end
		end)
	end

	ADD_EVENT("WindowCharInput")
	ADD_EVENT("WindowKeyInput", key_trigger)
	ADD_EVENT("WindowMouseInput", mouse_trigger)
	ADD_EVENT("WindowKeyInputRepeat")

	local mouse_trigger = function(key, press) mouse_trigger(key, press) event.Call("MouseInput", key, press) end

	ADD_EVENT("WindowMouseScroll", function(dir)
		local x,y = dir:Unpack()

		if y ~= 0 then
			for _ = 1, math.abs(y) do
				if y > 0 then
					mouse_trigger("mwheel_up", true)
				else
					mouse_trigger("mwheel_down", true)
				end
			end

			event.Delay(function()
				if y > 0 then
					mouse_trigger("mwheel_up", false)
				else
					mouse_trigger("mwheel_down", false)
				end
			end)
		end

		if x ~= 0 then
			for _ = 1, math.abs(x) do
				if x > 0 then
					mouse_trigger("mwheel_left", true)
				else
					mouse_trigger("mwheel_right", true)
				end
			end
			event.Delay(function()
				if x > 0 then
					mouse_trigger("mwheel_left", false)
				else
					mouse_trigger("mwheel_right", false)
				end
			end)
		end
	end)

	return wnd
end

function window.IsOpen()
	return render.GetWindow():IsValid()
end

function window.Close()
	if window.IsOpen() then
		render.GetWindow():Remove()
	end
end

return window
