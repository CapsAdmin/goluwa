-- header stolen from https://code.google.com/p/lua-files!!

local header = include("header.lua") 
local errors = include("errors.lua")
local enums = include("enums.lua")
  
ffi.cdef(header) 
 
local lib = assert(ffi.load("freetype"))
 
local freetype = {
	lib = lib,
}
 
for line in header:gmatch("(.-)\n") do
	if not line:find("typedef") and not line:find("=")  then
		local name = line:match(" FT_(.-)%(")
		
			
		if name then  
			name = name:trim()
			local return_type = line:match("^(.-)%sFT_")
			local friendly_name = name:gsub("_", "")
			local ok, func = pcall(function() return lib["FT_" .. name] end)
			
			if ok then
				freetype[friendly_name] = function(...)
					local val = func(...)
					
					if return_type == "FT_Error" and val ~= 0 then
						local info = debug.getinfo(2)
				
						logf("[freetype] %q in function %s at %s:%i\n", errors[val] or ("unknonw error " .. val), info.name, info.source, info.currentline)
					end
					
										
					if freetype.logcalls then
						setlogfile("freetype_calls")
							logf("%s = FT_%s(%s)\n", serializer.GetLibrary("luadata").ToString(val), name, table.concat(tostring_args(...), ",\t"))
						setlogfile()
					end					
					
					return val
				end
			else
				print(func)
			end
		end
	end
end

freetype.lib = lib
 
return freetype   
