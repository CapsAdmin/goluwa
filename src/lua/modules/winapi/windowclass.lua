
--oo/windows/window: overlapping (aka top-level) windows
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.basewindowclass'
require'winapi.menuclass'
require'winapi.color'
require'winapi.cursor'
require'winapi.waitemlistclass'

Window = subclass({
	__class_style_bitmask = bitmask{ --only static, frame styles here
		closeable = negate(CS_NOCLOSE), --enable close button and ALT+F4
		dropshadow = CS_DROPSHADOW, --only for non-movable windows
		own_dc = CS_OWNDC, --for opengl or other purposes
		receive_double_clicks = CS_DBLCLKS, --receive double click messages
	},
	__style_bitmask = bitmask{ --only static, frame styles here
		border = WS_BORDER, 		--a frameless window is one without WS_BORDER, WS_DLGFRAME, WS_SIZEBOX and WS_EX_WINDOWEDGE
		frame = WS_DLGFRAME,    --for the titlebar to appear you need both WS_BORDER and WS_DLGFRAME
		minimizable = WS_MINIMIZEBOX,
		maximizable = WS_MAXIMIZEBOX,
		resizeable = WS_SIZEBOX,  --needs WS_DLGFRAME
		sysmenu = WS_SYSMENU,   --not setting this hides all buttons
		vscroll = WS_VSCROLL,
		hscroll = WS_HSCROLL,
		clip_children = WS_CLIPCHILDREN,
		clip_siblings = WS_CLIPSIBLINGS,
		child = WS_CHILD, --needed for windows with WS_EX_TOOLWINDOW + WS_EX_NOACTIVATE!
	},
	__style_ex_bitmask = bitmask{
		topmost = WS_EX_TOPMOST,
		window_edge = WS_EX_WINDOWEDGE,  --needs to be the same as WS_DLGFRAME
		dialog_frame = WS_EX_DLGMODALFRAME, --double border and no system menu icon!
		help_button = WS_EX_CONTEXTHELP, --only shown if both minimize and maximize buttons are hidden
		tool_window = WS_EX_TOOLWINDOW,
		transparent = WS_EX_TRANSPARENT, --makes clicks go through where alpha == 255
		layered = WS_EX_LAYERED, --setting this makes a completely frameless window regardless of other styles
		control_parent = WS_EX_CONTROLPARENT, --recurse when looking for the next control with WS_TABSTOP
		activable = negate(WS_EX_NOACTIVATE), --don't activate and don't show on taskbar (but see notes in window.lua!)
		taskbar_button = WS_EX_APPWINDOW, --force showing a button on taskbar for this window
	},
	__defaults = {
		--class style bits
		closeable = true,
		dropshadow = false,
		own_dc = false,
		receive_double_clicks = true,
		--window style bits
		border = true,
		frame = true,
		minimizable = true,
		maximizable = true,
		resizeable = true, --...and has a 3px resizing border
		sysmenu = true,
		vscroll = false,
		hscroll = false,
		clip_children = true,
		clip_siblings = true,
		child = false,
		--window ex style bits
		topmost = false,
		window_edge = true,
		dialog_frame = false,
		help_button = false,
		tool_window = false,
		transparent = false,
		layered = false,
		control_parent = true,
		activable = true,
		taskbar_button = false,
		--class properties
		background = COLOR_WINDOW,
		cursor = LoadCursor(IDC_ARROW),
		--window properties
		title = '',
		x = CW_USEDEFAULT,
		y = CW_USEDEFAULT,
		w = CW_USEDEFAULT,
		h = CW_USEDEFAULT,
		autoquit = false,
		menu = nil,
		--behavior
		remember_maximized_pos = false, --see below for explanation of this flag
	},
	__init_properties = {
		'menu',
		'autoquit', --quit the app when the window closes
	},
	__wm_handler_names = index{
		on_close = WM_CLOSE,
		on_unminimizing = WM_QUERYOPEN, --return false to prevent.
		on_get_minmax_info = WM_GETMINMAXINFO,
		--system changes
		on_query_end_session = WM_QUERYENDSESSION,
		on_end_session = WM_ENDSESSION,
		on_system_color_change = WM_SYSCOLORCHANGE,
		on_settings_change = WM_SETTINGCHANGE,
		on_device_mode_change = WM_DEVMODECHANGE,
		on_fonts_change = WM_FONTCHANGE,
		on_time_change = WM_TIMECHANGE,
		on_spooler_change = WM_SPOOLERSTATUS,
		on_input_language_change = WM_INPUTLANGCHANGE,
		on_user_change = WM_USERCHANGED,
		on_display_change = WM_DISPLAYCHANGE,
	},
	__wm_syscommand_handler_names = index{
		on_minimizing = SC_MINIMIZE, --before minimize; return false to prevent.
		on_maximizing = SC_MAXIMIZE, --before maximize; return false to prevent.
		on_menu_key   = SC_KEYMENU,  --get the 'f' in Alt+F if there's a `&File` menu.
		on_restoring  = SC_RESTORE,
	},
}, BaseWindow)

--instantiating --------------------------------------------------------------

local n = 0
local function gen_classname()
	n = n + 1
	return 'Window'..n
end

function Window:__info_style(info)
	local style = Window.__index.__info_style(self, info)
	--NOTE: WS_MINIMIZE and WS_MAXIMIZE flags don't work together: combining
	--them makes ShowWindow(SW_RESTORE) have no effect. Instead, when both are
	--needed, we set WS_MINIMIZE only and then set self.restore_to_maximized.
	return bit.bor(style,
		info.minimized and WS_MINIMIZE or 0,
		info.maximized and not info.minimized and WS_MAXIMIZE or 0)
end

function Window:__before_create(info, args)
	Window.__index.__before_create(self, info, args)

	local class_args = {}
	class_args.name = gen_classname()
	class_args.style = self.__class_style_bitmask:set(0, info)
	class_args.proc = MessageRouter.proc
	class_args.icon = info.icon
	class_args.small_icon = info.small_icon
	class_args.cursor = info.cursor
	class_args.background = info.background
	args.class = RegisterClass(class_args)

	args.parent = info.owner and info.owner.hwnd
	args.text = info.title

	--properties affecting the maximized size and position
	self.remember_maximized_pos = info.remember_maximized_pos
	self.__state.maximized_pos = info.maximized_pos
	self.__state.maximized_size = info.maximized_size

	self.__winclass = args.class --for unregistering
	self.__winclass_style = class_args.style --for checking
end

function Window:__after_create(info, args)

	self:__check_class_style(self.__winclass_style)
	self.__winclass_style = nil --we're done with this

	--when WS_MINIMIZED is present we don't want to set WS_MAXIMIZED.
	if info.maximized and info.minimized then
		self.restore_to_maximized = true
	end

	self.accelerators = WAItemList(self)
end

--destroying -----------------------------------------------------------------

function Window:close()
	CloseWindow(self.hwnd)
end

function Window:WM_NCDESTROY()
	Window.__index.WM_NCDESTROY(self)

	--free the menu bar, if any.
	if self.menu then
		self.menu:free()
	end

	--post a message to unregister the window's class after the window is destroyed.
	PostMessage(nil, WM_UNREGISTER_CLASS, self.__winclass)

	--post WM_QUIT to stop the message loop, if autoquit is set.
	if self.autoquit then
		PostQuitMessage()
	end
end

--properties -----------------------------------------------------------------

Window.get_title = BaseWindow.get_text
Window.set_title = BaseWindow.set_text

function Window:get_owner()
	return Windows:find(GetWindowOwner(self.hwnd))
end

function Window:set_owner(owner)
	SetWindowOwner(self.hwnd, owner and owner.hwnd)
end

--activation -----------------------------------------------------------------

function Window:get_active() return GetActiveWindow() == self.hwnd end
function Window:get_foreground() return GetForegroundWindow() == self.hwnd end
function Window:activate() SetActiveWindow(self.hwnd) end

--this is different than activate() in that the window flashes in the taskbar
--if its thread is not currently the active thread.
function Window:setforeground()
	SetForegroundWindow(self.hwnd)
end

function Window:WM_ACTIVATE(flag, minimized, other_hwnd)
	if flag == 'active' or flag == 'clickactive' then
		if self.on_activate then
			self:on_activate(Windows:find(other_hwnd))
		end
	elseif flag == 'inactive' then
		if self.on_deactivate then
			self:on_deactivate(Windows:find(other_hwnd))
		end
	end
end

function Window:WM_ACTIVATEAPP(flag, other_thread_id)
	if flag == 'active' then
		if self.on_activate_app then
			self:on_activate_app(other_thread_id)
		end
	elseif flag == 'inactive' then
		if self.on_deactivate_app then
			self:on_deactivate_app(other_thread_id)
		end
	end
end

function Window:WM_NCACTIVATE(flag, update_hrgn)
	if flag == 'active' then
		if self.on_nc_activate then
			self:on_nc_activate(update_hrgn)
		end
	elseif flag == 'inactive' then
		if self.on_nc_deactivate then
			self:on_nc_deactivate(update_hrgn)
		end
	end
end

--constraints & maximized size and position ----------------------------------

function Window:WM_GETMINMAXINFO(info)

	--compute and apply any size constraints.
	local min_w, min_h, max_w, max_h = self:__constraints()

	if min_w then info.ptMinTrackSize.w = min_w end
	if min_h then info.ptMinTrackSize.h = min_h end
	if max_w then info.ptMaxTrackSize.w = max_w end
	if max_h then info.ptMaxTrackSize.h = max_h end

	--maximize to last position.
	if self.__maximized_pos then
		info.ptMaxPosition = self.__maximized_pos
	end

	--maximize to user position.
	if self.maximized_pos then
		info.ptMaxPosition = self.maximized_pos
	end

	--maximize to user size.
	if self.maximized_size then
		info.ptMaxSize = self.maximized_size
	end
end

function Window:WM_WINDOWPOSCHANGED(wp)
	--NOTE: A maximized window becomes movable if its size is smaller than
	--the entire screen (WinXP only, in Win7+ it is unmaximized when moved).
	--A window can have such smaller maximized size if constrained.
	--But when such a window is maximized, in absence of a programmer-supplied
	--maximized_pos, it always moves to the top-left corner of the screen,
	--which is lame. A much better option is to remember the last maximized
	--position and restore to that position instead, when maximized again.
	--Which is what we do here.
	if self.remember_maximized_pos and not getbit(wp.flags, SWP_NOMOVE) then
		if self.maximized and not self.minimized then
			self.__maximized_pos = POINT(self.__maximized_pos)
			self.__maximized_pos.x = wp.x
			self.__maximized_pos.y = wp.y
		end
	end
end

--window state ---------------------------------------------------------------

--NOTE: minimized state is preserved between hide() and show() calls.
function Window:get_minimized()
	return IsIconic(self.hwnd)
end

--NOTE: when a maximized window is minimized, the maximized flag becomes false,
--and the restore_to_maximized flag becomes true.
function Window:get_maximized()
	return IsZoomed(self.hwnd)
end

--minimize (or show minimized if hidden) and deactivate or not.
function Window:minimize(deactivate, async)
	self:show(deactivate == false and SW_SHOWMINIMIZED or SW_MINIMIZE, async)
end

--maximize (or show maximized if hidden) and activate.
--NOTE: can't maximize without activating; WM_COMMAND/SC_MAXIMIZE also activates.
function Window:maximize(_, async)
	self:show(SW_SHOWMAXIMIZED, async)
end

--restore to normal state (or show in normal state) and activate or not.
function Window:shownormal(activate, async)
	self:show(activate == false and SW_SHOWNOACTIVATE or SW_SHOWNORMAL, async)
end

--restore to last state and activate:
-- 1) if minimized, restore to normal or maximized state.
-- 2) if maximized, restore to normal state.
--NOTE: retore-to-maximized doesn't work with async=true.
function Window:restore(_, async)
	self:show(SW_RESTORE, async)
end

--normal rectangle -----------------------------------------------------------

--normal_rect is the frame rectangle in normal state.
--it can be get/set any time without affecting the current state of the window.

function Window:get_normal_rect()
	return GetWindowPlacement(self.hwnd).rcNormalPosition
end

--clamp with optional min and max, where min takes precedence over max.
local function clamp(x, min, max)
	if max and min and max < min then max = min end
	if min then x = math.max(x, min) end
	if max then x = math.min(x, max) end
	return x
end

function Window:set_normal_rect(...) --x1,y1,x2,y2 or rect
	local wp = GetWindowPlacement(self.hwnd)
	local r = RECT(...)

	--must apply constraints manually if maximized.
	if self.maximized then
		local minw, minh, maxw, maxh = self:__constraints()
		if minw or minh or maxw or maxh then
			r.x2 = r.x1 + clamp(r.w, minw, maxw)
			r.y2 = r.y1 + clamp(r.h, minh, maxh)
		end
	end

	wp.rcNormalPosition = r
	if not self.visible then wp.showCmd = SW_HIDE end --don't show it if hidden!
	SetWindowPlacement(self.hwnd, wp)
end

--restore state --------------------------------------------------------------

--control the behavior of the next call to restore().
--NOTE: only works when the window is minimized!

function Window:get_restore_to_maximized()
	local wp = GetWindowPlacement(self.hwnd)
	if wp.showCmd == SW_SHOWMINIMIZED then
		return getbit(wp.flags, WPF_RESTORETOMAXIMIZED)
	end
end

function Window:set_restore_to_maximized(yes)
	local wp = GetWindowPlacement(self.hwnd)

	if wp.showCmd ~= SW_SHOWMINIMIZED then return end

	wp.flags = yes and
		bit.bor(wp.flags, WPF_RESTORETOMAXIMIZED) or
		bit.band(wp.flags, bit.bnot(WPF_RESTORETOMAXIMIZED))

	--NOTE: wp.showCmd is SW_SHOWMINIMIZED even when the window is hidden,
	--so calling SetWindowPlacement() will show the window which we don't want.
	if not self.visible then
		wp.showCmd = SW_HIDE
	end

	SetWindowPlacement(self.hwnd, wp)
end

--z order --------------------------------------------------------------------

function Window:set_topmost(topmost)
	SetWindowPos(self.hwnd, topmost and HWND_TOPMOST or HWND_NOTOPMOST,
		0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
end

function Window:send_to_back(relto)
	local topmost = self.topmost
	local relto_hwnd = relto and relto.hwnd or (self.topmost and HWND_NOTOPMOST or HWND_BOTTOM)
	SetWindowPos(self.hwnd, relto_hwnd, 0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
	if topmost then
		--self.topmost = true
	end
end

function Window:bring_to_front(relto)
	local relto_hwnd = relto and GetPrevSibling(relto.hwnd) or (self.topmost and HWND_TOPMOST or HWND_TOP)
	SetWindowPos(self.hwnd, relto_hwnd, 0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
end

--menus ----------------------------------------------------------------------

function Window:get_menu()
	return Menus:find(GetMenu(self.hwnd))
end

function Window:set_menu(menu)
	if self.menu then self.menu:__set_window(nil) end
	SetMenu(self.hwnd, menu and menu.hmenu)
	if menu then menu:__set_window(self) end
end

function Window:WM_MENUCOMMAND(menu, i)
	menu = Menus:find(menu)
	if menu.WM_MENUCOMMAND then menu:WM_MENUCOMMAND(i) end
end

--rendering ------------------------------------------------------------------

function Window:WM_CTLCOLORSTATIC(wParam, lParam)
	 --TODO: fix group box
	 do return end
	 local hBackground = CreateSolidBrush(RGB(0, 0, 0))
	 local hdc = ffi.cast('HDC', wParam)
    SetBkMode(hdc, OPAQUE)
    SetTextColor(hdc, RGB(100, 100, 0))
	 return tonumber(hBackground)
end

--accelerators ---------------------------------------------------------------

function Window:WM_COMMAND(kind, id, ...)
	if kind == 'accelerator' then
		self.accelerators:WM_COMMAND(id) --route message to individual accelerators
	end
	Window.__index.WM_COMMAND(self, kind, id, ...)
end

--showcase -------------------------------------------------------------------

if not ... then
require'winapi.icon'
require'winapi.font'

local c = Window{title = 'Main',
	border = true, frame = true, window_edge = true, resizeable = true, control_parent = true,
	help_button = true, maximizable = false, minimizable = false, maximized = true,
	autoquit = true, w = 500, h = 300, visible = false}
c:show()

c.cursor = LoadCursor(IDC_HAND)
c.icon = LoadIconFromInstance(IDI_INFORMATION)

print('shown     ', c.visible, c.minimized, c.maximized)
c:maximize()
print('maximized ', c.visible, c.minimized, c.maximized)
c:minimize()
print('minimized ', c.visible, c.minimized, c.maximized)
c:show()
print('shown     ', c.visible, c.minimized, c.maximized)
c:restore()
print('restored  ', c.visible, c.minimized, c.maximized)
c:shownormal()
print('shownormal', c.visible, c.minimized, c.maximized)

local c3 = Window{topmost = true, title='Topmost', h = 300, w = 300, resizeable = false}

local c2 = Window{title = 'Owned by Main', frame = true, w = 500, h = 100, visible = true, owner = c,
							--taskbar_button = true --force a button on taskbar even when owned
							}
c2.min_w=200; c2.min_h=200
c2.max_w=300; c2.max_h=300

local c4 = Window{x = 400, y = 400, w = 400, h = 200,
						border = true,
						frame = false,
						window_edge = false,
						--dialog_frame = false,
						resizeable = false,
						owner = c,
						}

function c:on_key_down(vk, flags)
	print('WM_KEYDOWN', vk, flags)
end

function c:on_key_down_char(char, flags)
	print('WM_CHAR', char, flags)
end

function c:on_lbutton_double_click()
	print'double clicked'
end

c.__wantallkeys = true

c3:minimize()
c3:activate()
c3:minimize()

MessageLoop()

end

