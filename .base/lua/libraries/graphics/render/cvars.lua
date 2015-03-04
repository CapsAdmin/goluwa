local gl = require("libraries.ffi.opengl") -- OpenGL
local render = (...) or _G.render

local function cvar(name, def, callback)
	console.CreateVariable("render_" .. name, def, callback)
end

local modes = {
	fill = gl.e.GL_FILL,
	line = gl.e.GL_LINE,
	point = gl.e.GL_POINT,
}

cvar("mode", "fill", function(type) 
	gl.PolygonMode(gl.e.GL_FRONT_AND_BACK, modes[type] or modes.fill)
end)

cvar("line_width", 1, gl.LineWidth)
cvar("point_size", 1, gl.PointSize)