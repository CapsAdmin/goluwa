
--proc/windows/window: Windows (as in HWND) API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winuser'
require'winapi.windowclasses'
require'winapi.gdi'

--creation

ffi.cdef[[
HWND CreateWindowExW(
     DWORD dwExStyle,
     LPCWSTR lpClassName,
     LPCWSTR lpWindowName,
     DWORD dwStyle,
     int X,
     int Y,
     int nWidth,
     int nHeight,
     HWND hWndParent,
     HMENU hMenu,
     HINSTANCE hInstance,
     LPVOID lpParam);

BOOL DestroyWindow(HWND hWnd);
]]

WS_OVERLAPPED    = 0x00000000 --no bits!
WS_POPUP         = 0x80000000
WS_CHILD         = 0x40000000
WS_MINIMIZE      = 0x20000000
WS_VISIBLE       = 0x10000000
WS_DISABLED      = 0x08000000
WS_CLIPSIBLINGS  = 0x04000000
WS_CLIPCHILDREN  = 0x02000000
WS_MAXIMIZE      = 0x01000000
WS_CAPTION       = 0x00C00000 --WS_BORDER + WS_DLGFRAME (always set on creation)
WS_BORDER        = 0x00800000
WS_DLGFRAME      = 0x00400000
WS_VSCROLL       = 0x00200000
WS_HSCROLL       = 0x00100000
WS_SYSMENU       = 0x00080000
WS_THICKFRAME    = 0x00040000
WS_GROUP         = 0x00020000
WS_TABSTOP       = 0x00010000 --same value as WS_MAXIMIZEBOX
WS_MINIMIZEBOX   = 0x00020000
WS_MAXIMIZEBOX   = 0x00010000
WS_TILED         = WS_OVERLAPPED
WS_ICONIC        = WS_MINIMIZE
WS_SIZEBOX       = WS_THICKFRAME
WS_OVERLAPPEDWINDOW = bit.bor(WS_OVERLAPPED,
									  WS_CAPTION,
									  WS_SYSMENU,
									  WS_THICKFRAME,
									  WS_MINIMIZEBOX,
									  WS_MAXIMIZEBOX)
WS_TILEDWINDOW   = WS_OVERLAPPEDWINDOW
WS_CHILDWINDOW   = WS_CHILD

WS_EX_DLGMODALFRAME   = 0x00000001
WS_EX_NOPARENTNOTIFY  = 0x00000004
WS_EX_TOPMOST         = 0x00000008
WS_EX_ACCEPTFILES     = 0x00000010
WS_EX_TRANSPARENT     = 0x00000020
WS_EX_MDICHILD        = 0x00000040
WS_EX_TOOLWINDOW      = 0x00000080
WS_EX_WINDOWEDGE      = 0x00000100 --always set on creation
WS_EX_CLIENTEDGE      = 0x00000200
WS_EX_CONTEXTHELP     = 0x00000400
WS_EX_RIGHT           = 0x00001000
WS_EX_LEFT            = 0x00000000 --no bits!
WS_EX_RTLREADING      = 0x00002000
WS_EX_LTRREADING      = 0x00000000 --no bits!
WS_EX_LEFTSCROLLBAR   = 0x00004000
WS_EX_RIGHTSCROLLBAR  = 0x00000000 --no bits!
WS_EX_CONTROLPARENT   = 0x00010000
WS_EX_STATICEDGE      = 0x00020000
WS_EX_APPWINDOW       = 0x00040000
WS_EX_LAYERED         = 0x00080000
WS_EX_NOINHERITLAYOUT = 0x00100000
WS_EX_LAYOUTRTL       = 0x00400000
WS_EX_COMPOSITED      = 0x02000000

--NOTE: WS_EX_NOACTIVATE only works if there's only a single window in the app,
--otherwise it only works for windows with WS_EX_TOOLWINDOW + WS_CHILD + WS_THICKFRAME.
--there's also a bug: "show window contents while dragging" doesn't work,
--so SetWindowPos() must be called in WM_MOVING and WM_SIZING too.
--Also, you must set WS_CHILD **after** the window is created, otherwise
--your toolboxes will be clipped by the parent window, just like controls!
WS_EX_NOACTIVATE      = 0x08000000

WS_POPUPWINDOW         = bit.bor(WS_POPUP, WS_BORDER, WS_SYSMENU)
WS_EX_OVERLAPPEDWINDOW = bit.bor(WS_EX_WINDOWEDGE, WS_EX_CLIENTEDGE)
WS_EX_PALETTEWINDOW    = bit.bor(WS_EX_WINDOWEDGE, WS_EX_TOOLWINDOW, WS_EX_TOPMOST)

CW_USEDEFAULT = 0x80000000 --if used for x, then y must be a SW_* flag

--NOTE: Only windows without the WS_SIZEBOX style can be created off-screen.
function CreateWindow(info)
	local class = wcs(MAKEINTRESOURCE(info.class))
	local text = wcs(info.text)
	local hwnd = checkh(C.CreateWindowExW(
								flags(info.style_ex),
								ffi.cast('LPCWSTR', class),
								wcs(info.text),
								flags(info.style),
								info.x, info.y, info.w, info.h,
								info.parent,
								nil, nil, nil))
	if not info.parent then own(hwnd, DestroyWindow) end
	return hwnd
end

function DestroyWindow(hwnd)
	if not hwnd then return end
	checknz(C.DestroyWindow(hwnd))
	disown(hwnd)
end

--commands

ffi.cdef[[
BOOL ShowWindow(HWND hWnd, int nCmdShow);
BOOL ShowWindowAsync(HWND hWnd, int nCmdShow);
]]

SW_HIDE             =  0 --hide and remember the show state
SW_SHOWNORMAL       =  1 --revert to normal state and activate (do nothing if already in normal state)
SW_SHOWMINIMIZED    =  2 --minimize but do not deactivate (do nothing if already minimized)
SW_SHOWMAXIMIZED    =  3 --maximize and activate (do nothing if already maximized)
SW_SHOWNOACTIVATE   =  4 --revert to normal state but do not activate (do nothing if alread in normal state)
SW_SHOW             =  5 --show in current state and activate (activate even if minimized; do nothing if already visible)
SW_MINIMIZE         =  6 --minimize and deactivate (do nothing if already minimized); same as SW_SHOWMINNOACTIVE
SW_SHOWMINNOACTIVE  =  7 --minimize and deactivate; same as SW_MINIMIZE
SW_SHOWNA           =  8 --show in current state but do not activate
SW_RESTORE          =  9 --restore to last state (minimized -> normal or maximized; maximized -> normal) and activate
SW_SHOWDEFAULT      = 10 --show per STARTUPINFO
SW_FORCEMINIMIZE    = 11 --minimize from a different thread

function ShowWindow(hwnd, SW)
	return C.ShowWindow(hwnd, flags(SW)) ~= 0
end

function ShowWindowAsync(hwnd, SW)
	return C.ShowWindowAsync(hwnd, flags(SW)) ~= 0
end

ffi.cdef[[
int GetWindowTextLengthW(HWND hWnd);

int  GetWindowTextW(
     HWND hWnd,
     LPWSTR lpString,
     int nMaxCount);

BOOL SetWindowTextW(
     HWND hWnd,
     LPCWSTR lpString);
]]

GetWindowTextLength = C.GetWindowTextLengthW

function GetWindowText(hwnd, buf)
	local ws, sz = WCS(buf or C.GetWindowTextLengthW(hwnd))
	C.GetWindowTextW(hwnd, ws, sz+1)
	return buf or mbs(ws)
end

function SetWindowText(hwnd, text)
	checknz(C.SetWindowTextW(hwnd, wcs(text)))
end

ffi.cdef[[
BOOL SetWindowPos(
     HWND hWnd,
     HWND hWndInsertAfter,
     int X,
     int Y,
     int cx,
     int cy,
     UINT uFlags);
]]

HWND_TOP        = ffi.cast('HWND', 0)
HWND_BOTTOM     = ffi.cast('HWND', 1)
HWND_TOPMOST    = ffi.cast('HWND', -1)
HWND_NOTOPMOST  = ffi.cast('HWND', -2)

SWP_NOSIZE           = 0x0001
SWP_NOMOVE           = 0x0002
SWP_NOZORDER         = 0x0004
SWP_NOREDRAW         = 0x0008
SWP_NOACTIVATE       = 0x0010
SWP_FRAMECHANGED     = 0x0020  --the frame changed: send WM_NCCALCSIZE
SWP_SHOWWINDOW       = 0x0040
SWP_HIDEWINDOW       = 0x0080
SWP_NOCOPYBITS       = 0x0100
SWP_NOOWNERZORDER    = 0x0200  --don't do owner Z ordering
SWP_NOSENDCHANGING   = 0x0400  --don't send WM_WINDOWPOSCHANGING
SWP_DRAWFRAME        = SWP_FRAMECHANGED
SWP_NOREPOSITION     = SWP_NOOWNERZORDER
SWP_DEFERERASE       = 0x2000
SWP_ASYNCWINDOWPOS   = 0x4000
SWP_STATECHANGED     = 0x8000  --undocumented
SWP_FRAMECHANGED_ONLY = bit.bor(SWP_NOZORDER, SWP_NOOWNERZORDER, SWP_NOACTIVATE,
											SWP_NOSIZE, SWP_NOMOVE, SWP_FRAMECHANGED)
SWP_ZORDER_CHANGED_ONLY = bit.bor(SWP_NOMOVE, SWP_NOSIZE, SWP_NOACTIVATE)

--NOTE: Windows can't be moved off-screen with this function.
function SetWindowPos(hwnd, back_hwnd, x, y, cx, cy, SWP)
	checknz(C.SetWindowPos(hwnd, back_hwnd, x, y, cx, cy, flags(SWP)))
end

ffi.cdef[[
BOOL MoveWindow(HWND hWnd, int X, int Y, int nWidth, int nHeight, BOOL bRepaint);
BOOL UpdateWindow(HWND hWnd);
BOOL EnableWindow(HWND hWnd, BOOL bEnable);
BOOL GetWindowRect(HWND hWnd, LPRECT lpRect);
BOOL GetClientRect(HWND hWnd, LPRECT lpRect);
HWND SetParent(HWND hWndChild, HWND hWndNewParent);
HWND GetParent(HWND hWnd);
BOOL IsWindowVisible(HWND hWnd);
BOOL IsWindowEnabled(HWND hWnd);
HWND GetActiveWindow();
HWND SetActiveWindow(HWND hWnd);
BOOL BringWindowToTop(HWND hWnd);
BOOL IsIconic(HWND hWnd);
BOOL IsZoomed(HWND hWnd);
HWND GetFocus();
HWND SetFocus(HWND hWnd);
HWND GetWindow(HWND hWnd, UINT uCmd);
HWND GetTopWindow(HWND hWnd);
BOOL IsWindowUnicode(HWND hWnd);
HWND GetDesktopWindow();
HWND GetForegroundWindow();
BOOL SetForegroundWindow(HWND hWnd);
BOOL LockSetForegroundWindow(UINT uLockCode);
]]

function MoveWindow(hwnd, x, y, w, h, repaint)
	checknz(C.MoveWindow(hwnd, x, y, w, h, repaint))
end

function UpdateWindow(hwnd) --send WM_PAINT _if_ current update region is not empty
	checknz(C.UpdateWindow(hwnd))
end

function EnableWindow(hwnd, enable)
	return C.EnableWindow(hwnd, enable) ~= 0
end

function GetWindowRect(hwnd, rect)
	rect = RECT(rect)
	checknz(C.GetWindowRect(hwnd, rect))
	return rect
end

function GetClientRect(hwnd, rect)
	rect = RECT(rect)
	checknz(C.GetClientRect(hwnd, rect))
	return rect
end

GetParent = C.GetParent

function SetParent(hwnd, parent)
	local prev_parent = checkh(C.SetParent(hwnd, parent))
	if parent == nil then own(hwnd, DestroyWindow) else disown(hwnd) end
	return prev_parent
end

function IsWindowVisible(hwnd)
	return C.IsWindowVisible(hwnd) ~= 0
end

function IsWindowEnabled(hwnd)
	return C.IsWindowEnabled(hwnd) ~= 0
end

function GetActiveWindow()
	return ptr(C.GetActiveWindow())
end

--NOTE: SetActiveWindow() triggers WM_ACTIVATEAPP even when the app doesn't activate!
--An app (and thus one of its windows) doesn't activate with SetActiveWindow(),
--but with SetForegroundWindow(), and even then it might not activate immediately,
--but instead blink the window in the taskbar waiting for the user to activate it.
--WM_ACTIVATE is sent immediately and in all cases, while WM_NCACTIVATE is sent
--if and after the user clicks on the flashing taskbar button.
SetActiveWindow = C.SetActiveWindow

function BringWindowToTop(hwnd)
	checknz(C.BringWindowToTop(hwnd))
end

function IsIconic(hwnd)
	return C.IsIconic(hwnd) ~= 0
end

function IsZoomed(hwnd)
	return C.IsZoomed(hwnd) ~= 0
end

function GetFocus()
	return ptr(C.GetFocus())
end

SetFocus = C.SetFocus

GW_HWNDFIRST        = 0
GW_HWNDLAST         = 1
GW_HWNDNEXT         = 2
GW_HWNDPREV         = 3
GW_OWNER            = 4
GW_CHILD            = 5
GW_ENABLEDPOPUP     = 6

function GetWindow(hwnd, GW)   return ptr(C.GetWindow(hwnd, flags(GW))) end
function GetOwner(hwnd)        return callh2(GetWindow, hwnd, GW_OWNER) end
function GetFirstChild(hwnd)   return callh2(GetWindow, hwnd, GW_CHILD) end
function GetFirstSibling(hwnd) return callh2(GetWindow, hwnd, GW_HWNDFIRST) end
function GetLastSibling(hwnd)  return callh2(GetWindow, hwnd, GW_HWNDLAST) end
function GetNextSibling(hwnd)  return callh2(GetWindow, hwnd, GW_HWNDNEXT) end --from top to bottom of the z-order
function GetPrevSibling(hwnd)  return callh2(GetWindow, hwnd, GW_HWNDPREV) end --from bottom to top of the z-order

local function nextchild(parent, sibling)
	if not sibling then return GetFirstChild(parent) end
	return GetNextSibling(sibling)
end

--returns a stateless iterator iterating from top to bottom of the z-order.
--NOTE: you can get infinite loops if the z-order of the windows involved changes while iterating.
function GetChildWindows(hwnd)
	return nextchild, hwnd
end

GetTopWindow = C.GetTopWindow --same semantics as GetFirstChild ?

function IsWindowUnicode(hwnd) --for outside windows; ours are always unicode
	return C.IsWindowUnicode(hwnd) ~= 0
end

GetDesktopWindow = C.GetDesktopWindow

function GetForegroundWindow()
	return ptr(C.GetForegroundWindow())
end

function SetForegroundWindow(hwnd)
	return C.SetForegroundWindow(hwnd) ~= 0
end
jit.off(SetForegroundWindow) --important!

LSFW_LOCK   = 1
LSFW_UNLOCK = 2

function LockSetForegroundWindow(hwnd, LSFW)
	checknz(C.LockSetForegroundWindow(hwnd, flags(LSFW)))
end

--enum windows

ffi.cdef[[
typedef __stdcall BOOL (* WNDENUMPROC)(HWND, LPARAM);
BOOL EnumChildWindows(
     HWND hWndParent,
     WNDENUMPROC lpEnumFunc,
     LPARAM lParam);
]]

--NOTE: for a not null hwnd you can use GetChildWindows (no callback, no table).
function EnumChildWindows(hwnd) --note: front-to-back order
	local t = {}
	local cb = ffi.cast('WNDENUMPROC', function(hwnd, lparam)
		t[#t+1] = hwnd
		return 1 --continue
	end)
	C.EnumChildWindows(hwnd, cb, 0)
	cb:free()
	return t
end

WPF_ASYNCWINDOWPLACEMENT = 0x0004
WPF_RESTORETOMAXIMIZED   = 0x0002
WPF_SETMINPOSITION       = 0x0001

ffi.cdef[[
typedef struct tagWINDOWPLACEMENT {
    UINT  length;
    UINT  _flags;
    UINT  showCmd;
    POINT ptMinPosition;
    POINT ptMaxPosition;
    RECT  rcNormalPosition;
} WINDOWPLACEMENT;
typedef WINDOWPLACEMENT *PWINDOWPLACEMENT, *LPWINDOWPLACEMENT;

BOOL GetWindowPlacement(
     HWND hWnd,
     WINDOWPLACEMENT *lpwndpl);

BOOL SetWindowPlacement(
     HWND hWnd,
     const WINDOWPLACEMENT *lpwndpl);
]]

WINDOWPLACEMENT = struct{
	ctype = 'WINDOWPLACEMENT', size = 'length',
	fields = sfields{
		'flags', '_flags', flags, pass, --WPF_*
	},
}

function GetWindowPlacement(hwnd, wpl)
	wpl = WINDOWPLACEMENT(wpl)
	checknz(C.GetWindowPlacement(hwnd, wpl))
	return wpl
end

function SetWindowPlacement(hwnd, wpl)
	wpl = WINDOWPLACEMENT(wpl)
	checknz(C.SetWindowPlacement(hwnd, wpl))
end

ffi.cdef[[
LRESULT DefWindowProcW(
     HWND hWnd,
     UINT Msg,
     WPARAM wParam,
     LPARAM lParam);

LRESULT CallWindowProcW(
     WNDPROC lpPrevWndFunc,
	  HWND hWnd,
     UINT Msg,
     WPARAM wParam,
     LPARAM lParam);
]]

DefWindowProc = C.DefWindowProcW
CallWindowProc = C.CallWindowProcW

--set/get window long

GWL_WNDPROC        = -4
GWL_HINSTANCE      = -6
GWL_HWNDPARENT     = -8 --this gets/sets the owner, not the parent!
GWL_STYLE          = -16
GWL_EXSTYLE        = -20
GWL_USERDATA       = -21
GWL_ID             = -12

if ffi.abi'64bit' then
	ffi.cdef[[
	LONG_PTR SetWindowLongPtrW(HWND hWnd, int nIndex, LONG_PTR dwNewLong);
	LONG_PTR GetWindowLongPtrW(HWND hWnd, int nIndex);
	]]
	SetWindowLongW = C.SetWindowLongPtrW
	GetWindowLongW = C.GetWindowLongPtrW
else --32bit
	ffi.cdef[[
	LONG SetWindowLongW(HWND hWnd, int nIndex, LONG dwNewLong);
	LONG GetWindowLongW(HWND hWnd, int nIndex);
	]]
	SetWindowLongW = C.SetWindowLongW
	GetWindowLongW = C.GetWindowLongW
end

function SetWindowLong(hwnd, GWL, long)
	return callnz2(SetWindowLongW, hwnd, flags(GWL), ffi.cast('LONG', long))
end

function GetWindowLong(hwnd, GWL)
	return GetWindowLongW(hwnd, flags(GWL))
end

--Get/SetWindowLong wrappers (don't look them up in the docs)

function GetWindowStyle(hwnd) return tonumber(GetWindowLong(hwnd, GWL_STYLE)) end
function SetWindowStyle(hwnd, style) SetWindowLong(hwnd, GWL_STYLE, flags(style)) end

function GetWindowExStyle(hwnd) return tonumber(GetWindowLong(hwnd, GWL_EXSTYLE)) end
function SetWindowExStyle(hwnd, style) SetWindowLong(hwnd, GWL_EXSTYLE, flags(style)) end

function GetWindowInstance(hwnd) return ffi.cast('HMODULE', GetWindowLong(hwnd, GWL_HINSTANCE)) end
function SetWindowInstance(hwnd, hinst) SetWindowLong(hwnd, GWL_HINSTANCE, hinst) end

function IsRestored(hwnd) return bit.band(GetWindowStyle(hwnd), WS_MINIMIZE + WS_MAXIMIZE) == 0 end
function IsVisible(hwnd) return bit.band(GetWindowStyle(hwnd), WS_VISIBLE) == WS_VISIBLE end

function GetWindowOwner(hwnd) return ffi.cast('HWND', GetWindowLong(hwnd, GWL_HWNDPARENT)) end --GetOwner() is another way
function SetWindowOwner(hwnd, owner_hwnd) SetWindowLong(hwnd, GWL_HWNDPARENT, owner_hwnd) end

--window geometry

ffi.cdef[[
int MapWindowPoints(
     HWND hWndFrom,
     HWND hWndTo,
     LPPOINT lpPoints,
     UINT cPoints);

HWND WindowFromPoint(POINT Point);
HWND ChildWindowFromPoint(HWND hWndParent, POINT Point);
HWND RealChildWindowFromPoint(HWND hWndParent, POINT Point);

BOOL AdjustWindowRectEx(
     LPRECT lpRect,
     DWORD dwStyle,
     BOOL bMenu,
     DWORD dwExStyle);
]]

function MapWindowPoints(hwndFrom, hwndTo, points)
	local points, sz = arrays.POINT(points)
	callnz2(C.MapWindowPoints, hwndFrom, hwndTo, points, sz)
	return points
end

function MapWindowPoint(hwndFrom, hwndTo, ...) --changes and returns the same passed point
	local p = POINT(...)
	callnz2(C.MapWindowPoints, hwndFrom, hwndTo, ffi.cast('POINT*', p), 1)
	return p
end

function MapWindowRect(hwndFrom, hwndTo, ...) --changes and returns the same passed rect
	local r = RECT(...)
	callnz2(C.MapWindowPoints, hwndFrom, hwndTo, ffi.cast('POINT*', r), 2)
	return r
end

function WindowFromPoint(...)
	return ptr(C.WindowFromPoint(POINT(...)))
end

function ChildWindowFromPoint(hwnd, ...)
	return ptr(C.ChildWindowFromPoint(hwnd, POINT(...)))
end

function RealChildWindowFromPoint(hwnd, ...)
	return ptr(C.RealChildWindowFromPoint(hwnd, POINT(...)))
end

function AdjustWindowRect(crect, style, style_ex, has_menu, rect)
	rect = RECT(rect)
	rect.x1 = crect.x1
	rect.y1 = crect.y1
	rect.x2 = crect.x2
	rect.y2 = crect.y2
	checknz(C.AdjustWindowRectEx(rect, style, has_menu, style_ex))
	return rect
end

-- layered windows

ULW_COLORKEY            = 0x00000001
ULW_ALPHA               = 0x00000002
ULW_OPAQUE              = 0x00000004
ULW_EX_NORESIZE         = 0x00000008

ffi.cdef[[
BOOL UpdateLayeredWindow(
	HWND hwnd,
	HDC hdcDst,
	POINT *pptDst,
	SIZE *psize,
	HDC hdcSrc,
	POINT *pptSrc,
	COLORREF crKey,
	BLENDFUNCTION *pblend,
	DWORD dwFlags
);

BOOL SetLayeredWindowAttributes(
	HWND     hwnd,
	COLORREF crKey,
	BYTE     bAlpha,
	DWORD    dwFlags
);
]]

--NOTE: this fails under Remote Desktop and doesn't set an error in GetLastError().
function UpdateLayeredWindow(hwnd, dst_hdc, dst_ppt, psize, src_hdc, src_ppt, key, pblend, ULW)
	return C.UpdateLayeredWindow(hwnd, dst_hdc, dst_ppt, psize, src_hdc, src_ppt, key, pblend, flags(ULW)) == 1
end

LWA_COLORKEY = 1
LWA_ALPHA    = 2

function SetLayeredWindowAttributes(hwnd, key_color, alpha, LWA)
	return C.SetLayeredWindowAttributes(hwnd, key_color, alpha, flags(LWA)) == 1
end

-- timers

ffi.cdef[[
typedef void (* TIMERPROC)(HWND, UINT, UINT_PTR, DWORD);
UINT_PTR SetTimer(
     HWND hWnd,
     UINT_PTR nIDEvent,
     UINT uElapse,
     TIMERPROC lpTimerFunc);

BOOL KillTimer(
     HWND hWnd,
     UINT_PTR uIDEvent);
]]

--NOTE: calling error() in callback is not supported!
function SetTimer(hwnd, id, timeout, callback)
	return checknz(C.SetTimer(hwnd, id, timeout, callback))
end

function KillTimer(hwnd, id)
	checknz(C.KillTimer(hwnd, id))
end

-- messages

ffi.cdef[[
typedef struct tagMSG {
	 HWND        hwnd;
	 UINT        message;
	 union {
		WPARAM      wParam;
		LPARAM      signed_wParam;
	 };
	 LPARAM      lParam;
	 DWORD       time;
	 POINT       pt;
} MSG, *PMSG, *NPMSG, *LPMSG;

BOOL GetMessageW(
	  LPMSG lpMsg,
	  HWND hWnd,
	  UINT wMsgFilterMin,
	  UINT wMsgFilterMax);

BOOL TranslateMessage(const MSG *lpMsg);

int TranslateAcceleratorW(
     HWND hWnd,
     HACCEL hAccTable,
     LPMSG lpMsg);

LRESULT DispatchMessageW(const MSG *lpMsg);

BOOL IsDialogMessageW(
     HWND hDlg,
     LPMSG lpMsg);

void PostQuitMessage(int nExitCode);

LRESULT SendMessageW(
	  HWND hWnd,
	  UINT Msg,
	  WPARAM wParam,
	  LPARAM lParam);

BOOL PeekMessageW(
     LPMSG lpMsg,
     HWND hWnd,
     UINT wMsgFilterMin,
     UINT wMsgFilterMax,
     UINT wRemoveMsg);

BOOL PostMessageW(
     HWND hWnd,
     UINT Msg,
     WPARAM wParam,
     LPARAM lParam);

LONG GetMessageTime(void);
]]

function GetMessage(hwnd, WMmin, WMmax, msg)
	return checkpoz(C.GetMessageW(types.MSG(msg), hwnd, flags(WMmin), flags(WMmax)))
end

function DispatchMessage(msg)
	return C.DispatchMessageW(msg)
end

function TranslateAccelerator(hwnd, haccel, msg)
	return C.TranslateAcceleratorW(hwnd, haccel, msg) ~= 0
end

function TranslateMessage(msg)
	return C.TranslateMessage(msg)
end

--NOTE: IsDialogMessage() is filtering out WM_CHAR messages.
function IsDialogMessage(hwnd, msg)
	return C.IsDialogMessageW(hwnd, msg) ~= 0
end

-- NOTE: a FFI callback cannot safely be called from a C function which is
-- itself called via the FFI from JIT-compiled code. This means we must disable
-- jitting for all functions that could trigger a FFI callback.
jit.off(GetMessage)
jit.off(DispatchMessage)
jit.off(TranslateAccelerator)
jit.off(TranslateMessage)
jit.off(IsDialogMessage)

HWND_BROADCAST = ffi.cast('HWND', 0xffff)
HWND_MESSAGE   = ffi.cast('HWND', -3)

function PostQuitMessage(exitcode)
	C.PostQuitMessage(exitcode or 0)
end

function SendMessagePtr(hwnd, WM, wParam, lParam)
	if wParam == nil then wParam = 0 end
	if type(lParam) == 'nil' then lParam = 0 end
	return C.SendMessageW(hwnd, flags(WM),
		ffi.cast('WPARAM', wParam),
		ffi.cast('LPARAM', lParam))
end
if ffi.abi'64bit' then
	function SendMessage(...) --converts int64_t results on x64
		return tonumber(SendMessagePtr(...))
	end
else
	SendMessage = SendMessagePtr
end
SNDMSG = SendMessage
SNDMSG_PTR = SendMessagePtr --use this when the return value is a pointer

function PostMessage(hwnd, WM, wParam, lParam)
	if wParam == nil then wParam = 0 end
	if lParam == nil then lParam = 0 end
	return C.PostMessageW(hwnd, WM,
		ffi.cast('WPARAM', wParam),
		ffi.cast('LPARAM', lParam))
end

GetMessageTime = C.GetMessageTime

-- Queue status flags for GetQueueStatus() and MsgWaitForMultipleObjects()
QS_KEY              = 0x0001
QS_MOUSEMOVE        = 0x0002
QS_MOUSEBUTTON      = 0x0004
QS_POSTMESSAGE      = 0x0008
QS_TIMER            = 0x0010
QS_PAINT            = 0x0020
QS_SENDMESSAGE      = 0x0040
QS_HOTKEY           = 0x0080
QS_ALLPOSTMESSAGE   = 0x0100
QS_RAWINPUT         = 0x0400
QS_MOUSE            = bit.bor(QS_MOUSEMOVE, QS_MOUSEBUTTON)
QS_INPUT            = bit.bor(QS_MOUSE, QS_KEY, QS_RAWINPUT)
QS_ALLEVENTS        = bit.bor(QS_INPUT, QS_POSTMESSAGE, QS_TIMER, QS_PAINT, QS_HOTKEY)
QS_ALLINPUT         = bit.bor(QS_INPUT, QS_POSTMESSAGE, QS_TIMER, QS_PAINT, QS_HOTKEY, QS_SENDMESSAGE)

PM_NOREMOVE         = 0x0000
PM_REMOVE           = 0x0001
PM_NOYIELD          = 0x0002
PM_QS_INPUT         = bit.lshift(QS_INPUT, 16)
PM_QS_POSTMESSAGE   = bit.lshift(bit.bor(QS_POSTMESSAGE, QS_HOTKEY, QS_TIMER), 16)
PM_QS_PAINT         = bit.lshift(QS_PAINT, 16)
PM_QS_SENDMESSAGE   = bit.lshift(QS_SENDMESSAGE, 16)

function PeekMessage(hwnd, WMmin, WMmax, PM, msg)
	msg = types.MSG(msg)
	return C.PeekMessageW(msg, hwnd, flags(WMmin), flags(WMmax), flags(PM)) ~= 0, msg
end

--message-based commands

function SetWindowFont(hwnd, font)
	SNDMSG(hwnd, WM_SETFONT, font, true) --no result
end

function GetWindowFont(hwnd)
	return ptr(ffi.cast('HFONT', SNDMSG(hwnd, WM_GETFONT)))
end

function CloseWindow(hwnd) --the winapi CloseWindow() has nothing to do with closing the window
	checkz(SNDMSG(hwnd, WM_CLOSE))
end

function SetRedraw(hwnd, allow) --adds WS_VISIBLE to the window!
	SNDMSG(hwnd, WM_SETREDRAW, allow)
end

UIS_SET         = 1
UIS_CLEAR       = 2
UIS_INITIALIZE  = 3

UISF_HIDEFOCUS  = 0x1
UISF_HIDEACCEL  = 0x2
UISF_ACTIVE     = 0x4

function ChangeUIState(hwnd, UIS, UISF)
	SNDMSG(hwnd, WM_CHANGEUISTATE, MAKEWPARAM(flags(UIS), flags(UISF)))
end

-- message names and decoders

--wm ranges (for filtering)
WM_KEYFIRST                      = 0x0100
WM_KEYLAST                       = 0x0109
WM_IME_KEYLAST                   = 0x010F
WM_MOUSEFIRST                    = 0x0200
WM_MOUSELAST                     = 0x020D
WM_TABLET_FIRST                  = 0x02c0
WM_TABLET_LAST                   = 0x02df
WM_HANDHELDFIRST                 = 0x0358
WM_HANDHELDLAST                  = 0x035F
WM_AFXFIRST                      = 0x0360
WM_AFXLAST                       = 0x037F
WM_PENWINFIRST                   = 0x0380
WM_PENWINLAST                    = 0x038F

WM_APP                           = 0x8000 --tip: see the wmapp module on how to manage those.
WM_USER                          = 0x0400

--dev note: make a comment on obsolete messages but keep them anyway,
--so that you don't see unknown messages when debugging.

WM_NAMES = constants{
	WM_NULL                          = 0x0000,
	WM_CREATE                        = 0x0001,
	WM_DESTROY                       = 0x0002,
	WM_MOVE                          = 0x0003,
	WM_SIZE                          = 0x0005,
	WM_ACTIVATE                      = 0x0006,
	WM_SETFOCUS                      = 0x0007,
	WM_KILLFOCUS                     = 0x0008,
	WM_ENABLE                        = 0x000A,
	WM_SETREDRAW                     = 0x000B,
	WM_SETTEXT                       = 0x000C,
	WM_GETTEXT                       = 0x000D,
	WM_GETTEXTLENGTH                 = 0x000E,
	WM_PAINT                         = 0x000F,
	WM_CLOSE                         = 0x0010,
	WM_QUERYENDSESSION               = 0x0011,
	WM_QUERYOPEN                     = 0x0013,
	WM_ENDSESSION                    = 0x0016,
	WM_QUIT                          = 0x0012,
	WM_ERASEBKGND                    = 0x0014,
	WM_SYSCOLORCHANGE                = 0x0015,
	WM_SHOWWINDOW                    = 0x0018,
	WM_WININICHANGE                  = 0x001A, --obsolete
	WM_SETTINGCHANGE                 = 0x001A,
	WM_DEVMODECHANGE                 = 0x001B,
	WM_ACTIVATEAPP                   = 0x001C,
	WM_FONTCHANGE                    = 0x001D,
	WM_TIMECHANGE                    = 0x001E,
	WM_CANCELMODE                    = 0x001F,
	WM_SETCURSOR                     = 0x0020,
	WM_MOUSEACTIVATE                 = 0x0021,
	WM_CHILDACTIVATE                 = 0x0022,
	WM_QUEUESYNC                     = 0x0023,
	WM_GETMINMAXINFO                 = 0x0024,
	WM_PAINTICON                     = 0x0026,
	WM_ICONERASEBKGND                = 0x0027,
	WM_NEXTDLGCTL                    = 0x0028,
	WM_SPOOLERSTATUS                 = 0x002A,
	WM_DRAWITEM                      = 0x002B,
	WM_MEASUREITEM                   = 0x002C,
	WM_DELETEITEM                    = 0x002D,
	WM_VKEYTOITEM                    = 0x002E,
	WM_CHARTOITEM                    = 0x002F,
	WM_SETFONT                       = 0x0030,
	WM_GETFONT                       = 0x0031,
	WM_SETHOTKEY                     = 0x0032,
	WM_GETHOTKEY                     = 0x0033,
	WM_QUERYDRAGICON                 = 0x0037,
	WM_COMPAREITEM                   = 0x0039,
	WM_GETOBJECT                     = 0x003D,
	WM_COMPACTING                    = 0x0041,
	WM_COMMNOTIFY                    = 0x0044, --obsolete
	WM_WINDOWPOSCHANGING             = 0x0046,
	WM_WINDOWPOSCHANGED              = 0x0047,
	WM_POWER                         = 0x0048, --obsolete
	WM_COPYDATA                      = 0x004A,
	WM_CANCELJOURNAL                 = 0x004B,
	WM_NOTIFY                        = 0x004E,
	WM_INPUTLANGCHANGEREQUEST        = 0x0050,
	WM_INPUTLANGCHANGE               = 0x0051,
	WM_TCARD                         = 0x0052,
	WM_HELP                          = 0x0053,
	WM_USERCHANGED                   = 0x0054,
	WM_NOTIFYFORMAT                  = 0x0055,
	WM_CONTEXTMENU                   = 0x007B,
	WM_STYLECHANGING                 = 0x007C,
	WM_STYLECHANGED                  = 0x007D,
	WM_DISPLAYCHANGE                 = 0x007E,
	WM_GETICON                       = 0x007F,
	WM_SETICON                       = 0x0080,
	WM_NCCREATE                      = 0x0081,
	WM_NCDESTROY                     = 0x0082,
	WM_NCCALCSIZE                    = 0x0083,
	WM_NCHITTEST                     = 0x0084,
	WM_NCPAINT                       = 0x0085,
	WM_NCACTIVATE                    = 0x0086,
	WM_GETDLGCODE                    = 0x0087,
	WM_SYNCPAINT                     = 0x0088,
	WM_NCMOUSEMOVE                   = 0x00A0,
	WM_NCLBUTTONDOWN                 = 0x00A1,
	WM_NCLBUTTONUP                   = 0x00A2,
	WM_NCLBUTTONDBLCLK               = 0x00A3,
	WM_NCRBUTTONDOWN                 = 0x00A4,
	WM_NCRBUTTONUP                   = 0x00A5,
	WM_NCRBUTTONDBLCLK               = 0x00A6,
	WM_NCMBUTTONDOWN                 = 0x00A7,
	WM_NCMBUTTONUP                   = 0x00A8,
	WM_NCMBUTTONDBLCLK               = 0x00A9,
	WM_NCXBUTTONDOWN                 = 0x00AB,
	WM_NCXBUTTONUP                   = 0x00AC,
	WM_NCXBUTTONDBLCLK               = 0x00AD,
   WM_INPUT_DEVICE_CHANGE           = 0x00FE,
	WM_INPUT                         = 0x00FF,
	WM_KEYDOWN                       = 0x0100,
	WM_KEYUP                         = 0x0101,
	WM_CHAR                          = 0x0102,
	WM_DEADCHAR                      = 0x0103,
	WM_SYSKEYDOWN                    = 0x0104,
	WM_SYSKEYUP                      = 0x0105,
	WM_SYSCHAR                       = 0x0106,
	WM_SYSDEADCHAR                   = 0x0107,
	WM_UNICHAR                       = 0x0109,
	WM_IME_STARTCOMPOSITION          = 0x010D,
	WM_IME_ENDCOMPOSITION            = 0x010E,
	WM_IME_COMPOSITION               = 0x010F,
	WM_INITDIALOG                    = 0x0110,
	WM_COMMAND                       = 0x0111,
	WM_SYSCOMMAND                    = 0x0112,
	WM_TIMER                         = 0x0113, --id, callback
	WM_HSCROLL                       = 0x0114,
	WM_VSCROLL                       = 0x0115,
	WM_INITMENU                      = 0x0116,
	WM_INITMENUPOPUP                 = 0x0117,
	WM_MENUSELECT                    = 0x011F,
	WM_MENUCHAR                      = 0x0120,
	WM_ENTERIDLE                     = 0x0121,
	WM_MENURBUTTONUP                 = 0x0122,
	WM_MENUDRAG                      = 0x0123,
	WM_MENUGETOBJECT                 = 0x0124,
	WM_UNINITMENUPOPUP               = 0x0125,
	WM_MENUCOMMAND                   = 0x0126,
	WM_CHANGEUISTATE                 = 0x0127,
	WM_UPDATEUISTATE                 = 0x0128,
	WM_QUERYUISTATE                  = 0x0129,
	WM_CTLCOLORMSGBOX                = 0x0132,
	WM_CTLCOLOREDIT                  = 0x0133,
	WM_CTLCOLORLISTBOX               = 0x0134,
	WM_CTLCOLORBTN                   = 0x0135,
	WM_CTLCOLORDLG                   = 0x0136,
	WM_CTLCOLORSCROLLBAR             = 0x0137,
	WM_CTLCOLORSTATIC                = 0x0138,
	MN_GETHMENU                      = 0x01E1, --MN_ not a typo
	WM_MOUSEMOVE                     = 0x0200,
	WM_LBUTTONDOWN                   = 0x0201,
	WM_LBUTTONUP                     = 0x0202,
	WM_LBUTTONDBLCLK                 = 0x0203,
	WM_RBUTTONDOWN                   = 0x0204,
	WM_RBUTTONUP                     = 0x0205,
	WM_RBUTTONDBLCLK                 = 0x0206,
	WM_MBUTTONDOWN                   = 0x0207,
	WM_MBUTTONUP                     = 0x0208,
	WM_MBUTTONDBLCLK                 = 0x0209,
	WM_MOUSEWHEEL                    = 0x020A,
	WM_XBUTTONDOWN                   = 0x020B,
	WM_XBUTTONUP                     = 0x020C,
	WM_XBUTTONDBLCLK                 = 0x020D,
	WM_MOUSEHWHEEL                   = 0x020E,
	WM_PARENTNOTIFY                  = 0x0210,
	WM_ENTERMENULOOP                 = 0x0211,
	WM_EXITMENULOOP                  = 0x0212,
	WM_NEXTMENU                      = 0x0213,
	WM_SIZING                        = 0x0214,
	WM_CAPTURECHANGED                = 0x0215,
	WM_MOVING                        = 0x0216,
	WM_POWERBROADCAST                = 0x0218,
	WM_DEVICECHANGE                  = 0x0219,
	WM_MDICREATE                     = 0x0220,
	WM_MDIDESTROY                    = 0x0221,
	WM_MDIACTIVATE                   = 0x0222,
	WM_MDIRESTORE                    = 0x0223,
	WM_MDINEXT                       = 0x0224,
	WM_MDIMAXIMIZE                   = 0x0225,
	WM_MDITILE                       = 0x0226,
	WM_MDICASCADE                    = 0x0227,
	WM_MDIICONARRANGE                = 0x0228,
	WM_MDIGETACTIVE                  = 0x0229,
	WM_MDISETMENU                    = 0x0230,
	WM_ENTERSIZEMOVE                 = 0x0231,
	WM_EXITSIZEMOVE                  = 0x0232,
	WM_DROPFILES                     = 0x0233,
	WM_MDIREFRESHMENU                = 0x0234,
	WM_IME_SETCONTEXT                = 0x0281,
	WM_IME_NOTIFY                    = 0x0282,
	WM_IME_CONTROL                   = 0x0283,
	WM_IME_COMPOSITIONFULL           = 0x0284,
	WM_IME_SELECT                    = 0x0285,
	WM_IME_CHAR                      = 0x0286,
	WM_IME_REQUEST                   = 0x0288,
	WM_IME_KEYDOWN                   = 0x0290,
	WM_IME_KEYUP                     = 0x0291,
	WM_MOUSEHOVER                    = 0x02A1,
	WM_MOUSELEAVE                    = 0x02A3,
	WM_NCMOUSEHOVER                  = 0x02A0,
	WM_NCMOUSELEAVE                  = 0x02A2,
	WM_WTSSESSION_CHANGE             = 0x02B1,
	WM_DPICHANGED                    = 0x02E0, --Win8.1+
	WM_CUT                           = 0x0300,
	WM_COPY                          = 0x0301,
	WM_PASTE                         = 0x0302,
	WM_CLEAR                         = 0x0303,
	WM_UNDO                          = 0x0304,
	WM_RENDERFORMAT                  = 0x0305,
	WM_RENDERALLFORMATS              = 0x0306,
	WM_DESTROYCLIPBOARD              = 0x0307,
	WM_DRAWCLIPBOARD                 = 0x0308,
	WM_PAINTCLIPBOARD                = 0x0309,
	WM_VSCROLLCLIPBOARD              = 0x030A,
	WM_SIZECLIPBOARD                 = 0x030B,
	WM_ASKCBFORMATNAME               = 0x030C,
	WM_CHANGECBCHAIN                 = 0x030D,
	WM_HSCROLLCLIPBOARD              = 0x030E,
	WM_QUERYNEWPALETTE               = 0x030F,
	WM_PALETTEISCHANGING             = 0x0310,
	WM_PALETTECHANGED                = 0x0311,
	WM_HOTKEY                        = 0x0312,
	WM_PRINT                         = 0x0317,
	WM_PRINTCLIENT                   = 0x0318,
	WM_APPCOMMAND                    = 0x0319,
	WM_THEMECHANGED                  = 0x031A,
}

require'winapi.wmapp'

--message sent to the thread (thus the message loop) to unregister a window class after a window is destroyed.
register_message'WM_UNREGISTER_CLASS'

--default message routed by BaseWindowClass through the NotifyIcons tracker.
register_message'WM_NOTIFYICON'

--message sent to the thread to raise an error (see WM_PAINT handling in BaseWindowClass).
register_message'WM_EXCEPTION'

--decode a message based on registered decoders from various submodules.
function DecodeMessage(WM_, wParam, lParam) --returns decoded results...
	local decoder = WM[WM_NAMES[WM_]] or pass
	return decoder(wParam, lParam)
end

--window state

SW_OTHERUNZOOM    = 4 --The window is being uncovered because a maximize window was restored or minimized.
SW_OTHERZOOM      = 2 --The window is being covered by another window that has been maximized.
SW_PARENTCLOSING  = 1 --The window's owner window is being minimized.
SW_PARENTOPENING  = 3 --The window's owner window is being restored.

local show_status = {'owner_minimized', 'other_maximized', 'owner_restored', 'other_restored'}

function WM.WM_SHOWWINDOW(wParam, lParam) --shown/hidden, show_status (nil if ShowWindow was called)
	return wParam == 1, show_status[tonumber(lParam)]
end

function WM.WM_ENABLE(wParam)
	return wParam == 1
end

-- window activation

local activate_flags = {[0] = 'inactive', 'active', 'clickactive'}

function WM.WM_ACTIVATE(wParam, lParam)
	local WA, minimized = splitlong(wParam)
	return activate_flags[WA], minimized ~= 0, ptr(ffi.cast('HWND', lParam)) --flag, minimized, other_window
end

function WM.WM_ACTIVATEAPP(wParam, lParam)
	return activate_flags[tonumber(wParam)], tonumber(lParam) --flag, other_thread_id
end

function WM.WM_NCACTIVATE(wParam, lParam)
	return activate_flags[tonumber(wParam)], tonumber(lParam) --flag, update_hrgn
end

-- window sizing

ffi.cdef[[
typedef struct tagMINMAXINFO {
    POINT ptReserved;
    SIZE  ptMaxSize;
	 POINT ptMaxPosition;
	 SIZE  ptMinTrackSize;
	 SIZE  ptMaxTrackSize;
} MINMAXINFO, *PMINMAXINFO, *LPMINMAXINFO;

typedef struct tagWINDOWPOS {
    HWND    hwnd;
    HWND    hwndInsertAfter;
    int     x;
    int     y;
	 int     w;
    int     h;
    UINT    flags;
} WINDOWPOS, *LPWINDOWPOS, *PWINDOWPOS;
]]

do
	local wp_fields = {}
	for k,v in pairs(_M) do
		if k:match'^SWP_' then
			wp_fields[k] = v
		end
	end
	local wp_flags = bitmask(wp_fields)
	local function wp_flags_get(flags)
		local t = {}
		wp_flags:get(flags, t)
		return t
	end
	local function wp_flags_set(flags, value)
		wp_flags:set(flags, t)
	end

	WINDOWPOS = struct{
		ctype = 'WINDOWPOS',
		fields = sfields{
			'flagbits', 'flags', wp_flags_set, wp_flags_get, --SWP_*
		}
	}
end

--NOTE: only sent to top-level windows. Not sent initially, so a resize
--must be forced for the constraints to be applied.
function WM.WM_GETMINMAXINFO(wParam, lParam)
	return ffi.cast('MINMAXINFO*', lParam)
end

--NOTE: sent when the window position or size is about to change, programatically or by user.
function WM.WM_WINDOWPOSCHANGING(wParam, lParam)
	return ffi.cast('WINDOWPOS*', lParam)
end

--NOTE: sent after the window position or size changed, programatically or by user.
WM.WM_WINDOWPOSCHANGED = WM.WM_WINDOWPOSCHANGING

function WM.WM_MOVING(wParam, lParam) --RECT (frame rect, not client rect)
	return ffi.cast('RECT*', lParam)
end

local sizing_flags = {'left', 'right', 'top', 'topleft', 'topright', 'bottom', 'bottomleft', 'bottomright'}

--NOTE: only sent when resizing by user.
function WM.WM_SIZING(wParam, lParam) --flag, RECT (frame rect, not client rect)
	return sizing_flags[tonumber(wParam)], ffi.cast('RECT*', lParam)
end

local size_flags = {[0] = 'restored', 'minimized', 'maximized', 'other_restored', 'other_maximized'}

--NOTE: WM_SIZE gives the size of the client rect, not of the frame rect!
--NOTE: WM_SIZE is sent by the default proc for WM_WINDOWPOSCHANGED.
function WM.WM_SIZE(wParam, lParam) --flag, cw, ch
	return size_flags[tonumber(wParam)], splitlong(lParam)
end

--NOTE: WM_MOVE gives the coordinates of the client rect, not of the frame rect!
--NOTE: WM_MOVE is sent by the default proc for WM_WINDOWPOSCHANGED.
function WM.WM_MOVE(wParam, lParam) --cx, cy
	return splitlong(lParam)
end

function WM.WM_DISPLAYCHANGE(wParam, lParam) --w, h, bpp
	local w, h = splitlong(lParam)
	return w, h, bpp
end

-- controls/wm_*command

function WM.WM_COMMAND(wParam, lParam)
	local id, command = splitlong(wParam)
	if lParam == 0 then
		if command == 0 then --menu
			return 'menu', id
		elseif command == 1 then --accelerator
			return 'accelerator', id
		else
			assert(false)
		end
	else
		return 'control', id, command, checkh(ffi.cast('HWND', lParam))
	end
end

function WM.WM_MENUCOMMAND(wParam, lParam)
	return checkh(ffi.cast('HMENU', lParam)), countfrom1(tonumber(wParam))
end

SC_SIZE          = 0xF000
SC_MOVE          = 0xF010
SC_DRAGMOVE      = 0xF012
SC_MINIMIZE      = 0xF020
SC_MAXIMIZE      = 0xF030
SC_NEXTWINDOW    = 0xF040
SC_PREVWINDOW    = 0xF050
SC_CLOSE         = 0xF060
SC_VSCROLL       = 0xF070
SC_HSCROLL       = 0xF080
SC_MOUSEMENU     = 0xF090
SC_KEYMENU       = 0xF100
SC_ARRANGE       = 0xF110
SC_RESTORE       = 0xF120
SC_TASKLIST      = 0xF130
SC_SCREENSAVE    = 0xF140
SC_HOTKEY        = 0xF150
SC_DEFAULT       = 0xF160
SC_MONITORPOWER  = 0xF170
SC_CONTEXTHELP   = 0xF180
SC_SEPARATOR     = 0xF00F
SCF_ISSECURE     = 0x00000001

function WM.WM_SYSCOMMAND(wParam, lParam)
	local SC = bit.band(tonumber(wParam), 0xfff0)
	if SC == SC_KEYMENU then
		return SC, tonumber(lParam) --SC, char_code
	else
		return SC, splitsigned(lParam) --SC, x, y
	end
end

--controls/wm_compareitem

ffi.cdef[[
typedef struct tagCOMPAREITEMSTRUCT {
    UINT        CtlType;
    UINT        id;
    HWND        hwnd;
    UINT        i1;
    ULONG_PTR   item1_user_data;
    UINT        i2;
    ULONG_PTR   item2_user_data;
    DWORD       dwLocaleId;
} COMPAREITEMSTRUCT,  *PCOMPAREITEMSTRUCT,  *LPCOMPAREITEMSTRUCT;
]]

function WM.WM_COMPAREITEM(wParam, lParam) --must return -1 if a < b, 1 if a > b and 0 if a == b
	return checkh(ffi.cast('HWND', wParam)), checkh(ffi.cast('COMPAREITEMSTRUCT*', lParam))
end

--controls/wm_notify

NM_FIRST = 2^32

WM_NOTIFY_NAMES = constants{ --{code_number = code_name}
	NM_CUSTOMDRAW = NM_FIRST-12,
}

ffi.cdef[[
typedef struct tagNMHDR
{
    HWND      hwndFrom;
    UINT_PTR  idFrom;
    UINT      code;
}   NMHDR;
typedef NMHDR *LPNMHDR;
]]

function WM.WM_NOTIFY(wParam, lParam) --return hwnd, code, decoded message...
	local hdr = ffi.cast('NMHDR*', lParam)
	local code_name = WM_NOTIFY_NAMES[hdr.code]
	local decoder = NM[code_name] or pass
	return hdr.hwndFrom, hdr.code, decoder(hdr, wParam)
end

ffi.cdef[[
typedef struct tagNMCUSTOMDRAWINFO
{
    NMHDR hdr;
    DWORD stage;
    HDC hdc;
    RECT rc;
    DWORD_PTR dwItemSpec;
    UINT  uItemState;
    LPARAM lItemlParam;
} NMCUSTOMDRAW, *LPNMCUSTOMDRAW;
]]

--stage flags
CDDS_PREPAINT           = 0x00000001
CDDS_POSTPAINT          = 0x00000002
CDDS_PREERASE           = 0x00000003
CDDS_POSTERASE          = 0x00000004
CDDS_ITEM               = 0x00010000 --individual item specific
CDDS_ITEMPREPAINT       = bit.bor(CDDS_ITEM, CDDS_PREPAINT)
CDDS_ITEMPOSTPAINT      = bit.bor(CDDS_ITEM, CDDS_POSTPAINT)
CDDS_ITEMPREERASE       = bit.bor(CDDS_ITEM, CDDS_PREERASE)
CDDS_ITEMPOSTERASE      = bit.bor(CDDS_ITEM, CDDS_POSTERASE)
CDDS_SUBITEM            = 0x00020000

--return flags
CDRF_DODEFAULT          = 0x00000000
CDRF_NEWFONT            = 0x00000002
CDRF_SKIPDEFAULT        = 0x00000004
CDRF_DOERASE            = 0x00000008 -- draw the background
CDRF_SKIPPOSTPAINT      = 0x00000100 -- don't draw the focus rect
CDRF_NOTIFYPOSTPAINT    = 0x00000010
CDRF_NOTIFYITEMDRAW     = 0x00000020
CDRF_NOTIFYSUBITEMDRAW  = 0x00000020 --flags are the same, we can distinguish by context
CDRF_NOTIFYPOSTERASE    = 0x00000040

function NM.NM_CUSTOMDRAW(hdr)
	return ffi.cast('NMCUSTOMDRAW*', hdr)
end
