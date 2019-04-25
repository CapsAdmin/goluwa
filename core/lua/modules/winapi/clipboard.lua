
--proc/system/clipboard: clipboard API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.memory'

-- Predefined Clipboard Formats
CF_NAMES = constants{
	CF_TEXT              = 1,
	CF_BITMAP            = 2, --only for DDBs, doesn't work with DIBs!
	CF_METAFILEPICT      = 3,
	CF_SYLK              = 4,
	CF_DIF               = 5,
	CF_TIFF              = 6,
	CF_OEMTEXT           = 7,
	CF_DIB               = 8, --DIB without alpha
	CF_PALETTE           = 9,
	CF_PENDATA           = 10,
	CF_RIFF              = 11,
	CF_WAVE              = 12,
	CF_UNICODETEXT       = 13,
	CF_ENHMETAFILE       = 14,
	CF_HDROP             = 15,
	CF_LOCALE            = 16,
	CF_DIBV5             = 17, --DIB with alpha
	CF_OWNERDISPLAY      = 0x0080,
	CF_DSPTEXT           = 0x0081,
	CF_DSPBITMAP         = 0x0082,
	CF_DSPMETAFILEPICT   = 0x0083,
	CF_DSPENHMETAFILE    = 0x008E,
}

-- "Private" formats don't get GlobalFree()'d
CF_PRIVATEFIRST      = 0x0200
CF_PRIVATELAST       = 0x02FF
-- "GDIOBJ" formats do get DeleteObject()'d
CF_GDIOBJFIRST       = 0x0300
CF_GDIOBJLAST        = 0x03FF

ffi.cdef[[
BOOL   OpenClipboard(HWND hWndNewOwner);
BOOL   CloseClipboard(void);
BOOL   IsClipboardFormatAvailable(UINT format);
int    CountClipboardFormats(void);
HANDLE GetClipboardData(UINT uFormat);
BOOL   EmptyClipboard(void);
HANDLE SetClipboardData(UINT uFormat, HANDLE hMem);
UINT   EnumClipboardFormats(UINT format);
int    GetClipboardFormatNameW(UINT format, LPWSTR lpszFormatName, int cchMaxCount);
UINT   RegisterClipboardFormatW(LPWSTR lpszFormat);
]]

function OpenClipboard(hwnd)
	return C.OpenClipboard(hwnd) ~= 0
end

function CloseClipboard(hwnd)
	return checknz(C.CloseClipboard())
end

function IsClipboardFormatAvailable(format)
	return C.IsClipboardFormatAvailable(flags(format)) ~= 0
end

function CountClipboardFormats()
	return callnz2(C.CountClipboardFormats)
end

function GetClipboardData(uFormat)
	return checkh(C.GetClipboardData(flags(uFormat)))
end

function EmptyClipboard()
	checknz(C.EmptyClipboard())
end

function SetClipboardData(format, hmem)
	return checkh(C.SetClipboardData(flags(format), hmem))
end

function EnumClipboardFormats(last_format)
	local ret = callnz2(C.EnumClipboardFormats, last_format or 0)
	return ret ~= 0 and ret or nil
end

function GetClipboardFormatName(format, buf, sz)
	if not buf then buf, sz = WCS(sz) end
	sz = checknz(C.GetClipboardFormatNameW(format, buf, sz))
	return buf, sz
end

function RegisterClipboardFormat(name)
	return checknz(C.RegisterClipboardFormatW(wcs(name)))
end

--hi-level API: get/set data from/to clipboard.
--custom functions, don't look them up in msdn.

--return a list of available clipboard formats, in original order.
function GetClipboardFormats()
	local format
	local t = {}
	repeat
		format = EnumClipboardFormats(format)
		t[#t+1] = format
	until not format
	return t
end

--return a list of available clipboard format names, in original order.
--for built-in formats, the format number is returned instead.
function GetClipboardFormatNames()
	local t = GetClipboardFormats()
	local buf, sz
	for i=1,#t do
		local format = t[i]
		local name
		if CF_NAMES[format] then
			name = format
		else
			if not buf then buf, sz = WCS() end
			name = mbs(GetClipboardFormatName(format, buf, sz))
		end
		t[i] = name
	end
	return t
end

--get the data buffer of a specific format, pass it to a function,
--and return the result of that function.
function GetClipboardDataBuffer(format, copy)
	if not IsClipboardFormatAvailable(format) then
		return
	end
	return glue.fcall(function(finally)
		local h = GetClipboardData(format)
		local buf = GlobalLock(h)
		if not buf then return end
		finally(function() GlobalUnlock(h) end)
		local sz = GlobalSize(h)
		return copy(buf, sz)
	end)
end

--set the clipboard data for a specific format from a buffer or string.
--you can pass a buffer and a size, or just the size and a copy function.
function SetClipboardDataBuffer(format, srcbuf, sz, copy)
	--windows will own this memory, no need to free it.
	glue.fcall(function(finally, onerror)
		sz = sz or #buf
		local h = GlobalAlloc(bit.bor(GMEM_MOVEABLE, GMEM_ZEROINIT, GMEM_SHARE), sz)
		onerror(function() GlobalFree(h) end)
		local buf = GlobalLock(h)
		finally(function() GlobalUnlock(h) end)
		if copy then
			copy(buf, sz)
		else
			ffi.copy(buf, srcbuf, sz)
		end
		SetClipboardData(format, h)
	end)
end

--get utf8 text out of the clipboard.
function GetClipboardText()
	return GetClipboardDataBuffer(CF_UNICODETEXT, function(buf)
		return mbs(ffi.cast('WCHAR*', buf))
	end)
end

--set utf8 text into the clipboard.
function SetClipboardText(s)
	local buf = wcs(s)
	SetClipboardDataBuffer(CF_UNICODETEXT, buf, ffi.sizeof(buf))
end

--get a list of files from clipboard.
function GetClipboardFiles()
	require'winapi.shellapi'
	return GetClipboardDataBuffer(CF_HDROP, function(buf)
		local hdrop = ffi.cast('HDROP', buf)
		return DragQueryFiles(hdrop)
	end)
end

--put a list of files in clipboard.
function SetClipboardFiles(files)
	require'winapi.shellapi'
	local df = DROPFILES(files)
	return SetClipboardDataBuffer(CF_HDROP, df, ffi.sizeof(df))
end

--test/demo

if not ... then
	if not OpenClipboard() then
		error'OpenClipboard() failed'
	end

	print''
	print'clipboard as found:'
	print''
	for i,format in ipairs(GetClipboardFormats()) do
		local name
		if CF_NAMES[format] then
			name = CF_NAMES[format]
		else
			name = mbs(GetClipboardFormatName(format))
		end
		print('>' .. name)
		if format == CF_UNICODETEXT then
			print(GetClipboardText())
		elseif format == CF_HDROP then
			require'pp'(GetClipboardFiles())
		else
			GetClipboardDataBuffer(format, function(buf, sz)
				print(buf, sz, name)
			end)
		end
	end

	print''
	print'utf8 text:'
	print''
	local s = 'hello from the clipboard!'
	EmptyClipboard()
	SetClipboardText(s)

	assert(#GetClipboardFormatNames() == 1)
	assert(GetClipboardFormatNames()[1] == CF_UNICODETEXT)
	assert(GetClipboardText() == s)
	print(GetClipboardText())

	print''
	print'list of files:'
	print''
	EmptyClipboard()
	SetClipboardFiles{'file1', 'file2', 'file3'}
	assert(#GetClipboardFiles() == 3)
	assert(GetClipboardFiles()[3] == 'file3')
	require'pp'(GetClipboardFiles())

	CloseClipboard()
end
