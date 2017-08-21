
--proc/system/winbase: winbase.h. incomplete :)
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

FILE_FLAG_WRITE_THROUGH         = 0x80000000
FILE_FLAG_OVERLAPPED            = 0x40000000
FILE_FLAG_NO_BUFFERING          = 0x20000000
FILE_FLAG_RANDOM_ACCESS         = 0x10000000
FILE_FLAG_SEQUENTIAL_SCAN       = 0x08000000
FILE_FLAG_DELETE_ON_CLOSE       = 0x04000000
FILE_FLAG_BACKUP_SEMANTICS      = 0x02000000
FILE_FLAG_POSIX_SEMANTICS       = 0x01000000
FILE_FLAG_SESSION_AWARE         = 0x00800000
FILE_FLAG_OPEN_REPARSE_POINT    = 0x00200000
FILE_FLAG_OPEN_NO_RECALL        = 0x00100000
FILE_FLAG_FIRST_PIPE_INSTANCE   = 0x00080000
FILE_FLAG_OPEN_REQUIRING_OPLOCK = 0x00040000 --Win8+

INVALID_HANDLE_VALUE = ffi.cast('HANDLE', -1)

ffi.cdef[[
typedef struct _SECURITY_ATTRIBUTES {
	DWORD  nLength;
	LPVOID lpSecurityDescriptor;
	BOOL   bInheritHandle;
} SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;

DWORD GetCurrentThreadId(void);

BOOL CloseHandle (HANDLE hObject);
BOOL DuplicateHandle (
	HANDLE hSourceProcessHandle,
	HANDLE hSourceHandle,
	HANDLE hTargetProcessHandle,
	LPHANDLE lpTargetHandle,
	DWORD dwDesiredAccess,
	BOOL bInheritHandle,
	DWORD dwOptions);

BOOL GetHandleInformation (HANDLE hObject, LPDWORD lpdwFlags);
BOOL SetHandleInformation (HANDLE hObject, DWORD dwMask, DWORD dwFlags);
]]

GetCurrentThreadId = C.GetCurrentThreadId

function CloseHandle(h)
	return retnz(C.CloseHandle(h))
end

