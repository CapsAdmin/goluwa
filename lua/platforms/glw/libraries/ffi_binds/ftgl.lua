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
		ftgl[name] = lib["ftgl" .. name]
	end 
end  

return ftgl