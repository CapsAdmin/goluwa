-- header stolen from https://code.google.com/p/lua-files!!

local header = [[
typedef enum {
        FT_FACE_FLAG_SCALABLE           = ( 1 <<  0 ),
        FT_FACE_FLAG_FIXED_SIZES        = ( 1 <<  1 ),
        FT_FACE_FLAG_FIXED_WIDTH        = ( 1 <<  2 ),
        FT_FACE_FLAG_SFNT               = ( 1 <<  3 ),
        FT_FACE_FLAG_HORIZONTAL         = ( 1 <<  4 ),
        FT_FACE_FLAG_VERTICAL           = ( 1 <<  5 ),
        FT_FACE_FLAG_KERNING            = ( 1 <<  6 ),
        FT_FACE_FLAG_FAST_GLYPHS        = ( 1 <<  7 ),
        FT_FACE_FLAG_MULTIPLE_MASTERS   = ( 1 <<  8 ),
        FT_FACE_FLAG_GLYPH_NAMES        = ( 1 <<  9 ),
        FT_FACE_FLAG_EXTERNAL_STREAM    = ( 1 << 10 ),
        FT_FACE_FLAG_HINTER             = ( 1 << 11 ),
        FT_FACE_FLAG_CID_KEYED          = ( 1 << 12 ),
        FT_FACE_FLAG_TRICKY             = ( 1 << 13 ),

        FT_STYLE_FLAG_ITALIC  = ( 1 << 0 ),
        FT_STYLE_FLAG_BOLD    = ( 1 << 1 ),

        FT_LOAD_DEFAULT                       = 0x0,
        FT_LOAD_NO_SCALE                      = 0x1,
        FT_LOAD_NO_HINTING                    = 0x2,
        FT_LOAD_RENDER                        = 0x4,
        FT_LOAD_NO_BITMAP                     = 0x8,
        FT_LOAD_VERTICAL_LAYOUT               = 0x10,
        FT_LOAD_FORCE_AUTOHINT                = 0x20,
        FT_LOAD_CROP_BITMAP                   = 0x40,
        FT_LOAD_PEDANTIC                      = 0x80,
        FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH   = 0x200,
        FT_LOAD_NO_RECURSE                    = 0x400,
        FT_LOAD_IGNORE_TRANSFORM              = 0x800,
        FT_LOAD_MONOCHROME                    = 0x1000,
        FT_LOAD_LINEAR_DESIGN                 = 0x2000,
        FT_LOAD_NO_AUTOHINT                   = 0x8000U,

        FT_RASTER_FLAG_DEFAULT  = 0x0,
        FT_RASTER_FLAG_AA       = 0x1,
        FT_RASTER_FLAG_DIRECT   = 0x2,
        FT_RASTER_FLAG_CLIP     = 0x4,
};

typedef signed short FT_Int16;
typedef unsigned short FT_UInt16;
typedef signed int FT_Int32;
typedef unsigned int FT_UInt32;
typedef int FT_Fast;
typedef unsigned int FT_UFast;
typedef struct FT_MemoryRec_* FT_Memory;
typedef void*
(*FT_Alloc_Func)( FT_Memory memory,
                                          long size );
typedef void
(*FT_Free_Func)( FT_Memory memory,
                                         void* block );
typedef void*
(*FT_Realloc_Func)( FT_Memory memory,
                                                 long cur_size,
                                                 long new_size,
                                                 void* block );
struct FT_MemoryRec_
{
 void* user;
 FT_Alloc_Func alloc;
 FT_Free_Func free;
 FT_Realloc_Func realloc;
};
typedef struct FT_StreamRec_* FT_Stream;
typedef union FT_StreamDesc_
{
 long value;
 void* pointer;
} FT_StreamDesc;
typedef unsigned long
(*FT_Stream_IoFunc)( FT_Stream stream,
                                                  unsigned long offset,
                                                  unsigned char* buffer,
                                                  unsigned long count );
typedef void
(*FT_Stream_CloseFunc)( FT_Stream stream );
typedef struct FT_StreamRec_
{
 unsigned char* base;
 unsigned long size;
 unsigned long pos;
 FT_StreamDesc descriptor;
 FT_StreamDesc pathname;
 FT_Stream_IoFunc read;
 FT_Stream_CloseFunc close;
 FT_Memory memory;
 unsigned char* cursor;
 unsigned char* limit;
} FT_StreamRec;
typedef signed long FT_Pos;
typedef struct FT_Vector_
{
 FT_Pos x;
 FT_Pos y;
} FT_Vector;
typedef struct FT_BBox_
{
 FT_Pos xMin, yMin;
 FT_Pos xMax, yMax;
} FT_BBox;
typedef enum FT_Pixel_Mode_
{
 FT_PIXEL_MODE_NONE = 0,
 FT_PIXEL_MODE_MONO,
 FT_PIXEL_MODE_GRAY,
 FT_PIXEL_MODE_GRAY2,
 FT_PIXEL_MODE_GRAY4,
 FT_PIXEL_MODE_LCD,
 FT_PIXEL_MODE_LCD_V,
 FT_PIXEL_MODE_MAX
} FT_Pixel_Mode;
typedef struct FT_Bitmap_
{
 int rows;
 int width;
 int pitch;
 unsigned char* buffer;
 short num_grays;
 char pixel_mode;
 char palette_mode;
 void* palette;
} FT_Bitmap;
typedef struct FT_Outline_
{
 short n_contours;
 short n_points;
 FT_Vector* points;
 char* tags;
 short* contours;
 int flags;
} FT_Outline;
typedef int
(*FT_Outline_MoveToFunc)( const FT_Vector* to,
                                                                 void* user );
typedef int
(*FT_Outline_LineToFunc)( const FT_Vector* to,
                                                                 void* user );
typedef int
(*FT_Outline_ConicToFunc)( const FT_Vector* control,
                                                                  const FT_Vector* to,
                                                                  void* user );
typedef int
(*FT_Outline_CubicToFunc)( const FT_Vector* control1,
                                                                  const FT_Vector* control2,
                                                                  const FT_Vector* to,
                                                                  void* user );
typedef struct FT_Outline_Funcs_
{
 FT_Outline_MoveToFunc move_to;
 FT_Outline_LineToFunc line_to;
 FT_Outline_ConicToFunc conic_to;
 FT_Outline_CubicToFunc cubic_to;
 int shift;
 FT_Pos delta;
} FT_Outline_Funcs;
typedef enum FT_Glyph_Format_
{
 FT_GLYPH_FORMAT_NONE = ( ( (unsigned long)0 << 24 ) | ( (unsigned long)0 << 16 ) | ( (unsigned long)0 << 8 ) | (unsigned long)0 ),
 FT_GLYPH_FORMAT_COMPOSITE = ( ( (unsigned long)"c" << 24 ) | ( (unsigned long)"o" << 16 ) | ( (unsigned long)"m" << 8 ) | (unsigned long)"p" ),
 FT_GLYPH_FORMAT_BITMAP = ( ( (unsigned long)"b" << 24 ) | ( (unsigned long)"i" << 16 ) | ( (unsigned long)"t" << 8 ) | (unsigned long)"s" ),
 FT_GLYPH_FORMAT_OUTLINE = ( ( (unsigned long)"o" << 24 ) | ( (unsigned long)"u" << 16 ) | ( (unsigned long)"t" << 8 ) | (unsigned long)"l" ),
 FT_GLYPH_FORMAT_PLOTTER = ( ( (unsigned long)"p" << 24 ) | ( (unsigned long)"l" << 16 ) | ( (unsigned long)"o" << 8 ) | (unsigned long)"t" )
} FT_Glyph_Format;
typedef struct FT_RasterRec_* FT_Raster;
typedef struct FT_Span_
{
 short x;
 unsigned short len;
 unsigned char coverage;
} FT_Span;
typedef void
(*FT_SpanFunc)( int y,
                                        int count,
                                        const FT_Span* spans,
                                        void* user );
typedef int
(*FT_Raster_BitTest_Func)( int y,
                                                                  int x,
                                                                  void* user );
typedef void
(*FT_Raster_BitSet_Func)( int y,
                                                                 int x,
                                                                 void* user );
typedef struct FT_Raster_Params_
{
 const FT_Bitmap* target;
 const void* source;
 int flags;
 FT_SpanFunc gray_spans;
 FT_SpanFunc black_spans;
 FT_Raster_BitTest_Func bit_test;
 FT_Raster_BitSet_Func bit_set;
 void* user;
 FT_BBox clip_box;
} FT_Raster_Params;
typedef int
(*FT_Raster_NewFunc)( void* memory,
                                                        FT_Raster* raster );
typedef void
(*FT_Raster_DoneFunc)( FT_Raster raster );
typedef void
(*FT_Raster_ResetFunc)( FT_Raster raster,
                                                          unsigned char* pool_base,
                                                          unsigned long pool_size );
typedef int
(*FT_Raster_SetModeFunc)( FT_Raster raster,
                                                                 unsigned long mode,
                                                                 void* args );
typedef int
(*FT_Raster_RenderFunc)( FT_Raster raster,
                                                                const FT_Raster_Params* params );
typedef struct FT_Raster_Funcs_
{
 FT_Glyph_Format glyph_format;
 FT_Raster_NewFunc raster_new;
 FT_Raster_ResetFunc raster_reset;
 FT_Raster_SetModeFunc raster_set_mode;
 FT_Raster_RenderFunc raster_render;
 FT_Raster_DoneFunc raster_done;
} FT_Raster_Funcs;
typedef unsigned char FT_Bool;
typedef signed short FT_FWord;
typedef unsigned short FT_UFWord;
typedef signed char FT_Char;
typedef unsigned char FT_Byte;
typedef const FT_Byte* FT_Bytes;
typedef FT_UInt32 FT_Tag;
typedef char FT_String;
typedef signed short FT_Short;
typedef unsigned short FT_UShort;
typedef signed int FT_Int;
typedef unsigned int FT_UInt;
typedef signed long FT_Long;
typedef unsigned long FT_ULong;
typedef signed short FT_F2Dot14;
typedef signed long FT_F26Dot6;
typedef signed long FT_Fixed;
typedef int FT_Error;
typedef void* FT_Pointer;
typedef size_t FT_Offset;
typedef ptrdiff_t FT_PtrDist;
typedef struct FT_UnitVector_
{
 FT_F2Dot14 x;
 FT_F2Dot14 y;
} FT_UnitVector;
typedef struct FT_Matrix_
{
 FT_Fixed xx, xy;
 FT_Fixed yx, yy;
} FT_Matrix;
typedef struct FT_Data_
{
 const FT_Byte* pointer;
 FT_Int length;
} FT_Data;
typedef void (*FT_Generic_Finalizer)(void* object);
typedef struct FT_Generic_
{
 void* data;
 FT_Generic_Finalizer finalizer;
} FT_Generic;
typedef struct FT_ListNodeRec_* FT_ListNode;
typedef struct FT_ListRec_* FT_List;
typedef struct FT_ListNodeRec_
{
 FT_ListNode prev;
 FT_ListNode next;
 void* data;
} FT_ListNodeRec;
typedef struct FT_ListRec_
{
 FT_ListNode head;
 FT_ListNode tail;
} FT_ListRec;
typedef struct FT_Glyph_Metrics_
{
 FT_Pos width;
 FT_Pos height;
 FT_Pos horiBearingX;
 FT_Pos horiBearingY;
 FT_Pos horiAdvance;
 FT_Pos vertBearingX;
 FT_Pos vertBearingY;
 FT_Pos vertAdvance;
} FT_Glyph_Metrics;
typedef struct FT_Bitmap_Size_
{
 FT_Short height;
 FT_Short width;
 FT_Pos size;
 FT_Pos x_ppem;
 FT_Pos y_ppem;
} FT_Bitmap_Size;
typedef struct FT_LibraryRec_ FT_LibraryRec, *FT_Library;
typedef struct FT_ModuleRec_* FT_Module;
typedef struct FT_DriverRec_* FT_Driver;
typedef struct FT_RendererRec_* FT_Renderer;
typedef struct FT_FaceRec_* FT_Face;
typedef struct FT_SizeRec_* FT_Size;
typedef struct FT_GlyphSlotRec_* FT_GlyphSlot;
typedef struct FT_CharMapRec_* FT_CharMap;
typedef enum FT_Encoding_
{
 FT_ENCODING_NONE = ( ( (FT_UInt32)(0) << 24 ) | ( (FT_UInt32)(0) << 16 ) | ( (FT_UInt32)(0) << 8 ) | (FT_UInt32)(0) ),
 FT_ENCODING_MS_SYMBOL = ( ( (FT_UInt32)("s") << 24 ) | ( (FT_UInt32)("y") << 16 ) | ( (FT_UInt32)("m") << 8 ) | (FT_UInt32)("b") ),
 FT_ENCODING_UNICODE = ( ( (FT_UInt32)("u") << 24 ) | ( (FT_UInt32)("n") << 16 ) | ( (FT_UInt32)("i") << 8 ) | (FT_UInt32)("c") ),
 FT_ENCODING_SJIS = ( ( (FT_UInt32)("s") << 24 ) | ( (FT_UInt32)("j") << 16 ) | ( (FT_UInt32)("i") << 8 ) | (FT_UInt32)("s") ),
 FT_ENCODING_GB2312 = ( ( (FT_UInt32)("g") << 24 ) | ( (FT_UInt32)("b") << 16 ) | ( (FT_UInt32)(" ") << 8 ) | (FT_UInt32)(" ") ),
 FT_ENCODING_BIG5 = ( ( (FT_UInt32)("b") << 24 ) | ( (FT_UInt32)("i") << 16 ) | ( (FT_UInt32)("g") << 8 ) | (FT_UInt32)("5") ),
 FT_ENCODING_WANSUNG = ( ( (FT_UInt32)("w") << 24 ) | ( (FT_UInt32)("a") << 16 ) | ( (FT_UInt32)("n") << 8 ) | (FT_UInt32)("s") ),
 FT_ENCODING_JOHAB = ( ( (FT_UInt32)("j") << 24 ) | ( (FT_UInt32)("o") << 16 ) | ( (FT_UInt32)("h") << 8 ) | (FT_UInt32)("a") ),
 FT_ENCODING_MS_SJIS = FT_ENCODING_SJIS,
 FT_ENCODING_MS_GB2312 = FT_ENCODING_GB2312,
 FT_ENCODING_MS_BIG5 = FT_ENCODING_BIG5,
 FT_ENCODING_MS_WANSUNG = FT_ENCODING_WANSUNG,
 FT_ENCODING_MS_JOHAB = FT_ENCODING_JOHAB,
 FT_ENCODING_ADOBE_STANDARD = ( ( (FT_UInt32)("A") << 24 ) | ( (FT_UInt32)("D") << 16 ) | ( (FT_UInt32)("O") << 8 ) | (FT_UInt32)("B") ),
 FT_ENCODING_ADOBE_EXPERT = ( ( (FT_UInt32)("A") << 24 ) | ( (FT_UInt32)("D") << 16 ) | ( (FT_UInt32)("B") << 8 ) | (FT_UInt32)("E") ),
 FT_ENCODING_ADOBE_CUSTOM = ( ( (FT_UInt32)("A") << 24 ) | ( (FT_UInt32)("D") << 16 ) | ( (FT_UInt32)("B") << 8 ) | (FT_UInt32)("C") ),
 FT_ENCODING_ADOBE_LATIN_1 = ( ( (FT_UInt32)("l") << 24 ) | ( (FT_UInt32)("a") << 16 ) | ( (FT_UInt32)("t") << 8 ) | (FT_UInt32)("1") ),
 FT_ENCODING_OLD_LATIN_2 = ( ( (FT_UInt32)("l") << 24 ) | ( (FT_UInt32)("a") << 16 ) | ( (FT_UInt32)("t") << 8 ) | (FT_UInt32)("2") ),
 FT_ENCODING_APPLE_ROMAN = ( ( (FT_UInt32)("a") << 24 ) | ( (FT_UInt32)("r") << 16 ) | ( (FT_UInt32)("m") << 8 ) | (FT_UInt32)("n") )
} FT_Encoding;
typedef struct FT_CharMapRec_
{
 FT_Face face;
 FT_Encoding encoding;
 FT_UShort platform_id;
 FT_UShort encoding_id;
} FT_CharMapRec;
typedef struct FT_Face_InternalRec_* FT_Face_Internal;
typedef struct FT_FaceRec_
{
 FT_Long num_faces;
 FT_Long face_index;
 FT_Long face_flags;    // FT_FACE_FLAG_*
 FT_Long style_flags;
 FT_Long num_glyphs;
 FT_String* family_name;
 FT_String* style_name;
 FT_Int num_fixed_sizes;
 FT_Bitmap_Size* available_sizes;
 FT_Int num_charmaps;
 FT_CharMap* charmaps;
 FT_Generic generic;
 FT_BBox bbox;
 FT_UShort units_per_EM;
 FT_Short ascender;
 FT_Short descender;
 FT_Short height;
 FT_Short max_advance_width;
 FT_Short max_advance_height;
 FT_Short underline_position;
 FT_Short underline_thickness;
 FT_GlyphSlot glyph;
 FT_Size size;
 FT_CharMap charmap;
 FT_Driver driver;
 FT_Memory memory;
 FT_Stream stream;
 FT_ListRec sizes_list;
 FT_Generic autohint;
 void* extensions;
 FT_Face_Internal internal;
} FT_FaceRec;
typedef struct FT_Size_InternalRec_* FT_Size_Internal;
typedef struct FT_Size_Metrics_
{
 FT_UShort x_ppem;
 FT_UShort y_ppem;
 FT_Fixed x_scale;
 FT_Fixed y_scale;
 FT_Pos ascender;
 FT_Pos descender;
 FT_Pos height;
 FT_Pos max_advance;
} FT_Size_Metrics;
typedef struct FT_SizeRec_
{
 FT_Face face;
 FT_Generic generic;
 FT_Size_Metrics metrics;
 FT_Size_Internal internal;
} FT_SizeRec;
typedef struct FT_SubGlyphRec_* FT_SubGlyph;
typedef struct FT_Slot_InternalRec_* FT_Slot_Internal;
typedef struct FT_GlyphSlotRec_
{
 FT_Library library;
 FT_Face face;
 FT_GlyphSlot next;
 FT_UInt reserved;
 FT_Generic generic;
 FT_Glyph_Metrics metrics;
 FT_Fixed linearHoriAdvance;
 FT_Fixed linearVertAdvance;
 FT_Vector advance;
 FT_Glyph_Format format;
 FT_Bitmap bitmap;
 FT_Int bitmap_left;
 FT_Int bitmap_top;
 FT_Outline outline;
 FT_UInt num_subglyphs;
 FT_SubGlyph subglyphs;
 void* control_data;
 long control_len;
 FT_Pos lsb_delta;
 FT_Pos rsb_delta;
 void* other;
 FT_Slot_Internal internal;
} FT_GlyphSlotRec;

FT_Error FT_Init_FreeType(FT_Library *alibrary );
FT_Error FT_Done_FreeType(FT_Library library );

typedef struct FT_Parameter_
{
 FT_ULong tag;
 FT_Pointer data;
} FT_Parameter;
typedef struct FT_Open_Args_
{
 FT_UInt flags;
 const FT_Byte* memory_base;
 FT_Long memory_size;
 FT_String* pathname;
 FT_Stream stream;
 FT_Module driver;
 FT_Int num_params;
 FT_Parameter* params;
} FT_Open_Args;
FT_Error FT_New_Face( FT_Library library,const char* filepathname,FT_Long face_index,FT_Face *aface );
FT_Error FT_New_Memory_Face( FT_Library library,const FT_Byte* file_base,FT_Long file_size,FT_Long face_index,FT_Face *aface );
FT_Error FT_Open_Face( FT_Library library,const FT_Open_Args* args, FT_Long face_index,FT_Face *aface );
FT_Error FT_Attach_File( FT_Face face, const char* filepathname );
FT_Error FT_Attach_Stream( FT_Face face, FT_Open_Args* parameters );
FT_Error FT_Reference_Face( FT_Face face );
FT_Error FT_Done_Face( FT_Face face );
FT_Error FT_Select_Size( FT_Face face, FT_Int strike_index );
typedef enum FT_Size_Request_Type_
{
 FT_SIZE_REQUEST_TYPE_NOMINAL,
 FT_SIZE_REQUEST_TYPE_REAL_DIM,
 FT_SIZE_REQUEST_TYPE_BBOX,
 FT_SIZE_REQUEST_TYPE_CELL,
 FT_SIZE_REQUEST_TYPE_SCALES,
 FT_SIZE_REQUEST_TYPE_MAX
} FT_Size_Request_Type;
typedef struct FT_Size_RequestRec_
{
 FT_Size_Request_Type type;
 FT_Long width;
 FT_Long height;
 FT_UInt horiResolution;
 FT_UInt vertResolution;
} FT_Size_RequestRec;
typedef struct FT_Size_RequestRec_ *FT_Size_Request;

FT_Error FT_Request_Size( FT_Face face, FT_Size_Request req );
FT_Error FT_Set_Char_Size( FT_Face face, FT_F26Dot6 char_width, FT_F26Dot6 char_height, FT_UInt horz_resolution, FT_UInt vert_resolution );
FT_Error FT_Set_Pixel_Sizes( FT_Face face, FT_UInt pixel_width, FT_UInt pixel_height );
FT_Error FT_Load_Glyph( FT_Face face, FT_UInt glyph_index, FT_Int32 load_flags );
FT_Error FT_Load_Char( FT_Face face, FT_ULong char_code,FT_Int32 load_flags );
void FT_Set_Transform( FT_Face face, FT_Matrix* matrix, FT_Vector* delta );
typedef enum FT_Render_Mode_
{
 FT_RENDER_MODE_NORMAL = 0,
 FT_RENDER_MODE_LIGHT,
 FT_RENDER_MODE_MONO,
 FT_RENDER_MODE_LCD,
 FT_RENDER_MODE_LCD_V,
 FT_RENDER_MODE_MAX
} FT_Render_Mode;

typedef enum {
	FT_LOAD_TARGET_NORMAL = (FT_RENDER_MODE_NORMAL & 15) << 16,
	FT_LOAD_TARGET_LIGHT  = (FT_RENDER_MODE_LIGHT & 15) << 16,
	FT_LOAD_TARGET_MONO   = (FT_RENDER_MODE_MONO & 15) << 16,
	FT_LOAD_TARGET_LCD    = (FT_RENDER_MODE_LCD & 15) << 16,
	FT_LOAD_TARGET_LCD_V  = (FT_RENDER_MODE_LCD_V & 15) << 16
};

FT_Error FT_Render_Glyph( FT_GlyphSlot slot, FT_Render_Mode render_mode );
typedef enum FT_Kerning_Mode_
{
 FT_KERNING_DEFAULT = 0,
 FT_KERNING_UNFITTED,
 FT_KERNING_UNSCALED
} FT_Kerning_Mode;

FT_Error FT_Get_Kerning( FT_Face face, FT_UInt left_glyph, FT_UInt right_glyph, FT_UInt kern_mode, FT_Vector *akerning );
FT_Error FT_Get_Track_Kerning( FT_Face face, FT_Fixed point_size, FT_Int degree, FT_Fixed* akerning );
FT_Error FT_Get_Glyph_Name( FT_Face face, FT_UInt glyph_index, FT_Pointer buffer, FT_UInt buffer_max );
const char* FT_Get_Postscript_Name( FT_Face face );
FT_Error FT_Select_Charmap( FT_Face face, FT_Encoding encoding );
FT_Error FT_Set_Charmap( FT_Face face, FT_CharMap charmap );
FT_Int FT_Get_Charmap_Index( FT_CharMap charmap );
FT_UInt FT_Get_Char_Index( FT_Face face, FT_ULong charcode );
FT_ULong FT_Get_First_Char( FT_Face face, FT_UInt *agindex );
FT_ULong FT_Get_Next_Char( FT_Face face, FT_ULong char_code, FT_UInt *agindex );
FT_UInt FT_Get_Name_Index( FT_Face face, FT_String* glyph_name );
FT_Error FT_Get_SubGlyph_Info( FT_GlyphSlot glyph, FT_UInt sub_index, FT_Int *p_index, FT_UInt *p_flags, FT_Int *p_arg1, FT_Int *p_arg2, FT_Matrix *p_transform );
FT_UInt FT_Face_GetCharVariantIndex( FT_Face face, FT_ULong charcode, FT_ULong variantSelector );
FT_Int FT_Face_GetCharVariantIsDefault( FT_Face face, FT_ULong charcode, FT_ULong variantSelector );
FT_UInt32* FT_Face_GetVariantSelectors( FT_Face face );
FT_UInt32* FT_Face_GetVariantsOfChar( FT_Face face, FT_ULong charcode );
FT_UInt32* FT_Face_GetCharsOfVariant( FT_Face face, FT_ULong variantSelector );
FT_Long FT_MulDiv( FT_Long a, FT_Long b, FT_Long c );
FT_Long FT_DivFix( FT_Long a, FT_Long b );
FT_Fixed FT_RoundFix( FT_Fixed a );
FT_Fixed FT_CeilFix( FT_Fixed a );
FT_Fixed FT_FloorFix( FT_Fixed a );
void FT_Vector_Transform( FT_Vector* vec,const FT_Matrix* matrix );
void FT_Library_Version( FT_Library library,FT_Int *amajor,FT_Int *aminor,FT_Int *apatch );

// ftbitmap.h

void FT_Bitmap_New (FT_Bitmap *abitmap);
FT_Error FT_Bitmap_Copy (FT_Library library, const FT_Bitmap *source, FT_Bitmap *target);
FT_Error FT_Bitmap_Embolden (FT_Library library, FT_Bitmap* bitmap, FT_Pos xStrength, FT_Pos yStrength);
FT_Error FT_Bitmap_Convert (FT_Library library, const FT_Bitmap *source, FT_Bitmap *target, FT_Int alignment);
FT_Error FT_GlyphSlot_Own_Bitmap (FT_GlyphSlot slot);
FT_Error FT_Bitmap_Done (FT_Library library, FT_Bitmap *bitmap);

// ftglyph.h

typedef struct FT_Glyph_Class_ FT_Glyph_Class;
typedef struct FT_GlyphRec_* FT_Glyph;
typedef struct FT_GlyphRec_
{
 FT_Library library;
 const FT_Glyph_Class* clazz;
 FT_Glyph_Format format;
 FT_Vector advance;
} FT_GlyphRec;
typedef struct FT_BitmapGlyphRec_* FT_BitmapGlyph;
typedef struct FT_BitmapGlyphRec_
{
 FT_GlyphRec root;
 FT_Int left;
 FT_Int top;
 FT_Bitmap bitmap;
} FT_BitmapGlyphRec;
typedef struct FT_OutlineGlyphRec_* FT_OutlineGlyph;
typedef struct FT_OutlineGlyphRec_
{
 FT_GlyphRec root;
 FT_Outline outline;
} FT_OutlineGlyphRec;

FT_Error FT_Get_Glyph( FT_GlyphSlot slot, FT_Glyph *aglyph );
FT_Error FT_Glyph_Copy( FT_Glyph source, FT_Glyph *target );
FT_Error FT_Glyph_Transform( FT_Glyph glyph, FT_Matrix* matrix, FT_Vector* delta );
typedef enum FT_Glyph_BBox_Mode_
{
 FT_GLYPH_BBOX_UNSCALED = 0,
 FT_GLYPH_BBOX_SUBPIXELS = 0,
 FT_GLYPH_BBOX_GRIDFIT = 1,
 FT_GLYPH_BBOX_TRUNCATE = 2,
 FT_GLYPH_BBOX_PIXELS = 3
} FT_Glyph_BBox_Mode;

void FT_Glyph_Get_CBox( FT_Glyph glyph, FT_UInt bbox_mode, FT_BBox *acbox );
FT_Error FT_Glyph_To_Bitmap( FT_Glyph* the_glyph, FT_Render_Mode render_mode, FT_Vector* origin, FT_Bool destroy );
void FT_Done_Glyph( FT_Glyph glyph );
void FT_Matrix_Multiply( const FT_Matrix* a, FT_Matrix* b );
FT_Error FT_Matrix_Invert( FT_Matrix* matrix );

//ftoutln.h

FT_Error FT_Outline_Decompose( FT_Outline* outline, const FT_Outline_Funcs* func_interface, void* user );
FT_Error FT_Outline_New( FT_Library library, FT_UInt numPoints, FT_Int numContours, FT_Outline *anoutline );


FT_Error FT_Outline_New_Internal( FT_Memory memory, FT_UInt numPoints, FT_Int numContours, FT_Outline *anoutline );
FT_Error FT_Outline_Done( FT_Library library, FT_Outline* outline );

FT_Error FT_Outline_Done_Internal( FT_Memory memory, FT_Outline* outline );
FT_Error FT_Outline_Check( FT_Outline* outline );
void FT_Outline_Get_CBox( const FT_Outline* outline, FT_BBox *acbox );
void FT_Outline_Translate( const FT_Outline* outline, FT_Pos xOffset, FT_Pos yOffset );
FT_Error FT_Outline_Copy( const FT_Outline* source, FT_Outline *target );
void FT_Outline_Transform( const FT_Outline* outline, const FT_Matrix* matrix );
FT_Error FT_Outline_Embolden( FT_Outline* outline,FT_Pos strength );
FT_Error FT_Outline_EmboldenXY( FT_Outline* outline, FT_Pos xstrength, FT_Pos ystrength );
void FT_Outline_Reverse( FT_Outline* outline );
FT_Error FT_Outline_Get_Bitmap( FT_Library library,FT_Outline* outline,const FT_Bitmap *abitmap );
FT_Error FT_Outline_Render( FT_Library library, FT_Outline* outline, FT_Raster_Params* params );

typedef enum FT_Orientation_
{
 FT_ORIENTATION_TRUETYPE = 0,
 FT_ORIENTATION_POSTSCRIPT = 1,
 FT_ORIENTATION_FILL_RIGHT = FT_ORIENTATION_TRUETYPE,
 FT_ORIENTATION_FILL_LEFT = FT_ORIENTATION_POSTSCRIPT,
 FT_ORIENTATION_NONE

} FT_Orientation;
FT_Orientation
FT_Outline_Get_Orientation( FT_Outline* outline );

typedef enum  FT_LcdFilter_
{
FT_LCD_FILTER_NONE    = 0,
FT_LCD_FILTER_DEFAULT = 1,
FT_LCD_FILTER_LIGHT   = 2,
FT_LCD_FILTER_LEGACY  = 16,

FT_LCD_FILTER_MAX   /* do not remove */

} FT_LcdFilter;

FT_Error FT_Library_SetLcdFilter(FT_Library library, FT_LcdFilter  filter);
FT_Error FT_Library_SetLcdFilterWeights(FT_Library library, unsigned char* weights);

]]
local errors = {
	[0x01] = "Cannot Open Resource",
	[0x02] = "Unknown File Format",
	[0x03] = "Invalid File Format",
	[0x04] = "Invalid Version",
	[0x05] = "Lower Module Version",
	[0x06] = "Invalid Argument",
	[0x07] = "Unimplemented Feature",
	[0x08] = "Invalid Table",
	[0x09] = "Invalid Offset",
	[0x0A] = "Array Too Large",
	[0x10] = "Invalid Glyph Index",
	[0x11] = "Invalid Character Code",
	[0x12] = "Invalid Glyph Format",
	[0x13] = "Cannot Render Glyph",
	[0x14] = "Invalid Outline",
	[0x15] = "Invalid Composite",
	[0x16] = "Too Many Hints",
	[0x17] = "Invalid Pixel Size",
	[0x20] = "Invalid Handle",
	[0x21] = "Invalid Library Handle",
	[0x22] = "Invalid Driver Handle",
	[0x23] = "Invalid Face Handle",
	[0x24] = "Invalid Size Handle",
	[0x25] = "Invalid Slot Handle",
	[0x26] = "Invalid CharMap Handle",
	[0x27] = "Invalid Cache Handle",
	[0x28] = "Invalid Stream Handle",
	[0x30] = "Too Many Drivers",
	[0x31] = "Too Many Extensions",
	[0x40] = "Out Of Memory",
	[0x41] = "Unlisted Object",
	[0x51] = "Cannot Open Stream",
	[0x52] = "Invalid Stream Seek",
	[0x53] = "Invalid Stream Skip",
	[0x54] = "Invalid Stream Read",
	[0x55] = "Invalid Stream Operation",
	[0x56] = "Invalid Frame Operation",
	[0x57] = "Nested Frame Access",
	[0x58] = "Invalid Frame Read",
	[0x60] = "Raster Uninitialized",
	[0x61] = "Raster Corrupted",
	[0x62] = "Raster Overflow",
	[0x63] = "Raster Negative Height",
	[0x70] = "Too Many Caches",
	[0x80] = "Invalid Opcode",
	[0x81] = "Too Few Arguments",
	[0x82] = "Stack Overflow",
	[0x83] = "Code Overflow",
	[0x84] = "Bad Argument",
	[0x85] = "Divide By Zero",
	[0x86] = "Invalid Reference",
	[0x87] = "Debug OpCode",
	[0x88] = "ENDF In Exec Stream",
	[0x89] = "Nested DEFS",
	[0x8A] = "Invalid CodeRange",
	[0x8B] = "Execution Too Long",
	[0x8C] = "Too Many Function Defs",
	[0x8D] = "Too Many Instruction Defs",
	[0x8E] = "Table Missing",
	[0x8F] = "Horiz Header Missing",
	[0x90] = "Locations Missing",
	[0x91] = "Name Table Missing",
	[0x92] = "CMap Table Missing",
	[0x93] = "Hmtx Table Missing",
	[0x94] = "Post Table Missing",
	[0x95] = "Invalid Horiz Metrics",
	[0x96] = "Invalid CharMap Format",
	[0x97] = "Invalid PPem",
	[0x98] = "Invalid Vert Metrics",
	[0x99] = "Could Not Find Context",
	[0x9A] = "Invalid Post Table Format",
	[0x9B] = "Invalid Post Table",
	[0xA0] = "Syntax Error",
	[0xA1] = "Stack Underflow",
	[0xA2] = "Ignore",
	[0xA3] = "No Unicode Glyph Name",
	[0xB0] = "Missing Startfont Field",
	[0xB1] = "Missing Font Field",
	[0xB2] = "Missing Size Field",
	[0xB3] = "Missing Fontboundingbox Field",
	[0xB4] = "Missing Chars Field",
	[0xB5] = "Missing Startchar Field",
	[0xB6] = "Missing Encoding Field",
	[0xB7] = "Missing Bbx Field",
	[0xB8] = "Bbx Too Big",
	[0xB9] = "Corrupted Font Header",
	[0xBA] = "Corrupted Font Glyphs",
}

ffi.cdef(header)

local lib = assert(ffi.load("freetype"))

local freetype = {
	lib = lib,
}

for line in header:gmatch("(.-)\n") do
	if not line:find("typedef") and not line:find("=")  then
		local name = line:match(" FT_(.-)%(")


		if name then
			name = name:trim()
			local return_type = line:match("^(.-)%sFT_")
			local friendly_name = name:gsub("_", "")
			local ok, func = pcall(function() return lib["FT_" .. name] end)

			if ok then
				freetype[friendly_name] = function(...)
					local val = func(...)

					if return_type == "FT_Error" and val ~= 0 then
						local info = debug.getinfo(2)

						llog("%q in function %s at %s:%i\n", errors[val] or ("unknonw error " .. val), info.name, info.source, info.currentline)
					end


					if freetype.logcalls then
						setlogfile("freetype_calls")
							logf("%s = FT_%s(%s)\n", serializer.GetLibrary("luadata").ToString(val), name, table.concat(tostring_args(...), ",\t"))
						setlogfile()
					end

					return val
				end
			else
				print(func)
			end
		end
	end
end

freetype.lib = lib

return freetype
