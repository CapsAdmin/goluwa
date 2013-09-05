-- http://ftgl.sourceforge.net/docs/html/ftgl-tutorial.html

local header = [[
typedef struct {} FTGLfont;
typedef struct {} FTGLglyph;
typedef struct {} FT_GlyphSlot;
typedef struct {} FT_Encoding;
typedef struct {} FT_Error;
typedef double FTGL_DOUBLE;

FTGLglyph *ftglCreateBitmapGlyph(FT_GlyphSlot glyph);
FTGLfont *ftglCreateBufferFont(const char *file);
FTGLfont *ftglCreateBitmapFont(const char *file);
FTGLfont *ftglCreatePixmapFont(const char *file);
FTGLfont *ftglCreateTextureFont(const char *file);
FTGLfont *ftglCreatePolygonFont(const char *file);
FTGLfont *ftglCreateExtrudeFont(const char *file);
FTGLglyph *ftglCreateOutlineGlyph(FT_GlyphSlot glyph, float outset,int useDisplayList);
FTGLglyph *ftglCreatePolygonGlyph(FT_GlyphSlot glyph, float outset, int useDisplayList);

FTGLglyph *ftglCreateCustomGlyph(
	FTGLglyph *base, 
	void *data,
	void (*renderCallback) (FTGLglyph *, void *, FTGL_DOUBLE, FTGL_DOUBLE,int, FTGL_DOUBLE *, FTGL_DOUBLE *),
	void (*destroyCallback) (FTGLglyph *, void *)
);

FTGLfont *ftglCreateCustomFont(char const *fontFilePath,void *data,FTGLglyph * (*makeglyphCallback) (FT_GlyphSlot, void *));

void ftglDestroyFont(FTGLfont* font);
int ftglAttachFile(FTGLfont* font, const char* path);
int ftglAttachData(FTGLfont* font, const unsigned char * data, size_t size);
int ftglSetFontCharMap(FTGLfont* font, FT_Encoding encoding);
unsigned int ftglGetFontCharMapCount(FTGLfont* font);
FT_Encoding* ftglGetFontCharMapList(FTGLfont* font);
int ftglSetFontFaceSize(FTGLfont* font, unsigned int size,unsigned int res);
unsigned int ftglGetFontFaceSize(FTGLfont* font);
void ftglSetFontDepth(FTGLfont* font, float depth);
void ftglSetFontOutset(FTGLfont* font, float front, float back);
void ftglSetFontDisplayList(FTGLfont* font, int useList);
float ftglGetFontAscender(FTGLfont* font);
float ftglGetFontDescender(FTGLfont* font);
float ftglGetFontLineHeight(FTGLfont* font);
void ftglGetFontBBox(FTGLfont* font, const char *string,int len, float bounds[6]);
float ftglGetFontAdvance(FTGLfont* font, const char *string);
void ftglRenderFont(FTGLfont* font, const char *string, int mode);
FT_Error ftglGetFontError(FTGLfont* font);	
]] 

local errors = {}

errors[0x0000] = {"Ok", "Successful function call. Always 0!"}
errors[0x0001] = {"Invalid_Face_Handle", "An invalid face object handle was passed to an API function."}
errors[0x0002] =  {"Invalid_Instance_Handle", "An invalid instance object handle was passed to an API function."}
errors[0x0003] =  {"Invalid_Glyph_Handle", "An invalid glyph container handle was passed to an API function."}
errors[0x0004] =  {"Invalid_CharMap_Handle", "An invalid charmap handle was passed to an API function."}
errors[0x0005] =  {"Invalid_Result_Address", "An output parameter (a result) was given a NULL address in an API call."}
errors[0x0006] =  {"Invalid_Glyph_Index", "An invalid glyph index was passed to one API function."}
errors[0x0007] =  {"Invalid_Argument", "An invalid argument was passed to one API function. Usually, this means a simple out-of-bounds error."}
errors[0x0008] =  {"Could_Not_Open_File", "The pathname passed doesn't point to an existing or accessible file."}
errors[0x0009] =  {"File_Is_Not_Collection", "Returned by TT_Open_Collection when trying to open a file which isn't a collection."}
errors[0x000A] =  {"Table_Missing", "A mandatory TrueType table is missing from the font file. Denotes a broken font file."}
errors[0x000B] =  {"Invalid_Horiz_Metrics", "The font's HMTX table is broken. Denotes a broken font."}
errors[0x000C] =  {"Invalid_CharMap_Format", "A font's charmap entry has an invalid format.  Some other entries may be valid though."}
errors[0x000D] =  {"Invalid_PPem", "Invalid PPem values specified, i.e. you're accessing a scaled glyph without having called TT_Set_Instance_CharSize() or TT_Set_Instance_PixelSizes()."}
errors[0x0010] =  {"Invalid_File_Format", "The file isn't a TrueType font or collection."}
errors[0x0020] =  {"Invalid_Engine", "An invalid engine handle was passed to one of the API functions."}
errors[0x0021] =  {"Too_Many_Extensions", "The client application is trying to initialize too many extensions.  The default max extensions number is 8."}
errors[0x0022] =  {"Extensions_Unsupported", "This build of the engine doesn't support extensions"}
errors[0x0023] =  {"Invalid_Extension_Id", "This error indicates that the client application is trying to use an extension that has not been initialized yet."}
errors[0x0080] =  {"Max_Profile_Missing", "The max profile table is missing from the font file. => broken font file"}
errors[0x0081] =  {"Header_Table_Missing", "The font header table is missing from the font file. => broken font file"}
errors[0x0082] =  {"Horiz_Header_Missing", "The horizontal header is missing."}
errors[0x0083] =  {"Locations_Missing", "The locations table is missing."}
errors[0x0084] =  {"Name_Table_Missing", "The name table is missing."}
errors[0x0085] =  {"CMap_Table_Missing", "The character encoding tables are missing."}
errors[0x0086] =  {"Hmtx_Table_Missing", "The Hmtx table is missing."}
errors[0x0087] =  {"OS2_Table_Missing", "The OS/2 table is missing."}
errors[0x0088] =  {"Post_Table_Missing", "The PostScript table is missing."}
errors[0x0100] =  {"Out_Of_Memory", "An operation couldn't be performed due to memory exhaustion."}
errors[0x0200] =  {"Invalid_File_Offset", "Trying to seek to an invalid portion of the font file. Denotes a broken file."}
errors[0x0201] =  {"Invalid_File_Read", "Trying to read an invalid portion of the font file.  Denotes a broken file."}
errors[0x0202] =  {"Invalid_Frame_Access", "Trying to frame an invalid portion of the font file. Denotes a broken file."}
errors[0x0300] =  {"Too_Many_Points", "The glyph has too many points to be valid for its font file."}
errors[0x0301] =  {"Too_Many_Contours", "The glyph has too many contours to be valid for its font file."}
errors[0x0302] =  {"Invalid_Composite_Glyph", "A composite glyph's description is broken."}
errors[0x0303] =  {"Too_Many_Ins", "The glyph has too many instructions to be valid for its font file."}
errors[0x0400] =  {"Invalid_Opcode", "Found an invalid opcode in a TrueType byte-code stream."}
errors[0x0401] =  {"Too_Few_Arguments", "An opcode was invoked with too few arguments on the stack."}
errors[0x0402] =  {"Stack_Overflow", "The interpreter's stack has been filled up and operations can't continue."}
errors[0x0403] =  {"Code_Overflow", "The byte-code stream runs out of its valid bounds."}
errors[0x0404] =  {"Bad_Argument", "A function received an invalid argument."}
errors[0x0405] =  {"Divide_By_Zero", "A division by 0 operation was queried by the interpreter program."}
errors[0x0406] =  {"Storage_Overflow", "The program tried to access data outside of its storage area."}
errors[0x0407] =  {"Cvt_Overflow", "The program tried to access data outside of its control value table."}
errors[0x0408] =  {"Invalid_Reference", "The program tried to reference an invalid point, zone or contour."}
errors[0x0409] =  {"Invalid_Distance", "The program tried to use an invalid distance."}
errors[0x040A] =  {"Interpolate_Twilight", "The program tried to interpolate twilight points."}
errors[0x040B] =  {"Debug_Opcode", "The now invalid 'debug' opcode was found in the byte-code stream."}
errors[0x040C] =  {"ENDF_In_Exec_Stream", "A misplaced ENDF was encountered in the byte-code stream."}
errors[0x040D] =  {"Out_Of_CodeRanges", "The program tried to allocate too much code ranges (this is really an engine internal error that should never happen)."}
errors[0x040E] =  {"Nested_DEFS", "Nested function definitions encountered."}
errors[0x040F] =  {"Invalid_CodeRange", "The program tried to access an invalid code range."}
errors[0x0410] =  {"Invalid_Displacement", "The program tried to use an invalid displacement."}
errors[0x0411] =  {"Execution_Too_Long", "In order to get rid of \"poison\" fonts, the interpreter produces this error when more than a million opcodes have been interpreted in a single glyph program.  This detects infinite loops softly."}
errors[0x0500] =  {"Nested_Frame_Access","internal failure"}
errors[0x0501] =  {"Invalid_Cache_List","internal failure"}
errors[0x0502] =  {"Could_Not_Find_Context","internal failure"}
errors[0x0503] =  {"Unlisted_Object","internal failure"}
errors[0x0600] =  {"Raster_Pool_Overflow", "Render pool overflow. This should never happen in this release."}
errors[0x0601] =  {"Raster_Negative_Height", "A negative height was produced."}
errors[0x0602] =  {"Raster_Invalid_Value", "The outline data wasn't set properly. Check that: points >= endContours[contours]"}
errors[0x0603] =  {"Raster_Not_Initialized", "You did not call TT_Init_FreeType()!"}
errors[0x0A00] =  {"Invalid_Kerning_Table_Format", "A kerning subtable format was found invalid in this font."}
errors[0x0A01] =  {"Invalid_Kerning_Table", "A kerning table contains illegal glyph indices."}
errors[0x0B00] =  {"Invalid_Post_Table_Format", "The post table format specified in the font is invalid."}
errors[0x0B01] =  {"Invalid_Post_Table", "The post table contains illegal entries."}

e.FTGL_RENDER_FRONT = 0x0001
e.FTGL_RENDER_BACK = 0x0002
e.FTGL_RENDER_SIDE = 0x0004
e.FTGL_RENDER_ALL = 0xffff

e.FTGL_ALIGN_LEFT = 0
e.FTGL_ALIGN_CENTER = 1
e.FTGL_ALIGN_RIGHT = 2
e.FTGL_ALIGN_JUSTIFY = 3

ffi.cdef(header)  

local lib = ffi.load("ftgl") 

local ftgl = {}

ftgl.header = header
ftgl.lib = lib

for line in header:gmatch("(.-)\n") do
	local name = line:match("ftgl(.-)%(")
	
	if name then
		local func = lib["ftgl" .. name]
		ftgl[name] = function(...)
			local val = func(...)
				
			if name ~= "GetFontError" and ftgl.debug then
				local err = errors[ftgl.GetFontError()]
				if err[1] ~= "Ok" then
					local info = debug.getinfo(2)					
					logf("[opengl] %q in function %s at %s:%i", err[2], info.name, info.short_src, info.currentline)			
				end
			end
				
			return val
		end
	end 
end  

return ftgl