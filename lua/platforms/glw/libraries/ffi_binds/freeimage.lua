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


freeimage.LoadImage = function(str, texture_flags, channel_flags, prev_tex_id)
	local buffer = ffi.cast("const unsigned char *const ", str)

	local stream= lib.FreeImage_OpenMemory(buffer, #str)
	local type = lib.FreeImage_GetFileTypeFromMemory(stream, #str)
	local bitmap_ = lib.FreeImage_LoadFromMemory(type, stream, texture_flags or 0)
	
	bitmap = lib.FreeImage_ConvertTo32Bits(bitmap_)
	lib.FreeImage_Unload(bitmap_)
	
	lib.FreeImage_FlipVertical(bitmap)
	
	local id = ffi.new("GLuint[1]") gl.GenTextures(1, id) id = id[0]
	gl.BindTexture(e.GL_TEXTURE_2D, id)
	gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_MIN_FILTER, e.GL_LINEAR)
	gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_MAG_FILTER, e.GL_LINEAR)
	
	gl.TexImage2D(
		e.GL_TEXTURE_2D, 
		0, 
		e.GL_RGBA, 
		lib.FreeImage_GetWidth(bitmap), 
		lib.FreeImage_GetHeight(bitmap), 
		0, 
		e.GL_BGRA, 
		e.GL_UNSIGNED_BYTE, 
		lib.FreeImage_GetBits(bitmap) 
	)
	
	lib.FreeImage_Unload(bitmap)
	
	return id
end

return freeimage