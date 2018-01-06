
--proc/gdi/bitmap: bitmap API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

--constants for the biCompression field
BI_RGB        = 0
BI_RLE8       = 1
BI_RLE4       = 2
BI_BITFIELDS  = 3
BI_JPEG       = 4
BI_PNG        = 5

DIB_RGB_COLORS = 0
DIB_PAL_COLORS = 1

local function U(s)
	return ffi.cast('uint32_t*', ffi.cast('const char*', s))[0]
end

LCS_sRGB                  = U'sRGB'
LCS_WINDOWS_COLOR_SPACE   = U'Win '
LCS_CALIBRATED_RGB        = 0x00000000
LCS_GM_BUSINESS           = 0x00000001
LCS_GM_GRAPHICS           = 0x00000002
LCS_GM_IMAGES             = 0x00000004
LCS_GM_ABS_COLORIMETRIC   = 0x00000008

ffi.cdef[[
typedef struct tagRGBQUAD {
	BYTE rgbBlue;
	BYTE rgbGreen;
	BYTE rgbRed;
	BYTE rgbReserved;
} RGBQUAD;

typedef long FXPT2DOT30, *LPFXPT2DOT30;

typedef struct tagCIEXYZ {
	FXPT2DOT30 ciexyzX;
	FXPT2DOT30 ciexyzY;
	FXPT2DOT30 ciexyzZ;
} CIEXYZ, *LPCIEXYZ;

typedef struct tagICEXYZTRIPLE {
	CIEXYZ ciexyzRed;
	CIEXYZ ciexyzGreen;
	CIEXYZ ciexyzBlue;
} CIEXYZTRIPLE, *LPCIEXYZTRIPLE;

typedef struct tagBITMAP {
	LONG   bmType;
	LONG   bmWidth;
	LONG   bmHeight;
	LONG   bmWidthBytes;
	WORD   bmPlanes;
	WORD   bmBitsPixel;
	LPVOID bmBits;
} BITMAP, *PBITMAP;

typedef struct tagBITMAPINFOHEADER{
	DWORD        biSize;
	LONG         biWidth;
	LONG         biHeight;
	WORD         biPlanes;
	WORD         biBitCount;
	DWORD        biCompression;
	DWORD        biSizeImage;
	LONG         biXPelsPerMeter;
	LONG         biYPelsPerMeter;
	DWORD        biClrUsed;
	DWORD        biClrImportant;
} BITMAPINFOHEADER, *LPBITMAPINFOHEADER, *PBITMAPINFOHEADER;

typedef struct tagBITMAPINFO {
	BITMAPINFOHEADER    bmiHeader;
	RGBQUAD             bmiColors[1];
} BITMAPINFO, *LPBITMAPINFO, *PBITMAPINFO;

typedef struct {
	DWORD        bV4Size;
	LONG         bV4Width;
	LONG         bV4Height;
	WORD         bV4Planes;
	WORD         bV4BitCount;
	DWORD        bV4V4Compression;
	DWORD        bV4SizeImage;
	LONG         bV4XPelsPerMeter;
	LONG         bV4YPelsPerMeter;
	DWORD        bV4ClrUsed;
	DWORD        bV4ClrImportant;
	DWORD        bV4RedMask;
	DWORD        bV4GreenMask;
	DWORD        bV4BlueMask;
	DWORD        bV4AlphaMask;
	DWORD        bV4CSType;
	CIEXYZTRIPLE bV4Endpoints;
	DWORD        bV4GammaRed;
	DWORD        bV4GammaGreen;
	DWORD        bV4GammaBlue;
} BITMAPV4HEADER,  *LPBITMAPV4HEADER, *PBITMAPV4HEADER;

typedef struct {
	DWORD        bV5Size;
	LONG         bV5Width;
	LONG         bV5Height;
	WORD         bV5Planes;
	WORD         bV5BitCount;
	DWORD        bV5Compression;
	DWORD        bV5SizeImage;
	LONG         bV5XPelsPerMeter;
	LONG         bV5YPelsPerMeter;
	DWORD        bV5ClrUsed;
	DWORD        bV5ClrImportant;
	DWORD        bV5RedMask;
	DWORD        bV5GreenMask;
	DWORD        bV5BlueMask;
	DWORD        bV5AlphaMask;
	DWORD        bV5CSType;
	CIEXYZTRIPLE bV5Endpoints;
	DWORD        bV5GammaRed;
	DWORD        bV5GammaGreen;
	DWORD        bV5GammaBlue;
	DWORD        bV5Intent;
	DWORD        bV5ProfileData;
	DWORD        bV5ProfileSize;
	DWORD        bV5Reserved;
} BITMAPV5HEADER,  *LPBITMAPV5HEADER, *PBITMAPV5HEADER;

HBITMAP  CreateBitmap(int nWidth, int nHeight, UINT cPlanes, UINT cBitsPerPel, const VOID *lpvBits);
HBITMAP  CreateCompatibleBitmap(HDC hdc, int cx, int cy);
COLORREF SetPixel(HDC hdc, int x, int y, COLORREF color);
HBITMAP  CreateDIBSection(HDC hdc, const BITMAPINFO *lpbmi, UINT usage, void **ppvBits, HANDLE hSection, DWORD offset);
BOOL     BitBlt(HDC hdc, int x, int y, int cx, int cy, HDC hdcSrc, int x1, int y1, DWORD rop);
int      GetDIBits(HDC hdc, HBITMAP hbmp, UINT uStartScan, UINT cScanLines, LPVOID lpvBits, LPBITMAPINFO lpbi, UINT uUsage);
]]

BITMAPINFOHEADER = struct{ctype = 'BITMAPINFOHEADER', size = 'biSize'}
BITMAPV4HEADER   = struct{ctype = 'BITMAPV4HEADER', size = 'bV4Size'}
BITMAPV5HEADER   = struct{ctype = 'BITMAPV5HEADER', size = 'bV5Size'}

function CreateBitmap(w, h, planes, bpp, bits)
	return checkh(C.CreateBitmap(w, h, planes, bpp, bits))
end

function CreateCompatibleBitmap(hdc, w, h)
	return checkh(C.CreateCompatibleBitmap(hdc, w, h))
end

function CreateDIBSection(hdc, bmi, usage, hSection, offset, bits)
	local bits = bits or ffi.new'void*[1]'
	local hbitmap = checkh(C.CreateDIBSection(hdc, bmi, usage, bits, hSection, offset or 0))
	return hbitmap, bits[0]
end

function SetPixel(hdc, x, y, color)
	return C.SetPixel(hdc, x, y, color) --TODO: checkclr
end

R2_BLACK            = 1   -- 0
R2_NOTMERGEPEN      = 2   -- DPon
R2_MASKNOTPEN       = 3   -- DPna
R2_NOTCOPYPEN       = 4   -- PN
R2_MASKPENNOT       = 5   -- PDna
R2_NOT              = 6   -- Dn
R2_XORPEN           = 7   -- DPx
R2_NOTMASKPEN       = 8   -- DPan
R2_MASKPEN          = 9   -- DPa
R2_NOTXORPEN        = 10  -- DPxn
R2_NOP              = 11  -- D
R2_MERGENOTPEN      = 12  -- DPno
R2_COPYPEN          = 13  -- P
R2_MERGEPENNOT      = 14  -- PDno
R2_MERGEPEN         = 15  -- DPo
R2_WHITE            = 16  -- 1
R2_LAST             = 16
SRCCOPY             = 0x00CC0020 -- dest = source
SRCPAINT            = 0x00EE0086 -- dest = source OR dest
SRCAND              = 0x008800C6 -- dest = source AND dest
SRCINVERT           = 0x00660046 -- dest = source XOR dest
SRCERASE            = 0x00440328 -- dest = source AND (NOT dest )
NOTSRCCOPY          = 0x00330008 -- dest = (NOT source)
NOTSRCERASE         = 0x001100A6 -- dest = (NOT src) AND (NOT dest)
MERGECOPY           = 0x00C000CA -- dest = (source AND pattern)
MERGEPAINT          = 0x00BB0226 -- dest = (NOT source) OR dest
PATCOPY             = 0x00F00021 -- dest = pattern
PATPAINT            = 0x00FB0A09 -- dest = DPSnoo
PATINVERT           = 0x005A0049 -- dest = pattern XOR dest
DSTINVERT           = 0x00550009 -- dest = (NOT dest)
BLACKNESS           = 0x00000042 -- dest = BLACK
WHITENESS           = 0x00FF0062 -- dest = WHITE
NOMIRRORBITMAP      = 0x80000000 -- Do not Mirror the bitmap in this call
CAPTUREBLT          = 0x40000000 -- Include layered windows

function MAKEROP4(fore,back)
	return bit.bor(bit.band(bit.lshift(back, 8), 0xFF000000), fore)
end

function BitBlt(dst, x, y, w, h, src, x1, y1, rop)
	return checknz(C.BitBlt(dst, x, y, w, h, src, x1, y1, flags(rop)))
end

function GetDIBits(hdc, hbmp, firstrow, rowcount, buf, info, usage)
	return checknz(C.GetDIBits(hdc, hbmp, firstrow, rowcount, buf, info, flags(usage)))
end
