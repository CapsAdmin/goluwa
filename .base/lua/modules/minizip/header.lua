--combined result of cpp zip.h and cpp unzip.h (only base functions without the wrappers)
local ffi = require'ffi'
ffi.cdef[[
enum {
	UNZ_OK                          = 0,
	UNZ_EOF                         = 0,
	UNZ_ERRNO                       = -1,
	UNZ_END_OF_LIST_OF_FILE         = -100,
	UNZ_PARAMERROR                  = -102,
	UNZ_BADZIPFILE                  = -103,
	UNZ_INTERNALERROR               = -104,
	UNZ_CRCERROR                    = -105
};

enum {
	APPEND_STATUS_CREATE        = 0,
	APPEND_STATUS_CREATEAFTER   = 1,
	APPEND_STATUS_ADDINZIP      = 2
};

typedef struct {int unused;} zipFile_s;
typedef zipFile_s* zipFile;

/* tm_zip contain date/time info */
typedef struct tm_zip_s
{
    uint32_t tm_sec;            /* seconds after the minute - [0,59] */
    uint32_t tm_min;            /* minutes after the hour - [0,59] */
    uint32_t tm_hour;           /* hours since midnight - [0,23] */
    uint32_t tm_mday;           /* day of the month - [1,31] */
    uint32_t tm_mon;            /* months since January - [0,11] */
    uint32_t tm_year;           /* years - [1980..2044] */
} tm_zip;

typedef struct
{
    tm_zip      tmz_date;       /* date in understandable format           */
    uint32_t    dosDate;        /* if dos_date == 0, tmu_date is used      */
    uint32_t    internal_fa;    /* internal file attributes        2 bytes */
    uint32_t    external_fa;    /* external file attributes        4 bytes */
} zip_fileinfo;

zipFile zipOpen64 (const void *pathname, int append);

int zipOpenNewFileInZip4_64 (
	zipFile file,
	const char* filename,
	const zip_fileinfo* zipfi,
	const void* extrafield_local,  uint32_t size_extrafield_local,
	const void* extrafield_global, uint32_t size_extrafield_global,
	const char* comment,
	int method,
	int level,
	int raw,
	int windowBits,
	int memLevel,
	int strategy,
	const char* password,
	uint32_t crcForCrypting,
	uint32_t versionMadeBy,
	uint32_t flagBase,
	int zip64);

int zipWriteInFileInZip (zipFile file, const void* buf, unsigned len);
int zipCloseFileInZip (zipFile file);
int zipCloseFileInZipRaw64 (zipFile file, uint64_t uncompressed_size, uint32_t crc32);
int zipClose (zipFile file, const char* global_comment);
int zipRemoveExtraInfoBlock (char* pData, int* dataLen, short sHeader);

/* unzip.h */

typedef struct {int unused;} unzFile_s;
typedef unzFile_s* unzFile;

/* tm_unz contain date/time info */
typedef tm_zip tm_unz;

/* unz_global_info structure contain global data about the ZIPfile
   These data comes from the end of central dir */
typedef struct unz_global_info64_s
{
    uint64_t number_entry;         /* total number of entries in
                                     the central dir on this disk */
    uint32_t size_comment;         /* size of the global comment of the zipfile */
} unz_global_info64;

/* unz_file_info contain information about a file in the zipfile */
typedef struct unz_file_info64_s
{
    uint32_t version;              /* version made by                 2 bytes */
    uint32_t version_needed;       /* version needed to extract       2 bytes */
    uint32_t flag;                 /* general purpose bit flag        2 bytes */
    uint32_t compression_method;   /* compression method              2 bytes */
    uint32_t dosDate;              /* last mod file date in Dos fmt   4 bytes */
    uint32_t crc;                  /* crc-32                          4 bytes */
    uint64_t compressed_size;      /* compressed size                 8 bytes */
    uint64_t uncompressed_size;    /* uncompressed size               8 bytes */
    uint32_t size_filename;        /* filename length                 2 bytes */
    uint32_t size_file_extra;      /* extra field length              2 bytes */
    uint32_t size_file_comment;    /* file comment length             2 bytes */

    uint32_t disk_num_start;       /* disk number start               2 bytes */
    uint32_t internal_fa;          /* internal file attributes        2 bytes */
    uint32_t external_fa;          /* external file attributes        4 bytes */

    tm_unz tmu_date;
} unz_file_info64;

int unzStringFileNameCompare (const char* fileName1, const char* fileName2, int iCaseSensitivity);
unzFile unzOpen64 (const void *path);
int unzClose (unzFile file);
int unzGetGlobalInfo64 (unzFile file, unz_global_info64 *pglobal_info);
int unzGetGlobalComment (unzFile file, char *szComment, uint32_t uSizeBuf);
int unzGoToFirstFile (unzFile file);
int unzGoToNextFile (unzFile file);
int unzLocateFile (unzFile file, const char *szFileName, int iCaseSensitivity);

typedef struct unz64_file_pos_s
{
    uint64_t pos_in_zip_directory;
    uint64_t num_of_file;
} unz64_file_pos;

int unzGetFilePos64(unzFile file, unz64_file_pos* file_pos);
int unzGoToFilePos64(unzFile file, const unz64_file_pos* file_pos);
int unzGetCurrentFileInfo64 (unzFile file, unz_file_info64 *pfile_info, char *szFileName, uint32_t fileNameBufferSize, void *extraField, uint32_t extraFieldBufferSize, char *szComment, uint32_t commentBufferSize);
uint64_t unzGetCurrentFileZStreamPos64 (unzFile file);
int unzOpenCurrentFile3 (unzFile file, int* method, int* level, int raw, const char* password);
int unzCloseCurrentFile (unzFile file);
int unzReadCurrentFile (unzFile file, void* buf, unsigned len);
uint64_t unztell64 (unzFile file);
int unzeof (unzFile file);
int unzGetLocalExtrafield (unzFile file, void* buf, unsigned len);
uint64_t unzGetOffset64 (unzFile file);
int unzSetOffset64 (unzFile file, uint64_t pos);
]]
