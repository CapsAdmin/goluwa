local enums = include("enums.lua")
local header = include("header.lua")

ffi.cdef(header) 

local lib = ffi.load("hllib")

local hl = _G.hl or {}
local e = _G.e or hl

hl.enums = enums
hl.header = header
hl.lib = lib
hl.debug = true

-- put all the functions in the glfw table
for line in header:gmatch("(.-)\n") do
	local name = line:match("[hH][lL]%u.-hl(.-)%(")
		
	if name and not line:find("typedef") then
		local func = lib["hl" .. name]
		hl[name] = function(...)
			local val = func(...)
			
			if hl.debug and name ~= "GetString" then
				local str = hl.GetString(hl.enums.HL_ERROR_LONG_FORMATED)
				str = ffi.string(str)
				
				-- this has to be some bug in hllib because CreateDirectory() is called in some ::Extract function which isn't being called by goluwa
				if str:find("CreateDirectory() failed", nil, true) then return val end
				
				
				if str ~= "<No error reported.>" and  str ~= hl.last_error then
					hl.last_error = str
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

	function hl.EnumToString(num)
		return reverse_enums[num]
	end
end

hl.Initialize()

return hl