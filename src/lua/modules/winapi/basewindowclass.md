---
tagline: base class for windows and controls
---

## `require'winapi.basewindowclass'`

This module implements the `BaseWindow` class which is the base class
for both top-level windows and controls. The module also contains
the message loop and the `Windows` singleton which deals with windows
(top-level or not) as a collection.

`BaseWindow` is for subclassing, not for instantiation. Nevertheless,
it contains properties and methods that are common to both windows
and controls which are documented here.

## BaseWindow

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* BaseWindow

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- -------------------------- ----------------- ---------------------
__state__					__irw__	__description__				__default__			__reference__
visible						irw		visibility						true					WS_VISIBLE
is_visible					 r			is actually visible?									IsWindowVisible
enabled						irw		focusability					true					WS_DISABLED
focused						 rw		focused state											GetFocus
dead							 r			was it destroyed?										WM_NCDESTROY
__positioning__			__irw__	__description__				__default__			__reference__
x, y							irw		position													SetWindowPos
w, h							irw		size														SetWindowPos
rect							 rw		outer rect (RECT)										SetWindowPos
client_w, client_h		 r			inner size												GetClientRect
client_rect					 r			inner rect (RECT)										GetClientRect
screen_rect					 r			outer rect in screen space							GetWindowRect
min_w, min_h				irw		minimum size											WM_WINDOWPOSCHANGING
max_w, max_h				irw		maximum size											WM_WINDOWPOSCHANGING
monitor						 r			monitor (HMONITOR)									MonitorFromWindow
__painting__				__irw__	__description__				__default__			__reference__
updating						 w			control automatic radraw							SetRedraw
__other__					__irw__	__description__				__default__			__reference__
font							irw		default font					DEFAULT_GUI_FONT	Get/SetWindowFont
text							 rw		depends on control									Get/SetWindowText
cursor_pos					 r			mouse position (POINT)								GetCursorPos
----------------------- -------- -------------------------- ----------------- ---------------------
</div>

### Methods

<div class=small>
-------------------------------------- -------------------------------------------- ----------------------
__state__										__description__										__reference__
enable()											enable													EnableWindow
disable()										disable													EnableWindow
focus()											focus														SetFocus
show([async])									show														ShowWindow
hide()											hide														ShowWindow
__positioning__								__description__										__reference__
move(x, y)										move														SetWindowPos
resize(w, h)									resize													SetWindowPos
map_point(to_win, POINT) -> POINT		map a POINT to a window's space					MapWindowPoint
map_rect(to_win, RECT) -> RECT			map a RECT to a window's space					MapWindowRect
client_to_frame(nil, RECT) -> RECT		inner->outer frame space conversion				AdjustWindowRect
frame_to_client(nil, RECT) -> RECT		outer->inner frame space conversion				AdjustWindowRect
__children__									__description__										__reference__
children([all]) -> iter() -> win			iterate children										Get/EnumChildWindows
child_at(POINT) -> win						direct child window at position					ChildWindowFromPoint
real_child_at(POINT) -> win 				same but ignore transparent ones					RealChildWindowFromPoint
__z-order__										__description__										__reference__
send_to_back([rel_to_win])					move below of other windows						SetWindowPos
bring_to_front([rel_to_win])				bring in front of other windows					SetWindowPos
__painting__									__description__										__reference__
redraw()											redraw the window immediately						RedrawWindow
invalidate([RECT], [erase_bg])			invalidate the window or a subregion			InvalidateRect
batch_update(func, args...)				run func() with redrawing desabled				SetRedraw/RedrawWindow
__drag & drop__								__description__										__reference__
dragging(POINT) -> true|false				check if dragging										DragDetect
__timers__										__description__										__reference__
settimer(seconds, handler, id)			set/reset a timer										SetTimer
stoptimer(id)									cancel a timer											KillTimer
-------------------------------------- -------------------------------------------- ----------------------
</div>

### Events

<div class=small>
-------------------------------------------- -------------------------------------- -------------------------
__lifetime__											__description__								__reference__
on_destroy()											before destroying								WM_DESTROY
on_destroyed()											after being destroyed						WM_NCDESTROY
__state__												__description__								__reference__
on_pos_changing(WINDOWPOS)							resizing (or changing state)				WM_WINDOWPOSCHANGING
on_parent_resizing(WINDOWPOS)						parent is resizing							WM_WINDOWPOSCHANGING
on_pos_changed()										resized or state changed					WM_WINDOWPOSCHANGED
on_moving()												moving 											WM_MOVING
on_moved()												was moved										WM_MOVE
on_resizing()											resizing											WM_SIZING
on_resized()											was resized										WM_SIZE
on_begin_sizemove()									moving or resizing started					WM_ENTERSIZEMOVE
on_end_sizemove()										moving or resizing ended					WM_EXITSIZEMOVE
on_focus()												was focused										WM_SETFOCUS
on_blur()												was unfocused									WM_KILLFOCUS
on_enable(enabled)									was enabled or disabled						WM_ENABLE
on_show()												was shown										WM_SHOWWINDOW
__mouse__												__description__								__reference__
on_mouse_move(x, y, btns)							mouse moved										WM_MOUSEMOVE
on_mouse_over(x, y, btns)							mouse entered the client area (*) 		WM_MOUSEHOVER
on_mouse_leave()										mouse left the client area (*)			WM_MOUSELEAVE
on_lbutton_double_click(x, y, btns) 			left mouse button double-click			WM_LBUTTONDBLCLK
on_lbutton_down(x, y, btns)						left mouse button down						WM_LBUTTONDOWN
on_lbutton_up(x, y, btns)							left mouse button up							WM_LBUTTONUP
on_mbutton_double_click(x, y, btns)				middle mouse button double-click			WM_MBUTTONDBLCLK
on_mbutton_down(x, y, btns)						middle mouse button down					WM_MBUTTONDOWN
on_mbutton_up(x, y, btns)							middle mouse button up						WM_MBUTTONUP
on_rbutton_double_click(x, y, btns)				right mouse button double-click			WM_RBUTTONDBLCLK
on_rbutton_down(x, y, btns)						right mouse button down						WM_RBUTTONDOWN
on_rbutton_up(x, y, btns)							right mouse button up						WM_RBUTTONUP
on_xbutton_double_click(x, y, btns, which)	other mouse button double-click			WM_XBUTTONDBLCLK
on_xbutton_down(x, y, btns, which)				other mouse button down						WM_XBUTTONDOWN
on_xbutton_up(x, y, btns, which)					other mouse button up						WM_XBUTTONUP
on_mouse_wheel(x, y, btns, delta)				mouse wheel roll								WM_MOUSEWHEEL
on_mouse_hwheel(x, y, btns, delta)				mouse horizontal wheel roll				WM_MOUSEHWHEEL
on_set_cursor()										cursor changed									WM_SETCURSOR
__keyboard__											__description__								__reference__
on_key_down(VK_code, flags)						key down											WM_KEYDOWN
on_key_up(VK_code, flags)							key up											WM_KEYUP
on_syskey_down(VK_code, flags)					syskey down										WM_SYSKEYDOWN
on_syskey_up(VK_code, flags)						syskey up										WM_SYSKEYUP
on_key_down_char(utf8_char, flags)				key down	char									WM_CHAR
on_syskey_down_char(utf8_char, flags)			syskey down char								WM_SYSCHAR
on_dead_key_up_char(VK_code, flags)				dead key up char								WM_DEADCHAR
on_dead_syskey_down_char(VK_code, flags)		dead syskey down char						WM_SYSDEADCHAR
on_help()												user pressed F1								WM_HELP
__raw input__											__description__								__reference__
on_raw_input(RAWINPUT)								raw input event								WM_INPUT
on_device_change(how, HRAWINPUT)					input device added/removed					WM_INPUT_DEVICE_CHANGE
__system events__										__description__								__reference__
on_dpi_changed()										monitor's DPI changed						WM_DPICHANGED
__painting__											__description__								__reference__
on_paint(hdc)											window needs repainting						WM_PAINT
-------------------------------------------- -------------------------------------- -------------------------

(*) call `TrackMouseEvent()` to receive these messages.

</div>

## Windows

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [HandleList][winapi.handlelist]
			* Windows

### Properties and methods

<div class=small>
-------------------------------------------- -------------------------------------------- ----------------
__field/method__										__description__										__reference__
Windows.items -> {HWND -> win}					the HWND->window map
Windows.active_window -> win						get the active window
Windows.foreground_window -> win | nil			get the active window if the app is active
Windows:window_at(POINT) -> win | nil			get the window at a point
Windows:map_point(to_win, POINT) -> POINT		map a POINT to a window's space
Windows:map_rect(to_win, RECT) -> RECT			map a RECT to a window's space
Windows.cursor_pos -> POINT						current mouse position outside of events
-------------------------------------------- --------------------------------------------- ----------------

> __NOTE:__ The active window goes nil when the app is deactivated,
but if activate() is called on a window while the app is inactive,
the window's active state will be set immediately, even if the window
will not be activated (because the app is inactive). OTOH, the foreground
window is always nil while the app is inactive, even after calling
activate() on a window.

</div>

## The message loop

<div class=small>
-------------------------------------- -----------------------------------------------------------------------
`MessageLoop()`								start the message loop
`ProcessNextMessage() -> true|false`	process the next pending message (return true if there even was one)
`ProcessMessages()`							process all pending messages (if any) and return
`PostQuitMessage()`							post a quit message to the message loop to stop it
-------------------------------------- -----------------------------------------------------------------------

> __NOTE:__ The message loop returns an exit code, so you can call it
like this: `os.exit(MessageLoop())`.

</div>
