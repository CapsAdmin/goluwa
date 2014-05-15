return [[
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