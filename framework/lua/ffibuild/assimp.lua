ffibuild.Build(
	{
		name = "assimp",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		linux = [[
			FROM ubuntu:20.04

			ARG DEBIAN_FRONTEND=noninteractive
			ENV TZ=America/New_York
			RUN apt-get update

			RUN apt-get install -y git g++ gcc cmake

			WORKDIR /src

			RUN git clone https://github.com/assimp/assimp.git --depth 1 .
			RUN cmake CMakeLists.txt && make --jobs 32
		]],
		c_source = [[
		#include "assimp/color4.h"
		#include "assimp/camera.h"
		#include "assimp/cfileio.h"
		#include "assimp/mesh.h"
		#include "assimp/scene.h"
		#include "assimp/vector2.h"
		#include "assimp/anim.h"
		#include "assimp/metadata.h"
		#include "assimp/cimport.h"
		#include "assimp/version.h"
		#include "assimp/types.h"
		#include "assimp/material.h"
		#include "assimp/config.h"
		#include "assimp/matrix4x4.h"
		#include "assimp/defs.h"
		#include "assimp/cexport.h"
		#include "assimp/importerdesc.h"
		#include "assimp/postprocess.h"
		#include "assimp/aabb.h"
		#include "assimp/light.h"
		#include "assimp/pbrmaterial.h"
		#include "assimp/config.h.in"
		#include "assimp/ai_assert.h"
		#include "assimp/quaternion.h"
		#include "assimp/matrix3x3.h"
		#include "assimp/texture.h"
		#include "assimp/vector3.h"

		#undef aiProcess_ConvertToLeftHanded
		#undef aiProcessPreset_TargetRealtime_Fast
		#undef aiProcessPreset_TargetRealtime_Quality
		#undef aiProcessPreset_TargetRealtime_MaxQuality

		enum aiProcessHack {
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
		};

		typedef struct aiFile aiFile;

	]],
		gcc_flags = "-I./include",
		process_header = function(header)
			header = header:gsub("(%s)AI_", "%1ai")
			local meta_data = ffibuild.GetMetaData(header)
			meta_data.functions.aiGetImporterDesc = nil
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^ai")
				end,
				function(name)
					return name:find("^ai")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			local s = [=[
				local ffi = require("ffi")
				local lib = assert(ffi.load("assimp"))
				ffi.cdef([[]=] .. header .. [=[]])
				local CLIB = setmetatable({}, {__index = function(_, k)
					local ok, val = pcall(function() return lib[k] end)
					if ok then
						return val
					end
				end})
			]=]
			s = s .. "local library = " .. meta_data:BuildLuaFunctions("^ai(.+)")
			s = s .. "library.e = " .. meta_data:BuildLuaEnums("^ai.-_(%u.+)")
			s = s .. "library.clib = CLIB\n"
			s = s .. "return library\n"
			return s
		end,
	}
)