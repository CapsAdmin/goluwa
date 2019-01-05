local ffi = require"ffi"
local bit = require"bit"

local bnot = bit.bnot
local band = bit.band
local bor = bit.bor
local lshift = bit.lshift
local rshift = bit.rshift


ffi.cdef[[

// Basic Data types
typedef unsigned char	BYTE;
typedef long			BOOL;
typedef BYTE			BOOLEAN;
typedef char			CHAR;
typedef wchar_t			WCHAR;
typedef uint16_t		WORD;
typedef unsigned long	DWORD;
typedef uint32_t		DWORD32;
typedef int				INT;
typedef int32_t			INT32;
typedef int64_t			INT64;
typedef float 			FLOAT;
typedef long			LONG;
typedef signed int		LONG32;
typedef int64_t			LONGLONG;
typedef size_t			SIZE_T;

typedef uint8_t			BCHAR;
typedef unsigned char	UCHAR;
typedef unsigned int	UINT;
typedef unsigned int	UINT32;
typedef unsigned long	ULONG;
typedef unsigned int	ULONG32;
typedef unsigned short	USHORT;
typedef uint64_t		ULONGLONG;


// Some pointer types
typedef int *        LPINT;
typedef unsigned char *PBYTE;
typedef char *			PCHAR;
typedef uint16_t *		PWCHAR;

typedef unsigned char *PBOOLEAN;
typedef unsigned char	*PUCHAR;
typedef const unsigned char *PCUCHAR;
typedef char *      PSTR;
typedef unsigned int	*PUINT;
typedef unsigned int	*PUINT32;
typedef unsigned long	*PULONG;
typedef unsigned int	*PULONG32;
typedef unsigned short	*PUSHORT;
typedef LONGLONG 		*PLONGLONG;
typedef ULONGLONG 		*PULONGLONG;


typedef void *			PVOID;
typedef DWORD *			DWORD_PTR;
typedef intptr_t		LONG_PTR;
typedef uintptr_t		UINT_PTR;
typedef uintptr_t		ULONG_PTR;
typedef ULONG_PTR *		PULONG_PTR;


typedef DWORD *			LPCOLORREF;

typedef BOOL *			LPBOOL;
typedef char *			LPSTR;
typedef short *			LPWSTR;
typedef short *			PWSTR;
typedef const short *	LPCWSTR;
typedef const short *	PCWSTR;
typedef LPSTR			LPTSTR;

typedef DWORD *			LPDWORD;
typedef void *			LPVOID;
typedef WORD *			LPWORD;

typedef const char *	LPCSTR;
typedef const char *	PCSTR;
typedef LPCSTR			LPCTSTR;
typedef const void *	LPCVOID;


typedef LONG_PTR		LRESULT;

typedef LONG_PTR		LPARAM;
typedef UINT_PTR		WPARAM;


typedef unsigned char	TBYTE;
typedef char			TCHAR;

typedef USHORT			COLOR16;
typedef DWORD			COLORREF;

// Special types
typedef WORD			ATOM;
typedef DWORD			LCID;
typedef USHORT			LANGID;

// Various Handles
typedef void *			HANDLE;
typedef HANDLE			*PHANDLE;
typedef HANDLE			LPHANDLE;
typedef void *			HBITMAP;
typedef void *			HBRUSH;
typedef void *			HICON;
typedef HICON			HCURSOR;
typedef HANDLE			HDC;
typedef void *			HDESK;
typedef HANDLE			HDROP;
typedef HANDLE			HDWP;
typedef HANDLE			HENHMETAFILE;
typedef INT				HFILE;
typedef HANDLE			HFONT;
typedef void *			HGDIOBJ;
typedef HANDLE			HGLOBAL;
typedef HANDLE 			HGLRC;
typedef HANDLE			HHOOK;
typedef void *			HINSTANCE;
typedef void *			HKEY;
typedef void *			HKL;
typedef HANDLE			HLOCAL;
typedef void *			HMEMF;
typedef HANDLE			HMENU;
typedef HANDLE			HMETAFILE;
typedef void			HMF;
typedef HINSTANCE		HMODULE;
typedef HANDLE			HMONITOR;
typedef HANDLE			HPALETTE;
typedef void *			HPEN;
typedef LONG			HRESULT;
typedef HANDLE			HRGN;
typedef void *			HRSRC;
typedef void *			HSTR;
typedef HANDLE			HSZ;
typedef void *			HTASK;
typedef void *			HWINSTA;
typedef HANDLE			HWND;

// Ole Automation
typedef WCHAR			OLECHAR;
typedef OLECHAR 		*LPOLESTR;
typedef const OLECHAR	*LPCOLESTR;

//typedef char      OLECHAR;
//typedef LPSTR     LPOLESTR;
//typedef LPCSTR    LPCOLESTR;

typedef OLECHAR *BSTR;
typedef BSTR *LPBSTR;



typedef DWORD ACCESS_MASK;
typedef ACCESS_MASK* PACCESS_MASK;


typedef LONG FXPT16DOT16, *LPFXPT16DOT16;
typedef LONG FXPT2DOT30, *LPFXPT2DOT30;


]]

ffi.cdef[[
typedef union _LARGE_INTEGER {
	struct {
		DWORD LowPart;
		LONG HighPart;
	};
	struct {
		DWORD LowPart;
		LONG HighPart;
	} u;
	LONGLONG QuadPart;
} LARGE_INTEGER,  *PLARGE_INTEGER;

typedef struct _ULARGE_INTEGER
{
    ULONGLONG QuadPart;
} 	ULARGE_INTEGER;


typedef struct _FILETIME
{
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
} 	FILETIME;

typedef struct _FILETIME *PFILETIME;

typedef struct _FILETIME *LPFILETIME;


typedef struct _SYSTEMTIME
{
    WORD wYear;
    WORD wMonth;
    WORD wDayOfWeek;
    WORD wDay;
    WORD wHour;
    WORD wMinute;
    WORD wSecond;
    WORD wMilliseconds;
} 	SYSTEMTIME, *PSYSTEMTIME, *LPSYSTEMTIME;


typedef struct _SECURITY_ATTRIBUTES {
	DWORD nLength;
	LPVOID lpSecurityDescriptor;
	BOOL bInheritHandle;
} SECURITY_ATTRIBUTES,  *PSECURITY_ATTRIBUTES,  *LPSECURITY_ATTRIBUTES;


typedef USHORT SECURITY_DESCRIPTOR_CONTROL;

typedef USHORT *PSECURITY_DESCRIPTOR_CONTROL;

typedef PVOID PSID;

typedef struct _ACL
{
    UCHAR AclRevision;
    UCHAR Sbz1;
    USHORT AclSize;
    USHORT AceCount;
    USHORT Sbz2;
} 	ACL, *PACL;


typedef struct _SECURITY_DESCRIPTOR
{
    UCHAR Revision;
    UCHAR Sbz1;
    SECURITY_DESCRIPTOR_CONTROL Control;
    PSID Owner;
    PSID Group;
    PACL Sacl;
    PACL Dacl;
} 	SECURITY_DESCRIPTOR, *PSECURITY_DESCRIPTOR;

typedef struct _COAUTHIDENTITY
{
    USHORT *User;
    ULONG UserLength;
    USHORT *Domain;
    ULONG DomainLength;
    USHORT *Password;
    ULONG PasswordLength;
    ULONG Flags;
} 	COAUTHIDENTITY;

typedef struct _COAUTHINFO
{
    DWORD dwAuthnSvc;
    DWORD dwAuthzSvc;
    LPWSTR pwszServerPrincName;
    DWORD dwAuthnLevel;
    DWORD dwImpersonationLevel;
    COAUTHIDENTITY *pAuthIdentityData;
    DWORD dwCapabilities;
} 	COAUTHINFO;

typedef LONG SCODE;

typedef SCODE *PSCODE;


typedef
enum tagMEMCTX
    {	MEMCTX_TASK	= 1,
	MEMCTX_SHARED	= 2,
	MEMCTX_MACSYSTEM	= 3,
	MEMCTX_UNKNOWN	= -1,
	MEMCTX_SAME	= -2
    } 	MEMCTX;




typedef
enum tagMSHLFLAGS
    {	MSHLFLAGS_NORMAL	= 0,
	MSHLFLAGS_TABLESTRONG	= 1,
	MSHLFLAGS_TABLEWEAK	= 2,
	MSHLFLAGS_NOPING	= 4,
	MSHLFLAGS_RESERVED1	= 8,
	MSHLFLAGS_RESERVED2	= 16,
	MSHLFLAGS_RESERVED3	= 32,
	MSHLFLAGS_RESERVED4	= 64
    } 	MSHLFLAGS;

typedef
enum tagMSHCTX
    {	MSHCTX_LOCAL	= 0,
	MSHCTX_NOSHAREDMEM	= 1,
	MSHCTX_DIFFERENTMACHINE	= 2,
	MSHCTX_INPROC	= 3,
	MSHCTX_CROSSCTX	= 4
    } 	MSHCTX;

typedef
enum tagDVASPECT
    {	DVASPECT_CONTENT	= 1,
	DVASPECT_THUMBNAIL	= 2,
	DVASPECT_ICON	= 4,
	DVASPECT_DOCPRINT	= 8
    } 	DVASPECT;

typedef
enum tagSTGC
    {	STGC_DEFAULT	= 0,
	STGC_OVERWRITE	= 1,
	STGC_ONLYIFCURRENT	= 2,
	STGC_DANGEROUSLYCOMMITMERELYTODISKCACHE	= 4,
	STGC_CONSOLIDATE	= 8
    } 	STGC;

typedef
enum tagSTGMOVE
    {	STGMOVE_MOVE	= 0,
	STGMOVE_COPY	= 1,
	STGMOVE_SHALLOWCOPY	= 2
    } 	STGMOVE;

typedef
enum tagSTATFLAG
    {	STATFLAG_DEFAULT	= 0,
	STATFLAG_NONAME	= 1,
	STATFLAG_NOOPEN	= 2
    } 	STATFLAG;

typedef  void *HCONTEXT;

typedef struct _BYTE_BLOB
    {
    unsigned long clSize;
    uint8_t abData[ 1 ];
    } 	BYTE_BLOB;

typedef struct _WORD_BLOB
    {
    unsigned long clSize;
    unsigned short asData[ 1 ];
    } 	WORD_BLOB;

typedef struct _DWORD_BLOB
    {
    unsigned long clSize;
    unsigned long alData[ 1 ];
    } 	DWORD_BLOB;

typedef struct _FLAGGED_BYTE_BLOB
    {
    unsigned long fFlags;
    unsigned long clSize;
    uint8_t abData[ 1 ];
    } 	FLAGGED_BYTE_BLOB;

typedef struct _FLAGGED_WORD_BLOB
    {
    unsigned long fFlags;
    unsigned long clSize;
    unsigned short asData[ 1 ];
    } 	FLAGGED_WORD_BLOB;

typedef struct _BYTE_SIZEDARR
    {
    unsigned long clSize;
    uint8_t *pData;
    } 	BYTE_SIZEDARR;

typedef struct _SHORT_SIZEDARR
    {
    unsigned long clSize;
    unsigned short *pData;
    } 	WORD_SIZEDARR;

typedef struct _LONG_SIZEDARR
    {
    unsigned long clSize;
    unsigned long *pData;
    } 	DWORD_SIZEDARR;


]]

--typedef enum tagCLSCTX {
	CLSCTX_INPROC_SERVER	= 0x1
	CLSCTX_INPROC_HANDLER	= 0x2
	CLSCTX_LOCAL_SERVER	= 0x4
	CLSCTX_INPROC_SERVER16	= 0x8
	CLSCTX_REMOTE_SERVER	= 0x10
	CLSCTX_INPROC_HANDLER16	= 0x20
	CLSCTX_RESERVED1	= 0x40
	CLSCTX_RESERVED2	= 0x80
	CLSCTX_RESERVED3	= 0x100
	CLSCTX_RESERVED4	= 0x200
	CLSCTX_NO_CODE_DOWNLOAD	= 0x400
	CLSCTX_RESERVED5	= 0x800
	CLSCTX_NO_CUSTOM_MARSHAL	= 0x1000
	CLSCTX_ENABLE_CODE_DOWNLOAD	= 0x2000
	CLSCTX_NO_FAILURE_LOG	= 0x4000
	CLSCTX_DISABLE_AAA	= 0x8000
	CLSCTX_ENABLE_AAA	= 0x10000
	CLSCTX_FROM_DEFAULT_CONTEXT	= 0x20000
	CLSCTX_ACTIVATE_32_BIT_SERVER	= 0x40000
	CLSCTX_ACTIVATE_64_BIT_SERVER	= 0x80000
	CLSCTX_ENABLE_CLOAKING	= 0x100000
	CLSCTX_PS_DLL	= 0x80000000
--} 	CLSCTX;

CLSCTX_VALID_MASK = bor(
    CLSCTX_INPROC_SERVER ,
    CLSCTX_INPROC_HANDLER ,
    CLSCTX_LOCAL_SERVER ,
    CLSCTX_INPROC_SERVER16 ,
    CLSCTX_REMOTE_SERVER ,
    CLSCTX_NO_CODE_DOWNLOAD ,
    CLSCTX_NO_CUSTOM_MARSHAL ,
    CLSCTX_ENABLE_CODE_DOWNLOAD ,
    CLSCTX_NO_FAILURE_LOG ,
    CLSCTX_DISABLE_AAA ,
    CLSCTX_ENABLE_AAA ,
    CLSCTX_FROM_DEFAULT_CONTEXT ,
    CLSCTX_ACTIVATE_32_BIT_SERVER ,
    CLSCTX_ACTIVATE_64_BIT_SERVER ,
    CLSCTX_ENABLE_CLOAKING ,
    CLSCTX_PS_DLL)

WDT_INPROC_CALL	=( 0x48746457 )

WDT_REMOTE_CALL	=( 0x52746457 )

WDT_INPROC64_CALL =	( 0x50746457 )



ffi.cdef[[
enum {
	MAXSHORT = 32767,
	MINSHORT = -32768,

	MAXINT = 2147483647,
	MININT = -2147483648,

//	MAXLONGLONG = 9223372036854775807,
//	MINLONGLONG = -9223372036854775807,
	};

]]


ffi.cdef[[

typedef struct tagSIZE {
  LONG cx;
  LONG cy;
} SIZE, *PSIZE;

typedef struct tagPOINT {
  int32_t x;
  int32_t y;
} POINT, *PPOINT;

typedef struct _POINTL {
  LONG x;
  LONG y;
} POINTL, *PPOINTL;

typedef struct tagRECT {
	int32_t left;
	int32_t top;
	int32_t right;
	int32_t bottom;
} RECT, *PRECT;
]]

RECT = nil
RECT_mt = {
	__tostring = function(self)
		local str = string.format("%d %d %d %d", self.left, self.top, self.right, self.bottom)
		return str
	end,

	__index = {
	}
}
RECT = ffi.metatype("RECT", RECT_mt)

ffi.cdef[[
typedef struct _TRIVERTEX {
  LONG        x;
  LONG        y;
  COLOR16     Red;
  COLOR16     Green;
  COLOR16     Blue;
  COLOR16     Alpha;
}TRIVERTEX, *PTRIVERTEX;

typedef struct _GRADIENT_TRIANGLE {
  ULONG    Vertex1;
  ULONG    Vertex2;
  ULONG    Vertex3;
}GRADIENT_TRIANGLE, *PGRADIENT_TRIANGLE;

typedef struct _GRADIENT_RECT {
  ULONG    UpperLeft;
  ULONG    LowerRight;
}GRADIENT_RECT, *PGRADIENT_RECT;





typedef struct tagRGBQUAD {
  BYTE    rgbBlue;
  BYTE    rgbGreen;
  BYTE    rgbRed;
  BYTE    rgbReserved;
} RGBQUAD;

typedef struct tagRGBTRIPLE {
  BYTE rgbtBlue;
  BYTE rgbtGreen;
  BYTE rgbtRed;
} RGBTRIPLE;




typedef struct tagBITMAP {
  LONG   bmType;
  LONG   bmWidth;
  LONG   bmHeight;
  LONG   bmWidthBytes;
  WORD   bmPlanes;
  WORD   bmBitsPixel;
  LPVOID bmBits;
} BITMAP, *PBITMAP;

typedef struct tagBITMAPCOREHEADER {
  DWORD   bcSize;
  WORD    bcWidth;
  WORD    bcHeight;
  WORD    bcPlanes;
  WORD    bcBitCount;
} BITMAPCOREHEADER, *PBITMAPCOREHEADER;

typedef struct tagBITMAPINFOHEADER{
  DWORD  biSize;
  LONG   biWidth;
  LONG   biHeight;
  WORD   biPlanes;
  WORD   biBitCount;
  DWORD  biCompression;
  DWORD  biSizeImage;
  LONG   biXPelsPerMeter;
  LONG   biYPelsPerMeter;
  DWORD  biClrUsed;
  DWORD  biClrImportant;
} BITMAPINFOHEADER, *PBITMAPINFOHEADER;


typedef struct tagBITMAPINFO {
  BITMAPINFOHEADER bmiHeader;
  RGBQUAD          bmiColors[1];
} BITMAPINFO, *PBITMAPINFO;


typedef struct tagCIEXYZ {
  FXPT2DOT30 ciexyzX;
  FXPT2DOT30 ciexyzY;
  FXPT2DOT30 ciexyzZ;
} CIEXYZ, * PCIEXYZ;


typedef struct tagCIEXYZTRIPLE {
  CIEXYZ  ciexyzRed;
  CIEXYZ  ciexyzGreen;
  CIEXYZ  ciexyzBlue;
} CIEXYZTRIPLE, *PCIEXYZTRIPLE;



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
} BITMAPV4HEADER, *PBITMAPV4HEADER;

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
} BITMAPV5HEADER, *PBITMAPV5HEADER;

]]


BITMAPINFOHEADER = nil
BITMAPINFOHEADER_mt = {

	__index = {
    __new = function(ct)
    print("BITMAPINFOHEADER_ct")
      local obj = ffi.new(ct);
      obj.biSize = ffi.sizeof("BITMAPINFOHEADER")
      return obj;
    end,

		Init = function(self)
			self.biSize = ffi.sizeof("BITMAPINFOHEADER")
		end,
	}
}
BITMAPINFOHEADER = ffi.metatype("BITMAPINFOHEADER", BITMAPINFOHEADER_mt)


BITMAPINFO = ffi.typeof("BITMAPINFO")
BITMAPINFO_mt = {
  __new = function(ct)
  print("BITMAPINFO_ct")
    local obj = ffi.new(ct);
    obj.bmiHeader:Init();
    return obj;
  end,

  __index = {
    Init = function(self)
      self.bmiHeader:Init();
    end,
  },
}
BITMAPINFO = ffi.metatype("BITMAPINFO", BITMAPINFO_mt)

