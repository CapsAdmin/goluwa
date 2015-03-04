local gl = require("libraries.ffi.opengl") -- OpenGL
local render = (...) or _G.render

for k,v in pairs(render) do	
	if k:sub(0,6) == "Create" and not k:find("From") then
		local name = k:sub(7)
		_G[name] = render["Create" .. name]
	end
end