local header = include("header.lua") 
local enums = include("enums.lua")

local lib = assert(ffi.load("libsndfile"))

ffi.cdef(header)  

header = header:gsub("%s+", " ")
header = header:gsub(";", "%1\n")

local libsoundfile = {lib = lib, e = enums}

for line in header:gmatch("(.-)\n") do
	if not line:find("typedef") then
		local func = line:match("(sf_%S-) %(")
		if func then
		
			local temp = func
			temp = temp:gsub("(str)[^ing]", "string")
			temp = temp:gsub("_fd", "_file_descriptor")
			temp = temp:gsub("_readf", "_read_frames")
			local friendly = ("_" .. temp):sub(4):gsub("(_%l)", function(char) return char:sub(2,2):upper() end)
			
			libsoundfile[friendly] = lib[func]
		end
	end
end 

-- eek
libsoundfile.ErrorString = libsoundfile.ErrorStr
libsoundfile.ErrorStr = nil

libsoundfile.StringError = libsoundfile.Stringrror
libsoundfile.Stringrror = nil 

return libsoundfile