local ffi = require("ffi")
ffi.cdef([[enum{FT_Mod_Err_Base=0,FT_Mod_Err_Autofit=0,FT_Mod_Err_BDF=0,FT_Mod_Err_Bzip2=0,FT_Mod_Err_Cache=0,FT_Mod_Err_CFF=0,FT_Mod_Err_CID=0,FT_Mod_Err_Gzip=0,FT_Mod_Err_LZW=0,FT_Mod_Err_OTvalid=0,FT_Mod_Err_PCF=0,FT_Mod_Err_PFR=0,FT_Mod_Err_PSaux=0,FT_Mod_Err_PShinter=0,FT_Mod_Err_PSnames=0,FT_Mod_Err_Raster=0,FT_Mod_Err_SFNT=0,FT_Mod_Err_Smooth=0,FT_Mod_Err_TrueType=0,FT_Mod_Err_Type1=0,FT_Mod_Err_Type42=0,FT_Mod_Err_Winfonts=0,FT_Mod_Err_GXvalid=0,FT_Mod_Err_Max=1,
FT_Err_Ok=0,FT_Err_Cannot_Open_Resource=1,FT_Err_Unknown_File_Format=2,FT_Err_Invalid_File_Format=3,FT_Err_Invalid_Version=4,FT_Err_Lower_Module_Version=5,FT_Err_Invalid_Argument=6,FT_Err_Unimplemented_Feature=7,FT_Err_Invalid_Table=8,FT_Err_Invalid_Offset=9,FT_Err_Array_Too_Large=10,FT_Err_Missing_Module=11,FT_Err_Missing_Property=12,FT_Err_Invalid_Glyph_Index=16,FT_Err_Invalid_Character_Code=17,FT_Err_Invalid_Glyph_Format=18,FT_Err_Cannot_Render_Glyph=19,FT_Err_Invalid_Outline=20,FT_Err_Invalid_Composite=21,FT_Err_Too_Many_Hints=22,FT_Err_Invalid_Pixel_Size=23,FT_Err_Invalid_Handle=32,FT_Err_Invalid_Library_Handle=33,FT_Err_Invalid_Driver_Handle=34,FT_Err_Invalid_Face_Handle=35,FT_Err_Invalid_Size_Handle=36,FT_Err_Invalid_Slot_Handle=37,FT_Err_Invalid_CharMap_Handle=38,FT_Err_Invalid_Cache_Handle=39,FT_Err_Invalid_Stream_Handle=40,FT_Err_Too_Many_Drivers=48,FT_Err_Too_Many_Extensions=49,FT_Err_Out_Of_Memory=64,FT_Err_Unlisted_Object=65,FT_Err_Cannot_Open_Stream=81,FT_Err_Invalid_Stream_Seek=82,FT_Err_Invalid_Stream_Skip=83,FT_Err_Invalid_Stream_Read=84,FT_Err_Invalid_Stream_Operation=85,FT_Err_Invalid_Frame_Operation=86,FT_Err_Nested_Frame_Access=87,FT_Err_Invalid_Frame_Read=88,FT_Err_Raster_Uninitialized=96,FT_Err_Raster_Corrupted=97,FT_Err_Raster_Overflow=98,FT_Err_Raster_Negative_Height=99,FT_Err_Too_Many_Caches=112,FT_Err_Invalid_Opcode=128,FT_Err_Too_Few_Arguments=129,FT_Err_Stack_Overflow=130,FT_Err_Code_Overflow=131,FT_Err_Bad_Argument=132,FT_Err_Divide_By_Zero=133,FT_Err_Invalid_Reference=134,FT_Err_Debug_OpCode=135,FT_Err_ENDF_In_Exec_Stream=136,FT_Err_Nested_DEFS=137,FT_Err_Invalid_CodeRange=138,FT_Err_Execution_Too_Long=139,FT_Err_Too_Many_Function_Defs=140,FT_Err_Too_Many_Instruction_Defs=141,FT_Err_Table_Missing=142,FT_Err_Horiz_Header_Missing=143,FT_Err_Locations_Missing=144,FT_Err_Name_Table_Missing=145,FT_Err_CMap_Table_Missing=146,FT_Err_Hmtx_Table_Missing=147,FT_Err_Post_Table_Missing=148,FT_Err_Invalid_Horiz_Metrics=149,FT_Err_Invalid_CharMap_Format=150,FT_Err_Invalid_PPem=151,FT_Err_Invalid_Vert_Metrics=152,FT_Err_Could_Not_Find_Context=153,FT_Err_Invalid_Post_Table_Format=154,FT_Err_Invalid_Post_Table=155,FT_Err_Syntax_Error=160,FT_Err_Stack_Underflow=161,FT_Err_Ignore=162,FT_Err_No_Unicode_Glyph_Name=163,FT_Err_Glyph_Too_Big=164,FT_Err_Missing_Startfont_Field=176,FT_Err_Missing_Font_Field=177,FT_Err_Missing_Size_Field=178,FT_Err_Missing_Fontboundingbox_Field=179,FT_Err_Missing_Chars_Field=180,FT_Err_Missing_Startchar_Field=181,FT_Err_Missing_Encoding_Field=182,FT_Err_Missing_Bbx_Field=183,FT_Err_Bbx_Too_Big=184,FT_Err_Corrupted_Font_Header=185,FT_Err_Corrupted_Font_Glyphs=186,FT_Err_Max=187,};typedef enum FT_LcdFilter_{FT_LCD_FILTER_NONE=0,FT_LCD_FILTER_DEFAULT=1,FT_LCD_FILTER_LIGHT=2,FT_LCD_FILTER_LEGACY1=3,FT_LCD_FILTER_LEGACY=16,FT_LCD_FILTER_MAX=17};
typedef enum FT_Glyph_Format_{FT_GLYPH_FORMAT_NONE=0,FT_GLYPH_FORMAT_COMPOSITE=1668246896,FT_GLYPH_FORMAT_BITMAP=1651078259,FT_GLYPH_FORMAT_OUTLINE=1869968492,FT_GLYPH_FORMAT_PLOTTER=1886154612};
typedef enum FT_TrueTypeEngineType_{FT_TRUETYPE_ENGINE_TYPE_NONE=0,FT_TRUETYPE_ENGINE_TYPE_UNPATENTED=1,FT_TRUETYPE_ENGINE_TYPE_PATENTED=2};
typedef enum FT_Stroker_LineJoin_{FT_STROKER_LINEJOIN_ROUND=0,FT_STROKER_LINEJOIN_BEVEL=1,FT_STROKER_LINEJOIN_MITER_VARIABLE=2,FT_STROKER_LINEJOIN_MITER=2,FT_STROKER_LINEJOIN_MITER_FIXED=3};
typedef enum FT_Sfnt_Tag_{FT_SFNT_HEAD=0,FT_SFNT_MAXP=1,FT_SFNT_OS2=2,FT_SFNT_HHEA=3,FT_SFNT_VHEA=4,FT_SFNT_POST=5,FT_SFNT_PCLT=6,FT_SFNT_MAX=7};
typedef enum FT_Glyph_BBox_Mode_{FT_GLYPH_BBOX_UNSCALED=0,FT_GLYPH_BBOX_SUBPIXELS=0,FT_GLYPH_BBOX_GRIDFIT=1,FT_GLYPH_BBOX_TRUNCATE=2,FT_GLYPH_BBOX_PIXELS=3};
typedef enum FT_Size_Request_Type_{FT_SIZE_REQUEST_TYPE_NOMINAL=0,FT_SIZE_REQUEST_TYPE_REAL_DIM=1,FT_SIZE_REQUEST_TYPE_BBOX=2,FT_SIZE_REQUEST_TYPE_CELL=3,FT_SIZE_REQUEST_TYPE_SCALES=4,FT_SIZE_REQUEST_TYPE_MAX=5};
typedef enum FT_Encoding_{FT_ENCODING_NONE=0,FT_ENCODING_MS_SYMBOL=1937337698,FT_ENCODING_UNICODE=1970170211,FT_ENCODING_SJIS=1936353651,FT_ENCODING_GB2312=1734484000,FT_ENCODING_BIG5=1651074869,FT_ENCODING_WANSUNG=2002873971,FT_ENCODING_JOHAB=1785686113,FT_ENCODING_MS_SJIS=1936353651,FT_ENCODING_MS_GB2312=1734484000,FT_ENCODING_MS_BIG5=1651074869,FT_ENCODING_MS_WANSUNG=2002873971,FT_ENCODING_MS_JOHAB=1785686113,FT_ENCODING_ADOBE_STANDARD=1094995778,FT_ENCODING_ADOBE_EXPERT=1094992453,FT_ENCODING_ADOBE_CUSTOM=1094992451,FT_ENCODING_ADOBE_LATIN_1=1818326065,FT_ENCODING_OLD_LATIN_2=1818326066,FT_ENCODING_APPLE_ROMAN=1634889070};
typedef enum FT_Render_Mode_{FT_RENDER_MODE_NORMAL=0,FT_RENDER_MODE_LIGHT=1,FT_RENDER_MODE_MONO=2,FT_RENDER_MODE_LCD=3,FT_RENDER_MODE_LCD_V=4,FT_RENDER_MODE_MAX=5};
typedef enum FT_Orientation_{FT_ORIENTATION_TRUETYPE=0,FT_ORIENTATION_POSTSCRIPT=1,FT_ORIENTATION_FILL_RIGHT=0,FT_ORIENTATION_FILL_LEFT=1,FT_ORIENTATION_NONE=2};
typedef enum BDF_PropertyType_{BDF_PROPERTY_TYPE_NONE=0,BDF_PROPERTY_TYPE_ATOM=1,BDF_PROPERTY_TYPE_INTEGER=2,BDF_PROPERTY_TYPE_CARDINAL=3};
typedef enum FT_Pixel_Mode_{FT_PIXEL_MODE_NONE=0,FT_PIXEL_MODE_MONO=1,FT_PIXEL_MODE_GRAY=2,FT_PIXEL_MODE_GRAY2=3,FT_PIXEL_MODE_GRAY4=4,FT_PIXEL_MODE_LCD=5,FT_PIXEL_MODE_LCD_V=6,FT_PIXEL_MODE_BGRA=7,FT_PIXEL_MODE_MAX=8};
typedef enum FT_StrokerBorder_{FT_STROKER_BORDER_LEFT=0,FT_STROKER_BORDER_RIGHT=1};
typedef enum FT_Stroker_LineCap_{FT_STROKER_LINECAP_BUTT=0,FT_STROKER_LINECAP_ROUND=1,FT_STROKER_LINECAP_SQUARE=2};
typedef enum FT_Kerning_Mode_{FT_KERNING_DEFAULT=0,FT_KERNING_UNFITTED=1,FT_KERNING_UNSCALED=2};
struct _FT_Glyph_Class {};
struct FT_MemoryRec_ {void*user;void*(*alloc)(struct FT_MemoryRec_*,long);void(*free)(struct FT_MemoryRec_*,void*);void*(*realloc)(struct FT_MemoryRec_*,long,long,void*);};
union FT_StreamDesc_ {long value;void*pointer;};
struct FT_StreamRec_ {unsigned char*base;unsigned long size;unsigned long pos;union FT_StreamDesc_ descriptor;union FT_StreamDesc_ pathname;unsigned long(*read)(struct FT_StreamRec_*,unsigned long,unsigned char*,unsigned long);void(*close)(struct FT_StreamRec_*);struct FT_MemoryRec_*memory;unsigned char*cursor;unsigned char*limit;};
struct FT_Vector_ {signed long x;signed long y;};
struct FT_BBox_ {signed long xMin;signed long yMin;signed long xMax;signed long yMax;};
struct FT_Bitmap_ {unsigned int rows;unsigned int width;int pitch;unsigned char*buffer;unsigned short num_grays;unsigned char pixel_mode;unsigned char palette_mode;void*palette;};
struct FT_Outline_ {short n_contours;short n_points;struct FT_Vector_*points;char*tags;short*contours;int flags;};
struct FT_Outline_Funcs_ {int(*move_to)(const struct FT_Vector_*,void*);int(*line_to)(const struct FT_Vector_*,void*);int(*conic_to)(const struct FT_Vector_*,const struct FT_Vector_*,void*);int(*cubic_to)(const struct FT_Vector_*,const struct FT_Vector_*,const struct FT_Vector_*,void*);int shift;signed long delta;};
struct FT_Span_ {short x;unsigned short len;unsigned char coverage;};
struct FT_Raster_Params_ {const struct FT_Bitmap_*target;const void*source;int flags;void(*gray_spans)(int,int,const struct FT_Span_*,void*);void(*black_spans)(int,int,const struct FT_Span_*,void*);int(*bit_test)(int,int,void*);void(*bit_set)(int,int,void*);void*user;struct FT_BBox_ clip_box;};
struct FT_Matrix_ {signed long xx;signed long xy;signed long yx;signed long yy;};
struct FT_Generic_ {void*data;void(*finalizer)(void*);};
struct FT_ListNodeRec_ {struct FT_ListNodeRec_*prev;struct FT_ListNodeRec_*next;void*data;};
struct FT_ListRec_ {struct FT_ListNodeRec_*head;struct FT_ListNodeRec_*tail;};
struct FT_Glyph_Metrics_ {signed long width;signed long height;signed long horiBearingX;signed long horiBearingY;signed long horiAdvance;signed long vertBearingX;signed long vertBearingY;signed long vertAdvance;};
struct FT_Bitmap_Size_ {signed short height;signed short width;signed long size;signed long x_ppem;signed long y_ppem;};
struct FT_LibraryRec_ {};
struct FT_ModuleRec_ {};
struct FT_DriverRec_ {};
struct FT_RendererRec_ {};
struct FT_CharMapRec_ {struct FT_FaceRec_*face;enum FT_Encoding_ encoding;unsigned short platform_id;unsigned short encoding_id;};
struct FT_Face_InternalRec_ {};
struct FT_FaceRec_ {signed long num_faces;signed long face_index;signed long face_flags;signed long style_flags;signed long num_glyphs;char*family_name;char*style_name;signed int num_fixed_sizes;struct FT_Bitmap_Size_*available_sizes;signed int num_charmaps;struct FT_CharMapRec_**charmaps;struct FT_Generic_ generic;struct FT_BBox_ bbox;unsigned short units_per_EM;signed short ascender;signed short descender;signed short height;signed short max_advance_width;signed short max_advance_height;signed short underline_position;signed short underline_thickness;struct FT_GlyphSlotRec_*glyph;struct FT_SizeRec_*size;struct FT_CharMapRec_*charmap;struct FT_DriverRec_*driver;struct FT_MemoryRec_*memory;struct FT_StreamRec_*stream;struct FT_ListRec_ sizes_list;struct FT_Generic_ autohint;void*extensions;struct FT_Face_InternalRec_*internal;};
struct FT_Size_InternalRec_ {};
struct FT_Size_Metrics_ {unsigned short x_ppem;unsigned short y_ppem;signed long x_scale;signed long y_scale;signed long ascender;signed long descender;signed long height;signed long max_advance;};
struct FT_SizeRec_ {struct FT_FaceRec_*face;struct FT_Generic_ generic;struct FT_Size_Metrics_ metrics;struct FT_Size_InternalRec_*internal;};
struct FT_SubGlyphRec_ {};
struct FT_Slot_InternalRec_ {};
struct FT_GlyphSlotRec_ {struct FT_LibraryRec_*library;struct FT_FaceRec_*face;struct FT_GlyphSlotRec_*next;unsigned int reserved;struct FT_Generic_ generic;struct FT_Glyph_Metrics_ metrics;signed long linearHoriAdvance;signed long linearVertAdvance;struct FT_Vector_ advance;enum FT_Glyph_Format_ format;struct FT_Bitmap_ bitmap;signed int bitmap_left;signed int bitmap_top;struct FT_Outline_ outline;unsigned int num_subglyphs;struct FT_SubGlyphRec_*subglyphs;void*control_data;long control_len;signed long lsb_delta;signed long rsb_delta;void*other;struct FT_Slot_InternalRec_*internal;};
struct FT_Parameter_ {unsigned long tag;void*data;};
struct FT_Open_Args_ {unsigned int flags;const unsigned char*memory_base;signed long memory_size;char*pathname;struct FT_StreamRec_*stream;struct FT_ModuleRec_*driver;signed int num_params;struct FT_Parameter_*params;};
struct FT_Size_RequestRec_ {enum FT_Size_Request_Type_ type;signed long width;signed long height;unsigned int horiResolution;unsigned int vertResolution;};
struct FT_WinFNT_HeaderRec_ {unsigned short version;unsigned long file_size;unsigned char copyright[60];unsigned short file_type;unsigned short nominal_point_size;unsigned short vertical_resolution;unsigned short horizontal_resolution;unsigned short ascent;unsigned short internal_leading;unsigned short external_leading;unsigned char italic;unsigned char underline;unsigned char strike_out;unsigned short weight;unsigned char charset;unsigned short pixel_width;unsigned short pixel_height;unsigned char pitch_and_family;unsigned short avg_width;unsigned short max_width;unsigned char first_char;unsigned char last_char;unsigned char default_char;unsigned char break_char;unsigned short bytes_per_row;unsigned long device_offset;unsigned long face_name_offset;unsigned long bits_pointer;unsigned long bits_offset;unsigned char reserved;unsigned long flags;unsigned short A_space;unsigned short B_space;unsigned short C_space;unsigned short color_table_offset;unsigned long reserved1[4];};
struct FT_GlyphRec_ {struct FT_LibraryRec_*library;const struct _FT_Glyph_Class*clazz;enum FT_Glyph_Format_ format;struct FT_Vector_ advance;};
struct BDF_PropertyRec_ {enum BDF_PropertyType_ type;union {const char*atom;signed int integer;unsigned int cardinal;}u;};
struct PS_FontInfoRec_ {char*version;char*notice;char*full_name;char*family_name;char*weight;signed long italic_angle;unsigned char is_fixed_pitch;signed short underline_position;unsigned short underline_thickness;};
struct PS_PrivateRec_ {signed int unique_id;signed int lenIV;unsigned char num_blue_values;unsigned char num_other_blues;unsigned char num_family_blues;unsigned char num_family_other_blues;signed short blue_values[14];signed short other_blues[10];signed short family_blues[14];signed short family_other_blues[10];signed long blue_scale;signed int blue_shift;signed int blue_fuzz;unsigned short standard_width[1];unsigned short standard_height[1];unsigned char num_snap_widths;unsigned char num_snap_heights;unsigned char force_bold;unsigned char round_stem_up;signed short snap_widths[13];signed short snap_heights[13];signed long expansion_factor;signed long language_group;signed long password;signed short min_feature[2];};
struct FT_MM_Axis_ {char*name;signed long minimum;signed long maximum;};
struct FT_Multi_Master_ {unsigned int num_axis;unsigned int num_designs;struct FT_MM_Axis_ axis[4];};
struct FT_Var_Axis_ {char*name;signed long minimum;signed long def;signed long maximum;unsigned long tag;unsigned int strid;};
struct FT_Var_Named_Style_ {signed long*coords;unsigned int strid;};
struct FT_MM_Var_ {unsigned int num_axis;unsigned int num_designs;unsigned int num_namedstyles;struct FT_Var_Axis_*axis;struct FT_Var_Named_Style_*namedstyle;};
struct FT_SfntName_ {unsigned short platform_id;unsigned short encoding_id;unsigned short language_id;unsigned short name_id;unsigned char*string;unsigned int string_len;};
struct FT_Module_Class_ {unsigned long module_flags;signed long module_size;const char*module_name;signed long module_version;signed long module_requires;const void*module_interface;int(*module_init)(struct FT_ModuleRec_*);void(*module_done)(struct FT_ModuleRec_*);void*(*get_interface)(struct FT_ModuleRec_*,const char*);};
struct FT_StrokerRec_ {};
void(FT_List_Add)(struct FT_ListRec_*,struct FT_ListNodeRec_*);
void(FT_Stroker_Rewind)(struct FT_StrokerRec_*);
signed long(FT_Tan)(signed long);
int(FT_Bitmap_Embolden)(struct FT_LibraryRec_*,struct FT_Bitmap_*,signed long,signed long);
int(FT_Attach_Stream)(struct FT_FaceRec_*,struct FT_Open_Args_*);
int(FT_Outline_Done_Internal)(struct FT_MemoryRec_*,struct FT_Outline_*);
int(FT_Stroker_LineTo)(struct FT_StrokerRec_*,struct FT_Vector_*);
unsigned int(FT_Face_GetCharVariantIndex)(struct FT_FaceRec_*,unsigned long,unsigned long);
int(FT_New_Face)(struct FT_LibraryRec_*,const char*,signed long,struct FT_FaceRec_**);
void(FT_Outline_Reverse)(struct FT_Outline_*);
void(FT_Add_Default_Modules)(struct FT_LibraryRec_*);
signed long(FT_MulDiv)(signed long,signed long,signed long);
int(FT_Get_BDF_Property)(struct FT_FaceRec_*,const char*,struct BDF_PropertyRec_*);
int(FT_OpenType_Validate)(struct FT_FaceRec_*,unsigned int,const unsigned char**,const unsigned char**,const unsigned char**,const unsigned char**,const unsigned char**);
int(FT_Done_Size)(struct FT_SizeRec_*);
int(FT_New_Size)(struct FT_FaceRec_*,struct FT_SizeRec_**);
int(FT_Add_Module)(struct FT_LibraryRec_*,const struct FT_Module_Class_*);
signed int(FT_Has_PS_Glyph_Names)(struct FT_FaceRec_*);
signed int(FT_Get_Charmap_Index)(struct FT_CharMapRec_*);
int(FT_Get_PFR_Metrics)(struct FT_FaceRec_*,unsigned int*,unsigned int*,signed long*,signed long*);
unsigned int*(FT_Face_GetVariantsOfChar)(struct FT_FaceRec_*,unsigned long);
signed long(FT_CeilFix)(signed long);
int(FT_Set_Renderer)(struct FT_LibraryRec_*,struct FT_RendererRec_*,unsigned int,struct FT_Parameter_*);
int(FT_Set_Charmap)(struct FT_FaceRec_*,struct FT_CharMapRec_*);
void(FT_Vector_Polarize)(struct FT_Vector_*,signed long*,signed long*);
int(FT_Get_Kerning)(struct FT_FaceRec_*,unsigned int,unsigned int,unsigned int,struct FT_Vector_*);
int(FT_Outline_Done)(struct FT_LibraryRec_*,struct FT_Outline_*);
int(FT_New_Library)(struct FT_MemoryRec_*,struct FT_LibraryRec_**);
struct FT_RendererRec_*(FT_Get_Renderer)(struct FT_LibraryRec_*,enum FT_Glyph_Format_);
int(FT_Load_Sfnt_Table)(struct FT_FaceRec_*,unsigned long,signed long,unsigned char*,unsigned long*);
void(FT_Set_Transform)(struct FT_FaceRec_*,struct FT_Matrix_*,struct FT_Vector_*);
void(FT_Stroker_Done)(struct FT_StrokerRec_*);
void(FT_Bitmap_Init)(struct FT_Bitmap_*);
int(FT_Get_Advances)(struct FT_FaceRec_*,unsigned int,unsigned int,signed int,signed long*);
int(FT_Glyph_StrokeBorder)(struct FT_GlyphRec_**,struct FT_StrokerRec_*,unsigned char,unsigned char);
int(FT_Open_Face)(struct FT_LibraryRec_*,const struct FT_Open_Args_*,signed long,struct FT_FaceRec_**);
int(FT_Bitmap_Copy)(struct FT_LibraryRec_*,const struct FT_Bitmap_*,struct FT_Bitmap_*);
int(FT_Stream_OpenGzip)(struct FT_StreamRec_*,struct FT_StreamRec_*);
int(FT_ClassicKern_Validate)(struct FT_FaceRec_*,unsigned int,const unsigned char**);
int(FT_Get_CID_Is_Internally_CID_Keyed)(struct FT_FaceRec_*,unsigned char*);
signed long(FT_Atan2)(signed long,signed long);
void(FT_Library_Version)(struct FT_LibraryRec_*,signed int*,signed int*,signed int*);
int(FT_Glyph_Copy)(struct FT_GlyphRec_*,struct FT_GlyphRec_**);
int(FT_Get_CID_Registry_Ordering_Supplement)(struct FT_FaceRec_*,const char**,const char**,signed int*);
int(FT_Library_SetLcdFilterWeights)(struct FT_LibraryRec_*,unsigned char*);
int(FT_Stroker_EndSubPath)(struct FT_StrokerRec_*);
void(FT_Stroker_ExportBorder)(struct FT_StrokerRec_*,enum FT_StrokerBorder_,struct FT_Outline_*);
unsigned long(FT_Get_CMap_Language_ID)(struct FT_CharMapRec_*);
int(FT_Sfnt_Table_Info)(struct FT_FaceRec_*,unsigned int,unsigned long*,unsigned long*);
void*(FT_Get_Sfnt_Table)(struct FT_FaceRec_*,enum FT_Sfnt_Tag_);
int(FT_Load_Glyph)(struct FT_FaceRec_*,unsigned int,signed int);
void(FT_Vector_From_Polar)(struct FT_Vector_*,signed long,signed long);
int(FT_Load_Char)(struct FT_FaceRec_*,unsigned long,signed int);
signed long(FT_Vector_Length)(struct FT_Vector_*);
void(FT_Vector_Rotate)(struct FT_Vector_*,signed long);
int(FT_Outline_Render)(struct FT_LibraryRec_*,struct FT_Outline_*,struct FT_Raster_Params_*);
int(FT_Matrix_Invert)(struct FT_Matrix_*);
const char*(FT_Get_Font_Format)(struct FT_FaceRec_*);
const char*(FT_Get_X11_Font_Format)(struct FT_FaceRec_*);
void(FT_Glyph_Get_CBox)(struct FT_GlyphRec_*,unsigned int,struct FT_BBox_*);
void(FT_GlyphSlot_Oblique)(struct FT_GlyphSlotRec_*);
int(FT_Stroker_BeginSubPath)(struct FT_StrokerRec_*,struct FT_Vector_*,unsigned char);
int(FT_Glyph_Stroke)(struct FT_GlyphRec_**,struct FT_StrokerRec_*,unsigned char);
void(FT_Stroker_Export)(struct FT_StrokerRec_*,struct FT_Outline_*);
int(FT_Stroker_GetCounts)(struct FT_StrokerRec_*,unsigned int*,unsigned int*);
int(FT_Library_SetLcdFilter)(struct FT_LibraryRec_*,enum FT_LcdFilter_);
int(FT_Set_MM_Design_Coordinates)(struct FT_FaceRec_*,unsigned int,signed long*);
int(FT_Stroker_CubicTo)(struct FT_StrokerRec_*,struct FT_Vector_*,struct FT_Vector_*,struct FT_Vector_*);
void(FT_Bitmap_New)(struct FT_Bitmap_*);
int(FT_Stroker_ConicTo)(struct FT_StrokerRec_*,struct FT_Vector_*,struct FT_Vector_*);
int(FT_Glyph_To_Bitmap)(struct FT_GlyphRec_**,enum FT_Render_Mode_,struct FT_Vector_*,unsigned char);
void(FT_GlyphSlot_Embolden)(struct FT_GlyphSlotRec_*);
int(FT_Get_MM_Var)(struct FT_FaceRec_*,struct FT_MM_Var_**);
int(FT_Get_Glyph)(struct FT_GlyphSlotRec_*,struct FT_GlyphRec_**);
int(FT_Outline_Check)(struct FT_Outline_*);
int(FT_Get_Sfnt_Name)(struct FT_FaceRec_*,unsigned int,struct FT_SfntName_*);
int(FT_Stroker_New)(struct FT_LibraryRec_*,struct FT_StrokerRec_**);
int(FT_Attach_File)(struct FT_FaceRec_*,const char*);
enum FT_StrokerBorder_(FT_Outline_GetInsideBorder)(struct FT_Outline_*);
int(FT_Set_Var_Design_Coordinates)(struct FT_FaceRec_*,unsigned int,signed long*);
int(FT_Get_PFR_Kerning)(struct FT_FaceRec_*,unsigned int,unsigned int,struct FT_Vector_*);
void(FT_ClassicKern_Free)(struct FT_FaceRec_*,const unsigned char*);
int(FT_TrueTypeGX_Validate)(struct FT_FaceRec_*,unsigned int,const unsigned char*,unsigned int);
void(FT_OpenType_Free)(struct FT_FaceRec_*,const unsigned char*);
int(FT_Outline_Get_BBox)(struct FT_Outline_*,struct FT_BBox_*);
enum FT_TrueTypeEngineType_(FT_Get_TrueType_Engine_Type)(struct FT_LibraryRec_*);
int(FT_Get_PS_Font_Info)(struct FT_FaceRec_*,struct PS_FontInfoRec_*);
int(FT_Done_Library)(struct FT_LibraryRec_*);
int(FT_Stream_OpenLZW)(struct FT_StreamRec_*,struct FT_StreamRec_*);
int(FT_Reference_Library)(struct FT_LibraryRec_*);
int(FT_Property_Get)(struct FT_LibraryRec_*,const char*,const char*,void*);
int(FT_Property_Set)(struct FT_LibraryRec_*,const char*,const char*,const void*);
int(FT_Remove_Module)(struct FT_LibraryRec_*,struct FT_ModuleRec_*);
int(FT_Set_Var_Blend_Coordinates)(struct FT_FaceRec_*,unsigned int,signed long*);
int(FT_Set_MM_Blend_Coordinates)(struct FT_FaceRec_*,unsigned int,signed long*);
unsigned long(FT_Get_Next_Char)(struct FT_FaceRec_*,unsigned long,unsigned int*);
int(FT_Get_PS_Font_Private)(struct FT_FaceRec_*,struct PS_PrivateRec_*);
int(FT_Get_BDF_Charset_ID)(struct FT_FaceRec_*,const char**,const char**);
signed long(FT_Angle_Diff)(signed long,signed long);
signed long(FT_FloorFix)(signed long);
int(FT_Get_WinFNT_Header)(struct FT_FaceRec_*,struct FT_WinFNT_HeaderRec_*);
void(FT_Outline_Transform)(const struct FT_Outline_*,const struct FT_Matrix_*);
void(FT_Outline_Translate)(const struct FT_Outline_*,signed long,signed long);
void(FT_Outline_Get_CBox)(const struct FT_Outline_*,struct FT_BBox_*);
void(FT_Stroker_Set)(struct FT_StrokerRec_*,signed long,enum FT_Stroker_LineCap_,enum FT_Stroker_LineJoin_,signed long);
void(FT_List_Up)(struct FT_ListRec_*,struct FT_ListNodeRec_*);
int(FT_Outline_Decompose)(struct FT_Outline_*,const struct FT_Outline_Funcs_*,void*);
void(FT_List_Finalize)(struct FT_ListRec_*,void(*destroy)(struct FT_MemoryRec_*,void*,void*),struct FT_MemoryRec_*,void*);
int(FT_List_Iterate)(struct FT_ListRec_*,int(*iterator)(struct FT_ListNodeRec_*,void*),void*);
int(FT_Outline_New_Internal)(struct FT_MemoryRec_*,unsigned int,signed int,struct FT_Outline_*);
int(FT_Set_Char_Size)(struct FT_FaceRec_*,signed long,signed long,unsigned int,unsigned int);
void(FT_List_Remove)(struct FT_ListRec_*,struct FT_ListNodeRec_*);
void(FT_List_Insert)(struct FT_ListRec_*,struct FT_ListNodeRec_*);
signed int(FT_Get_Gasp)(struct FT_FaceRec_*,unsigned int);
int(FT_Bitmap_Done)(struct FT_LibraryRec_*,struct FT_Bitmap_*);
int(FT_GlyphSlot_Own_Bitmap)(struct FT_GlyphSlotRec_*);
int(FT_Bitmap_Convert)(struct FT_LibraryRec_*,const struct FT_Bitmap_*,struct FT_Bitmap_*,signed int);
int(FT_Gzip_Uncompress)(struct FT_MemoryRec_*,unsigned char*,unsigned long*,const unsigned char*,unsigned long);
signed long(FT_Sin)(signed long);
void(FT_Matrix_Multiply)(const struct FT_Matrix_*,struct FT_Matrix_*);
void(FT_Done_Glyph)(struct FT_GlyphRec_*);
int(FT_Glyph_Transform)(struct FT_GlyphRec_*,struct FT_Matrix_*,struct FT_Vector_*);
int(FT_Stroker_ParseOutline)(struct FT_StrokerRec_*,struct FT_Outline_*,unsigned char);
int(FT_Stream_OpenBzip2)(struct FT_StreamRec_*,struct FT_StreamRec_*);
unsigned char(FT_Face_SetUnpatentedHinting)(struct FT_FaceRec_*,unsigned char);
unsigned char(FT_Face_CheckTrueTypePatents)(struct FT_FaceRec_*);
void(FT_Vector_Transform)(struct FT_Vector_*,const struct FT_Matrix_*);
enum FT_StrokerBorder_(FT_Outline_GetOutsideBorder)(struct FT_Outline_*);
signed long(FT_MulFix)(signed long,signed long);
int(FT_Select_Charmap)(struct FT_FaceRec_*,enum FT_Encoding_);
int(FT_New_Memory_Face)(struct FT_LibraryRec_*,const unsigned char*,signed long,signed long,struct FT_FaceRec_**);
unsigned int*(FT_Face_GetVariantSelectors)(struct FT_FaceRec_*);
signed int(FT_Face_GetCharVariantIsDefault)(struct FT_FaceRec_*,unsigned long,unsigned long);
int(FT_Get_SubGlyph_Info)(struct FT_GlyphSlotRec_*,unsigned int,signed int*,unsigned int*,signed int*,signed int*,struct FT_Matrix_*);
unsigned int(FT_Get_Name_Index)(struct FT_FaceRec_*,char*);
signed long(FT_Get_PS_Font_Value)(struct FT_FaceRec_*,enum PS_Dict_Keys_,unsigned int,void*,signed long);
unsigned long(FT_Get_First_Char)(struct FT_FaceRec_*,unsigned int*);
unsigned int(FT_Get_Char_Index)(struct FT_FaceRec_*,unsigned long);
int(FT_Get_Advance)(struct FT_FaceRec_*,unsigned int,signed int,signed long*);
int(FT_Get_Glyph_Name)(struct FT_FaceRec_*,unsigned int,void*,unsigned int);
int(FT_Get_Track_Kerning)(struct FT_FaceRec_*,signed long,signed int,signed long*);
int(FT_Render_Glyph)(struct FT_GlyphSlotRec_*,enum FT_Render_Mode_);
int(FT_Set_Pixel_Sizes)(struct FT_FaceRec_*,unsigned int,unsigned int);
int(FT_Request_Size)(struct FT_FaceRec_*,struct FT_Size_RequestRec_*);
const char*(FT_Get_Postscript_Name)(struct FT_FaceRec_*);
int(FT_Done_Face)(struct FT_FaceRec_*);
signed long(FT_RoundFix)(signed long);
int(FT_Done_FreeType)(struct FT_LibraryRec_*);
unsigned int(FT_Get_Sfnt_Name_Count)(struct FT_FaceRec_*);
int(FT_Get_PFR_Advance)(struct FT_FaceRec_*,unsigned int,signed long*);
int(FT_Outline_Copy)(const struct FT_Outline_*,struct FT_Outline_*);
signed long(FT_DivFix)(signed long,signed long);
enum FT_Orientation_(FT_Outline_Get_Orientation)(struct FT_Outline_*);
int(FT_Reference_Face)(struct FT_FaceRec_*);
void(FT_Set_Debug_Hook)(struct FT_LibraryRec_*,unsigned int,void(*debug_hook)(void*));
int(FT_Outline_Embolden)(struct FT_Outline_*,signed long);
unsigned int*(FT_Face_GetCharsOfVariant)(struct FT_FaceRec_*,unsigned long);
signed long(FT_Get_CMap_Format)(struct FT_CharMapRec_*);
int(FT_Activate_Size)(struct FT_SizeRec_*);
int(FT_Init_FreeType)(struct FT_LibraryRec_**);
signed long(FT_Cos)(signed long);
struct FT_ListNodeRec_*(FT_List_Find)(struct FT_ListRec_*,void*);
int(FT_Outline_Get_Bitmap)(struct FT_LibraryRec_*,struct FT_Outline_*,const struct FT_Bitmap_*);
unsigned short(FT_Get_FSType_Flags)(struct FT_FaceRec_*);
struct FT_ModuleRec_*(FT_Get_Module)(struct FT_LibraryRec_*,const char*);
int(FT_Get_Multi_Master)(struct FT_FaceRec_*,struct FT_Multi_Master_*);
int(FT_Stroker_GetBorderCounts)(struct FT_StrokerRec_*,enum FT_StrokerBorder_,unsigned int*,unsigned int*);
void(FT_TrueTypeGX_Free)(struct FT_FaceRec_*,const unsigned char*);
void(FT_Vector_Unit)(struct FT_Vector_*,signed long);
int(FT_Get_CID_From_Glyph_Index)(struct FT_FaceRec_*,unsigned int,unsigned int*);
int(FT_Outline_EmboldenXY)(struct FT_Outline_*,signed long,signed long);
int(FT_Select_Size)(struct FT_FaceRec_*,signed int);
int(FT_Outline_New)(struct FT_LibraryRec_*,unsigned int,signed int,struct FT_Outline_*);
]])
local CLIB = ffi.load(_G.FFI_LIB or "freetype")
local library = {}
library = {
	ListAdd = CLIB.FT_List_Add,
	StrokerRewind = CLIB.FT_Stroker_Rewind,
	Tan = CLIB.FT_Tan,
	BitmapEmbolden = CLIB.FT_Bitmap_Embolden,
	AttachStream = CLIB.FT_Attach_Stream,
	OutlineDoneInternal = CLIB.FT_Outline_Done_Internal,
	StrokerLineTo = CLIB.FT_Stroker_LineTo,
	FaceGetCharVariantIndex = CLIB.FT_Face_GetCharVariantIndex,
	NewFace = CLIB.FT_New_Face,
	OutlineReverse = CLIB.FT_Outline_Reverse,
	AddDefaultModules = CLIB.FT_Add_Default_Modules,
	MulDiv = CLIB.FT_MulDiv,
	GetBDFProperty = CLIB.FT_Get_BDF_Property,
	OpenTypeValidate = CLIB.FT_OpenType_Validate,
	DoneSize = CLIB.FT_Done_Size,
	NewSize = CLIB.FT_New_Size,
	AddModule = CLIB.FT_Add_Module,
	HasPSGlyphNames = CLIB.FT_Has_PS_Glyph_Names,
	GetCharmapIndex = CLIB.FT_Get_Charmap_Index,
	GetPFRMetrics = CLIB.FT_Get_PFR_Metrics,
	FaceGetVariantsOfChar = CLIB.FT_Face_GetVariantsOfChar,
	CeilFix = CLIB.FT_CeilFix,
	SetRenderer = CLIB.FT_Set_Renderer,
	SetCharmap = CLIB.FT_Set_Charmap,
	VectorPolarize = CLIB.FT_Vector_Polarize,
	GetKerning = CLIB.FT_Get_Kerning,
	OutlineDone = CLIB.FT_Outline_Done,
	NewLibrary = CLIB.FT_New_Library,
	GetRenderer = CLIB.FT_Get_Renderer,
	LoadSfntTable = CLIB.FT_Load_Sfnt_Table,
	SetTransform = CLIB.FT_Set_Transform,
	StrokerDone = CLIB.FT_Stroker_Done,
	BitmapInit = CLIB.FT_Bitmap_Init,
	GetAdvances = CLIB.FT_Get_Advances,
	GlyphStrokeBorder = CLIB.FT_Glyph_StrokeBorder,
	OpenFace = CLIB.FT_Open_Face,
	BitmapCopy = CLIB.FT_Bitmap_Copy,
	StreamOpenGzip = CLIB.FT_Stream_OpenGzip,
	ClassicKernValidate = CLIB.FT_ClassicKern_Validate,
	GetCIDIsInternallyCIDKeyed = CLIB.FT_Get_CID_Is_Internally_CID_Keyed,
	Atan2 = CLIB.FT_Atan2,
	LibraryVersion = CLIB.FT_Library_Version,
	GlyphCopy = CLIB.FT_Glyph_Copy,
	GetCIDRegistryOrderingSupplement = CLIB.FT_Get_CID_Registry_Ordering_Supplement,
	LibrarySetLcdFilterWeights = CLIB.FT_Library_SetLcdFilterWeights,
	StrokerEndSubPath = CLIB.FT_Stroker_EndSubPath,
	StrokerExportBorder = CLIB.FT_Stroker_ExportBorder,
	GetCMapLanguageID = CLIB.FT_Get_CMap_Language_ID,
	SfntTableInfo = CLIB.FT_Sfnt_Table_Info,
	GetSfntTable = CLIB.FT_Get_Sfnt_Table,
	LoadGlyph = CLIB.FT_Load_Glyph,
	VectorFromPolar = CLIB.FT_Vector_From_Polar,
	LoadChar = CLIB.FT_Load_Char,
	VectorLength = CLIB.FT_Vector_Length,
	VectorRotate = CLIB.FT_Vector_Rotate,
	OutlineRender = CLIB.FT_Outline_Render,
	MatrixInvert = CLIB.FT_Matrix_Invert,
	GetFontFormat = CLIB.FT_Get_Font_Format,
	GetX11FontFormat = CLIB.FT_Get_X11_Font_Format,
	GlyphGetCBox = CLIB.FT_Glyph_Get_CBox,
	GlyphSlotOblique = CLIB.FT_GlyphSlot_Oblique,
	StrokerBeginSubPath = CLIB.FT_Stroker_BeginSubPath,
	GlyphStroke = CLIB.FT_Glyph_Stroke,
	StrokerExport = CLIB.FT_Stroker_Export,
	StrokerGetCounts = CLIB.FT_Stroker_GetCounts,
	LibrarySetLcdFilter = CLIB.FT_Library_SetLcdFilter,
	SetMMDesignCoordinates = CLIB.FT_Set_MM_Design_Coordinates,
	StrokerCubicTo = CLIB.FT_Stroker_CubicTo,
	BitmapNew = CLIB.FT_Bitmap_New,
	StrokerConicTo = CLIB.FT_Stroker_ConicTo,
	GlyphToBitmap = CLIB.FT_Glyph_To_Bitmap,
	GlyphSlotEmbolden = CLIB.FT_GlyphSlot_Embolden,
	GetMMVar = CLIB.FT_Get_MM_Var,
	GetGlyph = CLIB.FT_Get_Glyph,
	OutlineCheck = CLIB.FT_Outline_Check,
	GetSfntName = CLIB.FT_Get_Sfnt_Name,
	StrokerNew = CLIB.FT_Stroker_New,
	AttachFile = CLIB.FT_Attach_File,
	OutlineGetInsideBorder = CLIB.FT_Outline_GetInsideBorder,
	SetVarDesignCoordinates = CLIB.FT_Set_Var_Design_Coordinates,
	GetPFRKerning = CLIB.FT_Get_PFR_Kerning,
	ClassicKernFree = CLIB.FT_ClassicKern_Free,
	TrueTypeGXValidate = CLIB.FT_TrueTypeGX_Validate,
	OpenTypeFree = CLIB.FT_OpenType_Free,
	OutlineGetBBox = CLIB.FT_Outline_Get_BBox,
	GetTrueTypeEngineType = CLIB.FT_Get_TrueType_Engine_Type,
	GetPSFontInfo = CLIB.FT_Get_PS_Font_Info,
	DoneLibrary = CLIB.FT_Done_Library,
	StreamOpenLZW = CLIB.FT_Stream_OpenLZW,
	ReferenceLibrary = CLIB.FT_Reference_Library,
	PropertyGet = CLIB.FT_Property_Get,
	PropertySet = CLIB.FT_Property_Set,
	RemoveModule = CLIB.FT_Remove_Module,
	SetVarBlendCoordinates = CLIB.FT_Set_Var_Blend_Coordinates,
	SetMMBlendCoordinates = CLIB.FT_Set_MM_Blend_Coordinates,
	GetNextChar = CLIB.FT_Get_Next_Char,
	GetPSFontPrivate = CLIB.FT_Get_PS_Font_Private,
	GetBDFCharsetID = CLIB.FT_Get_BDF_Charset_ID,
	AngleDiff = CLIB.FT_Angle_Diff,
	FloorFix = CLIB.FT_FloorFix,
	GetWinFNTHeader = CLIB.FT_Get_WinFNT_Header,
	OutlineTransform = CLIB.FT_Outline_Transform,
	OutlineTranslate = CLIB.FT_Outline_Translate,
	OutlineGetCBox = CLIB.FT_Outline_Get_CBox,
	StrokerSet = CLIB.FT_Stroker_Set,
	ListUp = CLIB.FT_List_Up,
	OutlineDecompose = CLIB.FT_Outline_Decompose,
	ListFinalize = CLIB.FT_List_Finalize,
	ListIterate = CLIB.FT_List_Iterate,
	OutlineNewInternal = CLIB.FT_Outline_New_Internal,
	SetCharSize = CLIB.FT_Set_Char_Size,
	ListRemove = CLIB.FT_List_Remove,
	ListInsert = CLIB.FT_List_Insert,
	GetGasp = CLIB.FT_Get_Gasp,
	BitmapDone = CLIB.FT_Bitmap_Done,
	GlyphSlotOwnBitmap = CLIB.FT_GlyphSlot_Own_Bitmap,
	BitmapConvert = CLIB.FT_Bitmap_Convert,
	GzipUncompress = CLIB.FT_Gzip_Uncompress,
	Sin = CLIB.FT_Sin,
	MatrixMultiply = CLIB.FT_Matrix_Multiply,
	DoneGlyph = CLIB.FT_Done_Glyph,
	GlyphTransform = CLIB.FT_Glyph_Transform,
	StrokerParseOutline = CLIB.FT_Stroker_ParseOutline,
	StreamOpenBzip2 = CLIB.FT_Stream_OpenBzip2,
	FaceSetUnpatentedHinting = CLIB.FT_Face_SetUnpatentedHinting,
	FaceCheckTrueTypePatents = CLIB.FT_Face_CheckTrueTypePatents,
	VectorTransform = CLIB.FT_Vector_Transform,
	OutlineGetOutsideBorder = CLIB.FT_Outline_GetOutsideBorder,
	MulFix = CLIB.FT_MulFix,
	SelectCharmap = CLIB.FT_Select_Charmap,
	NewMemoryFace = CLIB.FT_New_Memory_Face,
	FaceGetVariantSelectors = CLIB.FT_Face_GetVariantSelectors,
	FaceGetCharVariantIsDefault = CLIB.FT_Face_GetCharVariantIsDefault,
	GetSubGlyphInfo = CLIB.FT_Get_SubGlyph_Info,
	GetNameIndex = CLIB.FT_Get_Name_Index,
	GetPSFontValue = CLIB.FT_Get_PS_Font_Value,
	GetFirstChar = CLIB.FT_Get_First_Char,
	GetCharIndex = CLIB.FT_Get_Char_Index,
	GetAdvance = CLIB.FT_Get_Advance,
	GetGlyphName = CLIB.FT_Get_Glyph_Name,
	GetTrackKerning = CLIB.FT_Get_Track_Kerning,
	RenderGlyph = CLIB.FT_Render_Glyph,
	SetPixelSizes = CLIB.FT_Set_Pixel_Sizes,
	RequestSize = CLIB.FT_Request_Size,
	GetPostscriptName = CLIB.FT_Get_Postscript_Name,
	DoneFace = CLIB.FT_Done_Face,
	RoundFix = CLIB.FT_RoundFix,
	DoneFreeType = CLIB.FT_Done_FreeType,
	GetSfntNameCount = CLIB.FT_Get_Sfnt_Name_Count,
	GetPFRAdvance = CLIB.FT_Get_PFR_Advance,
	OutlineCopy = CLIB.FT_Outline_Copy,
	DivFix = CLIB.FT_DivFix,
	OutlineGetOrientation = CLIB.FT_Outline_Get_Orientation,
	ReferenceFace = CLIB.FT_Reference_Face,
	SetDebugHook = CLIB.FT_Set_Debug_Hook,
	OutlineEmbolden = CLIB.FT_Outline_Embolden,
	FaceGetCharsOfVariant = CLIB.FT_Face_GetCharsOfVariant,
	GetCMapFormat = CLIB.FT_Get_CMap_Format,
	ActivateSize = CLIB.FT_Activate_Size,
	InitFreeType = CLIB.FT_Init_FreeType,
	Cos = CLIB.FT_Cos,
	ListFind = CLIB.FT_List_Find,
	OutlineGetBitmap = CLIB.FT_Outline_Get_Bitmap,
	GetFSTypeFlags = CLIB.FT_Get_FSType_Flags,
	GetModule = CLIB.FT_Get_Module,
	GetMultiMaster = CLIB.FT_Get_Multi_Master,
	StrokerGetBorderCounts = CLIB.FT_Stroker_GetBorderCounts,
	TrueTypeGXFree = CLIB.FT_TrueTypeGX_Free,
	VectorUnit = CLIB.FT_Vector_Unit,
	GetCIDFromGlyphIndex = CLIB.FT_Get_CID_From_Glyph_Index,
	OutlineEmboldenXY = CLIB.FT_Outline_EmboldenXY,
	SelectSize = CLIB.FT_Select_Size,
	OutlineNew = CLIB.FT_Outline_New,
}
library.e = {
	LCD_FILTER_NONE = ffi.cast("enum FT_LcdFilter_", "FT_LCD_FILTER_NONE"),
	LCD_FILTER_DEFAULT = ffi.cast("enum FT_LcdFilter_", "FT_LCD_FILTER_DEFAULT"),
	LCD_FILTER_LIGHT = ffi.cast("enum FT_LcdFilter_", "FT_LCD_FILTER_LIGHT"),
	LCD_FILTER_LEGACY1 = ffi.cast("enum FT_LcdFilter_", "FT_LCD_FILTER_LEGACY1"),
	LCD_FILTER_LEGACY = ffi.cast("enum FT_LcdFilter_", "FT_LCD_FILTER_LEGACY"),
	LCD_FILTER_MAX = ffi.cast("enum FT_LcdFilter_", "FT_LCD_FILTER_MAX"),
	GLYPH_FORMAT_NONE = ffi.cast("enum FT_Glyph_Format_", "FT_GLYPH_FORMAT_NONE"),
	GLYPH_FORMAT_COMPOSITE = ffi.cast("enum FT_Glyph_Format_", "FT_GLYPH_FORMAT_COMPOSITE"),
	GLYPH_FORMAT_BITMAP = ffi.cast("enum FT_Glyph_Format_", "FT_GLYPH_FORMAT_BITMAP"),
	GLYPH_FORMAT_OUTLINE = ffi.cast("enum FT_Glyph_Format_", "FT_GLYPH_FORMAT_OUTLINE"),
	GLYPH_FORMAT_PLOTTER = ffi.cast("enum FT_Glyph_Format_", "FT_GLYPH_FORMAT_PLOTTER"),
	TRUETYPE_ENGINE_TYPE_NONE = ffi.cast("enum FT_TrueTypeEngineType_", "FT_TRUETYPE_ENGINE_TYPE_NONE"),
	TRUETYPE_ENGINE_TYPE_UNPATENTED = ffi.cast("enum FT_TrueTypeEngineType_", "FT_TRUETYPE_ENGINE_TYPE_UNPATENTED"),
	TRUETYPE_ENGINE_TYPE_PATENTED = ffi.cast("enum FT_TrueTypeEngineType_", "FT_TRUETYPE_ENGINE_TYPE_PATENTED"),
	STROKER_LINEJOIN_ROUND = ffi.cast("enum FT_Stroker_LineJoin_", "FT_STROKER_LINEJOIN_ROUND"),
	STROKER_LINEJOIN_BEVEL = ffi.cast("enum FT_Stroker_LineJoin_", "FT_STROKER_LINEJOIN_BEVEL"),
	STROKER_LINEJOIN_MITER_VARIABLE = ffi.cast("enum FT_Stroker_LineJoin_", "FT_STROKER_LINEJOIN_MITER_VARIABLE"),
	STROKER_LINEJOIN_MITER = ffi.cast("enum FT_Stroker_LineJoin_", "FT_STROKER_LINEJOIN_MITER"),
	STROKER_LINEJOIN_MITER_FIXED = ffi.cast("enum FT_Stroker_LineJoin_", "FT_STROKER_LINEJOIN_MITER_FIXED"),
	SFNT_HEAD = ffi.cast("enum FT_Sfnt_Tag_", "FT_SFNT_HEAD"),
	SFNT_MAXP = ffi.cast("enum FT_Sfnt_Tag_", "FT_SFNT_MAXP"),
	SFNT_OS2 = ffi.cast("enum FT_Sfnt_Tag_", "FT_SFNT_OS2"),
	SFNT_HHEA = ffi.cast("enum FT_Sfnt_Tag_", "FT_SFNT_HHEA"),
	SFNT_VHEA = ffi.cast("enum FT_Sfnt_Tag_", "FT_SFNT_VHEA"),
	SFNT_POST = ffi.cast("enum FT_Sfnt_Tag_", "FT_SFNT_POST"),
	SFNT_PCLT = ffi.cast("enum FT_Sfnt_Tag_", "FT_SFNT_PCLT"),
	SFNT_MAX = ffi.cast("enum FT_Sfnt_Tag_", "FT_SFNT_MAX"),
	GLYPH_BBOX_UNSCALED = ffi.cast("enum FT_Glyph_BBox_Mode_", "FT_GLYPH_BBOX_UNSCALED"),
	GLYPH_BBOX_SUBPIXELS = ffi.cast("enum FT_Glyph_BBox_Mode_", "FT_GLYPH_BBOX_SUBPIXELS"),
	GLYPH_BBOX_GRIDFIT = ffi.cast("enum FT_Glyph_BBox_Mode_", "FT_GLYPH_BBOX_GRIDFIT"),
	GLYPH_BBOX_TRUNCATE = ffi.cast("enum FT_Glyph_BBox_Mode_", "FT_GLYPH_BBOX_TRUNCATE"),
	GLYPH_BBOX_PIXELS = ffi.cast("enum FT_Glyph_BBox_Mode_", "FT_GLYPH_BBOX_PIXELS"),
	SIZE_REQUEST_TYPE_NOMINAL = ffi.cast("enum FT_Size_Request_Type_", "FT_SIZE_REQUEST_TYPE_NOMINAL"),
	SIZE_REQUEST_TYPE_REAL_DIM = ffi.cast("enum FT_Size_Request_Type_", "FT_SIZE_REQUEST_TYPE_REAL_DIM"),
	SIZE_REQUEST_TYPE_BBOX = ffi.cast("enum FT_Size_Request_Type_", "FT_SIZE_REQUEST_TYPE_BBOX"),
	SIZE_REQUEST_TYPE_CELL = ffi.cast("enum FT_Size_Request_Type_", "FT_SIZE_REQUEST_TYPE_CELL"),
	SIZE_REQUEST_TYPE_SCALES = ffi.cast("enum FT_Size_Request_Type_", "FT_SIZE_REQUEST_TYPE_SCALES"),
	SIZE_REQUEST_TYPE_MAX = ffi.cast("enum FT_Size_Request_Type_", "FT_SIZE_REQUEST_TYPE_MAX"),
	ENCODING_NONE = ffi.cast("enum FT_Encoding_", "FT_ENCODING_NONE"),
	ENCODING_MS_SYMBOL = ffi.cast("enum FT_Encoding_", "FT_ENCODING_MS_SYMBOL"),
	ENCODING_UNICODE = ffi.cast("enum FT_Encoding_", "FT_ENCODING_UNICODE"),
	ENCODING_SJIS = ffi.cast("enum FT_Encoding_", "FT_ENCODING_SJIS"),
	ENCODING_GB2312 = ffi.cast("enum FT_Encoding_", "FT_ENCODING_GB2312"),
	ENCODING_BIG5 = ffi.cast("enum FT_Encoding_", "FT_ENCODING_BIG5"),
	ENCODING_WANSUNG = ffi.cast("enum FT_Encoding_", "FT_ENCODING_WANSUNG"),
	ENCODING_JOHAB = ffi.cast("enum FT_Encoding_", "FT_ENCODING_JOHAB"),
	ENCODING_MS_SJIS = ffi.cast("enum FT_Encoding_", "FT_ENCODING_MS_SJIS"),
	ENCODING_MS_GB2312 = ffi.cast("enum FT_Encoding_", "FT_ENCODING_MS_GB2312"),
	ENCODING_MS_BIG5 = ffi.cast("enum FT_Encoding_", "FT_ENCODING_MS_BIG5"),
	ENCODING_MS_WANSUNG = ffi.cast("enum FT_Encoding_", "FT_ENCODING_MS_WANSUNG"),
	ENCODING_MS_JOHAB = ffi.cast("enum FT_Encoding_", "FT_ENCODING_MS_JOHAB"),
	ENCODING_ADOBE_STANDARD = ffi.cast("enum FT_Encoding_", "FT_ENCODING_ADOBE_STANDARD"),
	ENCODING_ADOBE_EXPERT = ffi.cast("enum FT_Encoding_", "FT_ENCODING_ADOBE_EXPERT"),
	ENCODING_ADOBE_CUSTOM = ffi.cast("enum FT_Encoding_", "FT_ENCODING_ADOBE_CUSTOM"),
	ENCODING_ADOBE_LATIN_1 = ffi.cast("enum FT_Encoding_", "FT_ENCODING_ADOBE_LATIN_1"),
	ENCODING_OLD_LATIN_2 = ffi.cast("enum FT_Encoding_", "FT_ENCODING_OLD_LATIN_2"),
	ENCODING_APPLE_ROMAN = ffi.cast("enum FT_Encoding_", "FT_ENCODING_APPLE_ROMAN"),
	RENDER_MODE_NORMAL = ffi.cast("enum FT_Render_Mode_", "FT_RENDER_MODE_NORMAL"),
	RENDER_MODE_LIGHT = ffi.cast("enum FT_Render_Mode_", "FT_RENDER_MODE_LIGHT"),
	RENDER_MODE_MONO = ffi.cast("enum FT_Render_Mode_", "FT_RENDER_MODE_MONO"),
	RENDER_MODE_LCD = ffi.cast("enum FT_Render_Mode_", "FT_RENDER_MODE_LCD"),
	RENDER_MODE_LCD_V = ffi.cast("enum FT_Render_Mode_", "FT_RENDER_MODE_LCD_V"),
	RENDER_MODE_MAX = ffi.cast("enum FT_Render_Mode_", "FT_RENDER_MODE_MAX"),
	ORIENTATION_TRUETYPE = ffi.cast("enum FT_Orientation_", "FT_ORIENTATION_TRUETYPE"),
	ORIENTATION_POSTSCRIPT = ffi.cast("enum FT_Orientation_", "FT_ORIENTATION_POSTSCRIPT"),
	ORIENTATION_FILL_RIGHT = ffi.cast("enum FT_Orientation_", "FT_ORIENTATION_FILL_RIGHT"),
	ORIENTATION_FILL_LEFT = ffi.cast("enum FT_Orientation_", "FT_ORIENTATION_FILL_LEFT"),
	ORIENTATION_NONE = ffi.cast("enum FT_Orientation_", "FT_ORIENTATION_NONE"),
	PIXEL_MODE_NONE = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_NONE"),
	PIXEL_MODE_MONO = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_MONO"),
	PIXEL_MODE_GRAY = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_GRAY"),
	PIXEL_MODE_GRAY2 = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_GRAY2"),
	PIXEL_MODE_GRAY4 = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_GRAY4"),
	PIXEL_MODE_LCD = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_LCD"),
	PIXEL_MODE_LCD_V = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_LCD_V"),
	PIXEL_MODE_BGRA = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_BGRA"),
	PIXEL_MODE_MAX = ffi.cast("enum FT_Pixel_Mode_", "FT_PIXEL_MODE_MAX"),
	STROKER_BORDER_LEFT = ffi.cast("enum FT_StrokerBorder_", "FT_STROKER_BORDER_LEFT"),
	STROKER_BORDER_RIGHT = ffi.cast("enum FT_StrokerBorder_", "FT_STROKER_BORDER_RIGHT"),
	STROKER_LINECAP_BUTT = ffi.cast("enum FT_Stroker_LineCap_", "FT_STROKER_LINECAP_BUTT"),
	STROKER_LINECAP_ROUND = ffi.cast("enum FT_Stroker_LineCap_", "FT_STROKER_LINECAP_ROUND"),
	STROKER_LINECAP_SQUARE = ffi.cast("enum FT_Stroker_LineCap_", "FT_STROKER_LINECAP_SQUARE"),
	KERNING_DEFAULT = ffi.cast("enum FT_Kerning_Mode_", "FT_KERNING_DEFAULT"),
	KERNING_UNFITTED = ffi.cast("enum FT_Kerning_Mode_", "FT_KERNING_UNFITTED"),
	KERNING_UNSCALED = ffi.cast("enum FT_Kerning_Mode_", "FT_KERNING_UNSCALED"),
	Mod_Err_Base = 0,
	Mod_Err_Autofit = 0,
	Mod_Err_BDF = 0,
	Mod_Err_Bzip2 = 0,
	Mod_Err_Cache = 0,
	Mod_Err_CFF = 0,
	Mod_Err_CID = 0,
	Mod_Err_Gzip = 0,
	Mod_Err_LZW = 0,
	Mod_Err_OTvalid = 0,
	Mod_Err_PCF = 0,
	Mod_Err_PFR = 0,
	Mod_Err_PSaux = 0,
	Mod_Err_PShinter = 0,
	Mod_Err_PSnames = 0,
	Mod_Err_Raster = 0,
	Mod_Err_SFNT = 0,
	Mod_Err_Smooth = 0,
	Mod_Err_TrueType = 0,
	Mod_Err_Type1 = 0,
	Mod_Err_Type42 = 0,
	Mod_Err_Winfonts = 0,
	Mod_Err_GXvalid = 0,
	Mod_Err_Max = 1,
	Err_Ok = 0,
	Err_Cannot_Open_Resource = 1,
	Err_Unknown_File_Format = 2,
	Err_Invalid_File_Format = 3,
	Err_Invalid_Version = 4,
	Err_Lower_Module_Version = 5,
	Err_Invalid_Argument = 6,
	Err_Unimplemented_Feature = 7,
	Err_Invalid_Table = 8,
	Err_Invalid_Offset = 9,
	Err_Array_Too_Large = 10,
	Err_Missing_Module = 11,
	Err_Missing_Property = 12,
	Err_Invalid_Glyph_Index = 16,
	Err_Invalid_Character_Code = 17,
	Err_Invalid_Glyph_Format = 18,
	Err_Cannot_Render_Glyph = 19,
	Err_Invalid_Outline = 20,
	Err_Invalid_Composite = 21,
	Err_Too_Many_Hints = 22,
	Err_Invalid_Pixel_Size = 23,
	Err_Invalid_Handle = 32,
	Err_Invalid_Library_Handle = 33,
	Err_Invalid_Driver_Handle = 34,
	Err_Invalid_Face_Handle = 35,
	Err_Invalid_Size_Handle = 36,
	Err_Invalid_Slot_Handle = 37,
	Err_Invalid_CharMap_Handle = 38,
	Err_Invalid_Cache_Handle = 39,
	Err_Invalid_Stream_Handle = 40,
	Err_Too_Many_Drivers = 48,
	Err_Too_Many_Extensions = 49,
	Err_Out_Of_Memory = 64,
	Err_Unlisted_Object = 65,
	Err_Cannot_Open_Stream = 81,
	Err_Invalid_Stream_Seek = 82,
	Err_Invalid_Stream_Skip = 83,
	Err_Invalid_Stream_Read = 84,
	Err_Invalid_Stream_Operation = 85,
	Err_Invalid_Frame_Operation = 86,
	Err_Nested_Frame_Access = 87,
	Err_Invalid_Frame_Read = 88,
	Err_Raster_Uninitialized = 96,
	Err_Raster_Corrupted = 97,
	Err_Raster_Overflow = 98,
	Err_Raster_Negative_Height = 99,
	Err_Too_Many_Caches = 112,
	Err_Invalid_Opcode = 128,
	Err_Too_Few_Arguments = 129,
	Err_Stack_Overflow = 130,
	Err_Code_Overflow = 131,
	Err_Bad_Argument = 132,
	Err_Divide_By_Zero = 133,
	Err_Invalid_Reference = 134,
	Err_Debug_OpCode = 135,
	Err_ENDF_In_Exec_Stream = 136,
	Err_Nested_DEFS = 137,
	Err_Invalid_CodeRange = 138,
	Err_Execution_Too_Long = 139,
	Err_Too_Many_Function_Defs = 140,
	Err_Too_Many_Instruction_Defs = 141,
	Err_Table_Missing = 142,
	Err_Horiz_Header_Missing = 143,
	Err_Locations_Missing = 144,
	Err_Name_Table_Missing = 145,
	Err_CMap_Table_Missing = 146,
	Err_Hmtx_Table_Missing = 147,
	Err_Post_Table_Missing = 148,
	Err_Invalid_Horiz_Metrics = 149,
	Err_Invalid_CharMap_Format = 150,
	Err_Invalid_PPem = 151,
	Err_Invalid_Vert_Metrics = 152,
	Err_Could_Not_Find_Context = 153,
	Err_Invalid_Post_Table_Format = 154,
	Err_Invalid_Post_Table = 155,
	Err_Syntax_Error = 160,
	Err_Stack_Underflow = 161,
	Err_Ignore = 162,
	Err_No_Unicode_Glyph_Name = 163,
	Err_Glyph_Too_Big = 164,
	Err_Missing_Startfont_Field = 176,
	Err_Missing_Font_Field = 177,
	Err_Missing_Size_Field = 178,
	Err_Missing_Fontboundingbox_Field = 179,
	Err_Missing_Chars_Field = 180,
	Err_Missing_Startchar_Field = 181,
	Err_Missing_Encoding_Field = 182,
	Err_Missing_Bbx_Field = 183,
	Err_Bbx_Too_Big = 184,
	Err_Corrupted_Font_Header = 185,
	Err_Corrupted_Font_Glyphs = 186,
	Err_Max = 187,
}
local error_code_to_str = {
	[0] = "ok",
	[1] = "cannot open resource",
	[2] = "unknown file format",
	[3] = "invalid file format",
	[4] = "invalid version",
	[5] = "lower module version",
	[6] = "invalid argument",
	[7] = "unimplemented feature",
	[8] = "invalid table",
	[9] = "invalid offset",
	[10] = "array too large",
	[11] = "missing module",
	[12] = "missing property",
	[16] = "invalid glyph index",
	[17] = "invalid character code",
	[18] = "invalid glyph format",
	[19] = "cannot render glyph",
	[20] = "invalid outline",
	[21] = "invalid composite",
	[22] = "too many hints",
	[23] = "invalid pixel size",
	[32] = "invalid handle",
	[33] = "invalid library handle",
	[34] = "invalid driver handle",
	[35] = "invalid face handle",
	[36] = "invalid size handle",
	[37] = "invalid slot handle",
	[38] = "invalid charmap handle",
	[39] = "invalid cache handle",
	[40] = "invalid stream handle",
	[48] = "too many drivers",
	[49] = "too many extensions",
	[64] = "out of memory",
	[65] = "unlisted object",
	[81] = "cannot open stream",
	[82] = "invalid stream seek",
	[83] = "invalid stream skip",
	[84] = "invalid stream read",
	[85] = "invalid stream operation",
	[86] = "invalid frame operation",
	[87] = "nested frame access",
	[88] = "invalid frame read",
	[96] = "raster uninitialized",
	[97] = "raster corrupted",
	[98] = "raster overflow",
	[99] = "raster negative height",
	[112] = "too many caches",
	[128] = "invalid opcode",
	[129] = "too few arguments",
	[130] = "stack overflow",
	[131] = "code overflow",
	[132] = "bad argument",
	[133] = "divide by zero",
	[134] = "invalid reference",
	[135] = "debug opcode",
	[136] = "endf in exec stream",
	[137] = "nested defs",
	[138] = "invalid coderange",
	[139] = "execution too long",
	[140] = "too many function defs",
	[141] = "too many instruction defs",
	[142] = "table missing",
	[143] = "horiz header missing",
	[144] = "locations missing",
	[145] = "name table missing",
	[146] = "cmap table missing",
	[147] = "hmtx table missing",
	[148] = "post table missing",
	[149] = "invalid horiz metrics",
	[150] = "invalid charmap format",
	[151] = "invalid ppem",
	[152] = "invalid vert metrics",
	[153] = "could not find context",
	[154] = "invalid post table format",
	[155] = "invalid post table",
	[160] = "syntax error",
	[161] = "stack underflow",
	[162] = "ignore",
	[163] = "no unicode glyph name",
	[164] = "glyph too big",
	[176] = "missing startfont field",
	[177] = "missing font field",
	[178] = "missing size field",
	[179] = "missing fontboundingbox field",
	[180] = "missing chars field",
	[181] = "missing startchar field",
	[182] = "missing encoding field",
	[183] = "missing bbx field",
	[184] = "bbx too big",
	[185] = "corrupted font header",
	[186] = "corrupted font glyphs",
	[187] = "max",
}
function library.ErrorCodeToString(code) return error_code_to_str[code] end
library.clib = CLIB
return library
