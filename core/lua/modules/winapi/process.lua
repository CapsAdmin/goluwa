
--proc/system/process: Process API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winbase'

ffi.cdef[[
typedef struct _STARTUPINFOW {
	DWORD   cb;
	LPWSTR  lpReserved;
	LPWSTR  lpDesktop;
	LPWSTR  lpTitle;
	DWORD   dwX;
	DWORD   dwY;
	DWORD   dwXSize;
	DWORD   dwYSize;
	DWORD   dwXCountChars;
	DWORD   dwYCountChars;
	DWORD   dwFillAttribute;
	DWORD   dwFlags;
	WORD    wShowWindow;
	WORD    cbReserved2;
	LPBYTE  lpReserved2;
	HANDLE  hStdInput;
	HANDLE  hStdOutput;
	HANDLE  hStdError;
} STARTUPINFOW, *LPSTARTUPINFOW;

void GetStartupInfoW(LPSTARTUPINFOW lpStartupInfo);
]]

STARTF_USESHOWWINDOW    = 0x00000001
STARTF_USESIZE          = 0x00000002
STARTF_USEPOSITION      = 0x00000004
STARTF_USECOUNTCHARS    = 0x00000008
STARTF_USEFILLATTRIBUTE = 0x00000010
STARTF_RUNFULLSCREEN    = 0x00000020  --ignored for non-x86 platforms
STARTF_FORCEONFEEDBACK  = 0x00000040
STARTF_FORCEOFFFEEDBACK = 0x00000080
STARTF_USESTDHANDLES    = 0x00000100
STARTF_USEHOTKEY        = 0x00000200
STARTF_TITLEISLINKNAME  = 0x00000800
STARTF_TITLEISAPPID     = 0x00001000
STARTF_PREVENTPINNING   = 0x00002000

STARTUPINFO = types.STARTUPINFOW

function GetStartupInfo(si)
	si = STARTUPINFO(si)
	C.GetStartupInfoW(si)
	return si
end

--CreateProcess: dwCreationFlag values
DEBUG_PROCESS               = 0x00000001
DEBUG_ONLY_THIS_PROCESS     = 0x00000002
CREATE_SUSPENDED            = 0x00000004
DETACHED_PROCESS            = 0x00000008
CREATE_NEW_CONSOLE          = 0x00000010
NORMAL_PRIORITY_CLASS       = 0x00000020
IDLE_PRIORITY_CLASS         = 0x00000040
HIGH_PRIORITY_CLASS         = 0x00000080
REALTIME_PRIORITY_CLASS     = 0x00000100
BELOW_NORMAL_PRIORITY_CLASS = 0x00004000
ABOVE_NORMAL_PRIORITY_CLASS = 0x00008000
CREATE_NEW_PROCESS_GROUP    = 0x00000200
CREATE_UNICODE_ENVIRONMENT  = 0x00000400
CREATE_SEPARATE_WOW_VDM     = 0x00000800
CREATE_SHARED_WOW_VDM       = 0x00001000
STACK_SIZE_PARAM_IS_A_RESERVATION = 0x00010000
CREATE_BREAKAWAY_FROM_JOB   = 0x01000000
CREATE_DEFAULT_ERROR_MODE   = 0x04000000
CREATE_NO_WINDOW            = 0x08000000
PROFILE_USER                = 0x10000000
PROFILE_KERNEL              = 0x20000000
PROFILE_SERVER              = 0x40000000

ffi.cdef[[
typedef struct _PROCESS_INFORMATION {
	HANDLE hProcess;
	HANDLE hThread;
	DWORD  dwProcessId;
	DWORD  dwThreadId;
} PROCESS_INFORMATION, *LPPROCESS_INFORMATION;

BOOL CreateProcessW(
	LPCWSTR lpApplicationName,
	LPWSTR lpCommandLine,
	LPSECURITY_ATTRIBUTES lpProcessAttributes,
	LPSECURITY_ATTRIBUTES lpThreadAttributes,
	BOOL bInheritHandles,
	DWORD dwCreationFlags,
	LPCSTR lpEnvironment,
	LPCWSTR lpCurrentDirectory,
	LPSTARTUPINFOW lpStartupInfo,
	LPPROCESS_INFORMATION lpProcessInformation
);

BOOL GetExitCodeProcess(
	HANDLE hProcess,
	LPDWORD lpExitCode
);

BOOL TerminateProcess(
	HANDLE hProcess,
	UINT uExitCode
);
]]

--{var = val, ...} -> 'var1=val1\0...'
local function encode_env(env)
	if not env then return nil end
	if type(env) == 'string' or type(env) == 'cdata' then return env end
	local t = {}
	for k in pairs(env) do
		t[#t+1] = k
	end
	table.sort(t) --Windows says they must be sorted in Unicode order, pff...
	local dt = {}
	for i,k in ipairs(t) do
		dt[i] = k .. '=' .. env[k]
	end
	table.insert(dt, '')
	return table.concat(dt, '\0')
end

function CreateProcess(exe, cmdline, pattr, tattr, inherit_handles, flags, env, ...)
	checknz(C.CreateProcessW(wcs(exe), wcs(cmdline), pattr, tattr,
		inherit_handles, flags, encode_env(env), ...))
end

STILL_ACTIVE = 259

function GetExitCodeProcess(hproc, exitcode)
	exitcode = exitcode or ffi.new'DWORD[1]'
	checknz(C.GetExitCodeProcess(hproc, exitcode))
	return exitcode[0]
end

function TerminateProcess(hproc, exitcode)
	return retnz(C.TerminateProcess(hproc, exitcode or 0))
end

if not ... then
	local si = GetStartupInfo()
	print(si.wShowWindow)
end

