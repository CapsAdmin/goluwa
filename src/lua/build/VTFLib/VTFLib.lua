local ffi = require("ffi")
ffi.cdef([[enum{FP_NAN=0,FP_INFINITE=1,FP_ZERO=2,FP_SUBNORMAL=3,FP_NORMAL=4,};typedef enum tagVLSeekMode{SEEK_MODE_BEGIN=0,SEEK_MODE_CURRENT=1,SEEK_MODE_END=2};
typedef enum tagVTFImageFormat{IMAGE_FORMAT_RGBA8888=0,IMAGE_FORMAT_ABGR8888=1,IMAGE_FORMAT_RGB888=2,IMAGE_FORMAT_BGR888=3,IMAGE_FORMAT_RGB565=4,IMAGE_FORMAT_I8=5,IMAGE_FORMAT_IA88=6,IMAGE_FORMAT_P8=7,IMAGE_FORMAT_A8=8,IMAGE_FORMAT_RGB888_BLUESCREEN=9,IMAGE_FORMAT_BGR888_BLUESCREEN=10,IMAGE_FORMAT_ARGB8888=11,IMAGE_FORMAT_BGRA8888=12,IMAGE_FORMAT_DXT1=13,IMAGE_FORMAT_DXT3=14,IMAGE_FORMAT_DXT5=15,IMAGE_FORMAT_BGRX8888=16,IMAGE_FORMAT_BGR565=17,IMAGE_FORMAT_BGRX5551=18,IMAGE_FORMAT_BGRA4444=19,IMAGE_FORMAT_DXT1_ONEBITALPHA=20,IMAGE_FORMAT_BGRA5551=21,IMAGE_FORMAT_UV88=22,IMAGE_FORMAT_UVWQ8888=23,IMAGE_FORMAT_RGBA16161616F=24,IMAGE_FORMAT_RGBA16161616=25,IMAGE_FORMAT_UVLX8888=26,IMAGE_FORMAT_R32F=27,IMAGE_FORMAT_RGB323232F=28,IMAGE_FORMAT_RGBA32323232F=29,IMAGE_FORMAT_NV_DST16=30,IMAGE_FORMAT_NV_DST24=31,IMAGE_FORMAT_NV_INTZ=32,IMAGE_FORMAT_NV_RAWZ=33,IMAGE_FORMAT_ATI_DST16=34,IMAGE_FORMAT_ATI_DST24=35,IMAGE_FORMAT_NV_NULL=36,IMAGE_FORMAT_ATI2N=37,IMAGE_FORMAT_ATI1N=38,IMAGE_FORMAT_COUNT=39,IMAGE_FORMAT_NONE=-1};
typedef enum tagDXTQuality{DXT_QUALITY_LOW=0,DXT_QUALITY_MEDIUM=1,DXT_QUALITY_HIGH=2,DXT_QUALITY_HIGHEST=3,DXT_QUALITY_COUNT=4};
typedef enum tagVTFImageFlag{TEXTUREFLAGS_POINTSAMPLE=1,TEXTUREFLAGS_TRILINEAR=2,TEXTUREFLAGS_CLAMPS=4,TEXTUREFLAGS_CLAMPT=8,TEXTUREFLAGS_ANISOTROPIC=16,TEXTUREFLAGS_HINT_DXT5=32,TEXTUREFLAGS_SRGB=64,TEXTUREFLAGS_DEPRECATED_NOCOMPRESS=64,TEXTUREFLAGS_NORMAL=128,TEXTUREFLAGS_NOMIP=256,TEXTUREFLAGS_NOLOD=512,TEXTUREFLAGS_MINMIP=1024,TEXTUREFLAGS_PROCEDURAL=2048,TEXTUREFLAGS_ONEBITALPHA=4096,TEXTUREFLAGS_EIGHTBITALPHA=8192,TEXTUREFLAGS_ENVMAP=16384,TEXTUREFLAGS_RENDERTARGET=32768,TEXTUREFLAGS_DEPTHRENDERTARGET=65536,TEXTUREFLAGS_NODEBUGOVERRIDE=131072,TEXTUREFLAGS_SINGLECOPY=262144,TEXTUREFLAGS_UNUSED0=524288,TEXTUREFLAGS_DEPRECATED_ONEOVERMIPLEVELINALPHA=524288,TEXTUREFLAGS_UNUSED1=1048576,TEXTUREFLAGS_DEPRECATED_PREMULTCOLORBYONEOVERMIPLEVEL=1048576,TEXTUREFLAGS_UNUSED2=2097152,TEXTUREFLAGS_DEPRECATED_NORMALTODUDV=2097152,TEXTUREFLAGS_UNUSED3=4194304,TEXTUREFLAGS_DEPRECATED_ALPHATESTMIPGENERATION=4194304,TEXTUREFLAGS_NODEPTHBUFFER=8388608,TEXTUREFLAGS_UNUSED4=16777216,TEXTUREFLAGS_DEPRECATED_NICEFILTERED=16777216,TEXTUREFLAGS_CLAMPU=33554432,TEXTUREFLAGS_VERTEXTEXTURE=67108864,TEXTUREFLAGS_SSBUMP=134217728,TEXTUREFLAGS_UNUSED5=268435456,TEXTUREFLAGS_DEPRECATED_UNFILTERABLE_OK=268435456,TEXTUREFLAGS_BORDER=536870912,TEXTUREFLAGS_DEPRECATED_SPECVAR_RED=1073741824,TEXTUREFLAGS_DEPRECATED_SPECVAR_ALPHA=2147483648,TEXTUREFLAGS_LAST=536870912,TEXTUREFLAGS_COUNT=30};
typedef enum idtype_t{P_ALL=0,P_PID=1,P_PGID=2};
typedef enum _LIB_VERSION_TYPE{_IEEE_=-1,_SVID_=0,_XOPEN_=1,_POSIX_=2,_ISOC_=3};
typedef enum tagVTFLookDir{LOOK_DOWN_X=0,LOOK_DOWN_NEGX=1,LOOK_DOWN_Y=2,LOOK_DOWN_NEGY=3,LOOK_DOWN_Z=4,LOOK_DOWN_NEGZ=5};
typedef enum tagVTFCubeMapFace{CUBEMAP_FACE_RIGHT=0,CUBEMAP_FACE_LEFT=1,CUBEMAP_FACE_BACK=2,CUBEMAP_FACE_FRONT=3,CUBEMAP_FACE_UP=4,CUBEMAP_FACE_DOWN=5,CUBEMAP_FACE_SphereMap=6,CUBEMAP_FACE_COUNT=7};
typedef enum tagVTFLibOption{VTFLIB_DXT_QUALITY=0,VTFLIB_LUMINANCE_WEIGHT_R=1,VTFLIB_LUMINANCE_WEIGHT_G=2,VTFLIB_LUMINANCE_WEIGHT_B=3,VTFLIB_BLUESCREEN_MASK_R=4,VTFLIB_BLUESCREEN_MASK_G=5,VTFLIB_BLUESCREEN_MASK_B=6,VTFLIB_BLUESCREEN_CLEAR_R=7,VTFLIB_BLUESCREEN_CLEAR_G=8,VTFLIB_BLUESCREEN_CLEAR_B=9,VTFLIB_FP16_HDR_KEY=10,VTFLIB_FP16_HDR_SHIFT=11,VTFLIB_FP16_HDR_GAMMA=12,VTFLIB_UNSHARPEN_RADIUS=13,VTFLIB_UNSHARPEN_AMOUNT=14,VTFLIB_UNSHARPEN_THRESHOLD=15,VTFLIB_XSHARPEN_STRENGTH=16,VTFLIB_XSHARPEN_THRESHOLD=17,VTFLIB_VMT_PARSE_MODE=18};
typedef enum tagVTFResourceEntryTypeFlag{RSRCF_HAS_NO_DATA_CHUNK=2};
typedef enum tagVMTParseMode{PARSE_MODE_STRICT=0,PARSE_MODE_LOOSE=1,PARSE_MODE_COUNT=2};
typedef enum tagVTFSharpenFilter{SHARPEN_FILTER_NONE=0,SHARPEN_FILTER_NEGATIVE=1,SHARPEN_FILTER_LIGHTER=2,SHARPEN_FILTER_DARKER=3,SHARPEN_FILTER_CONTRASTMORE=4,SHARPEN_FILTER_CONTRASTLESS=5,SHARPEN_FILTER_SMOOTHEN=6,SHARPEN_FILTER_SHARPENSOFT=7,SHARPEN_FILTER_SHARPENMEDIUM=8,SHARPEN_FILTER_SHARPENSTRONG=9,SHARPEN_FILTER_FINDEDGES=10,SHARPEN_FILTER_CONTOUR=11,SHARPEN_FILTER_EDGEDETECT=12,SHARPEN_FILTER_EDGEDETECTSOFT=13,SHARPEN_FILTER_EMBOSS=14,SHARPEN_FILTER_MEANREMOVAL=15,SHARPEN_FILTER_UNSHARP=16,SHARPEN_FILTER_XSHARPEN=17,SHARPEN_FILTER_WARPSHARP=18,SHARPEN_FILTER_COUNT=19};
typedef enum __codecvt_result{__codecvt_ok=0,__codecvt_partial=1,__codecvt_error=2,__codecvt_noconv=3};
typedef enum tagVMTNodeType{NODE_TYPE_GROUP=0,NODE_TYPE_GROUP_END=1,NODE_TYPE_STRING=2,NODE_TYPE_INTEGER=3,NODE_TYPE_SINGLE=4,NODE_TYPE_COUNT=5};
typedef enum tagVTFKernelFilter{KERNEL_FILTER_4X=0,KERNEL_FILTER_3X3=1,KERNEL_FILTER_5X5=2,KERNEL_FILTER_7X7=3,KERNEL_FILTER_9X9=4,KERNEL_FILTER_DUDV=5,KERNEL_FILTER_COUNT=6};
typedef enum tagVTFResizeMethod{RESIZE_NEAREST_POWER2=0,RESIZE_BIGGEST_POWER2=1,RESIZE_SMALLEST_POWER2=2,RESIZE_SET=3,RESIZE_COUNT=4};
typedef enum tagVTFResourceEntryType{VTF_LEGACY_RSRC_LOW_RES_IMAGE=1,VTF_LEGACY_RSRC_IMAGE=48,VTF_RSRC_SHEET=16,VTF_RSRC_CRC=37966403,VTF_RSRC_TEXTURE_LOD_SETTINGS=38031180,VTF_RSRC_TEXTURE_SETTINGS_EX=38753108,VTF_RSRC_KEY_VALUE_DATA=4478539,VTF_RSRC_MAX_DICTIONARY_ENTRIES=32};
typedef enum tagVTFHeightConversionMethod{HEIGHT_CONVERSION_METHOD_ALPHA=0,HEIGHT_CONVERSION_METHOD_AVERAGE_RGB=1,HEIGHT_CONVERSION_METHOD_BIASED_RGB=2,HEIGHT_CONVERSION_METHOD_RED=3,HEIGHT_CONVERSION_METHOD_GREEN=4,HEIGHT_CONVERSION_METHOD_BLUE=5,HEIGHT_CONVERSION_METHOD_MAX_RGB=6,HEIGHT_CONVERSION_METHOD_COLORSPACE=7,HEIGHT_CONVERSION_METHOD_COUNT=8};
typedef enum tagVTFNormalAlphaResult{NORMAL_ALPHA_RESULT_NOCHANGE=0,NORMAL_ALPHA_RESULT_HEIGHT=1,NORMAL_ALPHA_RESULT_BLACK=2,NORMAL_ALPHA_RESULT_WHITE=3,NORMAL_ALPHA_RESULT_COUNT=4};
typedef enum tagVTFMipmapFilter{MIPMAP_FILTER_POINT=0,MIPMAP_FILTER_BOX=1,MIPMAP_FILTER_TRIANGLE=2,MIPMAP_FILTER_QUADRATIC=3,MIPMAP_FILTER_CUBIC=4,MIPMAP_FILTER_CATROM=5,MIPMAP_FILTER_MITCHELL=6,MIPMAP_FILTER_GAUSSIAN=7,MIPMAP_FILTER_SINC=8,MIPMAP_FILTER_BESSEL=9,MIPMAP_FILTER_HANNING=10,MIPMAP_FILTER_HAMMING=11,MIPMAP_FILTER_BLACKMAN=12,MIPMAP_FILTER_KAISER=13,MIPMAP_FILTER_COUNT=14};
struct tagSVTFImageFormatInfo {const char*lpName;unsigned int uiBitsPerPixel;unsigned int uiBytesPerPixel;unsigned int uiRedBitsPerPixel;unsigned int uiGreenBitsPerPixel;unsigned int uiBlueBitsPerPixel;unsigned int uiAlphaBitsPerPixel;unsigned char bIsCompressed;unsigned char bIsSupported;};
struct tagSVTFCreateOptions {unsigned int uiVersion[2];enum tagVTFImageFormat ImageFormat;unsigned int uiFlags;unsigned int uiStartFrame;float sBumpScale;float sReflectivity[3];unsigned char bMipmaps;enum tagVTFMipmapFilter MipmapFilter;enum tagVTFSharpenFilter MipmapSharpenFilter;unsigned char bThumbnail;unsigned char bReflectivity;unsigned char bResize;enum tagVTFResizeMethod ResizeMethod;enum tagVTFMipmapFilter ResizeFilter;enum tagVTFSharpenFilter ResizeSharpenFilter;unsigned int uiResizeWidth;unsigned int uiResizeHeight;unsigned char bResizeClamp;unsigned int uiResizeClampWidth;unsigned int uiResizeClampHeight;unsigned char bGammaCorrection;float sGammaCorrection;unsigned char bNormalMap;enum tagVTFKernelFilter KernelFilter;enum tagVTFHeightConversionMethod HeightConversionMethod;enum tagVTFNormalAlphaResult NormalAlphaResult;unsigned char bNormalMinimumZ;float sNormalScale;unsigned char bNormalWrap;unsigned char bNormalInvertX;unsigned char bNormalInvertY;unsigned char bNormalInvertZ;unsigned char bSphereMap;};
unsigned int(vlImageGetThumbnailHeight)();
unsigned char(vlImageLoadLump)(const void*,unsigned long,unsigned char);
void(vlMaterialAddNodeString)(const char*,const char*);
void*(vlImageGetResourceData)(unsigned int,unsigned int*);
unsigned int(vlMaterialGetNodeInteger)();
void(vlSetBoolean)(enum tagVTFLibOption,unsigned char);
unsigned char(vlImageGenerateThumbnail)();
void(vlDeleteMaterial)(unsigned int);
unsigned char(vlCreateMaterial)(unsigned int*);
unsigned char(vlInitialize)();
unsigned char(vlImageComputeReflectivity)();
unsigned char(vlMaterialSave)(const char*);
const struct tagSVTFImageFormatInfo*(vlImageGetImageFormatInfo)(enum tagVTFImageFormat);
unsigned char(vlMaterialCreate)(const char*);
void(vlImageSetFlags)(unsigned int);
unsigned char(vlImageConvertToNormalMap)(unsigned char*,unsigned char*,unsigned int,unsigned int,enum tagVTFKernelFilter,enum tagVTFHeightConversionMethod,enum tagVTFNormalAlphaResult,unsigned char,float,unsigned char,unsigned char,unsigned char);
unsigned int(vlImageGetDepth)();
unsigned char(vlCreateImage)(unsigned int*);
unsigned int(vlImageGetMinorVersion)();
unsigned char(vlMaterialGetFirstNode)();
void(vlMaterialSetNodeSingle)(float);
void(vlMaterialAddNodeInteger)(const char*,unsigned int);
void(vlImageComputeImageReflectivity)(unsigned char*,unsigned int,unsigned int,float*,float*,float*);
unsigned char(vlImageConvert)(unsigned char*,unsigned char*,unsigned int,unsigned int,enum tagVTFImageFormat,enum tagVTFImageFormat);
void(vlMaterialSetNodeString)(const char*);
void(vlMaterialSetNodeName)(const char*);
unsigned char(vlImageIsBound)();
unsigned char(vlImageGenerateAllNormalMaps)(enum tagVTFKernelFilter,enum tagVTFHeightConversionMethod,enum tagVTFNormalAlphaResult);
void(vlMaterialAddNodeSingle)(const char*,float);
void(vlMaterialAddNodeGroup)(const char*);
float(vlMaterialGetNodeSingle)();
void(vlMaterialSetNodeInteger)(unsigned int);
unsigned char*(vlImageGetData)(unsigned int,unsigned int,unsigned int,unsigned int);
const char*(vlMaterialGetNodeString)();
enum tagVMTNodeType(vlMaterialGetNodeType)();
const char*(vlMaterialGetNodeName)();
void(vlImageSetFlag)(enum tagVTFImageFlag,unsigned char);
unsigned char(vlMaterialGetChildNode)(const char*);
unsigned char(vlMaterialGetParentNode)();
unsigned char(vlMaterialGetPreviousNode)();
unsigned char(vlMaterialGetNextNode)();
unsigned char(vlMaterialGetLastNode)();
unsigned char(vlMaterialSaveProc)(void*);
unsigned char(vlMaterialSaveLump)(void*,unsigned long,unsigned long*);
const char*(vlGetLastError)();
unsigned char(vlMaterialIsLoaded)();
void(vlMaterialDestroy)();
unsigned char(vlBindMaterial)(unsigned int);
void(vlImageMirrorImage)(unsigned char*,unsigned int,unsigned int);
unsigned char(vlGetBoolean)(enum tagVTFLibOption);
void(vlImageCorrectImageGamma)(unsigned char*,unsigned int,unsigned int,float);
unsigned char(vlImageResize)(unsigned char*,unsigned char*,unsigned int,unsigned int,unsigned int,unsigned int,enum tagVTFMipmapFilter,enum tagVTFSharpenFilter);
unsigned char(vlImageConvertToRGBA8888)(unsigned char*,unsigned char*,unsigned int,unsigned int,enum tagVTFImageFormat);
unsigned int(vlImageComputeMipmapSize)(unsigned int,unsigned int,unsigned int,unsigned int,enum tagVTFImageFormat);
void(vlImageComputeMipmapDimensions)(unsigned int,unsigned int,unsigned int,unsigned int,unsigned int*,unsigned int*,unsigned int*);
unsigned int(vlImageComputeMipmapCount)(unsigned int,unsigned int,unsigned int);
unsigned int(vlImageComputeImageSize)(unsigned int,unsigned int,unsigned int,unsigned int,enum tagVTFImageFormat);
unsigned char(vlImageGetImageFormatInfoEx)(enum tagVTFImageFormat,struct tagSVTFImageFormatInfo*);
unsigned char(vlImageGenerateSphereMap)();
unsigned char(vlImageGenerateNormalMap)(unsigned int,enum tagVTFKernelFilter,enum tagVTFHeightConversionMethod,enum tagVTFNormalAlphaResult);
unsigned char(vlImageGenerateAllMipmaps)(enum tagVTFMipmapFilter,enum tagVTFSharpenFilter);
unsigned char(vlImageGenerateMipmaps)(unsigned int,unsigned int,enum tagVTFMipmapFilter,enum tagVTFSharpenFilter);
void*(vlImageSetResourceData)(unsigned int,unsigned int,void*);
unsigned char(vlImageGetHasResource)(unsigned int);
unsigned int(vlImageGetResourceCount)();
float(vlGetFloat)(enum tagVTFLibOption);
void(vlImageSetThumbnailData)(unsigned char*);
unsigned char*(vlImageGetThumbnailData)();
enum tagVTFImageFormat(vlImageGetThumbnailFormat)();
void(vlImageSetData)(unsigned int,unsigned int,unsigned int,unsigned int,unsigned char*);
enum tagVTFImageFormat(vlImageGetFormat)();
void(vlImageSetReflectivity)(float,float,float);
void(vlImageGetReflectivity)(float*,float*,float*);
void(vlImageSetBumpmapScale)(float);
float(vlImageGetBumpmapScale)();
unsigned char(vlImageGetFlag)(enum tagVTFImageFlag);
unsigned int(vlImageGetFlags)();
void(vlImageSetStartFrame)(unsigned int);
unsigned char(vlImageIsLoaded)();
unsigned int(vlImageGetMipmapCount)();
unsigned int(vlImageGetFaceCount)();
unsigned int(vlImageGetFrameCount)();
unsigned int(vlImageGetHeight)();
unsigned int(vlImageGetWidth)();
void(vlDeleteImage)(unsigned int);
unsigned int(vlImageGetSize)();
unsigned int(vlImageGetHasImage)();
unsigned char(vlImageSaveProc)(void*);
unsigned char(vlImageSaveLump)(void*,unsigned long,unsigned long*);
unsigned char(vlImageSave)(const char*);
unsigned char(vlImageLoadProc)(void*,unsigned char);
unsigned char(vlImageLoad)(const char*,unsigned char);
unsigned char(vlImageCreateSingle)(unsigned int,unsigned int,unsigned char*,struct tagSVTFCreateOptions*);
void(vlImageCreateDefaultCreateStructure)(struct tagSVTFCreateOptions*);
unsigned char(vlBindImage)(unsigned int);
void(vlSetFloat)(enum tagVTFLibOption,float);
void(vlSetInteger)(enum tagVTFLibOption,signed int);
signed int(vlGetInteger)(enum tagVTFLibOption);
void(vlShutdown)();
unsigned char(vlMaterialLoadLump)(const void*,unsigned long);
unsigned int(vlGetVersion)();
const char*(vlGetVersionString)();
unsigned int(vlImageGetStartFrame)();
unsigned char(vlMaterialIsBound)();
unsigned int(vlImageGetThumbnailWidth)();
unsigned char(vlMaterialLoad)(const char*);
unsigned char(vlImageCreate)(unsigned int,unsigned int,unsigned int,unsigned int,unsigned int,enum tagVTFImageFormat,unsigned char,unsigned char,unsigned char);
unsigned char(vlImageCreateMultiple)(unsigned int,unsigned int,unsigned int,unsigned int,unsigned int,unsigned char**,struct tagSVTFCreateOptions*);
unsigned char(vlMaterialLoadProc)(void*);
void(vlImageFlipImage)(unsigned char*,unsigned int,unsigned int);
unsigned int(vlImageGetMajorVersion)();
unsigned char(vlImageConvertFromRGBA8888)(unsigned char*,unsigned char*,unsigned int,unsigned int,enum tagVTFImageFormat);
unsigned int(vlImageGetResourceType)(unsigned int);
unsigned char(vlImageGetHasThumbnail)();
void(vlImageDestroy)();
unsigned char(vlImageGetSupportsResources)();
]])
local CLIB = ffi.load(_G.FFI_LIB or "VTFLib")
local library = {}
library = {
	ImageGetThumbnailHeight = CLIB.vlImageGetThumbnailHeight,
	ImageLoadLump = CLIB.vlImageLoadLump,
	MaterialAddNodeString = CLIB.vlMaterialAddNodeString,
	ImageGetResourceData = CLIB.vlImageGetResourceData,
	MaterialGetNodeInteger = CLIB.vlMaterialGetNodeInteger,
	SetBoolean = CLIB.vlSetBoolean,
	ImageGenerateThumbnail = CLIB.vlImageGenerateThumbnail,
	DeleteMaterial = CLIB.vlDeleteMaterial,
	CreateMaterial = CLIB.vlCreateMaterial,
	Initialize = CLIB.vlInitialize,
	ImageComputeReflectivity = CLIB.vlImageComputeReflectivity,
	MaterialSave = CLIB.vlMaterialSave,
	ImageGetImageFormatInfo = CLIB.vlImageGetImageFormatInfo,
	MaterialCreate = CLIB.vlMaterialCreate,
	ImageSetFlags = CLIB.vlImageSetFlags,
	ImageConvertToNormalMap = CLIB.vlImageConvertToNormalMap,
	ImageGetDepth = CLIB.vlImageGetDepth,
	CreateImage = CLIB.vlCreateImage,
	ImageGetMinorVersion = CLIB.vlImageGetMinorVersion,
	MaterialGetFirstNode = CLIB.vlMaterialGetFirstNode,
	MaterialSetNodeSingle = CLIB.vlMaterialSetNodeSingle,
	MaterialAddNodeInteger = CLIB.vlMaterialAddNodeInteger,
	ImageComputeImageReflectivity = CLIB.vlImageComputeImageReflectivity,
	ImageConvert = CLIB.vlImageConvert,
	MaterialSetNodeString = CLIB.vlMaterialSetNodeString,
	MaterialSetNodeName = CLIB.vlMaterialSetNodeName,
	ImageIsBound = CLIB.vlImageIsBound,
	ImageGenerateAllNormalMaps = CLIB.vlImageGenerateAllNormalMaps,
	MaterialAddNodeSingle = CLIB.vlMaterialAddNodeSingle,
	MaterialAddNodeGroup = CLIB.vlMaterialAddNodeGroup,
	MaterialGetNodeSingle = CLIB.vlMaterialGetNodeSingle,
	MaterialSetNodeInteger = CLIB.vlMaterialSetNodeInteger,
	ImageGetData = CLIB.vlImageGetData,
	MaterialGetNodeString = CLIB.vlMaterialGetNodeString,
	MaterialGetNodeType = CLIB.vlMaterialGetNodeType,
	MaterialGetNodeName = CLIB.vlMaterialGetNodeName,
	ImageSetFlag = CLIB.vlImageSetFlag,
	MaterialGetChildNode = CLIB.vlMaterialGetChildNode,
	MaterialGetParentNode = CLIB.vlMaterialGetParentNode,
	MaterialGetPreviousNode = CLIB.vlMaterialGetPreviousNode,
	MaterialGetNextNode = CLIB.vlMaterialGetNextNode,
	MaterialGetLastNode = CLIB.vlMaterialGetLastNode,
	MaterialSaveProc = CLIB.vlMaterialSaveProc,
	MaterialSaveLump = CLIB.vlMaterialSaveLump,
	GetLastError = CLIB.vlGetLastError,
	MaterialIsLoaded = CLIB.vlMaterialIsLoaded,
	MaterialDestroy = CLIB.vlMaterialDestroy,
	BindMaterial = CLIB.vlBindMaterial,
	ImageMirrorImage = CLIB.vlImageMirrorImage,
	GetBoolean = CLIB.vlGetBoolean,
	ImageCorrectImageGamma = CLIB.vlImageCorrectImageGamma,
	ImageResize = CLIB.vlImageResize,
	ImageConvertToRGBA8888 = CLIB.vlImageConvertToRGBA8888,
	ImageComputeMipmapSize = CLIB.vlImageComputeMipmapSize,
	ImageComputeMipmapDimensions = CLIB.vlImageComputeMipmapDimensions,
	ImageComputeMipmapCount = CLIB.vlImageComputeMipmapCount,
	ImageComputeImageSize = CLIB.vlImageComputeImageSize,
	ImageGetImageFormatInfoEx = CLIB.vlImageGetImageFormatInfoEx,
	ImageGenerateSphereMap = CLIB.vlImageGenerateSphereMap,
	ImageGenerateNormalMap = CLIB.vlImageGenerateNormalMap,
	ImageGenerateAllMipmaps = CLIB.vlImageGenerateAllMipmaps,
	ImageGenerateMipmaps = CLIB.vlImageGenerateMipmaps,
	ImageSetResourceData = CLIB.vlImageSetResourceData,
	ImageGetHasResource = CLIB.vlImageGetHasResource,
	ImageGetResourceCount = CLIB.vlImageGetResourceCount,
	GetFloat = CLIB.vlGetFloat,
	ImageSetThumbnailData = CLIB.vlImageSetThumbnailData,
	ImageGetThumbnailData = CLIB.vlImageGetThumbnailData,
	ImageGetThumbnailFormat = CLIB.vlImageGetThumbnailFormat,
	ImageSetData = CLIB.vlImageSetData,
	ImageGetFormat = CLIB.vlImageGetFormat,
	ImageSetReflectivity = CLIB.vlImageSetReflectivity,
	ImageGetReflectivity = CLIB.vlImageGetReflectivity,
	ImageSetBumpmapScale = CLIB.vlImageSetBumpmapScale,
	ImageGetBumpmapScale = CLIB.vlImageGetBumpmapScale,
	ImageGetFlag = CLIB.vlImageGetFlag,
	ImageGetFlags = CLIB.vlImageGetFlags,
	ImageSetStartFrame = CLIB.vlImageSetStartFrame,
	ImageIsLoaded = CLIB.vlImageIsLoaded,
	ImageGetMipmapCount = CLIB.vlImageGetMipmapCount,
	ImageGetFaceCount = CLIB.vlImageGetFaceCount,
	ImageGetFrameCount = CLIB.vlImageGetFrameCount,
	ImageGetHeight = CLIB.vlImageGetHeight,
	ImageGetWidth = CLIB.vlImageGetWidth,
	DeleteImage = CLIB.vlDeleteImage,
	ImageGetSize = CLIB.vlImageGetSize,
	ImageGetHasImage = CLIB.vlImageGetHasImage,
	ImageSaveProc = CLIB.vlImageSaveProc,
	ImageSaveLump = CLIB.vlImageSaveLump,
	ImageSave = CLIB.vlImageSave,
	ImageLoadProc = CLIB.vlImageLoadProc,
	ImageLoad = CLIB.vlImageLoad,
	ImageCreateSingle = CLIB.vlImageCreateSingle,
	ImageCreateDefaultCreateStructure = CLIB.vlImageCreateDefaultCreateStructure,
	BindImage = CLIB.vlBindImage,
	SetFloat = CLIB.vlSetFloat,
	SetInteger = CLIB.vlSetInteger,
	GetInteger = CLIB.vlGetInteger,
	Shutdown = CLIB.vlShutdown,
	MaterialLoadLump = CLIB.vlMaterialLoadLump,
	GetVersion = CLIB.vlGetVersion,
	GetVersionString = CLIB.vlGetVersionString,
	ImageGetStartFrame = CLIB.vlImageGetStartFrame,
	MaterialIsBound = CLIB.vlMaterialIsBound,
	ImageGetThumbnailWidth = CLIB.vlImageGetThumbnailWidth,
	MaterialLoad = CLIB.vlMaterialLoad,
	ImageCreate = CLIB.vlImageCreate,
	ImageCreateMultiple = CLIB.vlImageCreateMultiple,
	MaterialLoadProc = CLIB.vlMaterialLoadProc,
	ImageFlipImage = CLIB.vlImageFlipImage,
	ImageGetMajorVersion = CLIB.vlImageGetMajorVersion,
	ImageConvertFromRGBA8888 = CLIB.vlImageConvertFromRGBA8888,
	ImageGetResourceType = CLIB.vlImageGetResourceType,
	ImageGetHasThumbnail = CLIB.vlImageGetHasThumbnail,
	ImageDestroy = CLIB.vlImageDestroy,
	ImageGetSupportsResources = CLIB.vlImageGetSupportsResources,
}
library.e = {
	SEEK_MODE_BEGIN = ffi.cast("enum tagVLSeekMode", "SEEK_MODE_BEGIN"),
	SEEK_MODE_CURRENT = ffi.cast("enum tagVLSeekMode", "SEEK_MODE_CURRENT"),
	SEEK_MODE_END = ffi.cast("enum tagVLSeekMode", "SEEK_MODE_END"),
	IMAGE_FORMAT_RGBA8888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_RGBA8888"),
	IMAGE_FORMAT_ABGR8888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_ABGR8888"),
	IMAGE_FORMAT_RGB888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_RGB888"),
	IMAGE_FORMAT_BGR888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_BGR888"),
	IMAGE_FORMAT_RGB565 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_RGB565"),
	IMAGE_FORMAT_I8 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_I8"),
	IMAGE_FORMAT_IA88 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_IA88"),
	IMAGE_FORMAT_P8 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_P8"),
	IMAGE_FORMAT_A8 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_A8"),
	IMAGE_FORMAT_RGB888_BLUESCREEN = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_RGB888_BLUESCREEN"),
	IMAGE_FORMAT_BGR888_BLUESCREEN = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_BGR888_BLUESCREEN"),
	IMAGE_FORMAT_ARGB8888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_ARGB8888"),
	IMAGE_FORMAT_BGRA8888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_BGRA8888"),
	IMAGE_FORMAT_DXT1 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_DXT1"),
	IMAGE_FORMAT_DXT3 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_DXT3"),
	IMAGE_FORMAT_DXT5 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_DXT5"),
	IMAGE_FORMAT_BGRX8888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_BGRX8888"),
	IMAGE_FORMAT_BGR565 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_BGR565"),
	IMAGE_FORMAT_BGRX5551 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_BGRX5551"),
	IMAGE_FORMAT_BGRA4444 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_BGRA4444"),
	IMAGE_FORMAT_DXT1_ONEBITALPHA = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_DXT1_ONEBITALPHA"),
	IMAGE_FORMAT_BGRA5551 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_BGRA5551"),
	IMAGE_FORMAT_UV88 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_UV88"),
	IMAGE_FORMAT_UVWQ8888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_UVWQ8888"),
	IMAGE_FORMAT_RGBA16161616F = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_RGBA16161616F"),
	IMAGE_FORMAT_RGBA16161616 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_RGBA16161616"),
	IMAGE_FORMAT_UVLX8888 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_UVLX8888"),
	IMAGE_FORMAT_R32F = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_R32F"),
	IMAGE_FORMAT_RGB323232F = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_RGB323232F"),
	IMAGE_FORMAT_RGBA32323232F = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_RGBA32323232F"),
	IMAGE_FORMAT_NV_DST16 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_NV_DST16"),
	IMAGE_FORMAT_NV_DST24 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_NV_DST24"),
	IMAGE_FORMAT_NV_INTZ = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_NV_INTZ"),
	IMAGE_FORMAT_NV_RAWZ = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_NV_RAWZ"),
	IMAGE_FORMAT_ATI_DST16 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_ATI_DST16"),
	IMAGE_FORMAT_ATI_DST24 = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_ATI_DST24"),
	IMAGE_FORMAT_NV_NULL = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_NV_NULL"),
	IMAGE_FORMAT_ATI2N = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_ATI2N"),
	IMAGE_FORMAT_ATI1N = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_ATI1N"),
	IMAGE_FORMAT_COUNT = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_COUNT"),
	IMAGE_FORMAT_NONE = ffi.cast("enum tagVTFImageFormat", "IMAGE_FORMAT_NONE"),
	DXT_QUALITY_LOW = ffi.cast("enum tagDXTQuality", "DXT_QUALITY_LOW"),
	DXT_QUALITY_MEDIUM = ffi.cast("enum tagDXTQuality", "DXT_QUALITY_MEDIUM"),
	DXT_QUALITY_HIGH = ffi.cast("enum tagDXTQuality", "DXT_QUALITY_HIGH"),
	DXT_QUALITY_HIGHEST = ffi.cast("enum tagDXTQuality", "DXT_QUALITY_HIGHEST"),
	DXT_QUALITY_COUNT = ffi.cast("enum tagDXTQuality", "DXT_QUALITY_COUNT"),
	TEXTUREFLAGS_POINTSAMPLE = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_POINTSAMPLE"),
	TEXTUREFLAGS_TRILINEAR = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_TRILINEAR"),
	TEXTUREFLAGS_CLAMPS = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_CLAMPS"),
	TEXTUREFLAGS_CLAMPT = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_CLAMPT"),
	TEXTUREFLAGS_ANISOTROPIC = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_ANISOTROPIC"),
	TEXTUREFLAGS_HINT_DXT5 = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_HINT_DXT5"),
	TEXTUREFLAGS_SRGB = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_SRGB"),
	TEXTUREFLAGS_DEPRECATED_NOCOMPRESS = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_NOCOMPRESS"),
	TEXTUREFLAGS_NORMAL = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_NORMAL"),
	TEXTUREFLAGS_NOMIP = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_NOMIP"),
	TEXTUREFLAGS_NOLOD = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_NOLOD"),
	TEXTUREFLAGS_MINMIP = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_MINMIP"),
	TEXTUREFLAGS_PROCEDURAL = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_PROCEDURAL"),
	TEXTUREFLAGS_ONEBITALPHA = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_ONEBITALPHA"),
	TEXTUREFLAGS_EIGHTBITALPHA = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_EIGHTBITALPHA"),
	TEXTUREFLAGS_ENVMAP = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_ENVMAP"),
	TEXTUREFLAGS_RENDERTARGET = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_RENDERTARGET"),
	TEXTUREFLAGS_DEPTHRENDERTARGET = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPTHRENDERTARGET"),
	TEXTUREFLAGS_NODEBUGOVERRIDE = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_NODEBUGOVERRIDE"),
	TEXTUREFLAGS_SINGLECOPY = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_SINGLECOPY"),
	TEXTUREFLAGS_UNUSED0 = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_UNUSED0"),
	TEXTUREFLAGS_DEPRECATED_ONEOVERMIPLEVELINALPHA = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_ONEOVERMIPLEVELINALPHA"),
	TEXTUREFLAGS_UNUSED1 = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_UNUSED1"),
	TEXTUREFLAGS_DEPRECATED_PREMULTCOLORBYONEOVERMIPLEVEL = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_PREMULTCOLORBYONEOVERMIPLEVEL"),
	TEXTUREFLAGS_UNUSED2 = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_UNUSED2"),
	TEXTUREFLAGS_DEPRECATED_NORMALTODUDV = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_NORMALTODUDV"),
	TEXTUREFLAGS_UNUSED3 = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_UNUSED3"),
	TEXTUREFLAGS_DEPRECATED_ALPHATESTMIPGENERATION = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_ALPHATESTMIPGENERATION"),
	TEXTUREFLAGS_NODEPTHBUFFER = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_NODEPTHBUFFER"),
	TEXTUREFLAGS_UNUSED4 = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_UNUSED4"),
	TEXTUREFLAGS_DEPRECATED_NICEFILTERED = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_NICEFILTERED"),
	TEXTUREFLAGS_CLAMPU = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_CLAMPU"),
	TEXTUREFLAGS_VERTEXTEXTURE = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_VERTEXTEXTURE"),
	TEXTUREFLAGS_SSBUMP = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_SSBUMP"),
	TEXTUREFLAGS_UNUSED5 = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_UNUSED5"),
	TEXTUREFLAGS_DEPRECATED_UNFILTERABLE_OK = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_UNFILTERABLE_OK"),
	TEXTUREFLAGS_BORDER = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_BORDER"),
	TEXTUREFLAGS_DEPRECATED_SPECVAR_RED = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_SPECVAR_RED"),
	TEXTUREFLAGS_DEPRECATED_SPECVAR_ALPHA = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_DEPRECATED_SPECVAR_ALPHA"),
	TEXTUREFLAGS_LAST = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_LAST"),
	TEXTUREFLAGS_COUNT = ffi.cast("enum tagVTFImageFlag", "TEXTUREFLAGS_COUNT"),
	P_ALL = ffi.cast("enum idtype_t", "P_ALL"),
	P_PID = ffi.cast("enum idtype_t", "P_PID"),
	P_PGID = ffi.cast("enum idtype_t", "P_PGID"),
	_IEEE_ = ffi.cast("enum _LIB_VERSION_TYPE", "_IEEE_"),
	_SVID_ = ffi.cast("enum _LIB_VERSION_TYPE", "_SVID_"),
	_XOPEN_ = ffi.cast("enum _LIB_VERSION_TYPE", "_XOPEN_"),
	_POSIX_ = ffi.cast("enum _LIB_VERSION_TYPE", "_POSIX_"),
	_ISOC_ = ffi.cast("enum _LIB_VERSION_TYPE", "_ISOC_"),
	LOOK_DOWN_X = ffi.cast("enum tagVTFLookDir", "LOOK_DOWN_X"),
	LOOK_DOWN_NEGX = ffi.cast("enum tagVTFLookDir", "LOOK_DOWN_NEGX"),
	LOOK_DOWN_Y = ffi.cast("enum tagVTFLookDir", "LOOK_DOWN_Y"),
	LOOK_DOWN_NEGY = ffi.cast("enum tagVTFLookDir", "LOOK_DOWN_NEGY"),
	LOOK_DOWN_Z = ffi.cast("enum tagVTFLookDir", "LOOK_DOWN_Z"),
	LOOK_DOWN_NEGZ = ffi.cast("enum tagVTFLookDir", "LOOK_DOWN_NEGZ"),
	CUBEMAP_FACE_RIGHT = ffi.cast("enum tagVTFCubeMapFace", "CUBEMAP_FACE_RIGHT"),
	CUBEMAP_FACE_LEFT = ffi.cast("enum tagVTFCubeMapFace", "CUBEMAP_FACE_LEFT"),
	CUBEMAP_FACE_BACK = ffi.cast("enum tagVTFCubeMapFace", "CUBEMAP_FACE_BACK"),
	CUBEMAP_FACE_FRONT = ffi.cast("enum tagVTFCubeMapFace", "CUBEMAP_FACE_FRONT"),
	CUBEMAP_FACE_UP = ffi.cast("enum tagVTFCubeMapFace", "CUBEMAP_FACE_UP"),
	CUBEMAP_FACE_DOWN = ffi.cast("enum tagVTFCubeMapFace", "CUBEMAP_FACE_DOWN"),
	CUBEMAP_FACE_SphereMap = ffi.cast("enum tagVTFCubeMapFace", "CUBEMAP_FACE_SphereMap"),
	CUBEMAP_FACE_COUNT = ffi.cast("enum tagVTFCubeMapFace", "CUBEMAP_FACE_COUNT"),
	VTFLIB_DXT_QUALITY = ffi.cast("enum tagVTFLibOption", "VTFLIB_DXT_QUALITY"),
	VTFLIB_LUMINANCE_WEIGHT_R = ffi.cast("enum tagVTFLibOption", "VTFLIB_LUMINANCE_WEIGHT_R"),
	VTFLIB_LUMINANCE_WEIGHT_G = ffi.cast("enum tagVTFLibOption", "VTFLIB_LUMINANCE_WEIGHT_G"),
	VTFLIB_LUMINANCE_WEIGHT_B = ffi.cast("enum tagVTFLibOption", "VTFLIB_LUMINANCE_WEIGHT_B"),
	VTFLIB_BLUESCREEN_MASK_R = ffi.cast("enum tagVTFLibOption", "VTFLIB_BLUESCREEN_MASK_R"),
	VTFLIB_BLUESCREEN_MASK_G = ffi.cast("enum tagVTFLibOption", "VTFLIB_BLUESCREEN_MASK_G"),
	VTFLIB_BLUESCREEN_MASK_B = ffi.cast("enum tagVTFLibOption", "VTFLIB_BLUESCREEN_MASK_B"),
	VTFLIB_BLUESCREEN_CLEAR_R = ffi.cast("enum tagVTFLibOption", "VTFLIB_BLUESCREEN_CLEAR_R"),
	VTFLIB_BLUESCREEN_CLEAR_G = ffi.cast("enum tagVTFLibOption", "VTFLIB_BLUESCREEN_CLEAR_G"),
	VTFLIB_BLUESCREEN_CLEAR_B = ffi.cast("enum tagVTFLibOption", "VTFLIB_BLUESCREEN_CLEAR_B"),
	VTFLIB_FP16_HDR_KEY = ffi.cast("enum tagVTFLibOption", "VTFLIB_FP16_HDR_KEY"),
	VTFLIB_FP16_HDR_SHIFT = ffi.cast("enum tagVTFLibOption", "VTFLIB_FP16_HDR_SHIFT"),
	VTFLIB_FP16_HDR_GAMMA = ffi.cast("enum tagVTFLibOption", "VTFLIB_FP16_HDR_GAMMA"),
	VTFLIB_UNSHARPEN_RADIUS = ffi.cast("enum tagVTFLibOption", "VTFLIB_UNSHARPEN_RADIUS"),
	VTFLIB_UNSHARPEN_AMOUNT = ffi.cast("enum tagVTFLibOption", "VTFLIB_UNSHARPEN_AMOUNT"),
	VTFLIB_UNSHARPEN_THRESHOLD = ffi.cast("enum tagVTFLibOption", "VTFLIB_UNSHARPEN_THRESHOLD"),
	VTFLIB_XSHARPEN_STRENGTH = ffi.cast("enum tagVTFLibOption", "VTFLIB_XSHARPEN_STRENGTH"),
	VTFLIB_XSHARPEN_THRESHOLD = ffi.cast("enum tagVTFLibOption", "VTFLIB_XSHARPEN_THRESHOLD"),
	VTFLIB_VMT_PARSE_MODE = ffi.cast("enum tagVTFLibOption", "VTFLIB_VMT_PARSE_MODE"),
	RSRCF_HAS_NO_DATA_CHUNK = ffi.cast("enum tagVTFResourceEntryTypeFlag", "RSRCF_HAS_NO_DATA_CHUNK"),
	PARSE_MODE_STRICT = ffi.cast("enum tagVMTParseMode", "PARSE_MODE_STRICT"),
	PARSE_MODE_LOOSE = ffi.cast("enum tagVMTParseMode", "PARSE_MODE_LOOSE"),
	PARSE_MODE_COUNT = ffi.cast("enum tagVMTParseMode", "PARSE_MODE_COUNT"),
	SHARPEN_FILTER_NONE = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_NONE"),
	SHARPEN_FILTER_NEGATIVE = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_NEGATIVE"),
	SHARPEN_FILTER_LIGHTER = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_LIGHTER"),
	SHARPEN_FILTER_DARKER = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_DARKER"),
	SHARPEN_FILTER_CONTRASTMORE = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_CONTRASTMORE"),
	SHARPEN_FILTER_CONTRASTLESS = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_CONTRASTLESS"),
	SHARPEN_FILTER_SMOOTHEN = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_SMOOTHEN"),
	SHARPEN_FILTER_SHARPENSOFT = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_SHARPENSOFT"),
	SHARPEN_FILTER_SHARPENMEDIUM = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_SHARPENMEDIUM"),
	SHARPEN_FILTER_SHARPENSTRONG = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_SHARPENSTRONG"),
	SHARPEN_FILTER_FINDEDGES = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_FINDEDGES"),
	SHARPEN_FILTER_CONTOUR = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_CONTOUR"),
	SHARPEN_FILTER_EDGEDETECT = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_EDGEDETECT"),
	SHARPEN_FILTER_EDGEDETECTSOFT = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_EDGEDETECTSOFT"),
	SHARPEN_FILTER_EMBOSS = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_EMBOSS"),
	SHARPEN_FILTER_MEANREMOVAL = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_MEANREMOVAL"),
	SHARPEN_FILTER_UNSHARP = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_UNSHARP"),
	SHARPEN_FILTER_XSHARPEN = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_XSHARPEN"),
	SHARPEN_FILTER_WARPSHARP = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_WARPSHARP"),
	SHARPEN_FILTER_COUNT = ffi.cast("enum tagVTFSharpenFilter", "SHARPEN_FILTER_COUNT"),
	__codecvt_ok = ffi.cast("enum __codecvt_result", "__codecvt_ok"),
	__codecvt_partial = ffi.cast("enum __codecvt_result", "__codecvt_partial"),
	__codecvt_error = ffi.cast("enum __codecvt_result", "__codecvt_error"),
	__codecvt_noconv = ffi.cast("enum __codecvt_result", "__codecvt_noconv"),
	NODE_TYPE_GROUP = ffi.cast("enum tagVMTNodeType", "NODE_TYPE_GROUP"),
	NODE_TYPE_GROUP_END = ffi.cast("enum tagVMTNodeType", "NODE_TYPE_GROUP_END"),
	NODE_TYPE_STRING = ffi.cast("enum tagVMTNodeType", "NODE_TYPE_STRING"),
	NODE_TYPE_INTEGER = ffi.cast("enum tagVMTNodeType", "NODE_TYPE_INTEGER"),
	NODE_TYPE_SINGLE = ffi.cast("enum tagVMTNodeType", "NODE_TYPE_SINGLE"),
	NODE_TYPE_COUNT = ffi.cast("enum tagVMTNodeType", "NODE_TYPE_COUNT"),
	KERNEL_FILTER_4X = ffi.cast("enum tagVTFKernelFilter", "KERNEL_FILTER_4X"),
	KERNEL_FILTER_3X3 = ffi.cast("enum tagVTFKernelFilter", "KERNEL_FILTER_3X3"),
	KERNEL_FILTER_5X5 = ffi.cast("enum tagVTFKernelFilter", "KERNEL_FILTER_5X5"),
	KERNEL_FILTER_7X7 = ffi.cast("enum tagVTFKernelFilter", "KERNEL_FILTER_7X7"),
	KERNEL_FILTER_9X9 = ffi.cast("enum tagVTFKernelFilter", "KERNEL_FILTER_9X9"),
	KERNEL_FILTER_DUDV = ffi.cast("enum tagVTFKernelFilter", "KERNEL_FILTER_DUDV"),
	KERNEL_FILTER_COUNT = ffi.cast("enum tagVTFKernelFilter", "KERNEL_FILTER_COUNT"),
	RESIZE_NEAREST_POWER2 = ffi.cast("enum tagVTFResizeMethod", "RESIZE_NEAREST_POWER2"),
	RESIZE_BIGGEST_POWER2 = ffi.cast("enum tagVTFResizeMethod", "RESIZE_BIGGEST_POWER2"),
	RESIZE_SMALLEST_POWER2 = ffi.cast("enum tagVTFResizeMethod", "RESIZE_SMALLEST_POWER2"),
	RESIZE_SET = ffi.cast("enum tagVTFResizeMethod", "RESIZE_SET"),
	RESIZE_COUNT = ffi.cast("enum tagVTFResizeMethod", "RESIZE_COUNT"),
	VTF_LEGACY_RSRC_LOW_RES_IMAGE = ffi.cast("enum tagVTFResourceEntryType", "VTF_LEGACY_RSRC_LOW_RES_IMAGE"),
	VTF_LEGACY_RSRC_IMAGE = ffi.cast("enum tagVTFResourceEntryType", "VTF_LEGACY_RSRC_IMAGE"),
	VTF_RSRC_SHEET = ffi.cast("enum tagVTFResourceEntryType", "VTF_RSRC_SHEET"),
	VTF_RSRC_CRC = ffi.cast("enum tagVTFResourceEntryType", "VTF_RSRC_CRC"),
	VTF_RSRC_TEXTURE_LOD_SETTINGS = ffi.cast("enum tagVTFResourceEntryType", "VTF_RSRC_TEXTURE_LOD_SETTINGS"),
	VTF_RSRC_TEXTURE_SETTINGS_EX = ffi.cast("enum tagVTFResourceEntryType", "VTF_RSRC_TEXTURE_SETTINGS_EX"),
	VTF_RSRC_KEY_VALUE_DATA = ffi.cast("enum tagVTFResourceEntryType", "VTF_RSRC_KEY_VALUE_DATA"),
	VTF_RSRC_MAX_DICTIONARY_ENTRIES = ffi.cast("enum tagVTFResourceEntryType", "VTF_RSRC_MAX_DICTIONARY_ENTRIES"),
	HEIGHT_CONVERSION_METHOD_ALPHA = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_ALPHA"),
	HEIGHT_CONVERSION_METHOD_AVERAGE_RGB = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_AVERAGE_RGB"),
	HEIGHT_CONVERSION_METHOD_BIASED_RGB = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_BIASED_RGB"),
	HEIGHT_CONVERSION_METHOD_RED = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_RED"),
	HEIGHT_CONVERSION_METHOD_GREEN = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_GREEN"),
	HEIGHT_CONVERSION_METHOD_BLUE = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_BLUE"),
	HEIGHT_CONVERSION_METHOD_MAX_RGB = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_MAX_RGB"),
	HEIGHT_CONVERSION_METHOD_COLORSPACE = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_COLORSPACE"),
	HEIGHT_CONVERSION_METHOD_COUNT = ffi.cast("enum tagVTFHeightConversionMethod", "HEIGHT_CONVERSION_METHOD_COUNT"),
	NORMAL_ALPHA_RESULT_NOCHANGE = ffi.cast("enum tagVTFNormalAlphaResult", "NORMAL_ALPHA_RESULT_NOCHANGE"),
	NORMAL_ALPHA_RESULT_HEIGHT = ffi.cast("enum tagVTFNormalAlphaResult", "NORMAL_ALPHA_RESULT_HEIGHT"),
	NORMAL_ALPHA_RESULT_BLACK = ffi.cast("enum tagVTFNormalAlphaResult", "NORMAL_ALPHA_RESULT_BLACK"),
	NORMAL_ALPHA_RESULT_WHITE = ffi.cast("enum tagVTFNormalAlphaResult", "NORMAL_ALPHA_RESULT_WHITE"),
	NORMAL_ALPHA_RESULT_COUNT = ffi.cast("enum tagVTFNormalAlphaResult", "NORMAL_ALPHA_RESULT_COUNT"),
	MIPMAP_FILTER_POINT = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_POINT"),
	MIPMAP_FILTER_BOX = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_BOX"),
	MIPMAP_FILTER_TRIANGLE = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_TRIANGLE"),
	MIPMAP_FILTER_QUADRATIC = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_QUADRATIC"),
	MIPMAP_FILTER_CUBIC = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_CUBIC"),
	MIPMAP_FILTER_CATROM = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_CATROM"),
	MIPMAP_FILTER_MITCHELL = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_MITCHELL"),
	MIPMAP_FILTER_GAUSSIAN = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_GAUSSIAN"),
	MIPMAP_FILTER_SINC = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_SINC"),
	MIPMAP_FILTER_BESSEL = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_BESSEL"),
	MIPMAP_FILTER_HANNING = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_HANNING"),
	MIPMAP_FILTER_HAMMING = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_HAMMING"),
	MIPMAP_FILTER_BLACKMAN = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_BLACKMAN"),
	MIPMAP_FILTER_KAISER = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_KAISER"),
	MIPMAP_FILTER_COUNT = ffi.cast("enum tagVTFMipmapFilter", "MIPMAP_FILTER_COUNT"),
}

function library.LoadImage(data, format)
	local uiVTFImage = ffi.new("unsigned int[1]")
	library.CreateImage(uiVTFImage)
	library.BindImage(uiVTFImage[0])

	local mat = ffi.new("unsigned int[1]")
	library.CreateMaterial(mat)

	library.BindMaterial(mat[0])

	if library.ImageLoadLump(ffi.cast("void *", data), #data, 0) == 0 then
		return nil, "unknown format"
	end

	if not format then
		if library.ImageGetFormat() == library.e.IMAGE_FORMAT_DXT1 then
			format = library.e.IMAGE_FORMAT_RGB888
		else
			format = library.e.IMAGE_FORMAT_RGBA8888
		end
	end

	local w, h = library.ImageGetWidth(), library.ImageGetHeight()
	local size = library.ImageComputeImageSize(w, h, 1, 1, format)
	local buffer = ffi.new("uint8_t[?]", size)

	library.ImageConvert(library.ImageGetData(0, 0, 0, 0), buffer, w, h, library.ImageGetFormat(), format)

	return buffer, w, h, format
end
library.clib = CLIB
return library
