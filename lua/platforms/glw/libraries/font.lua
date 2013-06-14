local types = {}
local META = {}
META.__index = META

for line in ftgl.header:gmatch("(.-)\n") do
	local name = line:match("ftgl(.-)%(FTGLfont")
	
	if name then
		local func = ftgl.lib["ftgl" .. name]
		
		name = name:gsub("Font", "")
		
		if name == "Render" then
			META[name] = function(self, str, mode)
				mode = mode or e.FTGL_RENDER_ALL
				func(self.__ptr, str, mode)
			end
		else
			META[name] = function(self, ...)
				func(self.__ptr, ...)
			end
		end
	else
		local type = line:match("ftglCreate(.-)Font%(")
		if type then
			types[type:lower()] = ftgl.lib["ftglCreate" .. type .. "Font"]
		end
	end
end  

function Font(file_name, type)
	if not type or not types[type] then 
		type = "pixmap"
	end
	
	local ptr = types[type](file_name)
	local self = setmetatable({}, META)
	self.__ptr = ptr
	
	return self
end