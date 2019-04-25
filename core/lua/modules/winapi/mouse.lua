
--proc/input/mouse: Mouse API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

TME_HOVER       = 0x00000001
TME_LEAVE       = 0x00000002
TME_NONCLIENT   = 0x00000010
TME_QUERY       = 0x40000000
TME_CANCEL      = 0x80000000
HOVER_DEFAULT   = 0xFFFFFFFF

ffi.cdef[[
typedef struct tagTRACKMOUSEEVENT {
    DWORD cbSize;
    DWORD dwFlags;
    HWND  hwnd;
    DWORD hover_time;
} TRACKMOUSEEVENT, *LPTRACKMOUSEEVENT;

BOOL TrackMouseEvent(LPTRACKMOUSEEVENT lpEventTrack);

UINT GetDoubleClickTime();
BOOL SetDoubleClickTime(UINT uInterval);

HWND GetCapture(void);
HWND SetCapture(HWND hWnd);
BOOL ReleaseCapture(void);

BOOL DragDetect(HWND hwnd, POINT pt);
]]

TRACKMOUSEEVENT = struct{
	ctype = 'TRACKMOUSEEVENT', size = 'cbSize',
	fields = sfields{
		'flags', 'dwFlags', flags, pass,
	},

}

function TrackMouseEvent(event)
	event = TRACKMOUSEEVENT(event)
	checknz(C.TrackMouseEvent(event))
end

GetDoubleClickTime = C.GetDoubleClickTime

function SetDoubleClickTime(interval)
	checknz(C.SetDoubleClickTime(interval))
end

function GetCapture()
	return ptr(C.GetCapture())
end

function SetCapture(hwnd)
	return ptr(C.SetCapture(hwnd))
end

function ReleaseCapture()
	return checknz(C.ReleaseCapture())
end

function DragDetect(hwnd, point)
	return C.DragDetect(hwnd, POINT(point)) ~= 0
end

--messages

HTERROR             = -2
HTTRANSPARENT       = -1
HTNOWHERE           = 0
HTCLIENT            = 1
HTCAPTION           = 2
HTSYSMENU           = 3
HTGROWBOX           = 4
HTSIZE              = HTGROWBOX
HTMENU              = 5
HTHSCROLL           = 6
HTVSCROLL           = 7
HTMINBUTTON         = 8
HTMAXBUTTON         = 9
HTLEFT              = 10
HTRIGHT             = 11
HTTOP               = 12
HTTOPLEFT           = 13
HTTOPRIGHT          = 14
HTBOTTOM            = 15
HTBOTTOMLEFT        = 16
HTBOTTOMRIGHT       = 17
HTBORDER            = 18
HTREDUCE            = HTMINBUTTON
HTZOOM              = HTMAXBUTTON
HTSIZEFIRST         = HTLEFT
HTSIZELAST          = HTBOTTOMRIGHT
HTOBJECT            = 19
HTCLOSE             = 20
HTHELP              = 21

function WM.WM_NCHITTEST(wParam, lParam)
	return splitsigned(lParam) --x, y; must return HT*
end

MK_LBUTTON          = 0x0001
MK_RBUTTON          = 0x0002
MK_SHIFT            = 0x0004
MK_CONTROL          = 0x0008
MK_MBUTTON          = 0x0010
MK_XBUTTON1         = 0x0020
MK_XBUTTON2         = 0x0040

local buttons_bitmask = bitmask{
	lbutton = MK_LBUTTON,
	rbutton = MK_RBUTTON,
	shift = MK_SHIFT,
	control = MK_CONTROL,
	mbutton = MK_MBUTTON,
	xbutton1 = MK_XBUTTON1,
	xbutton2 = MK_XBUTTON2,
}

--NOTE: double-click messages are only received on windows with CS_DBLCLKS style
function WM.WM_LBUTTONDBLCLK(wParam, lParam)
	local x, y = splitsigned(lParam)
	return x, y, buttons_bitmask:get(tonumber(wParam))
end

WM.WM_LBUTTONDOWN = WM.WM_LBUTTONDBLCLK
WM.WM_LBUTTONUP = WM.WM_LBUTTONDBLCLK
WM.WM_MBUTTONDBLCLK = WM.WM_LBUTTONDBLCLK
WM.WM_MBUTTONDOWN = WM.WM_LBUTTONDBLCLK
WM.WM_MBUTTONUP = WM.WM_LBUTTONDBLCLK
WM.WM_MOUSEHOVER = WM.WM_LBUTTONDBLCLK
WM.WM_MOUSEMOVE = WM.WM_LBUTTONDBLCLK
WM.WM_RBUTTONDBLCLK = WM.WM_LBUTTONDBLCLK
WM.WM_RBUTTONDOWN = WM.WM_LBUTTONDBLCLK
WM.WM_RBUTTONUP = WM.WM_LBUTTONDBLCLK

function WM.WM_MOUSEWHEEL(wParam, lParam)
	local x, y = splitsigned(lParam)
	local buttons, delta = splitsigned(ffi.cast('int32_t', wParam))
	return x, y, buttons_bitmask:get(buttons), delta
end

WM.WM_MOUSEHWHEEL = WM.WM_MOUSEWHEEL

XBUTTON1 = 0x0001
XBUTTON2 = 0x0002

local xbuttons_bitmask = bitmask{
	xbutton1 = XBUTTON1,
	xbutton2 = XBUTTON2,
}

function WM.WM_XBUTTONDBLCLK(wParam, lParam)
	local x, y = splitsigned(lParam)
	local MK, XBUTTON = splitlong(wParam)
	return x, y, buttons_bitmask:get(MK), xbuttons_bitmask:get(XBUTTON)
end

WM.WM_XBUTTONDOWN = WM.WM_XBUTTONDBLCLK
WM.WM_XBUTTONUP = WM.WM_XBUTTONDBLCLK

function WM.WM_NCLBUTTONDBLCLK(wParam, lParam)
	local x, y = splitsigned(lParam)
	return x, y, tonumber(wParam) --x, y, HT*
end
WM.WM_NCLBUTTONDOWN = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCLBUTTONUP = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCMBUTTONDBLCLK = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCMBUTTONDOWN = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCMBUTTONUP = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCMOUSEHOVER = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCMOUSEMOVE = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCRBUTTONDBLCLK = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCRBUTTONDOWN = WM.WM_NCLBUTTONDBLCLK
WM.WM_NCRBUTTONUP = WM.WM_NCLBUTTONDBLCLK

WM.WM_NCXBUTTONDBLCLK = WM.WM_XBUTTONDBLCLK --HT*, XBUTTON*, x, y
WM.WM_NCXBUTTONDOWN = WM.WM_NCXBUTTONDBLCLK
WM.WM_NCXBUTTONUP = WM.WM_NCXBUTTONDBLCLK

MA_ACTIVATE         = 1
MA_ACTIVATEANDEAT   = 2
MA_NOACTIVATE       = 3
MA_NOACTIVATEANDEAT = 4

function WM.WM_MOUSEACTIVATE(wParam, lParam)
	local HT, MK = splitlong(lParam)
	return ffi.cast('HWND', wParam), HT, buttons_bitmask:get(MK) --must return MA_*
end

