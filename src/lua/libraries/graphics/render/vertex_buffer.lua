local render = (...) or _G.render

local META = prototype.CreateTemplate("vertex_buffer")

prototype.StartStorable()
META:GetSet("UpdateIndices", true)
META:GetSet("Mode", "triangles")
META:GetSet("Shader")
META:GetSet("Vertices")
META:GetSet("Indices")
prototype.EndStorable()

function render.CreateVertexBuffer(shader, vertices, indices, is_valid_table)
	local self = META:CreateObject()
	self:SetMode(self:GetMode())
	render._CreateVertexBuffer(self)
	self.vertex_array_info = shader:GetVertexAttributes()

	if vertices then
		self:UpdateBuffer(shader:CreateBuffersFromTable(vertices, indices, is_valid_table))
	end

	return self
end

if SSBO then
	function META:Draw(count)

		if render.current_shader_override then
			render.current_shader_override:Bind()
		elseif self.Shader then
			self.Shader:Bind()
		end

		render.update_globals2()

		self:_Draw(count)
	end
else
	function META:Draw(count)

		if render.current_shader_override then
			render.current_shader_override:Bind()
		elseif self.Shader then
			self.Shader:Bind()
		end

		self:_Draw(count)
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

function META:SetVertices(vertices)
	self.Vertices = vertices
	self.vertices_length = vertices:GetLength()
	self:_SetVertices(vertices)
end

function META:SetIndices(indices)
	self.Indices = indices
	self.indices_length = indices:GetLength() -- needed for drawing
	self:_SetIndices(indices)
end

function META:UnreferenceMesh()
	self.Vertices = nil
	self.Indices = nil
	collectgarbage("step")
end

include("opengl/vertex_buffer.lua", render, META)

prototype.Register(META)