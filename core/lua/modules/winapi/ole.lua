
--proc/system/ole: OLE API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

ole32 = ffi.load'ole32'

E_NOINTERFACE = 0x80004002

CLSCTX_INPROC_SERVER           = 0x1
CLSCTX_INPROC_HANDLER          = 0x2
CLSCTX_LOCAL_SERVER            = 0x4
CLSCTX_INPROC_SERVER16         = 0x8
CLSCTX_REMOTE_SERVER           = 0x10
CLSCTX_INPROC_HANDLER16        = 0x20
CLSCTX_RESERVED1               = 0x40
CLSCTX_RESERVED2               = 0x80
CLSCTX_RESERVED3               = 0x100
CLSCTX_RESERVED4               = 0x200
CLSCTX_NO_CODE_DOWNLOAD        = 0x400
CLSCTX_RESERVED5               = 0x800
CLSCTX_NO_CUSTOM_MARSHAL       = 0x1000
CLSCTX_ENABLE_CODE_DOWNLOAD    = 0x2000
CLSCTX_NO_FAILURE_LOG          = 0x4000
CLSCTX_DISABLE_AAA             = 0x8000
CLSCTX_ENABLE_AAA              = 0x10000
CLSCTX_FROM_DEFAULT_CONTEXT    = 0x20000
CLSCTX_ACTIVATE_32_BIT_SERVER  = 0x40000
CLSCTX_ACTIVATE_64_BIT_SERVER  = 0x80000
CLSCTX_ENABLE_CLOAKING         = 0x100000
CLSCTX_APPCONTAINER            = 0x400000
CLSCTX_ACTIVATE_AAA_AS_IU      = 0x800000
CLSCTX_PS_DLL                  = 0x80000000

ffi.cdef[[
typedef ULONG PROPID;

typedef WCHAR OLECHAR;
typedef OLECHAR *LPOLESTR;
typedef const OLECHAR *LPCOLESTR;
typedef OLECHAR *BSTR;
typedef BSTR *LPBSTR;

typedef struct IUnknown IUnknown, *LPUNKNOWN;
typedef struct IStream IStream;
typedef struct IStorage IStorage;
typedef struct IAdviseSink IAdviseSink;
typedef struct IEnumSTATDATA IEnumSTATDATA;
typedef struct IDispatch IDispatch;

HRESULT OleInitialize(LPVOID pvReserved);
void    OleUninitialize(void);

HRESULT CoInitialize(LPVOID pvReserved);
void    CoUninitialize(void);

HRESULT CoCreateInstance(REFCLSID rclsid,
	IUnknown * pUnkOuter,
	DWORD dwClsContext,
	REFIID riid,
	void ** ppv);

// COM initialization flags; passed to CoInitialize.
typedef enum tagCOINIT {
	COINIT_APARTMENTTHREADED  = 0x2,      // Apartment model

	// These constants are only valid on Windows NT 4.0
	COINIT_MULTITHREADED      = 0x0,      // OLE calls objects on any thread.
	COINIT_DISABLE_OLE1DDE    = 0x4,      // Don't use DDE for Ole1 support.
	COINIT_SPEED_OVER_MEMORY  = 0x8,      // Trade memory for speed.
} COINIT;

]]

local checkokfalse = checkwith(function(ret) return ret == 0 or ret == 1 end)

function OleInitialize()
	checkokfalse(ole32.OleInitialize(nil))
end

function CoInitialize()
	checkokfalse(ole32.CoInitialize(nil))
end

OleUninitialize = ole32.OleUninitialize
CoUninitialize = ole32.CoUninitialize

function CoCreateInstance(...)
	return checkz(ole32.CoCreateInstance(...))
end

--enable Clipboard, Drag and Drop, OLE, In-place activation.
OleInitialize()

--uninitialize when the module is unloaded.
_ole32 = ffi.new'char*'
ffi.gc(_ole32, OleUninitialize)

