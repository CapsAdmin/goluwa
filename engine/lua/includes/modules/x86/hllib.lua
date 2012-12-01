if not hllib then
ffi.cdef[[typedef unsigned char		hlBool;
typedef char				hlChar;
typedef unsigned char		hlByte;
typedef signed short		hlShort;
typedef unsigned short		hlUShort;
typedef signed int			hlInt;
typedef unsigned int		hlUInt;
typedef signed long			hlLong;
typedef unsigned long		hlULong;
typedef signed long long	hlLongLong;
typedef unsigned long long	hlULongLong;
typedef float				hlSingle;
typedef double				hlDouble;
typedef void				hlVoid;

typedef unsigned __int8		hlUInt8;
typedef unsigned __int16	hlUInt16;
typedef unsigned __int32	hlUInt32;
typedef unsigned __int64	hlUInt64;

typedef hlSingle		hlFloat;

enum
{
	hlFalse = 0,
	hlTrue = 1,

	HL_VERSION_NUMBER = ((2 << 24) | (4 << 16) | (2 << 8) | 0),
	//HL_VERSION_STRING = "2.4.2",

	HL_ID_INVALID = 0xffffffff,

	HL_DEFAULT_PACKAGE_TEST_BUFFER_SIZE = 8,
	HL_DEFAULT_VIEW_SIZE = 131072,
	HL_DEFAULT_COPY_BUFFER_SIZE = 131072,
}

typedef enum
{
	HL_VERSION = 0,
	HL_ERROR,
	HL_ERROR_SYSTEM,
	HL_ERROR_SHORT_FORMATED,
	HL_ERROR_LONG_FORMATED,
	HL_PROC_OPEN,
	HL_PROC_CLOSE,
	HL_PROC_READ,
	HL_PROC_WRITE,
	HL_PROC_SEEK,
	HL_PROC_TELL,
	HL_PROC_SIZE,
	HL_PROC_EXTRACT_ITEM_START,
	HL_PROC_EXTRACT_ITEM_END,
	HL_PROC_EXTRACT_FILE_PROGRESS,
	HL_PROC_VALIDATE_FILE_PROGRESS,
	HL_OVERWRITE_FILES,
	HL_PACKAGE_BOUND,
	HL_PACKAGE_ID,
	HL_PACKAGE_SIZE,
	HL_PACKAGE_TOTAL_ALLOCATIONS,
	HL_PACKAGE_TOTAL_MEMORY_ALLOCATED,
	HL_PACKAGE_TOTAL_MEMORY_USED,
	HL_READ_ENCRYPTED,
	HL_FORCE_DEFRAGMENT,
	HL_PROC_DEFRAGMENT_PROGRESS,
	HL_PROC_DEFRAGMENT_PROGRESS_EX,
	HL_PROC_SEEK_EX,
	HL_PROC_TELL_EX,
	HL_PROC_SIZE_EX
} HLOption;

typedef enum
{
	HL_MODE_INVALID = 0x00,
	HL_MODE_READ = 0x01,
	HL_MODE_WRITE = 0x02,
	HL_MODE_CREATE = 0x04,
	HL_MODE_VOLATILE = 0x08,
	HL_MODE_NO_FILEMAPPING = 0x10,
	HL_MODE_QUICK_FILEMAPPING = 0x20
} HLFileMode;

typedef enum
{
	HL_SEEK_BEGINNING = 0,
	HL_SEEK_CURRENT,
	HL_SEEK_END
} HLSeekMode;

typedef enum
{
	HL_ITEM_NONE = 0,
	HL_ITEM_FOLDER,
	HL_ITEM_FILE
} HLDirectoryItemType;

typedef enum
{
	HL_ORDER_ASCENDING = 0,
	HL_ORDER_DESCENDING
} HLSortOrder;

typedef enum
{
	HL_FIELD_NAME = 0,
	HL_FIELD_SIZE
} HLSortField;

typedef enum
{
	HL_FIND_FILES = 0x01,
	HL_FIND_FOLDERS = 0x02,
	HL_FIND_NO_RECURSE = 0x04,
	HL_FIND_CASE_SENSITIVE = 0x08,
	HL_FIND_MODE_STRING = 0x10,
	HL_FIND_MODE_SUBSTRING = 0x20,
	HL_FIND_MODE_WILDCARD = 0x00,
	HL_FIND_ALL = HL_FIND_FILES | HL_FIND_FOLDERS
} HLFindType;

typedef enum
{
	HL_STREAM_NONE = 0,
	HL_STREAM_FILE,
	HL_STREAM_GCF,
	HL_STREAM_MAPPING,
	HL_STREAM_MEMORY,
	HL_STREAM_PROC,
	HL_STREAM_NULL
} HLStreamType;

typedef enum
{
	HL_MAPPING_NONE = 0,
	HL_MAPPING_FILE,
	HL_MAPPING_MEMORY,
	HL_MAPPING_STREAM
} HLMappingType;

typedef enum
{
	HL_PACKAGE_NONE = 0,
	HL_PACKAGE_BSP,
	HL_PACKAGE_GCF,
	HL_PACKAGE_PAK,
	HL_PACKAGE_VBSP,
	HL_PACKAGE_WAD,
	HL_PACKAGE_XZP,
	HL_PACKAGE_ZIP,
	HL_PACKAGE_NCF,
	HL_PACKAGE_VPK
} HLPackageType;

typedef enum
{
	HL_ATTRIBUTE_INVALID = 0,
	HL_ATTRIBUTE_BOOLEAN,
	HL_ATTRIBUTE_INTEGER,
	HL_ATTRIBUTE_UNSIGNED_INTEGER,
	HL_ATTRIBUTE_FLOAT,
	HL_ATTRIBUTE_STRING
} HLAttributeType;

typedef enum
{
	HL_BSP_PACKAGE_VERSION = 0,
	HL_BSP_PACKAGE_COUNT,
	HL_BSP_ITEM_WIDTH = 0,
	HL_BSP_ITEM_HEIGHT,
	HL_BSP_ITEM_PALETTE_ENTRIES,
	HL_BSP_ITEM_COUNT,

	HL_GCF_PACKAGE_VERSION = 0,
	HL_GCF_PACKAGE_ID,
	HL_GCF_PACKAGE_ALLOCATED_BLOCKS,
	HL_GCF_PACKAGE_USED_BLOCKS,
	HL_GCF_PACKAGE_BLOCK_LENGTH,
	HL_GCF_PACKAGE_LAST_VERSION_PLAYED,
	HL_GCF_PACKAGE_COUNT,
	HL_GCF_ITEM_ENCRYPTED = 0,
	HL_GCF_ITEM_COPY_LOCAL,
	HL_GCF_ITEM_OVERWRITE_LOCAL,
	HL_GCF_ITEM_BACKUP_LOCAL,
	HL_GCF_ITEM_FLAGS,
	HL_GCF_ITEM_FRAGMENTATION,
	HL_GCF_ITEM_COUNT,

	HL_NCF_PACKAGE_VERSION = 0,
	HL_NCF_PACKAGE_ID,
	HL_NCF_PACKAGE_LAST_VERSION_PLAYED,
	HL_NCF_PACKAGE_COUNT,
	HL_NCF_ITEM_ENCRYPTED = 0,
	HL_NCF_ITEM_COPY_LOCAL,
	HL_NCF_ITEM_OVERWRITE_LOCAL,
	HL_NCF_ITEM_BACKUP_LOCAL,
	HL_NCF_ITEM_FLAGS,
	HL_NCF_ITEM_COUNT,

	HL_PAK_PACKAGE_COUNT = 0,
	HL_PAK_ITEM_COUNT = 0,

	HL_VBSP_PACKAGE_VERSION = 0,
	HL_VBSP_PACKAGE_MAP_REVISION,
	HL_VBSP_PACKAGE_COUNT,
	HL_VBSP_ITEM_VERSION = 0,
	HL_VBSP_ITEM_FOUR_CC,
	HL_VBSP_ZIP_PACKAGE_DISK,
	HL_VBSP_ZIP_PACKAGE_COMMENT,
	HL_VBSP_ZIP_ITEM_CREATE_VERSION,
	HL_VBSP_ZIP_ITEM_EXTRACT_VERSION,
	HL_VBSP_ZIP_ITEM_FLAGS,
	HL_VBSP_ZIP_ITEM_COMPRESSION_METHOD,
	HL_VBSP_ZIP_ITEM_CRC,
	HL_VBSP_ZIP_ITEM_DISK,
	HL_VBSP_ZIP_ITEM_COMMENT,
	HL_VBSP_ITEM_COUNT,

	HL_VPK_PACKAGE_Archives = 0,
	HL_VPK_PACKAGE_Version,
	HL_VPK_PACKAGE_COUNT,
	HL_VPK_ITEM_PRELOAD_BYTES = 0,
	HL_VPK_ITEM_ARCHIVE,
	HL_VPK_ITEM_CRC,
	HL_VPK_ITEM_COUNT,

	HL_WAD_PACKAGE_VERSION = 0,
	HL_WAD_PACKAGE_COUNT,
	HL_WAD_ITEM_WIDTH = 0,
	HL_WAD_ITEM_HEIGHT,
	HL_WAD_ITEM_PALETTE_ENTRIES,
	HL_WAD_ITEM_MIPMAPS,
	HL_WAD_ITEM_COMPRESSED,
	HL_WAD_ITEM_TYPE,
	HL_WAD_ITEM_COUNT,

	HL_XZP_PACKAGE_VERSION = 0,
	HL_XZP_PACKAGE_PRELOAD_BYTES,
	HL_XZP_PACKAGE_COUNT,
	HL_XZP_ITEM_CREATED = 0,
	HL_XZP_ITEM_PRELOAD_BYTES,
	HL_XZP_ITEM_COUNT,

	HL_ZIP_PACKAGE_DISK = 0,
	HL_ZIP_PACKAGE_COMMENT,
	HL_ZIP_PACKAGE_COUNT,
	HL_ZIP_ITEM_CREATE_VERSION = 0,
	HL_ZIP_ITEM_EXTRACT_VERSION,
	HL_ZIP_ITEM_FLAGS,
	HL_ZIP_ITEM_COMPRESSION_METHOD,
	HL_ZIP_ITEM_CRC,
	HL_ZIP_ITEM_DISK,
	HL_ZIP_ITEM_COMMENT,
	HL_ZIP_ITEM_COUNT
} HLPackageAttribute;

typedef enum
{
	HL_VALIDATES_OK = 0,
	HL_VALIDATES_ASSUMED_OK,
	HL_VALIDATES_INCOMPLETE,
	HL_VALIDATES_CORRUPT,
	HL_VALIDATES_CANCELED,
	HL_VALIDATES_ERROR
} HLValidation;

typedef struct
{
	HLAttributeType eAttributeType;
	hlChar lpName[252];
	union
	{
		struct
		{
			hlBool bValue;
		} Boolean;
		struct
		{
			hlInt iValue;
		} Integer;
		struct
		{
			hlUInt uiValue;
			hlBool bHexadecimal;
		} UnsignedInteger;
		struct
		{
			hlFloat fValue;
		} Float;
		struct
		{
			hlChar lpValue[256];
		} String;
	} Value;
} HLAttribute;

typedef hlVoid HLDirectoryItem;
typedef hlVoid HLStream;

typedef hlBool (*POpenProc) (hlUInt, hlVoid *);
typedef hlVoid (*PCloseProc)(hlVoid *);
typedef hlUInt (*PReadProc)  (hlVoid *, hlUInt, hlVoid *);
typedef hlUInt (*PWriteProc)  (const hlVoid *, hlUInt, hlVoid *);
typedef hlULongLong (*PSeekExProc) (hlLongLong, HLSeekMode, hlVoid *);
typedef hlUInt (*PTellProc) (hlVoid *);
typedef hlULongLong (*PTellExProc) (hlVoid *);
typedef hlUInt (*PSizeProc) (hlVoid *);
typedef hlULongLong (*PSizeExProc) (hlVoid *);

typedef hlVoid (*PExtractItemStartProc) (const HLDirectoryItem *pItem);
typedef hlVoid (*PExtractItemEndProc) (const HLDirectoryItem *pItem, hlBool bSuccess);
typedef hlVoid (*PExtractFileProgressProc) (const HLDirectoryItem *pFile, hlUInt uiBytesExtracted, hlUInt uiBytesTotal, hlBool *pCancel);
typedef hlVoid (*PValidateFileProgressProc) (const HLDirectoryItem *pFile, hlUInt uiBytesValidated, hlUInt uiBytesTotal, hlBool *pCancel);
typedef hlVoid (*PDefragmentProgressProc) (const HLDirectoryItem *pFile, hlUInt uiFilesDefragmented, hlUInt uiFilesTotal, hlUInt uiBytesDefragmented, hlUInt uiBytesTotal, hlBool *pCancel);
typedef hlVoid (*PDefragmentProgressExProc) (const HLDirectoryItem *pFile, hlUInt uiFilesDefragmented, hlUInt uiFilesTotal, hlULongLong uiBytesDefragmented, hlULongLong uiBytesTotal, hlBool *pCancel);

//
// C library routines.
//

hlVoid hlInitialize();
hlVoid hlShutdown();

//
// Get/Set
//

hlBool hlGetBoolean(HLOption eOption);
hlBool hlGetBooleanValidate(HLOption eOption, hlBool *pValue);
hlVoid hlSetBoolean(HLOption eOption, hlBool bValue);

hlInt hlGetInteger(HLOption eOption);
hlBool hlGetIntegerValidate(HLOption eOption, hlInt *pValue);
hlVoid hlSetInteger(HLOption eOption, hlInt iValue);

hlUInt hlGetUnsignedInteger(HLOption eOption);
hlBool hlGetUnsignedIntegerValidate(HLOption eOption, hlUInt *pValue);
hlVoid hlSetUnsignedInteger(HLOption eOption, hlUInt iValue);

hlLongLong hlGetLongLong(HLOption eOption);
hlBool hlGetLongLongValidate(HLOption eOption, hlLongLong *pValue);
hlVoid hlSetLongLong(HLOption eOption, hlLongLong iValue);

hlULongLong hlGetUnsignedLongLong(HLOption eOption);
hlBool hlGetUnsignedLongLongValidate(HLOption eOption, hlULongLong *pValue);
hlVoid hlSetUnsignedLongLong(HLOption eOption, hlULongLong iValue);

hlFloat hlGetFloat(HLOption eOption);
hlBool hlGetFloatValidate(HLOption eOption, hlFloat *pValue);
hlVoid hlSetFloat(HLOption eOption, hlFloat fValue);

const hlChar *hlGetString(HLOption eOption);
hlBool hlGetStringValidate(HLOption eOption, const hlChar **pValue);
hlVoid hlSetString(HLOption eOption, const hlChar *lpValue);

const hlVoid *hlGetVoid(HLOption eOption);
hlBool hlGetVoidValidate(HLOption eOption, const hlVoid **pValue);
hlVoid hlSetVoid(HLOption eOption, const hlVoid *pValue);

//
// Attributes
//

hlBool hlAttributeGetBoolean(HLAttribute *pAttribute);
hlVoid hlAttributeSetBoolean(HLAttribute *pAttribute, const hlChar *lpName, hlBool bValue);

hlInt hlAttributeGetInteger(HLAttribute *pAttribute);
hlVoid hlAttributeSetInteger(HLAttribute *pAttribute, const hlChar *lpName, hlInt iValue);

hlUInt hlAttributeGetUnsignedInteger(HLAttribute *pAttribute);
hlVoid hlAttributeSetUnsignedInteger(HLAttribute *pAttribute, const hlChar *lpName, hlUInt uiValue, hlBool bHexadecimal);

hlFloat hlAttributeGetFloat(HLAttribute *pAttribute);
hlVoid hlAttributeSetFloat(HLAttribute *pAttribute, const hlChar *lpName, hlFloat fValue);

const hlChar *hlAttributeGetString(HLAttribute *pAttribute);
hlVoid hlAttributeSetString(HLAttribute *pAttribute, const hlChar *lpName, const hlChar *lpValue);

//
// Directory Item
//

HLDirectoryItemType hlItemGetType(const HLDirectoryItem *pItem);

const hlChar *hlItemGetName(const HLDirectoryItem *pItem);
hlUInt hlItemGetID(const HLDirectoryItem *pItem);
const hlVoid *hlItemGetData(const HLDirectoryItem *pItem);

hlUInt hlItemGetPackage(const HLDirectoryItem *pItem);
HLDirectoryItem *hlItemGetParent(HLDirectoryItem *pItem);

hlBool hlItemGetSize(const HLDirectoryItem *pItem, hlUInt *pSize);
hlBool hlItemGetSizeEx(const HLDirectoryItem *pItem, hlULongLong *pSize);
hlBool hlItemGetSizeOnDisk(const HLDirectoryItem *pItem, hlUInt *pSize);
hlBool hlItemGetSizeOnDiskEx(const HLDirectoryItem *pItem, hlULongLong *pSize);

hlVoid hlItemGetPath(const HLDirectoryItem *pItem, hlChar *lpPath, hlUInt uiPathSize);
hlBool hlItemExtract(HLDirectoryItem *pItem, const hlChar *lpPath);

//
// Directory Folder
//

hlUInt hlFolderGetCount(const HLDirectoryItem *pItem);

HLDirectoryItem *hlFolderGetItem(HLDirectoryItem *pItem, hlUInt uiIndex);
HLDirectoryItem *hlFolderGetItemByName(HLDirectoryItem *pItem, const hlChar *lpName, HLFindType eFind);
HLDirectoryItem *hlFolderGetItemByPath(HLDirectoryItem *pItem, const hlChar *lpPath, HLFindType eFind);

hlVoid hlFolderSort(HLDirectoryItem *pItem, HLSortField eField, HLSortOrder eOrder, hlBool bRecurse);

HLDirectoryItem *hlFolderFindFirst(HLDirectoryItem *pFolder, const hlChar *lpSearch, HLFindType eFind);
HLDirectoryItem *hlFolderFindNext(HLDirectoryItem *pFolder, HLDirectoryItem *pItem, const hlChar *lpSearch, HLFindType eFind);

hlUInt hlFolderGetSize(const HLDirectoryItem *pItem, hlBool bRecurse);
hlULongLong hlFolderGetSizeEx(const HLDirectoryItem *pItem, hlBool bRecurse);
hlUInt hlFolderGetSizeOnDisk(const HLDirectoryItem *pItem, hlBool bRecurse);
hlULongLong hlFolderGetSizeOnDiskEx(const HLDirectoryItem *pItem, hlBool bRecurse);
hlUInt hlFolderGetFolderCount(const HLDirectoryItem *pItem, hlBool bRecurse);
hlUInt hlFolderGetFileCount(const HLDirectoryItem *pItem, hlBool bRecurse);

//
// Directory File
//

hlUInt hlFileGetExtractable(const HLDirectoryItem *pItem);
HLValidation hlFileGetValidation(const HLDirectoryItem *pItem);
hlUInt hlFileGetSize(const HLDirectoryItem *pItem);
hlUInt hlFileGetSizeOnDisk(const HLDirectoryItem *pItem);

hlBool hlFileCreateStream(HLDirectoryItem *pItem, HLStream **pStream);
hlVoid hlFileReleaseStream(HLDirectoryItem *pItem, HLStream *pStream);

//
// Stream
//

HLStreamType hlStreamGetType(const HLStream *pStream);

hlBool hlStreamGetOpened(const HLStream *pStream);
hlUInt hlStreamGetMode(const HLStream *pStream);

hlBool hlStreamOpen(HLStream *pStream, hlUInt uiMode);
hlVoid hlStreamClose(HLStream *pStream);

hlUInt hlStreamGetStreamSize(const HLStream *pStream);
hlULongLong hlStreamGetStreamSizeEx(const HLStream *pStream);
hlUInt hlStreamGetStreamPointer(const HLStream *pStream);
hlULongLong hlStreamGetStreamPointerEx(const HLStream *pStream);

hlUInt hlStreamSeek(HLStream *pStream, hlLongLong iOffset, HLSeekMode eSeekMode);
hlULongLong hlStreamSeekEx(HLStream *pStream, hlLongLong iOffset, HLSeekMode eSeekMode);

hlBool hlStreamReadChar(HLStream *pStream, hlChar *pChar);
hlUInt hlStreamRead(HLStream *pStream, hlVoid *lpData, hlUInt uiBytes);

hlBool hlStreamWriteChar(HLStream *pStream, hlChar iChar);
hlUInt hlStreamWrite(HLStream *pStream, const hlVoid *lpData, hlUInt uiBytes);

//
// Package
//

hlBool hlBindPackage(hlUInt uiPackage);

HLPackageType hlGetPackageTypeFromName(const hlChar *lpName);
HLPackageType hlGetPackageTypeFromMemory(const hlVoid *lpBuffer, hlUInt uiBufferSize);
HLPackageType hlGetPackageTypeFromStream(HLStream *pStream);
hlBool hlCreatePackage(HLPackageType ePackageType, hlUInt *uiPackage);
hlVoid hlDeletePackage(hlUInt uiPackage);

HLPackageType hlPackageGetType();
const hlChar *hlPackageGetExtension();
const hlChar *hlPackageGetDescription();

hlBool hlPackageGetOpened();

hlBool hlPackageOpenFile(const hlChar *lpFileName, hlUInt uiMode);
hlBool hlPackageOpenMemory(hlVoid *lpData, hlUInt uiBufferSize, hlUInt uiMode);
hlBool hlPackageOpenProc(hlVoid *pUserData, hlUInt uiMode);
hlBool hlPackageOpenStream(HLStream *pStream, hlUInt uiMode);
hlVoid hlPackageClose();

hlBool hlPackageDefragment();

HLDirectoryItem *hlPackageGetRoot();

hlUInt hlPackageGetAttributeCount();
const hlChar *hlPackageGetAttributeName(HLPackageAttribute eAttribute);
hlBool hlPackageGetAttribute(HLPackageAttribute eAttribute, HLAttribute *pAttribute);

hlUInt hlPackageGetItemAttributeCount();
const hlChar *hlPackageGetItemAttributeName(HLPackageAttribute eAttribute);
hlBool hlPackageGetItemAttribute(const HLDirectoryItem *pItem, HLPackageAttribute eAttribute, HLAttribute *pAttribute);

hlBool hlPackageGetExtractable(const HLDirectoryItem *pFile, hlBool *pExtractable);
hlBool hlPackageGetFileSize(const HLDirectoryItem *pFile, hlUInt *pSize);
hlBool hlPackageGetFileSizeOnDisk(const HLDirectoryItem *pFile, hlUInt *pSize);
hlBool hlPackageCreateStream(const HLDirectoryItem *pFile, HLStream **pStream);
hlVoid hlPackageReleaseStream(HLStream *pStream);

const hlChar *hlNCFFileGetRootPath();
hlVoid hlNCFFileSetRootPath(const hlChar *lpRootPath);

hlBool hlWADFileGetImageSizePaletted(const HLDirectoryItem *pFile, hlUInt *uiPaletteDataSize, hlUInt *uiPixelDataSize);
hlBool hlWADFileGetImageDataPaletted(const HLDirectoryItem *pFile, hlUInt *uiWidth, hlUInt *uiHeight, hlByte **lpPaletteData, hlByte **lpPixelData);
hlBool hlWADFileGetImageSize(const HLDirectoryItem *pFile, hlUInt *uiPixelDataSize);
hlBool hlWADFileGetImageData(const HLDirectoryItem *pFile, hlUInt *uiWidth, hlUInt *uiHeight, hlByte **lpPixelData);
]]
end

hllib = hllib or {}
hllib.module = ffi.load("../lua/includes/modules/x86/hllib.dll")