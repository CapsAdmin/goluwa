
--proc/controls/filedialogs: standard open and save dialogs
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.comdlg'

OFN_READONLY                 = 0x00000001
OFN_OVERWRITEPROMPT          = 0x00000002
OFN_HIDEREADONLY             = 0x00000004
OFN_NOCHANGEDIR              = 0x00000008
OFN_SHOWHELP                 = 0x00000010
OFN_ENABLEHOOK               = 0x00000020
OFN_ENABLETEMPLATE           = 0x00000040
OFN_ENABLETEMPLATEHANDLE     = 0x00000080
OFN_NOVALIDATE               = 0x00000100
OFN_ALLOWMULTISELECT         = 0x00000200
OFN_EXTENSIONDIFFERENT       = 0x00000400
OFN_PATHMUSTEXIST            = 0x00000800
OFN_FILEMUSTEXIST            = 0x00001000
OFN_CREATEPROMPT             = 0x00002000
OFN_SHAREAWARE               = 0x00004000
OFN_NOREADONLYRETURN         = 0x00008000
OFN_NOTESTFILECREATE         = 0x00010000
OFN_NONETWORKBUTTON          = 0x00020000
OFN_NOLONGNAMES              = 0x00040000     -- force no long names for 4.x modules
OFN_EXPLORER                 = 0x00080000     -- new look commdlg
OFN_NODEREFERENCELINKS       = 0x00100000
OFN_LONGNAMES                = 0x00200000     -- force long names for 3.x modules
-- OFN_ENABLEINCLUDENOTIFY and OFN_ENABLESIZING require
-- Windows 2000 or higher to have any effect.
OFN_ENABLEINCLUDENOTIFY      = 0x00400000     -- send include message to callback
OFN_ENABLESIZING             = 0x00800000
OFN_DONTADDTORECENT          = 0x02000000
OFN_FORCESHOWHIDDEN          = 0x10000000    -- Show All files including System and hidden files

--FlagsEx Values
OFN_EX_NOPLACESBAR = 0x00000001

-- Return values for the registered message sent to the hook function
-- when a sharing violation occurs.  OFN_SHAREFALLTHROUGH allows the
-- filename to be accepted, OFN_SHARENOWARN rejects the name but puts
-- up no warning (returned when the app has already put up a warning
-- message), and OFN_SHAREWARN puts up the default warning message
-- for sharing violations.
--
-- Note:  Undefined return values map to OFN_SHAREWARN, but are
--        reserved for future use.
OFN_SHAREFALLTHROUGH     = 2
OFN_SHARENOWARN          = 1
OFN_SHAREWARN            = 0

ffi.cdef[[
typedef UINT_PTR (*LPOFNHOOKPROC) (HWND, UINT, WPARAM, LPARAM);

typedef struct tagOFNW {
   DWORD        lStructSize;
   HWND         hwndOwner;
   HINSTANCE    hInstance;
   LPCWSTR      lpstrFilter;
   LPWSTR       lpstrCustomFilter;
   DWORD        nMaxCustFilter;
   DWORD        nFilterIndex;
   LPWSTR       lpstrFile;
   DWORD        nMaxFile;
   LPWSTR       lpstrFileTitle;
   DWORD        nMaxFileTitle;
   LPCWSTR      lpstrInitialDir;
   LPCWSTR      lpstrTitle;
   DWORD        Flags;
   WORD         nFileOffset;
   WORD         nFileExtension;
   LPCWSTR      lpstrDefExt;
   LPARAM       lCustData;
   LPOFNHOOKPROC lpfnHook;
   LPCWSTR      lpTemplateName;
   void*        pvReserved;
   DWORD        dwReserved;
   DWORD        FlagsEx;
} OPENFILENAMEW, *LPOPENFILENAMEW;

BOOL GetSaveFileNameW(LPOPENFILENAMEW);
BOOL GetOpenFileNameW(LPOPENFILENAMEW);
]]

local function set_filter(s)
	if type(s) == 'table' then s = table.concat(s,'\0') end
	if type(s) == 'string' then s = s..'\0' end
	return wcs(s)
end

local function set_filepath(s, info)
	local pwcs, sz = wcs_sz(s)
	info.lpstrFile = pwcs
	info.nMaxFile = sz
end

local function get_filepath(info)
	return mbs(info.lpstrFile)
end

OPENFILENAME = struct{
	ctype = 'OPENFILENAMEW', size = 'lStructSize',
	fields = sfields{
		'filepath', '', set_filepath, get_filepath, --in/out
		'filename', 'lpstrFileTitle', pass, mbs, --out
		'filter', 'lpstrFilter', set_filter, mbs,
		'custom_filter', 'lpstrCustomFilter', pass, mbs, --out
		'filter_index', 'nFilterIndex', pass, pass,
		'initial_dir', 'lpstrInitialDir', wcs, mbs,
		'title', 'lpstrTitle', wcs, mbs,
		'flags', 'Flags', flags, pass, --OFN_*
		'default_ext', 'lpstrDefExt', wcs, mbs,
		'flags_ex', 'FlagsEx', flags, pass, --OFN_EX_*
	},
	init = function(info)
		--TODO: make out and in/out buffer allocations declarative.
		local p, psz = info.lpstrFile, info.nMaxFile
		local wcs, sz = WCS(65536); pin(wcs, info); info.lpstrFile, info.nMaxFile = wcs, sz
		if p ~= nil then ffi.copy(wcs, p, psz * 2) end
		local wcs, sz = WCS(); pin(wcs, info);	info.lpstrFileTitle, info.nMaxFileTitle = wcs, sz
		local wcs, sz = WCS(); pin(wcs, info);	info.lpstrCustomFilter, info.nMaxCustFilter = wcs, sz
	end,
}

function GetSaveFileName(info)
	info = OPENFILENAME(info)
	return checkcomdlg(comdlg.GetSaveFileNameW(info)), info
end

--custom function, don't look for it in msdn!
--for multiselect, info.lpstrFile contains dir \0 filename1 \0 ... \0\0,
--except if a single file is selected, in which case it's just path \0\0.
--this function extracts and rejoins the dir and filenames to a list of paths.
function GetOpenFileNamePaths(info)

	--split at \0 to a list of offset1, size1, ...
	local t, i0 = {}, 0
	for i = 0, info.nMaxFile - 1 do
		if info.lpstrFile[i] == 0 then
			local sz = i - i0 - 1
			if sz < 0 then break end
			t[#t+1] = i0
			t[#t+1] = sz
			i0 = i + 1
		end
	end

	--convert to utf8
	local dt = {}
	for i=1,#t,2 do
		local offset, size = t[i], t[i+1]
		dt[#dt+1] = mbs(info.lpstrFile + offset, size)
	end

	--if a single file selected, that is the full path
	if #dt == 1 then return dt end

	--remove dir from the list and prepend it to each filename
	local dir = table.remove(dt, 1)
	for i=1,#dt do
		dt[i] = dir .. '\\' .. dt[i]
	end

	return dt
end

function GetOpenFileName(info)
	info = OPENFILENAME(info)
	return checkcomdlg(comdlg.GetOpenFileNameW(info)), info
end


--showcase
if not ... then
	local ok, info = GetSaveFileName{
		title = 'Save this thing',
		filter = {'All Files','*.*','Text Files','*.txt'},
		filter_index = 1,
		flags = 'OFN_SHOWHELP',
	}
	print(ok, info.filepath, info.filename, info.filter_index, info.custom_filter)

	local ok, info = GetOpenFileName{
		title = 'Open\'em up!',
		filter = {'All Files','*.*','Text Files','*.txt'},
		filter_index = 1,
		flags = 'OFN_ALLOWMULTISELECT|OFN_EXPLORER',
	}

	print(ok, info.filepath, info.filename, info.filter_index, info.custom_filter)
	require'pp'(GetOpenFileNamePaths(info))
end

