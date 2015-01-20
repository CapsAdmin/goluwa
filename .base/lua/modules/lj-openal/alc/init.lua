local header = require("lj-openal.alc.header")
local enums = require("lj-openal.alc.enums")

local reverse_enums = {}
for k,v in pairs(enums) do 
	k = k:gsub("AL_", "")
	k = k:gsub("_", " ")
	k = k:lower()	

	reverse_enums[v] = k 
end

ffi.cdef(header)

local lib = assert(ffi.load(jit.os == "Windows" and "openal32" or "openal"))

local alc = {
	lib = lib, 
	e = enums,
}

for line in header:gmatch("(.-)\n") do
	local func_name = line:match(" (alc%u.-)%(")
	if func_name then
		local name = func_name:sub(4)
		alc[name] = function(...) 
		
			if name ~= "GetError" and alc.debug and alc.device then
			
				local code = alc.GetError(alc.device)
			
				if code ~= 0 then
					local str = reverse_enums[code] or "unkown error"
					
					local info = debug.getinfo(2)
					
					logf("[alc] %q in function %s at %s:%i\n", str, info.name, info.source, info.currentline)
				end
			end
		
			return lib[func_name](...)
		end
	end
end

return alc