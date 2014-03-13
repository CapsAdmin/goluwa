-- https://github.com/malkia/ufo/blob/master/ffi/OpenAL.lua

-- The code below was contributed by David Hollander along with OpenALUT.cpp
-- To run on Windows, there are few choices, easiest one is to download
-- http://connect.creativelabs.com/openal/Downloads/oalinst.zip
-- and run the executable from inside of it (I've seen couple of games use it).

local header = include("header.lua") 

local enums = include("enums.lua")
local extensions = include("extensions.lua")

local reverse_enums = {}
for k,v in pairs(enums) do 
	k = k:gsub("AL_", "")
	k = k:gsub("_", " ")
	k = k:lower()	

	reverse_enums[v] = k 
end

for k,v in pairs(enums) do
	e[k] = v
end
 
ffi.cdef(header)

local library = ffi.load(WINDOWS and "openal32" or "openal")

local al = _G.al or {}

local function add_al_func(name, func)
	al[name] = function(...) 
		local val = func(...)
		
		if al.logcalls then
			setlogfile("al_calls")
				logf("%s = al%s(%s)", luadata.ToString(val), name, table.concat(tostring_args(...), ",\t"))
			setlogfile()
		end
		
		if name ~= "GetError" and al.debug then
		
			local code = al.GetError()
		
			if code ~= 0 then
				local str = reverse_enums[code] or "unkown error"
				
				local info = debug.getinfo(2)
				for i = 1, 10 do
					if info.source:find("al.lua", nil, true) then
						info = debug.getinfo(2+i)
					else
						break
					end
				end
				
				logf("[openal] %q in function %s at %s:%i", str, info.name, info.short_src, info.currentline)
			end
		end
		
		return val
	end
end

for line in header:gmatch("(.-)\n") do
	local func_name = line:match(" (al%u.-)%(")
	if func_name then
		add_al_func(func_name:sub(3), library[func_name])
	end 
end

for name, type in pairs(extensions) do
	local func = al.GetProcAddress(name)
	func = ffi.cast(type, func)
	
	al[name:sub(3)] = func
end

for name, func in pairs(al) do
	if name:find("Gen%u%l") then
		al[name:sub(0,-2)] = function()
			local id = ffi.new("ALuint [1]") 
			al[name](1, id) 
			return id[0]
		end
	end
end

return al
