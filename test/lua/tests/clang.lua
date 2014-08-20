
local ffi=require'ffi'
ffi.cdef'void AllocConsole()';ffi.C.AllocConsole()
ffi.cdef[[
typedef unsigned int time_t;
typedef struct {
  const void *data;
  unsigned private_flags;
} CXString;
typedef void * CXCompilationDatabase;
typedef void * CXCompileCommands;
typedef void * CXCompileCommand;
typedef enum  {
  CXCompilationDatabase_NoError = 0,
  CXCompilationDatabase_CanNotLoadDatabase = 1
} CXCompilationDatabase_Error;
CXCompilationDatabase
clang_CompilationDatabase_fromDirectory(const char *BuildDir,
                                        CXCompilationDatabase_Error *ErrorCode);
void clang_CompilationDatabase_dispose(CXCompilationDatabase);
CXCompileCommands clang_CompilationDatabase_getCompileCommands(CXCompilationDatabase,
                                             const char *CompleteFileName);
CXCompileCommands clang_CompilationDatabase_getAllCompileCommands(CXCompilationDatabase);
void clang_CompileCommands_dispose(CXCompileCommands);
unsigned clang_CompileCommands_getSize(CXCompileCommands);
CXCompileCommand clang_CompileCommands_getCommand(CXCompileCommands, unsigned I);
CXString clang_CompileCommand_getDirectory(CXCompileCommand);
unsigned clang_CompileCommand_getNumArgs(CXCompileCommand);
CXString clang_CompileCommand_getArg(CXCompileCommand, unsigned I);
unsigned clang_CompileCommand_getNumMappedSources(CXCompileCommand);
CXString clang_CompileCommand_getMappedSourcePath(CXCompileCommand, unsigned I);
CXString clang_CompileCommand_getMappedSourceContent(CXCompileCommand, unsigned I);



const char *clang_getCString(CXString string);

void clang_disposeString(CXString string);
typedef struct CXIndexImpl CXIndexImpl;
typedef CXIndexImpl *CXIndex;

typedef struct CXTranslationUnitImpl *CXTranslationUnit;

typedef void *CXClientData;

struct CXUnsavedFile {
  const char *Filename;
  const char *Contents;
  unsigned long Length;
};

enum CXAvailabilityKind {
  CXAvailability_Available,
  CXAvailability_Deprecated,
  CXAvailability_NotAvailable,
  CXAvailability_NotAccessible
};

typedef struct CXVersion {
  int Major;
  int Minor;
  int Subminor;
} CXVersion;
CXIndex clang_createIndex(int excludeDeclarationsFromPCH,
                                         int displayDiagnostics);

void clang_disposeIndex(CXIndex index);
typedef enum {
  CXGlobalOpt_None = 0x0,
  CXGlobalOpt_ThreadBackgroundPriorityForIndexing = 0x1,
  CXGlobalOpt_ThreadBackgroundPriorityForEditing = 0x2,
  CXGlobalOpt_ThreadBackgroundPriorityForAll =
      CXGlobalOpt_ThreadBackgroundPriorityForIndexing |
      CXGlobalOpt_ThreadBackgroundPriorityForEditing
} CXGlobalOptFlags;

void clang_CXIndex_setGlobalOptions(CXIndex, unsigned options);

unsigned clang_CXIndex_getGlobalOptions(CXIndex);
typedef void *CXFile;

CXString clang_getFileName(CXFile SFile);

time_t clang_getFileTime(CXFile SFile);

typedef struct {
  unsigned long long data[3];
} CXFileUniqueID;

int clang_getFileUniqueID(CXFile file, CXFileUniqueID *outID);

unsigned 
clang_isFileMultipleIncludeGuarded(CXTranslationUnit tu, CXFile file);

CXFile clang_getFile(CXTranslationUnit tu,
                                    const char *file_name);

typedef struct {
  const void *ptr_data[2];
  unsigned int_data;
} CXSourceLocation;

typedef struct {
  const void *ptr_data[2];
  unsigned begin_int_data;
  unsigned end_int_data;
} CXSourceRange;

CXSourceLocation clang_getNullLocation(void);

unsigned clang_equalLocations(CXSourceLocation loc1,
                                             CXSourceLocation loc2);

CXSourceLocation clang_getLocation(CXTranslationUnit tu,
                                                  CXFile file,
                                                  unsigned line,
                                                  unsigned column);
CXSourceLocation clang_getLocationForOffset(CXTranslationUnit tu,
                                                           CXFile file,
                                                           unsigned offset);

int clang_Location_isInSystemHeader(CXSourceLocation location);

int clang_Location_isFromMainFile(CXSourceLocation location);

CXSourceRange clang_getNullRange(void);

CXSourceRange clang_getRange(CXSourceLocation begin,
                                            CXSourceLocation end);

unsigned clang_equalRanges(CXSourceRange range1,
                                          CXSourceRange range2);

int clang_Range_isNull(CXSourceRange range);

void clang_getExpansionLocation(CXSourceLocation location,
                                               CXFile *file,
                                               unsigned *line,
                                               unsigned *column,
                                               unsigned *offset);

void clang_getPresumedLocation(CXSourceLocation location,
                                              CXString *filename,
                                              unsigned *line,
                                              unsigned *column);

void clang_getInstantiationLocation(CXSourceLocation location,
                                                   CXFile *file,
                                                   unsigned *line,
                                                   unsigned *column,
                                                   unsigned *offset);

void clang_getSpellingLocation(CXSourceLocation location,
                                              CXFile *file,
                                              unsigned *line,
                                              unsigned *column,
                                              unsigned *offset);

void clang_getFileLocation(CXSourceLocation location,
                                          CXFile *file,
                                          unsigned *line,
                                          unsigned *column,
                                          unsigned *offset);

CXSourceLocation clang_getRangeStart(CXSourceRange range);

CXSourceLocation clang_getRangeEnd(CXSourceRange range);

enum CXDiagnosticSeverity {
  CXDiagnostic_Ignored = 0,
  CXDiagnostic_Note    = 1,
  CXDiagnostic_Warning = 2,
  CXDiagnostic_Error   = 3,
  CXDiagnostic_Fatal   = 4
};

typedef void *CXDiagnostic;

typedef void *CXDiagnosticSet;
unsigned clang_getNumDiagnosticsInSet(CXDiagnosticSet Diags);

CXDiagnostic clang_getDiagnosticInSet(CXDiagnosticSet Diags,
                                                     unsigned Index);  

enum CXLoadDiag_Error {
  CXLoadDiag_None = 0,
  CXLoadDiag_Unknown = 1,
  CXLoadDiag_CannotLoad = 2,
  CXLoadDiag_InvalidFile = 3
};
CXDiagnosticSet clang_loadDiagnostics(const char *file,
                                                  enum CXLoadDiag_Error *error,
                                                  CXString *errorString);

void clang_disposeDiagnosticSet(CXDiagnosticSet Diags);

CXDiagnosticSet clang_getChildDiagnostics(CXDiagnostic D);

unsigned clang_getNumDiagnostics(CXTranslationUnit Unit);

CXDiagnostic clang_getDiagnostic(CXTranslationUnit Unit,
                                                unsigned Index);

CXDiagnosticSet
  clang_getDiagnosticSetFromTU(CXTranslationUnit Unit);  

void clang_disposeDiagnostic(CXDiagnostic Diagnostic);

enum CXDiagnosticDisplayOptions {
  CXDiagnostic_DisplaySourceLocation = 0x01,
  CXDiagnostic_DisplayColumn = 0x02,
  CXDiagnostic_DisplaySourceRanges = 0x04,
  CXDiagnostic_DisplayOption = 0x08,
  CXDiagnostic_DisplayCategoryId = 0x10,
  CXDiagnostic_DisplayCategoryName = 0x20
};

CXString clang_formatDiagnostic(CXDiagnostic Diagnostic,
                                               unsigned Options);

unsigned clang_defaultDiagnosticDisplayOptions(void);

enum CXDiagnosticSeverity
clang_getDiagnosticSeverity(CXDiagnostic);

CXSourceLocation clang_getDiagnosticLocation(CXDiagnostic);

CXString clang_getDiagnosticSpelling(CXDiagnostic);

CXString clang_getDiagnosticOption(CXDiagnostic Diag,
                                                  CXString *Disable);

unsigned clang_getDiagnosticCategory(CXDiagnostic);

 
CXString clang_getDiagnosticCategoryName(unsigned Category);

CXString clang_getDiagnosticCategoryText(CXDiagnostic);
unsigned clang_getDiagnosticNumRanges(CXDiagnostic);

CXSourceRange clang_getDiagnosticRange(CXDiagnostic Diagnostic,
                                                      unsigned Range);

unsigned clang_getDiagnosticNumFixIts(CXDiagnostic Diagnostic);

CXString clang_getDiagnosticFixIt(CXDiagnostic Diagnostic,
                                                 unsigned FixIt,
                                               CXSourceRange *ReplacementRange);

CXString
clang_getTranslationUnitSpelling(CXTranslationUnit CTUnit);

CXTranslationUnit clang_createTranslationUnitFromSourceFile(
                                         CXIndex CIdx,
                                         const char *source_filename,
                                         int num_clang_command_line_args,
                                   const char * const *clang_command_line_args,
                                         unsigned num_unsaved_files,
                                         struct CXUnsavedFile *unsaved_files);

CXTranslationUnit clang_createTranslationUnit(CXIndex,
                                             const char *ast_filename);

enum CXTranslationUnit_Flags {
  CXTranslationUnit_None = 0x0,
  CXTranslationUnit_DetailedPreprocessingRecord = 0x01,
  CXTranslationUnit_Incomplete = 0x02,
  CXTranslationUnit_PrecompiledPreamble = 0x04,
  CXTranslationUnit_CacheCompletionResults = 0x08,
  CXTranslationUnit_ForSerialization = 0x10,
  CXTranslationUnit_CXXChainedPCH = 0x20,
  CXTranslationUnit_SkipFunctionBodies = 0x40,
  CXTranslationUnit_IncludeBriefCommentsInCodeCompletion = 0x80
};

unsigned clang_defaultEditingTranslationUnitOptions(void);
CXTranslationUnit clang_parseTranslationUnit(CXIndex CIdx,
                                                    const char *source_filename,
                                         const char * const *command_line_args,
                                                      int num_command_line_args,
                                            struct CXUnsavedFile *unsaved_files,
                                                     unsigned num_unsaved_files,
                                                            unsigned options);
enum CXSaveTranslationUnit_Flags {
  CXSaveTranslationUnit_None = 0x0
};

unsigned clang_defaultSaveOptions(CXTranslationUnit TU);

enum CXSaveError {
  CXSaveError_None = 0,
  CXSaveError_Unknown = 1,
  CXSaveError_TranslationErrors = 2,
  CXSaveError_InvalidTU = 3
};
int clang_saveTranslationUnit(CXTranslationUnit TU,
                                             const char *FileName,
                                             unsigned options);

void clang_disposeTranslationUnit(CXTranslationUnit);

enum CXReparse_Flags {
  CXReparse_None = 0x0
};
unsigned clang_defaultReparseOptions(CXTranslationUnit TU);

int clang_reparseTranslationUnit(CXTranslationUnit TU,
                                                unsigned num_unsaved_files,
                                          struct CXUnsavedFile *unsaved_files,
                                                unsigned options);

enum CXTUResourceUsageKind {
  CXTUResourceUsage_AST = 1,
  CXTUResourceUsage_Identifiers = 2,
  CXTUResourceUsage_Selectors = 3,
  CXTUResourceUsage_GlobalCompletionResults = 4,
  CXTUResourceUsage_SourceManagerContentCache = 5,
  CXTUResourceUsage_AST_SideTables = 6,
  CXTUResourceUsage_SourceManager_Membuffer_Malloc = 7,
  CXTUResourceUsage_SourceManager_Membuffer_MMap = 8,
  CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc = 9, 
  CXTUResourceUsage_ExternalASTSource_Membuffer_MMap = 10, 
  CXTUResourceUsage_Preprocessor = 11,
  CXTUResourceUsage_PreprocessingRecord = 12,
  CXTUResourceUsage_SourceManager_DataStructures = 13,
  CXTUResourceUsage_Preprocessor_HeaderSearch = 14,
  CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN = CXTUResourceUsage_AST,
  CXTUResourceUsage_MEMORY_IN_BYTES_END =
    CXTUResourceUsage_Preprocessor_HeaderSearch,
  CXTUResourceUsage_First = CXTUResourceUsage_AST,
  CXTUResourceUsage_Last = CXTUResourceUsage_Preprocessor_HeaderSearch
};


const char *clang_getTUResourceUsageName(enum CXTUResourceUsageKind kind);
typedef struct CXTUResourceUsageEntry {
  enum CXTUResourceUsageKind kind;  
  unsigned long amount;
} CXTUResourceUsageEntry;

typedef struct CXTUResourceUsage {
  void *data;
  unsigned numEntries;
  CXTUResourceUsageEntry *entries;
} CXTUResourceUsage;

CXTUResourceUsage clang_getCXTUResourceUsage(CXTranslationUnit TU);
void clang_disposeCXTUResourceUsage(CXTUResourceUsage usage);
enum CXCursorKind {
  CXCursor_UnexposedDecl                 = 1,
  CXCursor_StructDecl                    = 2,
  CXCursor_UnionDecl                     = 3,
  CXCursor_ClassDecl                     = 4,
  CXCursor_EnumDecl                      = 5,
  CXCursor_FieldDecl                     = 6,
  CXCursor_EnumConstantDecl              = 7,
  CXCursor_FunctionDecl                  = 8,
  CXCursor_VarDecl                       = 9,
  CXCursor_ParmDecl                      = 10,
  CXCursor_ObjCInterfaceDecl             = 11,
  CXCursor_ObjCCategoryDecl              = 12,
  CXCursor_ObjCProtocolDecl              = 13,
  CXCursor_ObjCPropertyDecl              = 14,
  CXCursor_ObjCIvarDecl                  = 15,
  CXCursor_ObjCInstanceMethodDecl        = 16,
  CXCursor_ObjCClassMethodDecl           = 17,
  CXCursor_ObjCImplementationDecl        = 18,
  CXCursor_ObjCCategoryImplDecl          = 19,
  CXCursor_TypedefDecl                   = 20,
  CXCursor_CXXMethod                     = 21,
  CXCursor_Namespace                     = 22,
  CXCursor_LinkageSpec                   = 23,
  CXCursor_Constructor                   = 24,
  CXCursor_Destructor                    = 25,
  CXCursor_ConversionFunction            = 26,
  CXCursor_TemplateTypeParameter         = 27,
  CXCursor_NonTypeTemplateParameter      = 28,
  CXCursor_TemplateTemplateParameter     = 29,
  CXCursor_FunctionTemplate              = 30,
  CXCursor_ClassTemplate                 = 31,
  CXCursor_ClassTemplatePartialSpecialization = 32,
  CXCursor_NamespaceAlias                = 33,
  CXCursor_UsingDirective                = 34,
  CXCursor_UsingDeclaration              = 35,
  CXCursor_TypeAliasDecl                 = 36,
  CXCursor_ObjCSynthesizeDecl            = 37,
  CXCursor_ObjCDynamicDecl               = 38,
  CXCursor_CXXAccessSpecifier            = 39,
  CXCursor_FirstDecl                     = CXCursor_UnexposedDecl,
  CXCursor_LastDecl                      = CXCursor_CXXAccessSpecifier,
  CXCursor_FirstRef                      = 40, 
  CXCursor_ObjCSuperClassRef             = 40,
  CXCursor_ObjCProtocolRef               = 41,
  CXCursor_ObjCClassRef                  = 42,
  CXCursor_TypeRef                       = 43,
  CXCursor_CXXBaseSpecifier              = 44,
  CXCursor_TemplateRef                   = 45,
  CXCursor_NamespaceRef                  = 46,
  CXCursor_MemberRef                     = 47,
  CXCursor_LabelRef                      = 48,
  CXCursor_OverloadedDeclRef             = 49,
  CXCursor_VariableRef                   = 50,
  CXCursor_LastRef                       = CXCursor_VariableRef,
  CXCursor_FirstInvalid                  = 70,
  CXCursor_InvalidFile                   = 70,
  CXCursor_NoDeclFound                   = 71,
  CXCursor_NotImplemented                = 72,
  CXCursor_InvalidCode                   = 73,
  CXCursor_LastInvalid                   = CXCursor_InvalidCode,
  CXCursor_FirstExpr                     = 100,
  CXCursor_UnexposedExpr                 = 100,
  CXCursor_DeclRefExpr                   = 101,
  CXCursor_MemberRefExpr                 = 102,
  CXCursor_CallExpr                      = 103,
  CXCursor_ObjCMessageExpr               = 104,
  CXCursor_BlockExpr                     = 105,
  CXCursor_IntegerLiteral                = 106,
  CXCursor_FloatingLiteral               = 107,
  CXCursor_ImaginaryLiteral              = 108,
  CXCursor_StringLiteral                 = 109,
  CXCursor_CharacterLiteral              = 110,
  CXCursor_ParenExpr                     = 111,
  CXCursor_UnaryOperator                 = 112,
  CXCursor_ArraySubscriptExpr            = 113,
  CXCursor_BinaryOperator                = 114,
  CXCursor_CompoundAssignOperator        = 115,
  CXCursor_ConditionalOperator           = 116,
  CXCursor_CStyleCastExpr                = 117,
  CXCursor_CompoundLiteralExpr           = 118,
  CXCursor_InitListExpr                  = 119,
  CXCursor_AddrLabelExpr                 = 120,
  CXCursor_StmtExpr                      = 121,
  CXCursor_GenericSelectionExpr          = 122,
  CXCursor_GNUNullExpr                   = 123,
  CXCursor_CXXStaticCastExpr             = 124,
  CXCursor_CXXDynamicCastExpr            = 125,
  CXCursor_CXXReinterpretCastExpr        = 126,
  CXCursor_CXXConstCastExpr              = 127,
  CXCursor_CXXFunctionalCastExpr         = 128,
  CXCursor_CXXTypeidExpr                 = 129,
  CXCursor_CXXBoolLiteralExpr            = 130,
  CXCursor_CXXNullPtrLiteralExpr         = 131,
  CXCursor_CXXThisExpr                   = 132,
  CXCursor_CXXThrowExpr                  = 133,
  CXCursor_CXXNewExpr                    = 134,
  CXCursor_CXXDeleteExpr                 = 135,
  CXCursor_UnaryExpr                     = 136,
  CXCursor_ObjCStringLiteral             = 137,
  CXCursor_ObjCEncodeExpr                = 138,
  CXCursor_ObjCSelectorExpr              = 139,
  CXCursor_ObjCProtocolExpr              = 140,
  CXCursor_ObjCBridgedCastExpr           = 141,
  CXCursor_PackExpansionExpr             = 142,
  CXCursor_SizeOfPackExpr                = 143,
  CXCursor_LambdaExpr                    = 144,
  CXCursor_ObjCBoolLiteralExpr           = 145,
  CXCursor_ObjCSelfExpr                  = 146,
  CXCursor_LastExpr                      = CXCursor_ObjCSelfExpr,
  CXCursor_FirstStmt                     = 200,
  CXCursor_UnexposedStmt                 = 200,
  CXCursor_LabelStmt                     = 201,
  CXCursor_CompoundStmt                  = 202,
  CXCursor_CaseStmt                      = 203,
  CXCursor_DefaultStmt                   = 204,
  CXCursor_IfStmt                        = 205,
  CXCursor_SwitchStmt                    = 206,
  CXCursor_WhileStmt                     = 207,
  CXCursor_DoStmt                        = 208,
  CXCursor_ForStmt                       = 209,
  CXCursor_GotoStmt                      = 210,
  CXCursor_IndirectGotoStmt              = 211,
  CXCursor_ContinueStmt                  = 212,
  CXCursor_BreakStmt                     = 213,
  CXCursor_ReturnStmt                    = 214,
  CXCursor_GCCAsmStmt                    = 215,
  CXCursor_AsmStmt                       = CXCursor_GCCAsmStmt,
  CXCursor_ObjCAtTryStmt                 = 216,
  CXCursor_ObjCAtCatchStmt               = 217,
  CXCursor_ObjCAtFinallyStmt             = 218,
  CXCursor_ObjCAtThrowStmt               = 219,
  CXCursor_ObjCAtSynchronizedStmt        = 220,
  CXCursor_ObjCAutoreleasePoolStmt       = 221,
  CXCursor_ObjCForCollectionStmt         = 222,
  CXCursor_CXXCatchStmt                  = 223,
  CXCursor_CXXTryStmt                    = 224,
  CXCursor_CXXForRangeStmt               = 225,
  CXCursor_SEHTryStmt                    = 226,
  CXCursor_SEHExceptStmt                 = 227,
  CXCursor_SEHFinallyStmt                = 228,
  CXCursor_MSAsmStmt                     = 229,
  CXCursor_NullStmt                      = 230,
  CXCursor_DeclStmt                      = 231,
  CXCursor_OMPParallelDirective          = 232,
  CXCursor_LastStmt                      = CXCursor_OMPParallelDirective,
  CXCursor_TranslationUnit               = 300,
  CXCursor_FirstAttr                     = 400,
  CXCursor_UnexposedAttr                 = 400,
  CXCursor_IBActionAttr                  = 401,
  CXCursor_IBOutletAttr                  = 402,
  CXCursor_IBOutletCollectionAttr        = 403,
  CXCursor_CXXFinalAttr                  = 404,
  CXCursor_CXXOverrideAttr               = 405,
  CXCursor_AnnotateAttr                  = 406,
  CXCursor_AsmLabelAttr                  = 407,
  CXCursor_PackedAttr                    = 408,
  CXCursor_LastAttr                      = CXCursor_PackedAttr,
  CXCursor_PreprocessingDirective        = 500,
  CXCursor_MacroDefinition               = 501,
  CXCursor_MacroExpansion                = 502,
  CXCursor_MacroInstantiation            = CXCursor_MacroExpansion,
  CXCursor_InclusionDirective            = 503,
  CXCursor_FirstPreprocessing            = CXCursor_PreprocessingDirective,
  CXCursor_LastPreprocessing             = CXCursor_InclusionDirective,
  CXCursor_ModuleImportDecl              = 600,
  CXCursor_FirstExtraDecl                = CXCursor_ModuleImportDecl,
  CXCursor_LastExtraDecl                 = CXCursor_ModuleImportDecl
};

typedef struct {
  enum CXCursorKind kind;
  int xdata;
  const void *data[3];
} CXCursor;

typedef struct {
  const void *ASTNode;
  CXTranslationUnit TranslationUnit;
} CXComment;
CXCursor clang_getNullCursor(void);

CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);

unsigned clang_equalCursors(CXCursor, CXCursor);

int clang_Cursor_isNull(CXCursor cursor);

unsigned clang_hashCursor(CXCursor);
enum CXCursorKind clang_getCursorKind(CXCursor);

unsigned clang_isDeclaration(enum CXCursorKind);

unsigned clang_isReference(enum CXCursorKind);

unsigned clang_isExpression(enum CXCursorKind);

unsigned clang_isStatement(enum CXCursorKind);

unsigned clang_isAttribute(enum CXCursorKind);

unsigned clang_isInvalid(enum CXCursorKind);

unsigned clang_isTranslationUnit(enum CXCursorKind);

unsigned clang_isPreprocessing(enum CXCursorKind);
unsigned clang_isUnexposed(enum CXCursorKind);

enum CXLinkageKind {
  CXLinkage_Invalid,
  CXLinkage_NoLinkage,
  CXLinkage_Internal,
  CXLinkage_UniqueExternal,
  CXLinkage_External
};

enum CXLinkageKind clang_getCursorLinkage(CXCursor cursor);

enum CXAvailabilityKind 
clang_getCursorAvailability(CXCursor cursor);

typedef struct CXPlatformAvailability {
  CXString Platform;
  CXVersion Introduced;
  CXVersion Deprecated;
  CXVersion Obsoleted;
  int Unavailable;
  CXString Message;
} CXPlatformAvailability;

int
clang_getCursorPlatformAvailability(CXCursor cursor,
                                    int *always_deprecated,
                                    CXString *deprecated_message,
                                    int *always_unavailable,
                                    CXString *unavailable_message,
                                    CXPlatformAvailability *availability,
                                    int availability_size);

void
clang_disposeCXPlatformAvailability(CXPlatformAvailability *availability);
enum CXLanguageKind {
  CXLanguage_Invalid = 0,
  CXLanguage_C,
  CXLanguage_ObjC,
  CXLanguage_CPlusPlus
};

enum CXLanguageKind clang_getCursorLanguage(CXCursor cursor);

CXTranslationUnit clang_Cursor_getTranslationUnit(CXCursor);

typedef struct CXCursorSetImpl *CXCursorSet;

CXCursorSet clang_createCXCursorSet(void);

void clang_disposeCXCursorSet(CXCursorSet cset);

unsigned clang_CXCursorSet_contains(CXCursorSet cset,
                                                   CXCursor cursor);

unsigned clang_CXCursorSet_insert(CXCursorSet cset,
                                                 CXCursor cursor);

CXCursor clang_getCursorSemanticParent(CXCursor cursor);

CXCursor clang_getCursorLexicalParent(CXCursor cursor);

void clang_getOverriddenCursors(CXCursor cursor, 
                                               CXCursor **overridden,
                                               unsigned *num_overridden);

void clang_disposeOverriddenCursors(CXCursor *overridden);

CXFile clang_getIncludedFile(CXCursor cursor);
CXCursor clang_getCursor(CXTranslationUnit, CXSourceLocation);

CXSourceLocation clang_getCursorLocation(CXCursor);

CXSourceRange clang_getCursorExtent(CXCursor);
enum CXTypeKind {
  CXType_Invalid = 0,
  CXType_Unexposed = 1,
  CXType_Void = 2,
  CXType_Bool = 3,
  CXType_Char_U = 4,
  CXType_UChar = 5,
  CXType_Char16 = 6,
  CXType_Char32 = 7,
  CXType_UShort = 8,
  CXType_UInt = 9,
  CXType_ULong = 10,
  CXType_ULongLong = 11,
  CXType_UInt128 = 12,
  CXType_Char_S = 13,
  CXType_SChar = 14,
  CXType_WChar = 15,
  CXType_Short = 16,
  CXType_Int = 17,
  CXType_Long = 18,
  CXType_LongLong = 19,
  CXType_Int128 = 20,
  CXType_Float = 21,
  CXType_Double = 22,
  CXType_LongDouble = 23,
  CXType_NullPtr = 24,
  CXType_Overload = 25,
  CXType_Dependent = 26,
  CXType_ObjCId = 27,
  CXType_ObjCClass = 28,
  CXType_ObjCSel = 29,
  CXType_FirstBuiltin = CXType_Void,
  CXType_LastBuiltin  = CXType_ObjCSel,
  CXType_Complex = 100,
  CXType_Pointer = 101,
  CXType_BlockPointer = 102,
  CXType_LValueReference = 103,
  CXType_RValueReference = 104,
  CXType_Record = 105,
  CXType_Enum = 106,
  CXType_Typedef = 107,
  CXType_ObjCInterface = 108,
  CXType_ObjCObjectPointer = 109,
  CXType_FunctionNoProto = 110,
  CXType_FunctionProto = 111,
  CXType_ConstantArray = 112,
  CXType_Vector = 113,
  CXType_IncompleteArray = 114,
  CXType_VariableArray = 115,
  CXType_DependentSizedArray = 116,
  CXType_MemberPointer = 117
};

enum CXCallingConv {
  CXCallingConv_Default = 0,
  CXCallingConv_C = 1,
  CXCallingConv_X86StdCall = 2,
  CXCallingConv_X86FastCall = 3,
  CXCallingConv_X86ThisCall = 4,
  CXCallingConv_X86Pascal = 5,
  CXCallingConv_AAPCS = 6,
  CXCallingConv_AAPCS_VFP = 7,
  CXCallingConv_PnaclCall = 8,
  CXCallingConv_IntelOclBicc = 9,
  CXCallingConv_X86_64Win64 = 10,
  CXCallingConv_X86_64SysV = 11,
  CXCallingConv_Invalid = 100,
  CXCallingConv_Unexposed = 200
};

typedef struct {
  enum CXTypeKind kind;
  void *data[2];
} CXType;

CXType clang_getCursorType(CXCursor C);

CXString clang_getTypeSpelling(CXType CT);

CXType clang_getTypedefDeclUnderlyingType(CXCursor C);

CXType clang_getEnumDeclIntegerType(CXCursor C);

long long clang_getEnumConstantDeclValue(CXCursor C);

unsigned long long clang_getEnumConstantDeclUnsignedValue(CXCursor C);

int clang_getFieldDeclBitWidth(CXCursor C);

int clang_Cursor_getNumArguments(CXCursor C);

CXCursor clang_Cursor_getArgument(CXCursor C, unsigned i);

unsigned clang_equalTypes(CXType A, CXType B);

CXType clang_getCanonicalType(CXType T);

unsigned clang_isConstQualifiedType(CXType T);

unsigned clang_isVolatileQualifiedType(CXType T);

unsigned clang_isRestrictQualifiedType(CXType T);

CXType clang_getPointeeType(CXType T);

CXCursor clang_getTypeDeclaration(CXType T);

CXString clang_getDeclObjCTypeEncoding(CXCursor C);

CXString clang_getTypeKindSpelling(enum CXTypeKind K);

enum CXCallingConv clang_getFunctionTypeCallingConv(CXType T);

CXType clang_getResultType(CXType T);

int clang_getNumArgTypes(CXType T);

CXType clang_getArgType(CXType T, unsigned i);

unsigned clang_isFunctionTypeVariadic(CXType T);

CXType clang_getCursorResultType(CXCursor C);

unsigned clang_isPODType(CXType T);

CXType clang_getElementType(CXType T);

long long clang_getNumElements(CXType T);

CXType clang_getArrayElementType(CXType T);

long long clang_getArraySize(CXType T);

enum CXTypeLayoutError {
  CXTypeLayoutError_Invalid = -1,
  CXTypeLayoutError_Incomplete = -2,
  CXTypeLayoutError_Dependent = -3,
  CXTypeLayoutError_NotConstantSize = -4,
  CXTypeLayoutError_InvalidFieldName = -5
};

long long clang_Type_getAlignOf(CXType T);

CXType clang_Type_getClassType(CXType T);

long long clang_Type_getSizeOf(CXType T);

long long clang_Type_getOffsetOf(CXType T, const char *S);
enum CXRefQualifierKind {
  CXRefQualifier_None = 0,
  CXRefQualifier_LValue,
  CXRefQualifier_RValue
};

enum CXRefQualifierKind clang_Type_getCXXRefQualifier(CXType T);

unsigned clang_Cursor_isBitField(CXCursor C);

unsigned clang_isVirtualBase(CXCursor);
enum CX_CXXAccessSpecifier {
  CX_CXXInvalidAccessSpecifier,
  CX_CXXPublic,
  CX_CXXProtected,
  CX_CXXPrivate
};

enum CX_CXXAccessSpecifier clang_getCXXAccessSpecifier(CXCursor);

unsigned clang_getNumOverloadedDecls(CXCursor cursor);

CXCursor clang_getOverloadedDecl(CXCursor cursor, 
                                                unsigned index);
CXType clang_getIBOutletCollectionType(CXCursor);

enum CXChildVisitResult {
  CXChildVisit_Break,
  CXChildVisit_Continue,
  CXChildVisit_Recurse
};

typedef enum CXChildVisitResult (*CXCursorVisitor)(CXCursor cursor,
                                                   CXCursor parent,
                                                   CXClientData client_data);

unsigned clang_visitChildren(CXCursor parent,
                                            CXCursorVisitor visitor,
                                            CXClientData client_data);
#ifdef __has_feature
#  if __has_feature(blocks)
typedef enum CXChildVisitResult 
     (CXCursorVisitorBlock)(CXCursor cursor, CXCursor parent);

unsigned clang_visitChildrenWithBlock(CXCursor parent,
                                      CXCursorVisitorBlock block);
#  endif
#endif

CXString clang_getCursorUSR(CXCursor);

CXString clang_constructUSR_ObjCClass(const char *class_name);

CXString
  clang_constructUSR_ObjCCategory(const char *class_name,
                                 const char *category_name);

CXString
  clang_constructUSR_ObjCProtocol(const char *protocol_name);

CXString clang_constructUSR_ObjCIvar(const char *name,
                                                    CXString classUSR);

CXString clang_constructUSR_ObjCMethod(const char *name,
                                                      unsigned isInstanceMethod,
                                                      CXString classUSR);

CXString clang_constructUSR_ObjCProperty(const char *property,
                                                        CXString classUSR);

CXString clang_getCursorSpelling(CXCursor);

CXSourceRange clang_Cursor_getSpellingNameRange(CXCursor,
                                                          unsigned pieceIndex,
                                                          unsigned options);

CXString clang_getCursorDisplayName(CXCursor);
CXCursor clang_getCursorReferenced(CXCursor);

CXCursor clang_getCursorDefinition(CXCursor);

unsigned clang_isCursorDefinition(CXCursor);

CXCursor clang_getCanonicalCursor(CXCursor);

int clang_Cursor_getObjCSelectorIndex(CXCursor);

int clang_Cursor_isDynamicCall(CXCursor C);

CXType clang_Cursor_getReceiverType(CXCursor C);

typedef enum {
  CXObjCPropertyAttr_noattr    = 0x00,
  CXObjCPropertyAttr_readonly  = 0x01,
  CXObjCPropertyAttr_getter    = 0x02,
  CXObjCPropertyAttr_assign    = 0x04,
  CXObjCPropertyAttr_readwrite = 0x08,
  CXObjCPropertyAttr_retain    = 0x10,
  CXObjCPropertyAttr_copy      = 0x20,
  CXObjCPropertyAttr_nonatomic = 0x40,
  CXObjCPropertyAttr_setter    = 0x80,
  CXObjCPropertyAttr_atomic    = 0x100,
  CXObjCPropertyAttr_weak      = 0x200,
  CXObjCPropertyAttr_strong    = 0x400,
  CXObjCPropertyAttr_unsafe_unretained = 0x800
} CXObjCPropertyAttrKind;

unsigned clang_Cursor_getObjCPropertyAttributes(CXCursor C,
                                                             unsigned reserved);

typedef enum {
  CXObjCDeclQualifier_None = 0x0,
  CXObjCDeclQualifier_In = 0x1,
  CXObjCDeclQualifier_Inout = 0x2,
  CXObjCDeclQualifier_Out = 0x4,
  CXObjCDeclQualifier_Bycopy = 0x8,
  CXObjCDeclQualifier_Byref = 0x10,
  CXObjCDeclQualifier_Oneway = 0x20
} CXObjCDeclQualifierKind;

unsigned clang_Cursor_getObjCDeclQualifiers(CXCursor C);

unsigned clang_Cursor_isObjCOptional(CXCursor C);

unsigned clang_Cursor_isVariadic(CXCursor C);

CXSourceRange clang_Cursor_getCommentRange(CXCursor C);

CXString clang_Cursor_getRawCommentText(CXCursor C);

CXString clang_Cursor_getBriefCommentText(CXCursor C);

CXComment clang_Cursor_getParsedComment(CXCursor C);
typedef void *CXModule;

CXModule clang_Cursor_getModule(CXCursor C);

CXFile clang_Module_getASTFile(CXModule Module);

CXModule clang_Module_getParent(CXModule Module);

CXString clang_Module_getName(CXModule Module);

CXString clang_Module_getFullName(CXModule Module);

unsigned clang_Module_getNumTopLevelHeaders(CXTranslationUnit,
                                                           CXModule Module);


CXFile clang_Module_getTopLevelHeader(CXTranslationUnit,
                                      CXModule Module, unsigned Index);

enum CXCommentKind {
  CXComment_Null = 0,
  CXComment_Text = 1,
  CXComment_InlineCommand = 2,
  CXComment_HTMLStartTag = 3,
  CXComment_HTMLEndTag = 4,
  CXComment_Paragraph = 5,
  CXComment_BlockCommand = 6,
  CXComment_ParamCommand = 7,
  CXComment_TParamCommand = 8,
  CXComment_VerbatimBlockCommand = 9,
  CXComment_VerbatimBlockLine = 10,
  CXComment_VerbatimLine = 11,
  CXComment_FullComment = 12
};

enum CXCommentInlineCommandRenderKind {
  CXCommentInlineCommandRenderKind_Normal,
  CXCommentInlineCommandRenderKind_Bold,
  CXCommentInlineCommandRenderKind_Monospaced,
  CXCommentInlineCommandRenderKind_Emphasized
};

enum CXCommentParamPassDirection {
  CXCommentParamPassDirection_In,
  CXCommentParamPassDirection_Out,
  CXCommentParamPassDirection_InOut
};

enum CXCommentKind clang_Comment_getKind(CXComment Comment);

unsigned clang_Comment_getNumChildren(CXComment Comment);


CXComment clang_Comment_getChild(CXComment Comment, unsigned ChildIdx);

unsigned clang_Comment_isWhitespace(CXComment Comment);


unsigned clang_InlineContentComment_hasTrailingNewline(CXComment Comment);

CXString clang_TextComment_getText(CXComment Comment);


CXString clang_InlineCommandComment_getCommandName(CXComment Comment);

enum CXCommentInlineCommandRenderKind
clang_InlineCommandComment_getRenderKind(CXComment Comment);


unsigned clang_InlineCommandComment_getNumArgs(CXComment Comment);


CXString clang_InlineCommandComment_getArgText(CXComment Comment,
                                               unsigned ArgIdx);

CXString clang_HTMLTagComment_getTagName(CXComment Comment);


unsigned clang_HTMLStartTagComment_isSelfClosing(CXComment Comment);

unsigned clang_HTMLStartTag_getNumAttrs(CXComment Comment);


CXString clang_HTMLStartTag_getAttrName(CXComment Comment, unsigned AttrIdx);


CXString clang_HTMLStartTag_getAttrValue(CXComment Comment, unsigned AttrIdx);


CXString clang_BlockCommandComment_getCommandName(CXComment Comment);


unsigned clang_BlockCommandComment_getNumArgs(CXComment Comment);


CXString clang_BlockCommandComment_getArgText(CXComment Comment,
                                              unsigned ArgIdx);


CXComment clang_BlockCommandComment_getParagraph(CXComment Comment);


CXString clang_ParamCommandComment_getParamName(CXComment Comment);


unsigned clang_ParamCommandComment_isParamIndexValid(CXComment Comment);


unsigned clang_ParamCommandComment_getParamIndex(CXComment Comment);


unsigned clang_ParamCommandComment_isDirectionExplicit(CXComment Comment);


enum CXCommentParamPassDirection clang_ParamCommandComment_getDirection(
                                                            CXComment Comment);


CXString clang_TParamCommandComment_getParamName(CXComment Comment);


unsigned clang_TParamCommandComment_isParamPositionValid(CXComment Comment);


unsigned clang_TParamCommandComment_getDepth(CXComment Comment);


unsigned clang_TParamCommandComment_getIndex(CXComment Comment, unsigned Depth);


CXString clang_VerbatimBlockLineComment_getText(CXComment Comment);

CXString clang_VerbatimLineComment_getText(CXComment Comment);

CXString clang_HTMLTagComment_getAsString(CXComment Comment);

CXString clang_FullComment_getAsHTML(CXComment Comment);

CXString clang_FullComment_getAsXML(CXComment Comment);

unsigned clang_CXXMethod_isPureVirtual(CXCursor C);

unsigned clang_CXXMethod_isStatic(CXCursor C);

unsigned clang_CXXMethod_isVirtual(CXCursor C);

enum CXCursorKind clang_getTemplateCursorKind(CXCursor C);
CXCursor clang_getSpecializedCursorTemplate(CXCursor C);

CXSourceRange clang_getCursorReferenceNameRange(CXCursor C,
                                                unsigned NameFlags, 
                                                unsigned PieceIndex);
enum CXNameRefFlags {
  CXNameRange_WantQualifier = 0x1,
  CXNameRange_WantTemplateArgs = 0x2,
  CXNameRange_WantSinglePiece = 0x4
};
typedef enum CXTokenKind {
  CXToken_Punctuation,
  CXToken_Keyword,
  CXToken_Identifier,
  CXToken_Literal,
  CXToken_Comment
} CXTokenKind;

typedef struct {
  unsigned int_data[4];
  void *ptr_data;
} CXToken;

CXTokenKind clang_getTokenKind(CXToken);

CXString clang_getTokenSpelling(CXTranslationUnit, CXToken);

CXSourceLocation clang_getTokenLocation(CXTranslationUnit,
                                                       CXToken);

CXSourceRange clang_getTokenExtent(CXTranslationUnit, CXToken);

void clang_tokenize(CXTranslationUnit TU, CXSourceRange Range,
                                   CXToken **Tokens, unsigned *NumTokens);

void clang_annotateTokens(CXTranslationUnit TU,
                                         CXToken *Tokens, unsigned NumTokens,
                                         CXCursor *Cursors);

void clang_disposeTokens(CXTranslationUnit TU,
                                        CXToken *Tokens, unsigned NumTokens);

CXString clang_getCursorKindSpelling(enum CXCursorKind Kind);
void clang_getDefinitionSpellingAndExtent(CXCursor,
                                          const char **startBuf,
                                          const char **endBuf,
                                          unsigned *startLine,
                                          unsigned *startColumn,
                                          unsigned *endLine,
                                          unsigned *endColumn);
void clang_enableStackTraces(void);
void clang_executeOnThread(void (*fn)(void*), void *user_data,
                                          unsigned stack_size);

typedef void *CXCompletionString;

typedef struct {
  enum CXCursorKind CursorKind;
  CXCompletionString CompletionString;
} CXCompletionResult;

enum CXCompletionChunkKind {
  CXCompletionChunk_Optional,
  CXCompletionChunk_TypedText,
  CXCompletionChunk_Text,
  CXCompletionChunk_Placeholder,
  CXCompletionChunk_Informative,
  CXCompletionChunk_CurrentParameter,
  CXCompletionChunk_LeftParen,
  CXCompletionChunk_RightParen,
  CXCompletionChunk_LeftBracket,
  CXCompletionChunk_RightBracket,
  CXCompletionChunk_LeftBrace,
  CXCompletionChunk_RightBrace,
  CXCompletionChunk_LeftAngle,
  CXCompletionChunk_RightAngle,
  CXCompletionChunk_Comma,
  CXCompletionChunk_ResultType,
  CXCompletionChunk_Colon,
  CXCompletionChunk_SemiColon,
  CXCompletionChunk_Equal,
  CXCompletionChunk_HorizontalSpace,
  CXCompletionChunk_VerticalSpace
};

enum CXCompletionChunkKind
clang_getCompletionChunkKind(CXCompletionString completion_string,
                             unsigned chunk_number);

CXString
clang_getCompletionChunkText(CXCompletionString completion_string,
                             unsigned chunk_number);

CXCompletionString
clang_getCompletionChunkCompletionString(CXCompletionString completion_string,
                                         unsigned chunk_number);

unsigned
clang_getNumCompletionChunks(CXCompletionString completion_string);

unsigned
clang_getCompletionPriority(CXCompletionString completion_string);
enum CXAvailabilityKind 
clang_getCompletionAvailability(CXCompletionString completion_string);

unsigned
clang_getCompletionNumAnnotations(CXCompletionString completion_string);

CXString
clang_getCompletionAnnotation(CXCompletionString completion_string,
                              unsigned annotation_number);

CXString
clang_getCompletionParent(CXCompletionString completion_string,
                          enum CXCursorKind *kind);

CXString
clang_getCompletionBriefComment(CXCompletionString completion_string);

CXCompletionString
clang_getCursorCompletionString(CXCursor cursor);
typedef struct {
  CXCompletionResult *Results;
  unsigned NumResults;
} CXCodeCompleteResults;

enum CXCodeComplete_Flags {
  CXCodeComplete_IncludeMacros = 0x01,
  CXCodeComplete_IncludeCodePatterns = 0x02,
  CXCodeComplete_IncludeBriefComments = 0x04
};

enum CXCompletionContext {
  CXCompletionContext_Unexposed = 0,
  CXCompletionContext_AnyType = 1 << 0,
  CXCompletionContext_AnyValue = 1 << 1,
  CXCompletionContext_ObjCObjectValue = 1 << 2,
  CXCompletionContext_ObjCSelectorValue = 1 << 3,
  CXCompletionContext_CXXClassTypeValue = 1 << 4,
  CXCompletionContext_DotMemberAccess = 1 << 5,
  CXCompletionContext_ArrowMemberAccess = 1 << 6,
  CXCompletionContext_ObjCPropertyAccess = 1 << 7,
  CXCompletionContext_EnumTag = 1 << 8,
  CXCompletionContext_UnionTag = 1 << 9,
  CXCompletionContext_StructTag = 1 << 10,
  CXCompletionContext_ClassTag = 1 << 11,
  CXCompletionContext_Namespace = 1 << 12,
  CXCompletionContext_NestedNameSpecifier = 1 << 13,
  CXCompletionContext_ObjCInterface = 1 << 14,
  CXCompletionContext_ObjCProtocol = 1 << 15,
  CXCompletionContext_ObjCCategory = 1 << 16,
  CXCompletionContext_ObjCInstanceMessage = 1 << 17,
  CXCompletionContext_ObjCClassMessage = 1 << 18,
  CXCompletionContext_ObjCSelectorName = 1 << 19,
  CXCompletionContext_MacroName = 1 << 20,
  CXCompletionContext_NaturalLanguage = 1 << 21,
  CXCompletionContext_Unknown = ((1 << 22) - 1)
};
unsigned clang_defaultCodeCompleteOptions(void);


CXCodeCompleteResults *clang_codeCompleteAt(CXTranslationUnit TU,
                                            const char *complete_filename,
                                            unsigned complete_line,
                                            unsigned complete_column,
                                            struct CXUnsavedFile *unsaved_files,
                                            unsigned num_unsaved_files,
                                            unsigned options);


void clang_sortCodeCompletionResults(CXCompletionResult *Results,
                                     unsigned NumResults);

void clang_disposeCodeCompleteResults(CXCodeCompleteResults *Results);

unsigned clang_codeCompleteGetNumDiagnostics(CXCodeCompleteResults *Results);


CXDiagnostic clang_codeCompleteGetDiagnostic(CXCodeCompleteResults *Results,
                                             unsigned Index);


unsigned long long clang_codeCompleteGetContexts(
                                                CXCodeCompleteResults *Results);


enum CXCursorKind clang_codeCompleteGetContainerKind(
                                                 CXCodeCompleteResults *Results,
                                                     unsigned *IsIncomplete);


CXString clang_codeCompleteGetContainerUSR(CXCodeCompleteResults *Results);

CXString clang_codeCompleteGetObjCSelector(CXCodeCompleteResults *Results);
CXString clang_getClangVersion(void);
void clang_toggleCrashRecovery(unsigned isEnabled);
typedef void (*CXInclusionVisitor)(CXFile included_file,
                                   CXSourceLocation* inclusion_stack,
                                   unsigned include_len,
                                   CXClientData client_data);

void clang_getInclusions(CXTranslationUnit tu,
                                        CXInclusionVisitor visitor,
                                        CXClientData client_data);

typedef void *CXRemapping;

CXRemapping clang_getRemappings(const char *path);


CXRemapping clang_getRemappingsFromFileList(const char **filePaths,
                                            unsigned numFiles);

unsigned clang_remap_getNumFiles(CXRemapping);

void clang_remap_getFilenames(CXRemapping, unsigned index,
                                     CXString *original, CXString *transformed);

void clang_remap_dispose(CXRemapping);
enum CXVisitorResult {
  CXVisit_Break,
  CXVisit_Continue
};
typedef struct {
  void *context;
  enum CXVisitorResult (*visit)(void *context, CXCursor, CXSourceRange);
} CXCursorAndRangeVisitor;
typedef enum {
  CXResult_Success = 0,
  CXResult_Invalid = 1,
  CXResult_VisitBreak = 2
} CXResult;

CXResult clang_findReferencesInFile(CXCursor cursor, CXFile file,
                                               CXCursorAndRangeVisitor visitor);

CXResult clang_findIncludesInFile(CXTranslationUnit TU,
                                                 CXFile file,
                                              CXCursorAndRangeVisitor visitor);
#ifdef __has_feature
#  if __has_feature(blocks)
typedef enum CXVisitorResult
    (^CXCursorAndRangeVisitorBlock)(CXCursor, CXSourceRange);

CXResult clang_findReferencesInFileWithBlock(CXCursor, CXFile,
                                             CXCursorAndRangeVisitorBlock);

CXResult clang_findIncludesInFileWithBlock(CXTranslationUnit, CXFile,
                                           CXCursorAndRangeVisitorBlock);
#  endif
#endif

typedef void *CXIdxClientFile;

typedef void *CXIdxClientEntity;

typedef void *CXIdxClientContainer;

typedef void *CXIdxClientASTFile;

typedef struct {
  void *ptr_data[2];
  unsigned int_data;
} CXIdxLoc;

typedef struct {
  CXIdxLoc hashLoc;
  const char *filename;
  CXFile file;
  int isImport;
  int isAngled;
  int isModuleImport;
} CXIdxIncludedFileInfo;

typedef struct {
  CXFile file;
  CXModule module;
  CXIdxLoc loc;
  int isImplicit;
} CXIdxImportedASTFileInfo;
typedef enum {
  CXIdxEntity_Unexposed     = 0,
  CXIdxEntity_Typedef       = 1,
  CXIdxEntity_Function      = 2,
  CXIdxEntity_Variable      = 3,
  CXIdxEntity_Field         = 4,
  CXIdxEntity_EnumConstant  = 5,
  CXIdxEntity_ObjCClass     = 6,
  CXIdxEntity_ObjCProtocol  = 7,
  CXIdxEntity_ObjCCategory  = 8,
  CXIdxEntity_ObjCInstanceMethod = 9,
  CXIdxEntity_ObjCClassMethod    = 10,
  CXIdxEntity_ObjCProperty  = 11,
  CXIdxEntity_ObjCIvar      = 12,
  CXIdxEntity_Enum          = 13,
  CXIdxEntity_Struct        = 14,
  CXIdxEntity_Union         = 15,
  CXIdxEntity_CXXClass              = 16,
  CXIdxEntity_CXXNamespace          = 17,
  CXIdxEntity_CXXNamespaceAlias     = 18,
  CXIdxEntity_CXXStaticVariable     = 19,
  CXIdxEntity_CXXStaticMethod       = 20,
  CXIdxEntity_CXXInstanceMethod     = 21,
  CXIdxEntity_CXXConstructor        = 22,
  CXIdxEntity_CXXDestructor         = 23,
  CXIdxEntity_CXXConversionFunction = 24,
  CXIdxEntity_CXXTypeAlias          = 25,
  CXIdxEntity_CXXInterface          = 26
} CXIdxEntityKind;
typedef enum {
  CXIdxEntityLang_None = 0,
  CXIdxEntityLang_C    = 1,
  CXIdxEntityLang_ObjC = 2,
  CXIdxEntityLang_CXX  = 3
} CXIdxEntityLanguage;

typedef enum {
  CXIdxEntity_NonTemplate   = 0,
  CXIdxEntity_Template      = 1,
  CXIdxEntity_TemplatePartialSpecialization = 2,
  CXIdxEntity_TemplateSpecialization = 3
} CXIdxEntityCXXTemplateKind;
typedef enum {
  CXIdxAttr_Unexposed     = 0,
  CXIdxAttr_IBAction      = 1,
  CXIdxAttr_IBOutlet      = 2,
  CXIdxAttr_IBOutletCollection = 3
} CXIdxAttrKind;
typedef struct {
  CXIdxAttrKind kind;
  CXCursor cursor;
  CXIdxLoc loc;
} CXIdxAttrInfo;
typedef struct {
  CXIdxEntityKind kind;
  CXIdxEntityCXXTemplateKind templateKind;
  CXIdxEntityLanguage lang;
  const char *name;
  const char *USR;
  CXCursor cursor;
  const CXIdxAttrInfo *const *attributes;
  unsigned numAttributes;
} CXIdxEntityInfo;
typedef struct {
  CXCursor cursor;
} CXIdxContainerInfo;
typedef struct {
  const CXIdxAttrInfo *attrInfo;
  const CXIdxEntityInfo *objcClass;
  CXCursor classCursor;
  CXIdxLoc classLoc;
} CXIdxIBOutletCollectionAttrInfo;
typedef enum {
  CXIdxDeclFlag_Skipped = 0x1
} CXIdxDeclInfoFlags;
typedef struct {
  const CXIdxEntityInfo *entityInfo;
  CXCursor cursor;
  CXIdxLoc loc;
  const CXIdxContainerInfo *semanticContainer;
  const CXIdxContainerInfo *lexicalContainer;
  int isRedeclaration;
  int isDefinition;
  int isContainer;
  const CXIdxContainerInfo *declAsContainer;
  int isImplicit;
  const CXIdxAttrInfo *const *attributes;
  unsigned numAttributes;
  unsigned flags;
} CXIdxDeclInfo;
typedef enum {
  CXIdxObjCContainer_ForwardRef = 0,
  CXIdxObjCContainer_Interface = 1,
  CXIdxObjCContainer_Implementation = 2
} CXIdxObjCContainerKind;
typedef struct {
  const CXIdxDeclInfo *declInfo;
  CXIdxObjCContainerKind kind;
} CXIdxObjCContainerDeclInfo;
typedef struct {
  const CXIdxEntityInfo *base;
  CXCursor cursor;
  CXIdxLoc loc;
} CXIdxBaseClassInfo;
typedef struct {
  const CXIdxEntityInfo *protocol;
  CXCursor cursor;
  CXIdxLoc loc;
} CXIdxObjCProtocolRefInfo;
typedef struct {
  const CXIdxObjCProtocolRefInfo *const *protocols;
  unsigned numProtocols;
} CXIdxObjCProtocolRefListInfo;
typedef struct {
  const CXIdxObjCContainerDeclInfo *containerInfo;
  const CXIdxBaseClassInfo *superInfo;
  const CXIdxObjCProtocolRefListInfo *protocols;
} CXIdxObjCInterfaceDeclInfo;
typedef struct {
  const CXIdxObjCContainerDeclInfo *containerInfo;
  const CXIdxEntityInfo *objcClass;
  CXCursor classCursor;
  CXIdxLoc classLoc;
  const CXIdxObjCProtocolRefListInfo *protocols;
} CXIdxObjCCategoryDeclInfo;
typedef struct {
  const CXIdxDeclInfo *declInfo;
  const CXIdxEntityInfo *getter;
  const CXIdxEntityInfo *setter;
} CXIdxObjCPropertyDeclInfo;
typedef struct {
  const CXIdxDeclInfo *declInfo;
  const CXIdxBaseClassInfo *const *bases;
  unsigned numBases;
} CXIdxCXXClassDeclInfo;

typedef enum {
  CXIdxEntityRef_Direct = 1,
  CXIdxEntityRef_Implicit = 2
} CXIdxEntityRefKind;

typedef struct {
  CXIdxEntityRefKind kind;
  CXCursor cursor;
  CXIdxLoc loc;
  const CXIdxEntityInfo *referencedEntity;
  const CXIdxEntityInfo *parentEntity;
  const CXIdxContainerInfo *container;
} CXIdxEntityRefInfo;

typedef struct {
  int (*abortQuery)(CXClientData client_data, void *reserved);
  void (*diagnostic)(CXClientData client_data,
                     CXDiagnosticSet, void *reserved);
  CXIdxClientFile (*enteredMainFile)(CXClientData client_data,
                                     CXFile mainFile, void *reserved);
  CXIdxClientFile (*ppIncludedFile)(CXClientData client_data,
                                    const CXIdxIncludedFileInfo *);
  CXIdxClientASTFile (*importedASTFile)(CXClientData client_data,
                                        const CXIdxImportedASTFileInfo *);
  CXIdxClientContainer (*startedTranslationUnit)(CXClientData client_data,
                                                 void *reserved);
  void (*indexDeclaration)(CXClientData client_data,
                           const CXIdxDeclInfo *);
  void (*indexEntityReference)(CXClientData client_data,
                               const CXIdxEntityRefInfo *);
} IndexerCallbacks;
int clang_index_isEntityObjCContainerKind(CXIdxEntityKind);
const CXIdxObjCContainerDeclInfo *
clang_index_getObjCContainerDeclInfo(const CXIdxDeclInfo *);
const CXIdxObjCInterfaceDeclInfo *
clang_index_getObjCInterfaceDeclInfo(const CXIdxDeclInfo *);

const CXIdxObjCCategoryDeclInfo *
clang_index_getObjCCategoryDeclInfo(const CXIdxDeclInfo *);
const CXIdxObjCProtocolRefListInfo *
clang_index_getObjCProtocolRefListInfo(const CXIdxDeclInfo *);
const CXIdxObjCPropertyDeclInfo *
clang_index_getObjCPropertyDeclInfo(const CXIdxDeclInfo *);
const CXIdxIBOutletCollectionAttrInfo *
clang_index_getIBOutletCollectionAttrInfo(const CXIdxAttrInfo *);
const CXIdxCXXClassDeclInfo *
clang_index_getCXXClassDeclInfo(const CXIdxDeclInfo *);

CXIdxClientContainer
clang_index_getClientContainer(const CXIdxContainerInfo *);

void
clang_index_setClientContainer(const CXIdxContainerInfo *,CXIdxClientContainer);

CXIdxClientEntity
clang_index_getClientEntity(const CXIdxEntityInfo *);

void
clang_index_setClientEntity(const CXIdxEntityInfo *, CXIdxClientEntity);

typedef void *CXIndexAction;

CXIndexAction clang_IndexAction_create(CXIndex CIdx);

void clang_IndexAction_dispose(CXIndexAction);
typedef enum {
  CXIndexOpt_None = 0x0,
  CXIndexOpt_SuppressRedundantRefs = 0x1,
  CXIndexOpt_IndexFunctionLocalSymbols = 0x2,
  CXIndexOpt_IndexImplicitTemplateInstantiations = 0x4,
  CXIndexOpt_SuppressWarnings = 0x8,
  CXIndexOpt_SkipParsedBodiesInSession = 0x10
} CXIndexOptFlags;

int clang_indexSourceFile(CXIndexAction,
                                         CXClientData client_data,
                                         IndexerCallbacks *index_callbacks,
                                         unsigned index_callbacks_size,
                                         unsigned index_options,
                                         const char *source_filename,
                                         const char * const *command_line_args,
                                         int num_command_line_args,
                                         struct CXUnsavedFile *unsaved_files,
                                         unsigned num_unsaved_files,
                                         CXTranslationUnit *out_TU,
                                         unsigned TU_options);

int clang_indexTranslationUnit(CXIndexAction,
                                              CXClientData client_data,
                                              IndexerCallbacks *index_callbacks,
                                              unsigned index_callbacks_size,
                                              unsigned index_options,
                                              CXTranslationUnit);

void clang_indexLoc_getFileLocation(CXIdxLoc loc,
                                                   CXIdxClientFile *indexFile,
                                                   CXFile *file,
                                                   unsigned *line,
                                                   unsigned *column,
                                                   unsigned *offset);


CXSourceLocation clang_indexLoc_getCXSourceLocation(CXIdxLoc loc);

]]
local clang = ffi.load("libclang")
local libclang = {}

function libclang.newIndex(pchExcluded, diagnostics)
	return ffi.gc( clang.clang_createIndex(pchExcluded, diagnostics), clang.clang_disposeIndex )
end
function libclang.newMemoryFile( filename, contents )
	local unsavedFile = ffi.new'struct CXUnsavedFile'
	unsavedFile.Filename = filename
	unsavedFile.Contents = contents
	unsavedFile.Length = #contents
	
	return unsavedFile
end

local function cxstring(str)
	local ret = ffi.string(clang.clang_getCString( str ))
	clang.clang_disposeString(str)
	return ret
end

local index = {}
index.__index = index
function index:ParseTranslationUnit( filename, args, files, options )
	files = files or {}
	unsaved = #files ~= 0 and ffi.new('struct CXUnsavedFile[?]', #files, files) or nil
	args = args or {}
	local cargs = #args ~= 0 and ffi.new('const char* const[?]', #args, args) or nil
	return clang.clang_parseTranslationUnit( self, filename, cargs, #args, unsaved, #files, options or 0)
end
ffi.metatype( "struct CXIndexImpl",index )

local trans = {}
trans.__index = trans
function trans:GetFilename()
	return cxstring( clang.clang_getTranslationUnitSpelling( self ) )
end
function trans:__tostring()
	return "TranslationUnit[" .. self:GetFilename() .. "]"
end
function trans:__gc()
	clang.clang_disposeTranslationUnit( self )
end
function trans:GetCursor()
	return clang.clang_getTranslationUnitCursor( self )
end
ffi.metatype( "struct CXTranslationUnitImpl", trans )

local curs = {}
curs.__index = curs
function curs:__tostring()
	return "Cursor ["..self:GetSpelling().."]"
end
function curs:__eq(other)
	return clang.clang_equalCursors( self, other ) == 1
end
function curs:IsVirtual()
	return clang.clang_CXXMethod_isVirtual( self ) == 1
end
function curs:GetParent()
	return clang.clang_getCursorLexicalParent( self )
end
function curs:GetLanguage()
	return clang.clang_getCursorLanguage( self )
end
function curs:GetAvailability()
	return clang.clang_getCursorAvailability( self )
end
function curs:GetKind()
	return clang.clang_getCursorKind( self )
end
function curs:GetKindSpelling()
	return cxstring( clang.clang_getCursorKindSpelling( self ) )
end

function curs:GetLinkage()
	return clang.clang_getCursorLinkage( self )
end
function curs:GetAccess()
	return clang.clang_getCXXAccessSpecifier( self )
end
function curs:GetSpelling()
	return cxstring(clang.clang_getCursorSpelling(self))
end
function curs:GetNumArguments()
	return clang.clang_Cursor_getNumArguments( self )
end
function curs:GetArgument( i )
	return clang.clang_Cursor_getArgument( self, i )
end
function curs:GetEnumValue()
	return clang.clang_GetEnumConstantDeclValue( self )
end
function curs:GetArguments()
	local ret = {}
	for i = 1, self:GetNumArguments() do
		table.insert( ret, self:GetArgument( i - 1 ) )
	end
	return ret
end
function curs:IsVariadic()
	return clang.clang_isFunctionTypeVariadic( self ) == 1
end
function curs:GetType()
	return clang.clang_getCursorType( self )
end
function curs:GetReturnType()
	return clang.clang_getResultType( self:GetType() )
end
local line, column, offset = ffi.new("unsigned[1]"), ffi.new("unsigned[1]"), ffi.new("unsigned[1]")
local function breakLocation( loc, func )
	
	if func == clang.clang_getPresumedLocation then
		local file = ffi.new("CXString[1]")
		func( loc, file, line, column )
		return file[0] ~= nil and cxstring( file[0] ), line[0], column[0], offset[0]
	else
		local file = ffi.new("CXFile[1]")
		func( loc, file, line, column, offset )
		return file[0] ~= nil and cxstring( clang.clang_getFileName( file[0] ) ), line[0], column[0], offset[0]
	end
	
end
function curs:GetSpellingLocation()
	return breakLocation( clang.clang_getCursorLocation( self ), clang.clang_getSpellingLocation )
end
function curs:GetPresumedLocation()
	return breakLocation( clang.clang_getCursorLocation( self ), clang.clang_getPresumedLocation )
end
function curs:GetExpansionLocation()
	return breakLocation( clang.clang_getCursorLocation( self ), clang.clang_getExpansionLocation )
end
function curs:GetInstantiationLocation()
	return breakLocation( clang.clang_getCursorLocation( self ), clang.clang_getInstantiationLocation )
end

function curs:GetTypeSpelling(ret)
	return cxstring( clang.clang_getTypeSpelling( ret and self:GetReturnType() or self:GetType() ) )
end

ffi.cdef[[
typedef enum CXChildVisitResult (*lua_visitor)(CXCursor *cursor, CXCursor *parent, void *ud);
typedef struct {
lua_visitor visitor;
void *ud;
} HelperVisitorUD;
enum CXChildVisitResult clang_devastation(CXCursor cursor, CXCursor parent, CXClientData ud);
]]
local terrible = ffi.load'clang_devastating.dll'

function curs:Iterate( callback, recursive )
	local cb = ffi.cast("lua_visitor",function(cursor, parent, ud)
		cursor = cursor[0]
		parent = parent[0]
		
		callback( cursor, parent )
		
		return recursive and 2 or 1
	end)
	local wrapper = ffi.new("HelperVisitorUD", cb,nil)
	clang.clang_visitChildren( self, terrible.clang_devastation, wrapper )

	cb:free()
end
function curs:Iterator( recursive )
	local ret = {}
	local cb = ffi.cast("lua_visitor",function(self, parent, ud)
		table.insert( ret, {self[0], parent[0]} )
		return recursive and 2 or 1
	end)
	local wrapper = ffi.new("HelperVisitorUD", cb,nil)
	clang.clang_visitChildren( self, terrible.clang_devastation, wrapper )
	cb:free()
	
	local i, v
	return function()
		i, v = next( ret, i )
		if i then
			return v[1], v[2]
		end
	end
end

ffi.metatype( "CXCursor", curs )


local idx = libclang.newIndex(false,true)
local tests = libclang.newMemoryFile( "main.cpp", [[
class HelloWorld{
public:
HelloWorld(){
	this->aids = 1;
}
void printAids(){
	printf("Aids: %d\n", this->aids);
}
private:
	int aids;
};
int main(){
	HelloWorld aids;
	return 0;
}
]])

local transunit = idx:ParseTranslationUnit( "../../src/bullet3/src/omg.cpp", {"-I../../src/bullet3/src"}, {} )

if transunit == nil then error'nope' end

local cursor = transunit:GetCursor()

local typedef = ""
local cdef = ""
local def = ""
local cpp = ""
local includes = {}
local included = ""
local lua = ""
local luadef = ""
local defined = {}
local function addInclude( path )
	if not table.hasvalue( includes, path ) then table.insert( includes, path ) included = included .. string.format("#include <%s>\n", path) end
end
local cancer = 0
local function parseArgs( cursor )
	local args = cursor:GetArguments()
	local ret = {}
	local ret2 = {}
	for k,v in pairs( args ) do
		local aids = v:GetSpelling()
		if not aids or #aids == 0 then cancer = cancer + 1 aids = "aids" .. cancer end
		table.insert( ret, string.format( "%s %s", v:GetTypeSpelling(), aids ) )
		table.insert( ret2, aids )
	end
	return ret, table.concat( ret2, ", " )
end
local pretty = {}
cursor:Iterate(function(c)
	--if( c:IsVirtual()) then return end
	local path = c:GetSpellingLocation()
	if not path or not path:find"%.h" then return end
	addInclude( path )
	if c:GetKind() == clang.CXCursor_ClassDecl then
		local name = c:GetSpelling()
		
		if defined[name] then return end
		pretty[name] = pretty[name] or {}
		defined[name] = true
		local ln = "C"..name
		
		typedef = typedef .. string.format( "typedef void* %s;\n", name )
		lua = lua .. ln .. " = {} " .. ln .. ".__index = " .. ln .. " ffi.metatype( \"" .. name .. '", ' .. ln .. ' )\n'
		c:Iterate( function( c )
			--if( c:IsVirtual()) then return end
			if c:GetAccess() ~= clang.CX_CXXPublic then return end
			local kind = c:GetKind()
			if kind == clang.CXCursor_Constructor then
				local suffix = ""
				if pretty[name][name] then
					pretty[name][name] = pretty[name][name] + 1
					suffix = "_" .. pretty[name][name]
				else pretty[name][name] = 0 end
				local args, args2 = parseArgs( c )
				
				cdef = cdef .. string.format( "void* %s__" .. suffix .. "(%s);\n", name, args2 )
				luadef = luadef .. string.format( "%s* %s__" .. suffix .. "(%s);\n", name, name, table.concat( args, ", " ) )
				
				def = def .. ( string.format( "function %s:new" .. suffix .. "(...) return dll.%s__(...) end\n", ln, name ) )
				cpp = cpp .. string.format( "\tEXPORT void* %s__" .. suffix .. "(%s){ return (void*)new %s(%s); };\n", name, name,name, args2 )
			elseif kind == clang.CXCursor_CXXMethod and not c:GetSpelling():find'operator' then
				local suffix = ""
				if pretty[name][c:GetSpelling()] then
					pretty[name][c:GetSpelling()] = pretty[name][c:GetSpelling()] + 1
					suffix = "_" .. pretty[name][c:GetSpelling()]
				else pretty[name][c:GetSpelling()] = 0 end
				
				local args, args2 = parseArgs( c )
				local parsed = #args == 0 and "" or ( ", " .. table.concat( args, ", " ) )
				local taip = c:GetTypeSpelling(true)
				local cheat = not(taip:find("bool") or taip:find"int" or taip:find"char" or taip:find"void" or taip:find"long" or taip:find"float" or taip:find"double")
				local cheater = cheat and "void*" or taip
				cdef = cdef .. string.format( "%s %s_%s" .. suffix .. "(%s* self%s);\n", cheater, name, c:GetSpelling(), name, parsed )
				def = def .. ( string.format( "function %s:%s" .. suffix .. "(...) return dll.%s_%s( self, ... ) end\n", ln, c:GetSpelling(), name, c:GetSpelling() ) )
				
				
				cpp = cpp .. string.format( "\tEXPORT %s %s__%s" .. suffix .. "(%s* self%s){ %sself->%s(%s); };\n", cheater, name, c:GetSpelling(), name, parsed, c:GetTypeSpelling(true)=="void" and "" or "return " .. (cheat and "(void*)" or ""), c:GetSpelling(), args2 )
			end
			
		end )
		
	end
	
end,false)
vfs.Write( "out.lua", "\nffi.cdef[[" .. typedef:trim() .. "\n" .. luadef:trim() .. "]]\n" .. lua .. "\nlocal dll = ffi.load'bulletphysics3.dll'\n"..def:trim() )
vfs.Write( "out.cpp", "\nextern \"C\" {\n" .. cpp:trim() .. '\n}' )
vfs.Write( "out.h", "#ifdef _MSC_VER\n#define EXPORT __declspec(dllexport)\n#else\n#define EXPORT __attribute__((dllexport))\n#endif\n" .. cdef:trim())