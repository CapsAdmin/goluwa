-- header stolen from https://code.google.com/p/lua-files!!

local header = require("lj-libusb.header")
local enums =require("lj-libusb.enums")

ffi.cdef(header) 
 
local lib = assert(ffi.load("libusb"))
 
local libusb = {
	lib = lib,
	e = enums,
}

local prefix = "libusb_"
 
for line in header:gmatch("(.-)\n") do
	if not line:find("typedef") and not line:find("=")  then
		local name = line:match(" "..prefix.."(.-)%(")
		if name then  
			name = name:trim()
			local return_type = line:match("^(.-)%s"..prefix)
			local friendly_name = name -- name:gsub("_", "")
			local ok, func = pcall(function() return lib[prefix .. name] end)
			
			if ok then
				libusb[friendly_name] = func
			else
				print(func)
			end
		end
	end
end

libusb.lib = lib
 
return libusb   
