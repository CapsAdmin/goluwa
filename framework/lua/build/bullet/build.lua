package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

ffibuild.Clone("https://github.com/bulletphysics/bullet3.git", "repo/bullet")
ffibuild.Clone("https://github.com/AndresTraks/BulletSharpPInvoke.git", "repo/libbulletc")

os.execute("mkdir -p repo/libbulletc/libbulletc/build")
os.execute("cd repo/libbulletc/libbulletc/build && cmake .. && make")
os.execute("cp libbulletc.so ../../../../libbullet.so")

ffibuild.lib_name = "bullet"

local header = ffibuild.BuildCHeader([[
	#include "bulletc.h"

]], "-I./repo/libbulletc/libbulletc/src/")

local temp = ""
for chunk in header:gmatch("extern \"C\"\n(%b{})") do
   temp = temp .. chunk:sub(2,-2)
end

local meta_data = ffibuild.GetMetaData(temp)

meta_data.functions.btWorldImporter_createGearConstraint = nil
meta_data.functions.btRaycastVehicle_getSteeringValue = nil
meta_data.functions.btAlignedObjectArray_btSoftBody_JointPtr_resizeNoInitialize = nil
meta_data.functions.btRaycastVehicle_setPitchControl = nil

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^bt%u") end, function(name) return name:find("^bt%u") end, true, true)

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^bt(%u.+)")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^bt(%u.+)")

ffibuild.EndLibrary(lua, header)
