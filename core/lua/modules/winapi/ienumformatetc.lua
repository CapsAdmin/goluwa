
--proc/ole/enumformatetc: IEnumFormatETC interface
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.ole'

ffi.cdef[[
typedef WORD CLIPFORMAT;

typedef struct tagDVTARGETDEVICE {
	DWORD tdSize;
	WORD tdDriverNameOffset;
	WORD tdDeviceNameOffset;
	WORD tdPortNameOffset;
	WORD tdExtDevmodeOffset;
	BYTE tdData[1];
} DVTARGETDEVICE;

typedef struct tagFORMATETC {
	CLIPFORMAT cfFormat;
	DVTARGETDEVICE *ptd;
	DWORD dwAspect;
	LONG lindex;
	DWORD tymed;
} FORMATETC;

typedef struct tagFORMATETC *LPFORMATETC;

typedef struct IEnumFORMATETC IEnumFORMATETC;

typedef struct IEnumFORMATETCVtbl {

  HRESULT ( __stdcall *QueryInterface )(
		IEnumFORMATETC * This,
		REFIID riid,
		void **ppvObject);

  ULONG ( __stdcall *AddRef )(
		IEnumFORMATETC * This);

  ULONG ( __stdcall *Release )(
		IEnumFORMATETC * This);

  HRESULT ( __stdcall *Next )(
		IEnumFORMATETC * This,
		ULONG celt,
		FORMATETC *rgelt,
		ULONG *pceltFetched);

  HRESULT ( __stdcall *Skip )(
		IEnumFORMATETC * This,
		ULONG celt);

  HRESULT ( __stdcall *Reset )(
		IEnumFORMATETC * This);

  HRESULT ( __stdcall *Clone )(
		IEnumFORMATETC * This,
		IEnumFORMATETC **ppenum);

} IEnumFORMATETCVtbl;

struct IEnumFORMATETC {
	struct IEnumFORMATETCVtbl *lpVtbl;
};
]]

