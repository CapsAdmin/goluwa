package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")


ffibuild.BuildSharedLibrary(
	"glfw",
	"https://github.com/glfw/glfw.git",
	"cmake -DBUILD_SHARED_LIBS=1 . && make"
)

local header = ffibuild.BuildCHeader([[
	#include "vulkan.h"
	#include "GLFW/glfw3.h"
	#include "GLFW/glfw3native.h"
]], "-I./repo/include -I./../vulkan/repo/include/vulkan")

local meta_data = ffibuild.GetMetaData(header)

meta_data.functions.glfwCreateWindowSurface.return_type = ffibuild.CreateType("type", "int")
meta_data.functions.glfwCreateWindowSurface.arguments[1] = ffibuild.CreateType("type", "void *")
meta_data.functions.glfwCreateWindowSurface.arguments[3] = ffibuild.CreateType("type", "void *")
meta_data.functions.glfwCreateWindowSurface.arguments[4] = ffibuild.CreateType("type", "void * *")

meta_data.functions.glfwGetInstanceProcAddress.arguments[1] = ffibuild.CreateType("type", "void *")

meta_data.functions.glfwGetPhysicalDevicePresentationSupport.arguments[1] = ffibuild.CreateType("type", "void *")
meta_data.functions.glfwGetPhysicalDevicePresentationSupport.arguments[2] = ffibuild.CreateType("type", "void *")

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^glfw") end, function(name) return name:find("^GLFW") end, true)

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^glfw(.+)")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^GLFW_(.+)", "./repo/include/GLFW/glfw3.h", "GLFW_")

lua = lua .. [[
function library.GetRequiredInstanceExtensions(extra)
	local count = ffi.new("uint32_t[1]")
	local array = CLIB.glfwGetRequiredInstanceExtensions(count)
	local out = {}
	for i = 0, count[0] - 1 do
		table.insert(out, ffi.string(array[i]))
	end
	if extra then
		for i,v in ipairs(extra) do
			table.insert(out, v)
		end
	end
	return out
end

function library.CreateWindowSurface(instance, window, huh)
	local box = ffi.new("struct VkSurfaceKHR_T * [1]")
	local status = CLIB.glfwCreateWindowSurface(instance, window, huh, ffi.cast("void **", box))
	if status == 0 then
		return box[0]
	end
	return nil, status
end
]]

ffibuild.EndLibrary(lua, header)