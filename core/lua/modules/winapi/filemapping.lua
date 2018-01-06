
--proc/system/filemapping: memory mapped files
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winbase'
require'winapi.winnt'

ffi.cdef[[
HANDLE CreateFileMappingW(
	HANDLE hFile,
	LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
	DWORD flProtect,
	DWORD dwMaximumSizeHigh,
	DWORD dwMaximumSizeLow,
	LPCWSTR lpName
);

LPVOID MapViewOfFileEx(
	HANDLE hFileMappingObject,
	DWORD dwDesiredAccess,
	DWORD dwFileOffsetHigh,
	DWORD dwFileOffsetLow,
	SIZE_T dwNumberOfBytesToMap,
	LPVOID lpBaseAddress
);

BOOL UnmapViewOfFile(
	LPCVOID lpBaseAddress
);

BOOL FlushViewOfFile(LPCVOID lpBaseAddress, SIZE_T dwNumberOfBytesToFlush);
]]

FILE_MAP_WRITE      = SECTION_MAP_WRITE
FILE_MAP_READ       = SECTION_MAP_READ
FILE_MAP_ALL_ACCESS = SECTION_ALL_ACCESS
FILE_MAP_COPY       = 0x00000001
FILE_MAP_RESERVE    = 0x80000000
FILE_MAP_EXECUTE    = SECTION_MAP_EXECUTE_EXPLICIT --XP SP2+

function CreateFileMapping(hfile, secattrs, protect, maxsize, name)
	hfile = hfile or INVALID_HANDLE_VALUE
	local mhi, mlo = split_uint64(maxsize)
	return reth(C.CreateFileMappingW(
		hfile, secattrs, flags(protect), mhi, mlo, wcs(name)))
end

function MapViewOfFile(hfilemap, access, offset, sz, baseaddr)
	local ohi, olo = split_uint64(offset)
	return reth(C.MapViewOfFileEx(hfilemap, flags(access), ohi, olo, sz, baseaddr))
end

function UnmapViewOfFile(baseaddr)
	checknz(C.UnmapViewOfFile(baseaddr))
end

function FlushViewOfFile(baseaddr, sz)
	return retnz(C.FlushViewOfFile(baseaddr, sz))
end

if not ... then
	for i=1,100 do
		local sz = 100*1024^2
		local fm = assert(CreateFileMapping(nil, nil, 'PAGE_READWRITE', sz, 'big_shm'))
		print(fm)
		local p = MapViewOfFile(fm, 'FILE_MAP_WRITE', 0, sz)
		print(p)
		assert(FlushViewOfFile(p, sz))
		UnmapViewOfFile(p)
		assert(CloseHandle(fm))
	end
end
