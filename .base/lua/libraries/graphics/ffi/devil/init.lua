local header = include("header.lua") 

ffi.cdef(header)

local lib = assert(ffi.load("devil"))
ffi.cdef("ILboolean iluFlipImage(void);")
local util = ffi.load("ilu")

local devil = {
	lib = lib, 
}
 
function devil.LoadImage(data, flip)
	local buffer = ffi.cast("const unsigned char *const ", data)

	local id = ffi.new("ILuint[1]")
	lib.ilGenImages(1, id)
	lib.ilBindImage(id[0])
	
	local width, height
	
	if lib.ilLoadL("IL_TYPE_UNKNOWN", buffer, #data) ~= 0 then
		if flip and util then util.iluFlipImage() end
		lib.ilConvertImage("IL_BGRA", "IL_UNSIGNED_BYTE")
		
		local size = lib.ilGetInteger("IL_IMAGE_SIZE_OF_DATA")
		width = lib.ilGetInteger("IL_IMAGE_WIDTH")
		height = lib.ilGetInteger("IL_IMAGE_HEIGHT")
		data = ffi.new("char[?]", size)
		ffi.copy(data, lib.ilGetData(), size)
	else
		data = nil
		width = "unknown format"
	end
	
	lib.ilDeleteImages(1, id)
	
	return data, width, height
end

return devil