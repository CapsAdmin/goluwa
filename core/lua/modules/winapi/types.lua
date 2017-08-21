
--types/types: types and macros from multiple headers
--Written by Cosmin Apreutesei. Public Domain.

--NOTE: Don't define time_t because it's 64bit in windows but 32bit in mingw: use explicit types!
--NOTE: SIZE has w and h unioned to cx and cy and these are the ones used throughout.
--NOTE: RECT has x1, y1, x2, y2 unioned to left, right, top, bottom and these are the ones used throughout.

local ffi = require'ffi'

if ffi.abi'64bit' then
	ffi.cdef[[
		typedef int32_t  __int1632;
		typedef int64_t  __int3264;
		typedef uint32_t __uint1632;
		typedef uint64_t __uint3264;
	]]
else
	ffi.cdef[[
		typedef int16_t  __int1632;
		typedef int32_t  __int3264;
		typedef uint16_t __uint1632;
		typedef uint32_t __uint3264;
	]]
end

ffi.cdef[[
typedef size_t          rsize_t;
typedef unsigned short  wctype_t;
typedef int             errno_t;
typedef long            __time32_t;
typedef __int64         __time64_t;

typedef unsigned long   ULONG;
typedef ULONG           *PULONG;
typedef unsigned short  USHORT;
typedef USHORT          *PUSHORT;
typedef unsigned char   UCHAR;
typedef UCHAR           *PUCHAR;
typedef char            *PSZ;
typedef unsigned long   DWORD;
typedef int             BOOL;
typedef unsigned char   BYTE;
typedef unsigned short  WORD;
typedef float           FLOAT;
typedef double          DOUBLE;
typedef FLOAT           *PFLOAT;
typedef BOOL            *PBOOL;
typedef BOOL            *LPBOOL;
typedef BYTE            *PBYTE;
typedef BYTE            *LPBYTE;
typedef int             *PINT;
typedef int             *LPINT;
typedef WORD            *PWORD;
typedef WORD            *LPWORD;
typedef long            *LPLONG;
typedef DWORD           *PDWORD;
typedef DWORD           *LPDWORD;
typedef void            VOID;
typedef VOID            *LPVOID;
typedef const VOID      *LPCVOID;
typedef int             INT;
typedef unsigned int    UINT;
typedef unsigned int    *PUINT;
typedef unsigned long   POINTER_64_INT;
typedef signed char     INT8, *PINT8;
typedef signed short    INT16, *PINT16;
typedef signed int      INT32, *PINT32;
typedef signed __int64  INT64, *PINT64;
typedef unsigned char   UINT8, *PUINT8;
typedef unsigned short  UINT16, *PUINT16;
typedef unsigned int    UINT32, *PUINT32;
typedef unsigned __int64 UINT64, *PUINT64;
typedef signed int      LONG32, *PLONG32;
typedef unsigned int    ULONG32, *PULONG32;
typedef unsigned int    DWORD32, *PDWORD32;
typedef __int3264  INT_PTR, *PINT_PTR;
typedef __uint3264 UINT_PTR, *PUINT_PTR;
typedef __int3264  LONG_PTR, *PLONG_PTR;
typedef __uint3264 ULONG_PTR, *PULONG_PTR;
typedef __int1632  HALF_PTR, *PHALF_PTR;
typedef __uint1632 UHALF_PTR, *PUHALF_PTR;
typedef __int3264  SHANDLE_PTR;
typedef __uint3264 HANDLE_PTR;
typedef ULONG_PTR       SIZE_T, *PSIZE_T;
typedef LONG_PTR        SSIZE_T, *PSSIZE_T;
typedef ULONG_PTR       DWORD_PTR, *PDWORD_PTR;
typedef __int64         LONG64, *PLONG64;
typedef unsigned __int64 ULONG64, *PULONG64;
typedef unsigned __int64 DWORD64, *PDWORD64;
typedef VOID            *PVOID;
typedef VOID* __ptr64   PVOID64;
typedef char            CHAR;
typedef short           SHORT;
typedef long            LONG;
typedef int             INT;
typedef wchar_t         WCHAR;
typedef WCHAR           *PWCHAR, *LPWCH, *PWCH;
typedef const WCHAR     *LPCWCH, *PCWCH;
typedef WCHAR           *NWPSTR, *LPWSTR, *PWSTR;
typedef PWSTR           *PZPWSTR;
typedef const PWSTR     *PCZPWSTR;
typedef WCHAR           *LPUWSTR, *PUWSTR;
typedef const WCHAR     *LPCWSTR, *PCWSTR;
typedef PCWSTR          *PZPCWSTR;
typedef const WCHAR     *LPCUWSTR, *PCUWSTR;
typedef CHAR            *PCHAR, *LPCH, *PCH;
typedef const CHAR      *LPCCH, *PCCH;
typedef CHAR            *NPSTR, *LPSTR, *PSTR;
typedef PSTR            *PZPSTR;
typedef const PSTR      *PCZPSTR;
typedef const CHAR      *LPCSTR, *PCSTR;
typedef PCSTR           *PZPCSTR;
typedef char            TCHAR, *PTCHAR;
typedef unsigned char   TBYTE, *PTBYTE;
typedef LPCH            LPTCH, PTCH;
typedef LPSTR           PTSTR, LPTSTR, PUTSTR, LPUTSTR;
typedef LPCSTR          PCTSTR, LPCTSTR, PCUTSTR, LPCUTSTR;
typedef SHORT           *PSHORT;
typedef LONG            *PLONG;
typedef VOID            *HANDLE;
typedef HANDLE          *PHANDLE;
typedef BYTE            FCHAR;
typedef WORD            FSHORT;
typedef DWORD           FLONG;
typedef long            HRESULT;
typedef char            CCHAR;
typedef DWORD           LCID;
typedef PDWORD          PLCID;
typedef WORD            LANGID;
typedef __int64         LONGLONG;
typedef unsigned __int64 ULONGLONG;
typedef LONGLONG        *PLONGLONG;
typedef ULONGLONG       *PULONGLONG;
typedef LONGLONG        USN;

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
} LARGE_INTEGER;
typedef LARGE_INTEGER *PLARGE_INTEGER;
typedef union _ULARGE_INTEGER {
	struct {
		DWORD LowPart;
		DWORD HighPart;
	};
	struct {
		DWORD LowPart;
		DWORD HighPart;
	} u;
	ULONGLONG QuadPart;
} ULARGE_INTEGER;
typedef ULARGE_INTEGER *PULARGE_INTEGER;
typedef struct _LUID {
	DWORD LowPart;
	LONG HighPart;
} LUID, *PLUID;
typedef ULONGLONG  DWORDLONG;
typedef DWORDLONG *PDWORDLONG;
typedef BYTE  BOOLEAN;
typedef BOOLEAN *PBOOLEAN;

typedef int HFILE;

typedef struct _FILETIME {
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
} FILETIME, *PFILETIME, *LPFILETIME;

typedef HANDLE *SPHANDLE;
typedef HANDLE *LPHANDLE;
typedef HANDLE HGLOBAL;
typedef HANDLE HLOCAL;
typedef HANDLE GLOBALHANDLE;
typedef HANDLE LOCALHANDLE;

typedef struct _GUID {
    unsigned long  Data1;
    unsigned short Data2;
    unsigned short Data3;
    unsigned char  Data4[8];
} GUID, *LPGUID;

typedef GUID IID;
typedef IID *LPIID;
typedef GUID CLSID;
typedef CLSID *LPCLSID;
typedef GUID FMTID;
typedef FMTID *LPFMTID;
typedef IID* REFIID;
typedef GUID UUID;
typedef const GUID *LPCGUID;
typedef const GUID *REFGUID;
typedef GUID CLSID;
typedef CLSID *LPCLSID;
typedef const GUID *REFCLSID;

typedef UINT_PTR WPARAM;
typedef LONG_PTR LPARAM;
typedef LONG_PTR LRESULT;
struct HWND__ { int unused; }; typedef struct HWND__ *HWND;
struct HHOOK__ { int unused; }; typedef struct HHOOK__ *HHOOK;
typedef WORD   ATOM;
typedef HANDLE *SPHANDLE;
typedef HANDLE *LPHANDLE;
typedef HANDLE HGLOBAL;
typedef HANDLE HLOCAL;
typedef HANDLE GLOBALHANDLE;
typedef HANDLE LOCALHANDLE;
typedef int (*FARPROC)();
typedef int (*NEARPROC)();
typedef int (*PROC)();
typedef void *HGDIOBJ;

typedef LONG (__stdcall* WNDPROC)(HWND, UINT, WPARAM, LONG);

struct HACCEL__ { int unused; }; typedef struct HACCEL__ *HACCEL;
struct HBITMAP__ { int unused; }; typedef struct HBITMAP__ *HBITMAP;
struct HBRUSH__ { int unused; }; typedef struct HBRUSH__ *HBRUSH;
struct HCOLORSPACE__ { int unused; }; typedef struct HCOLORSPACE__ *HCOLORSPACE;
struct HDC__ { int unused; }; typedef struct HDC__ *HDC;
struct HGLRC__ { int unused; }; typedef struct HGLRC__ *HGLRC;
struct HDESK__ { int unused; }; typedef struct HDESK__ *HDESK;
struct HENHMETAFILE__ { int unused; }; typedef struct HENHMETAFILE__ *HENHMETAFILE;
struct HFONT__ { int unused; }; typedef struct HFONT__ *HFONT;
struct HICON__ { int unused; }; typedef struct HICON__ *HICON;
struct HMENU__ { int unused; }; typedef struct HMENU__ *HMENU;
struct HMETAFILE__ { int unused; }; typedef struct HMETAFILE__ *HMETAFILE;
struct HPALETTE__ { int unused; }; typedef struct HPALETTE__ *HPALETTE;
struct HPEN__ { int unused; }; typedef struct HPEN__ *HPEN;
struct HRGN__ { int unused; }; typedef struct HRGN__ *HRGN;
struct HRSRC__ { int unused; }; typedef struct HRSRC__ *HRSRC;
struct HSPRITE__ { int unused; }; typedef struct HSPRITE__ *HSPRITE;
struct HSTR__ { int unused; }; typedef struct HSTR__ *HSTR;
struct HTASK__ { int unused; }; typedef struct HTASK__ *HTASK;
struct HWINSTA__ { int unused; }; typedef struct HWINSTA__ *HWINSTA;
struct HKL__ { int unused; }; typedef struct HKL__ *HKL;
struct HWINEVENTHOOK__ { int unused; }; typedef struct HWINEVENTHOOK__ *HWINEVENTHOOK;
struct HMONITOR__ { int unused; }; typedef struct HMONITOR__ *HMONITOR;
struct HUMPD__ { int unused; }; typedef struct HUMPD__ *HUMPD;
typedef HICON HCURSOR;
typedef DWORD COLORREF;
typedef DWORD *LPCOLORREF;
struct HINSTANCE__ { int unused; }; typedef struct HINSTANCE__ *HINSTANCE;
typedef HINSTANCE HMODULE;

typedef struct tagRECT {
	union{
		struct{
			LONG left;
			LONG top;
			LONG right;
			LONG bottom;
		};
		struct{
			LONG x1;
			LONG y1;
			LONG x2;
			LONG y2;
		};
		struct{
			LONG x;
			LONG y;
		};
	};
} RECT, *PRECT,  *NPRECT,  *LPRECT;
typedef const RECT * LPCRECT;
typedef RECT RECTL, *PRECTL, *LPRECTL;
typedef const RECTL * LPCRECTL;

typedef struct tagPOINT {
	LONG  x;
	LONG  y;
} POINT, *PPOINT, *NPPOINT, *LPPOINT;

typedef struct _POINTL {
	LONG  x;
	LONG  y;
} POINTL, *PPOINTL;

typedef struct tagSIZE {
	union {
		struct {
			LONG w;
			LONG h;
		};
		struct {
			LONG cx;
			LONG cy;
		};
	};
} SIZE, *PSIZE, *LPSIZE;

typedef SIZE SIZEL;
typedef SIZE *PSIZEL, *LPSIZEL;

typedef struct tagPOINTS {
	SHORT x;
	SHORT y;
} POINTS, *PPOINTS, *LPPOINTS;

struct HKEY__ { int unused; }; typedef struct HKEY__ *HKEY;
typedef HKEY *PHKEY;
]]
