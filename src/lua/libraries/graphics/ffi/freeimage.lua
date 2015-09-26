local header = [[
	typedef struct {} FI_MEMORY;
	typedef struct {} FI_BITMAP;
	typedef struct {} FI_MULTIBITMAP;;
	typedef struct {} FI_TAG;

	__stdcall FI_MEMORY * FreeImage_OpenMemory(const char *data, unsigned int size);
	__stdcall void FreeImage_CloseMemory(FI_MEMORY *stream);
	__stdcall unsigned int FreeImage_GetFileTypeFromMemory(FI_MEMORY *stream, unsigned int size);
	__stdcall FI_BITMAP *FreeImage_LoadFromMemory(unsigned int format, FI_MEMORY *stream, int flags);
	__stdcall FI_BITMAP *FreeImage_ConvertTo32Bits(FI_BITMAP *bitmap);
	__stdcall int FreeImage_FlipVertical(FI_BITMAP *bitmap);
	__stdcall int FreeImage_Invert(FI_BITMAP *bitmap);
	__stdcall unsigned int FreeImage_GetWidth(FI_BITMAP *bitmap);
	__stdcall unsigned int FreeImage_GetHeight(FI_BITMAP *bitmap);
	__stdcall const char *FreeImage_GetBits(FI_BITMAP *bitmap);
	__stdcall void FreeImage_Unload(FI_BITMAP *bitmap);
	__stdcall FI_MULTIBITMAP *FreeImage_LoadMultiBitmapFromMemory(unsigned int format, FI_MEMORY *stream, int flags);
	__stdcall int FreeImage_GetPageCount(FI_MULTIBITMAP *multi_bitmap);
	__stdcall FI_BITMAP *FreeImage_LockPage(FI_MULTIBITMAP *multi_bitmap, int page);
	__stdcall int FreeImage_CloseMultiBitmap(FI_MULTIBITMAP *multi_bitmap, int flags);

	__stdcall const char *FreeImage_GetTagValue(FI_TAG *);
	__stdcall int FreeImage_GetMetadata(int model, FI_BITMAP *dib, const char *key, FI_TAG **tag);
	__stdcall const char *FreeImage_TagToString(int model, FI_TAG *tag, char *Make);

	__stdcall FI_TAG *FreeImage_CreateTag();
	__stdcall void FreeImage_DeleteTag(FI_TAG *tag);


	typedef struct
	{
		uint8_t r;
		uint8_t g;
		uint8_t b;
		uint8_t a;
	} FI_RGB;

	__stdcall FI_BITMAP * FreeImage_Allocate(int w, int h, int bpp, unsigned,unsigned,unsigned);
	__stdcall int FreeImage_SetPixelColor(FI_BITMAP *, unsigned x, unsigned y, FI_RGB * color);
	__stdcall int FreeImage_Save(int type, FI_BITMAP *, const char *file_name, int flags);

]]
local enums = {
	FIF_UNKNOWN = -1,
	FIF_BMP = 0,
	FIF_ICO = 1,
	FIF_JPEG = 2,
	FIF_JNG = 3,
	FIF_KOALA = 4,
	FIF_LBM = 5,
	FIF_IFF = FIF_LBM,
	FIF_MNG = 6,
	FIF_PBM = 7,
	FIF_PBMRAW = 8,
	FIF_PCD = 9,
	FIF_PCX = 10,
	FIF_PGM = 11,
	FIF_PGMRAW = 12,
	FIF_PNG = 13,
	FIF_PPM = 14,
	FIF_PPMRAW = 15,
	FIF_RAS = 16,
	FIF_TARGA = 17,
	FIF_TIFF = 18,
	FIF_WBMP = 19,
	FIF_PSD = 20,
	FIF_CUT = 21,
	FIF_XBM = 22,
	FIF_XPM = 23,
	FIF_DDS = 24,
	FIF_GIF = 25,
	FIF_HDR = 26,
	FIF_FAXG3 = 27,
	FIF_SGI = 28,
	FIF_EXR = 29,
	FIF_J2K = 30,
	FIF_JP2 = 31,
	FIF_PFM = 32,
	FIF_PICT = 33,
	FIF_RAW = 34,

	FIMD_NODATA = -1, -- no data
	FIMD_COMMENTS = 0, -- comment or keywords
	FIMD_EXIF_MAIN = 1, ---TIFF metadata
	FIMD_EXIF_EXIF = 2, ---specific metadata
	FIMD_EXIF_GPS = 3, -- GPS metadata
	FIMD_EXIF_MAKERNOTE = 4, -- maker note metadata
	FIMD_EXIF_INTEROP = 5, -- interoperability metadata
	FIMD_IPTC = 6, --/NAA metadata
	FIMD_XMP = 7, -- XMP metadata
	FIMD_GEOTIFF = 8, -- metadata
	FIMD_ANIMATION = 9, -- metadata
	FIMD_CUSTOM = 10, -- to attach other metadata types to a dib
	FIMD_EXIF_RAW = 11, -- as a raw buffer
}

ffi.cdef(header)

local lib = assert(ffi.load("freeimage"))

local freeimage = {
	lib = lib,
	e = enums,
}

function freeimage.LoadMultiPageImage(data, flags)
	local buffer = ffi.cast("const unsigned char *const ", data)

	local stream = lib.FreeImage_OpenMemory(buffer, #data)
	local type = lib.FreeImage_GetFileTypeFromMemory(stream, #data)

	local temp = lib.FreeImage_LoadMultiBitmapFromMemory(type, stream, flags or 0)
	local count = lib.FreeImage_GetPageCount(temp)

	local out = {}

	for page = 0, count - 1 do
		local temp = lib.FreeImage_LockPage(temp, page)
		local bitmap = lib.FreeImage_ConvertTo32Bits(temp)

		local tag = ffi.new("FI_TAG *[1]")
		lib.FreeImage_GetMetadata(enums.FIMD_ANIMATION, bitmap, "FrameLeft", tag)
		local x = tonumber(ffi.cast("int", lib.FreeImage_GetTagValue(tag[0])))

		lib.FreeImage_GetMetadata(enums.FIMD_ANIMATION, bitmap, "FrameTop", tag)
		local y = tonumber(ffi.cast("int", lib.FreeImage_GetTagValue(tag[0])))

		lib.FreeImage_GetMetadata(enums.FIMD_ANIMATION, bitmap, "FrameTime", tag)
		local ms = tonumber(ffi.cast("int", lib.FreeImage_GetTagValue(tag[0]))) / 1000

		lib.FreeImage_DeleteTag(tag[0])

		local data = lib.FreeImage_GetBits(bitmap)
		local width = lib.FreeImage_GetWidth(bitmap)
		local height = lib.FreeImage_GetHeight(bitmap)

		ffi.gc(bitmap, lib.FreeImage_Unload)

		table.insert(out, {w = width, h = height, x = x, y = y, ms = ms, data = data})
	end

	lib.FreeImage_CloseMultiBitmap(temp, 0)

	return out
end

function freeimage.LoadImage(data, flags, format)
	local buffer = ffi.cast("const unsigned char *const ", data)

	local stream = lib.FreeImage_OpenMemory(buffer, #data)
	local type = format or lib.FreeImage_GetFileTypeFromMemory(stream, #data)

	if type == enums.FIF_UNKNOWN or type > enums.FIF_RAW then -- huh...
		lib.FreeImage_CloseMemory(stream)
		return nil, "unknown format"
	end

	local temp = lib.FreeImage_LoadFromMemory(type, stream, flags or 0)
	local bitmap = lib.FreeImage_ConvertTo32Bits(temp)
	lib.FreeImage_Unload(temp)

	local data = lib.FreeImage_GetBits(bitmap)
	local width = lib.FreeImage_GetWidth(bitmap)
	local height = lib.FreeImage_GetHeight(bitmap)

	ffi.gc(bitmap, lib.FreeImage_Unload)

	lib.FreeImage_CloseMemory(stream)

	return data, width, height
end

function freeimage.GetColorFromBuffer(buffer, x, y, w, h)
	if x < 1 and y < 1 then
		x = x * w
		y = y * h
	end

	local offset = math.floor((y * w + x) * 4)

	local b = buffer[offset + 0]%256
	local g = buffer[offset + 1]%256
	local r = buffer[offset + 2]%256
	local a = buffer[offset + 3]%256

	return r / 255, g / 255, b / 255, a / 255
end

function freeimage.Save(path, buffer, length, w, h, bpp)
	local bitmap = lib.FreeImage_Allocate(w, h, bpp, 0,0,0)

	local color = ffi.new("FI_RGB")

	for x = 0, w-1 do
	for y = 0, h-1 do
		local i = (y * w + x)
		color = buffer[i]

		if i < length then
			lib.FreeImage_SetPixelColor(bitmap, x, y, color)
		else
			break
		end
	end
	end

	lib.FreeImage_Save(enums.FIF_PNG, bitmap, path, 0)
	lib.FreeImage_Unload(bitmap)
end

--[[
local buffer = ffi.new("FI_RGB[?]", 512*512)

for i = 0, 512*512 do
	local color = buffer[i]
	color.r = math.random(255)
	color.g = math.random(255)
	color.b = math.random(255)
	color.a = 255
end

freeimage.Save("test.png", buffer, 512*512, 512, 512, 24)]]

return freeimage