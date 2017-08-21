
--proc/ole/dataobject: IDataObject interface
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.ole'
require'winapi.ienumformatetc'

ffi.cdef[[
typedef void *HMETAFILEPICT;

typedef struct tagSTGMEDIUM {
	DWORD tymed;
	union {
		HBITMAP hBitmap;
		HMETAFILEPICT hMetaFilePict;
		HENHMETAFILE hEnhMetaFile;
		HGLOBAL hGlobal;
		LPOLESTR lpszFileName;
		IStream *pstm;
		IStorage *pstg;
	};
	IUnknown *pUnkForRelease;
} uSTGMEDIUM;

typedef uSTGMEDIUM STGMEDIUM;
typedef STGMEDIUM* LPSTGMEDIUM;
]]

ffi.cdef[[
typedef struct IDataObject IDataObject;
typedef IDataObject *LPDATAOBJECT;

typedef struct IDataObjectVtbl {

	HRESULT ( __stdcall *QueryInterface )(
		IDataObject * This,
		REFIID riid,
		void **ppvObject);

	ULONG ( __stdcall *AddRef )(
		IDataObject * This);

	ULONG ( __stdcall *Release )(
		IDataObject * This);

	HRESULT ( __stdcall *GetData )(
		IDataObject * This,
		FORMATETC *pformatetcIn,
		STGMEDIUM *pmedium);

	HRESULT ( __stdcall *GetDataHere )(
		IDataObject * This,
		FORMATETC *pformatetc,
		STGMEDIUM *pmedium);

	HRESULT ( __stdcall *QueryGetData )(
		IDataObject * This,
		FORMATETC *pformatetc);

	HRESULT ( __stdcall *GetCanonicalFormatEtc )(
		IDataObject * This,
		FORMATETC *pformatectIn,
		FORMATETC *pformatetcOut);

	HRESULT ( __stdcall *SetData )(
		IDataObject * This,
		FORMATETC *pformatetc,
		STGMEDIUM *pmedium,
		BOOL fRelease);

	HRESULT ( __stdcall *EnumFormatEtc )(
		IDataObject * This,
		DWORD dwDirection,
		IEnumFORMATETC **ppenumFormatEtc);

	HRESULT ( __stdcall *DAdvise )(
		IDataObject * This,
		FORMATETC *pformatetc,
		DWORD advf,
		IAdviseSink *pAdvSink,
		DWORD *pdwConnection);

	HRESULT ( __stdcall *DUnadvise )(
		IDataObject * This,
		DWORD dwConnection);

	HRESULT ( __stdcall *EnumDAdvise )(
		IDataObject * This,
		IEnumSTATDATA **ppenumAdvise);

} IDataObjectVtbl;

struct IDataObject {
	struct IDataObjectVtbl *lpVtbl;
};
]]

