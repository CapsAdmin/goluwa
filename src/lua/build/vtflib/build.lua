package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")


ffibuild.BuildSharedLibrary(
	"VTFLib",
	"https://github.com/CapsAdmin/VTFLib.git",
	"cmake . -DUSE_LIBTXC_DXTN=0 && make"
)

local header = ffibuild.BuildCHeader([[
	typedef struct tagSVTFImageFormatInfo {} SVTFImageFormatInfo;
	#include "VTFLib.h"
	#include "VTFWrapper.h"
	#include "VMTWrapper.h"
]], "-I./repo/src")


local meta_data = ffibuild.GetMetaData(header)

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^vl") end, function(name) return true end, true, true)
local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^vl(.+)")
lua = lua .. "library.e = " .. meta_data:BuildEnums(nil,nil,nil,"^enum tagVTF")

lua = lua .. [[

function library.LoadImage(data, format)
	local uiVTFImage = ffi.new("unsigned int[1]")
	library.CreateImage(uiVTFImage)
	library.BindImage(uiVTFImage[0])

	local mat = ffi.new("unsigned int[1]")
	library.CreateMaterial(mat)

	library.BindMaterial(mat[0])

	if library.ImageLoadLump(ffi.cast("void *", data), #data, 0) == 0 then
		return nil, "unknown format"
	end

	if not format then
		if library.ImageGetFormat() == library.e.IMAGE_FORMAT_DXT1 then
			format = library.e.IMAGE_FORMAT_RGB888
		else
			format = library.e.IMAGE_FORMAT_RGBA8888
		end
	end

	local w, h = library.ImageGetWidth(), library.ImageGetHeight()
	local size = library.ImageComputeImageSize(w, h, 1, 1, format)
	local buffer = ffi.new("uint8_t[?]", size)

	library.ImageConvert(library.ImageGetData(0, 0, 0, 0), buffer, w, h, library.ImageGetFormat(), format)

	return buffer, w, h, format
end
]]

ffibuild.EndLibrary(lua, header)