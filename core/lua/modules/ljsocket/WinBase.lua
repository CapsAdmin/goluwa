-- WinBase.lua
-- From WinBase.h
local ffi = require "ffi"

require "ljsocket.WTypes"

-- Winnt.h
MAXIMUM_WAIT_OBJECTS = 64     -- Maximum number of wait objects


INVALID_HANDLE_VALUE = ffi.cast("intptr_t", -1)
INVALID_FILE_SIZE         = (0xFFFFFFFF);
INVALID_SET_FILE_POINTER  = (-1);
INVALID_FILE_ATTRIBUTES   = (-1);

WAIT_TIMEOUT = 0X102;
WAIT_OBJECT_0 = 0;


FILE_SHARE_READ			= 0X01;
FILE_SHARE_WRITE		= 0X02;
FILE_FLAG_OVERLAPPED 	= 0X40000000;

FILE_READ_DATA                   = 0x0001    -- file & pipe
FILE_WRITE_DATA                  = 0x0002    -- file & pipe
FILE_APPEND_DATA                 = 0x0004    -- file
FILE_READ_EA                     = 0x0008    -- file & directory
FILE_WRITE_EA                    = 0x0010    -- file & directory
FILE_EXECUTE                     = 0x0020    -- file
FILE_READ_ATTRIBUTES             = 0x0080    -- all
FILE_WRITE_ATTRIBUTES            = 0x0100    -- all

--[[
--FILE_ALL_ACCESS             =STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0x1FF,


FILE_GENERIC_READ          =
            STANDARD_RIGHTS_READ     |
            FILE_READ_DATA           |
            FILE_READ_ATTRIBUTES     |
            FILE_READ_EA             |
            SYNCHRONIZE,


        FILE_GENERIC_WRITE         =
            STANDARD_RIGHTS_WRITE    |
            FILE_WRITE_DATA          |
            FILE_WRITE_ATTRIBUTES    |
            FILE_WRITE_EA            |
            FILE_APPEND_DATA         |
            SYNCHRONIZE,

        FILE_GENERIC_EXECUTE      =
            STANDARD_RIGHTS_EXECUTE  |
            FILE_READ_ATTRIBUTES     |
            FILE_EXECUTE             |
            SYNCHRONIZE,
--]]












OPEN_ALWAYS = 4;
OPEN_EXISTING = 3;

GENERIC_READ    = 0x80000000;
GENERIC_WRITE   = 0x40000000;
GENERIC_EXECUTE = 0x20000000;
GENERIC_ALL     = 0x10000000;

PURGE_TXABORT = 0x01;
PURGE_RXABORT = 0x02;
PURGE_TXCLEAR = 0x04;
PURGE_RXCLEAR = 0x08;




ERROR_IO_PENDING = 0x03E5; -- 997

INFINITE = 0xFFFFFFFF;


-- Access Rights
DELETE 			= 0x00010000
READ_CONTROL	= 0x00020000
WRITE_DAC		= 0x00040000
WRITE_OWNER		= 0x00080000
SYNCHRONIZE		= 0x00100000

STANDARD_RIGHTS_REQUIRED        = 0x000F0000

STANDARD_RIGHTS_READ            = READ_CONTROL
STANDARD_RIGHTS_WRITE           = READ_CONTROL
STANDARD_RIGHTS_EXECUTE         = READ_CONTROL

STANDARD_RIGHTS_ALL             = 0x001F0000
SPECIFIC_RIGHTS_ALL             = 0x0000FFFF

--THREAD_ALL_ACCESS
THREAD_DIRECT_IMPERSONATION			= 0x0200
THREAD_GET_CONTEXT					= 0x0008
THREAD_IMPERSONATE					= 0x0100
THREAD_QUERY_INFORMATION			= 0x0040
THREAD_QUERY_LIMITED_INFORMATION	= 0x0800
THREAD_SET_CONTEXT					= 0x0010
THREAD_SET_INFORMATION				= 0x0020
THREAD_SET_LIMITED_INFORMATION		= 0x0400
THREAD_SET_THREAD_TOKEN				= 0x0080
THREAD_SUSPEND_RESUME				= 0x0002
THREAD_TERMINATE					= 0x0001

-- Process dwCreationFlag values

 DEBUG_PROCESS                    = 0x00000001
 DEBUG_ONLY_THIS_PROCESS          = 0x00000002
 CREATE_SUSPENDED                 = 0x00000004
 DETACHED_PROCESS                 = 0x00000008

 CREATE_NEW_CONSOLE               = 0x00000010
 NORMAL_PRIORITY_CLASS            = 0x00000020
 IDLE_PRIORITY_CLASS              = 0x00000040
 HIGH_PRIORITY_CLASS              = 0x00000080

 REALTIME_PRIORITY_CLASS          = 0x00000100
 CREATE_NEW_PROCESS_GROUP         = 0x00000200
 CREATE_UNICODE_ENVIRONMENT       = 0x00000400
 CREATE_SEPARATE_WOW_VDM          = 0x00000800

 CREATE_SHARED_WOW_VDM            = 0x00001000
 CREATE_FORCEDOS                  = 0x00002000
 BELOW_NORMAL_PRIORITY_CLASS      = 0x00004000
 ABOVE_NORMAL_PRIORITY_CLASS      = 0x00008000

 INHERIT_PARENT_AFFINITY          = 0x00010000
 CREATE_PROTECTED_PROCESS         = 0x00040000
 EXTENDED_STARTUPINFO_PRESENT     = 0x00080000

 PROCESS_MODE_BACKGROUND_BEGIN    = 0x00100000
 PROCESS_MODE_BACKGROUND_END      = 0x00200000

 CREATE_BREAKAWAY_FROM_JOB        = 0x01000000
 CREATE_PRESERVE_CODE_AUTHZ_LEVEL = 0x02000000
 CREATE_DEFAULT_ERROR_MODE        = 0x04000000
 CREATE_NO_WINDOW                 = 0x08000000

 PROFILE_USER                     = 0x10000000
 PROFILE_KERNEL                   = 0x20000000
 PROFILE_SERVER                   = 0x40000000
 CREATE_IGNORE_SYSTEM_DEFAULT     = 0x80000000


 STACK_SIZE_PARAM_IS_A_RESERVATION   = 0x00010000    -- Threads only

--
-- Priority flags
--
--[[
 THREAD_PRIORITY_LOWEST          THREAD_BASE_PRIORITY_MIN
 THREAD_PRIORITY_BELOW_NORMAL    (THREAD_PRIORITY_LOWEST+1)
 THREAD_PRIORITY_NORMAL          0
 THREAD_PRIORITY_HIGHEST         THREAD_BASE_PRIORITY_MAX
 THREAD_PRIORITY_ABOVE_NORMAL    (THREAD_PRIORITY_HIGHEST-1)
 THREAD_PRIORITY_ERROR_RETURN    (MAXLONG)

 THREAD_PRIORITY_TIME_CRITICAL   THREAD_BASE_PRIORITY_LOWRT
 THREAD_PRIORITY_IDLE            THREAD_BASE_PRIORITY_IDLE

 THREAD_MODE_BACKGROUND_BEGIN    0x00010000
 THREAD_MODE_BACKGROUND_END      0x00020000
--]]



PROCESS_HEAP_REGION             =0x0001
PROCESS_HEAP_UNCOMMITTED_RANGE  =0x0002
PROCESS_HEAP_ENTRY_BUSY         =0x0004
PROCESS_HEAP_ENTRY_MOVEABLE     =0x0010
PROCESS_HEAP_ENTRY_DDESHARE     =0x0020

HEAP_NO_SERIALIZE				= 0x00000001
HEAP_GENERATE_EXCEPTIONS		= 0x00000004
HEAP_ZERO_MEMORY				= 0x00000008
HEAP_REALLOC_IN_PLACE_ONLY		= 0x00000010
HEAP_CREATE_ENABLE_EXECUTE		= 0x00040000


ffi.cdef[[


typedef struct _PROCESS_HEAP_ENTRY {
    PVOID lpData;
    DWORD cbData;
    BYTE cbOverhead;
    BYTE iRegionIndex;
    WORD wFlags;
    union {
        struct {
            HANDLE hMem;
            DWORD dwReserved[ 3 ];
        } Block;
        struct {
            DWORD dwCommittedSize;
            DWORD dwUnCommittedSize;
            LPVOID lpFirstBlock;
            LPVOID lpLastBlock;
        } Region;
    } DUMMYUNIONNAME;
} PROCESS_HEAP_ENTRY, *LPPROCESS_HEAP_ENTRY, *PPROCESS_HEAP_ENTRY;


HANDLE HeapCreate(DWORD flOptions,
    SIZE_T dwInitialSize,
    SIZE_T dwMaximumSize);


BOOL HeapDestroy(HANDLE hHeap);


LPVOID HeapAlloc(
    HANDLE hHeap,
    DWORD dwFlags,
    SIZE_T dwBytes);


LPVOID HeapReAlloc(HANDLE hHeap,
	DWORD dwFlags,
    LPVOID lpMem,
	SIZE_T dwBytes);

BOOL HeapFree(HANDLE hHeap, DWORD dwFlags, LPVOID lpMem);

SIZE_T HeapSize(HANDLE hHeap, DWORD dwFlags, LPCVOID lpMem);

BOOL HeapValidate(HANDLE hHeap, DWORD dwFlags, LPCVOID lpMem);

SIZE_T HeapCompact(HANDLE hHeap, DWORD dwFlags);

HANDLE GetProcessHeap( void );

DWORD GetProcessHeaps(DWORD NumberOfHeaps, PHANDLE ProcessHeaps);

BOOL HeapLock(HANDLE hHeap);

BOOL HeapUnlock(HANDLE hHeap);

BOOL HeapWalk(HANDLE hHeap, PROCESS_HEAP_ENTRY * lpEntry);

]]

--[[
BOOL HeapSetInformation (HANDLE HeapHandle,
    HEAP_INFORMATION_CLASS HeapInformationClass,
    PVOID HeapInformation,
    SIZE_T HeapInformationLength);

BOOL HeapQueryInformation (HANDLE HeapHandle,
    HEAP_INFORMATION_CLASS HeapInformationClass,
    __out_bcount_part_opt(HeapInformationLength, *ReturnLength) PVOID HeapInformation,
    SIZE_T HeapInformationLength,
    __out_opt PSIZE_T ReturnLength
    );
--]]


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



BOOL GetQueuedCompletionStatus(
    HANDLE CompletionPort,
    LPDWORD lpNumberOfBytesTransferred,
    PULONG_PTR lpCompletionKey,
    LPOVERLAPPED *lpOverlapped,
    DWORD dwMilliseconds
    );

BOOL PostQueuedCompletionStatus(
	HANDLE CompletionPort,
	DWORD dwNumberOfBytesTransferred,
	ULONG_PTR dwCompletionKey,
	LPOVERLAPPED lpOverlapped
);


typedef struct _BY_HANDLE_FILE_INFORMATION {
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD dwVolumeSerialNumber;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD nNumberOfLinks;
    DWORD nFileIndexHigh;
    DWORD nFileIndexLow;
} BY_HANDLE_FILE_INFORMATION, *PBY_HANDLE_FILE_INFORMATION, *LPBY_HANDLE_FILE_INFORMATION;
]]

