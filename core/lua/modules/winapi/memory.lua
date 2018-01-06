
--proc/system/memory: Memory Management API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winnt'

-- Global Memory Flags
GMEM_FIXED           = 0x0000
GMEM_MOVEABLE        = 0x0002
GMEM_NOCOMPACT       = 0x0010
GMEM_NODISCARD       = 0x0020
GMEM_ZEROINIT        = 0x0040
GMEM_MODIFY          = 0x0080
GMEM_DISCARDABLE     = 0x0100
GMEM_NOT_BANKED      = 0x1000
GMEM_SHARE           = 0x2000
GMEM_DDESHARE        = 0x2000
GMEM_NOTIFY          = 0x4000
GMEM_LOWER           = GMEM_NOT_BANKED
GMEM_VALID_FLAGS     = 0x7F72
GMEM_INVALID_HANDLE  = 0x8000
GHND                 = bit.bor(GMEM_MOVEABLE, GMEM_ZEROINIT)
GPTR                 = bit.bor(GMEM_FIXED, GMEM_ZEROINIT)
-- Flags returned by GlobalFlags (in addition to GMEM_DISCARDABLE)
GMEM_DISCARDED       = 0x4000
GMEM_LOCKCOUNT       = 0x00FF

ffi.cdef[[
LPVOID GlobalLock(HGLOBAL hMem);
BOOL  GlobalUnlock(HGLOBAL hMem);
SIZE_T GlobalSize(HGLOBAL hMem);
HGLOBAL GlobalAlloc(UINT uFlags, SIZE_T dwBytes);
HGLOBAL GlobalFree(HGLOBAL hMem);

LPVOID VirtualAlloc(LPVOID lpAddress, SIZE_T dwSize, DWORD flAllocationType, DWORD flProtect);
BOOL VirtualProtect(LPVOID lpAddress, SIZE_T dwSize, DWORD flNewProtect, PDWORD lpflOldProtect);
BOOL VirtualFree(LPVOID lpAddress, SIZE_T dwSize, DWORD dwFreeType);

HANDLE GetProcessHeap(void);
HANDLE HeapCreate(DWORD flOptions, SIZE_T dwInitialSize, SIZE_T dwMaximumSize);
BOOL HeapDestroy(HANDLE hHeap);
LPVOID HeapAlloc(HANDLE hHeap, DWORD dwFlags, SIZE_T dwBytes);
LPVOID HeapReAlloc(HANDLE hHeap, DWORD dwFlags, LPVOID lpMem, SIZE_T dwBytes);
BOOL HeapFree(HANDLE hHeap, DWORD dwFlags, LPVOID lpMem);
BOOL HeapValidate(HANDLE hHeap, DWORD dwFlags, LPCVOID lpMem);
]]

function GlobalLock(hmem)
	return ptr(ffi.C.GlobalLock(hmem))
end

function GlobalUnlock(hmem)
	return callnz2(ffi.C.GlobalUnlock, hmem)
end

function GlobalSize(hmem)
	return checknz(ffi.C.GlobalSize(hmem))
end

function GlobalAlloc(GMEM, sz)
	return checkh(ffi.C.GlobalAlloc(flags(GMEM), sz))
end

function GlobalFree(h)
	return checknz(ffi.C.GlobalFree(h) == nil and 1 or 0)
end

MEM_COMMIT        = 0x00001000
MEM_RESERVE       = 0x00002000
MEM_DECOMMIT      = 0x00004000
MEM_RELEASE       = 0x00008000
MEM_FREE          = 0x00010000
MEM_PRIVATE       = 0x00020000
MEM_MAPPED        = 0x00040000
MEM_RESET         = 0x00080000
MEM_TOP_DOWN      = 0x00100000
MEM_WRITE_WATCH   = 0x00200000
MEM_PHYSICAL      = 0x00400000
MEM_ROTATE        = 0x00800000
MEM_LARGE_PAGES   = 0x20000000
MEM_4MB_PAGES     = 0x80000000

MEM_IMAGE         = SEC_IMAGE

WRITE_WATCH_FLAG_RESET  = 0x01

function VirtualAlloc(addr, size, MEM, PAGE)
	return checkh(C.VirtualAlloc(addr, size, flags(MEM), flags(PAGE)))
end

function VirtualProtect(addr, size, newprotect, oldprotect)
	oldprotect = oldprotect or ffi.new'DWORD[1]'
	checknz(C.VirtualProtect(addr, size, flags(newprotect), oldprotect))
	return oldprotect
end

MEM_DECOMMIT = 0x4000
MEM_RELEASE  = 0x8000 --size must be 0 with this flag

function VirtualFree(addr, size, freetype)
	checknz(C.VirtualFree(addr, size or 0, flags(freetype or MEM_RELEASE)))
end

HEAP_NO_SERIALIZE          = 0x00000001
HEAP_GENERATE_EXCEPTIONS   = 0x00000004
HEAP_ZERO_MEMORY           = 0x00000008
HEAP_REALLOC_IN_PLACE_ONLY = 0x00000010
HEAP_CREATE_ENABLE_EXECUTE = 0x00040000

GetProcessHeap = C.GetProcessHeap

function HeapCreate(HEAP, initsz, maxsz)
	return checkh(C.HeapCreate(flags(HEAP), initsz or 0, maxsz or 0))
end

function HeapDestroy(heap)
	checknz(C.HeapDestroy(heap))
end

function HeapAlloc(heap, HEAP, bytes)
	return checkh(C.HeapAlloc(heap, flags(HEAP), bytes))
end

function HeapReAlloc(heap, HEAP, mem, bytes)
	return checkh(C.HeapReAlloc(heap, flags(HEAP), mem, bytes))
end

function HeapFree(heap, HEAP, mem)
	return checknz(C.HeapFree(heap, flags(HEAP), mem))
end

function HeapValidate(heap, HEAP, mem)
	return checknz(C.HeapValidate(heap, flags(HEAP), mem))
end

