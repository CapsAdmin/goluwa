local render = (...) or _G.render

local function cvar(name, def, callback)
	console.CreateVariable("render_" .. name, def, callback)
end

local modes = {
	fill = e.GL_FILL,
	line = e.GL_LINE,
	point = e.GL_POINT,
}

cvar("mode", "fill", function(type) 
	gl.PolygonMode(e.GL_FRONT_AND_BACK, modes[type])
end)

cvar("line_width", 1, gl.LineWidth)
cvar("point_size", 1, gl.PointSize)