local ffi = require("ffi")
local header = [[
typedef enum ILenum {
	IL_FALSE = 0,
	IL_TRUE = 1,

	//  Matches OpenGL's right now.
	//! Data formats \link Formats Formats\endlink
	IL_COLOUR_INDEX = 0x1900,
	IL_COLOR_INDEX = 0x1900,
	IL_ALPHA = 0x1906,
	IL_RGB = 0x1907,
	IL_RGBA = 0x1908,
	IL_BGR = 0x80E0,
	IL_BGRA = 0x80E1,
	IL_LUMINANCE = 0x1909,
	IL_LUMINANCE_ALPHA = 0x190A,

	//! Data types \link Types Types\endlink
	IL_BYTE = 0x1400,
	IL_UNSIGNED_BYTE = 0x1401,
	IL_SHORT = 0x1402,
	IL_UNSIGNED_SHORT = 0x1403,
	IL_INT = 0x1404,
	IL_UNSIGNED_INT = 0x1405,
	IL_FLOAT = 0x1406,
	IL_DOUBLE = 0x140A,
	IL_HALF = 0x140B,


	/*IL_MAX_BYTE = SCHAR_MAX,
	IL_MAX_UNSIGNED_BYTE = UCHAR_MAX,
	IL_MAX_SHORT = SHRT_MAX,
	IL_MAX_UNSIGNED_SHORT = USHRT_MAX,
	IL_MAX_INT = INT_MAX,
	IL_MAX_UNSIGNED_INT = UINT_MAX,*/

	//IL_LIMIT(x,m,M)		(x<m?m:(x>M?M:x))
	//IL_CLAMP(x) 		IL_LIMIT(x,0,1)

	IL_VENDOR = 0x1F00,
	IL_LOAD_EXT = 0x1F01,
	IL_SAVE_EXT = 0x1F02,


	//
	// IL-specific #define's
	//

	IL_VERSION_1_7_8 = 1,
	IL_VERSION = 178,


	// Attribute Bits
	IL_ORIGIN_BIT = 0x00000001,
	IL_FILE_BIT = 0x00000002,
	IL_PAL_BIT = 0x00000004,
	IL_FORMAT_BIT = 0x00000008,
	IL_TYPE_BIT = 0x00000010,
	IL_COMPRESS_BIT = 0x00000020,
	IL_LOADFAIL_BIT = 0x00000040,
	IL_FORMAT_SPECIFIC_BIT = 0x00000080,
	IL_ALL_ATTRIB_BITS = 0x000FFFFF,


	// Palette types
	IL_PAL_NONE = 0x0400,
	IL_PAL_RGB24 = 0x0401,
	IL_PAL_RGB32 = 0x0402,
	IL_PAL_RGBA32 = 0x0403,
	IL_PAL_BGR24 = 0x0404,
	IL_PAL_BGR32 = 0x0405,
	IL_PAL_BGRA32 = 0x0406,


	// Image types
	IL_TYPE_UNKNOWN = 0x0000,
	IL_BMP = 0x0420,  //!< Microsoft Windows Bitmap - .bmp extension
	IL_CUT = 0x0421,  //!< Dr. Halo - .cut extension
	IL_DOOM = 0x0422,  //!< DooM walls - no specific extension
	IL_DOOM_FLAT = 0x0423,  //!< DooM flats - no specific extension
	IL_ICO = 0x0424,  //!< Microsoft Windows Icons and Cursors - .ico and .cur extensions
	IL_JPG = 0x0425,  //!< JPEG - .jpg, .jpe and .jpeg extensions
	IL_JFIF = 0x0425,  //!<
	IL_ILBM = 0x0426,  //!< Amiga IFF (FORM ILBM) - .iff, .ilbm, .lbm extensions
	IL_PCD = 0x0427,  //!< Kodak PhotoCD - .pcd extension
	IL_PCX = 0x0428,  //!< ZSoft PCX - .pcx extension
	IL_PIC = 0x0429,  //!< PIC - .pic extension
	IL_PNG = 0x042A,  //!< Portable Network Graphics - .png extension
	IL_PNM = 0x042B,  //!< Portable Any Map - .pbm, .pgm, .ppm and .pnm extensions
	IL_SGI = 0x042C,  //!< Silicon Graphics - .sgi, .bw, .rgb and .rgba extensions
	IL_TGA = 0x042D,  //!< TrueVision Targa File - .tga, .vda, .icb and .vst extensions
	IL_TIF = 0x042E,  //!< Tagged Image File Format - .tif and .tiff extensions
	IL_CHEAD = 0x042F,  //!< C-Style Header - .h extension
	IL_RAW = 0x0430,  //!< Raw Image Data - any extension
	IL_MDL = 0x0431,  //!< Half-Life Model Texture - .mdl extension
	IL_WAL = 0x0432,  //!< Quake 2 Texture - .wal extension
	IL_LIF = 0x0434,  //!< Homeworld Texture - .lif extension
	IL_MNG = 0x0435,  //!< Multiple-image Network Graphics - .mng extension
	IL_JNG = 0x0435,  //!<
	IL_GIF = 0x0436,  //!< Graphics Interchange Format - .gif extension
	IL_DDS = 0x0437,  //!< DirectDraw Surface - .dds extension
	IL_DCX = 0x0438,  //!< ZSoft Multi-PCX - .dcx extension
	IL_PSD = 0x0439,  //!< Adobe PhotoShop - .psd extension
	IL_EXIF = 0x043A,  //!<
	IL_PSP = 0x043B,  //!< PaintShop Pro - .psp extension
	IL_PIX = 0x043C,  //!< PIX - .pix extension
	IL_PXR = 0x043D,  //!< Pixar - .pxr extension
	IL_XPM = 0x043E,  //!< X Pixel Map - .xpm extension
	IL_HDR = 0x043F,  //!< Radiance High Dynamic Range - .hdr extension
	IL_ICNS = 0x0440,  //!< Macintosh Icon - .icns extension
	IL_JP2 = 0x0441,  //!< Jpeg 2000 - .jp2 extension
	IL_EXR = 0x0442,  //!< OpenEXR - .exr extension
	IL_WDP = 0x0443,  //!< Microsoft HD Photo - .wdp and .hdp extension
	IL_VTF = 0x0444,  //!< Valve Texture Format - .vtf extension
	IL_WBMP = 0x0445,  //!< Wireless Bitmap - .wbmp extension
	IL_SUN = 0x0446,  //!< Sun Raster - .sun, .ras, .rs, .im1, .im8, .im24 and .im32 extensions
	IL_IFF = 0x0447,  //!< Interchange File Format - .iff extension
	IL_TPL = 0x0448,  //!< Gamecube Texture - .tpl extension
	IL_FITS = 0x0449,  //!< Flexible Image Transport System - .fit and .fits extensions
	IL_DICOM = 0x044A,  //!< Digital Imaging and Communications in Medicine (DICOM) - .dcm and .dicom extensions
	IL_IWI = 0x044B,  //!< Call of Duty Infinity Ward Image - .iwi extension
	IL_BLP = 0x044C,  //!< Blizzard Texture Format - .blp extension
	IL_FTX = 0x044D,  //!< Heavy Metal: FAKK2 Texture - .ftx extension
	IL_ROT = 0x044E,  //!< Homeworld 2 - Relic Texture - .rot extension
	IL_TEXTURE = 0x044F,  //!< Medieval II: Total War Texture - .texture extension
	IL_DPX = 0x0450,  //!< Digital Picture Exchange - .dpx extension
	IL_UTX = 0x0451,  //!< Unreal (and Unreal Tournament) Texture - .utx extension
	IL_MP3 = 0x0452,  //!< MPEG-1 Audio Layer 3 - .mp3 extension


	IL_JASC_PAL = 0x0475,  //!< PaintShop Pro Palette


	// Error Types
	IL_NO_ERROR = 0x0000,
	IL_INVALID_ENUM = 0x0501,
	IL_OUT_OF_MEMORY = 0x0502,
	IL_FORMAT_NOT_SUPPORTED = 0x0503,
	IL_INTERNAL_ERROR = 0x0504,
	IL_INVALID_VALUE = 0x0505,
	IL_ILLEGAL_OPERATION = 0x0506,
	IL_ILLEGAL_FILE_VALUE = 0x0507,
	IL_INVALID_FILE_HEADER = 0x0508,
	IL_INVALID_PARAM = 0x0509,
	IL_COULD_NOT_OPEN_FILE = 0x050A,
	IL_INVALID_EXTENSION = 0x050B,
	IL_FILE_ALREADY_EXISTS = 0x050C,
	IL_OUT_FORMAT_SAME = 0x050D,
	IL_STACK_OVERFLOW = 0x050E,
	IL_STACK_UNDERFLOW = 0x050F,
	IL_INVALID_CONVERSION = 0x0510,
	IL_BAD_DIMENSIONS = 0x0511,
	IL_FILE_READ_ERROR = 0x0512, // 05/12/2002: Addition by Sam.
	IL_FILE_WRITE_ERROR = 0x0512,

	IL_LIB_GIF_ERROR = 0x05E1,
	IL_LIB_JPEG_ERROR = 0x05E2,
	IL_LIB_PNG_ERROR = 0x05E3,
	IL_LIB_TIFF_ERROR = 0x05E4,
	IL_LIB_MNG_ERROR = 0x05E5,
	IL_LIB_JP2_ERROR = 0x05E6,
	IL_LIB_EXR_ERROR = 0x05E7,
	IL_UNKNOWN_ERROR = 0x05FF,


	// Origin Definitions
	IL_ORIGIN_SET = 0x0600,
	IL_ORIGIN_LOWER_LEFT = 0x0601,
	IL_ORIGIN_UPPER_LEFT = 0x0602,
	IL_ORIGIN_MODE = 0x0603,


	// Format and Type Mode Definitions
	IL_FORMAT_SET = 0x0610,
	IL_FORMAT_MODE = 0x0611,
	IL_TYPE_SET = 0x0612,
	IL_TYPE_MODE = 0x0613,


	// File definitions
	IL_FILE_OVERWRITE = 0x0620,
	IL_FILE_MODE = 0x0621,


	// Palette definitions
	IL_CONV_PAL = 0x0630,


	// Load fail definitions
	IL_DEFAULT_ON_FAIL = 0x0632,


	// Key colour and alpha definitions
	IL_USE_KEY_COLOUR = 0x0635,
	IL_USE_KEY_COLOR = 0x0635,
	IL_BLIT_BLEND = 0x0636,


	// Interlace definitions
	IL_SAVE_INTERLACED = 0x0639,
	IL_INTERLACE_MODE = 0x063A,


	// Quantization definitions
	IL_QUANTIZATION_MODE = 0x0640,
	IL_WU_QUANT = 0x0641,
	IL_NEU_QUANT = 0x0642,
	IL_NEU_QUANT_SAMPLE = 0x0643,
	IL_MAX_QUANT_INDEXS = 0x0644, //XIX : ILint : Maximum number of colors to reduce to, default of 256. and has a range of 2-256
	IL_MAX_QUANT_INDICES = 0x0644, // Redefined, since the above is misspelled


	// Hints
	IL_FASTEST = 0x0660,
	IL_LESS_MEM = 0x0661,
	IL_DONT_CARE = 0x0662,
	IL_MEM_SPEED_HINT = 0x0665,
	IL_USE_COMPRESSION = 0x0666,
	IL_NO_COMPRESSION = 0x0667,
	IL_COMPRESSION_HINT = 0x0668,


	// = Compression,
	IL_NVIDIA_COMPRESS = 0x0670,
	IL_SQUISH_COMPRESS = 0x0671,


	// Subimage types
	IL_SUB_NEXT = 0x0680,
	IL_SUB_MIPMAP = 0x0681,
	IL_SUB_LAYER = 0x0682,


	// Compression definitions
	IL_COMPRESS_MODE = 0x0700,
	IL_COMPRESS_NONE = 0x0701,
	IL_COMPRESS_RLE = 0x0702,
	IL_COMPRESS_LZO = 0x0703,
	IL_COMPRESS_ZLIB = 0x0704,


	// File format-specific values
	IL_TGA_CREATE_STAMP = 0x0710,
	IL_JPG_QUALITY = 0x0711,
	IL_PNG_INTERLACE = 0x0712,
	IL_TGA_RLE = 0x0713,
	IL_BMP_RLE = 0x0714,
	IL_SGI_RLE = 0x0715,
	IL_TGA_ID_STRING = 0x0717,
	IL_TGA_AUTHNAME_STRING = 0x0718,
	IL_TGA_AUTHCOMMENT_STRING = 0x0719,
	IL_PNG_AUTHNAME_STRING = 0x071A,
	IL_PNG_TITLE_STRING = 0x071B,
	IL_PNG_DESCRIPTION_STRING = 0x071C,
	IL_TIF_DESCRIPTION_STRING = 0x071D,
	IL_TIF_HOSTCOMPUTER_STRING = 0x071E,
	IL_TIF_DOCUMENTNAME_STRING = 0x071F,
	IL_TIF_AUTHNAME_STRING = 0x0720,
	IL_JPG_SAVE_FORMAT = 0x0721,
	IL_CHEAD_HEADER_STRING = 0x0722,
	IL_PCD_PICNUM = 0x0723,
	IL_PNG_ALPHA_INDEX = 0x0724, //XIX : ILint : the color in the palette at this index value (0-255) is considered transparent, -1 for no trasparent color
	IL_JPG_PROGRESSIVE = 0x0725,
	IL_VTF_COMP = 0x0726,


	// DXTC definitions
	IL_DXTC_FORMAT = 0x0705,
	IL_DXT1 = 0x0706,
	IL_DXT2 = 0x0707,
	IL_DXT3 = 0x0708,
	IL_DXT4 = 0x0709,
	IL_DXT5 = 0x070A,
	IL_DXT_NO_COMP = 0x070B,
	IL_KEEP_DXTC_DATA = 0x070C,
	IL_DXTC_DATA_FORMAT = 0x070D,
	IL_3DC = 0x070E,
	IL_RXGB = 0x070F,
	IL_ATI1N = 0x0710,
	IL_DXT1A = 0x0711,  // Normally the same as IL_DXT1, except for nVidia Texture Tools.

	// Environment map definitions
	IL_CUBEMAP_POSITIVEX = 0x00000400,
	IL_CUBEMAP_NEGATIVEX = 0x00000800,
	IL_CUBEMAP_POSITIVEY = 0x00001000,
	IL_CUBEMAP_NEGATIVEY = 0x00002000,
	IL_CUBEMAP_POSITIVEZ = 0x00004000,
	IL_CUBEMAP_NEGATIVEZ = 0x00008000,
	IL_SPHEREMAP = 0x00010000,


	// Values
	IL_VERSION_NUM = 0x0DE2,
	IL_IMAGE_WIDTH = 0x0DE4,
	IL_IMAGE_HEIGHT = 0x0DE5,
	IL_IMAGE_DEPTH = 0x0DE6,
	IL_IMAGE_SIZE_OF_DATA = 0x0DE7,
	IL_IMAGE_BPP = 0x0DE8,
	IL_IMAGE_BYTES_PER_PIXEL = 0x0DE8,
	IL_IMAGE_BITS_PER_PIXEL = 0x0DE9,
	IL_IMAGE_FORMAT = 0x0DEA,
	IL_IMAGE_TYPE = 0x0DEB,
	IL_PALETTE_TYPE = 0x0DEC,
	IL_PALETTE_SIZE = 0x0DED,
	IL_PALETTE_BPP = 0x0DEE,
	IL_PALETTE_NUM_COLS = 0x0DEF,
	IL_PALETTE_BASE_TYPE = 0x0DF0,
	IL_NUM_FACES = 0x0DE1,
	IL_NUM_IMAGES = 0x0DF1,
	IL_NUM_MIPMAPS = 0x0DF2,
	IL_NUM_LAYERS = 0x0DF3,
	IL_ACTIVE_IMAGE = 0x0DF4,
	IL_ACTIVE_MIPMAP = 0x0DF5,
	IL_ACTIVE_LAYER = 0x0DF6,
	IL_ACTIVE_FACE = 0x0E00,
	IL_CUR_IMAGE = 0x0DF7,
	IL_IMAGE_DURATION = 0x0DF8,
	IL_IMAGE_PLANESIZE = 0x0DF9,
	IL_IMAGE_BPC = 0x0DFA,
	IL_IMAGE_OFFX = 0x0DFB,
	IL_IMAGE_OFFY = 0x0DFC,
	IL_IMAGE_CUBEFLAGS = 0x0DFD,
	IL_IMAGE_ORIGIN = 0x0DFE,
	IL_IMAGE_CHANNELS = 0x0DFF,

	IL_SEEK_SET = 0,
	IL_SEEK_CUR = 1,
	IL_SEEK_END = 2,
	IL_EOF = -1
} ILenum;

typedef unsigned int   ILenum;
typedef unsigned char  ILboolean;
typedef unsigned int   ILbitfield;
typedef signed char    ILbyte;
typedef signed short   ILshort;
typedef int     	   ILint;
typedef size_t         ILsizei;
typedef unsigned char  ILubyte;
typedef unsigned short ILushort;
typedef unsigned int   ILuint;
typedef float          ILfloat;
typedef float          ILclampf;
typedef double         ILdouble;
typedef double         ILclampd;

typedef long long int          ILint64;
typedef long long unsigned int ILuint64;

//if we use a define instead of a typedef
//ILconst_string works as intended
typedef wchar_t ILchar;
typedef wchar_t* ILstring;
typedef wchar_t const * ILconst_string;

// Callback functions for file reading
typedef void* ILHANDLE;
typedef void      (*fCloseRProc)(ILHANDLE);
typedef ILboolean (*fEofProc)   (ILHANDLE);
typedef ILint     (*fGetcProc)  (ILHANDLE);
typedef ILHANDLE  (*fOpenRProc) (ILconst_string);
typedef ILint     (*fReadProc)  (void*, ILuint, ILuint, ILHANDLE);
typedef ILint     (*fSeekRProc) (ILHANDLE, ILint, ILint);
typedef ILint     (*fTellRProc) (ILHANDLE);

// Callback functions for file writing
typedef void     (*fCloseWProc)(ILHANDLE);
typedef ILHANDLE (*fOpenWProc) (ILconst_string);
typedef ILint    (*fPutcProc)  (ILubyte, ILHANDLE);
typedef ILint    (*fSeekWProc) (ILHANDLE, ILint, ILint);
typedef ILint    (*fTellWProc) (ILHANDLE);
typedef ILint    (*fWriteProc) (const void*, ILuint, ILuint, ILHANDLE);

// Callback functions for allocation and deallocation
typedef void* (*mAlloc)(const ILsizei);
typedef void  (*mFree) (const void* CONST_RESTRICT);

// Registered format procedures
typedef ILenum (*IL_LOADPROC)(ILconst_string);
typedef ILenum (*IL_SAVEPROC)(ILconst_string);

ILboolean ilActiveFace(ILuint Number);
ILboolean ilActiveImage(ILuint Number);
ILboolean ilActiveLayer(ILuint Number);
ILboolean ilActiveMipmap(ILuint Number);
ILboolean ilApplyPal(ILconst_string FileName);
ILboolean ilApplyProfile(ILstring InProfile, ILstring OutProfile);
void		ilBindImage(ILuint Image);
ILboolean ilBlit(ILuint Source, ILint DestX, ILint DestY, ILint DestZ, ILuint SrcX, ILuint SrcY, ILuint SrcZ, ILuint Width, ILuint Height, ILuint Depth);
ILboolean ilClampNTSC(void);
void		ilClearColour(ILclampf Red, ILclampf Green, ILclampf Blue, ILclampf Alpha);
ILboolean ilClearImage(void);
ILuint    ilCloneCurImage(void);
ILubyte*	ilCompressDXT(ILubyte *Data, ILuint Width, ILuint Height, ILuint Depth, ILenum DXTCFormat, ILuint *DXTCSize);
ILboolean ilCompressFunc(ILenum Mode);
ILboolean ilConvertImage(ILenum DestFormat, ILenum DestType);
ILboolean ilConvertPal(ILenum DestFormat);
ILboolean ilCopyImage(ILuint Src);
ILuint    ilCopyPixels(ILuint XOff, ILuint YOff, ILuint ZOff, ILuint Width, ILuint Height, ILuint Depth, ILenum Format, ILenum Type, void *Data);
ILuint    ilCreateSubImage(ILenum Type, ILuint Num);
ILboolean ilDefaultImage(void);
void		ilDeleteImage(const ILuint Num);
void      ilDeleteImages(ILsizei Num, const ILuint *Images);
ILenum	ilDetermineType(ILconst_string FileName);
ILenum	ilDetermineTypeF(ILHANDLE File);
ILenum	ilDetermineTypeL(const void *Lump, ILuint Size);
ILboolean ilDisable(ILenum Mode);
ILboolean ilDxtcDataToImage(void);
ILboolean ilDxtcDataToSurface(void);
ILboolean ilEnable(ILenum Mode);
void		ilFlipSurfaceDxtcData(void);
ILboolean ilFormatFunc(ILenum Mode);
void	    ilGenImages(ILsizei Num, ILuint *Images);
ILuint	ilGenImage(void);
ILubyte*  ilGetAlpha(ILenum Type);
ILboolean ilGetBoolean(ILenum Mode);
void      ilGetBooleanv(ILenum Mode, ILboolean *Param);
ILubyte*  ilGetData(void);
ILuint    ilGetDXTCData(void *Buffer, ILuint BufferSize, ILenum DXTCFormat);
ILenum    ilGetError(void);
ILint     ilGetInteger(ILenum Mode);
void      ilGetIntegerv(ILenum Mode, ILint *Param);
ILuint    ilGetLumpPos(void);
ILubyte*  ilGetPalette(void);
ILconst_string  ilGetString(ILenum StringName);
void      ilHint(ILenum Target, ILenum Mode);
ILboolean	ilInvertSurfaceDxtcDataAlpha(void);
void      ilInit(void);
ILboolean ilImageToDxtcData(ILenum Format);
ILboolean ilIsDisabled(ILenum Mode);
ILboolean ilIsEnabled(ILenum Mode);
ILboolean ilIsImage(ILuint Image);
ILboolean ilIsValid(ILenum Type, ILconst_string FileName);
ILboolean ilIsValidF(ILenum Type, ILHANDLE File);
ILboolean ilIsValidL(ILenum Type, void *Lump, ILuint Size);
void      ilKeyColour(ILclampf Red, ILclampf Green, ILclampf Blue, ILclampf Alpha);
ILboolean ilLoad(ILenum Type, ILconst_string FileName);
ILboolean ilLoadF(ILenum Type, ILHANDLE File);
ILboolean ilLoadImage(ILconst_string FileName);
ILboolean ilLoadL(ILenum Type, const void *Lump, ILuint Size);
ILboolean ilLoadPal(ILconst_string FileName);
void      ilModAlpha(ILdouble AlphaValue);
ILboolean ilOriginFunc(ILenum Mode);
ILboolean ilOverlayImage(ILuint Source, ILint XCoord, ILint YCoord, ILint ZCoord);
void      ilPopAttrib(void);
void      ilPushAttrib(ILuint Bits);
void      ilRegisterFormat(ILenum Format);
ILboolean ilRegisterLoad(ILconst_string Ext, IL_LOADPROC Load);
ILboolean ilRegisterMipNum(ILuint Num);
ILboolean ilRegisterNumFaces(ILuint Num);
ILboolean ilRegisterNumImages(ILuint Num);
void      ilRegisterOrigin(ILenum Origin);
void      ilRegisterPal(void *Pal, ILuint Size, ILenum Type);
ILboolean ilRegisterSave(ILconst_string Ext, IL_SAVEPROC Save);
void      ilRegisterType(ILenum Type);
ILboolean ilRemoveLoad(ILconst_string Ext);
ILboolean ilRemoveSave(ILconst_string Ext);
void      ilResetMemory(void); // Deprecated
void      ilResetRead(void);
void      ilResetWrite(void);
ILboolean ilSave(ILenum Type, ILconst_string FileName);
ILuint    ilSaveF(ILenum Type, ILHANDLE File);
ILboolean ilSaveImage(ILconst_string FileName);
ILuint    ilSaveL(ILenum Type, void *Lump, ILuint Size);
ILboolean ilSavePal(ILconst_string FileName);
ILboolean ilSetAlpha(ILdouble AlphaValue);
ILboolean ilSetData(void *Data);
ILboolean ilSetDuration(ILuint Duration);
void      ilSetInteger(ILenum Mode, ILint Param);
void      ilSetMemory(mAlloc, mFree);
void      ilSetPixels(ILint XOff, ILint YOff, ILint ZOff, ILuint Width, ILuint Height, ILuint Depth, ILenum Format, ILenum Type, void *Data);
void      ilSetRead(fOpenRProc, fCloseRProc, fEofProc, fGetcProc, fReadProc, fSeekRProc, fTellRProc);
void      ilSetString(ILenum Mode, const char *String);
void      ilSetWrite(fOpenWProc, fCloseWProc, fPutcProc, fSeekWProc, fTellWProc, fWriteProc);
void      ilShutDown(void);
ILboolean ilSurfaceToDxtcData(ILenum Format);
ILboolean ilTexImage(ILuint Width, ILuint Height, ILuint Depth, ILubyte NumChannels, ILenum Format, ILenum Type, void *Data);
ILboolean ilTexImageDxtc(ILint w, ILint h, ILint d, ILenum DxtFormat, const ILubyte* data);
ILenum    ilTypeFromExt(ILconst_string FileName);
ILboolean ilTypeFunc(ILenum Mode);
ILboolean ilLoadData(ILconst_string FileName, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
ILboolean ilLoadDataF(ILHANDLE File, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
ILboolean ilLoadDataL(void *Lump, ILuint Size, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
ILboolean ilSaveData(ILconst_string FileName);
]]

local error_to_string = {
	[0x0000] = "no error",
	[0x0501] = "invalid enum",
	[0x0502] = "out of memory",
	[0x0503] = "format not supported",
	[0x0504] = "internal error",
	[0x0505] = "invalid value",
	[0x0506] = "illegal operation",
	[0x0507] = "illegal file value",
	[0x0508] = "invalid file header",
	[0x0509] = "invalid param",
	[0x050a] = "could not open file",
	[0x050b] = "invalid extension",
	[0x050c] = "file already exists",
	[0x050d] = "out format same",
	[0x050e] = "stack overflow",
	[0x050f] = "stack underflow",
	[0x0510] = "invalid conversion",
	[0x0511] = "bad dimensions",
	[0x0512] = "file read error",
	[0x0512] = "file write error",
	[0x05e1] = "lib gif error",
	[0x05e2] = "lib jpeg error",
	[0x05e3] = "lib png error",
	[0x05e4] = "lib tiff error",
	[0x05e5] = "lib mng error",
	[0x05e6] = "lib jp2 error",
	[0x05e7] = "lib exr error",
	[0x05ff] = "unknown error",
}

local extensions = {
	type_unknown = 0x0000,
	bmp = 0x0420,
	cut = 0x0421,
	doom = 0x0422,
	doom_flat = 0x0423,
	ico = 0x0424,
	jpg = 0x0425,
	jfif = 0x0425,
	ilbm = 0x0426,
	pcd = 0x0427,
	pcx = 0x0428,
	pic = 0x0429,
	png = 0x042a,
	pnm = 0x042b,
	sgi = 0x042c,
	tga = 0x042d,
	tif = 0x042e,
	chead = 0x042f,
	raw = 0x0430,
	mdl = 0x0431,
	wal = 0x0432,
	lif = 0x0434,
	mng = 0x0435,
	jng = 0x0435,
	gif = 0x0436,
	dds = 0x0437,
	dcx = 0x0438,
	psd = 0x0439,
	exif = 0x043a,
	psp = 0x043b,
	pix = 0x043c,
	pxr = 0x043d,
	xpm = 0x043e,
	hdr = 0x043f,
	icns = 0x0440,
	jp2 = 0x0441,
	exr = 0x0442,
	wdp = 0x0443,
	vtf = 0x0444,
	wbmp = 0x0445,
	sun = 0x0446,
	iff = 0x0447,
	tpl = 0x0448,
	fits = 0x0449,
	dicom = 0x044a,
	iwi = 0x044b,
	blp = 0x044c,
	ftx = 0x044d,
	rot = 0x044e,
	texture = 0x044f,
	dpx = 0x0450,
	utx = 0x0451,
	mp3 = 0x0452,
	jasc_pal = 0x0475,
}

ffi.cdef(header)

local lib = assert(ffi.load(LINUX and "IL" or "devil"))
ffi.cdef("ILboolean iluFlipImage(void);")

local function check_error()
	local code = tonumber(lib.ilGetError())
	if code~= 0 then
		error(error_to_string[code] or "unknown error: " .. lib.ilGetError(), 2)
	end
end

local devil = {
	lib = lib,
}

function devil.LoadImage(data, path_hint)

	local info = {}

	local id = ffi.new("ILuint[1]")
	lib.ilGenImages(1, id)
	lib.ilBindImage(id[0])

	if lib.ilLoadL("IL_TYPE_UNKNOWN", ffi.cast("const unsigned char *const ", data), #data) == 0 then
		check_error()
		error("unknown format: ilLoadL(IL_TYPE_UNKNOWN, buffer, "..#data..") failed", 2)
	end

	if path_hint:endswith(".hdr") or path_hint:endswith(".exr") then
		lib.ilConvertImage("IL_BGRA", "IL_FLOAT")
		check_error()

		info.internal_format = "rgb16f"
	else
		lib.ilConvertImage("IL_BGRA", "IL_UNSIGNED_BYTE")
		check_error()
	end

	local size = lib.ilGetInteger("IL_IMAGE_SIZE_OF_DATA")
	local width = lib.ilGetInteger("IL_IMAGE_WIDTH")
	local height = lib.ilGetInteger("IL_IMAGE_HEIGHT")

	data = ffi.malloc("uint8_t", size)
	ffi.copy(data, lib.ilGetData(), size)

	check_error()

	lib.ilDeleteImages(1, id)

	check_error()

	return data, width, height, info
end

return devil