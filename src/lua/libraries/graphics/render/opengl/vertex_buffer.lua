local render, META = ...
render = render or _G.render
META = META or prototype.GetRegistered("vertex_buffer")

local gl = require("libopengl")

local translate = {
	patches = "GL_PATCHES", -- tessellation
	points = "GL_POINTS", --Draws points on screen. Every vertex specified is a point.
	lines = "GL_LINES", --Draws lines on screen. Every two vertices specified compose a line.
	line_strip = "GL_LINE_STRIP", --Draws connected lines on screen. Every vertex specified after first two are connected.
	line_loop = "GL_LINE_LOOP", --Draws connected lines on screen. The last vertex specified is connected to first vertex.
	triangles = "GL_TRIANGLES", --Draws triangles on screen. Every three vertices specified compose a triangle.
	triangle_strip = "GL_TRIANGLE_STRIP", --Draws connected triangles on screen. Every vertex specified after first three vertices creates a triangle.
	triangle_fan = "GL_TRIANGLE_FAN", --Draws connected triangles like GL_TRIANGLE_STRIP, except draws triangles in fan shape.
	quads = "GL_QUADS", --Draws quadrilaterals (4 – sided shapes) on screen. Every four vertices specified compose a quadrilateral.
	quad_strip = "GL_QUAD_STRIP", --Draws connected quadrilaterals on screen. Every two vertices specified after first four compose a connected quadrilateral.
	polygon = "GL_POLYGON", --Draws a polygon on screen. Polygon can be composed of as many sides as you want.
}

function META:SetMode(mode)
	self.Mode = mode
	self.gl_mode = translate[mode] or translate.triangle
end


if not NVIDIA_WORKAROUND then
	function render._CreateVertexBuffer(self)
		self.vertex_buffer = gl.CreateBuffer("GL_ARRAY_BUFFER")
		self.element_buffer = gl.CreateBuffer("GL_ELEMENT_ARRAY_BUFFER")
		self.vertex_array = gl.CreateVertexArray()
	end

	function META:OnRemove()
		self.vertex_buffer:Unmap()
		self.vertex_buffer:Delete()

		self.element_buffer:Unmap()
		self.element_buffer:Delete()
	end

	if window.IsExtensionSupported("GL_ARB_direct_state_access") then
		function META:_Draw(count)
			gl.BindVertexArray(self.vertex_array.id)
			gl.DrawElements(self.gl_mode, count or self.indices_length, "GL_UNSIGNED_INT", nil)
		end
	else
		function META:_Draw(count)
			gl.BindVertexArray(self.vertex_array.id)
			self.element_buffer:Bind()
			gl.DrawElements(self.gl_mode, count or self.indices_length, "GL_UNSIGNED_INT", nil)
		end
	end

	local function setup_vertex_array(self)
		if not self.setup_vao and self.Indices and self.Vertices then
			for _, data in ipairs(self.vertex_array_info.attributes) do
				if not window.IsExtensionSupported("GL_ARB_direct_state_access") then
					self.element_buffer:Bind()
					self.vertex_array:VertexBuffer(0, self.vertex_buffer.id, 0, self.vertex_array_info.size)
				end
				self.vertex_array:AttribBinding(data.location, 0)
				self.vertex_array:AttribFormat(data.location, data.row_length, data.number_type, false, data.row_offset)
				self.vertex_array:EnableAttrib(data.location)
			end
			self.setup_vao = true
		end
	end

	function META:_SetVertices(vertices)
		self.vertex_buffer:Data(vertices:GetSize(), vertices:GetPointer(), "GL_DYNAMIC_DRAW")
		setup_vertex_array(self)
		if window.IsExtensionSupported("GL_ARB_direct_state_access") then
			self.vertex_array:VertexBuffer(0, self.vertex_buffer.id, 0, self.vertex_array_info.size)
		end
	end

	function META:_SetIndices(indices)
		self.element_buffer:Data(indices:GetSize(), indices:GetPointer(), "GL_DYNAMIC_DRAW")
		setup_vertex_array(self)
		if window.IsExtensionSupported("GL_ARB_direct_state_access") then
			self.vertex_array:ElementBuffer(self.element_buffer.id)
		end
	end
else
	local ffi = require("ffi")

	function render._CreateVertexBuffer(self)
		self.vertices_id = gl.GenBuffer()
		self.indices_id = gl.GenBuffer()
		self.vao_id = gl.GenVertexArray()
	end


	function META:OnRemove()
		gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.vertices_id))
		gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.indices_id))
	end

	function META:_Draw(count)
		gl.BindVertexArray(self.vao_id)
		gl.BindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indices_id)
		gl.DrawElements(self.gl_mode, count or self.indices_length, "GL_UNSIGNED_INT", nil)
	end

	local function setup_vertex_array(self)
		if not self.setup_vao and self.Indices and self.Vertices then
			gl.BindBuffer("GL_ARRAY_BUFFER", self.vertices_id)
			gl.BindVertexArray(self.vao_id)
				for _, data in ipairs(self.vertex_array_info.attributes) do
					gl.EnableVertexAttribArray(data.location)
					gl.VertexAttribPointer(data.location, data.row_length, data.number_type, false, self.vertex_array_info.size, ffi.cast("void*", data.row_offset))
				end
			gl.BindVertexArray(0)
			self.setup_vao = true
		end
	end

	function META:_SetVertices(vertices)
		gl.BindBuffer("GL_ARRAY_BUFFER", self.vertices_id)
		gl.BufferData("GL_ARRAY_BUFFER", vertices:GetSize(), vertices:GetPointer(), "GL_STATIC_DRAW")
		gl.BindBuffer("GL_ARRAY_BUFFER", 0)

		setup_vertex_array(self)
	end

	function META:_SetIndices(indices)
		gl.BindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indices_id)
		gl.BufferData("GL_ELEMENT_ARRAY_BUFFER", indices:GetSize(), indices:GetPointer(), "GL_STATIC_DRAW")
		gl.BindBuffer("GL_ELEMENT_ARRAY_BUFFER", 0)

		setup_vertex_array(self)
	end
end