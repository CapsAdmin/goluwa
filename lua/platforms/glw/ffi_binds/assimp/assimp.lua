local header = include("header.lua") 
local enums = include("enums.lua")
 
for k,v in pairs(enums) do e[k] = v end

ffi.cdef(header)

local module = ffi.load("assimp")

local assimp = {}

for line in header:gmatch("(.-)\n") do
	if not line:find("enum") and not line:find("struct") and not line:find("typedef") then
		local func = line:match("(ai%u[%a_]-)%(.-%)") 
		
		if func then 
			assimp[func:sub(3)] = module[func]
		end
		
	end
end

assimp.lib = module

return assimp