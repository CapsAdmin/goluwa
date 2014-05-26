local gl = require("lj-opengl")
local render = (...) or _G.render

local META = utilities.CreateBaseMeta("vertex_buffer")

function render.CreateVertexBuffer(buffer, vertex_attributes)
	check(buffer, "cdata")
	check(vertex_attributes, "table")
	
	local size = ffi.sizeof(buffer)
	
	local self = META:New()
	self.size = size
	self.buffer = buffer
	self.id = gl.GenBuffer()
	self.vao_id = gl.GenVertexArray()
	self.vertex_attributes = vertex_attributes
	
	self:UpdateVertexBuffer()

	return self
end 

function META:OnRemove()
	gl.DeleteBuffers(1, ffi.new("GLuint[1]", self.id))
end

function META:Draw()
	render.BindVertexArray(self.vao_id)
	render.BindArrayBuffer(self.id)		
	gl.DrawArrays(gl.e.GL_TRIANGLES, 0, self.size)
end

function META:UpdateVertexBuffer(buffer)
	if buffer then
		self.buffer = buffer
		self.size = ffi.sizeof(buffer)
	end
	
	self:UpdateBuffer()
end

function META:UpdateBuffer()
	render.BindArrayBuffer(self.id)
		render.BindVertexArray(self.vao_id)
			for location, data in pairs(self.vertex_attributes) do
				gl.EnableVertexAttribArray(location)
				gl.VertexAttribPointer(location, data.arg_count, data.enum, false, data.stride, data.type_stride)
			end		
		render.BindVertexArray(0)
		gl.BufferData(gl.e.GL_ARRAY_BUFFER, self.size, self.buffer, gl.e.GL_DYNAMIC_DRAW)
	render.BindArrayBuffer(0)
end