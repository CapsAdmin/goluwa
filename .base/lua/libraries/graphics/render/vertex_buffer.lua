local gl = require("lj-opengl")
local render = (...) or _G.render

local META = prototype.CreateTemplate("vertex_buffer")

prototype.GetSet(META, "UpdateIndices", true)
prototype.GetSet(META, "Mode", "triangles")

function render.CreateVertexBuffer(shader, vertices, indices, is_valid_table)
	checkx(shader, "shader")
	--check(vertices, "cdata", "table")
	--check(indices, "cdata", "table", "number", "nil")
	
	local vertex_attributes = shader:GetVertexAttributes() 
	local vertices, indices, vertices_size, indices_size = shader:CreateBuffersFromTable(vertices, indices, is_valid_table)
	
	local self = prototype.CreateObject(META)
	self.vertices_id = gl.GenBuffer()
	self.indices_id = gl.GenBuffer()
	self.vao_id = gl.GenVertexArray()
	self.vertex_attributes = vertex_attributes
	
	self:UpdateBuffer(vertices, indices, vertices_size, indices_size)

	return self
end 

function META:OnRemove()
	gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.vertices_id))
	gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.indices_id))
end

local translate = {
	points = gl.e.GL_POINTS, --Draws points on screen. Every vertex specified is a point.
	lines = gl.e.GL_LINES, --Draws lines on screen. Every two vertices specified compose a line.
	line_strip = gl.e.GL_LINE_STRIP, --Draws connected lines on screen. Every vertex specified after first two are connected.
	line_loop = gl.e.GL_LINE_LOOP, --Draws connected lines on screen. The last vertex specified is connected to first vertex.
	triangles = gl.e.GL_TRIANGLES, --Draws triangles on screen. Every three vertices specified compose a triangle.
	triangle_strip = gl.e.GL_TRIANGLE_STRIP, --Draws connected triangles on screen. Every vertex specified after first three vertices creates a triangle.
	triangle_fan = gl.e.GL_TRIANGLE_FAN, --Draws connected triangles like GL_TRIANGLE_STRIP, except draws triangles in fan shape.
	quads = gl.e.GL_QUADS, --Draws quadrilaterals (4 – sided shapes) on screen. Every four vertices specified compose a quadrilateral.
	quad_strip = gl.e.GL_QUAD_STRIP, --Draws connected quadrilaterals on screen. Every two vertices specified after first four compose a connected quadrilateral.
	polygon = gl.e.GL_POLYGON, --Draws a polygon on screen. Polygon can be composed of as many sides as you want.
}

function META:Draw(count)
	render.BindVertexArray(self.vao_id)
	--render.BindArrayBuffer(self.vertices_id)	
	gl.BindBuffer(gl.e.GL_ELEMENT_ARRAY_BUFFER, self.indices_id)
	gl.DrawElements(translate[self.Mode] or translate.triangles, count or self.indices_count, gl.e.GL_UNSIGNED_INT, nil)
end

function META:UpdateBuffer(vertices, indices, vertices_size, indices_size)
	vertices = vertices or self.vertices
	indices = indices or self.indices
	
	if vertices then
		self.vertices = vertices
		self.vertices_size = vertices_size or ffi.sizeof(vertices)
		
		render.BindArrayBuffer(self.vertices_id)
		gl.BufferData(gl.e.GL_ARRAY_BUFFER, self.vertices_size, vertices, gl.e.GL_STATIC_DRAW)
	end
	
	if indices and self.UpdateIndices then
		indices_size = indices_size or ffi.sizeof(self.indices)
		
		self.indices = indices
		self.indices_size = indices_size
		self.indices_count = indices_size / ffi.sizeof("unsigned int")
		
		gl.BindBuffer(gl.e.GL_ELEMENT_ARRAY_BUFFER, self.indices_id)
		gl.BufferData(gl.e.GL_ELEMENT_ARRAY_BUFFER, indices_size, indices, gl.e.GL_STATIC_DRAW)
	end
		
	render.BindVertexArray(self.vao_id)		
		for _, data in ipairs(self.vertex_attributes) do
			gl.EnableVertexAttribArray(data.location)
			gl.VertexAttribPointer(data.location, data.arg_count, data.enum, false, data.stride, data.type_stride)
		end
	render.BindVertexArray(0)
	
	render.BindArrayBuffer(0)
	gl.BindBuffer(gl.e.GL_ELEMENT_ARRAY_BUFFER, 0)
	
	--logf("[render] updated %s with %s amount of data\n", self, utility.FormatFileSize(self.vertices_size + self.indices_size))
end

function META:UnreferenceMesh()
	self.vertices = nil
	self.indices = nil
	collectgarbage("step")
end

prototype.Register(META)