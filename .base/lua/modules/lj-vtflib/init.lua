local enums = require("lj-vtflib.enums")
local header = require("lj-vtflib.header")

ffi.cdef(header) 

local lib = ffi.load("vtflib")

local vl = {
	lib = lib,
	e = enums,
	header = header,
	debug = true,
}

-- put all the functions in the glfw table
for line in header:gmatch("(.-)\n") do
	local name = line:match("[vV][lT]%u.-vl(.-)%(")
		
	if name and not line:find("typedef") then
		local func = lib["vl" .. name]
		vl[name] = function(...)
			local val = func(...)
			
			if vl.debug and name ~= "GetLastError" then
				local str = vl.GetLastError()
				str = ffi.string(str)
				if str ~= "" and  str ~= vl.last_error then
					vl.last_error = str
					error("HLLib " .. str, 2)
				end
			end
			
			return val
		end
	end
end

for key, val in pairs(enums) do
	e[key] = val
end

do
	local reverse_enums = {}

	for k,v in pairs(enums) do
		local nice = k:lower():sub(6)
		reverse_enums[v] = nice
	end

	function vl.EnumToString(num)
		return reverse_enums[num]
	end
end

function vl.LoadImage(data, format)
	format = format or e.IMAGE_FORMAT_BGRA8888
	
	local uiVTFImage = ffi.new("unsigned int[1]")
	vl.CreateImage(uiVTFImage)
	vl.BindImage(uiVTFImage[0])

	local uiVMTMaterial = ffi.new("unsigned int[1]")

	vl.CreateMaterial(uiVMTMaterial)
	vl.BindMaterial(uiVMTMaterial[0])

	if vl.ImageLoadLump(ffi.cast("void *", data), #data, 0) == 0 then
		return nil, "unknown format"
	end

	local w, h = vl.ImageGetWidth(), vl.ImageGetHeight()
	local size = vl.ImageComputeImageSize(w, h, 1, 1, format)
	local buffer = ffi.new("vlByte[?]", size)

	vl.ImageConvert(vl.ImageGetData(0, 0, 0, 0), buffer, w, h, vl.ImageGetFormat(), format)

	return buffer, w, h
end

vl.Initialize() 

return vl