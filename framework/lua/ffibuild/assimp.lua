ffibuild.Build({
	name = "assimp",
	url = "https://github.com/assimp/assimp.git",
	cmd = "cmake CMakeLists.txt && make",
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),

	c_source = [[
		#include "assimp/types.h"
		#include "assimp/metadata.h"
		#include "assimp/ai_assert.h"
		#include "assimp/cexport.h"
		#include "assimp/color4.h"
		#include "assimp/config.h"
		#include "assimp/matrix4x4.h"
		#include "assimp/postprocess.h"
		#include "assimp/vector3.h"
		#include "assimp/anim.h"
		#include "assimp/cfileio.h"
		#include "assimp/importerdesc.h"
		#include "assimp/matrix3x3.h"
		#include "assimp/scene.h"
		#include "assimp/vector2.h"
		#include "assimp/camera.h"
		#include "assimp/cimport.h"
		#include "assimp/defs.h"
		#include "assimp/light.h"
		#include "assimp/material.h"
		#include "assimp/mesh.h"
		#include "assimp/quaternion.h"
		#include "assimp/texture.h"
		#include "assimp/version.h"


		#undef aiProcess_ConvertToLeftHanded
		#undef aiProcessPreset_TargetRealtime_Fast
		#undef aiProcessPreset_TargetRealtime_Quality
		#undef aiProcessPreset_TargetRealtime_MaxQuality

		typedef enum {
			aiProcess_ConvertToLeftHanded =
				aiProcess_MakeLeftHanded     |
				aiProcess_FlipUVs            |
				aiProcess_FlipWindingOrder   |
				0,

			aiProcessPreset_TargetRealtime_Fast =
				aiProcess_CalcTangentSpace      |
				aiProcess_GenNormals            |
				aiProcess_JoinIdenticalVertices |
				aiProcess_Triangulate           |
				aiProcess_GenUVCoords           |
				aiProcess_SortByPType           |
				0,

			aiProcessPreset_TargetRealtime_Quality =
				aiProcess_CalcTangentSpace              |
				aiProcess_GenSmoothNormals              |
				aiProcess_JoinIdenticalVertices         |
				aiProcess_ImproveCacheLocality          |
				aiProcess_LimitBoneWeights              |
				aiProcess_RemoveRedundantMaterials      |
				aiProcess_SplitLargeMeshes              |
				aiProcess_Triangulate                   |
				aiProcess_GenUVCoords                   |
				aiProcess_SortByPType                   |
				aiProcess_FindDegenerates               |
				aiProcess_FindInvalidData               |
				0,

			aiProcessPreset_TargetRealtime_MaxQuality =
				aiProcessPreset_TargetRealtime_Quality   |
				aiProcess_FindInstances                  |
				aiProcess_ValidateDataStructure          |
				aiProcess_OptimizeMeshes                 |
				0
		} aiGrrr;

		typedef struct aiFile aiFile;

	]],
	gcc_flags = "-I./include",

	process_header = function(header)
		header = header:gsub("(%s)AI_", "%1ai")

		local meta_data = ffibuild.GetMetaData(header)
		meta_data.functions.aiGetImporterDesc = nil
		return meta_data:BuildMinimalHeader(function(name) return name:find("^ai") end, function(name) return name:find("^ai") end, true, true)
	end,

	build_lua = function(header, meta_data)
		local lua = ffibuild.StartLibrary(header)
		lua = lua .. "library = " .. meta_data:BuildFunctions("^ai(.+)")
		lua = lua .. "library.e = " .. meta_data:BuildEnums("^ai.-_(%u.+)")
		return ffibuild.EndLibrary(lua, header)
	end,
})