
--proc/windows/gdi: GDI API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winuser'

--glue

CLR_INVALID = 0xFFFFFFFF
local function validclr(ret) return ret ~= CLR_INVALID, 'valid color expected, got CLR_INVALID' end
checkclr = checkwith(validclr)

--macros

function RGB(r, g, b)
	return b * 65536 + g * 256 + r
end

--stock objects

ffi.cdef[[
HGDIOBJ  GetStockObject(int i);
]]

WHITE_BRUSH          = 0
LTGRAY_BRUSH         = 1
GRAY_BRUSH           = 2
DKGRAY_BRUSH         = 3
BLACK_BRUSH          = 4
NULL_BRUSH           = 5
HOLLOW_BRUSH         = NULL_BRUSH

WHITE_PEN            = 6
BLACK_PEN            = 7
NULL_PEN             = 8

OEM_FIXED_FONT       = 10
ANSI_FIXED_FONT      = 11
ANSI_VAR_FONT        = 12
SYSTEM_FONT          = 13
DEVICE_DEFAULT_FONT  = 14
DEFAULT_PALETTE      = 15
SYSTEM_FIXED_FONT    = 16
DEFAULT_GUI_FONT     = 17

DC_BRUSH             = 18
DC_PEN               = 19


function GetStockObject(i)
	return checkh(C.GetStockObject(i))
end

--device contexts

ffi.cdef[[
HDC GetDC(HWND hWnd);
int ReleaseDC(HWND hWnd, HDC hDC);
typedef struct tagPAINTSTRUCT {
	HDC   hdc;
	BOOL  fErase;
	RECT  rcPaint;
	BOOL  fRestore;
	BOOL  fIncUpdate;
	BYTE  rgbReserved[32];
} PAINTSTRUCT, *PPAINTSTRUCT, *NPPAINTSTRUCT, *LPPAINTSTRUCT;
HDC      BeginPaint(HWND hwnd, LPPAINTSTRUCT lpPaint);
BOOL     EndPaint(HWND hWnd, const PAINTSTRUCT *lpPaint);
BOOL     InvalidateRect(HWND hWnd, const RECT *lpRect, BOOL bErase);
BOOL     RedrawWindow(HWND hWnd, const RECT *lprcUpdate, HRGN hrgnUpdate, UINT flags);
HGDIOBJ  SelectObject(HDC hdc, HGDIOBJ h);
BOOL     DeleteObject(HGDIOBJ ho);
COLORREF SetDCBrushColor(HDC hdc, COLORREF color);
COLORREF SetDCPenColor(HDC hdc, COLORREF color);
int      SetBkMode(HDC hdc, int mode);
HDC      CreateCompatibleDC(HDC hdc);
BOOL     DeleteDC(HDC hdc);
BOOL     SwapBuffers(HDC);
int      GetObjectW(HGDIOBJ hgdiobj, int cbBuffer, LPVOID lpvObject);
]]

function GetDC(hwnd)
	return checkh(C.GetDC(hwnd))
end

function ReleaseDC(hwnd, hdc)
	checktrue(C.ReleaseDC(hwnd, hdc))
	disown(hdc)
end

function SelectObject(hdc, hobj)
	local ret = C.SelectObject(hdc, hobj)
	--TODO: checkh for non-regions, HGDI_ERROR (-1U) for regions
	return ret
end

function DeleteObject(ho)
	checknz(C.DeleteObject(ho))
end

function BeginPaint(hwnd, paintstruct)
	return checkh(C.BeginPaint(hwnd, paintstruct))
end

function EndPaint(hwnd, paintstruct)
	return checktrue(C.EndPaint(hwnd, paintstruct))
end

RDW_INVALIDATE          = 0x0001
RDW_INTERNALPAINT       = 0x0002
RDW_ERASE               = 0x0004
RDW_VALIDATE            = 0x0008
RDW_NOINTERNALPAINT     = 0x0010
RDW_NOERASE             = 0x0020
RDW_NOCHILDREN          = 0x0040
RDW_ALLCHILDREN         = 0x0080
RDW_UPDATENOW           = 0x0100
RDW_ERASENOW            = 0x0200
RDW_FRAME               = 0x0400
RDW_NOFRAME             = 0x0800

function RedrawWindow(hwnd, rect_or_region, RDW)
	local rect, region
	if ffi.istype('RECT', rect_or_region) then
		rect = rect_or_region
	else
		region = rect_or_region
	end
	checknz(C.RedrawWindow(hwnd, rect, region, flags(RDW)))
end

function InvalidateRect(hwnd, rect, erase_bk)
	return checktrue(C.InvalidateRect(hwnd, rect, erase_bk or false))
end

function SetDCBrushColor(hdc, color)
	return checkclr(C.SetDCBrushColor(hdc, color))
end

function SetDCPenColor(hdc, color)
	return checkclr(C.SetDCPenColor(hdc, color))
end

TRANSPARENT         = 1
OPAQUE              = 2

function SetBkMode(hdc, mode)
	return checknz(SetBkMode, hdc, flags(mode))
end

function CreateCompatibleDC(hdc)
	return checkh(C.CreateCompatibleDC(hdc))
end

function DeleteDC(hdc)
	return checknz(C.DeleteDC(hdc))
end

function SwapBuffers(hdc)
	return checknz(C.SwapBuffers(hdc))
end

function GetObject(hobject, sz, buf)
	sz = sz or checknz(C.GetObjectW(hobject, 0, nil))
	buf = buf or ffi.new('uint8_t[?]', sz)
	checknz(C.GetObjectW(hobject, sz, buf))
	return buf, sz
end

--dc pixel format

ffi.cdef[[
typedef struct tagPIXELFORMATDESCRIPTOR
{
    WORD  nSize;
    WORD  nVersion;
    DWORD dwFlags;
    BYTE  iPixelType;
    BYTE  cColorBits;
    BYTE  cRedBits;
    BYTE  cRedShift;
    BYTE  cGreenBits;
    BYTE  cGreenShift;
    BYTE  cBlueBits;
    BYTE  cBlueShift;
    BYTE  cAlphaBits;
    BYTE  cAlphaShift;
    BYTE  cAccumBits;
    BYTE  cAccumRedBits;
    BYTE  cAccumGreenBits;
    BYTE  cAccumBlueBits;
    BYTE  cAccumAlphaBits;
    BYTE  cDepthBits;
    BYTE  cStencilBits;
    BYTE  cAuxBuffers;
    BYTE  iLayerType;
    BYTE  bReserved;
    DWORD dwLayerMask;
    DWORD dwVisibleMask;
    DWORD dwDamageMask;
} PIXELFORMATDESCRIPTOR, *PPIXELFORMATDESCRIPTOR,  *LPPIXELFORMATDESCRIPTOR;
int  ChoosePixelFormat(HDC hdc, const PIXELFORMATDESCRIPTOR *ppfd);
BOOL SetPixelFormat(HDC hdc, int format, const PIXELFORMATDESCRIPTOR* ppfd);
]]

PIXELFORMATDESCRIPTOR = struct{
	ctype = 'PIXELFORMATDESCRIPTOR', size = 'nSize', defaults = {nVersion = 1},
	fields = sfields{
		'flags', 'dwFlags', flags, pass, --PFD_*
		'pixel_type', 'iPixelType', flags, pass, --PFD_TYPE_*
		'layer_type', 'iLayerType', flags, pass, --PFD_*_PLANE
	},
}

-- pixel types
PFD_TYPE_RGBA         = 0
PFD_TYPE_COLORINDEX   = 1

-- layer types
PFD_MAIN_PLANE        = 0
PFD_OVERLAY_PLANE     = 1
PFD_UNDERLAY_PLANE    = (-1)

-- PIXELFORMATDESCRIPTOR flags
PFD_DOUBLEBUFFER             = 0x00000001
PFD_STEREO                   = 0x00000002
PFD_DRAW_TO_WINDOW           = 0x00000004
PFD_DRAW_TO_BITMAP           = 0x00000008
PFD_SUPPORT_GDI              = 0x00000010
PFD_SUPPORT_OPENGL           = 0x00000020
PFD_GENERIC_FORMAT           = 0x00000040
PFD_NEED_PALETTE             = 0x00000080
PFD_NEED_SYSTEM_PALETTE      = 0x00000100
PFD_SWAP_EXCHANGE            = 0x00000200
PFD_SWAP_COPY                = 0x00000400
PFD_SWAP_LAYER_BUFFERS       = 0x00000800
PFD_GENERIC_ACCELERATED      = 0x00001000
PFD_SUPPORT_DIRECTDRAW       = 0x00002000
PFD_DIRECT3D_ACCELERATED     = 0x00004000
PFD_SUPPORT_COMPOSITION      = 0x00008000

-- PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only
PFD_DEPTH_DONTCARE           = 0x20000000
PFD_DOUBLEBUFFER_DONTCARE    = 0x40000000
PFD_STEREO_DONTCARE          = 0x80000000

function ChoosePixelFormat(hdc, pfd)
	pfd = PIXELFORMATDESCRIPTOR(pfd)
	return checkpoz(C.ChoosePixelFormat(hdc, pfd))
end

function SetPixelFormat(hdc, format, pfd)
	pfd = PIXELFORMATDESCRIPTOR(pfd)
	return checktrue(C.SetPixelFormat(hdc, format, pfd))
end

--brushes

ffi.cdef[[
HBRUSH CreateSolidBrush(COLORREF color);
]]

function CreateSolidBrush(color)
	return checkh(C.CreateSolidBrush(color))
end

--pens

ffi.cdef[[
HPEN CreatePen(int iStyle, int cWidth, COLORREF color);
]]

PS_SOLID            = 0
PS_DASH             = 1       -- -------
PS_DOT              = 2       -- .......
PS_DASHDOT          = 3       -- _._._._
PS_DASHDOTDOT       = 4       -- _.._.._
PS_NULL             = 5
PS_INSIDEFRAME      = 6
PS_USERSTYLE        = 7
PS_ALTERNATE        = 8
PS_STYLE_MASK       = 0x0000000F

PS_ENDCAP_ROUND     = 0x00000000
PS_ENDCAP_SQUARE    = 0x00000100
PS_ENDCAP_FLAT      = 0x00000200
PS_ENDCAP_MASK      = 0x00000F00

PS_JOIN_ROUND       = 0x00000000
PS_JOIN_BEVEL       = 0x00001000
PS_JOIN_MITER       = 0x00002000
PS_JOIN_MASK        = 0x0000F000

PS_COSMETIC         = 0x00000000
PS_GEOMETRIC        = 0x00010000
PS_TYPE_MASK        = 0x000F0000

function CreatePen(style, width, color)
	return checkh(C.CreatePen(style, width, color))
end

--text

ffi.cdef[[
COLORREF SetTextColor(HDC hdc, COLORREF color);
]]

function SetTextColor(hdc, color)
	return checkclr(C.SetTextColor(hdc, color))
end

--filled shapes

ffi.cdef[[
BOOL Chord(HDC hdc, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4);
BOOL Ellipse(HDC hdc, int left, int top, int right, int bottom);
int FillRect(HDC hDC, const RECT *lprc, HBRUSH hbr);
int FrameRect(HDC hDC, const RECT *lprc, HBRUSH hbr);
BOOL InvertRect(HDC hDC, const RECT *lprc);
BOOL Pie(HDC hdc, int left, int top, int right, int bottom, int xr1, int yr1, int xr2, int yr2);
BOOL PolyPolygon(HDC hdc, const POINT *apt, const INT *asz, int csz);
BOOL Polygon(HDC hdc, const POINT *apt, int cpt);
BOOL Rectangle(HDC hdc, int left, int top, int right, int bottom);
BOOL RoundRect(HDC hdc, int left, int top, int right, int bottom, int width, int height);
]]

function Chord(...) return checknz(C.Chord(...)) end
function Ellipse(...) return checknz(C.Ellipse(...)) end
function FillRect(...) return checknz(C.FillRect(...)) end
function FrameRect(...) return checknz(C.FrameRect(...)) end
function InvertRect(...) return checknz(C.InvertRect(...)) end
function Pie(...) return checknz(C.Pie(...)) end
function PolyPolygon(...) return checknz(C.PolyPolygon(...)) end
function Polygon(...) return checknz(C.Polygon(...)) end
function Rectangle(...) return checknz(C.Rectangle(...)) end
function RoundRect(...) return checknz(C.RoundRect(...)) end

--batching

ffi.cdef[[
BOOL GdiFlush(void);
]]

GdiFlush = C.GdiFlush

--blending

ffi.cdef[[
typedef struct _BLENDFUNCTION {
    BYTE   BlendOp;
    BYTE   BlendFlags;
    BYTE   SourceConstantAlpha;
    BYTE   AlphaFormat;
} BLENDFUNCTION, *PBLENDFUNCTION;
]]

AC_SRC_OVER  = 0x00
AC_SRC_ALPHA = 0x01

--regions

ffi.cdef[[
HRGN CreateRoundRectRgn(
	int nLeftRect,
	int nTopRect,
	int nRightRect,
	int nBottomRect,
	int nWidthEllipse,
	int nHeightEllipse
);

int SetWindowRgn(
	HWND hWnd,
	HRGN hRgn,
	BOOL bRedraw
);
]]

function CreateRoundRectRgn(...)
	return checkh(C.CreateRoundRectRgn(...))
end

function SetWindowRgn(hwnd, rgn, redraw)
	checknz(C.SetWindowRgn(hwnd, rgn, redraw))
end

--showcase

if not ... then
	print(GetStockObject(WHITE_BRUSH))
	print(GetStockObject(DEFAULT_GUI_FONT))
end

