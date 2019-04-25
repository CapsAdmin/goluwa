
--proc/system/propsys: Property System API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.sstorage'

ffi.cdef[[
typedef struct _tagpropertykey
    {
    GUID fmtid;
    DWORD pid;
    }   PROPERTYKEY;

typedef const PROPERTYKEY * REFPROPERTYKEY;

typedef struct IPropertyStore IPropertyStore;

    typedef struct IPropertyStoreVtbl
    {

        HRESULT ( __stdcall *QueryInterface )(
            IPropertyStore * This,
            REFIID riid,
            void **ppvObject);

        ULONG ( __stdcall *AddRef )(
            IPropertyStore * This);

        ULONG ( __stdcall *Release )(
            IPropertyStore * This);

        HRESULT ( __stdcall *GetCount )(
            IPropertyStore * This,
            DWORD *cProps);

        HRESULT ( __stdcall *GetAt )(
            IPropertyStore * This,
            DWORD iProp,
            PROPERTYKEY *pkey);

        HRESULT ( __stdcall *GetValue )(
            IPropertyStore * This,
            REFPROPERTYKEY key,
            PROPVARIANT *pv);

        HRESULT ( __stdcall *SetValue )(
            IPropertyStore * This,
            /* [in] */ REFPROPERTYKEY key,
            /* [in] */ REFPROPVARIANT propvar);

        HRESULT ( __stdcall *Commit )(
            IPropertyStore * This);

    } IPropertyStoreVtbl;

    struct IPropertyStore
    {
        const struct IPropertyStoreVtbl *lpVtbl;
    };
]]

IPropertyStore = ffi.typeof("IPropertyStore");
IPropertyStore_mt = {
    __index = {
        GetAt = function(self, idx, pkey)
            return self.lpVtbl.GetAt(self, idx, pkey);
        end,

        GetValue = function(self, pkey, pv)
            return self.lpVtbl.GetValue(self, pkey, pv);
        end,
    },
}
ffi.metatype(IPropertyStore, IPropertyStore_mt);


--[[
#define IPropertyStore_QueryInterface(This,riid,ppvObject)  \
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) )

#define IPropertyStore_AddRef(This) \
    ( (This)->lpVtbl -> AddRef(This) )

#define IPropertyStore_Release(This)    \
    ( (This)->lpVtbl -> Release(This) )


#define IPropertyStore_GetCount(This,cProps)    \
    ( (This)->lpVtbl -> GetCount(This,cProps) )

#define IPropertyStore_GetAt(This,iProp,pkey)   \
    ( (This)->lpVtbl -> GetAt(This,iProp,pkey) )

#define IPropertyStore_GetValue(This,key,pv)    \
    ( (This)->lpVtbl -> GetValue(This,key,pv) )

#define IPropertyStore_SetValue(This,key,propvar)   \
    ( (This)->lpVtbl -> SetValue(This,key,propvar) )

#define IPropertyStore_Commit(This) \
    ( (This)->lpVtbl -> Commit(This) )
--]]
