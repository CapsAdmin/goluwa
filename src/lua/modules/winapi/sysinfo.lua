
--proc/system/sysinfo: System Info API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

--GetSystemInfo

ffi.cdef[[
typedef struct _SYSTEM_INFO {
    union {
        DWORD dwOemId;
        struct {
            WORD wProcessorArchitecture;
            WORD wReserved;
        };
    };
    DWORD dwPageSize;
    LPVOID lpMinimumApplicationAddress;
    LPVOID lpMaximumApplicationAddress;
    DWORD_PTR dwActiveProcessorMask;
    DWORD dwNumberOfProcessors;
    DWORD dwProcessorType;
    DWORD dwAllocationGranularity;
    WORD wProcessorLevel;
    WORD wProcessorRevision;
} SYSTEM_INFO, *LPSYSTEM_INFO;

void GetSystemInfo(LPSYSTEM_INFO lpSystemInfo);
]]

function GetSystemInfo(sysinfo)
	local sysinfo = sysinfo or ffi.new'SYSTEM_INFO'
	C.GetSystemInfo(sysinfo)
	return sysinfo
end

--GetVersionEx

ffi.cdef[[
typedef struct _OSVERSIONINFOEXW {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;       // always 2
    WCHAR szCSDVersion[128];
    WORD  wServicePackMajor;
    WORD  wServicePackMinor;
    WORD  wSuiteMask;         // VER_SUITE_*
    BYTE  wProductType;       // VER_NT_*
    BYTE  wReserved;
} OSVERSIONINFOEXW, *POSVERSIONINFOEXW, *LPOSVERSIONINFOEXW, RTL_OSVERSIONINFOEXW, *PRTL_OSVERSIONINFOEXW;

BOOL  GetVersionExW(LPOSVERSIONINFOEXW lpVersionInfo);
DWORD RtlGetVersion(PRTL_OSVERSIONINFOEXW lpVersionInformation);
]]

VER_SUITE_SMALLBUSINESS             = 0x00000001
VER_SUITE_ENTERPRISE                = 0x00000002
VER_SUITE_BACKOFFICE                = 0x00000004
VER_SUITE_COMMUNICATIONS            = 0x00000008
VER_SUITE_TERMINAL                  = 0x00000010
VER_SUITE_SMALLBUSINESS_RESTRICTED  = 0x00000020
VER_SUITE_EMBEDDEDNT                = 0x00000040
VER_SUITE_DATACENTER                = 0x00000080
VER_SUITE_SINGLEUSERTS              = 0x00000100
VER_SUITE_PERSONAL                  = 0x00000200
VER_SUITE_BLADE                     = 0x00000400
VER_SUITE_EMBEDDED_RESTRICTED       = 0x00000800
VER_SUITE_SECURITY_APPLIANCE        = 0x00001000
VER_SUITE_STORAGE_SERVER            = 0x00002000
VER_SUITE_COMPUTE_SERVER            = 0x00004000
VER_SUITE_WH_SERVER                 = 0x00008000

VER_NT_DOMAIN_CONTROLLER            = 0x0000002 --domain controler for VER_NT_SERVER.
VER_NT_SERVER                       = 0x0000003 --Server 2013, 2008 R2, 2008, 2003, 2000.
VER_NT_WORKSTATION                  = 0x0000001 --8, 7, Vista, XP Pro, XP Home, 200O Pro.

local function forcembs(ver)
	return mbs(ffi.cast('WCHAR*', ver))
end

OSVERSIONINFOEX = struct{
	ctype = 'OSVERSIONINFOEXW', size = 'dwOSVersionInfoSize',
	fields = sfields{
		'ServicePackString', 'szCSDVersion', pass, forcembs,
	},
}

--NOTE: GetVersionEx lies about Win8.1 being Win8.0 (i.e. 6.2 instead of 6.3).
--To make it not lie, you have to use a dreaded manifest.
--Better use RtlGetVersion which doesn't (yet) lie.
function GetVersionEx(info)
	info = OSVERSIONINFOEX(info)
	checknz(C.GetVersionExW(info))
	return info
end

local ntdll
function RtlGetVersion(info)
	ntdll = ntdll or ffi.load'ntdll'
	info = OSVERSIONINFOEX(info)
	checkz(ntdll.RtlGetVersion(info))
	return info
end

if not ... then
	local sysinfo = GetSystemInfo()

	local function print_verinfo(how)
		local verinfo = _M[how]()
		print(how, 'Windows ' ..
				verinfo.dwMajorVersion .. '.' .. verinfo.dwMinorVersion .. '.' .. verinfo.dwBuildNumber .. ' ' ..
				'SP ' .. verinfo.wServicePackMajor .. '.' .. verinfo.wServicePackMinor .. ' (' ..
				verinfo.ServicePackString .. ')')
	end

	print_verinfo'GetVersionEx'
	print_verinfo'RtlGetVersion'
end

