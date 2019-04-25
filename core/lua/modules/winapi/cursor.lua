
--proc/resources/cursor: cursor resources
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winuser'

ffi.cdef[[
typedef struct {
  DWORD   cbSize;
  DWORD   flags;
  HCURSOR hCursor;
  POINT   ptScreenPos;
} CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

HCURSOR LoadCursorW(HINSTANCE hInstance, LPCWSTR lpCursorName);
int ShowCursor(BOOL bShow);
BOOL SetCursorPos(int X, int Y);
BOOL SetPhysicalCursorPos(int X, int Y);
HCURSOR SetCursor(HCURSOR hCursor);
BOOL GetCursorPos(LPPOINT lpPoint);
BOOL GetPhysicalCursorPos(LPPOINT lpPoint);
DWORD GetMessagePos(void);
BOOL ClipCursor(const RECT *lpRect);
BOOL GetClipCursor(LPRECT lpRect);
HCURSOR GetCursor(void);
BOOL GetCursorInfo(PCURSORINFO pci);
]]

IDC_ARROW       = 32512
IDC_IBEAM       = 32513
IDC_WAIT        = 32514
IDC_CROSS       = 32515
IDC_UPARROW     = 32516
IDC_SIZE        = 32640
IDC_ICON        = 32641
IDC_SIZENWSE    = 32642
IDC_SIZENESW    = 32643
IDC_SIZEWE      = 32644
IDC_SIZENS      = 32645
IDC_SIZEALL     = 32646
IDC_NO          = 32648
IDC_HAND        = 32649
IDC_APPSTARTING = 32650
IDC_HELP        = 32651

function LoadCursor(hInstance, name)
	if not name then hInstance, name = nil, hInstance end
   return checkh(C.LoadCursorW(hInstance,
						ffi.cast('LPCWSTR', wcs(MAKEINTRESOURCE(name)))))
end

function SetCursor(cursor)
	return ptr(C.SetCursor(cursor))
end

function GetMessagePos()
	return splitsigned(C.GetMessagePos())
end

CURSOR_SHOWING     = 1
CURSOR_SUPPRESSED  = 2 --Win8+

CURSORINFO = struct{ctype = 'CURSORINFO', size = 'cbSize'}

function GetCursorInfo(pci)
	pci = CURSORINFO(pci)
	checknz(C.GetCursorInfo(pci))
	return pci
end

--NOTE: GetCursorPos() must be passed in a POINT* in the low 2GB of address
--space or it will fail. This is safe with LuaJIT 2.x but to future-proof it,
--we emulate GetCursorPos() with GetCursorInfo() which doesn't suffer from this.
function GetCursorPos(p, pci)
	pci = GetCursorInfo(pci)
	if p then
		p.x = pci.ptScreenPos.x
		p.y = pci.ptScreenPos.y
	else
		p = POINT(pci.ptScreenPos)
	end
	return p, pci
end

SetCursorPos = C.SetCursorPos

--messages

function WM.WM_SETCURSOR(wParam, lParam)
	local HT, id = splitlong(lParam)
	return ffi.cast('HWND', wParam), HT, id --HT codes are in winapi.mouse
end

--demo

if not ... then
	print(LoadCursor(IDC_ARROW))
	assert(LoadCursor(IDC_ARROW) == LoadCursor(IDC_ARROW)) --same handle every time, no worry about freeing these
	print(LoadCursor(IDC_HELP))

	local p1 = GetCursorPos()
	local p2 = GetCursorInfo().ptScreenPos
	assert(p1.x == p2.x and p1.y == p2.y)
	local p3 = GetCursorPos(p1)
	assert(p1 == p3)
end

