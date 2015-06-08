
--proc/ole/dragdrop: drag & drop OLE API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.ole'
require'winapi.idataobject'

DRAGDROP_S_FIRST               = 0x00040100
DRAGDROP_S_LAST                = 0x0004010F
DRAGDROP_S_DROP                = 0x00040100
DRAGDROP_S_CANCEL              = 0x00040101
DRAGDROP_S_USEDEFAULTCURSORS   = 0x00040102

DROPEFFECT_NONE   = 0
DROPEFFECT_COPY   = 1
DROPEFFECT_MOVE   = 2
DROPEFFECT_LINK   = 4
DROPEFFECT_SCROLL = 0x80000000

DATADIR_GET = 1
DATADIR_SET = 2

TYMED_HGLOBAL   = 1
TYMED_FILE      = 2
TYMED_ISTREAM   = 4
TYMED_ISTORAGE  = 8
TYMED_GDI       = 16
TYMED_MFPICT    = 32
TYMED_ENHMF     = 64
TYMED_NULL      = 0

ffi.cdef([[
typedef struct IDropTarget IDropTarget;
typedef IDropTarget *LPDROPTARGET;

typedef struct IDropTargetVtbl {

	HRESULT ( __stdcall *QueryInterface )(
		IDropTarget * This,
		REFIID riid,
		void **ppvObject);

	ULONG ( __stdcall *AddRef )(
		IDropTarget * This);

	ULONG ( __stdcall *Release )(
		IDropTarget * This);

	HRESULT ( __stdcall *DragEnter )(
		IDropTarget * This,
		IDataObject *pDataObj,
		DWORD grfKeyState,
		]]..(ffi.abi'32bit' and 'LONG x, LONG y' or 'POINTL pt')..[[,
		DWORD *pdwEffect);

	HRESULT ( __stdcall *DragOver )(
		IDropTarget * This,
		DWORD grfKeyState,
		]]..(ffi.abi'32bit' and 'LONG x, LONG y' or 'POINTL pt')..[[,
		DWORD *pdwEffect);

	HRESULT ( __stdcall *DragLeave )(
		IDropTarget * This);

	HRESULT ( __stdcall *Drop )(
		IDropTarget * This,
		IDataObject *pDataObj,
		DWORD grfKeyState,
		]]..(ffi.abi'32bit' and 'LONG x, LONG y' or 'POINTL pt')..[[,
		DWORD *pdwEffect);

} IDropTargetVtbl;

struct IDropTarget {
	struct IDropTargetVtbl *lpVtbl;
	int refcount;
};

typedef struct IDropSource IDropSource;
typedef IDropSource *LPDROPSOURCE;

typedef struct IDropSourceVtbl {

	HRESULT ( __stdcall *QueryInterface )(
		IDropSource * This,
		REFIID riid,
		void **ppvObject);

	ULONG ( __stdcall *AddRef )(
		IDropSource * This);

	ULONG ( __stdcall *Release )(
		IDropSource * This);

	HRESULT ( __stdcall *QueryContinueDrag )(
		IDropSource * This,
		BOOL fEscapePressed,
		DWORD grfKeyState);

	HRESULT ( __stdcall *GiveFeedback )(
		IDropSource * This,
		DWORD dwEffect);

} IDropSourceVtbl;

struct IDropSource {
	struct IDropSourceVtbl *lpVtbl;
};

HRESULT RegisterDragDrop(HWND hwnd, LPDROPTARGET pDropTarget);
HRESULT RevokeDragDrop(HWND hwnd);
HRESULT DoDragDrop(LPDATAOBJECT pDataObj, LPDROPSOURCE pDropSource,
            DWORD dwOKEffects, LPDWORD pdwEffect);

void ReleaseStgMedium(LPSTGMEDIUM);
]])

function RegisterDragDrop(...) return checkz(ole32.RegisterDragDrop(...)) end
function RevokeDragDrop(...) return checkz(ole32.RevokeDragDrop(...)) end
function DoDragDrop(...) return checkz(ole32.DoDragDrop(...)) end

ReleaseStgMedium = ole32.ReleaseStgMedium

