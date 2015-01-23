local header = require("lj-freeimage.header")
local enums = require("lj-freeimage.enums")

ffi.cdef(header)

local lib = assert(ffi.load("freeimage"))

local freeimage = {
	lib = lib, 
	e = enums,
}
 
function freeimage.LoadMultiPageImage(data, flags)
	local buffer = ffi.cast("const unsigned char *const ", data)

	local stream = lib.FreeImage_OpenMemory(buffer, #data)
	local type = lib.FreeImage_GetFileTypeFromMemory(stream, #data)
				
	local temp = lib.FreeImage_LoadMultiBitmapFromMemory(type, stream, flags or 0)
	local count = lib.FreeImage_GetPageCount(temp)
	
	local out = {}
	
	for page = 0, count - 1 do
		local temp = lib.FreeImage_LockPage(temp, page)
		local bitmap = lib.FreeImage_ConvertTo32Bits(temp)
		
		local tag = ffi.new("FI_TAG *[1]")
		lib.FreeImage_GetMetadata(enums.FIMD_ANIMATION, bitmap, "FrameLeft", tag)
		local x = tonumber(ffi.cast("int", lib.FreeImage_GetTagValue(tag[0])))
		
		lib.FreeImage_GetMetadata(enums.FIMD_ANIMATION, bitmap, "FrameTop", tag)
		local y = tonumber(ffi.cast("int", lib.FreeImage_GetTagValue(tag[0])))
		
		lib.FreeImage_GetMetadata(enums.FIMD_ANIMATION, bitmap, "FrameTime", tag)
		local ms = tonumber(ffi.cast("int", lib.FreeImage_GetTagValue(tag[0]))) / 1000
				
		lib.FreeImage_DeleteTag(tag[0])
		
		local data = lib.FreeImage_GetBits(bitmap) 
		local width = lib.FreeImage_GetWidth(bitmap)
		local height = lib.FreeImage_GetHeight(bitmap)
		
		ffi.gc(bitmap, lib.FreeImage_Unload)
		
		table.insert(out, {w = width, h = height, x = x, y = y, ms = ms, data = data})
	end
	
	lib.FreeImage_CloseMultiBitmap(temp, 0)
	
	return out
end

function freeimage.LoadImage(data, flags, format)
	local buffer = ffi.cast("const unsigned char *const ", data)

	local stream = lib.FreeImage_OpenMemory(buffer, #data)
	local type = format or lib.FreeImage_GetFileTypeFromMemory(stream, #data)
	
	if type == enums.FIF_UNKNOWN or type > enums.FIF_RAW then -- huh...
		lib.FreeImage_CloseMemory(stream)
		return nil, "unknown format"
	end
		
	local temp = lib.FreeImage_LoadFromMemory(type, stream, flags or 0)
	local bitmap = lib.FreeImage_ConvertTo32Bits(temp)
	lib.FreeImage_Unload(temp)
			
	local data = lib.FreeImage_GetBits(bitmap) 
	local width = lib.FreeImage_GetWidth(bitmap)
	local height = lib.FreeImage_GetHeight(bitmap)
		
	ffi.gc(bitmap, lib.FreeImage_Unload)
	
	lib.FreeImage_CloseMemory(stream)
	
	return data, width, height
end

function freeimage.GetColorFromBuffer(buffer, x, y, w, h)	
	if x < 1 and y < 1 then 
		x = x * w 
		y = y * h 
	end

	local offset = math.floor((y * w + x) * 4)
	
	local b = buffer[offset + 0]%256
	local g = buffer[offset + 1]%256
	local r = buffer[offset + 2]%256
	local a = buffer[offset + 3]%256
	
	return r / 255, g / 255, b / 255, a / 255
end

function freeimage.Save(path, buffer, length, w, h, bpp)
	local bitmap = lib.FreeImage_Allocate(w, h, bpp, 0,0,0)
		
	local color = ffi.new("FI_RGB")
	
	for x = 0, w-1 do
	for y = 0, h-1 do
		local i = (y * w + x)
		color = buffer[i]
				
		if i < length then
			lib.FreeImage_SetPixelColor(bitmap, x, y, color)
		else
			break
		end
	end
	end
	
	lib.FreeImage_Save(enums.FIF_PNG, bitmap, path, 0)
	lib.FreeImage_Unload(bitmap)
end

--[[
local buffer = ffi.new("FI_RGB[?]", 512*512)

for i = 0, 512*512 do
	local color = buffer[i]
	color.r = math.random(255)
	color.g = math.random(255)
	color.b = math.random(255)
	color.a = 255
end

freeimage.Save("test.png", buffer, 512*512, 512, 512, 24)]]

return freeimage