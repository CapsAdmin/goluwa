package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

local header = ffibuild.NixBuild({
	name = "freeimage",
	src = [[
	#include "FreeImage.h"
]]})


local meta_data = ffibuild.GetMetaData(header)
local header = meta_data:BuildMinimalHeader(function(name) return name:find("^FreeImage_") end, function(name) return name:find("^FI") end, true, true)
local lua = ffibuild.StartLibrary(header)

meta_data.functions.FreeImage_RegisterExternalPlugin = nil

lua = lua .. "library = " .. meta_data:BuildFunctions("^FreeImage_(.+)")

do -- enums
	lua = lua .. "library.e = {\n"
	for basic_type, type in pairs(meta_data.enums) do
		for i, enum in ipairs(type.enums) do
			local friendly = enum.key:match("^FI(.+)")
			if friendly then
				if friendly:find("^T_") then
					friendly = friendly:gsub("^T", "IMAGE_TYPE")
				elseif friendly:find("^CC_") then
					friendly = friendly:gsub("^CC", "COLOR_CHANNEL")
				elseif friendly:find("^C_") then
					friendly = friendly:gsub("^C", "COLOR_TYPE")
				elseif friendly:find("^F_") then
					friendly = friendly:gsub("^F", "FORMAT")
				elseif friendly:find("^Q_") then
					friendly = friendly:gsub("^Q", "QUANTIZE")
				elseif friendly:find("^LTER_") then
					friendly = friendly:gsub("^LTER", "IMAGE_FILTER")
				elseif friendly:find("^D_") then
					friendly = friendly:gsub("^D", "DITHER")
				elseif friendly:find("^MD_") then
					friendly = friendly:gsub("^MD", "METADATA")
				elseif friendly:find("^DT_") then
					friendly = friendly:gsub("^DT", "METADATA_TYPE")
				elseif friendly:find("^JPEG_OP_") then
					friendly = friendly:gsub("^JPEG_OP", "JPEG_OPERATION")
				elseif friendly:find("^JPEG_OP_") then
					friendly = friendly:gsub("^JPEG_OP", "JPEG_OPERATION")
				elseif friendly:find("^TMO_") then
					friendly = friendly:gsub("^TMO", "TONEMAP_OPERATOR")
				end
				lua =  lua .. "\t" .. friendly .. " = ffi.cast(\""..basic_type.."\", \""..enum.key.."\"),\n"
			end
		end
	end
	lua = lua .. "}\n"
end

lua = lua .. [[
do
	do
		local function pow2ceil(n)
			return 2 ^ math.ceil(math.log(n) / math.log(2))
		end

		local function create_mip_map(bitmap, w, h, div)
			local width = pow2ceil(w)
			local height = pow2ceil(h)

			local size = width > height and width or height

			size = size / (2 ^ div)

			local new_bitmap = ffi.gc(library.Rescale(bitmap, size, size, library.e.IMAGE_FILTER_BILINEAR), library.Unload)

			return {
				data = library.GetBits(new_bitmap),
				size = library.GetMemorySize(new_bitmap),
				width = size,
				height = size,
				new_bitmap = new_bitmap,
			}
		end

		function library.LoadImageMipMaps(file_name, flags, format)
			local file = io.open(file_name, "rb")
			local data = file:read("*all")
			file:close()

			local buffer = ffi.cast("unsigned char *", data)

			local stream = library.OpenMemory(buffer, #data)
			local type = format or library.GetFileTypeFromMemory(stream, #data)

			local temp = library.LoadFromMemory(type, stream, flags or 0)
			local bitmap = library.ConvertTo32Bits(temp)


			local width = library.GetWidth(bitmap)
			local height = library.GetHeight(bitmap)

			local images = {}

			for level = 0, math.floor(math.log(math.max(width, height)) / math.log(2)) do
				images[level] = create_mip_map(bitmap, width, height, level)
			end

			library.Unload(bitmap)
			library.Unload(temp)

			library.CloseMemory(stream)

			return images
		end
	end

	function library.LoadImage(data)
		local stream_buffer = ffi.cast("unsigned char *", data)
		local stream = library.OpenMemory(stream_buffer, #data)

		local type = library.GetFileTypeFromMemory(stream, #data)

		if type == library.e.FORMAT_UNKNOWN or type > library.e.FORMAT_RAW then -- huh...
			library.CloseMemory(stream)
			error("unknown format", 2)
		end

		local bitmap = library.LoadFromMemory(type, stream, 0)

		local image_type = library.GetImageType(bitmap)
		local color_type = library.GetColorType(bitmap)

		stream_buffer = nil

		local format = "bgra"
		local type = "unsigned_byte"

		if color_type == library.e.COLOR_TYPE_RGBALPHA then
			format = "bgra"
		elseif color_type == library.e.COLOR_TYPE_RGB then
			format = "bgr"
		elseif color_type == library.e.COLOR_TYPE_MINISBLACK or color_type == library.e.COLOR_TYPE_MINISWHITE then
			format = "r"
		else
			bitmap = library.ConvertTo32Bits(bitmap)

			format = "bgra"
			wlog("unhandled freeimage color type: %s\nconverting to 8bit rgba", color_type)
		end

		ffi.gc(bitmap, library.Unload)

		if image_type == library.e.IMAGE_TYPE_BITMAP then
			type = "unsigned_byte"
		elseif image_type == library.e.IMAGE_TYPE_RGBF then
			type = "float"
			format = "rgb"
		elseif image_type == library.e.IMAGE_TYPE_RGBAF then
			type = "float"
			format = "rgba"
		else
			wlog("unhandled freeimage format type: %s", image_type)
		end

		-- the image type of some png images are RGB but bpp is actuall 32bit (RGBA)
		local bpp = library.GetBPP(bitmap)

		if bpp == 32 then
			format = "bgra"
		end

		local ret = {
			buffer = library.GetBits(bitmap),
			width = library.GetWidth(bitmap),
			height = library.GetHeight(bitmap),
			format = format,
			type = type,
		}

		library.CloseMemory(stream)

		return ret
	end

	function library.LoadMultiPageImage(data, flags)
		local buffer = ffi.cast("unsigned char *", data)

		local stream = library.OpenMemory(buffer, #data)
		local type = library.GetFileTypeFromMemory(stream, #data)

		local temp = library.LoadMultiBitmapFromMemory(type, stream, flags or 0)
		local count = library.GetPageCount(temp)

		local out = {}

		for page = 0, count - 1 do
			local temp = library.LockPage(temp, page)
			local bitmap = library.ConvertTo32Bits(temp)

			local tag = ffi.new("struct FITAG *[1]")
			library.GetMetadata(library.e.METADATA_ANIMATION, bitmap, "FrameLeft", tag)
			local x = tonumber(ffi.cast("int", library.GetTagValue(tag[0])))

			library.GetMetadata(library.e.METADATA_ANIMATION, bitmap, "FrameTop", tag)
			local y = tonumber(ffi.cast("int", library.GetTagValue(tag[0])))

			library.GetMetadata(library.e.METADATA_ANIMATION, bitmap, "FrameTime", tag)
			local ms = tonumber(ffi.cast("int", library.GetTagValue(tag[0]))) / 1000

			library.DeleteTag(tag[0])

			local data = library.GetBits(bitmap)
			local width = library.GetWidth(bitmap)
			local height = library.GetHeight(bitmap)

			ffi.gc(bitmap, library.Unload)

			table.insert(out, {w = width, h = height, x = x, y = y, ms = ms, data = data})
		end

		library.CloseMultiBitmap(temp, 0)

		return out
	end

	function library.ImageToBuffer(data, format, force_32bit)
		format = format or "png"

		local bitmap = library.ConvertFromRawBits(data.buffer, data.width, data.height, data.width * #data.format, #data.format * 8, 0,0,0,0)
		local temp
		if force_32bit then
			temp = bitmap
			bitmap = library.ConvertTo32Bits(temp)
		end

		local mem = library.OpenMemory(nil, 0)
		library.SaveToMemory(library.e["FORMAT_" .. format:upper()], bitmap, mem, 0)
		local size = library.TellMemory(mem)
		local buffer_box = ffi.new("uint8_t *[1]")
		local size_box = ffi.new("unsigned int[1]")
		local out_buffer = ffi.new("uint8_t[?]", size)
		buffer_box[0] = out_buffer
		size_box[0] = size
		library.AcquireMemory(mem, buffer_box, size_box)

		library.Unload(bitmap)
		if temp then library.Unload(temp) end
		library.CloseMemory(mem)

		return buffer_box[0], size_box[0]
	end
end
]]

ffibuild.EndLibrary(lua, header)
