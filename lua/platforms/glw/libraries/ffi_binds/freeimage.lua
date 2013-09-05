local freeimage = {}

local lib = ffi.load("freeimage") 

ffi.cdef[[
	typedef struct {} FI_MEMORY;
	typedef struct {} FI_BITMAP;
	 
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
	
]]

function freeimage.LoadImage(data, flags)
	local buffer = ffi.cast("const unsigned char *const ", data)

	local stream = lib.FreeImage_OpenMemory(buffer, #data)
	local type = lib.FreeImage_GetFileTypeFromMemory(stream, #data)
		
	local temp = lib.FreeImage_LoadFromMemory(type, stream, flags or 0)
	local bitmap = lib.FreeImage_ConvertTo32Bits(temp)
	lib.FreeImage_Unload(temp)
	
	lib.FreeImage_FlipVertical(bitmap)
		
	local data = lib.FreeImage_GetBits(bitmap) 
	local width = lib.FreeImage_GetWidth(bitmap)
	local height = lib.FreeImage_GetHeight(bitmap)
		
	--lib.FreeImage_Unload(bitmap)
	
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