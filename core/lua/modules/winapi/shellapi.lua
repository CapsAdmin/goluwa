
--proc/system/shellapi: Shell32 API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winuser'
require'winapi.winnt'

shell32 = ffi.load'Shell32'

--file info ------------------------------------------------------------------

ffi.cdef[[
typedef struct _SHFILEINFOW {
	HICON hIcon;
	int   iIcon;
	DWORD dwAttributes;
	WCHAR szDisplayName[260];
	WCHAR szTypeName[80];
} SHFILEINFOW;

extern DWORD_PTR SHGetFileInfoW(LPCWSTR pszPath, DWORD dwFileAttributes,
	SHFILEINFOW *psfi, UINT cbFileInfo, UINT uFlags);
]]

SHFILEINFO = struct{
	ctype = 'SHFILEINFOW',
}

SHGFI_ICON              = 0x000000100 -- get icon
SHGFI_DISPLAYNAME       = 0x000000200 -- get display name
SHGFI_TYPENAME          = 0x000000400 -- get type name
SHGFI_ATTRIBUTES        = 0x000000800 -- get attributes
SHGFI_ICONLOCATION      = 0x000001000 -- get icon location
SHGFI_EXETYPE           = 0x000002000 -- return exe type
SHGFI_SYSICONINDEX      = 0x000004000 -- get system icon index
SHGFI_LINKOVERLAY       = 0x000008000 -- put a link overlay on icon
SHGFI_SELECTED          = 0x000010000 -- show icon in selected state
SHGFI_ATTR_SPECIFIED    = 0x000020000 -- get only specified attributes
SHGFI_LARGEICON         = 0x000000000 -- get large icon
SHGFI_SMALLICON         = 0x000000001 -- get small icon
SHGFI_OPENICON          = 0x000000002 -- get open icon
SHGFI_SHELLICONSIZE     = 0x000000004 -- get shell size icon
SHGFI_PIDL              = 0x000000008 -- pszPath is a pidl
SHGFI_USEFILEATTRIBUTES = 0x000000010 -- use passed dwFileAttribute
SHGFI_ADDOVERLAYS       = 0x000000020 -- apply the appropriate overlays
SHGFI_OVERLAYINDEX      = 0x000000040 -- Get the index of the overlay

function SHGetFileInfo(path, fileattr, SHGFI, fileinfo)
	fileinfo = SHFILEINFO(fileinfo)
	return shell32.SHGetFileInfoW(wcs(path), flags(fileattr), fileinfo,
		ffi.sizeof'SHFILEINFOW', flags(SHGFI)), fileinfo
end

--notify icons ---------------------------------------------------------------

ffi.cdef[[
typedef struct _NOTIFYICONDATAW {
    DWORD cbSize;
    HWND hwnd;
    UINT id;
    UINT uFlags;
    UINT uCallbackMessage;
    HICON hIcon;
    WCHAR szTip[128];  // Win2K+
    DWORD dwState;
    DWORD dwStateMask;
    WCHAR szInfo[256]; // Win2K+
    union {
        UINT uTimeout;
        UINT uVersion; // used with NIM_SETVERSION, values 0, 3 and 4
    };
    WCHAR szInfoTitle[64];
    DWORD dwInfoFlags;
    GUID guidItem;       // WinXP+
    HICON hBalloonIcon;  // Vista+
} NOTIFYICONDATAW, *PNOTIFYICONDATAW;

typedef struct _NOTIFYICONIDENTIFIER {
    DWORD cbSize;
    HWND hWnd;
    UINT uID;
    GUID guidItem;
} NOTIFYICONIDENTIFIER, *PNOTIFYICONIDENTIFIER;

BOOL Shell_NotifyIconW(DWORD dwMessage, PNOTIFYICONDATAW lpData);
void Shell_NotifyIconGetRect(const NOTIFYICONIDENTIFIER* identifier, RECT* iconLocation);
]]

--messages
WM_USER                 = 0x0400
NIN_SELECT              = (WM_USER + 0)
NINF_KEY                = 0x1
NIN_KEYSELECT           = bit.bor(NIN_SELECT, NINF_KEY)
NIN_BALLOONSHOW         = (WM_USER + 2) --XP+
NIN_BALLOONHIDE         = (WM_USER + 3) --XP+
NIN_BALLOONTIMEOUT      = (WM_USER + 4) --XP+
NIN_BALLOONUSERCLICK    = (WM_USER + 5) --XP+
NIN_POPUPOPEN           = (WM_USER + 6) --Vista+
NIN_POPUPCLOSE          = (WM_USER + 7) --Vista+

--actions
NIM_ADD         = 0x00000000
NIM_MODIFY      = 0x00000001
NIM_DELETE      = 0x00000002
NIM_SETFOCUS    = 0x00000003
NIM_SETVERSION  = 0x00000004

--bitmask/flags
NIF_MESSAGE     = 0x00000001
NIF_ICON        = 0x00000002
NIF_TIP         = 0x00000004
NIF_STATE       = 0x00000008
NIF_INFO        = 0x00000010
NIF_GUID        = 0x00000020 --Vista+
NIF_REALTIME    = 0x00000040 --Vista+
NIF_SHOWTIP     = 0x00000080 --Vista+

--state flags
NIS_HIDDEN      = 0x00000001 --Vista+
NIS_SHAREDICON  = 0x00000002 --Vista+

--infotip flags (mutually exclusive)
NIIF_NONE       = 0x00000000
NIIF_INFO       = 0x00000001
NIIF_WARNING    = 0x00000002
NIIF_ERROR      = 0x00000003
NIIF_USER       = 0x00000004 --XP SP2+ / WS03 SP1+
NIIF_ICON_MASK  = 0x0000000F --XP SP2+ / WS03 SP1+
NIIF_NOSOUND    = 0x00000010 --XP SP2+ / WS03 SP1+
NIIF_LARGE_ICON = 0x00000020 --Vista+
NIIF_RESPECT_QUIET_TIME = 0x00000080 --Win7+

NOTIFYICONDATA = struct{
	ctype = 'NOTIFYICONDATAW', size = 'cbSize', mask = 'uFlags',
	fields = mfields{
		'message',      'uCallbackMessage', NIF_MESSAGE, pass, pass,
		'icon',         'hIcon',            NIF_ICON, pass, pass,
		'tip',          '',                 NIF_TIP, wc_set'szTip', wc_get'szTip',
		'__state',      'dwState',          NIF_STATE, pass, pass,
		'__stateMask',  'dwStateMask',      NIF_STATE, pass, pass,
		'info',         '',                 NIF_INFO, wc_set'szInfo', wc_get'szInfo',
		'info_title',   '',      				NIF_INFO, wc_set'szInfoTitle', wc_get'szInfoTitle',
		'info_flags',   'dwInfoFlags',      NIF_INFO, flags, pass,
		'info_timeout', 'uTimeout',         NIF_INFO, pass, pass,
	},
	bitfields = {
		state = {'__state', '__stateMask', 'NIS'},
	},
}

function Shell_NotifyIcon(msg, data)
	data = NOTIFYICONDATA(data)
	checknz(shell32.Shell_NotifyIconW(msg, data))
end

--drag & drop files ----------------------------------------------------------

ffi.cdef[[
struct HDROP__ { int unused; };
typedef struct HDROP__ *HDROP;

typedef struct _DROPFILES {
	DWORD pFiles;                       // offset of file list, i.e. sizeof(DROPFILES)
	                                    // if it immediately follows the struct.
	POINT pt;                           // drop point (client coords).
	BOOL fNC;                           // is it on NonClient area and pt is in screen coords.
	BOOL fWide;                         // WIDE character switch.
} DROPFILES, *LPDROPFILES;

typedef struct DROPFILESW_VLS {        // don't look this up in msdn.
	DROPFILES;
	WCHAR files[?];
} DROPFILESW_VLS;

UINT DragQueryFileW(HDROP hDrop, UINT iFile, LPWSTR lpszFile, UINT cch);
BOOL DragQueryPoint(HDROP hDrop, POINT *lppt);
VOID DragAcceptFiles(HWND hWnd, BOOL fAccept);
VOID DragFinish(HDROP hDrop);
]]

--special constructor for a Lua list of utf-8 (or wcs) filenames.
DROPFILES = function(files)
	local bufsz = 1 --trailing \0
	local t = {}
	for i=1,#files do
		local buf, sz = wcs_sz(files[i])
		bufsz = bufsz + sz + 1 --string + \0
		t[i] = buf
	end
	local df = ffi.new('DROPFILESW_VLS', bufsz)
	df.pFiles = ffi.sizeof'DROPFILES'
	df.fWide = 1
	local offset = 0
	for i=1,#t do
		ffi.copy(df.files + offset, t[i], ffi.sizeof(t[i]))
		offset = offset + ffi.sizeof(t[i]) / 2
	end
	df.files[offset] = 0 --trailing \0
	return df
end

function DragQueryFile(hdrop, ifile, buf, sz) --returns nfiles | buf,nchars
	if not ifile then
		--get number of files
		return checknz(shell32.DragQueryFileW(hdrop, 0xFFFFFFFF, nil, 0))
	end
	if not buf then buf, sz = WCS() end
	return buf, checknz(shell32.DragQueryFileW(hdrop, ifile, buf, sz + 1))
end

--return the list of files that are being dragged or in clipboard.
--custom function, don't look it up in msdn.
function DragQueryFiles(hdrop)
	local buf, sz = WCS()
	local n = DragQueryFile(hdrop)
	local t = {}
	for i=0,n-1 do
		t[#t+1] = mbs(DragQueryFile(hdrop, i, buf, sz))
	end
	return t
end

function DragQueryPoint(hdrop, p)
	p = POINT(p)
	local in_client_area = shell32.DragQueryPoint(hdrop, p) ~= 0
	return p, in_client_area
end

DragAcceptFiles = shell32.DragAcceptFiles
DragFinish = shell32.DragFinish

function WM.WM_DROPFILES(wParam, lParam)
	return ffi.cast('HDROP', wParam)
end

