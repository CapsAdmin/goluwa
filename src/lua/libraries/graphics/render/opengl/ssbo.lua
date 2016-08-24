local render = ... or _G.render
local META = prototype.CreateTemplate("shader_storage_buffer")

local gl = require("libopengl")
local ffi = require("ffi")

local usage_translate = {
	stream_draw = "GL_STREAM_DRAW",
	stream_read = "GL_STREAM_READ",
	stream_copy = "GL_STREAM_COPY",
	static_draw = "GL_STATIC_DRAW",
	static_read = "GL_STATIC_READ",
	static_copy = "GL_STATIC_COPY",
	dynamic_draw = "GL_DYNAMIC_DRAW",
	dynamic_read = "GL_DYNAMIC_READ",
	dynamic_copy = "GL_DYNAMIC_COPY",
}

function render.CreateShaderStorageBuffer(usage, ptr, size)
	size = size or 0
	usage = usage or "dynamic_copy"

	usage = usage_translate[usage]

	local self = META:CreateObject()

	self.ssbo = gl.CreateBuffer("GL_SHADER_STORAGE_BUFFER")
	self.ssbo:Data(size, ptr, usage)
	self.size = size

	return self
end

function META:OnRemove()
	self.ssbo:Delete()
end

function META:UpdateData2(ptr)
	local p = self.ssbo:Map("GL_WRITE_ONLY")
	ffi.copy(p, ptr, self.size)
	self.ssbo:Unmap()
end

function META:UpdateData(data, size, offset)
	offset = offset or 0
	local p = self.ssbo:SetSubData(offset, size, data)
end

function META:Bind(where)
	gl.BindBufferBase("GL_SHADER_STORAGE_BUFFER", where, self.ssbo.id)
end

prototype.Register(META)