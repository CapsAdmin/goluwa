package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")


ffibuild.BuildSharedLibrary(
	"ode",
	"hg clone https://bitbucket.org/odedevs/ode repo",
	"./bootstrap && ./configure --enable-shared --enable-double-precision --with-libccd=system --with-gimpact --with-libccd && make"
)

local header = ffibuild.BuildCHeader([[
	#include "ode/ode.h"

]], "-I./repo/include")
local meta_data = ffibuild.GetMetaData(header)

meta_data.functions.dThreadingImplementationGetFunctions = nil
meta_data.functions.dWorldSetStepThreadingImplementation = nil
meta_data.functions.dCreateGeomClass = nil
meta_data.functions.dJointAddPUTorque = nil

--for k,v in pairs(meta_data.structs["struct dJointFeedback"].data) do print(v, meta_data.typedefs.dVector3:GetDeclaration(meta_data), v:GetDeclaration(meta_data), v.array_size, "!!") end
--print(meta_data.typedefs.dVector3.array_size)
--do return end

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^d%u") end, function(name) return name:find("^d%u") end, true, true)

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^d(%u.+)")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^d(%u.+)")

ffibuild.EndLibrary(lua, header)
