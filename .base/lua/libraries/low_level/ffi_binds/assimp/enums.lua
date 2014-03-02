local enums = {
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
	aiProcess_Debone  = 0x4000000,
	aiPrimitiveType_POINT       = 0x1,
	aiPrimitiveType_LINE        = 0x2,
	aiPrimitiveType_TRIANGLE    = 0x4,
	aiPrimitiveType_POLYGON     = 0x8,
	aiImporterFlags_SupportTextFlavour = 0x1,
	aiImporterFlags_SupportBinaryFlavour = 0x2,
	aiImporterFlags_SupportCompressedFlavour = 0x4,
	aiImporterFlags_LimitedSupport = 0x8,
	aiImporterFlags_Experimental = 0x10,
}


enums.aiProcessPreset_TargetRealtime_Quality = bit.bor(
	enums.aiProcess_CalcTangentSpace,
	enums.aiProcess_GenSmoothNormals,
	enums.aiProcess_JoinIdenticalVertices,
	enums.aiProcess_ImproveCacheLocality,
	enums.aiProcess_LimitBoneWeights,
	enums.aiProcess_RemoveRedundantMaterials,
	enums.aiProcess_SplitLargeMeshes,
	enums.aiProcess_Triangulate,
	enums.aiProcess_GenUVCoords,
	enums.aiProcess_SortByPType,
	enums.aiProcess_FindDegenerates,
	enums.aiProcess_FindInvalidData
)

enums.aiProcessPreset_TargetRealtime_MaxQuality = bit.bor(
	enums.aiProcessPreset_TargetRealtime_Quality,
	enums.aiProcess_FindInstances,
	enums.aiProcess_ValidateDataStructure,
	enums.aiProcess_OptimizeMeshes,
	enums.aiProcess_Debone
)
enums.aiProcessPreset_TargetRealtime_Fast = bit.bor(
	enums.aiProcess_CalcTangentSpace,
	enums.aiProcess_GenNormals,
	enums.aiProcess_JoinIdenticalVertices,
	enums.aiProcess_Triangulate,
	enums.aiProcess_GenUVCoords,
	enums.aiProcess_SortByPType
)

enums.aiProcess_ConvertToLeftHanded = bit.bor(
	enums.aiProcess_MakeLeftHanded ,
	enums.aiProcess_FlipUVs,
	enums.aiProcess_FlipWindingOrder
)

return enums