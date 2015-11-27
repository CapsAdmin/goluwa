local ffi = require("ffi")
local gl = require("graphics.ffi.opengl")
local render = (...) or _G.render

local META = prototype.CreateTemplate("vertex_buffer")

prototype.StartStorable()
prototype.GetSet(META, "UpdateIndices", true)
prototype.GetSet(META, "Mode", "triangles")
prototype.GetSet(META, "Shader")
prototype.GetSet(META, "Vertices")
prototype.GetSet(META, "Indices")
prototype.EndStorable()

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


if NVIDIA_WORKAROUND then
	function render.CreateVertexBuffer(shader, vertices, indices, is_valid_table)
		checkx(shader, "shader")
		--check(vertices, "cdata", "table")
		--check(indices, "cdata", "table", "number", "nil")

		local self = prototype.CreateObject(META)
		self:SetMode(self:GetMode())
		self.vertices_id = gl.GenBuffer()
		self.indices_id = gl.GenBuffer()
		self.vao_id = gl.GenVertexArray()
		self.vertex_attributes = shader:GetVertexAttributes()

		if vertices then
			self:UpdateBuffer(shader:CreateBuffersFromTable(vertices, indices, is_valid_table))
		end

		return self
	end

	function META:OnRemove()
		gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.vertices_id))
		gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.indices_id))
	end

	function META:Draw(count)

		if render.current_shader_override then
			render.current_shader_override:Bind()
		elseif self.Shader then
			self.Shader:Bind()
		end

		gl.BindVertexArray(self.vao_id)
		gl.BindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indices_id)
		gl.DrawElements(self.gl_mode, count or self.indices_length, "GL_UNSIGNED_INT", nil)

		render.vertex_draw_count = render.vertex_draw_count + self.vertices_length
		render.draw_call_count = render.draw_call_count + 1
	end

	local function setup_vertex_array(self)
		if not self.setup_vao and self.Indices and self.Vertices then
			gl.BindBuffer("GL_ARRAY_BUFFER", self.vertices_id)
			gl.BindVertexArray(self.vao_id)
				for _, data in ipairs(self.vertex_attributes.attributes) do
					gl.EnableVertexAttribArray(data.location)
					gl.VertexAttribPointer(data.location, data.row_length, data.number_type, false, self.vertex_attributes.size, ffi.cast("void*", data.row_offset))
				end
			gl.BindVertexArray(0)
			self.setup_vao = true
		end
	end

	function META:SetVertices(vertices)
		self.Vertices = vertices

		self.vertices_length = vertices:GetLength()

		gl.BindBuffer("GL_ARRAY_BUFFER", self.vertices_id)
		gl.BufferData("GL_ARRAY_BUFFER", vertices:GetSize(), vertices:GetPointer(), "GL_STATIC_DRAW")
		gl.BindBuffer("GL_ARRAY_BUFFER", 0)

		setup_vertex_array(self)
	end

	function META:SetIndices(indices)
		self.Indices = indices

		self.indices_length = indices:GetLength() -- needed for drawing

		gl.BindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indices_id)
		gl.BufferData("GL_ELEMENT_ARRAY_BUFFER", indices:GetSize(), indices:GetPointer(), "GL_STATIC_DRAW")
		gl.BindBuffer("GL_ELEMENT_ARRAY_BUFFER", 0)

		setup_vertex_array(self)
	end
else
	function render.CreateVertexBuffer(shader, vertices, indices, is_valid_table)
		checkx(shader, "shader")
		--check(vertices, "cdata", "table")
		--check(indices, "cdata", "table", "number", "nil")
		local self = prototype.CreateObject(META)
		self:SetMode(self:GetMode())
		self.vertex_buffer = gl.CreateBuffer("GL_ARRAY_BUFFER")
		self.element_buffer = gl.CreateBuffer("GL_ELEMENT_ARRAY_BUFFER")
		self.vertex_array = gl.CreateVertexArray()
		self.vertex_array_info = shader:GetVertexAttributes()

		if vertices then
			self:UpdateBuffer(shader:CreateBuffersFromTable(vertices, indices, is_valid_table))
		end

		return self
	end

	function META:OnRemove()
		self.vertex_buffer:Unmap()
		self.vertex_buffer:Delete()

		self.element_buffer:Unmap()
		self.element_buffer:Delete()
	end

	function META:Draw(count)

		if render.current_shader_override then
			render.current_shader_override:Bind()
		elseif self.Shader then
			self.Shader:Bind()
		end

		gl.BindVertexArray(self.vertex_array.id)
		if not system.IsOpenGLExtensionSupported("GL_ARB_direct_state_access") then
			self.element_buffer:Bind()
		end
		gl.DrawElements(self.gl_mode, count or self.indices_length, "GL_UNSIGNED_INT", nil)

		--render.vertex_draw_count = render.vertex_draw_count + self.vertices_length
		--render.draw_call_count = render.draw_call_count + 1
	end

	local function setup_vertex_array(self)
		if not self.setup_vao and self.Indices and self.Vertices then
			for _, data in ipairs(self.vertex_array_info.attributes) do
				if not system.IsOpenGLExtensionSupported("GL_ARB_direct_state_access") then
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

	function META:SetVertices(vertices)
		self.Vertices = vertices

		self.vertices_length = vertices:GetLength()

		self.vertex_buffer:Data(vertices:GetSize(), vertices:GetPointer(), "GL_DYNAMIC_DRAW")

		setup_vertex_array(self)

		if system.IsOpenGLExtensionSupported("GL_ARB_direct_state_access") then
			self.vertex_array:VertexBuffer(0, self.vertex_buffer.id, 0, self.vertex_array_info.size)
		end
	end

	function META:SetIndices(indices)
		self.Indices = indices

		self.indices_length = indices:GetLength() -- needed for drawing

		self.element_buffer:Data(indices:GetSize(), indices:GetPointer(), "GL_DYNAMIC_DRAW")

		setup_vertex_array(self)

		if system.IsOpenGLExtensionSupported("GL_ARB_direct_state_access") then
			self.vertex_array:ElementBuffer(self.element_buffer.id)
		end
	end
end

function META:UpdateBuffer(vertices, indices)
	vertices = vertices or self.Vertices
	indices = indices or self.Indices

	if vertices then
		self:SetVertices(vertices)
	end

	if indices then
		self:SetIndices(indices)
	end
end

function META:UnreferenceMesh()
	self.Vertices = nil
	self.Indices = nil
	collectgarbage("step")
end

prototype.Register(META)