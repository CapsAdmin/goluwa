local render, META = ...
render = render or _G.render
META = META or prototype.GetRegistered("vertex_buffer")

local gl = require("opengl")

do
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
end

do
	local translate = {
		["uint8_t"] = "GL_UNSIGNED_BYTE",
		["uint16_t"] = "GL_UNSIGNED_SHORT",
		["uint32_t"] = "GL_UNSIGNED_INT",
	}

	function META:SetIndicesType(typ)
		self.IndicesType = typ
		self.gl_indices_type = translate[typ] or translate["uint16_t"]
	end
end

do
	local translate = {
		dynamic = "GL_DYNAMIC_DRAW",
		stream = "GL_STREAM_DRAW",
		static = "GL_STATIC_DRAW",
	}

	function META:SetDrawHint(hint)
		self.DrawHint = hint
		self.gl_draw_hint = translate[hint] or translate.dynamic
	end
end


if not NVIDIA_WORKAROUND then
	function render._CreateVertexBuffer(self)
		self:SetMode(self:GetMode())
		self:SetIndicesType(self:GetIndicesType())
		self:SetDrawHint(self:GetDrawHint())
		self.vertex_buffer = gl.CreateBuffer("GL_ARRAY_BUFFER")
		self.element_buffer = gl.CreateBuffer("GL_ELEMENT_ARRAY_BUFFER")
		self.vertex_array = gl.CreateVertexArray()
	end

	function META:OnRemove()
		self.vertex_buffer:Delete()
		self.element_buffer:Delete()
	end

	if system.IsOpenGLExtensionSupported("GL_ARB_direct_state_access") then
		function META:_Draw(count)
			if render.last_vertex_array_id ~= self.vertex_array.id then
				gl.BindVertexArray(self.vertex_array.id)
				render.last_vertex_array_id = self.vertex_array.id
			end
			gl.DrawElements(self.gl_mode, count or self.indices_length, self.gl_indices_type, nil)
		end
	else
		function META:_Draw(count)
			if render.last_vertex_array_id ~= self.vertex_array.id then
				gl.BindVertexArray(self.vertex_array.id)
				self.element_buffer:Bind()
				render.last_vertex_array_id = self.vertex_array.id
			end
			gl.DrawElements(self.gl_mode, count or self.indices_length, self.gl_indices_type, nil)
		end
	end

	local function setup_vertex_array(self)
		if not self.setup_vao and self.Indices and self.Vertices then
			if not system.IsOpenGLExtensionSupported("GL_ARB_direct_state_access") then
				self.vertex_array:VertexBuffer(0, self.vertex_buffer.id, 0, self.mesh_layout.size)
			end
			for _, data in ipairs(self.mesh_layout.attributes) do
				self.vertex_array:EnableAttrib(data.location)
				self.vertex_array:AttribBinding(data.location, 0)
				self.vertex_array:AttribFormat(data.location, data.row_length, data.number_type, false, data.row_offset)
			end
			self.setup_vao = true
		end
	end

	function META:_SetVertices(vertices)
		self.vertex_buffer:Data(vertices:GetSize(), vertices:GetPointer(), self.gl_draw_hint)
		setup_vertex_array(self)
		if system.IsOpenGLExtensionSupported("GL_ARB_direct_state_access") then
			self.vertex_array:VertexBuffer(0, self.vertex_buffer.id, 0, self.mesh_layout.size)
		end
		render.last_vertex_array_id = nil
	end

	function META:_SetIndices(indices)
		self.element_buffer:Data(indices:GetSize(), indices:GetPointer(), self.gl_draw_hint)
		setup_vertex_array(self)
		if system.IsOpenGLExtensionSupported("GL_ARB_direct_state_access") then
			self.vertex_array:ElementBuffer(self.element_buffer.id)
		end
		render.last_vertex_array_id = nil
	end
else
	local ffi = require("ffi")

	function render._CreateVertexBuffer(self)
		self:SetMode(self:GetMode())
		self:SetIndicesType(self:GetIndicesType())
		self:SetDrawHint(self:GetDrawHint())
		self.vertices_id = gl.GenBuffer()
		self.indices_id = gl.GenBuffer()
		self.vao_id = gl.GenVertexArray()
	end


	function META:OnRemove()
		gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.vertices_id))
		gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.indices_id))
	end

	function META:_Draw(count)
		if render.last_vertex_array_id ~= self.vao_id then
			gl.BindVertexArray(self.vao_id)
			gl.BindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indices_id)
			render.last_vertex_array_id = self.vao_id
		end
		gl.DrawElements(self.gl_mode, count or self.indices_length, self.gl_indices_type, nil)
	end

	local function setup_vertex_array(self)
		if not self.setup_vao and self.Indices and self.Vertices then
			gl.BindBuffer("GL_ARRAY_BUFFER", self.vertices_id)
			gl.BindVertexArray(self.vao_id)
				for _, data in ipairs(self.mesh_layout.attributes) do
					gl.EnableVertexAttribArray(data.location)
					gl.VertexAttribPointer(data.location, data.row_length, data.number_type, false, self.mesh_layout.size, ffi.cast("void*", data.row_offset))
				end
			self.setup_vao = true
		end
	end

	function META:_SetVertices(vertices)
		gl.BindBuffer("GL_ARRAY_BUFFER", self.vertices_id)
		gl.BufferData("GL_ARRAY_BUFFER", vertices:GetSize(), vertices:GetPointer(), self.gl_draw_hint)

		setup_vertex_array(self)
		render.last_vertex_array_id = nil
	end

	function META:_SetIndices(indices)
		gl.BindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indices_id)
		gl.BufferData("GL_ELEMENT_ARRAY_BUFFER", indices:GetSize(), indices:GetPointer(), self.gl_draw_hint)

		setup_vertex_array(self)
		render.last_vertex_array_id = nil
	end
end