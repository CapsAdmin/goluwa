-- NO C API FOR BULLET >:(
do
	return
end

local swig = [[
%module bullet

#define SIMD_FORCE_INLINE inline
#define ATTRIBUTE_ALIGNED16(a) a
#define ATTRIBUTE_ALIGNED64(a) a
#define ATTRIBUTE_ALIGNED128(a) a

%include BulletCollision/CollisionDispatch/btCollisionWorld.h
%include BulletCollision/CollisionDispatch/btCollisionObject.h
%include BulletCollision/CollisionShapes/btBoxShape.h
%include BulletCollision/CollisionShapes/btSphereShape.h
%include BulletCollision/CollisionShapes/btCapsuleShape.h
%include BulletCollision/CollisionShapes/btCylinderShape.h
%include BulletCollision/CollisionShapes/btConeShape.h
%include BulletCollision/CollisionShapes/btStaticPlaneShape.h
%include BulletCollision/CollisionShapes/btConvexHullShape.h
%include BulletCollision/CollisionShapes/btTriangleMesh.h
%include BulletCollision/CollisionShapes/btConvexTriangleMeshShape.h
%include BulletCollision/CollisionShapes/btBvhTriangleMeshShape.h
%include BulletCollision/CollisionShapes/btScaledBvhTriangleMeshShape.h
%include BulletCollision/CollisionShapes/btTriangleMeshShape.h
%include BulletCollision/CollisionShapes/btTriangleIndexVertexArray.h
%include BulletCollision/CollisionShapes/btCompoundShape.h
%include BulletCollision/CollisionShapes/btTetrahedronShape.h
%include BulletCollision/CollisionShapes/btEmptyShape.h
%include BulletCollision/CollisionShapes/btMultiSphereShape.h
%include BulletCollision/CollisionShapes/btUniformScalingShape.h
%include BulletCollision/CollisionDispatch/btSphereSphereCollisionAlgorithm.h
%include BulletCollision/CollisionDispatch/btDefaultCollisionConfiguration.h
%include BulletCollision/CollisionDispatch/btCollisionDispatcher.h
%include BulletCollision/BroadphaseCollision/btSimpleBroadphase.h
%include BulletCollision/BroadphaseCollision/btAxisSweep3.h
%include BulletCollision/BroadphaseCollision/btDbvtBroadphase.h
%include LinearMath/btQuaternion.h
%include LinearMath/btTransform.h
%include LinearMath/btDefaultMotionState.h
%include LinearMath/btQuickprof.h
%include LinearMath/btIDebugDraw.h
%include LinearMath/btSerializer.h
%include btBulletCollisionCommon.h
%include BulletDynamics/Dynamics/btDiscreteDynamicsWorld.h
%include BulletDynamics/Dynamics/btSimpleDynamicsWorld.h
%include BulletDynamics/Dynamics/btRigidBody.h
%include BulletDynamics/ConstraintSolver/btPoint2PointConstraint.h
%include BulletDynamics/ConstraintSolver/btHingeConstraint.h
%include BulletDynamics/ConstraintSolver/btConeTwistConstraint.h
%include BulletDynamics/ConstraintSolver/btGeneric6DofConstraint.h
%include BulletDynamics/ConstraintSolver/btSliderConstraint.h
%include BulletDynamics/ConstraintSolver/btGeneric6DofSpringConstraint.h
%include BulletDynamics/ConstraintSolver/btUniversalConstraint.h
%include BulletDynamics/ConstraintSolver/btHinge2Constraint.h
%include BulletDynamics/ConstraintSolver/btGearConstraint.h
%include BulletDynamics/ConstraintSolver/btFixedConstraint.h
%include BulletDynamics/ConstraintSolver/btSequentialImpulseConstraintSolver.h
%include BulletDynamics/Vehicle/btRaycastVehicle.h
]]
ffibuild.DockerBuild(
	{
		name = "bullet",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		addfiles = {
			["bullet.i"] = swig,
		},
		dockerfile = [[
			FROM ubuntu:20.04

			ARG DEBIAN_FRONTEND=noninteractive
			ENV TZ=America/New_York
			RUN apt-get update

			RUN apt-get install -y \
				build-essential  \
				clang \
				cmake \
				curl \
				git \
				libgl-dev \
				libglu-dev \
				libpython3-dev \
				lsb-release \
				pkg-config \
				python3 \
				python3-dev \
				python3-distutils \
				software-properties-common \
				sudo

			WORKDIR /src

			RUN git clone https://github.com/bulletphysics/bullet3 --depth 1 .
			RUN cmake . && make -j 32

			WORKDIR /src/src
			
			RUN git clone https://github.com/vadz/swig 
			
			WORKDIR /src/src/swig
			RUN git checkout C
			RUN apt-get install -y libpcre2-dev libbison-dev
			RUN mkdir build
			RUN cd build && cmake .. && make -j 32 && make install
			WORKDIR /src/src

			ADD bullet.i .
			RUN swig -c++ -c bullet.i

			WORKDIR /src
		]],
		c_source = [[#include "PhysicsClientC_API.h"]],
		gcc_flags = "-I./examples/SharedMemory/",
		filter_library = function(path)
			if path:ends_with("sharedmembullet") then
				print("LIBRARY", path)
				return true
			end
		end,
		process_header = function(header)
			local meta_data = ffibuild.GetMetaData(header)
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^b3")
				end,
				function(name)
					return name:find("^b3")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			local lua = ffibuild.StartLibrary(header, "safe_clib_index")
			lua = lua .. "CLIB = SAFE_INDEX(CLIB)"
			lua = lua .. "library = " .. meta_data:BuildFunctions("^b3(.+)")
			lua = lua .. "library.e = " .. meta_data:BuildEnums("^b3(%u.+)")
			return ffibuild.EndLibrary(lua, header)
		end,
	}
)

do
	return
end

if render then
	os.execute("cd ../ffibuild/bullet/ && bash make.sh")
	os.execute("cp -f ../ffibuild/bullet/bullet.lua ./bullet.lua")
	return
end

--ffibuild.Clone("https://github.com/bulletphysics/bullet3.git", "repo/bullet")
--ffibuild.Clone("https://github.com/AndresTraks/BulletSharpPInvoke.git", "repo/libbulletc")
--os.execute("mkdir -p repo/libbulletc/libbulletc/build")
--os.execute("cd repo/libbulletc/libbulletc/build && cmake .. && make")
--os.execute("cp repo/libbulletc/libbulletc/build/libbulletc.so .")
ffibuild.lib_name = "bullet"
local header = ffibuild.ProcessSourceFileGCC([[
	#include "bulletc.h"

]], "-I./repo/libbulletc/libbulletc/src/")
local meta_data = ffibuild.GetMetaData(header)
local objects = {}

for key, tbl in pairs(meta_data.functions) do
	if key:sub(1, 2) == "bt" then
		local t = key:match("^(.+)_[^_]+$")

		if t then
			objects[t] = objects[t] or {ctors = {}, functions = {}}
		else

		--			print(key)
		end
	else

	--	print(key)
	end
end

do
	local temp = {}

	for k, v in pairs(objects) do
		v.name = k
		list.insert(temp, v)
	end

	list.sort(temp, function(a, b)
		return #a.name > #b.name
	end)

	objects = temp
end

local done = {}

for _, info in ipairs(objects) do
	for key, tbl in pairs(meta_data.functions) do
		if not done[key] and key:sub(1, #info.name) == info.name then
			if key:find("_new", nil, true) then
				list.insert(info.ctors, key)
				done[key] = true
			else
				local friendly = key:sub(#info.name + 2)

				if friendly == "" then friendly = key end

				list.insert(
					info.functions,
					{func = key, friendly = ffibuild.ChangeCase(friendly, "fooBar", "FooBar")}
				)
				done[key] = true
			end
		end
	end
end

local header = meta_data:BuildMinimalHeader(
	function(name)
		return name:find("^bt%u")
	end,
	function(name)
		return name:find("^bt%u")
	end,
	true,
	true
)
local lua = ffibuild.StartLibrary(header)
local ffi = require("ffi")
local clib = ffi.load("./libbullet.so")
ffi.cdef(header)
lua = lua .. "library = " .. meta_data:BuildFunctions(
		"^bt(%u.+)",
		nil,
		nil,
		nil,
		function(name)
			local ok, err = pcall(function()
				return clib[name]
			end)

			if not pcall(function()
				return clib[name]
			end) then return false end
		end
	)
lua = lua .. "library.e = " .. meta_data:BuildEnums("^bt(%u.+)")
lua = lua .. "library.metatables = {}\n"
local inheritance = {
	btDiscreteDynamicsWorld = "btDynamicsWorld",
	btDynamicsWorld = "btCollisionWorld",
	btRigidBody = "btCollisionObject",
	btBoxShape = "btConvexInternalShape",
	btSphereShape = "btConvexInternalShape",
	btConvexInternalShape = "btConvexShape",
	btConvexShape = "btCollisionShape",
}

do
	collectgarbage()

	for _, info in ipairs(objects) do
		local s = ""
		s = s .. "do -- " .. info.name .. "\n"
		s = s .. "\tlocal META = {}\n"
		s = s .. "\tlibrary.metatables." .. info.name .. " = META\n"

		if inheritance[info.name] then
			s = s .. "\tfunction META:__index(k)\n"
			s = s .. "\t\tlocal v\n\n"
			s = s .. "\t\tv = META[k]\n"
			s = s .. "\t\tif v ~= nil then\n"
			s = s .. "\t\t\treturn v\n"
			s = s .. "\t\tend\n"
			s = s .. "\t\tv = library.metatables." .. inheritance[info.name] .. ".__index(self, k)\n"
			s = s .. "\t\tif v ~= nil then\n"
			s = s .. "\t\t\treturn v\n"
			s = s .. "\t\tend\n"
			s = s .. "\tend\n"
		else
			s = s .. "\tMETA.__index = function(s, k) return META[k] end\n"
		end

		for i, func_name in ipairs(info.ctors) do
			if i == 1 then i = "" end

			s = s .. "\tfunction library.Create" .. info.name:sub(3) .. i .. "(...)\n"
			s = s .. "\t\tlocal self = setmetatable({}, META)\n"
			s = s .. "\t\tself.ptr = CLIB." .. func_name .. "(...)\n"
			s = s .. "\t\treturn self\n"
			s = s .. "\tend\n"
		end

		for k, v in ipairs(info.functions) do
			s = s .. "\tfunction META:" .. v.friendly .. "(...)\n"
			s = s .. "\t\treturn CLIB." .. v.func .. "(self.ptr, ...)\n"
			s = s .. "\tend\n"
		end

		s = s .. "end\n"
		lua = lua .. s
	end
end

ffibuild.EndLibrary(lua, header)