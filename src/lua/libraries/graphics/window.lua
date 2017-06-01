local window = _G.window or {}

window.wnd = window.wnd or NULL

local meta = prototype.GetRegistered("render_window")

if not meta then wlog("no window manager found") return end

for key, val in pairs(meta) do
	if type(val) == "function" then
		window[key] = function(...)
			return val(window.wnd, ...)
		end
	end
end

function window.Open(...)
	if window.wnd:IsValid() then return end

	if not system.CreateWindow then
		wlog("no window manager found")
		return nil, "no window manager found"
	end

	local ok, wnd = pcall(system.CreateWindow, ...)

	if not ok then wlog(wnd) return nil, wnd end

	if not render.initialized then
		render.initialized = true
		render.Initialize(wnd)
	end

	render.SetWindow(wnd)

	function wnd:OnUpdate()
		render.PushWindow(self)
			local dt = system.GetFrameTime()
			render.GetScreenFrameBuffer():Begin()
			if render3d.IsGBufferReady() then
				render3d.DrawGBuffer()
			end

			if render2d.IsReady() then
				render2d.Start()
				render2d.SetColor(1,1,1,1)
				render.SetCullMode("none")

				render.SetDepth(false)
				render.SetPresetBlendMode("alpha")

				if render3d.IsGBufferReady() then
					if menu and menu.IsVisible() then
						render2d.PushHSV(1,0,1)
					end

					render2d.SetTexture(render3d.GetFinalGBufferTexture())
					render2d.DrawRect(0, 0, render2d.GetSize())

					if menu and menu.IsVisible() then
						render2d.PopHSV()
					end

					if render3d.debug then
						render3d.DrawGBufferDebugOverlay()
					end
				end


				if not render3d.IsGBufferReady() and (line and not line.IsGameRunning()) then
					render.GetScreenFrameBuffer():ClearAll()
				end

				event.Call("PreDrawGUI", dt)
				event.Call("DrawGUI", dt)
				event.Call("PostDrawGUI", dt)

				render2d.End()

				event.Call("PostDrawScene")
			end

			render.GetScreenFrameBuffer():End()
			render.SwapBuffers(self)
		render.PopWindow()
	end

	function wnd:OnCursorPosition()
		if system then window.GetCursor(window.GetCursor()) end
	end

	local key_trigger = input.SetupInputEvent("Key")
	local mouse_trigger = input.SetupInputEvent("Mouse")

	local function ADD_EVENT(name, callback)
		local nice = name:sub(7)

		event.AddListener(name, "window_events", function(_wnd, ...)
			--if _wnd == window.wnd then
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

	window.wnd = wnd

	return wnd
end

function window.IsOpen()
	return window.wnd:IsValid()
end

function window.Close()
	if window.wnd:IsValid() then
		window.wnd:Remove()
	end
end

return window