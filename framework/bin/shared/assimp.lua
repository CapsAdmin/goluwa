				local ffi = require("ffi")
				local lib = assert(ffi.load("assimp"))
				ffi.cdef([[typedef enum aiAnimBehaviour{aiAnimBehaviour_DEFAULT=0,aiAnimBehaviour_CONSTANT=1,aiAnimBehaviour_LINEAR=2,aiAnimBehaviour_REPEAT=3};
typedef enum aiBlendMode{aiBlendMode_Default=0,aiBlendMode_Additive=1};
typedef enum aiComponent{aiComponent_NORMALS=2,aiComponent_TANGENTS_AND_BITANGENTS=4,aiComponent_COLORS=8,aiComponent_TEXCOORDS=16,aiComponent_BONEWEIGHTS=32,aiComponent_ANIMATIONS=64,aiComponent_TEXTURES=128,aiComponent_LIGHTS=256,aiComponent_CAMERAS=512,aiComponent_MESHES=1024,aiComponent_MATERIALS=2048};
typedef enum aiDefaultLogStream{aiDefaultLogStream_FILE=1,aiDefaultLogStream_STDOUT=2,aiDefaultLogStream_STDERR=4,aiDefaultLogStream_DEBUGGER=8};
typedef enum aiImporterFlags{aiImporterFlags_SupportTextFlavour=1,aiImporterFlags_SupportBinaryFlavour=2,aiImporterFlags_SupportCompressedFlavour=4,aiImporterFlags_LimitedSupport=8,aiImporterFlags_Experimental=16};
typedef enum aiLightSourceType{aiLightSource_UNDEFINED=0,aiLightSource_DIRECTIONAL=1,aiLightSource_POINT=2,aiLightSource_SPOT=3,aiLightSource_AMBIENT=4,aiLightSource_AREA=5};
typedef enum aiMetadataType{aiBOOL=0,aiINT32=1,aiUINT64=2,aiFLOAT=3,aiDOUBLE=4,aiAISTRING=5,aiAIVECTOR3D=6,aiAIMETADATA=7,aiMETA_MAX=8};
typedef enum aiMorphingMethod{aiMorphingMethod_VERTEX_BLEND=1,aiMorphingMethod_MORPH_NORMALIZED=2,aiMorphingMethod_MORPH_RELATIVE=3};
typedef enum aiOrigin{aiOrigin_SET=0,aiOrigin_CUR=1,aiOrigin_END=2};
typedef enum aiPostProcessSteps{aiProcess_CalcTangentSpace=1,aiProcess_JoinIdenticalVertices=2,aiProcess_MakeLeftHanded=4,aiProcess_Triangulate=8,aiProcess_RemoveComponent=16,aiProcess_GenNormals=32,aiProcess_GenSmoothNormals=64,aiProcess_SplitLargeMeshes=128,aiProcess_PreTransformVertices=256,aiProcess_LimitBoneWeights=512,aiProcess_ValidateDataStructure=1024,aiProcess_ImproveCacheLocality=2048,aiProcess_RemoveRedundantMaterials=4096,aiProcess_FixInfacingNormals=8192,aiProcess_PopulateArmatureData=16384,aiProcess_SortByPType=32768,aiProcess_FindDegenerates=65536,aiProcess_FindInvalidData=131072,aiProcess_GenUVCoords=262144,aiProcess_TransformUVCoords=524288,aiProcess_FindInstances=1048576,aiProcess_OptimizeMeshes=2097152,aiProcess_OptimizeGraph=4194304,aiProcess_FlipUVs=8388608,aiProcess_FlipWindingOrder=16777216,aiProcess_SplitByBoneCount=33554432,aiProcess_Debone=67108864,aiProcess_GlobalScale=134217728,aiProcess_EmbedTextures=268435456,aiProcess_ForceGenNormals=536870912,aiProcess_DropNormals=1073741824,aiProcess_GenBoundingBoxes=2147483648};
typedef enum aiPrimitiveType{aiPrimitiveType_POINT=1,aiPrimitiveType_LINE=2,aiPrimitiveType_TRIANGLE=4,aiPrimitiveType_POLYGON=8,aiPrimitiveType_NGONEncodingFlag=16};
typedef enum aiProcessHack{aiProcess_ConvertToLeftHanded=25165828,aiProcessPreset_TargetRealtime_Fast=294955,aiProcessPreset_TargetRealtime_Quality=498379,aiProcessPreset_TargetRealtime_MaxQuality=3645131};
typedef enum aiPropertyTypeInfo{aiPTI_Float=1,aiPTI_Double=2,aiPTI_String=3,aiPTI_Integer=4,aiPTI_Buffer=5};
typedef enum aiReturn{aiReturn_SUCCESS=0,aiReturn_FAILURE=-1,aiReturn_OUTOFMEMORY=-3};
typedef enum aiShadingMode{aiShadingMode_Flat=1,aiShadingMode_Gouraud=2,aiShadingMode_Phong=3,aiShadingMode_Blinn=4,aiShadingMode_Toon=5,aiShadingMode_OrenNayar=6,aiShadingMode_Minnaert=7,aiShadingMode_CookTorrance=8,aiShadingMode_NoShading=9,aiShadingMode_Unlit=9,aiShadingMode_Fresnel=10,aiShadingMode_PBR_BRDF=11};
typedef enum aiTextureFlags{aiTextureFlags_Invert=1,aiTextureFlags_UseAlpha=2,aiTextureFlags_IgnoreAlpha=4};
typedef enum aiTextureMapMode{aiTextureMapMode_Wrap=0,aiTextureMapMode_Clamp=1,aiTextureMapMode_Decal=3,aiTextureMapMode_Mirror=2};
typedef enum aiTextureMapping{aiTextureMapping_UV=0,aiTextureMapping_SPHERE=1,aiTextureMapping_CYLINDER=2,aiTextureMapping_BOX=3,aiTextureMapping_PLANE=4,aiTextureMapping_OTHER=5};
typedef enum aiTextureOp{aiTextureOp_Multiply=0,aiTextureOp_Add=1,aiTextureOp_Subtract=2,aiTextureOp_Divide=3,aiTextureOp_SmoothAdd=4,aiTextureOp_SignedAdd=5};
typedef enum aiTextureType{aiTextureType_NONE=0,aiTextureType_DIFFUSE=1,aiTextureType_SPECULAR=2,aiTextureType_AMBIENT=3,aiTextureType_EMISSIVE=4,aiTextureType_HEIGHT=5,aiTextureType_NORMALS=6,aiTextureType_SHININESS=7,aiTextureType_OPACITY=8,aiTextureType_DISPLACEMENT=9,aiTextureType_LIGHTMAP=10,aiTextureType_REFLECTION=11,aiTextureType_BASE_COLOR=12,aiTextureType_NORMAL_CAMERA=13,aiTextureType_EMISSION_COLOR=14,aiTextureType_METALNESS=15,aiTextureType_DIFFUSE_ROUGHNESS=16,aiTextureType_AMBIENT_OCCLUSION=17,aiTextureType_SHEEN=19,aiTextureType_CLEARCOAT=20,aiTextureType_TRANSMISSION=21,aiTextureType_UNKNOWN=18};
struct aiColor4D {float r;float g;float b;float a;};
struct aiVector2D {float x;float y;};
struct aiVector3D {float x;float y;float z;};
struct aiMatrix3x3 {float a1;float a2;float a3;float b1;float b2;float b3;float c1;float c2;float c3;};
struct aiMatrix4x4 {float a1;float a2;float a3;float a4;float b1;float b2;float b3;float b4;float c1;float c2;float c3;float c4;float d1;float d2;float d3;float d4;};
struct aiQuaternion {float w;float x;float y;float z;};
struct aiColor3D {float r;float g;float b;};
struct aiString {unsigned int length;char data[1024];};
struct aiMemoryInfo {unsigned int textures;unsigned int materials;unsigned int meshes;unsigned int nodes;unsigned int animations;unsigned int cameras;unsigned int lights;unsigned int total;};
struct aiCamera {struct aiString mName;struct aiVector3D mPosition;struct aiVector3D mUp;struct aiVector3D mLookAt;float mHorizontalFOV;float mClipPlaneNear;float mClipPlaneFar;float mAspect;float mOrthographicWidth;};
struct aiFileIO {struct aiFile*(*OpenProc)(struct aiFileIO*,const char*,const char*);void(*CloseProc)(struct aiFileIO*,struct aiFile*);char*UserData;};
struct aiFile {unsigned long(*ReadProc)(struct aiFile*,char*,unsigned long,unsigned long);unsigned long(*WriteProc)(struct aiFile*,const char*,unsigned long,unsigned long);unsigned long(*TellProc)(struct aiFile*);unsigned long(*FileSizeProc)(struct aiFile*);enum aiReturn(*SeekProc)(struct aiFile*,unsigned long,enum aiOrigin);void(*FlushProc)(struct aiFile*);char*UserData;};
struct aiAABB {struct aiVector3D mMin;struct aiVector3D mMax;};
struct aiFace {unsigned int mNumIndices;unsigned int*mIndices;};
struct aiVertexWeight {unsigned int mVertexId;float mWeight;};
struct aiBone {struct aiString mName;unsigned int mNumWeights;struct aiNode*mArmature;struct aiNode*mNode;struct aiVertexWeight*mWeights;struct aiMatrix4x4 mOffsetMatrix;};
struct aiAnimMesh {struct aiString mName;struct aiVector3D*mVertices;struct aiVector3D*mNormals;struct aiVector3D*mTangents;struct aiVector3D*mBitangents;struct aiColor4D*mColors[0x8];struct aiVector3D*mTextureCoords[0x8];unsigned int mNumVertices;float mWeight;};
struct aiMesh {unsigned int mPrimitiveTypes;unsigned int mNumVertices;unsigned int mNumFaces;struct aiVector3D*mVertices;struct aiVector3D*mNormals;struct aiVector3D*mTangents;struct aiVector3D*mBitangents;struct aiColor4D*mColors[0x8];struct aiVector3D*mTextureCoords[0x8];unsigned int mNumUVComponents[0x8];struct aiFace*mFaces;unsigned int mNumBones;struct aiBone**mBones;unsigned int mMaterialIndex;struct aiString mName;unsigned int mNumAnimMeshes;struct aiAnimMesh**mAnimMeshes;unsigned int mMethod;struct aiAABB mAABB;struct aiString**mTextureCoordsNames;};
struct aiSkeletonBone {int mParent;struct aiNode*mArmature;struct aiNode*mNode;unsigned int mNumnWeights;struct aiMesh*mMeshId;struct aiVertexWeight*mWeights;struct aiMatrix4x4 mOffsetMatrix;struct aiMatrix4x4 mLocalMatrix;};
struct aiSkeleton {struct aiString mName;unsigned int mNumBones;struct aiSkeletonBone**mBones;};
struct aiTexel {unsigned int b;unsigned int g;unsigned int r;unsigned int a;};
struct aiTexture {unsigned int mWidth;unsigned int mHeight;char achFormatHint[9];struct aiTexel*pcData;struct aiString mFilename;};
struct aiLight {struct aiString mName;enum aiLightSourceType mType;struct aiVector3D mPosition;struct aiVector3D mDirection;struct aiVector3D mUp;float mAttenuationConstant;float mAttenuationLinear;float mAttenuationQuadratic;struct aiColor3D mColorDiffuse;struct aiColor3D mColorSpecular;struct aiColor3D mColorAmbient;float mAngleInnerCone;float mAngleOuterCone;struct aiVector2D mSize;};
struct aiUVTransform {struct aiVector2D mTranslation;struct aiVector2D mScaling;float mRotation;};
struct aiMaterialProperty {struct aiString mKey;unsigned int mSemantic;unsigned int mIndex;unsigned int mDataLength;enum aiPropertyTypeInfo mType;char*mData;};
struct aiMaterial {struct aiMaterialProperty**mProperties;unsigned int mNumProperties;unsigned int mNumAllocated;};
struct aiVectorKey {double mTime;struct aiVector3D mValue;};
struct aiQuatKey {double mTime;struct aiQuaternion mValue;};
struct aiMeshKey {double mTime;unsigned int mValue;};
struct aiMeshMorphKey {double mTime;unsigned int*mValues;double*mWeights;unsigned int mNumValuesAndWeights;};
struct aiNodeAnim {struct aiString mNodeName;unsigned int mNumPositionKeys;struct aiVectorKey*mPositionKeys;unsigned int mNumRotationKeys;struct aiQuatKey*mRotationKeys;unsigned int mNumScalingKeys;struct aiVectorKey*mScalingKeys;enum aiAnimBehaviour mPreState;enum aiAnimBehaviour mPostState;};
struct aiMeshAnim {struct aiString mName;unsigned int mNumKeys;struct aiMeshKey*mKeys;};
struct aiMeshMorphAnim {struct aiString mName;unsigned int mNumKeys;struct aiMeshMorphKey*mKeys;};
struct aiAnimation {struct aiString mName;double mDuration;double mTicksPerSecond;unsigned int mNumChannels;struct aiNodeAnim**mChannels;unsigned int mNumMeshChannels;struct aiMeshAnim**mMeshChannels;unsigned int mNumMorphMeshChannels;struct aiMeshMorphAnim**mMorphMeshChannels;};
struct aiMetadataEntry {enum aiMetadataType mType;void*mData;};
struct aiMetadata {unsigned int mNumProperties;struct aiString*mKeys;struct aiMetadataEntry*mValues;};
struct aiNode {struct aiString mName;struct aiMatrix4x4 mTransformation;struct aiNode*mParent;unsigned int mNumChildren;struct aiNode**mChildren;unsigned int mNumMeshes;unsigned int*mMeshes;struct aiMetadata*mMetaData;};
struct aiScene {unsigned int mFlags;struct aiNode*mRootNode;unsigned int mNumMeshes;struct aiMesh**mMeshes;unsigned int mNumMaterials;struct aiMaterial**mMaterials;unsigned int mNumAnimations;struct aiAnimation**mAnimations;unsigned int mNumTextures;struct aiTexture**mTextures;unsigned int mNumLights;struct aiLight**mLights;unsigned int mNumCameras;struct aiCamera**mCameras;struct aiMetadata*mMetaData;struct aiString mName;unsigned int mNumSkeletons;struct aiSkeleton**mSkeletons;char*mPrivate;};
struct aiImporterDesc {const char*mName;const char*mAuthor;const char*mMaintainer;const char*mComments;unsigned int mFlags;unsigned int mMinMajor;unsigned int mMinMinor;unsigned int mMaxMajor;unsigned int mMaxMinor;const char*mFileExtensions;};
struct aiLogStream {void(*callback)(const char*,char*);char*user;};
struct aiPropertyStore {char sentinel;};
struct aiExportFormatDesc {const char*id;const char*description;const char*fileExtension;};
struct aiExportDataBlob {unsigned long size;void*data;struct aiString name;struct aiExportDataBlob*next;};
const char*(aiGetBranchName)();
const char*(aiGetErrorString)();
const char*(aiGetLegalString)();
const char*(aiTextureTypeToString)(enum aiTextureType);
const struct aiExportDataBlob*(aiExportSceneToBlob)(const struct aiScene*,const char*,unsigned int);
const struct aiExportFormatDesc*(aiGetExportFormatDescription)(unsigned long);
const struct aiImporterDesc*(aiGetImportFormatDescription)(unsigned long);
const struct aiScene*(aiApplyPostProcessing)(const struct aiScene*,unsigned int);
const struct aiScene*(aiImportFile)(const char*,unsigned int);
const struct aiScene*(aiImportFileEx)(const char*,unsigned int,struct aiFileIO*);
const struct aiScene*(aiImportFileExWithProperties)(const char*,unsigned int,struct aiFileIO*,const struct aiPropertyStore*);
const struct aiScene*(aiImportFileFromMemory)(const char*,unsigned int,unsigned int,const char*);
const struct aiScene*(aiImportFileFromMemoryWithProperties)(const char*,unsigned int,unsigned int,const char*,const struct aiPropertyStore*);
enum aiReturn(aiDetachLogStream)(const struct aiLogStream*);
enum aiReturn(aiExportScene)(const struct aiScene*,const char*,const char*,unsigned int);
enum aiReturn(aiExportSceneEx)(const struct aiScene*,const char*,const char*,struct aiFileIO*,unsigned int);
enum aiReturn(aiGetMaterialColor)(const struct aiMaterial*,const char*,unsigned int,unsigned int,struct aiColor4D*);
enum aiReturn(aiGetMaterialFloatArray)(const struct aiMaterial*,const char*,unsigned int,unsigned int,float*,unsigned int*);
enum aiReturn(aiGetMaterialIntegerArray)(const struct aiMaterial*,const char*,unsigned int,unsigned int,int*,unsigned int*);
enum aiReturn(aiGetMaterialProperty)(const struct aiMaterial*,const char*,unsigned int,unsigned int,const struct aiMaterialProperty**);
enum aiReturn(aiGetMaterialString)(const struct aiMaterial*,const char*,unsigned int,unsigned int,struct aiString*);
enum aiReturn(aiGetMaterialTexture)(const struct aiMaterial*,enum aiTextureType,unsigned int,struct aiString*,enum aiTextureMapping*,unsigned int*,float*,enum aiTextureOp*,enum aiTextureMapMode*,unsigned int*);
enum aiReturn(aiGetMaterialUVTransform)(const struct aiMaterial*,const char*,unsigned int,unsigned int,struct aiUVTransform*);
float(aiMatrix3Determinant)(const struct aiMatrix3x3*);
float(aiMatrix4Determinant)(const struct aiMatrix4x4*);
float(aiVector2DotProduct)(const struct aiVector2D*,const struct aiVector2D*);
float(aiVector2Length)(const struct aiVector2D*);
float(aiVector2SquareLength)(const struct aiVector2D*);
float(aiVector3DotProduct)(const struct aiVector3D*,const struct aiVector3D*);
float(aiVector3Length)(const struct aiVector3D*);
float(aiVector3SquareLength)(const struct aiVector3D*);
int(aiIsExtensionSupported)(const char*);
int(aiMatrix3AreEqual)(const struct aiMatrix3x3*,const struct aiMatrix3x3*);
int(aiMatrix3AreEqualEpsilon)(const struct aiMatrix3x3*,const struct aiMatrix3x3*,const float);
int(aiMatrix4AreEqual)(const struct aiMatrix4x4*,const struct aiMatrix4x4*);
int(aiMatrix4AreEqualEpsilon)(const struct aiMatrix4x4*,const struct aiMatrix4x4*,const float);
int(aiMatrix4IsIdentity)(const struct aiMatrix4x4*);
int(aiQuaternionAreEqual)(const struct aiQuaternion*,const struct aiQuaternion*);
int(aiQuaternionAreEqualEpsilon)(const struct aiQuaternion*,const struct aiQuaternion*,const float);
int(aiVector2AreEqual)(const struct aiVector2D*,const struct aiVector2D*);
int(aiVector2AreEqualEpsilon)(const struct aiVector2D*,const struct aiVector2D*,const float);
int(aiVector3AreEqual)(const struct aiVector3D*,const struct aiVector3D*);
int(aiVector3AreEqualEpsilon)(const struct aiVector3D*,const struct aiVector3D*,const float);
int(aiVector3LessThan)(const struct aiVector3D*,const struct aiVector3D*);
struct aiLogStream(aiGetPredefinedLogStream)(enum aiDefaultLogStream,const char*);
struct aiPropertyStore*(aiCreatePropertyStore)();
unsigned int(aiGetCompileFlags)();
unsigned int(aiGetMaterialTextureCount)(const struct aiMaterial*,enum aiTextureType);
unsigned int(aiGetVersionMajor)();
unsigned int(aiGetVersionMinor)();
unsigned int(aiGetVersionPatch)();
unsigned int(aiGetVersionRevision)();
unsigned long(aiGetExportFormatCount)();
unsigned long(aiGetImportFormatCount)();
void(aiAttachLogStream)(const struct aiLogStream*);
void(aiCopyScene)(const struct aiScene*,struct aiScene**);
void(aiCreateQuaternionFromMatrix)(struct aiQuaternion*,const struct aiMatrix3x3*);
void(aiDecomposeMatrix)(const struct aiMatrix4x4*,struct aiVector3D*,struct aiQuaternion*,struct aiVector3D*);
void(aiDetachAllLogStreams)();
void(aiEnableVerboseLogging)(int);
void(aiFreeScene)(const struct aiScene*);
void(aiGetExtensionList)(struct aiString*);
void(aiGetMemoryRequirements)(const struct aiScene*,struct aiMemoryInfo*);
void(aiIdentityMatrix3)(struct aiMatrix3x3*);
void(aiIdentityMatrix4)(struct aiMatrix4x4*);
void(aiMatrix3FromMatrix4)(struct aiMatrix3x3*,const struct aiMatrix4x4*);
void(aiMatrix3FromQuaternion)(struct aiMatrix3x3*,const struct aiQuaternion*);
void(aiMatrix3FromRotationAroundAxis)(struct aiMatrix3x3*,const struct aiVector3D*,const float);
void(aiMatrix3FromTo)(struct aiMatrix3x3*,const struct aiVector3D*,const struct aiVector3D*);
void(aiMatrix3Inverse)(struct aiMatrix3x3*);
void(aiMatrix3RotationZ)(struct aiMatrix3x3*,const float);
void(aiMatrix3Translation)(struct aiMatrix3x3*,const struct aiVector2D*);
void(aiMatrix4Add)(struct aiMatrix4x4*,const struct aiMatrix4x4*);
void(aiMatrix4DecomposeIntoScalingAxisAnglePosition)(const struct aiMatrix4x4*,struct aiVector3D*,struct aiVector3D*,float*,struct aiVector3D*);
void(aiMatrix4DecomposeIntoScalingEulerAnglesPosition)(const struct aiMatrix4x4*,struct aiVector3D*,struct aiVector3D*,struct aiVector3D*);
void(aiMatrix4DecomposeNoScaling)(const struct aiMatrix4x4*,struct aiQuaternion*,struct aiVector3D*);
void(aiMatrix4FromEulerAngles)(struct aiMatrix4x4*,float,float,float);
void(aiMatrix4FromMatrix3)(struct aiMatrix4x4*,const struct aiMatrix3x3*);
void(aiMatrix4FromRotationAroundAxis)(struct aiMatrix4x4*,const struct aiVector3D*,const float);
void(aiMatrix4FromScalingQuaternionPosition)(struct aiMatrix4x4*,const struct aiVector3D*,const struct aiQuaternion*,const struct aiVector3D*);
void(aiMatrix4FromTo)(struct aiMatrix4x4*,const struct aiVector3D*,const struct aiVector3D*);
void(aiMatrix4Inverse)(struct aiMatrix4x4*);
void(aiMatrix4RotationX)(struct aiMatrix4x4*,const float);
void(aiMatrix4RotationY)(struct aiMatrix4x4*,const float);
void(aiMatrix4RotationZ)(struct aiMatrix4x4*,const float);
void(aiMatrix4Scaling)(struct aiMatrix4x4*,const struct aiVector3D*);
void(aiMatrix4Translation)(struct aiMatrix4x4*,const struct aiVector3D*);
void(aiMultiplyMatrix3)(struct aiMatrix3x3*,const struct aiMatrix3x3*);
void(aiMultiplyMatrix4)(struct aiMatrix4x4*,const struct aiMatrix4x4*);
void(aiQuaternionConjugate)(struct aiQuaternion*);
void(aiQuaternionFromAxisAngle)(struct aiQuaternion*,const struct aiVector3D*,const float);
void(aiQuaternionFromEulerAngles)(struct aiQuaternion*,float,float,float);
void(aiQuaternionFromNormalizedQuaternion)(struct aiQuaternion*,const struct aiVector3D*);
void(aiQuaternionInterpolate)(struct aiQuaternion*,const struct aiQuaternion*,const struct aiQuaternion*,const float);
void(aiQuaternionMultiply)(struct aiQuaternion*,const struct aiQuaternion*);
void(aiQuaternionNormalize)(struct aiQuaternion*);
void(aiReleaseExportBlob)(const struct aiExportDataBlob*);
void(aiReleaseExportFormatDescription)(const struct aiExportFormatDesc*);
void(aiReleaseImport)(const struct aiScene*);
void(aiReleasePropertyStore)(struct aiPropertyStore*);
void(aiSetImportPropertyFloat)(struct aiPropertyStore*,const char*,float);
void(aiSetImportPropertyInteger)(struct aiPropertyStore*,const char*,int);
void(aiSetImportPropertyMatrix)(struct aiPropertyStore*,const char*,const struct aiMatrix4x4*);
void(aiSetImportPropertyString)(struct aiPropertyStore*,const char*,const struct aiString*);
void(aiTransformVecByMatrix3)(struct aiVector3D*,const struct aiMatrix3x3*);
void(aiTransformVecByMatrix4)(struct aiVector3D*,const struct aiMatrix4x4*);
void(aiTransposeMatrix3)(struct aiMatrix3x3*);
void(aiTransposeMatrix4)(struct aiMatrix4x4*);
void(aiVector2Add)(struct aiVector2D*,const struct aiVector2D*);
void(aiVector2DivideByScalar)(struct aiVector2D*,const float);
void(aiVector2DivideByVector)(struct aiVector2D*,struct aiVector2D*);
void(aiVector2Negate)(struct aiVector2D*);
void(aiVector2Normalize)(struct aiVector2D*);
void(aiVector2Scale)(struct aiVector2D*,const float);
void(aiVector2Subtract)(struct aiVector2D*,const struct aiVector2D*);
void(aiVector2SymMul)(struct aiVector2D*,const struct aiVector2D*);
void(aiVector3Add)(struct aiVector3D*,const struct aiVector3D*);
void(aiVector3CrossProduct)(struct aiVector3D*,const struct aiVector3D*,const struct aiVector3D*);
void(aiVector3DivideByScalar)(struct aiVector3D*,const float);
void(aiVector3DivideByVector)(struct aiVector3D*,struct aiVector3D*);
void(aiVector3Negate)(struct aiVector3D*);
void(aiVector3Normalize)(struct aiVector3D*);
void(aiVector3NormalizeSafe)(struct aiVector3D*);
void(aiVector3RotateByQuaternion)(struct aiVector3D*,const struct aiQuaternion*);
void(aiVector3Scale)(struct aiVector3D*,const float);
void(aiVector3Subtract)(struct aiVector3D*,const struct aiVector3D*);
void(aiVector3SymMul)(struct aiVector3D*,const struct aiVector3D*);
]])
				local CLIB = setmetatable({}, {__index = function(_, k)
					local ok, val = pcall(function() return lib[k] end)
					if ok then
						return val
					end
				end})
			local library = {
	ApplyPostProcessing = CLIB.aiApplyPostProcessing,
	AttachLogStream = CLIB.aiAttachLogStream,
	CopyScene = CLIB.aiCopyScene,
	CreatePropertyStore = CLIB.aiCreatePropertyStore,
	CreateQuaternionFromMatrix = CLIB.aiCreateQuaternionFromMatrix,
	DecomposeMatrix = CLIB.aiDecomposeMatrix,
	DetachAllLogStreams = CLIB.aiDetachAllLogStreams,
	DetachLogStream = CLIB.aiDetachLogStream,
	EnableVerboseLogging = CLIB.aiEnableVerboseLogging,
	ExportScene = CLIB.aiExportScene,
	ExportSceneEx = CLIB.aiExportSceneEx,
	ExportSceneToBlob = CLIB.aiExportSceneToBlob,
	FreeScene = CLIB.aiFreeScene,
	GetBranchName = CLIB.aiGetBranchName,
	GetCompileFlags = CLIB.aiGetCompileFlags,
	GetErrorString = CLIB.aiGetErrorString,
	GetExportFormatCount = CLIB.aiGetExportFormatCount,
	GetExportFormatDescription = CLIB.aiGetExportFormatDescription,
	GetExtensionList = CLIB.aiGetExtensionList,
	GetImportFormatCount = CLIB.aiGetImportFormatCount,
	GetImportFormatDescription = CLIB.aiGetImportFormatDescription,
	GetLegalString = CLIB.aiGetLegalString,
	GetMaterialColor = CLIB.aiGetMaterialColor,
	GetMaterialFloatArray = CLIB.aiGetMaterialFloatArray,
	GetMaterialIntegerArray = CLIB.aiGetMaterialIntegerArray,
	GetMaterialProperty = CLIB.aiGetMaterialProperty,
	GetMaterialString = CLIB.aiGetMaterialString,
	GetMaterialTexture = CLIB.aiGetMaterialTexture,
	GetMaterialTextureCount = CLIB.aiGetMaterialTextureCount,
	GetMaterialUVTransform = CLIB.aiGetMaterialUVTransform,
	GetMemoryRequirements = CLIB.aiGetMemoryRequirements,
	GetPredefinedLogStream = CLIB.aiGetPredefinedLogStream,
	GetVersionMajor = CLIB.aiGetVersionMajor,
	GetVersionMinor = CLIB.aiGetVersionMinor,
	GetVersionPatch = CLIB.aiGetVersionPatch,
	GetVersionRevision = CLIB.aiGetVersionRevision,
	IdentityMatrix3 = CLIB.aiIdentityMatrix3,
	IdentityMatrix4 = CLIB.aiIdentityMatrix4,
	ImportFile = CLIB.aiImportFile,
	ImportFileEx = CLIB.aiImportFileEx,
	ImportFileExWithProperties = CLIB.aiImportFileExWithProperties,
	ImportFileFromMemory = CLIB.aiImportFileFromMemory,
	ImportFileFromMemoryWithProperties = CLIB.aiImportFileFromMemoryWithProperties,
	IsExtensionSupported = CLIB.aiIsExtensionSupported,
	Matrix3AreEqual = CLIB.aiMatrix3AreEqual,
	Matrix3AreEqualEpsilon = CLIB.aiMatrix3AreEqualEpsilon,
	Matrix3Determinant = CLIB.aiMatrix3Determinant,
	Matrix3FromMatrix4 = CLIB.aiMatrix3FromMatrix4,
	Matrix3FromQuaternion = CLIB.aiMatrix3FromQuaternion,
	Matrix3FromRotationAroundAxis = CLIB.aiMatrix3FromRotationAroundAxis,
	Matrix3FromTo = CLIB.aiMatrix3FromTo,
	Matrix3Inverse = CLIB.aiMatrix3Inverse,
	Matrix3RotationZ = CLIB.aiMatrix3RotationZ,
	Matrix3Translation = CLIB.aiMatrix3Translation,
	Matrix4Add = CLIB.aiMatrix4Add,
	Matrix4AreEqual = CLIB.aiMatrix4AreEqual,
	Matrix4AreEqualEpsilon = CLIB.aiMatrix4AreEqualEpsilon,
	Matrix4DecomposeIntoScalingAxisAnglePosition = CLIB.aiMatrix4DecomposeIntoScalingAxisAnglePosition,
	Matrix4DecomposeIntoScalingEulerAnglesPosition = CLIB.aiMatrix4DecomposeIntoScalingEulerAnglesPosition,
	Matrix4DecomposeNoScaling = CLIB.aiMatrix4DecomposeNoScaling,
	Matrix4Determinant = CLIB.aiMatrix4Determinant,
	Matrix4FromEulerAngles = CLIB.aiMatrix4FromEulerAngles,
	Matrix4FromMatrix3 = CLIB.aiMatrix4FromMatrix3,
	Matrix4FromRotationAroundAxis = CLIB.aiMatrix4FromRotationAroundAxis,
	Matrix4FromScalingQuaternionPosition = CLIB.aiMatrix4FromScalingQuaternionPosition,
	Matrix4FromTo = CLIB.aiMatrix4FromTo,
	Matrix4Inverse = CLIB.aiMatrix4Inverse,
	Matrix4IsIdentity = CLIB.aiMatrix4IsIdentity,
	Matrix4RotationX = CLIB.aiMatrix4RotationX,
	Matrix4RotationY = CLIB.aiMatrix4RotationY,
	Matrix4RotationZ = CLIB.aiMatrix4RotationZ,
	Matrix4Scaling = CLIB.aiMatrix4Scaling,
	Matrix4Translation = CLIB.aiMatrix4Translation,
	MultiplyMatrix3 = CLIB.aiMultiplyMatrix3,
	MultiplyMatrix4 = CLIB.aiMultiplyMatrix4,
	QuaternionAreEqual = CLIB.aiQuaternionAreEqual,
	QuaternionAreEqualEpsilon = CLIB.aiQuaternionAreEqualEpsilon,
	QuaternionConjugate = CLIB.aiQuaternionConjugate,
	QuaternionFromAxisAngle = CLIB.aiQuaternionFromAxisAngle,
	QuaternionFromEulerAngles = CLIB.aiQuaternionFromEulerAngles,
	QuaternionFromNormalizedQuaternion = CLIB.aiQuaternionFromNormalizedQuaternion,
	QuaternionInterpolate = CLIB.aiQuaternionInterpolate,
	QuaternionMultiply = CLIB.aiQuaternionMultiply,
	QuaternionNormalize = CLIB.aiQuaternionNormalize,
	ReleaseExportBlob = CLIB.aiReleaseExportBlob,
	ReleaseExportFormatDescription = CLIB.aiReleaseExportFormatDescription,
	ReleaseImport = CLIB.aiReleaseImport,
	ReleasePropertyStore = CLIB.aiReleasePropertyStore,
	SetImportPropertyFloat = CLIB.aiSetImportPropertyFloat,
	SetImportPropertyInteger = CLIB.aiSetImportPropertyInteger,
	SetImportPropertyMatrix = CLIB.aiSetImportPropertyMatrix,
	SetImportPropertyString = CLIB.aiSetImportPropertyString,
	TextureTypeToString = CLIB.aiTextureTypeToString,
	TransformVecByMatrix3 = CLIB.aiTransformVecByMatrix3,
	TransformVecByMatrix4 = CLIB.aiTransformVecByMatrix4,
	TransposeMatrix3 = CLIB.aiTransposeMatrix3,
	TransposeMatrix4 = CLIB.aiTransposeMatrix4,
	Vector2Add = CLIB.aiVector2Add,
	Vector2AreEqual = CLIB.aiVector2AreEqual,
	Vector2AreEqualEpsilon = CLIB.aiVector2AreEqualEpsilon,
	Vector2DivideByScalar = CLIB.aiVector2DivideByScalar,
	Vector2DivideByVector = CLIB.aiVector2DivideByVector,
	Vector2DotProduct = CLIB.aiVector2DotProduct,
	Vector2Length = CLIB.aiVector2Length,
	Vector2Negate = CLIB.aiVector2Negate,
	Vector2Normalize = CLIB.aiVector2Normalize,
	Vector2Scale = CLIB.aiVector2Scale,
	Vector2SquareLength = CLIB.aiVector2SquareLength,
	Vector2Subtract = CLIB.aiVector2Subtract,
	Vector2SymMul = CLIB.aiVector2SymMul,
	Vector3Add = CLIB.aiVector3Add,
	Vector3AreEqual = CLIB.aiVector3AreEqual,
	Vector3AreEqualEpsilon = CLIB.aiVector3AreEqualEpsilon,
	Vector3CrossProduct = CLIB.aiVector3CrossProduct,
	Vector3DivideByScalar = CLIB.aiVector3DivideByScalar,
	Vector3DivideByVector = CLIB.aiVector3DivideByVector,
	Vector3DotProduct = CLIB.aiVector3DotProduct,
	Vector3Length = CLIB.aiVector3Length,
	Vector3LessThan = CLIB.aiVector3LessThan,
	Vector3Negate = CLIB.aiVector3Negate,
	Vector3Normalize = CLIB.aiVector3Normalize,
	Vector3NormalizeSafe = CLIB.aiVector3NormalizeSafe,
	Vector3RotateByQuaternion = CLIB.aiVector3RotateByQuaternion,
	Vector3Scale = CLIB.aiVector3Scale,
	Vector3SquareLength = CLIB.aiVector3SquareLength,
	Vector3Subtract = CLIB.aiVector3Subtract,
	Vector3SymMul = CLIB.aiVector3SymMul,
}
library.e = {
	DEFAULT = ffi.cast("enum aiAnimBehaviour", "aiAnimBehaviour_DEFAULT"),
	CONSTANT = ffi.cast("enum aiAnimBehaviour", "aiAnimBehaviour_CONSTANT"),
	LINEAR = ffi.cast("enum aiAnimBehaviour", "aiAnimBehaviour_LINEAR"),
	REPEAT = ffi.cast("enum aiAnimBehaviour", "aiAnimBehaviour_REPEAT"),
	Default = ffi.cast("enum aiBlendMode", "aiBlendMode_Default"),
	Additive = ffi.cast("enum aiBlendMode", "aiBlendMode_Additive"),
	NORMALS = ffi.cast("enum aiComponent", "aiComponent_NORMALS"),
	TANGENTS_AND_BITANGENTS = ffi.cast("enum aiComponent", "aiComponent_TANGENTS_AND_BITANGENTS"),
	COLORS = ffi.cast("enum aiComponent", "aiComponent_COLORS"),
	TEXCOORDS = ffi.cast("enum aiComponent", "aiComponent_TEXCOORDS"),
	BONEWEIGHTS = ffi.cast("enum aiComponent", "aiComponent_BONEWEIGHTS"),
	ANIMATIONS = ffi.cast("enum aiComponent", "aiComponent_ANIMATIONS"),
	TEXTURES = ffi.cast("enum aiComponent", "aiComponent_TEXTURES"),
	LIGHTS = ffi.cast("enum aiComponent", "aiComponent_LIGHTS"),
	CAMERAS = ffi.cast("enum aiComponent", "aiComponent_CAMERAS"),
	MESHES = ffi.cast("enum aiComponent", "aiComponent_MESHES"),
	MATERIALS = ffi.cast("enum aiComponent", "aiComponent_MATERIALS"),
	FILE = ffi.cast("enum aiDefaultLogStream", "aiDefaultLogStream_FILE"),
	STDOUT = ffi.cast("enum aiDefaultLogStream", "aiDefaultLogStream_STDOUT"),
	STDERR = ffi.cast("enum aiDefaultLogStream", "aiDefaultLogStream_STDERR"),
	DEBUGGER = ffi.cast("enum aiDefaultLogStream", "aiDefaultLogStream_DEBUGGER"),
	SupportTextFlavour = ffi.cast("enum aiImporterFlags", "aiImporterFlags_SupportTextFlavour"),
	SupportBinaryFlavour = ffi.cast("enum aiImporterFlags", "aiImporterFlags_SupportBinaryFlavour"),
	SupportCompressedFlavour = ffi.cast("enum aiImporterFlags", "aiImporterFlags_SupportCompressedFlavour"),
	LimitedSupport = ffi.cast("enum aiImporterFlags", "aiImporterFlags_LimitedSupport"),
	Experimental = ffi.cast("enum aiImporterFlags", "aiImporterFlags_Experimental"),
	UNDEFINED = ffi.cast("enum aiLightSourceType", "aiLightSource_UNDEFINED"),
	DIRECTIONAL = ffi.cast("enum aiLightSourceType", "aiLightSource_DIRECTIONAL"),
	POINT = ffi.cast("enum aiLightSourceType", "aiLightSource_POINT"),
	SPOT = ffi.cast("enum aiLightSourceType", "aiLightSource_SPOT"),
	AMBIENT = ffi.cast("enum aiLightSourceType", "aiLightSource_AMBIENT"),
	AREA = ffi.cast("enum aiLightSourceType", "aiLightSource_AREA"),
	MAX = ffi.cast("enum aiMetadataType", "aiMETA_MAX"),
	VERTEX_BLEND = ffi.cast("enum aiMorphingMethod", "aiMorphingMethod_VERTEX_BLEND"),
	MORPH_NORMALIZED = ffi.cast("enum aiMorphingMethod", "aiMorphingMethod_MORPH_NORMALIZED"),
	MORPH_RELATIVE = ffi.cast("enum aiMorphingMethod", "aiMorphingMethod_MORPH_RELATIVE"),
	SET = ffi.cast("enum aiOrigin", "aiOrigin_SET"),
	CUR = ffi.cast("enum aiOrigin", "aiOrigin_CUR"),
	END = ffi.cast("enum aiOrigin", "aiOrigin_END"),
	CalcTangentSpace = ffi.cast("enum aiPostProcessSteps", "aiProcess_CalcTangentSpace"),
	JoinIdenticalVertices = ffi.cast("enum aiPostProcessSteps", "aiProcess_JoinIdenticalVertices"),
	MakeLeftHanded = ffi.cast("enum aiPostProcessSteps", "aiProcess_MakeLeftHanded"),
	Triangulate = ffi.cast("enum aiPostProcessSteps", "aiProcess_Triangulate"),
	RemoveComponent = ffi.cast("enum aiPostProcessSteps", "aiProcess_RemoveComponent"),
	GenNormals = ffi.cast("enum aiPostProcessSteps", "aiProcess_GenNormals"),
	GenSmoothNormals = ffi.cast("enum aiPostProcessSteps", "aiProcess_GenSmoothNormals"),
	SplitLargeMeshes = ffi.cast("enum aiPostProcessSteps", "aiProcess_SplitLargeMeshes"),
	PreTransformVertices = ffi.cast("enum aiPostProcessSteps", "aiProcess_PreTransformVertices"),
	LimitBoneWeights = ffi.cast("enum aiPostProcessSteps", "aiProcess_LimitBoneWeights"),
	ValidateDataStructure = ffi.cast("enum aiPostProcessSteps", "aiProcess_ValidateDataStructure"),
	ImproveCacheLocality = ffi.cast("enum aiPostProcessSteps", "aiProcess_ImproveCacheLocality"),
	RemoveRedundantMaterials = ffi.cast("enum aiPostProcessSteps", "aiProcess_RemoveRedundantMaterials"),
	FixInfacingNormals = ffi.cast("enum aiPostProcessSteps", "aiProcess_FixInfacingNormals"),
	PopulateArmatureData = ffi.cast("enum aiPostProcessSteps", "aiProcess_PopulateArmatureData"),
	SortByPType = ffi.cast("enum aiPostProcessSteps", "aiProcess_SortByPType"),
	FindDegenerates = ffi.cast("enum aiPostProcessSteps", "aiProcess_FindDegenerates"),
	FindInvalidData = ffi.cast("enum aiPostProcessSteps", "aiProcess_FindInvalidData"),
	GenUVCoords = ffi.cast("enum aiPostProcessSteps", "aiProcess_GenUVCoords"),
	TransformUVCoords = ffi.cast("enum aiPostProcessSteps", "aiProcess_TransformUVCoords"),
	FindInstances = ffi.cast("enum aiPostProcessSteps", "aiProcess_FindInstances"),
	OptimizeMeshes = ffi.cast("enum aiPostProcessSteps", "aiProcess_OptimizeMeshes"),
	OptimizeGraph = ffi.cast("enum aiPostProcessSteps", "aiProcess_OptimizeGraph"),
	FlipUVs = ffi.cast("enum aiPostProcessSteps", "aiProcess_FlipUVs"),
	FlipWindingOrder = ffi.cast("enum aiPostProcessSteps", "aiProcess_FlipWindingOrder"),
	SplitByBoneCount = ffi.cast("enum aiPostProcessSteps", "aiProcess_SplitByBoneCount"),
	Debone = ffi.cast("enum aiPostProcessSteps", "aiProcess_Debone"),
	GlobalScale = ffi.cast("enum aiPostProcessSteps", "aiProcess_GlobalScale"),
	EmbedTextures = ffi.cast("enum aiPostProcessSteps", "aiProcess_EmbedTextures"),
	ForceGenNormals = ffi.cast("enum aiPostProcessSteps", "aiProcess_ForceGenNormals"),
	DropNormals = ffi.cast("enum aiPostProcessSteps", "aiProcess_DropNormals"),
	GenBoundingBoxes = ffi.cast("enum aiPostProcessSteps", "aiProcess_GenBoundingBoxes"),
	POINT = ffi.cast("enum aiPrimitiveType", "aiPrimitiveType_POINT"),
	LINE = ffi.cast("enum aiPrimitiveType", "aiPrimitiveType_LINE"),
	TRIANGLE = ffi.cast("enum aiPrimitiveType", "aiPrimitiveType_TRIANGLE"),
	POLYGON = ffi.cast("enum aiPrimitiveType", "aiPrimitiveType_POLYGON"),
	NGONEncodingFlag = ffi.cast("enum aiPrimitiveType", "aiPrimitiveType_NGONEncodingFlag"),
	ConvertToLeftHanded = ffi.cast("enum aiProcessHack", "aiProcess_ConvertToLeftHanded"),
	TargetRealtime_Fast = ffi.cast("enum aiProcessHack", "aiProcessPreset_TargetRealtime_Fast"),
	TargetRealtime_Quality = ffi.cast("enum aiProcessHack", "aiProcessPreset_TargetRealtime_Quality"),
	TargetRealtime_MaxQuality = ffi.cast("enum aiProcessHack", "aiProcessPreset_TargetRealtime_MaxQuality"),
	Float = ffi.cast("enum aiPropertyTypeInfo", "aiPTI_Float"),
	Double = ffi.cast("enum aiPropertyTypeInfo", "aiPTI_Double"),
	String = ffi.cast("enum aiPropertyTypeInfo", "aiPTI_String"),
	Integer = ffi.cast("enum aiPropertyTypeInfo", "aiPTI_Integer"),
	Buffer = ffi.cast("enum aiPropertyTypeInfo", "aiPTI_Buffer"),
	SUCCESS = ffi.cast("enum aiReturn", "aiReturn_SUCCESS"),
	FAILURE = ffi.cast("enum aiReturn", "aiReturn_FAILURE"),
	OUTOFMEMORY = ffi.cast("enum aiReturn", "aiReturn_OUTOFMEMORY"),
	Flat = ffi.cast("enum aiShadingMode", "aiShadingMode_Flat"),
	Gouraud = ffi.cast("enum aiShadingMode", "aiShadingMode_Gouraud"),
	Phong = ffi.cast("enum aiShadingMode", "aiShadingMode_Phong"),
	Blinn = ffi.cast("enum aiShadingMode", "aiShadingMode_Blinn"),
	Toon = ffi.cast("enum aiShadingMode", "aiShadingMode_Toon"),
	OrenNayar = ffi.cast("enum aiShadingMode", "aiShadingMode_OrenNayar"),
	Minnaert = ffi.cast("enum aiShadingMode", "aiShadingMode_Minnaert"),
	CookTorrance = ffi.cast("enum aiShadingMode", "aiShadingMode_CookTorrance"),
	NoShading = ffi.cast("enum aiShadingMode", "aiShadingMode_NoShading"),
	Unlit = ffi.cast("enum aiShadingMode", "aiShadingMode_Unlit"),
	Fresnel = ffi.cast("enum aiShadingMode", "aiShadingMode_Fresnel"),
	PBR_BRDF = ffi.cast("enum aiShadingMode", "aiShadingMode_PBR_BRDF"),
	Invert = ffi.cast("enum aiTextureFlags", "aiTextureFlags_Invert"),
	UseAlpha = ffi.cast("enum aiTextureFlags", "aiTextureFlags_UseAlpha"),
	IgnoreAlpha = ffi.cast("enum aiTextureFlags", "aiTextureFlags_IgnoreAlpha"),
	Wrap = ffi.cast("enum aiTextureMapMode", "aiTextureMapMode_Wrap"),
	Clamp = ffi.cast("enum aiTextureMapMode", "aiTextureMapMode_Clamp"),
	Decal = ffi.cast("enum aiTextureMapMode", "aiTextureMapMode_Decal"),
	Mirror = ffi.cast("enum aiTextureMapMode", "aiTextureMapMode_Mirror"),
	UV = ffi.cast("enum aiTextureMapping", "aiTextureMapping_UV"),
	SPHERE = ffi.cast("enum aiTextureMapping", "aiTextureMapping_SPHERE"),
	CYLINDER = ffi.cast("enum aiTextureMapping", "aiTextureMapping_CYLINDER"),
	BOX = ffi.cast("enum aiTextureMapping", "aiTextureMapping_BOX"),
	PLANE = ffi.cast("enum aiTextureMapping", "aiTextureMapping_PLANE"),
	OTHER = ffi.cast("enum aiTextureMapping", "aiTextureMapping_OTHER"),
	Multiply = ffi.cast("enum aiTextureOp", "aiTextureOp_Multiply"),
	Add = ffi.cast("enum aiTextureOp", "aiTextureOp_Add"),
	Subtract = ffi.cast("enum aiTextureOp", "aiTextureOp_Subtract"),
	Divide = ffi.cast("enum aiTextureOp", "aiTextureOp_Divide"),
	SmoothAdd = ffi.cast("enum aiTextureOp", "aiTextureOp_SmoothAdd"),
	SignedAdd = ffi.cast("enum aiTextureOp", "aiTextureOp_SignedAdd"),
	NONE = ffi.cast("enum aiTextureType", "aiTextureType_NONE"),
	DIFFUSE = ffi.cast("enum aiTextureType", "aiTextureType_DIFFUSE"),
	SPECULAR = ffi.cast("enum aiTextureType", "aiTextureType_SPECULAR"),
	AMBIENT = ffi.cast("enum aiTextureType", "aiTextureType_AMBIENT"),
	EMISSIVE = ffi.cast("enum aiTextureType", "aiTextureType_EMISSIVE"),
	HEIGHT = ffi.cast("enum aiTextureType", "aiTextureType_HEIGHT"),
	NORMALS = ffi.cast("enum aiTextureType", "aiTextureType_NORMALS"),
	SHININESS = ffi.cast("enum aiTextureType", "aiTextureType_SHININESS"),
	OPACITY = ffi.cast("enum aiTextureType", "aiTextureType_OPACITY"),
	DISPLACEMENT = ffi.cast("enum aiTextureType", "aiTextureType_DISPLACEMENT"),
	LIGHTMAP = ffi.cast("enum aiTextureType", "aiTextureType_LIGHTMAP"),
	REFLECTION = ffi.cast("enum aiTextureType", "aiTextureType_REFLECTION"),
	BASE_COLOR = ffi.cast("enum aiTextureType", "aiTextureType_BASE_COLOR"),
	NORMAL_CAMERA = ffi.cast("enum aiTextureType", "aiTextureType_NORMAL_CAMERA"),
	EMISSION_COLOR = ffi.cast("enum aiTextureType", "aiTextureType_EMISSION_COLOR"),
	METALNESS = ffi.cast("enum aiTextureType", "aiTextureType_METALNESS"),
	DIFFUSE_ROUGHNESS = ffi.cast("enum aiTextureType", "aiTextureType_DIFFUSE_ROUGHNESS"),
	AMBIENT_OCCLUSION = ffi.cast("enum aiTextureType", "aiTextureType_AMBIENT_OCCLUSION"),
	SHEEN = ffi.cast("enum aiTextureType", "aiTextureType_SHEEN"),
	CLEARCOAT = ffi.cast("enum aiTextureType", "aiTextureType_CLEARCOAT"),
	TRANSMISSION = ffi.cast("enum aiTextureType", "aiTextureType_TRANSMISSION"),
	UNKNOWN = ffi.cast("enum aiTextureType", "aiTextureType_UNKNOWN"),
}
library.clib = CLIB
return library
