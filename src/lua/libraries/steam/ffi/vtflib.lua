local ffi = require("ffi")

local enums = {
	VTFLIB_DXT_QUALITY = 0,
	VTFLIB_LUMINANCE_WEIGHT_R = 1,
	VTFLIB_LUMINANCE_WEIGHT_G = 2,
	VTFLIB_LUMINANCE_WEIGHT_B = 3,
	VTFLIB_BLUESCREEN_MASK_R = 4,
	VTFLIB_BLUESCREEN_MASK_G = 5,
	VTFLIB_BLUESCREEN_MASK_B = 6,
	VTFLIB_BLUESCREEN_CLEAR_R = 7,
	VTFLIB_BLUESCREEN_CLEAR_G = 8,
	VTFLIB_BLUESCREEN_CLEAR_B = 9,
	VTFLIB_FP16_HDR_KEY = 10,
	VTFLIB_FP16_HDR_SHIFT = 11,
	VTFLIB_FP16_HDR_GAMMA = 12,
	VTFLIB_UNSHARPEN_RADIUS = 13,
	VTFLIB_UNSHARPEN_AMOUNT = 14,
	VTFLIB_UNSHARPEN_THRESHOLD = 15,
	VTFLIB_XSHARPEN_STRENGTH = 16,
	VTFLIB_XSHARPEN_THRESHOLD = 17,
	VTFLIB_VMT_PARSE_MODE = 18,
	IMAGE_FORMAT_RGBA8888 = 0,
	IMAGE_FORMAT_ABGR8888 = 1,
	IMAGE_FORMAT_RGB888 = 2,
	IMAGE_FORMAT_BGR888 = 3,
	IMAGE_FORMAT_RGB565 = 4,
	IMAGE_FORMAT_I8 = 5,
	IMAGE_FORMAT_IA88 = 6,
	IMAGE_FORMAT_P8 = 7,
	IMAGE_FORMAT_A8 = 8,
	IMAGE_FORMAT_RGB888_BLUESCREEN = 9,
	IMAGE_FORMAT_BGR888_BLUESCREEN = 10,
	IMAGE_FORMAT_ARGB8888 = 11,
	IMAGE_FORMAT_BGRA8888 = 12,
	IMAGE_FORMAT_DXT1 = 13,
	IMAGE_FORMAT_DXT3 = 14,
	IMAGE_FORMAT_DXT5 = 15,
	IMAGE_FORMAT_BGRX8888 = 16,
	IMAGE_FORMAT_BGR565 = 17,
	IMAGE_FORMAT_BGRX5551 = 18,
	IMAGE_FORMAT_BGRA4444 = 19,
	IMAGE_FORMAT_DXT1_ONEBITALPHA = 20,
	IMAGE_FORMAT_BGRA5551 = 21,
	IMAGE_FORMAT_UV88 = 22,
	IMAGE_FORMAT_UVWQ8888 = 23,
	IMAGE_FORMAT_RGBA16161616F = 24,
	IMAGE_FORMAT_RGBA16161616 = 25,
	IMAGE_FORMAT_UVLX8888 = 26,
	IMAGE_FORMAT_R32F = 27,
	IMAGE_FORMAT_RGB323232F = 28,
	IMAGE_FORMAT_RGBA32323232F = 29,
	IMAGE_FORMAT_NV_DST16 = 30,
	IMAGE_FORMAT_NV_DST24 = 31,
	IMAGE_FORMAT_NV_INTZ = 32,
	IMAGE_FORMAT_NV_RAWZ = 33,
	IMAGE_FORMAT_ATI_DST16 = 34,
	IMAGE_FORMAT_ATI_DST24 = 35,
	IMAGE_FORMAT_NV_NULL = 36,
	IMAGE_FORMAT_ATI2N = 37,
	IMAGE_FORMAT_ATI1N = 38,
	IMAGE_FORMAT_COUNT = 39,
	IMAGE_FORMAT_NONE = 40,
	TEXTUREFLAGS_POINTSAMPLE = 0x00000001,
	TEXTUREFLAGS_TRILINEAR = 0x00000002,
	TEXTUREFLAGS_CLAMPS = 0x00000004,
	TEXTUREFLAGS_CLAMPT = 0x00000008,
	TEXTUREFLAGS_ANISOTROPIC = 0x00000010,
	TEXTUREFLAGS_HINT_DXT5 = 0x00000020,
	TEXTUREFLAGS_SRGB = 0x00000040,
	TEXTUREFLAGS_DEPRECATED_NOCOMPRESS = 0x00000040,
	TEXTUREFLAGS_NORMAL = 0x00000080,
	TEXTUREFLAGS_NOMIP = 0x00000100,
	TEXTUREFLAGS_NOLOD = 0x00000200,
	TEXTUREFLAGS_MINMIP = 0x00000400,
	TEXTUREFLAGS_PROCEDURAL = 0x00000800,
	TEXTUREFLAGS_ONEBITALPHA = 0x00001000,
	TEXTUREFLAGS_EIGHTBITALPHA = 0x00002000,
	TEXTUREFLAGS_ENVMAP = 0x00004000,
	TEXTUREFLAGS_RENDERTARGET = 0x00008000,
	TEXTUREFLAGS_DEPTHRENDERTARGET = 0x00010000,
	TEXTUREFLAGS_NODEBUGOVERRIDE = 0x00020000,
	TEXTUREFLAGS_SINGLECOPY = 0x00040000,
	TEXTUREFLAGS_UNUSED0 = 0x00080000,
	TEXTUREFLAGS_DEPRECATED_ONEOVERMIPLEVELINALPHA = 0x00080000,
	TEXTUREFLAGS_UNUSED1 = 0x00100000,
	TEXTUREFLAGS_DEPRECATED_PREMULTCOLORBYONEOVERMIPLEVEL = 0x00100000,
	TEXTUREFLAGS_UNUSED2 = 0x00200000,
	TEXTUREFLAGS_DEPRECATED_NORMALTODUDV = 0x00200000,
	TEXTUREFLAGS_UNUSED3 = 0x00400000,
	TEXTUREFLAGS_DEPRECATED_ALPHATESTMIPGENERATION = 0x00400000,
	TEXTUREFLAGS_NODEPTHBUFFER = 0x00800000,
	TEXTUREFLAGS_UNUSED4 = 0x01000000,
	TEXTUREFLAGS_DEPRECATED_NICEFILTERED = 0x01000000,
	TEXTUREFLAGS_CLAMPU = 0x02000000,
	TEXTUREFLAGS_VERTEXTEXTURE = 0x04000000,
	TEXTUREFLAGS_SSBUMP = 0x08000000,
	TEXTUREFLAGS_UNUSED5 = 0x10000000,
	TEXTUREFLAGS_DEPRECATED_UNFILTERABLE_OK = 0x10000000,
	TEXTUREFLAGS_BORDER = 0x20000000,
	TEXTUREFLAGS_DEPRECATED_SPECVAR_RED = 0x40000000,
	TEXTUREFLAGS_DEPRECATED_SPECVAR_ALPHA = 0x80000000,
	TEXTUREFLAGS_LAST = 0x20000000,
	TEXTUREFLAGS_COUNT = 536870913,
	CUBEMAP_FACE_RIGHT = 0,
	CUBEMAP_FACE_LEFT = 1,
	CUBEMAP_FACE_BACK = 2,
	CUBEMAP_FACE_FRONT = 3,
	CUBEMAP_FACE_UP = 4,
	CUBEMAP_FACE_DOWN = 5,
	CUBEMAP_FACE_SPHERE_MAP = 6,
	CUBEMAP_FACE_COUNT = 7,
	MIPMAP_FILTER_POINT = 0,
	MIPMAP_FILTER_BOX = 1,
	MIPMAP_FILTER_TRIANGLE = 2,
	MIPMAP_FILTER_QUADRATIC = 3,
	MIPMAP_FILTER_CUBIC = 4,
	MIPMAP_FILTER_CATROM = 5,
	MIPMAP_FILTER_MITCHELL = 6,
	MIPMAP_FILTER_GAUSSIAN = 7,
	MIPMAP_FILTER_SINC = 8,
	MIPMAP_FILTER_BESSEL = 9,
	MIPMAP_FILTER_HANNING = 10,
	MIPMAP_FILTER_HAMMING = 11,
	MIPMAP_FILTER_BLACKMAN = 12,
	MIPMAP_FILTER_KAISER = 13,
	MIPMAP_FILTER_COUNT = 14,
	SHARPEN_FILTER_NONE = 0,
	SHARPEN_FILTER_NEGATIVE = 1,
	SHARPEN_FILTER_LIGHTER = 2,
	SHARPEN_FILTER_DARKER = 3,
	SHARPEN_FILTER_CONTRASTMORE = 4,
	SHARPEN_FILTER_CONTRASTLESS = 5,
	SHARPEN_FILTER_SMOOTHEN = 6,
	SHARPEN_FILTER_SHARPENSOFT = 7,
	SHARPEN_FILTER_SHARPENMEDIUM = 8,
	SHARPEN_FILTER_SHARPENSTRONG = 9,
	SHARPEN_FILTER_FINDEDGES = 10,
	SHARPEN_FILTER_CONTOUR = 11,
	SHARPEN_FILTER_EDGEDETECT = 12,
	SHARPEN_FILTER_EDGEDETECTSOFT = 13,
	SHARPEN_FILTER_EMBOSS = 14,
	SHARPEN_FILTER_MEANREMOVAL = 15,
	SHARPEN_FILTER_UNSHARP = 16,
	SHARPEN_FILTER_XSHARPEN = 17,
	SHARPEN_FILTER_WARPSHARP = 18,
	SHARPEN_FILTER_COUNT = 19,
	DXT_QUALITY_LOW = 0,
	DXT_QUALITY_MEDIUM = 1,
	DXT_QUALITY_HIGH = 2,
	DXT_QUALITY_HIGHEST = 3,
	DXT_QUALITY_COUNT = 4,
	KERNEL_FILTER_4X = 0,
	KERNEL_FILTER_3X3 = 1,
	KERNEL_FILTER_5X5 = 2,
	KERNEL_FILTER_7X7 = 3,
	KERNEL_FILTER_9X9 = 4,
	KERNEL_FILTER_DUDV = 5,
	KERNEL_FILTER_COUNT = 6,
	HEIGHT_CONVERSION_METHOD_ALPHA = 0,
	HEIGHT_CONVERSION_METHOD_AVERAGE_RGB = 1,
	HEIGHT_CONVERSION_METHOD_BIASED_RGB = 2,
	HEIGHT_CONVERSION_METHOD_RED = 3,
	HEIGHT_CONVERSION_METHOD_GREEN = 4,
	HEIGHT_CONVERSION_METHOD_BLUE = 5,
	HEIGHT_CONVERSION_METHOD_MAX_RGB = 6,
	HEIGHT_CONVERSION_METHOD_COLORSPACE = 7,
	HEIGHT_CONVERSION_METHOD_COUNT = 8,
	NORMAL_ALPHA_RESULT_NOCHANGE = 0,
	NORMAL_ALPHA_RESULT_HEIGHT = 1,
	NORMAL_ALPHA_RESULT_BLACK = 2,
	NORMAL_ALPHA_RESULT_WHITE = 3,
	NORMAL_ALPHA_RESULT_COUNT = 4,
	RESIZE_NEAREST_POWER2 = 0,
	RESIZE_BIGGEST_POWER2 = 1,
	RESIZE_SMALLEST_POWER2 = 2,
	RESIZE_SET = 3,
	RESIZE_COUNT = 4,
	RSRCF_HAS_NO_DATA_CHUNK = 5,
	 VTF_LEGACY_RSRC_LOW_RES_IMAGE = 1,
	VTF_LEGACY_RSRC_IMAGE = 48,
	VTF_RSRC_SHEET = 16,
	VTF_RSRC_CRC = 37966403,
	VTF_RSRC_TEXTURE_LOD_SETTINGS = 38031180,
	VTF_RSRC_TEXTURE_SETTINGS_EX = 38753108,
	VTF_RSRC_KEY_VALUE_DATA = 4478539,
	VTF_RSRC_MAX_DICTIONARY_ENTRIES = 32,
	PARSE_MODE_STRICT = 0,
	PARSE_MODE_LOOSE = 1,
	PARSE_MODE_COUNT = 2,
	NODE_TYPE_GROUP = 0,
	NODE_TYPE_GROUP_END = 1,
	NODE_TYPE_STRING = 2,
	NODE_TYPE_INTEGER = 3,
	NODE_TYPE_SINGLE = 4,
	NODE_TYPE_COUNT = 5,
}
local header = [[
typedef unsigned char vlBool;
typedef char vlChar;
typedef unsigned char vlByte;
typedef signed short vlShort;
typedef unsigned short vlUShort;
typedef signed int vlInt;
typedef unsigned int vlUInt;
typedef signed long vlLong;
typedef unsigned long vlULong;
typedef float vlSingle;
typedef double vlDouble;
typedef void vlVoid;
typedef vlSingle vlFloat;
typedef enum tagVTFLibOption
{
 VTFLIB_DXT_QUALITY = 0,
 VTFLIB_LUMINANCE_WEIGHT_R,
 VTFLIB_LUMINANCE_WEIGHT_G,
 VTFLIB_LUMINANCE_WEIGHT_B,
 VTFLIB_BLUESCREEN_MASK_R,
 VTFLIB_BLUESCREEN_MASK_G,
 VTFLIB_BLUESCREEN_MASK_B,
 VTFLIB_BLUESCREEN_CLEAR_R,
 VTFLIB_BLUESCREEN_CLEAR_G,
 VTFLIB_BLUESCREEN_CLEAR_B,
 VTFLIB_FP16_HDR_KEY,
 VTFLIB_FP16_HDR_SHIFT,
 VTFLIB_FP16_HDR_GAMMA,
 VTFLIB_UNSHARPEN_RADIUS,
 VTFLIB_UNSHARPEN_AMOUNT,
 VTFLIB_UNSHARPEN_THRESHOLD,
 VTFLIB_XSHARPEN_STRENGTH,
 VTFLIB_XSHARPEN_THRESHOLD,
 VTFLIB_VMT_PARSE_MODE
} VTFLibOption;
typedef enum tagVTFImageFormat
{
 IMAGE_FORMAT_RGBA8888 = 0,
 IMAGE_FORMAT_ABGR8888,
 IMAGE_FORMAT_RGB888,
 IMAGE_FORMAT_BGR888,
 IMAGE_FORMAT_RGB565,
 IMAGE_FORMAT_I8,
 IMAGE_FORMAT_IA88,
 IMAGE_FORMAT_P8,
 IMAGE_FORMAT_A8,
 IMAGE_FORMAT_RGB888_BLUESCREEN,
 IMAGE_FORMAT_BGR888_BLUESCREEN,
 IMAGE_FORMAT_ARGB8888,
 IMAGE_FORMAT_BGRA8888,
 IMAGE_FORMAT_DXT1,
 IMAGE_FORMAT_DXT3,
 IMAGE_FORMAT_DXT5,
 IMAGE_FORMAT_BGRX8888,
 IMAGE_FORMAT_BGR565,
 IMAGE_FORMAT_BGRX5551,
 IMAGE_FORMAT_BGRA4444,
 IMAGE_FORMAT_DXT1_ONEBITALPHA,
 IMAGE_FORMAT_BGRA5551,
 IMAGE_FORMAT_UV88,
 IMAGE_FORMAT_UVWQ8888,
 IMAGE_FORMAT_RGBA16161616F,
 IMAGE_FORMAT_RGBA16161616,
 IMAGE_FORMAT_UVLX8888,
 IMAGE_FORMAT_R32F,
 IMAGE_FORMAT_RGB323232F,
 IMAGE_FORMAT_RGBA32323232F,
 IMAGE_FORMAT_NV_DST16,
 IMAGE_FORMAT_NV_DST24,
 IMAGE_FORMAT_NV_INTZ,
 IMAGE_FORMAT_NV_RAWZ,
 IMAGE_FORMAT_ATI_DST16,
 IMAGE_FORMAT_ATI_DST24,
 IMAGE_FORMAT_NV_NULL,
 IMAGE_FORMAT_ATI2N,
 IMAGE_FORMAT_ATI1N,
 IMAGE_FORMAT_COUNT,
 IMAGE_FORMAT_NONE = -1
} VTFImageFormat;
typedef enum tagVTFImageFlag
{
 TEXTUREFLAGS_POINTSAMPLE = 0x00000001,
 TEXTUREFLAGS_TRILINEAR = 0x00000002,
 TEXTUREFLAGS_CLAMPS = 0x00000004,
 TEXTUREFLAGS_CLAMPT = 0x00000008,
 TEXTUREFLAGS_ANISOTROPIC = 0x00000010,
 TEXTUREFLAGS_HINT_DXT5 = 0x00000020,
 TEXTUREFLAGS_SRGB = 0x00000040,
 TEXTUREFLAGS_DEPRECATED_NOCOMPRESS = 0x00000040,
 TEXTUREFLAGS_NORMAL = 0x00000080,
 TEXTUREFLAGS_NOMIP = 0x00000100,
 TEXTUREFLAGS_NOLOD = 0x00000200,
 TEXTUREFLAGS_MINMIP = 0x00000400,
 TEXTUREFLAGS_PROCEDURAL = 0x00000800,
 TEXTUREFLAGS_ONEBITALPHA = 0x00001000,
 TEXTUREFLAGS_EIGHTBITALPHA = 0x00002000,
 TEXTUREFLAGS_ENVMAP = 0x00004000,
 TEXTUREFLAGS_RENDERTARGET = 0x00008000,
 TEXTUREFLAGS_DEPTHRENDERTARGET = 0x00010000,
 TEXTUREFLAGS_NODEBUGOVERRIDE = 0x00020000,
 TEXTUREFLAGS_SINGLECOPY = 0x00040000,
 TEXTUREFLAGS_UNUSED0 = 0x00080000,
 TEXTUREFLAGS_DEPRECATED_ONEOVERMIPLEVELINALPHA = 0x00080000,
 TEXTUREFLAGS_UNUSED1 = 0x00100000,
 TEXTUREFLAGS_DEPRECATED_PREMULTCOLORBYONEOVERMIPLEVEL = 0x00100000,
 TEXTUREFLAGS_UNUSED2 = 0x00200000,
 TEXTUREFLAGS_DEPRECATED_NORMALTODUDV = 0x00200000,
 TEXTUREFLAGS_UNUSED3 = 0x00400000,
 TEXTUREFLAGS_DEPRECATED_ALPHATESTMIPGENERATION = 0x00400000,
 TEXTUREFLAGS_NODEPTHBUFFER = 0x00800000,
 TEXTUREFLAGS_UNUSED4 = 0x01000000,
 TEXTUREFLAGS_DEPRECATED_NICEFILTERED = 0x01000000,
 TEXTUREFLAGS_CLAMPU = 0x02000000,
 TEXTUREFLAGS_VERTEXTEXTURE = 0x04000000,
 TEXTUREFLAGS_SSBUMP = 0x08000000,
 TEXTUREFLAGS_UNUSED5 = 0x10000000,
 TEXTUREFLAGS_DEPRECATED_UNFILTERABLE_OK = 0x10000000,
 TEXTUREFLAGS_BORDER = 0x20000000,
 TEXTUREFLAGS_DEPRECATED_SPECVAR_RED = 0x40000000,
 TEXTUREFLAGS_DEPRECATED_SPECVAR_ALPHA = 0x80000000,
 TEXTUREFLAGS_LAST = 0x20000000,
 TEXTUREFLAGS_COUNT = 30
} VTFImageFlag;
typedef enum tagVTFCubeMapFace
{
 CUBEMAP_FACE_RIGHT = 0,
 CUBEMAP_FACE_LEFT,
 CUBEMAP_FACE_BACK,
 CUBEMAP_FACE_FRONT,
 CUBEMAP_FACE_UP,
 CUBEMAP_FACE_DOWN,
 CUBEMAP_FACE_SPHERE_MAP,
 CUBEMAP_FACE_COUNT
} VTFCubeMapFace;
typedef enum tagVTFMipmapFilter
{
 MIPMAP_FILTER_POINT = 0,
 MIPMAP_FILTER_BOX,
 MIPMAP_FILTER_TRIANGLE,
 MIPMAP_FILTER_QUADRATIC,
 MIPMAP_FILTER_CUBIC,
 MIPMAP_FILTER_CATROM,
 MIPMAP_FILTER_MITCHELL,
 MIPMAP_FILTER_GAUSSIAN,
 MIPMAP_FILTER_SINC,
 MIPMAP_FILTER_BESSEL,
 MIPMAP_FILTER_HANNING,
 MIPMAP_FILTER_HAMMING,
 MIPMAP_FILTER_BLACKMAN,
 MIPMAP_FILTER_KAISER,
 MIPMAP_FILTER_COUNT
} VTFMipmapFilter;
typedef enum tagVTFSharpenFilter
{
 SHARPEN_FILTER_NONE = 0,
 SHARPEN_FILTER_NEGATIVE,
 SHARPEN_FILTER_LIGHTER,
 SHARPEN_FILTER_DARKER,
 SHARPEN_FILTER_CONTRASTMORE,
 SHARPEN_FILTER_CONTRASTLESS,
 SHARPEN_FILTER_SMOOTHEN,
 SHARPEN_FILTER_SHARPENSOFT,
 SHARPEN_FILTER_SHARPENMEDIUM,
 SHARPEN_FILTER_SHARPENSTRONG,
 SHARPEN_FILTER_FINDEDGES,
 SHARPEN_FILTER_CONTOUR,
 SHARPEN_FILTER_EDGEDETECT,
 SHARPEN_FILTER_EDGEDETECTSOFT,
 SHARPEN_FILTER_EMBOSS,
 SHARPEN_FILTER_MEANREMOVAL,
 SHARPEN_FILTER_UNSHARP,
 SHARPEN_FILTER_XSHARPEN,
 SHARPEN_FILTER_WARPSHARP,
 SHARPEN_FILTER_COUNT
} VTFSharpenFilter;
typedef enum tagDXTQuality
{
 DXT_QUALITY_LOW = 0,
 DXT_QUALITY_MEDIUM,
 DXT_QUALITY_HIGH,
 DXT_QUALITY_HIGHEST,
 DXT_QUALITY_COUNT
} VTFDXTQuality;
typedef enum tagVTFKernelFilter
{
 KERNEL_FILTER_4X = 0,
 KERNEL_FILTER_3X3,
 KERNEL_FILTER_5X5,
 KERNEL_FILTER_7X7,
 KERNEL_FILTER_9X9,
 KERNEL_FILTER_DUDV,
 KERNEL_FILTER_COUNT
} VTFKernelFilter;
typedef enum tagVTFHeightConversionMethod
{
 HEIGHT_CONVERSION_METHOD_ALPHA = 0,
 HEIGHT_CONVERSION_METHOD_AVERAGE_RGB,
 HEIGHT_CONVERSION_METHOD_BIASED_RGB,
 HEIGHT_CONVERSION_METHOD_RED,
 HEIGHT_CONVERSION_METHOD_GREEN,
 HEIGHT_CONVERSION_METHOD_BLUE,
 HEIGHT_CONVERSION_METHOD_MAX_RGB,
 HEIGHT_CONVERSION_METHOD_COLORSPACE,
 HEIGHT_CONVERSION_METHOD_COUNT
} VTFHeightConversionMethod;
typedef enum tagVTFNormalAlphaResult
{
 NORMAL_ALPHA_RESULT_NOCHANGE = 0,
 NORMAL_ALPHA_RESULT_HEIGHT,
 NORMAL_ALPHA_RESULT_BLACK,
 NORMAL_ALPHA_RESULT_WHITE,
 NORMAL_ALPHA_RESULT_COUNT
} VTFNormalAlphaResult;
typedef enum tagVTFResizeMethod
{
    RESIZE_NEAREST_POWER2 = 0,
    RESIZE_BIGGEST_POWER2,
    RESIZE_SMALLEST_POWER2,
    RESIZE_SET,
 RESIZE_COUNT
} VTFResizeMethod;
typedef enum tagVTFResourceEntryTypeFlag
{
 RSRCF_HAS_NO_DATA_CHUNK = 0x02
} VTFResourceEntryTypeFlag;
typedef enum tagVTFResourceEntryType
{
 VTF_LEGACY_RSRC_LOW_RES_IMAGE = 1,
 VTF_LEGACY_RSRC_IMAGE = 48,
 VTF_RSRC_SHEET = 16,
 VTF_RSRC_CRC = 37966403,
 VTF_RSRC_TEXTURE_LOD_SETTINGS = 38031180,
 VTF_RSRC_TEXTURE_SETTINGS_EX = 38753108,
 VTF_RSRC_KEY_VALUE_DATA = 4478539,
 VTF_RSRC_MAX_DICTIONARY_ENTRIES = 32
} VTFResourceEntryType;
typedef enum tagVMTParseMode
{
 PARSE_MODE_STRICT = 0,
 PARSE_MODE_LOOSE,
 PARSE_MODE_COUNT
} VMTParseMode;
typedef enum tagVMTNodeType
{
 NODE_TYPE_GROUP = 0,
 NODE_TYPE_GROUP_END,
 NODE_TYPE_STRING,
 NODE_TYPE_INTEGER,
 NODE_TYPE_SINGLE,
 NODE_TYPE_COUNT
} VMTNodeType;
#pragma pack(1)
typedef struct tagSVTFImageFormatInfo
{
 vlChar *lpName;
 vlUInt uiBitsPerPixel;
 vlUInt uiBytesPerPixel;
 vlUInt uiRedBitsPerPixel;
 vlUInt uiGreenBitsPerPixel;
 vlUInt uiBlueBitsPerPixel;
 vlUInt uiAlphaBitsPerPixel;
 vlBool bIsCompressed;
 vlBool bIsSupported;
} SVTFImageFormatInfo;
#pragma pack()
#pragma pack(1)
typedef struct tagSVTFCreateOptions
{
 vlUInt uiVersion[2];
 VTFImageFormat ImageFormat;
 vlUInt uiFlags;
 vlUInt uiStartFrame;
 vlSingle sBumpScale;
 vlSingle sReflectivity[3];
 vlBool bMipmaps;
 VTFMipmapFilter MipmapFilter;
 VTFSharpenFilter MipmapSharpenFilter;
 vlBool bThumbnail;
 vlBool bReflectivity;
 vlBool bResize;
 VTFResizeMethod ResizeMethod;
 VTFMipmapFilter ResizeFilter;
 VTFSharpenFilter ResizeSharpenFilter;
 vlUInt uiResizeWidth;
 vlUInt uiResizeHeight;
 vlBool bResizeClamp;
 vlUInt uiResizeClampWidth;
 vlUInt uiResizeClampHeight;
 vlBool bGammaCorrection;
 vlSingle sGammaCorrection;
 vlBool bNormalMap;
 VTFKernelFilter KernelFilter;
 VTFHeightConversionMethod HeightConversionMethod;
 VTFNormalAlphaResult NormalAlphaResult;
 vlByte bNormalMinimumZ;
 vlSingle sNormalScale;
 vlBool bNormalWrap;
 vlBool bNormalInvertX;
 vlBool bNormalInvertY;
 vlBool bNormalInvertZ;
 vlBool bSphereMap;
} SVTFCreateOptions;
typedef struct tagSVTFTextureLODControlResource
{
 vlByte ResolutionClampU;
 vlByte ResolutionClampV;
 vlByte Padding[2];
} SVTFTextureLODControlResource;
#pragma pack()
typedef enum tagVLProc
{
 PROC_READ_CLOSE = 0,
 PROC_READ_OPEN,
 PROC_READ_READ,
 PROC_READ_SEEK,
 PROC_READ_TELL,
 PROC_READ_SIZE,
 PROC_WRITE_CLOSE,
 PROC_WRITE_OPEN,
 PROC_WRITE_WRITE,
 PROC_WRITE_SEEK,
 PROC_WRITE_SIZE,
 PROC_WRITE_TELL,
 PROC_COUNT
} VLProc;
typedef enum tagVLSeekMode
{
 SEEK_MODE_BEGIN = 0,
 SEEK_MODE_CURRENT,
 SEEK_MODE_END
} VLSeekMode;
typedef vlVoid (*PReadCloseProc)(vlVoid *);
typedef vlBool (*PReadOpenProc)(vlVoid *);
typedef vlUInt (*PReadReadProc)(vlVoid *, vlUInt, vlVoid *);
typedef vlUInt (*PReadSeekProc)(vlLong, VLSeekMode, vlVoid *);
typedef vlUInt (*PReadSizeProc)(vlVoid *);
typedef vlUInt (*PReadTellProc)(vlVoid *);
typedef vlVoid (*PWriteCloseProc)(vlVoid *);
typedef vlBool (*PWriteOpenProc)(vlVoid *);
typedef vlUInt (*PWriteWriteProc)(vlVoid *, vlUInt, vlVoid *);
typedef vlUInt (*PWriteSeekProc)(vlLong, VLSeekMode, vlVoid *);
typedef vlUInt (*PWriteSizeProc)(vlVoid *);
typedef vlUInt (*PWriteTellProc)(vlVoid *);
vlUInt vlGetVersion();
const vlChar *vlGetVersionString();
const vlChar *vlGetLastError();
vlBool vlInitialize();
vlVoid vlShutdown();
vlBool vlGetBoolean(VTFLibOption Option);
vlVoid vlSetBoolean(VTFLibOption Option, vlBool bValue);
vlInt vlGetInteger(VTFLibOption Option);
vlVoid vlSetInteger(VTFLibOption Option, vlInt iValue);
vlSingle vlGetFloat(VTFLibOption Option);
vlVoid vlSetFloat(VTFLibOption Option, vlSingle sValue);
vlVoid vlSetProc(VLProc Proc, vlVoid *pProc);
vlVoid *vlGetProc(VLProc Proc);
vlBool vlImageIsBound();
vlBool vlBindImage(vlUInt uiImage);
vlBool vlCreateImage(vlUInt *uiImage);
vlVoid vlDeleteImage(vlUInt uiImage);
vlVoid vlImageCreateDefaultCreateStructure(SVTFCreateOptions *VTFCreateOptions);
vlBool vlImageCreate(vlUInt uiWidth, vlUInt uiHeight, vlUInt uiFrames, vlUInt uiFaces, vlUInt uiSlices, VTFImageFormat ImageFormat, vlBool bThumbnail, vlBool bMipmaps, vlBool bNullImageData);
vlBool vlImageCreateSingle(vlUInt uiWidth, vlUInt uiHeight, vlByte *lpImageDataRGBA8888, SVTFCreateOptions *VTFCreateOptions);
vlBool vlImageCreateMultiple(vlUInt uiWidth, vlUInt uiHeight, vlUInt uiFrames, vlUInt uiFaces, vlUInt uiSlices, vlByte **lpImageDataRGBA8888, SVTFCreateOptions *VTFCreateOptions);
vlVoid vlImageDestroy();
vlBool vlImageIsLoaded();
vlBool vlImageLoad(const vlChar *cFileName, vlBool bHeaderOnly);
vlBool vlImageLoadLump(const vlVoid *lpData, vlUInt uiBufferSize, vlBool bHeaderOnly);
vlBool vlImageLoadProc(vlVoid *pUserData, vlBool bHeaderOnly);
vlBool vlImageSave(const vlChar *cFileName);
vlBool vlImageSaveLump(vlVoid *lpData, vlUInt uiBufferSize, vlUInt *uiSize);
vlBool vlImageSaveProc(vlVoid *pUserData);
vlUInt vlImageGetHasImage();
vlUInt vlImageGetMajorVersion();
vlUInt vlImageGetMinorVersion();
vlUInt vlImageGetSize();
vlUInt vlImageGetWidth();
vlUInt vlImageGetHeight();
vlUInt vlImageGetDepth();
vlUInt vlImageGetFrameCount();
vlUInt vlImageGetFaceCount();
vlUInt vlImageGetMipmapCount();
vlUInt vlImageGetStartFrame();
vlVoid vlImageSetStartFrame(vlUInt uiStartFrame);
vlUInt vlImageGetFlags();
vlVoid vlImageSetFlags(vlUInt uiFlags);
vlBool vlImageGetFlag(VTFImageFlag ImageFlag);
vlVoid vlImageSetFlag(VTFImageFlag ImageFlag, vlBool bState);
vlSingle vlImageGetBumpmapScale();
vlVoid vlImageSetBumpmapScale(vlSingle sBumpmapScale);
vlVoid vlImageGetReflectivity(vlSingle *sX, vlSingle *sY, vlSingle *sZ);
vlVoid vlImageSetReflectivity(vlSingle sX, vlSingle sY, vlSingle sZ);
VTFImageFormat vlImageGetFormat();
vlByte *vlImageGetData(vlUInt uiFrame, vlUInt uiFace, vlUInt uiSlice, vlUInt uiMipmapLevel);
vlVoid vlImageSetData(vlUInt uiFrame, vlUInt uiFace, vlUInt uiSlice, vlUInt uiMipmapLevel, vlByte *lpData);
vlBool vlImageGetHasThumbnail();
vlUInt vlImageGetThumbnailWidth();
vlUInt vlImageGetThumbnailHeight();
VTFImageFormat vlImageGetThumbnailFormat();
vlByte *vlImageGetThumbnailData();
vlVoid vlImageSetThumbnailData(vlByte *lpData);
vlBool vlImageGetSupportsResources();
vlUInt vlImageGetResourceCount();
vlUInt vlImageGetResourceType(vlUInt uiIndex);
vlBool vlImageGetHasResource(vlUInt uiType);
vlVoid *vlImageGetResourceData(vlUInt uiType, vlUInt *uiSize);
vlVoid *vlImageSetResourceData(vlUInt uiType, vlUInt uiSize, vlVoid *lpData);
vlBool vlImageGenerateMipmaps(vlUInt uiFace, vlUInt uiFrame, VTFMipmapFilter MipmapFilter, VTFSharpenFilter SharpenFilter);
vlBool vlImageGenerateAllMipmaps(VTFMipmapFilter MipmapFilter, VTFSharpenFilter SharpenFilter);
vlBool vlImageGenerateThumbnail();
vlBool vlImageGenerateNormalMap(vlUInt uiFrame, VTFKernelFilter KernelFilter, VTFHeightConversionMethod HeightConversionMethod, VTFNormalAlphaResult NormalAlphaResult);
vlBool vlImageGenerateAllNormalMaps(VTFKernelFilter KernelFilter, VTFHeightConversionMethod HeightConversionMethod, VTFNormalAlphaResult NormalAlphaResult);
vlBool vlImageGenerateSphereMap();
vlBool vlImageComputeReflectivity();
SVTFImageFormatInfo const *vlImageGetImageFormatInfo(VTFImageFormat ImageFormat);
vlBool vlImageGetImageFormatInfoEx(VTFImageFormat ImageFormat, SVTFImageFormatInfo *VTFImageFormatInfo);
vlUInt vlImageComputeImageSize(vlUInt uiWidth, vlUInt uiHeight, vlUInt uiDepth, vlUInt uiMipmaps, VTFImageFormat ImageFormat);
vlUInt vlImageComputeMipmapCount(vlUInt uiWidth, vlUInt uiHeight, vlUInt uiDepth);
vlVoid vlImageComputeMipmapDimensions(vlUInt uiWidth, vlUInt uiHeight, vlUInt uiDepth, vlUInt uiMipmapLevel, vlUInt *uiMipmapWidth, vlUInt *uiMipmapHeight, vlUInt *uiMipmapDepth);
vlUInt vlImageComputeMipmapSize(vlUInt uiWidth, vlUInt uiHeight, vlUInt uiDepth, vlUInt uiMipmapLevel, VTFImageFormat ImageFormat);
vlBool vlImageConvertToRGBA8888(vlByte *lpSource, vlByte *lpDest, vlUInt uiWidth, vlUInt uiHeight, VTFImageFormat SourceFormat);
vlBool vlImageConvertFromRGBA8888(vlByte *lpSource, vlByte *lpDest, vlUInt uiWidth, vlUInt uiHeight, VTFImageFormat DestFormat);
vlBool vlImageConvert(vlByte *lpSource, vlByte *lpDest, vlUInt uiWidth, vlUInt uiHeight, VTFImageFormat SourceFormat, VTFImageFormat DestFormat);
vlBool vlImageConvertToNormalMap(vlByte *lpSourceRGBA8888, vlByte *lpDestRGBA8888, vlUInt uiWidth, vlUInt uiHeight, VTFKernelFilter KernelFilter, VTFHeightConversionMethod HeightConversionMethod, VTFNormalAlphaResult NormalAlphaResult, vlByte bMinimumZ, vlSingle sScale, vlBool bWrap, vlBool bInvertX, vlBool bInvertY);
vlBool vlImageResize(vlByte *lpSourceRGBA8888, vlByte *lpDestRGBA8888, vlUInt uiSourceWidth, vlUInt uiSourceHeight, vlUInt uiDestWidth, vlUInt uiDestHeight, VTFMipmapFilter ResizeFilter, VTFSharpenFilter SharpenFilter);
vlVoid vlImageCorrectImageGamma(vlByte *lpImageDataRGBA8888, vlUInt uiWidth, vlUInt uiHeight, vlSingle sGammaCorrection);
vlVoid vlImageComputeImageReflectivity(vlByte *lpImageDataRGBA8888, vlUInt uiWidth, vlUInt uiHeight, vlSingle *sX, vlSingle *sY, vlSingle *sZ);
vlVoid vlImageFlipImage(vlByte *lpImageDataRGBA8888, vlUInt uiWidth, vlUInt uiHeight);
vlVoid vlImageMirrorImage(vlByte *lpImageDataRGBA8888, vlUInt uiWidth, vlUInt uiHeight);
vlBool vlMaterialIsBound();
vlBool vlBindMaterial(vlUInt uiMaterial);
vlBool vlCreateMaterial(vlUInt *uiMaterial);
vlVoid vlDeleteMaterial(vlUInt uiMaterial);
vlBool vlMaterialCreate(const vlChar *cRoot);
vlVoid vlMaterialDestroy();
vlBool vlMaterialIsLoaded();
vlBool vlMaterialLoad(const vlChar *cFileName);
vlBool vlMaterialLoadLump(const vlVoid *lpData, vlUInt uiBufferSize);
vlBool vlMaterialLoadProc(vlVoid *pUserData);
vlBool vlMaterialSave(const vlChar *cFileName);
vlBool vlMaterialSaveLump(vlVoid *lpData, vlUInt uiBufferSize, vlUInt *uiSize);
vlBool vlMaterialSaveProc(vlVoid *pUserData);
vlBool vlMaterialGetFirstNode();
vlBool vlMaterialGetLastNode();
vlBool vlMaterialGetNextNode();
vlBool vlMaterialGetPreviousNode();
vlBool vlMaterialGetParentNode();
vlBool vlMaterialGetChildNode(const vlChar *cName);
const vlChar *vlMaterialGetNodeName();
vlVoid vlMaterialSetNodeName(const vlChar *cName);
VMTNodeType vlMaterialGetNodeType();
const vlChar *vlMaterialGetNodeString();
vlVoid vlMaterialSetNodeString(const vlChar *cValue);
vlUInt vlMaterialGetNodeInteger();
vlVoid vlMaterialSetNodeInteger(vlUInt iValue);
vlFloat vlMaterialGetNodeSingle();
vlVoid vlMaterialSetNodeSingle(vlFloat sValue);
vlVoid vlMaterialAddNodeGroup(const vlChar *cName);
vlVoid vlMaterialAddNodeString(const vlChar *cName, const vlChar *cValue);
vlVoid vlMaterialAddNodeInteger(const vlChar *cName, vlUInt iValue);
vlVoid vlMaterialAddNodeSingle(const vlChar *cName, vlFloat sValue);

]]

ffi.cdef(header)

local lib = assert(ffi.load("VTFLib"))

local vl = {
	lib = lib,
	e = enums,
	header = header,
	debug = true,
}

-- put all the functions in the glfw table
for line in header:gmatch("(.-)\n") do
	local name = line:match("[vV][lT]%u.-vl(.-)%(")

	if name and not line:find("typedef") then
		local func = lib["vl" .. name]
		vl[name] = function(...)
			local val = func(...)

			if vl.debug and name ~= "GetLastError" then
				local str = vl.GetLastError()
				str = ffi.string(str)
				if str ~= "" and  str ~= vl.last_error then
					vl.last_error = str
					error("HLLib " .. str, 2)
				end
			end

			return val
		end
	end
end

do
	local reverse_enums = {}

	for k,v in pairs(enums) do
		local nice = k:lower():sub(6)
		reverse_enums[v] = nice
	end

	function vl.EnumToString(num)
		return reverse_enums[num] or num
	end
end

function vl.LoadImage(data, format)
	local uiVTFImage = ffi.new("unsigned int[1]")
	vl.CreateImage(uiVTFImage)
	vl.BindImage(uiVTFImage[0])

	local uiVMTMaterial = ffi.new("unsigned int[1]")

	vl.CreateMaterial(uiVMTMaterial)
	vl.BindMaterial(uiVMTMaterial[0])

	if vl.ImageLoadLump(ffi.cast("void *", data), #data, 0) == 0 then
		return nil, "unknown format"
	end


	if not format then
		if vl.ImageGetFormat() == enums.IMAGE_FORMAT_DXT1 then
			format = enums.IMAGE_FORMAT_RGB888
		else
			format = enums.IMAGE_FORMAT_RGBA8888
		end
	end

	local w, h = vl.ImageGetWidth(), vl.ImageGetHeight()
	local size = vl.ImageComputeImageSize(w, h, 1, 1, format)
	local buffer = ffi.new("vlByte[?]", size)

	vl.ImageConvert(vl.ImageGetData(0, 0, 0, 0), buffer, w, h, vl.ImageGetFormat(), format)

	return buffer, w, h, format
end

vl.Initialize()

return vl