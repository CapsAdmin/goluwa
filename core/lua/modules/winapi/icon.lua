
--proc/resources/icon: icon resources
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winuser'

ffi.cdef[[
HICON LoadIconW(
	  HINSTANCE hInstance,
	  LPCWSTR lpIconName);

BOOL DestroyIcon(HICON hIcon);

typedef struct _ICONINFO {
    BOOL    fIcon;
    DWORD   xHotspot;
    DWORD   yHotspot;
    HBITMAP hbmMask;
    HBITMAP hbmColor;
} ICONINFO;
typedef ICONINFO *PICONINFO;

HICON CreateIconIndirect(PICONINFO piconinfo);
]]

IDI_APPLICATION   = 32512
IDI_INFORMATION   = 32516
IDI_QUESTION      = 32514
IDI_WARNING       = 32515
IDI_ERROR         = 32513
IDI_WINLOGO       = 32517 --same as IDI_APPLICATION in XP
IDI_SHIELD        = 32518 --not found in XP

function LoadIconFromInstance(hInstance, name)
	if not name then hInstance, name = nil, hInstance end --hInstance is optional
	return own(checkh(C.LoadIconW(hInstance,
		ffi.cast('LPCWSTR', wcs(MAKEINTRESOURCE(flags(name)))))), DestroyIcon)
end

function DestroyIcon(hicon)
	checknz(C.DestroyIcon(hicon))
end

ICONINFO = types.ICONINFO

function CreateIconIndirect(info)
	info = ICONINFO(info)
	return checkh(C.CreateIconIndirect(info))
end

--WM_SETICON flags
ICON_BIG = 1
ICON_SMALL = 0

if not ... then
print(LoadIconFromInstance(IDI_APPLICATION))
print(LoadIconFromInstance(IDI_INFORMATION))
end

