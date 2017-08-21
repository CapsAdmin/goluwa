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


local function float(high, low)
	local b = low
	local sign = 1
	if b >= 128 then
		sign = -1
		b = b - 128
	end
	local exponent = bit.rshift(b, 2) - 15
	local mantissa = bit.band(b, 3) / 4

	b = high
	mantissa = mantissa + b / 4 / 256

	if mantissa == 0 and exponent == -15 then
		return 0
	else
		return (mantissa + 1) * math.pow(2, exponent) * sign
	end
end

local function half_buffer_to_float_buffer(length, buffer)
	local out = ffi.new("float[?]", length)
	local i2 = 0
	for i = 1, length * 2, 2 do
		i = i -1
		out[i2] = float(buffer[i + 0], buffer[i + 1])
		i2 = i2 + 1
	end
	return ffi.cast("uint8_t *", out)
end

local function cleanup(vtf_material, vtf_image)
	library.ImageDestroy()
	library.MaterialDestroy()
	library.DeleteMaterial(vtf_material[0])
	library.DeleteImage(vtf_image[0])
end

local function get_error()
	return ffi.string(library.GetLastError())
end

function library.LoadImage(data, path_hint)
	local vtf_image = ffi.new("unsigned int[1]")
	if library.CreateImage(vtf_image) == 0 then return false, "failed to create image: " .. get_error() end
	if library.BindImage(vtf_image[0]) == 0 then return false, "failed to bind image: " .. get_error() end

	-- dummy material
	local vtf_material = ffi.new("unsigned int[1]")
	if library.CreateMaterial(vtf_material) == 0 then return false, "failed to create material: " .. get_error() end
	if library.BindMaterial(vtf_material[0]) == 0 then return false, "failed to bind material: " .. get_error() end

	if library.ImageLoadLump(ffi.cast("void *", data), #data, 0) == 0 then
		return nil, "unknown format"
	end

	local width = library.ImageGetWidth()
	local height = library.ImageGetHeight()
	local internal_format = library.ImageGetFormat()
	local conversion_format = internal_format
	local buffer

	do
		local internal_buffer = library.ImageGetData(0, 0, 0, 0)
		local info = library.ImageGetImageFormatInfo(internal_format)

		if info.bIsCompressed == 1 then
			if info.uiAlphaBitsPerPixel > 0 then
				conversion_format = library.e.IMAGE_FORMAT_RGBA8888
			else
				conversion_format = library.e.IMAGE_FORMAT_RGB888
			end
		end

		local size = library.ImageComputeImageSize(width, height, 1, 1, conversion_format)
		buffer = ffi.new("uint8_t[?]", size)

		if library.ImageConvert(internal_buffer, buffer, width, height, internal_format, conversion_format) == 0 then
			cleanup(vtf_material, vtf_image)
			return false, "conversion from " .. tostring(internal_format) .. " to " .. tostring(conversion_format) .. " failed: " .. get_error()
		end
	end

	local format = "rgba"
	local type = "unsigned_byte"

	if conversion_format == library.e.IMAGE_FORMAT_RGBA8888 then
		format = "rgba"
	elseif conversion_format == library.e.IMAGE_FORMAT_RGB888 then
		format = "rgb"
	elseif conversion_format == library.e.IMAGE_FORMAT_BGRA8888 then
		if path_hint and path_hint:find(".+/[^/]-hdr[^/]-%.vtf") then
			format = "bgr"
			type = "float"

			local new = ffi.new("float[?][3]", width * height)
			local i2 = 0
			for i = 1, (width * height) * 4, 4 do
				i = i - 1
				local r = buffer[i + 0]
				local g = buffer[i + 1]
				local b = buffer[i + 2]
				local a = buffer[i + 3]

				r = (r * (a * 16)) / 262144
				g = (g * (a * 16)) / 262144
				b = (b * (a * 16)) / 262144

				new[i2][0] = r
				new[i2][1] = g
				new[i2][2] = b
				i2 = i2 + 1
			end
			buffer = new
		else
			format = "bgra"
		end
	elseif conversion_format == library.e.IMAGE_FORMAT_BGR888 then
		format = "bgr"
	elseif conversion_format == library.e.IMAGE_FORMAT_RGBA32323232F then
		format = "rgba"
		type = "float"
	elseif conversion_format == library.e.IMAGE_FORMAT_RGB323232F then
		format = "rgb"
		type = "float"
	elseif conversion_format == library.e.IMAGE_FORMAT_RGBA16161616F then
		format = "rgba"
		type = "float"
		buffer = half_buffer_to_float_buffer((width * height) * 4, buffer)
	elseif conversion_format == library.e.IMAGE_FORMAT_RGB161616F then
		format = "rgb"
		type = "float"
		buffer = half_buffer_to_float_buffer((width * height) * 4, buffer)
	else
		wlog("unhandled image format: %s", conversion_format)
	end

	cleanup(vtf_material, vtf_image)

	return {
		buffer = buffer,
		width = width,
		height = height,
		format = format,
		type = type,
	}
end
]]

ffibuild.EndLibrary(lua, header)
