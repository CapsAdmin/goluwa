local freeimage = {}

local lib = ffi.load("libfreeimage") 

ffi.cdef[[
	typedef struct {} FI_MEMORY;
	typedef struct {} FI_BITMAP;
	typedef struct {} FI_MULTIBITMAP;;
	typedef struct {} FI_TAG;
	 
	__stdcall FI_MEMORY * FreeImage_OpenMemory(const char *data, unsigned int size);
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
	
]]

local FIMD_NODATA = -1 -- no data
local FIMD_COMMENTS = 0 -- comment or keywords
local FIMD_EXIF_MAIN = 1 ---TIFF metadata
local FIMD_EXIF_EXIF = 2 ---specific metadata
local FIMD_EXIF_GPS = 3 -- GPS metadata
local FIMD_EXIF_MAKERNOTE = 4 -- maker note metadata
local FIMD_EXIF_INTEROP = 5 -- interoperability metadata
local FIMD_IPTC = 6 --/NAA metadata
local FIMD_XMP = 7 -- XMP metadata
local FIMD_GEOTIFF = 8 -- metadata
local FIMD_ANIMATION = 9 -- metadata
local FIMD_CUSTOM = 10 -- to attach other metadata types to a dib
local FIMD_EXIF_RAW = 11 -- as a raw buffer
 
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
		lib.FreeImage_GetMetadata(FIMD_ANIMATION, bitmap, "FrameLeft", tag)
		local x = tonumber(ffi.cast("int", lib.FreeImage_GetTagValue(tag[0])))
		
		lib.FreeImage_GetMetadata(FIMD_ANIMATION, bitmap, "FrameTop", tag)
		local y = tonumber(ffi.cast("int", lib.FreeImage_GetTagValue(tag[0])))
		
		lib.FreeImage_GetMetadata(FIMD_ANIMATION, bitmap, "FrameTime", tag)
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

function freeimage.LoadImage(data, flags)
	local buffer = ffi.cast("const unsigned char *const ", data)

	local stream = lib.FreeImage_OpenMemory(buffer, #data)
	local type = lib.FreeImage_GetFileTypeFromMemory(stream, #data)
		
	local temp = lib.FreeImage_LoadFromMemory(type, stream, flags or 0)
	local bitmap = lib.FreeImage_ConvertTo32Bits(temp)
	lib.FreeImage_Unload(temp)
			
	local data = lib.FreeImage_GetBits(bitmap) 
	local width = lib.FreeImage_GetWidth(bitmap)
	local height = lib.FreeImage_GetHeight(bitmap)
		
	ffi.gc(bitmap, lib.FreeImage_Unload)
	
	return width, height, data
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

return freeimage