
--proc/system/file: file I/O
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winbase'
require'winapi.winnt'

CREATE_NEW        = 1
CREATE_ALWAYS     = 2
OPEN_EXISTING     = 3
OPEN_ALWAYS       = 4
TRUNCATE_EXISTING = 5

ffi.cdef[[
typedef struct _OVERLAPPED {
	ULONG_PTR Internal;
	ULONG_PTR InternalHigh;
	union {
		struct {
			DWORD Offset;
			DWORD OffsetHigh;
		};
	  PVOID Pointer;
	};
	HANDLE hEvent;
} OVERLAPPED, *LPOVERLAPPED;

typedef struct _OVERLAPPED_ENTRY {
	ULONG_PTR lpCompletionKey;
	LPOVERLAPPED lpOverlapped;
	ULONG_PTR Internal;
	DWORD dwNumberOfBytesTransferred;
} OVERLAPPED_ENTRY, *LPOVERLAPPED_ENTRY;

HANDLE CreateFileW(
	LPCWSTR lpFileName,
	DWORD dwDesiredAccess,
	DWORD dwShareMode,
	LPSECURITY_ATTRIBUTES lpSecurityAttributes,
	DWORD dwCreationDisposition,
	DWORD dwFlagsAndAttributes,
	HANDLE hTemplateFile
);

BOOL WriteFile(
	HANDLE hFile,
	LPCVOID lpBuffer,
	DWORD nNumberOfBytesToWrite,
	LPDWORD lpNumberOfBytesWritten,
	LPOVERLAPPED lpOverlapped
);

BOOL ReadFile(
	HANDLE hFile,
	LPVOID lpBuffer,
	DWORD nNumberOfBytesToRead,
	LPDWORD lpNumberOfBytesRead,
	LPOVERLAPPED lpOverlapped
);

BOOL FlushFileBuffers(HANDLE hFile);
]]

local function validhi(ret)
	return ret ~= INVALID_HANDLE_VALUE,
		'handle expected, got INVALID_HANDLE_VALUE'
end
local rethi = retwith(validhi)

function CreateFile(filename, accessflags, sharemode, secattrs, creationdisp,
	flagsandattrs, htemplatefile)
	return rethi(C.CreateFileW(
		wcs(filename), flags(accessflags), flags(sharemode), secattrs,
		flags(creationdisp), flags(flagsandattrs), htemplatefile))
end

--return the number of bytes read/written or nil,err,errcode.
local function ioop(outbytes, ret, ...)
	outbytes = outbytes or ffi.new'DWORD[1]'
	if ret then
		return outbytes[0]
	else
		return nil, ...
	end
end

function WriteFile(hfile, buf, sz, overlapped, outbytes)
	return ioop(outbytes, C.WriteFile(hfile, buf, sz, outbytes, overlapped))
end

function ReadFile(hfile, buf, sz, overlapped, outbytes)
	return ioop(outbytes, C.ReadFile(hfile, buf, sz, outbytes, overlapped))
end

function FlushFileBuffers(hfile)
	return retnz(C.FlushFileBuffers(hfile))
end

if not ... then
	local tmpname = '_CreateFileTest.tmp'
	local f = assert(CreateFile(tmpname, 'GENERIC_WRITE', 0, nil,
		'OPEN_ALWAYS', 'FILE_ATTRIBUTE_NORMAL'))
	assert(CloseHandle(f))
	os.remove(tmpname)
end
