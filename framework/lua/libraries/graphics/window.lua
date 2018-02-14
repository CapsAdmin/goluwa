local window = _G.window or {}

if PLATFORM == "gmod" then
	runfile("window_gmod.lua", window)
else
	runfile("window_sdl.lua", window)
end

local meta = prototype.GetRegistered("render_window")

if not meta then wlog("no window manager found") return end

for key, val in pairs(meta) do
	if type(val) == "function" then
		window[key] = function(...)
			return val(render.GetWindow(), ...)
		end
	end
end

function window.Open(...)
	if window.IsOpen() then return end

	if not window.CreateWindow then
		wlog("no window manager found")
		return nil, "no window manager found"
	end

	local ok, wnd = pcall(window.CreateWindow, ...)

	if not ok then wlog(wnd) return nil, wnd end

	if not render.initialized then
		render.initialized = true
		render.Initialize(wnd)
	end

	function wnd:OnUpdate()
		render.PushWindow(self)
		render.PushViewport(0, 0, self:GetSize():Unpack())

			local dt = system.GetFrameTime()
			render.GetScreenFrameBuffer():Begin()

			if render2d.IsReady() then
				render2d.Start()
				render2d.SetColor(1,1,1,1)
				render.SetCullMode("none")

				event.Call("Draw3D", dt)

				render.SetDepth(false)
				render.SetPresetBlendMode("alpha")

				event.Call("PreDrawGUI", dt)
				event.Call("DrawGUI", dt)
				event.Call("PostDrawGUI", dt)

				render2d.End()

				event.Call("PostDrawScene")
			end

			render.GetScreenFrameBuffer():End()
			render.SwapBuffers(self)
		render.PopWindow()
		render.PopViewport()
	end

	function wnd:OnCursorPosition()
		if system then window.GetCursor(window.GetCursor()) end
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

	ADD_EVENT("WindowMouseScroll", function(x, y)
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
