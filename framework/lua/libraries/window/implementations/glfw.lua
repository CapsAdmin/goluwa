local glfw = desire("glfw")
if not glfw then return end

local ffi = require("ffi")

local META = ... or prototype.GetRegistered("window")

META.KeyMap = {
	[-1] = "unknown",
	[32] = "space",
	[39] = "apostrophe",
	[44] = "comma",
	[45] = "minus",
	[46] = "period",
	[47] = "forward_slash",
	[48] = "0",
	[49] = "1",
	[50] = "2",
	[51] = "3",
	[52] = "4",
	[53] = "5",
	[54] = "6",
	[55] = "7",
	[56] = "8",
	[57] = "9",
	[59] = "semicolon",
	[61] = "equal",
	[65] = "a",
	[66] = "b",
	[67] = "c",
	[68] = "d",
	[69] = "e",
	[70] = "f",
	[71] = "g",
	[72] = "h",
	[73] = "i",
	[74] = "j",
	[75] = "k",
	[76] = "l",
	[77] = "m",
	[78] = "n",
	[79] = "o",
	[80] = "p",
	[81] = "q",
	[82] = "r",
	[83] = "s",
	[84] = "t",
	[85] = "u",
	[86] = "v",
	[87] = "w",
	[88] = "x",
	[89] = "y",
	[90] = "z",
	[91] = "left_bracket",
	[92] = "back_slash",
	[93] = "right_bracket",
	[96] = "grave_accent",
	[161] = "world_1",
	[162] = "world_2",
	[256] = "escape",
	[257] = "enter",
	[258] = "tab",
	[259] = "backspace",
	[260] = "insert",
	[261] = "delete",
	[262] = "right",
	[263] = "left",
	[264] = "down",
	[265] = "up",
	[266] = "page_up",
	[267] = "page_down",
	[268] = "home",
	[269] = "end",
	[280] = "caps_lock",
	[281] = "scroll_lock",
	[282] = "num_lock",
	[283] = "print_screen",
	[284] = "pause",
	[290] = "f1",
	[291] = "f2",
	[292] = "f3",
	[293] = "f4",
	[294] = "f5",
	[295] = "f6",
	[296] = "f7",
	[297] = "f8",
	[298] = "f9",
	[299] = "f10",
	[300] = "f11",
	[301] = "f12",
	[302] = "f13",
	[303] = "f14",
	[304] = "f15",
	[305] = "f16",
	[306] = "f17",
	[307] = "f18",
	[308] = "f19",
	[309] = "f20",
	[310] = "f21",
	[311] = "f22",
	[312] = "f23",
	[313] = "f24",
	[314] = "f25",
	[320] = "kp_0",
	[321] = "kp_1",
	[322] = "kp_2",
	[323] = "kp_3",
	[324] = "kp_4",
	[325] = "kp_5",
	[326] = "kp_6",
	[327] = "kp_7",
	[328] = "kp_8",
	[329] = "kp_9",
	[330] = "kp_decimal",
	[331] = "kp_divide",
	[332] = "kp_multiply",
	[333] = "kp_subtract",
	[334] = "kp_add",
	[335] = "kp_enter",
	[336] = "kp_equal",
	[340] = "left_shift",
	[341] = "left_control",
	[342] = "left_alt",
	[343] = "left_super",
	[344] = "right_shift",
	[345] = "right_control",
	[346] = "right_alt",
	[347] = "right_super",
	[348] = "menu",
}

META.ButtonMap = {
	[0] = "button_1",
	[1] = "button_2",
	[2] = "button_3",
	[3] = "button_4",
	[4] = "button_5",
	[5] = "button_6",
	[6] = "button_7",
	[7] = "button_8",
}


function META:Initialize()
	if not glfw.init then
		glfw.Init()

		local cb = function(code, str) wlog(ffi.string(str)) end
		jit.off(cb)
		glfw.SetErrorCallback(cb)

		local cb = function() event.Call("OnMonitorConnected") end
		jit.off(cb)
		glfw.SetMonitorCallback(cb)

		if OPENGL then
			require("opengl").GetProcAddress = glfw.GetProcAddress
		end

		glfw.init = true
	end

	self:PreWindowSetup(self.Flags or {"shown", "resizable"})

	local w, h = self.Size.x, self.Size.y

	local monitor = glfw.GetPrimaryMonitor()
	local props = glfw.GetVideoMode(monitor)

	if w == 0 then
		w = props.width
	end

	if h == 0 then
		h = props.height
	end

	local ptr = glfw.CreateWindow(w, h, self.Title, nil, render.main_window and render.main_window.wnd_ptr)

	if ptr == nil then
		wlog("failed to create opengl window")
		return NULL
	end

	glfw.MakeContextCurrent(ptr)
	
	if VERBOSE then
		logn("glfw version: ", ffi.string(glfw.GetVersionString()):trim())
	end

	self.wnd_ptr = ptr

	self:PostWindowSetup()

	if not system.disable_window then
		self:AddEvent("Update")
		self:AddEvent("FrameEnd")
	end

	do -- callbacks
		local function set_callback(name, cb)
			jit.off(cb)
			glfw["Set" .. name .."Callback"](ptr, cb)
		end

		set_callback("Drop", function(ptr, count, strings)
			local t = {}

			for i = 1, count do
				t[i] = ffi.string(strings[i-1])
			end

			self:CallEvent("Drop", t)
		end)

		do
			local suppress_char_input = false

			set_callback("Char", function(ptr, uint)
				event.Delay(function()
					if suppress_char_input then
						suppress_char_input = false
						return
					end

					self:CallEvent("CharInput", utf8.char(uint))
				end)
			end)

			set_callback("Key", function(ptr, key_, scancode, action, mods)
				local key = self.KeyMap[key_]

				if action ~= glfw.e.REPEAT then
					local press = action == glfw.e.PRESS

					if self:CallEvent("KeyInput", key, press) == false then
						suppress_char_input = true
					end
				end

				self:CallEvent("KeyInputRepeat", key, glfw.e.PRESS or action == glfw.e.REPEAT)
			end)

			set_callback("MouseButton", function(ptr, button, action, mods)
				self:CallEvent("MouseInput", self.ButtonMap[button], action == glfw.e.PRESS)
			end)

			set_callback("Scroll", function(ptr, x, y)
				self:CallEvent("MouseScroll", Vec2(x, y))
			end)
		end

		set_callback("WindowClose", function(ptr)
			self:CallEvent("Close")
		end)

		set_callback("WindowFocus", function(ptr, b)
			self.Focused = b == 1

			if b == 1 then
				self:CallEvent("GainedFocus")
			else
				self:CallEvent("LostFocus")
			end
		end)

		set_callback("FramebufferSize", function(ptr, w, h)
			self:CallEvent("FramebufferResized", Vec2(w, h))
		end)

		set_callback("WindowSize", function(ptr, w, h)
			self:CallEvent("SizeChanged", Vec2(w, h))
		end)

		set_callback("WindowPos", function(ptr, x, y)
			self:CallEvent("PositionChanged", Vec2(x, y))
		end)

		set_callback("CursorEnter", function(ptr, a)
			if enter == 1 then
				self:CallEvent("CursorEnter")
			else
				self:CallEvent("CursorLeave")
			end
		end)
	end

	if not render.current_window:IsValid() then
		render.current_window = self
	end

	render.context_created = true

	if not render.init then
		render.Initialize(self)
		render.init = true
		render.main_window = self
	end
end

function META:OnRemove()
	glfw.DestroyWindow(self.wnd_ptr)
end

function META:OnFrameEnd()
	self:SwapBuffers()
end

function META:OnUpdate(dt)
	self:OnPostUpdate(dt)
	self:UpdateMouseDelta()
	glfw.PollEvents()
end

function META:Maximize()
	glfw.MaximizeWindow(self.wnd_ptr)
end

function META:Minimize()
	glfw.IconifyWindow(self.wnd_ptr)
end

function META:Restore()
	glfw.RestoreWindow(self.wnd_ptr)
end

do
	local shapes = {
		arrow = glfw.CreateStandardCursor(glfw.e.ARROW_CURSOR),
		text_input = glfw.CreateStandardCursor(glfw.e.IBEAM_CURSOR),
		crosshair = glfw.CreateStandardCursor(glfw.e.CROSSHAIR_CURSOR),
		hand = glfw.CreateStandardCursor(glfw.e.HAND_CURSOR),
		horizontal_resize = glfw.CreateStandardCursor(glfw.e.HRESIZE_CURSOR),
		vertical_resize = glfw.CreateStandardCursor(glfw.e.VRESIZE_CURSOR),
	}

	function META:SetCursor(mode)
		if not self.Cursors[mode] then
			mode = "arrow"
		end

		self.Cursor = mode

		if mode == "hidden" then
			glfw.SetInputMode(self.wnd_ptr, glfw.e.CURSOR, glfw.e.CURSOR_HIDDEN)
		elseif mode == "trapped" then
			glfw.SetInputMode(self.wnd_ptr, glfw.e.CURSOR, glfw.e.CURSOR_DISABLED)
		else
			glfw.SetInputMode(self.wnd_ptr, glfw.e.CURSOR, glfw.e.CURSOR_NORMAL)
			glfw.SetCursor(self.wnd_ptr, shapes[mode])
		end
	end
end
function META:SetSize(pos)
	glfw.SetWindowSize(self.wnd_ptr, pos:Unpack())
end
function META:GetSize()
	local x = ffi.new("int[1]")
	local y = ffi.new("int[1]")

	glfw.GetWindowSize(self.wnd_ptr, x, y)
	return Vec2(x[0], y[0])
end

function META:GetFramebufferSize()
	local x = ffi.new("int[1]")
	local y = ffi.new("int[1]")

	glfw.GetFramebufferSize(self.wnd_ptr, x, y)

	return Vec2(x[0], y[0])
end

function META:SetTitle(title)
	self.Title = tostring(title)
	glfw.SetWindowTitle(self.wnd_ptr, self.Title)
end

function META:SetMousePosition(pos)
	glfw.SetCursorPos(self.wnd_ptr, pos:Unpack())
end

function META:GetMousePosition()
	local x = ffi.new("double[1]")
	local y = ffi.new("double[1]")
	glfw.GetCursorPos(self.wnd_ptr, x, y)
	return Vec2(x[0], y[0])
end

function META:SwapInterval(b)
	if last~= b then
		glfw.SwapInterval(b and 1 or 0)
		last = b
	end
end

function META:SetClipboard(str)
	glfw.SetClipboardString(self.wnd_ptr, str)
end

function META:GetClipboard()
	local str = glfw.GetClipboardString(self.wnd_ptr)
	if str ~= nil then
		return ffi.string(str)
	end
end

if VULKAN then
	function META:PreWindowSetup(flags)
		table.insert(flags, "vulkan")

		glfw.WindowHint(glfw.e.CLIENT_API, glfw.e.NO_API)
	end

	function META:PostWindowSetup()

	end

	function render.CreateVulkanSurface(wnd, instance)
		return glfw.CreateWindowSurface(instance, wnd.wnd_ptr, nil)
	end

	function render.GetRequiredInstanceExtensions(wnd, extra)
		return glfw.GetRequiredInstanceExtensions(wnd.wnd_ptr, extra)
	end
end

if OPENGL and not NULL_OPENGL then
	local gl = require("opengl")

	function META:BindContext()
		glfw.MakeContextCurrent(self.wnd_ptr)
	end

	function META:SwapBuffers()
		glfw.SwapBuffers(self.wnd_ptr)
	end

	function META:PreWindowSetup(flags)
		table.insert(flags, "opengl")

		glfw.WindowHint(glfw.e.DEPTH_BITS, 16)
		glfw.WindowHint(glfw.e.STENCIL_BITS, 8)

		-- workaround for srgb on intel mesa driver
		glfw.WindowHint(glfw.e.ALPHA_BITS, 1)
		--glfw.WindowHint(glfw.e.CONTEXT_VERSION_MINOR, 3)
		glfw.WindowHint(glfw.e.CONTEXT_VERSION_MAJOR, 4)
	end

	function META:PostWindowSetup()
		local gl = require("opengl")
		gl.GetProcAddress = glfw.GetProcAddress
		gl.Initialize()
	end

	function META:IsExtensionSupported(str)
		return glfw.ExtensionSupported("GL_" .. str) == 1
	end
end

do
	local count = ffi.new("int[1]")

	function META:GetJoystickState(i)
		if glfw.JoystickPresent(i) == 0 then return end

		local out = {axes = {}, buttons = {}}
		if glfw.JoystickPresent(i) ~= 0 then

			out.name = ffi.string(glfw.GetJoystickName(i))

			local axes = glfw.GetJoystickAxes(i, count)
			for i = 0, count[0] do
				out.axes[i+1] = axes[i]
			end

			local buttons = glfw.GetJoystickButtons(i, count)
			for i = 0, count[0] do
				out.buttons[i+1] = buttons[i]
			end

			return out
		end
	end
end