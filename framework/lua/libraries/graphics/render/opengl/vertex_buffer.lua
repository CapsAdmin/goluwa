local render = ... or _G.render
local META = prototype.GetRegistered("vertex_buffer")

local gl = system.GetFFIBuildLibrary("opengl", true)

local buffers_supported = gl.GenBuffers

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
		dynamic = "GL_DYNAMIC_DRAW",
		stream = "GL_STREAM_DRAW",
		static = "GL_STATIC_DRAW",
	}

	function META:SetDrawHint(hint)
		self.DrawHint = hint
		self.gl_draw_hint = translate[hint] or translate.dynamic
	end
end

local mapping_flags = bit.bor(gl.e.GL_MAP_WRITE_BIT, gl.e.GL_MAP_READ_BIT, gl.e.GL_MAP_PERSISTENT_BIT, gl.e.GL_MAP_COHERENT_BIT)
local storage_flags = bit.bor(gl.e.GL_DYNAMIC_STORAGE_BIT, mapping_flags)

function render._CreateVertexBuffer(self)
	self:SetMode(self:GetMode())
	self:SetDrawHint(self:GetDrawHint())

	if buffers_supported then
		self.vertex_buffer = gl.CreateBuffer("GL_ARRAY_BUFFER")
		self.vertex_array = gl.CreateVertexArray()
	end
end

function META:OnRemove()
	self.vertex_buffer:Delete()
	self.vertex_array:Delete()
end

if buffers_supported then
	if render.IsExtensionSupported("GL_ARB_direct_state_access") then
		function META:Draw(index_buffer, count)
			if render.last_vertex_array_id ~= self.vertex_array.id then
				gl.BindVertexArray(self.vertex_array.id)
				render.last_vertex_array_id = self.vertex_array.id
			end

			if self.last_element_buffer ~= index_buffer.element_buffer.id then
				self.vertex_array:ElementBuffer(index_buffer.element_buffer.id)
				self.last_element_buffer = index_buffer.element_buffer.id
			end

			gl.DrawElements(self.gl_mode, count or index_buffer.Indices:GetLength(), index_buffer.gl_indices_type, nil)
		end
	else
		function META:Draw(index_buffer, count)
			if render.last_vertex_array_id ~= self.vertex_array.id then
				gl.BindVertexArray(self.vertex_array.id)
				render.last_vertex_array_id = self.vertex_array.id
			end

			index_buffer.element_buffer:Bind()

			gl.DrawElements(self.gl_mode, count or index_buffer.Indices:GetLength(), index_buffer.gl_indices_type, index_buffer.Indices:GetPointer())
		end
	end

	local function setup_vertex_array(self)
		if not self.setup_vao and self.Vertices then
			for _, data in ipairs(self.mesh_layout.attributes) do
				self.vertex_array:AttribFormat(data.location, data.row_length, data.number_type, false, data.row_offset)
				self.vertex_array:AttribBinding(data.location, 0)
				self.vertex_array:EnableAttrib(data.location)
			end
			self.vertex_array:VertexBuffer(0, self.vertex_buffer.id, 0, self.mesh_layout.size)
			render.last_vertex_array_id = nil
			self.setup_vao = true
		end
	end

	function META:_SetVertices(vertices)
		if self.vertex_mapped then return end
		setup_vertex_array(self)
		self.vertex_buffer:Data(vertices:GetSize(), vertices:GetPointer(), self.gl_draw_hint)
	end

	local ffi = require("ffi")

	function META:MapVertexArray(count)
		self.vertex_mapped = true

		self.Vertices = self.Vertices or Array(self.mesh_layout.ctype, count)
		self.vertex_buffer:Storage(self.Vertices:GetSize(), nil, storage_flags)
		local ptr = self.vertex_buffer:MapRange(0, self.Vertices:GetSize(), mapping_flags)
		ptr = ffi.cast(ffi.typeof("$*", self.mesh_layout.ctype), ptr)
		self.Vertices.Pointer = ptr

		return self.Vertices
	end
else
	-- this will probably only happen when running goluwa in virtual box with windows as a host
	-- it's using the windows opengl api (seems to be 1.1)

	function META:_SetVertices(vertices)

	end

	function META:_SetIndices(indices)

	end

	function META:Draw(index_buffer, count)
		local vertices = self:GetVertices()

		gl.Enable("GL_TEXTURE_2D")
		render2d.GetTexture():Bind(0)

		for _, data in ipairs(self.mesh_layout.attributes) do
			if data.name == "pos" then
				gl.EnableClientState("GL_VERTEX_ARRAY")
				gl.VertexPointer(data.row_length, data.number_type, self.mesh_layout.size, vertices:GetPointer() + data.row_offset)
			elseif data.name == "color" then
				gl.EnableClientState("GL_COLOR_ARRAY")
				gl.ColorPointer(data.row_length, data.number_type, self.mesh_layout.size, vertices:GetPointer() + data.row_offset)
			elseif data.name == "uv" then
				gl.EnableClientState("GL_TEXTURE_COORD_ARRAY")
				gl.TexCoordPointer(data.row_length, data.number_type, self.mesh_layout.size, vertices:GetPointer() + data.row_offset)
			end
		end

		gl.MatrixMode("GL_PROJECTION")
		gl.LoadMatrixf(render2d.camera:GetMatrices().projection:GetFloatPointer())
		gl.MatrixMode("GL_MODELVIEW")
		gl.LoadMatrixf((render2d.camera:GetMatrices().view * render2d.camera:GetMatrices().world):GetFloatPointer())

		gl.DrawElements(self.gl_mode, count or index_buffer.Indices:GetLength(), index_buffer.gl_indices_type, index_buffer.Indices:GetPointer())
	end
end
prototype.Register(META)
