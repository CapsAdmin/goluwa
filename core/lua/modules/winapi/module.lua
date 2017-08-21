
--proc/system/module: LoadLibrary API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winuser'

ffi.cdef[[
HMODULE GetModuleHandleW(
     LPCWSTR lpModuleName
    );

BOOL GetModuleHandleExW(
			DWORD dwFlags,
         LPCWSTR lpModuleName,
         HMODULE* phModule
    );

HMODULE LoadLibraryW(LPCWSTR lpLibFileName);
]]

function GetModuleHandle(name)
	return checkh(C.GetModuleHandleW(wcs(name)))
end

GET_MODULE_HANDLE_EX_FLAG_PIN                 = 0x00000001
GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT  = 0x00000002
GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS        = 0x00000004

function GetModuleHandleEx(name, GMHX, h)
	h = types.HMODULE(h)
	checkz(C.GetModuleHandleExW(flags(GMHX), wcs(name), h))
	return h
end

function LoadLibrary(filename)
    return checkh(C.LoadLibraryW(wcs(filename)))
end

if not ... then
print(GetModuleHandle())
print(LoadLibrary'shell32')
end
