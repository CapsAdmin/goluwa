local gl = require("libopengl") -- OpenGL
local render = (...) or _G.render

for k,v in pairs(render) do
	if k:sub(0,6) == "Create" and not k:find("From") then
		local name = k:sub(7)
		if not _G[name] then
			_G[name] = render["Create" .. name]
		end
	end
end