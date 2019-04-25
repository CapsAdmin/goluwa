
--proc/opengl/wgl: WGL API from wingdi.h
--Written by Cosmin Apreutesei. Public Domain.

--used for managing opengl contexts and loading actual opengl API functions.
setfenv(1, require'winapi')
require'winapi.winuser'

opengl32 = ffi.load'opengl32'

ffi.cdef[[
BOOL   wglCopyContext(HGLRC, HGLRC, UINT);
HGLRC  wglCreateContext(HDC);
HGLRC  wglCreateLayerContext(HDC, int);
BOOL   wglDeleteContext(HGLRC);
HGLRC  wglGetCurrentContext(void);
HDC    wglGetCurrentDC(void);
PROC   wglGetProcAddress(LPCSTR);
BOOL   wglMakeCurrent(HDC, HGLRC);
BOOL   wglShareLists(HGLRC, HGLRC);
BOOL   wglUseFontBitmapsA(HDC, DWORD, DWORD, DWORD);
BOOL   wglUseFontBitmapsW(HDC, DWORD, DWORD, DWORD);

typedef struct _POINTFLOAT {
    FLOAT   x;
    FLOAT   y;
} POINTFLOAT, *PPOINTFLOAT;

typedef struct _GLYPHMETRICSFLOAT {
    FLOAT       gmfBlackBoxX;
    FLOAT       gmfBlackBoxY;
    POINTFLOAT  gmfptGlyphOrigin;
    FLOAT       gmfCellIncX;
    FLOAT       gmfCellIncY;
} GLYPHMETRICSFLOAT, *PGLYPHMETRICSFLOAT,  *LPGLYPHMETRICSFLOAT;

BOOL wglUseFontOutlinesA(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
BOOL wglUseFontOutlinesW(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);

typedef struct tagLAYERPLANEDESCRIPTOR {
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
    BYTE  iLayerPlane;
    BYTE  bReserved;
    COLORREF crTransparent;
} LAYERPLANEDESCRIPTOR, *PLAYERPLANEDESCRIPTOR,  *LPLAYERPLANEDESCRIPTOR;

BOOL   wglDescribeLayerPlane(HDC, int, int, UINT, LPLAYERPLANEDESCRIPTOR);
int    wglSetLayerPaletteEntries(HDC, int, int, int, const COLORREF *);
int    wglGetLayerPaletteEntries(HDC, int, int, int, COLORREF *);
BOOL   wglRealizeLayerPalette(HDC, int, BOOL);
BOOL   wglSwapLayerBuffers(HDC, UINT);

typedef struct _WGLSWAP {
    HDC hdc;
    UINT uiFlags;
} WGLSWAP, *PWGLSWAP, *LPWGLSWAP;
DWORD  wglSwapMultipleBuffers(UINT, const WGLSWAP *);
]]

WGL_FONT_LINES       = 0
WGL_FONT_POLYGONS    = 1

-- LAYERPLANEDESCRIPTOR flags
LPD_DOUBLEBUFFER         = 0x00000001
LPD_STEREO               = 0x00000002
LPD_SUPPORT_GDI          = 0x00000010
LPD_SUPPORT_OPENGL       = 0x00000020
LPD_SHARE_DEPTH          = 0x00000040
LPD_SHARE_STENCIL        = 0x00000080
LPD_SHARE_ACCUM          = 0x00000100
LPD_SWAP_EXCHANGE        = 0x00000200
LPD_SWAP_COPY            = 0x00000400
LPD_TRANSPARENT          = 0x00001000

LPD_TYPE_RGBA         = 0
LPD_TYPE_COLORINDEX   = 1

-- wglSwapLayerBuffers flags
WGL_SWAP_MAIN_PLANE      = 0x00000001
WGL_SWAP_OVERLAY1        = 0x00000002
WGL_SWAP_OVERLAY2        = 0x00000004
WGL_SWAP_OVERLAY3        = 0x00000008
WGL_SWAP_OVERLAY4        = 0x00000010
WGL_SWAP_OVERLAY5        = 0x00000020
WGL_SWAP_OVERLAY6        = 0x00000040
WGL_SWAP_OVERLAY7        = 0x00000080
WGL_SWAP_OVERLAY8        = 0x00000100
WGL_SWAP_OVERLAY9        = 0x00000200
WGL_SWAP_OVERLAY10       = 0x00000400
WGL_SWAP_OVERLAY11       = 0x00000800
WGL_SWAP_OVERLAY12       = 0x00001000
WGL_SWAP_OVERLAY13       = 0x00002000
WGL_SWAP_OVERLAY14       = 0x00004000
WGL_SWAP_OVERLAY15       = 0x00008000
WGL_SWAP_UNDERLAY1       = 0x00010000
WGL_SWAP_UNDERLAY2       = 0x00020000
WGL_SWAP_UNDERLAY3       = 0x00040000
WGL_SWAP_UNDERLAY4       = 0x00080000
WGL_SWAP_UNDERLAY5       = 0x00100000
WGL_SWAP_UNDERLAY6       = 0x00200000
WGL_SWAP_UNDERLAY7       = 0x00400000
WGL_SWAP_UNDERLAY8       = 0x00800000
WGL_SWAP_UNDERLAY9       = 0x01000000
WGL_SWAP_UNDERLAY10      = 0x02000000
WGL_SWAP_UNDERLAY11      = 0x04000000
WGL_SWAP_UNDERLAY12      = 0x08000000
WGL_SWAP_UNDERLAY13      = 0x10000000
WGL_SWAP_UNDERLAY14      = 0x20000000
WGL_SWAP_UNDERLAY15      = 0x40000000

WGL_SWAPMULTIPLE_MAX  = 16

function wglCreateContext(hdc)
	return own(checkh(opengl32.wglCreateContext(hdc)), wglDeleteContext)
end

function wglMakeCurrent(hdc, hrc)
	checktrue(opengl32.wglMakeCurrent(hdc, hrc))
end

function wglDeleteContext(hrc)
	checktrue(opengl32.wglDeleteContext(hrc))
	disown(hrc)
end

wglGetProcAddress = opengl32.wglGetProcAddress

