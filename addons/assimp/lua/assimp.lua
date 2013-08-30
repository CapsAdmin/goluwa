ffi.cdef[[
typedef struct{
	float x,y;
}aiVector2D;

typedef struct{

	float x,y,z;
}aiVector3D;

typedef struct
{
	float a,b,c,d;
}aiPlane;

typedef struct
{
	aiVector3D pos, dir;
}aiRay;

typedef struct
{
	float r, g, b;
}aiColor3D;

typedef struct
{
	size_t length;
	char data[1024];
}aiString; 

typedef struct
{
} aiFile;

typedef struct {
	float a1, a2, a3, a4;
	float b1, b2, b3, b4;
	float c1, c2, c3, c4;
	float d1, d2, d3, d4;
} aiMatrix4x4;

typedef struct {

	float a1, a2, a3;
	float b1, b2, b3;
	float c1, c2, c3;
}aiMatrix3x3;

 
typedef enum
{
	aiReturn_SUCCESS = 0x0,
	aiReturn_FAILURE = -0x1,
	aiReturn_OUTOFMEMORY = -0x3,
	_AI_ENFORCE_ENUM_SIZE = 0x7fffffff 
}aiReturn;
 

typedef enum
{
	aiOrigin_SET = 0x0,
	aiOrigin_CUR = 0x1,
	aiOrigin_END = 0x2,
	_AI_ORIGIN_ENFORCE_ENUM_SIZE = 0x7fffffff 
}aiOrigin;



typedef struct{float r, g, b, a;} aiColor4D;

typedef struct {} aiFileIO;
typedef struct {} aiFile;  
 
typedef size_t   (*aiFileWriteProc) (aiFile*,   const char*, size_t, size_t);
typedef size_t   (*aiFileReadProc)  (aiFile*,   char*, size_t,size_t);
typedef size_t   (*aiFileTellProc)  (aiFile*);
typedef void     (*aiFileFlushProc) (aiFile*);
typedef aiReturn (*aiFileSeek)(aiFile*, size_t, aiOrigin);
typedef aiFile* (*aiFileOpenProc)  (aiFileIO*, const char*, const char*);
typedef void    (*aiFileCloseProc) (aiFileIO*, aiFile*);

typedef char* aiUserData; 

typedef struct
{
	aiFileOpenProc OpenProc;
	aiFileCloseProc CloseProc;
	aiUserData UserData;
}aiFileIO; 
 
typedef struct
{
	aiFileReadProc ReadProc;
	aiFileWriteProc WriteProc;
	aiFileTellProc TellProc;
	aiFileTellProc FileSizeProc;
	aiFileSeek SeekProc;
	aiFileFlushProc FlushProc;
	aiUserData UserData;
}aiFile;

enum aiDefaultLogStream	
{
	aiDefaultLogStream_FILE = 0x1,
	aiDefaultLogStream_STDOUT = 0x2,
	aiDefaultLogStream_STDERR = 0x4,
	aiDefaultLogStream_DEBUGGER = 0x8,
	_AI_DLS_ENFORCE_ENUM_SIZE = 0x7fffffff 
};

struct aiMemoryInfo
{
	unsigned int textures;
	unsigned int materials;
	unsigned int meshes;
	unsigned int nodes;
	unsigned int animations;
	unsigned int cameras;
	unsigned int lights;
	unsigned int total;
};

struct aiPropertyStore { char sentinel; };
typedef bool aiBool;

typedef void (*aiLogStreamCallback)(const char* /* message */, char* /* user */);

typedef struct 
{
	aiLogStreamCallback callback;
	char* user;
}aiLogStream ;

typedef enum
{
	aiLightSource_UNDEFINED     = 0x0,
	aiLightSource_DIRECTIONAL   = 0x1,
	aiLightSource_POINT         = 0x2,
	aiLightSource_SPOT          = 0x3,
} aiLightSourceType;

typedef struct
{
	aiString mName;
	aiLightSourceType mType;
	aiVector3D mPosition;
	aiVector3D mDirection;
	float mAttenuationConstant;
	float mAttenuationLinear;
	float mAttenuationQuadratic;
	aiColor3D mColorDiffuse;
	aiColor3D mColorSpecular;
	aiColor3D mColorAmbient;
	float mAngleInnerCone;
	float mAngleOuterCone;
}aiLight; 

typedef enum
{
	aiTextureOp_Multiply = 0x0,
	aiTextureOp_Add = 0x1,
	aiTextureOp_Subtract = 0x2,
	aiTextureOp_Divide = 0x3,
	aiTextureOp_SmoothAdd = 0x4,
	aiTextureOp_SignedAdd = 0x5,
}aiTextureOp;

typedef enum
{
    aiTextureMapMode_Wrap = 0x0,
    aiTextureMapMode_Clamp = 0x1,
    aiTextureMapMode_Decal = 0x3,
    aiTextureMapMode_Mirror = 0x2,
}aiTextureMapMode;
typedef enum
{
    aiTextureMapping_UV = 0x0,
    aiTextureMapping_SPHERE = 0x1,
    aiTextureMapping_CYLINDER = 0x2,
    aiTextureMapping_BOX = 0x3,
    aiTextureMapping_PLANE = 0x4,
    aiTextureMapping_OTHER = 0x5,
}aiTextureMapping;
typedef enum
{
	aiTextureType_NONE = 0x0,
    aiTextureType_DIFFUSE = 0x1,
    aiTextureType_SPECULAR = 0x2,
    aiTextureType_AMBIENT = 0x3,
    aiTextureType_EMISSIVE = 0x4,
    aiTextureType_HEIGHT = 0x5,
    aiTextureType_NORMALS = 0x6,
    aiTextureType_SHININESS = 0x7,
    aiTextureType_OPACITY = 0x8,
    aiTextureType_DISPLACEMENT = 0x9,
    aiTextureType_LIGHTMAP = 0xA,
    aiTextureType_REFLECTION = 0xB,
    aiTextureType_UNKNOWN = 0xC,
}aiTextureType;
enum aiShadingMode
{
    aiShadingMode_Flat = 0x1,
    aiShadingMode_Gouraud =	0x2,
    aiShadingMode_Phong = 0x3,
    aiShadingMode_Blinn	= 0x4,
    aiShadingMode_Toon = 0x5,
    aiShadingMode_OrenNayar = 0x6,
    aiShadingMode_Minnaert = 0x7,
    aiShadingMode_CookTorrance = 0x8,
    aiShadingMode_NoShading = 0x9,
    aiShadingMode_Fresnel = 0xa,
};
enum aiTextureFlags
{
	aiTextureFlags_Invert = 0x1,
	aiTextureFlags_UseAlpha = 0x2,
	aiTextureFlags_IgnoreAlpha = 0x4,
};
enum aiBlendMode
{
	aiBlendMode_Default = 0x0,
	aiBlendMode_Additive = 0x1,
};
struct aiUVTransform
{
	aiVector2D mTranslation;
	aiVector2D mScaling;
	float mRotation;
};
typedef enum
{
    aiPTI_Float   = 0x1,
    aiPTI_String  = 0x3,
    aiPTI_Integer = 0x4,
    aiPTI_Buffer  = 0x5,
}aiPropertyTypeInfo;

typedef struct
{
    aiString mKey;
	unsigned int mSemantic;
	unsigned int mIndex;
    unsigned int mDataLength;
    aiPropertyTypeInfo mType;
    char* mData;
}aiMaterialProperty;


typedef struct
{
    aiMaterialProperty** mProperties;
    unsigned int mNumProperties;
    unsigned int mNumAllocated;
}aiMaterial;

typedef struct
{
    aiMaterialProperty** mProperties;
    unsigned int mNumProperties;
    unsigned int mNumAllocated;
}aiMaterialaiMaterial;

aiReturn aiGetMaterialProperty(
	 const aiMaterial* pMat, 
    const char* pKey,
	 unsigned int type,
    unsigned int  index,
    const aiMaterialProperty** pPropOut);
aiReturn aiGetMaterialFloatArray(
	 const aiMaterial* pMat, 
    const char* pKey,
	 unsigned int type,
    unsigned int index,
    float* pOut,
    unsigned int* pMax);
aiReturn aiGetMaterialIntegerArray(const aiMaterial* pMat, 
    const char* pKey,
	 unsigned int  type,
	 unsigned int  index,
    int* pOut,
    unsigned int* pMax);
aiReturn aiGetMaterialColor(const aiMaterial* pMat, 
    const char* pKey,
	 unsigned int type,
    unsigned int index,
	 aiColor4D* pOut);
aiReturn aiGetMaterialString(const aiMaterial* pMat, 
    const char* pKey,
	 unsigned int type,
    unsigned int index,
    aiString* pOut); 
unsigned int aiGetMaterialTextureCount(const aiMaterial* pMat,  
	aiTextureType type);

aiReturn aiGetMaterialTexture(const aiMaterial* mat,
    aiTextureType type,
    unsigned int  index,
    aiString* path,
	aiTextureMapping* mapping,
    unsigned int* uvindex,
    float* blend,
    aiTextureOp* op,
	aiTextureMapMode* mapmode,
	unsigned int* flags
); 

struct aiExportFormatDesc
{
	const char* id; 
	const char* description;
	const char* fileExtension;
};

typedef struct{} aiNode;
typedef struct{} aiMesh;
typedef struct{} aiMaterial;
typedef struct{} aiAnimation;
typedef struct{} aiTexture;
typedef struct{} aiLight;
typedef struct{} aiCamera;
typedef struct{} aiVertexWeight;
typedef struct{} aiFileIO;
typedef struct{} aiPropertyStore; 
typedef struct{} aiLogStream; 
typedef struct{} aiDefaultLogStream; 
typedef struct{} aiReturn; 
typedef struct{} aiMemoryInfo; 
typedef struct{} aiQuaternion; 
typedef struct{} aiExportFormatDesc;
typedef struct{} aiExportDataBlob;

typedef struct
{
	aiString mName;
	aiMatrix4x4 mTransformation;
	aiNode* mParent;
	unsigned int mNumChildren;
	aiNode** mChildren;
	unsigned int mNumMeshes;
	unsigned int* mMeshes;
}aiNode;


typedef struct
{
	unsigned int mFlags;
	aiNode* mRootNode;
	unsigned int mNumMeshes;
	aiMesh** mMeshes;
	unsigned int mNumMaterials;
	aiMaterial** mMaterials;
	unsigned int mNumAnimations; 
	aiAnimation** mAnimations;
	unsigned int mNumTextures;
	aiTexture** mTextures;
	unsigned int mNumLights;
	aiLight** mLights;
	unsigned int mNumCameras;
	aiCamera** mCameras;
}aiScene;

enum aiPostProcessSteps
{
	aiProcess_CalcTangentSpace = 0x1,
	aiProcess_JoinIdenticalVertices = 0x2,
	aiProcess_MakeLeftHanded = 0x4,
	aiProcess_Triangulate = 0x8,
	aiProcess_RemoveComponent = 0x10,
	aiProcess_GenNormals = 0x20,
	aiProcess_GenSmoothNormals = 0x40,
	aiProcess_SplitLargeMeshes = 0x80,
	aiProcess_PreTransformVertices = 0x100,
	aiProcess_LimitBoneWeights = 0x200,
	aiProcess_ValidateDataStructure = 0x400,
	aiProcess_ImproveCacheLocality = 0x800,
	aiProcess_RemoveRedundantMaterials = 0x1000,
	aiProcess_FixInfacingNormals = 0x2000,
	aiProcess_SortByPType = 0x8000,
	aiProcess_FindDegenerates = 0x10000,
	aiProcess_FindInvalidData = 0x20000,
	aiProcess_GenUVCoords = 0x40000,
	aiProcess_TransformUVCoords = 0x80000,
	aiProcess_FindInstances = 0x100000,
	aiProcess_OptimizeMeshes  = 0x200000, 
	aiProcess_OptimizeGraph  = 0x400000, 
	aiProcess_FlipUVs = 0x800000, 
	aiProcess_FlipWindingOrder  = 0x1000000,
	aiProcess_SplitByBoneCount  = 0x2000000,
	aiProcess_Debone  = 0x4000000
};

struct aiCamera
{
	aiString mName;
	aiVector3D mPosition;
	aiVector3D mUp;
	aiVector3D mLookAt;
	float mHorizontalFOV;
	float mClipPlaneNear;
	float mClipPlaneFar;
	float mAspect;
};

typedef struct
{
	unsigned int mNumIndices;
	unsigned int* mIndices;   
}aiFace;

typedef struct
{
	unsigned int mVertexId;
	float mWeight;
}aiVertexWeight;

typedef struct
{
	aiString mName;
	unsigned int mNumWeights;
	aiVertexWeight* mWeights;
	aiMatrix4x4 mOffsetMatrix;
}aiBone;

enum aiPrimitiveType
{
	aiPrimitiveType_POINT       = 0x1,
	aiPrimitiveType_LINE        = 0x2,
	aiPrimitiveType_TRIANGLE    = 0x4,
	aiPrimitiveType_POLYGON     = 0x8,
};

typedef struct
{
	aiVector3D* mVertices;
	aiVector3D* mNormals;
	aiVector3D* mTangents;
	aiVector3D* mBitangents;
	aiColor4D* mColors[8];
	aiVector3D* mTextureCoords[8];
	unsigned int mNumVertices;
} aiAnimMesh;

typedef struct
{
	unsigned int mPrimitiveTypes;
	unsigned int mNumVertices;
	unsigned int mNumFaces;
	aiVector3D* mVertices;
	aiVector3D* mNormals;
	aiVector3D* mTangents;
	aiVector3D* mBitangents;
	aiColor4D* mColors[8];
	aiVector3D* mTextureCoords[8];
	unsigned int mNumUVComponents[8];
	aiFace* mFaces;
	unsigned int mNumBones;
	aiBone** mBones;
	unsigned int mMaterialIndex;
	aiString mName;
	unsigned int mNumAnimMeshes;
	aiAnimMesh** mAnimMeshes;
}aiMesh;

enum aiImporterFlags 
{
	aiImporterFlags_SupportTextFlavour = 0x1,
	aiImporterFlags_SupportBinaryFlavour = 0x2,
	aiImporterFlags_SupportCompressedFlavour = 0x4,
	aiImporterFlags_LimitedSupport = 0x8,
	aiImporterFlags_Experimental = 0x10,
};
struct aiImporterDesc 
{
	const char* mName;
	const char* mAuthor;
	const char* mMaintainer;
	const char* mComments;
	unsigned int mFlags;
	unsigned int mMinMajor;
	unsigned int mMinMinor;
	unsigned int mMaxMajor;
	unsigned int mMaxMinor;
	const char* mFileExtensions;
};

typedef struct
{
	unsigned char b,g,r,a;
} aiTexel;

struct aiTexture
{
	unsigned int mWidth;
	unsigned int mHeight;
	char achFormatHint[4];
	aiTexel* pcData;
};

const aiScene* aiImportFile( const char* pFile, unsigned int pFlags);
const aiScene* aiImportFileEx( const char* pFile,unsigned int pFlags,aiFileIO* pFS);
const aiScene* aiImportFileExWithProperties(const char* pFile,unsigned int pFlags,aiFileIO* pFS,const aiPropertyStore* pProps);
const aiScene* aiImportFileFromMemory(const char* pBuffer,unsigned int pLength,unsigned int pFlags,const char* pHint);
const aiScene* aiImportFileFromMemoryWithProperties(const char* pBuffer,unsigned int pLength,unsigned int pFlags,const char* pHint,const aiPropertyStore* pProps);
const aiScene* aiApplyPostProcessing(const aiScene* pScene,unsigned int pFlags);
aiLogStream aiGetPredefinedLogStream(aiDefaultLogStream pStreams,const char* file);
void aiAttachLogStream(const aiLogStream* stream);
void aiEnableVerboseLogging(aiBool d);
aiReturn aiDetachLogStream(const aiLogStream* stream);
void aiDetachAllLogStreams(void);
void aiReleaseImport(const aiScene* pScene);
const char* aiGetErrorString();
aiBool aiIsExtensionSupported(const char* szExtension);
void aiGetExtensionList(aiString* szOut);
void aiGetMemoryRequirements(const aiScene* pIn,aiMemoryInfo* in);
aiPropertyStore* aiCreatePropertyStore(void);
void aiReleasePropertyStore(aiPropertyStore* p);
void aiSetImportPropertyInteger(aiPropertyStore* store,const char* szName, int value);
void aiSetImportPropertyFloat(aiPropertyStore* store,const char* szName,float value);
void aiSetImportPropertyString(aiPropertyStore* store,const char* szName,const aiString* st);
void aiCreateQuaternionFromMatrix(aiQuaternion* quat,const aiMatrix3x3* mat);
void aiDecomposeMatrix(const aiMatrix4x4* mat,aiVector3D* scaling, aiQuaternion* rotation,aiVector3D* position);
void aiTransposeMatrix4(aiMatrix4x4* mat);
void aiTransposeMatrix3(aiMatrix3x3* mat);
void aiTransformVecByMatrix3(aiVector3D* vec, const aiMatrix3x3* mat);
void aiTransformVecByMatrix4(aiVector3D* vec, const aiMatrix4x4* mat);
void aiMultiplyMatrix4(aiMatrix4x4* dst, const aiMatrix4x4* src);
void aiMultiplyMatrix3(aiMatrix3x3* dst, const aiMatrix3x3* src);
void aiIdentityMatrix3(aiMatrix3x3* mat);
void aiIdentityMatrix4(aiMatrix4x4* mat);
size_t aiGetExportFormatCount(void);
const aiExportFormatDesc* aiGetExportFormatDescription( size_t pIndex);
void aiCopyScene(const aiScene* pIn, aiScene** pOut);
aiReturn aiExportScene(const aiScene* pScene, const char* pFormatId, const char* pFileName,  unsigned int pPreprocessing);
aiReturn aiExportSceneEx(const aiScene* pScene,const char* pFormatId, const char* pFileName, aiFileIO* pIO,  unsigned int pPreprocessing );
	
typedef struct 
{
	size_t size; 
	void* data;
	aiString name;
	aiExportDataBlob * next;
}aiExportDataBlob; 

const aiExportDataBlob* aiExportSceneToBlob( const aiScene* pScene, const char* pFormatId,  unsigned int pPreprocessing );
void aiReleaseExportBlob( const aiExportDataBlob* pData );
]]

--[[


#define aiProcess_ConvertToLeftHanded ( \
	aiProcess_MakeLeftHanded     | \
	aiProcess_FlipUVs            | \
	aiProcess_FlipWindingOrder   | \
	0 ) 


#define aiProcessPreset_TargetRealtime_Fast ( \
	aiProcess_CalcTangentSpace		|  \
	aiProcess_GenNormals			|  \
	aiProcess_JoinIdenticalVertices |  \
	aiProcess_Triangulate			|  \
	aiProcess_GenUVCoords           |  \
	aiProcess_SortByPType           |  \
	0 )

#define aiProcessPreset_TargetRealtime_Quality ( \
	aiProcess_CalcTangentSpace				|  \
	aiProcess_GenSmoothNormals				|  \
	aiProcess_JoinIdenticalVertices			|  \
	aiProcess_ImproveCacheLocality			|  \
	aiProcess_LimitBoneWeights				|  \
	aiProcess_RemoveRedundantMaterials      |  \
	aiProcess_SplitLargeMeshes				|  \
	aiProcess_Triangulate					|  \
	aiProcess_GenUVCoords                   |  \
	aiProcess_SortByPType                   |  \
	aiProcess_FindDegenerates               |  \
	aiProcess_FindInvalidData               |  \
	0 )


#define aiProcessPreset_TargetRealtime_MaxQuality ( \
	aiProcessPreset_TargetRealtime_Quality   |  \
	aiProcess_FindInstances                  |  \
	aiProcess_ValidateDataStructure          |  \
	aiProcess_OptimizeMeshes                 |  \
	aiProcess_Debone						 |  \
	0 )
	
	
#define AI_SCENE_FLAGS_INCOMPLETE	0x1
#define AI_SCENE_FLAGS_VALIDATED	0x2
#define AI_SCENE_FLAGS_VALIDATION_WARNING  	0x4
#define AI_SCENE_FLAGS_NON_VERBOSE_FORMAT  	0x8
#define AI_SCENE_FLAGS_TERRAIN 0x10
]]

local module = ffi.load("assimp")

local assimp = {}

function assimp.Decode(data)
	
	local data = module.aiImportFileFromMemory(data, #data, flags or 0, hint or "")
		
	if data == nil then
		return false, ffi.string(module.aiGetErrorString())
	end
		
	return data
end

local scene = assimp.Decode(vfs.Read("models/hair27.obj"))
--print(ffi.cast("aiMesh", ffi.cast("aiScene *", scene.mMeshes)[0]).mNumFaces)
