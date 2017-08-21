
--oo/abstract/basewindow: base class for top-level windows and controls
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.vobject'
require'winapi.handlelist'
require'winapi.window'
require'winapi.gdi'
require'winapi.keyboard'
require'winapi.mouse'
require'winapi.monitor'
require'winapi.dpiaware'

--window tracker -------------------------------------------------------------

Windows = class(HandleList) --track window objects by their hwnd

--the active window goes nil when the app is deactivated, but if
--SetActiveWindow() is called while the app is inactive, the active
--window will be set immediately, even if the window doesn't activate.
function Windows:get_active_window()
	return self:find(GetActiveWindow())
end

--the difference between active window and foreground window is that
--the foreground window is always nil when the app is not active,
--even after calling SetActiveWindow().
function Windows:get_foreground_window()
	return self:find(GetForegroundWindow())
end

--get window under POINT
function Windows:window_at(p)
	return self:find(WindowFromPoint(p))
end

--screen POINT -> client POINT
function Windows:map_point(to_window, ...) --x,y or point
	return MapWindowPoint(nil, to_window.hwnd, ...)
end

--screen RECT -> client RECT
function Windows:map_rect(to_window, ...) --x1,y1,x2,y2 or rect
	return MapWindowRect(nil, to_window.hwnd, ...)
end

--get current mouse position in screen or client coordinates.
--NOTE: gets the current mouse position, outside of the event stream.
function Windows:get_cursor_pos(in_window)
	local p = GetCursorPos()
	return in_window and self:map_point(in_window, p) or p
end

Windows = Windows'hwnd' --singleton

--message router -------------------------------------------------------------

--By assigning your window's WNDPROC to MessageRouter.proc (either via
--SetWindowLong(GWL_WNDPROC) or via RegisterClass(), and adding your window
--object to the window tracker via Windows:add(window), your window's
--__handle_message() method will be called for each message destined to your
--window. This way only one ffi callback object is wasted for all windows.

MessageRouter = class(Object)

function MessageRouter:__init()
	local function dispatch(hwnd, WM, wParam, lParam)
		local window = Windows:find(hwnd)
		if window then
			return window:__handle_message(WM, wParam, lParam)
		end
		return DefWindowProc(hwnd, WM, wParam, lParam) --catch WM_CREATE etc.
	end

	--exceptions in WNDPROC are caught by Windows on x64, see:
	--http://stackoverflow.com/questions/1487950/access-violation-in-wm-paint-not-caught
	if ffi.abi'64bit' then
		local dispatch0 = dispatch
		function dispatch(...)
			local ok, ret = xpcall(dispatch0, debug.traceback, ...)
			if ok then return ret end
			io.stderr:write(ret..'\n')
			PostMessage(nil, WM_EXCEPTION)
		end
	end

	self.proc = ffi.cast('WNDPROC', dispatch)
end

function MessageRouter:free()
	self.proc:free()
end

MessageRouter = MessageRouter() --singleton

--message loop ---------------------------------------------------------------

--standard recipe message dispatcher based on the Window tracker.
function ProcessMessage(msg)
	local window = Windows.active_window
	if window then
		if window.accelerators and window.accelerators.haccel then
			--make hotkeys work
			if TranslateAccelerator(window.hwnd, window.accelerators.haccel, msg) then
				return
			end
		end
		if not window.__wantallkeys then
			--make tab and arrow keys work with controls.
			--for windows with no focusable controls, set __wantallkeys,
			--which skips this step so that no WM_CHAR messages are filtered.
			if IsDialogMessage(window.hwnd, msg) then
				return
			end
		end
	end
	TranslateMessage(msg) --make keyboard work
	DispatchMessage(msg) --make everything else work

	--posted by Window objects to unregister their WNDCLASS after they're gone.
	if msg.message == WM_UNREGISTER_CLASS then
		UnregisterClass(msg.wParam)
	elseif msg.message == WM_EXCEPTION then
		error'WM_EXCEPTION'
	end
end

--NOTE: you can call the message loop like this: os.exit(MessageLoop()).
function MessageLoop()
	local msg = types.MSG()
	while true do
		local ret = GetMessage(nil, 0, 0, msg)
		if ret == 0 then break end --WM_QUIT received
		ProcessMessage(msg)
	end
	return tonumber(msg.signed_wParam) --WM_QUIT sends an int exit code in wParam
end

function ProcessNextMessage()
	local ok, msg = PeekMessage(nil, 0, 0, PM_REMOVE)
	if not ok then return false end
	if msg.message == WM_QUIT then return false, true end
	ProcessMessage(msg)
	return true
end

--process all pending messages from the queue (if any) and return.
function ProcessMessages()
	while ProcessNextMessage() do end
end

--base window class ----------------------------------------------------------

BaseWindow = {
	__class_style_bitmask = bitmask{}, --for windows that own their WNDCLASS
	__style_bitmask = bitmask{},       --style bits
	__style_ex_bitmask = bitmask{},    --extended style bits
	__defaults = {
		visible = true,
		enabled = true,
		x = 0,
		y = 0,
	},
	__init_properties = {},     --properties to be set after window creation
	__wm_handler_names = index{ --message name -> handler name mapping
		--lifetime
		on_destroy = WM_DESTROY,
		--on_destroyed = WM_NCDESTROY, --manually triggered
		--movement
		on_pos_changing = WM_WINDOWPOSCHANGING,
		on_pos_change = WM_WINDOWPOSCHANGED,
		on_moving = WM_MOVING,
		on_moved = WM_MOVE,
		on_resizing = WM_SIZING,
		on_resized = WM_SIZE,
		on_begin_sizemove = WM_ENTERSIZEMOVE,
		on_end_sizemove = WM_EXITSIZEMOVE,
		on_focus = WM_SETFOCUS,
		on_blur = WM_KILLFOCUS,
		on_enable = WM_ENABLE,
		on_show = WM_SHOWWINDOW,
		--queries
		on_help = WM_HELP,
		on_set_cursor = WM_SETCURSOR,
		--mouse events
		on_mouse_move = WM_MOUSEMOVE,
		on_mouse_over = WM_MOUSEHOVER,  --call TrackMouseEvent() to receive this
		on_mouse_leave = WM_MOUSELEAVE, --call TrackMouseEvent() to receive this
		on_lbutton_double_click = WM_LBUTTONDBLCLK,
		on_lbutton_down = WM_LBUTTONDOWN,
		on_lbutton_up = WM_LBUTTONUP,
		on_mbutton_double_click = WM_MBUTTONDBLCLK,
		on_mbutton_down = WM_MBUTTONDOWN,
		on_mbutton_up = WM_MBUTTONUP,
		on_rbutton_double_click = WM_RBUTTONDBLCLK,
		on_rbutton_down = WM_RBUTTONDOWN,
		on_rbutton_up = WM_RBUTTONUP,
		on_xbutton_double_click = WM_XBUTTONDBLCLK,
		on_xbutton_down = WM_XBUTTONDOWN,
		on_xbutton_up = WM_XBUTTONUP,
		on_mouse_wheel = WM_MOUSEWHEEL,
		on_mouse_hwheel = WM_MOUSEHWHEEL,
		--keyboard events
		on_key_down = WM_KEYDOWN,
		on_key_up = WM_KEYUP,
		on_syskey_down = WM_SYSKEYDOWN,
		on_syskey_up = WM_SYSKEYUP,
		on_key_down_char = WM_CHAR,
		on_syskey_down_char = WM_SYSCHAR,
		on_dead_key_up_char = WM_DEADCHAR,
		on_dead_syskey_down_char = WM_SYSDEADCHAR,
		--raw input
		on_raw_input = WM_INPUT,
		on_device_change = WM_INPUT_DEVICE_CHANGE,
		--system events
		on_dpi_change = WM_DPICHANGED,
		--custom draw
		on_nc_hittest = WM_NCHITTEST,
		on_nc_calcsize = WM_NCCALCSIZE,
	},
	__wm_syscommand_handler_names = {}, --WM_SYSCOMMAND code -> handler name map
	__wm_command_handler_names = {},    --WM_COMMAND code -> handler name map
	__wm_notify_handler_names = {},     --WM_NOTIFY code -> handler name map
}

BaseWindow = subclass(BaseWindow, VObject)

--subclassing ----------------------------------------------------------------

--Subclassing from BaseWindow via subclass() allows the subclass to define
--style bits, WM -> handler name mappings, etc. that are relevant to the
--subclass. When subclassing, virtual properites will be generated for
--getting and setting style bits individually, and other tables like
--__defaults or __wm_handler_names will be inherited from the superclass.

function BaseWindow:__get_class_style_bit(k)
	return self.__class_style_bitmask:getbit(GetClassStyle(self.hwnd), k)
end

function BaseWindow:__get_style_bit(k)
	return self.__style_bitmask:getbit(GetWindowStyle(self.hwnd), k)
end

function BaseWindow:__get_style_ex_bit(k)
	return self.__style_ex_bitmask:getbit(GetWindowExStyle(self.hwnd), k)
end

function BaseWindow:__set_class_style_bit(k,v)
	SetClassStyle(self.hwnd,
		self.__class_style_bitmask:setbit(GetClassStyle(self.hwnd), k, v))
	SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY)
end

function BaseWindow:__set_style_bit(k,v)
	SetWindowStyle(self.hwnd,
		self.__style_bitmask:setbit(GetWindowStyle(self.hwnd), k, v))
	SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY)
end

function BaseWindow:__set_style_ex_bit(k,v)
	SetWindowExStyle(self.hwnd,
		self.__style_ex_bitmask:setbit(GetWindowExStyle(self.hwnd), k, v))
	SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY)
end

function BaseWindow:__subclass(class)
	BaseWindow.__index.__subclass(self, class)

	--generate style virtual properties from additional style bitmask fields,
	--if any, and inherit the bitmask fields of the superclass.
	if rawget(class, '__class_style_bitmask') then
		class:__gen_vproperties(class.__class_style_bitmask.fields,
			class.__get_class_style_bit, class.__set_class_style_bit)
		update(class.__class_style_bitmask.fields, self.__class_style_bitmask.fields)
	end
	if rawget(class, '__style_bitmask') then
		class:__gen_vproperties(class.__style_bitmask.fields,
			class.__get_style_bit, class.__set_style_bit)
		update(class.__style_bitmask.fields, self.__style_bitmask.fields)
	end
	if rawget(class, '__style_ex_bitmask') then
		class:__gen_vproperties(class.__style_ex_bitmask.fields,
			class.__get_style_ex_bit, class.__set_style_ex_bit)
		update(class.__style_ex_bitmask.fields, self.__style_ex_bitmask.fields)
	end

	--inherit settings from the super class.
	if rawget(class, '__defaults') then
		inherit(class.__defaults, self.__defaults)
	end
	if rawget(class, '__init_properties') then
		extend(class.__init_properties, self.__init_properties)
	end
	if rawget(class, '__wm_handler_names') then
		inherit(class.__wm_handler_names, self.__wm_handler_names)
	end
	if rawget(class, '__wm_syscommand_handler_names') then
		inherit(class.__wm_syscommand_handler_names, self.__wm_syscommand_handler_names)
	end
	if rawget(class, '__wm_command_handler_names') then
		inherit(class.__wm_command_handler_names, self.__wm_command_handler_names)
	end
	if rawget(class, '__wm_notify_handler_names') then
		inherit(class.__wm_notify_handler_names, self.__wm_notify_handler_names)
	end
end

--instantiating --------------------------------------------------------------

function BaseWindow:__before_create(info, args) end --stub
function BaseWindow:__after_create(info, args) end --stub

--Windows will ignore style bits that are contradictory, so we check our
--wanted style attributes to what was actually set and raise an error if
--any of our attributes were ignored.
function BaseWindow:__check_bitmask(name, mask, wanted, actual)
	if bit.tobit(wanted) == bit.tobit(actual) then return end
	local ok, pp = pcall(require, 'pp')
	local wanted_fmt = ok and pp.format(mask:get(wanted), '   ') or ''
	local actual_fmt = ok and pp.format(mask:get(actual), '   ') or ''
	print(string.format(
		'WARNING: inconsistent %s bits\nwanted: 0x%08x %s\nactual: 0x%08x %s', name,
			tonumber(wanted), wanted_fmt,
			tonumber(actual), actual_fmt))
end

function BaseWindow:__check_class_style(wanted)
	self:__check_bitmask('ClassStyle', self.__class_style_bitmask, wanted,
		GetClassStyle(self.hwnd))
end

function BaseWindow:__check_style(wanted)
	self:__check_bitmask('WS_* style', self.__style_bitmask, wanted,
		GetWindowStyle(self.hwnd))
end

function BaseWindow:__check_style_ex(wanted)
	self:__check_bitmask('WS_EX_* style', self.__style_ex_bitmask, wanted,
		GetWindowExStyle(self.hwnd))
end

--class method: convert info attributes to style bits.
--subclasses override this to customize style bits based on info attributes.
function BaseWindow:__info_style(info)
	local style = self.__style_bitmask:set(0, info)
	local style = bit.bor(style, info.enabled and 0 or WS_DISABLED)
	return style
end

--class method: convert info attributes to extended style bits.
--subclasses override this to customize style bits based on info attributes.
function BaseWindow:__info_style_ex(info)
	return self.__style_ex_bitmask:set(0, info)
end

function BaseWindow:__init(info)

	--given a window handle, wrap it in a window object, ignoring info completely.
	if info.hwnd then
		self.hwnd = info.hwnd
		Windows:add(self)
		return
	end

	info = inherit(info or {}, self.__defaults)

	self.__state = {}

	--size constraints
	self.min_w = info.min_w
	self.min_h = info.min_h
	self.max_w = info.max_w
	self.max_h = info.max_h
	self.min_cw = info.min_cw
	self.min_ch = info.min_ch
	self.max_cw = info.max_cw
	self.max_ch = info.max_ch

	local args = {}
	args.x = info.x
	args.y = info.y
	args.w = info.w
	args.h = info.h

	args.style = self:__info_style(info)
	args.style_ex = self:__info_style_ex(info)

	self:__before_create(info, args)

	self.hwnd = CreateWindow(args)

	--style bits WS_BORDER and WS_DLGFRAME are always set on creation,
	--so we clear them now if we have to.
	if GetWindowStyle(self.hwnd) ~= args.style then
		SetWindowStyle(self.hwnd, args.style)
		SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY) --events not yet routed.
	end

	--style bit WS_EX_WINDOWEDGE is always set on creation,
	--so we clear it now if we have to.
	if GetWindowExStyle(self.hwnd) ~= args.style_ex then
		SetWindowExStyle(self.hwnd, args.style_ex)
		SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY) --events not yet routed.
	end

	--check that style bits are consistent and reject them if they're not.
	self:__check_style(args.style)
	self:__check_style_ex(args.style_ex)

	self:__after_create(info, args)

	self.font = info.font or GetStockObject(DEFAULT_GUI_FONT)

	--initialize post-creation properties in the prescribed order.
	for _,name in ipairs(self.__init_properties) do
		if info[name] then
			self[name] = info[name] --events are not yet routed.
		end
	end

	--register the window so that MessageRouter can track it.
	--hooking WNDPROC to MessageRouter is done in subclasses.
	Windows:add(self)

	--force a resize to apply any constraints.
	self:resize(self.w, self.h)

	--show the window, which was intentionally created without WS_VISIBLE
	--to allow us to set up event routing first.
	if info.visible and not self.visible then
		self.visible = true
	end
end

--destroying -----------------------------------------------------------------

function BaseWindow:free()
	if not self.hwnd then return end
	DestroyWindow(self.hwnd)
end

function BaseWindow:WM_NCDESTROY() --after children are destroyed
	--trigger this manually
	if self.on_destroyed then
		self:on_destroyed()
	end
	Windows:remove(self)
	disown(self.hwnd) --prevent the __gc on hwnd calling DestroyWindow again
	self.hwnd = nil
end

function BaseWindow:get_dead() return self.hwnd == nil end

--message routing ------------------------------------------------------------

function BaseWindow:__handle_message(WM, wParam, lParam)
	--print(WM_NAMES[WM], wParam, lParam)

	--look for a low-level handler self:WM_*()
	local handler = self[WM_NAMES[WM]]
	if handler then
		local ret = handler(self, DecodeMessage(WM, wParam, lParam))
		if ret ~= nil then return ret end
	end

	--look for a hi-level handler self:on_*()
	local handler = self[self.__wm_handler_names[WM]]
	if handler then
		local ret = handler(self, DecodeMessage(WM, wParam, lParam))
		if ret ~= nil then return ret end
	end

	return self:__default_proc(WM, wParam, lParam)
end

--NOTE: controls override this and call CallWindowProc() instead.
function BaseWindow:__default_proc(WM, wParam, lParam)
	return DefWindowProc(self.hwnd, WM, wParam, lParam)
end

--WM_SYSCOMMAND routing ------------------------------------------------------

function BaseWindow:WM_SYSCOMMAND(SC, ...)
	local handler = self[self.__wm_syscommand_handler_names[SC]]
	if handler then return handler(self, ...) end
end

--WM_COMMAND routing ---------------------------------------------------------

function BaseWindow:WM_COMMAND(kind, id, command, hwnd)
	if kind == 'control' then
		local window = Windows:find(hwnd)
		--some controls (eg. combobox) create their own child windows which we
		--don't know about, so the window might not always be found.
		if window then
			local handler = window[window.__wm_command_handler_names[command]]
			if handler then return handler(window) end
		end
	elseif kind == 'menu' then
		--nothing to do there: our Menu class uses MNS_NOTIFYBYPOS so we get
		--WM_MENUCOMMAND instead of WM_COMMAND.
	elseif kind == 'accelerator' then
		--nothing to do here: top-level windows handle accelerators.
	end
end

--WM_NOTIFY routing ----------------------------------------------------------

function BaseWindow:WM_NOTIFY(hwnd, code, ...)

	--find the target windotw.
	local window = Windows:find(hwnd)
	if window == nil then return end

	--look for a low-level handler self:*N_*()
	local handler = window[WM_NOTIFY_NAMES[code]]
	if handler then
		local ret = handler(window, ...)
		if ret ~= nil then return ret end
	end

	--look for a hi-level handler self:on_*()
	local handler = window[window.__wm_notify_handler_names[code]]
	if handler then
		local ret = handler(window, ...)
		if ret ~= nil then return ret end
	end
end

--WM_COMPAREITEM routing -----------------------------------------------------

function BaseWindow:WM_COMPAREITEM(hwnd, ci)
	local window = Windows:find(hwnd)
	if window and window.on_compare_items then
		return window:on_compare_items(ci.i1, ci.i2)
	end
end

--WM_NOTIFYICON routing ------------------------------------------------------

function BaseWindow:WM_NOTIFYICON(id, WM)
	local notify_icon = NotifyIcons:find(id)
	if notify_icon then
		notify_icon:WM_NOTIFYICON(WM)
	end
end

--class properties -----------------------------------------------------------

--NOTE: these will affect all instances that share the same WNDCLASS!

function BaseWindow:get_background() return GetClassBackground(self.hwnd) end
function BaseWindow:set_background(bg) SetClassBackground(self.hwnd, bg) end

function BaseWindow:get_cursor() return GetClassCursor(self.hwnd) end
function BaseWindow:set_cursor(cursor) SetClassCursor(self.hwnd, cursor) end

function BaseWindow:get_icon() return GetClassIcon(self.hwnd) end
function BaseWindow:set_icon(icon) SetClassIcon(self.hwnd, icon) end

function BaseWindow:get_small_icon() GetClassSmallIcon(self.hwnd) end
function BaseWindow:set_small_icon(icon) SetClassSmallIcon(self.hwnd, icon) end

--properties -----------------------------------------------------------------

function BaseWindow:get_text() return GetWindowText(self.hwnd) end
function BaseWindow:set_text(text) SetWindowText(self.hwnd, text) end

function BaseWindow:set_font(font) SetWindowFont(self.hwnd, font) end
function BaseWindow:get_font() return GetWindowFont(self.hwnd) end

function BaseWindow:get_enabled() return IsWindowEnabled(self.hwnd) end
function BaseWindow:set_enabled(enabled) EnableWindow(self.hwnd, enabled) end
function BaseWindow:enable() self.enabled = true end
function BaseWindow:disable() self.enabled = false end

function BaseWindow:get_focused() return GetFocus() == self.hwnd end
function BaseWindow:focus() SetFocus(self.hwnd) end

function BaseWindow:children(recursive)
	local t
	if recursive then
		t = EnumChildWindows(self.hwnd)
	else
		t = {}
		for win in GetChildWindows(self.hwnd) do
			t[#t+1] = win
		end
	end
	local i = 0
	return function()
		i = i + 1
		return Windows:find(t[i])
	end
end


function BaseWindow:get_cursor_pos()
	return Windows:get_cursor_pos(self)
end

function BaseWindow:get_monitor(flag)
	return MonitorFromWindow(self.hwnd, flag)
end

--visibility -----------------------------------------------------------------

--show(true|nil) = show in current state.
--show(false) = show in current state but don't activate.
function BaseWindow:show(SW, async)
	SW = flags((SW == nil or SW == true) and SW_SHOW or SW == false and SW_SHOWNA or SW)
	local ShowWindow = async and ShowWindowAsync or ShowWindow
	ShowWindow(self.hwnd, SW)
	--NOTE: The SW arg is ignored the first time an app calls ShowWindow()
	--_on a top-level window_ (msdn is not accurate about this detail).
	--Instead, the SW flag in STARTUPINFO is used (which for luajit.exe is SW_HIDE).
	--So unless SW_SHOWDEFAULT is explicitly requested, ShowWindow() is called again.
	--NOTE: if async is used, ShowWindow() is not called twice, call it yourself then!
	if not async and SW ~= SW_HIDE and SW ~= SW_SHOWDEFAULT and not self.visible then
		ShowWindow(self.hwnd, SW)
	end
end

function BaseWindow:hide(async)
	self:show(SW_HIDE, async)
end

function BaseWindow:get_is_visible() --visible and all parents are visible too
	return IsWindowVisible(self.hwnd)
end

function BaseWindow:get_visible()
	return getbit(GetWindowStyle(self.hwnd), WS_VISIBLE)
end

function BaseWindow:set_visible(visible)
	if visible then self:show() else self:hide() end
end

--size and position ----------------------------------------------------------

function BaseWindow:move(x, y)
	local flags = bit.bor(SWP_NOZORDER, SWP_NOOWNERZORDER, SWP_NOACTIVATE, SWP_NOSIZE)
	SetWindowPos(self.hwnd, nil, x, y, 0, 0, flags)
end

function BaseWindow:resize(w, h)
	local flags = bit.bor(SWP_NOZORDER, SWP_NOOWNERZORDER, SWP_NOACTIVATE, SWP_NOMOVE)
	SetWindowPos(self.hwnd, nil, 0, 0, w, h, flags)
end

function BaseWindow:set_rect(...) --x1,y1,x2,y2 or rect
	local r = RECT(...)
	local flags = bit.bor(SWP_NOZORDER, SWP_NOOWNERZORDER, SWP_NOACTIVATE)
	SetWindowPos(self.hwnd, nil, r.x, r.y, r.w, r.h, flags)
end

--frame rect in client coordinates of parent (or screen coordinates if no parent).
function BaseWindow:get_rect(r)
	return MapWindowRect(nil, GetParent(self.hwnd), GetWindowRect(self.hwnd, r))
end

function BaseWindow:get_x() return self.rect.x end
function BaseWindow:get_y() return self.rect.y end
function BaseWindow:get_w() return self.rect.w end
function BaseWindow:get_h() return self.rect.h end
function BaseWindow:set_x(x) self:move(x, self.rect.y) end
function BaseWindow:set_y(y) self:move(self.rect.y, y) end
function BaseWindow:set_w(w) self:resize(w, self.rect.h) end
function BaseWindow:set_h(h) self:resize(self.rect.w, h) end

--frame rect in screen coordinates.
function BaseWindow:get_screen_rect(r)
	return GetWindowRect(self.hwnd, r)
end

--client rectangle, relative to itself i.e. it's top-left corner is (0,0).
function BaseWindow:get_client_rect(r)
	return GetClientRect(self.hwnd, r)
end

function BaseWindow:get_client_w()
	return GetClientRect(self.hwnd).x2
end

function BaseWindow:get_client_h()
	return GetClientRect(self.hwnd).y2
end

--client POINT -> client POINT of other window
function BaseWindow:map_point(to_window, ...) --x,y or point
	return MapWindowPoint(self.hwnd, to_window and to_window.hwnd, ...)
end

--client RECT -> client RECT of other window
function BaseWindow:map_rect(to_window, ...) --x1,y1,x2,y2 or rect
	return MapWindowRect(self.hwnd, to_window and to_window.hwnd, ...)
end

--frame-rect - client-rect relationship --------------------------------------

--class method: screen RECT of client area -> screen RECT of window frame.
--info should contain window attributes specific to how the frame should look.
--used as instance method if info is nil.
function BaseWindow:client_to_frame(info, ...) --x1,y1,x2,y2 or rect
	local rect = RECT(...)
	local style, style_ex, has_menu
	if info then
		info = glue.update({}, self.__defaults, info)
		style = self:__info_style(info)
		style_ex = self:__info_style_ex(info)
		has_menu = info.menu ~= nil
	else
		style = GetWindowStyle(self.hwnd)
		style_ex = GetWindowExStyle(self.hwnd)
		has_menu = self.menu ~= nil
	end
	return AdjustWindowRect(rect, style, style_ex, has_menu)
end

--class method: screen RECT of window frame -> screen RECT of client area.
--info should contain window attributes specific to how the frame should look.
--used as instance method if info is nil.
function BaseWindow:frame_to_client(info, ...) --x1,y1,x2,y2 or rect
	local cr = RECT(...)
	local dr = self:client_to_frame(info, 0, 0, 200, 200)
	cr.x1 = cr.x1 - dr.x1
	cr.y1 = cr.y1 - dr.y1
	cr.x2 = cr.x2 - (dr.w - 200) - dr.x
	cr.y2 = cr.y2 - (dr.h - 200) - dr.y
	return cr
end

--size constraints -----------------------------------------------------------

--operation with optional operands
local function optop(op, x, y)
	return x and y and op(x, y) or x or y
end

--compute frame rect constraints based on frame rect and client rect constraints.
function BaseWindow:__constraints()

	--get frame rect constraints.
	local min_w = self.min_w
	local min_h = self.min_h
	local max_w = self.max_w
	local max_h = self.max_h

	--mix them with client rect constraints.
	if self.min_cw or self.min_ch or self.max_cw or self.max_ch then
		local dr = self:client_to_frame(nil, 0, 0, 200, 200)
		local dw = dr.w - 200
		local dh = dr.h - 200
		min_w = optop(math.max, min_w, self.min_cw and self.min_cw + dw)
		min_h = optop(math.max, min_h, self.min_ch and self.min_ch + dh)
		max_w = optop(math.min, max_w, self.max_cw and self.max_cw + dw)
		max_h = optop(math.min, max_h, self.max_ch and self.max_ch + dh)
	end

	return min_w, min_h, max_w, max_h
end

--parent resizing event ------------------------------------------------------

--called on all direct children of a window to give them an opportunity
--to adjust their rect or the rect of the parent when the parent is resized.
function BaseWindow:__parent_resizing(wp)
	if self.on_parent_resizing then
		self:on_parent_resizing(wp)
	end
end

function BaseWindow:WM_WINDOWPOSCHANGING(wp)
	if not getbit(wp.flags, SWP_NOSIZE) then
		--this is to enable anchors and constraints in child windows.
		for child in self:children() do
			child:__parent_resizing(wp)
		end
	end
end

--hit testing ----------------------------------------------------------------

function BaseWindow:child_at(...) --x,y or point
	return Windows:find(ChildWindowFromPoint(self.hwnd, ...))
end

function BaseWindow:real_child_at(...) --x,y or point
	return Windows:find(RealChildWindowFromPoint(self.hwnd, ...))
end

--z order --------------------------------------------------------------------

function BaseWindow:send_to_back(relto)
	local relto_hwnd = relto and relto.hwnd or HWND_BOTTOM
	SetWindowPos(self.hwnd, relto_hwnd, 0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
end

function BaseWindow:bring_to_front(relto)
	local relto_hwnd = relto and GetPrevSibling(relto.hwnd) or HWND_TOP
	SetWindowPos(self.hwnd, relto_hwnd, 0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
end

--rendering ------------------------------------------------------------------

function BaseWindow:set_updating(updating)
	if not self.visible then return end
	SetRedraw(self.hwnd, not updating)
end

function BaseWindow:batch_update(f, ...)
	if not self.visible or self.updating then
		f(...) --calling batch_update() inside batch_update()
		return
	end
	self.updating = true
	local ok,err = pcall(f,...)
	self.updating = false
	self:redraw()
	assert(ok, err)
end

function BaseWindow:redraw()
	RedrawWindow(self.hwnd, nil,
		bit.bor(RDW_ERASE, RDW_FRAME, RDW_INVALIDATE, RDW_ALLCHILDREN))
end

function BaseWindow:invalidate(r, erase_background)
	InvalidateRect(self.hwnd, r, erase_background ~= false)
end

function BaseWindow:__WM_PAINT_pass(ok, err)
	EndPaint(self.hwnd, self.__paintstruct)
	if not ok then error(err, 4) end
end

function BaseWindow:WM_PAINT()
	if self.on_paint then
		self.__paintstruct = types.PAINTSTRUCT(self.__paintstruct)
		local hdc = BeginPaint(self.hwnd, self.__paintstruct)
		self:__WM_PAINT_pass(xpcall(self.on_paint, debug.traceback, self, hdc))
		return 0
	end
end

--drag & drop ----------------------------------------------------------------

function BaseWindow:dragging(...)
	return DragDetect(self.hwnd, POINT(...))
end

--timers ---------------------------------------------------------------------

--NOTE: passing an existing id replaces that timer.
function BaseWindow:settimer(seconds, handler, id)
	self.__timers = self.__timers or {}
	id = id or #self.__timers + 1
	assert(id > 0) --id 0 only works if passing a callback to SetTimer()
	SetTimer(self.hwnd, id, seconds * 1000)
	self.__timers[id] = handler
	return id
end

function BaseWindow:stoptimer(id)
	id = tonumber(id)
	KillTimer(self.hwnd, id)
	self.__timers[id] = nil
end

function BaseWindow:WM_TIMER(id)
	id = tonumber(id)
	local callback = self.__timers and self.__timers[id]
	if callback then
		if callback(self, id) == false then --returning false kills the timer
			self:stoptimer(id)
		end
	end
end

