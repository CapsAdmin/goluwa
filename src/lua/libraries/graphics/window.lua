local window = _G.window or {}

window.wnd = window.wnd or NULL

local meta = prototype.GetRegistered("render_window")

if not meta then warning("no window managed found") return end

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
		warning("no window manager found")
		return
	end

	local ok, wnd = pcall(system.CreateWindow, ...)

	if not render.initialized then
		render.initialized = true
		render.Initialize()
	end

	if not ok then warning(wnd) return NULL end

	function wnd:OnUpdate(dt)
		render.PushWindow(self)
			render.DrawScene()
			self:SwapBuffers()
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
			for i = 1, math.abs(y) do
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
			for i = 1, math.abs(x) do
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