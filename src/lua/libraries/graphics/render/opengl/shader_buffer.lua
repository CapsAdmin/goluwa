local render = ... or _G.render
local META = prototype.CreateTemplate("shader_storage_buffer")

local gl = require("opengl")
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

local type_translate = {
	uniform = "GL_UNIFORM_BUFFER",
	shader_storage = "GL_SHADER_STORAGE_BUFFER",
}

function render.CreateShaderVariableBuffer(typ, usage, ptr, size)
	size = size or 0
	usage = usage or "dynamic_copy"

	usage = usage_translate[usage]
	typ = type_translate[typ]

	local self = META:CreateObject()

	self.buffer = gl.CreateBuffer(typ)
	if type(ptr) == "number" then
		size = ptr
		ptr = ffi.new("uint8_t[?]", size)
	end
	self.buffer:Data(size, ptr, usage)
	self.size = size
	self.type = typ

	return self
end

function META:OnRemove()
	self.buffer:Delete()
end

function META:UpdateData2(ptr)
	local p = self.buffer:Map("GL_WRITE_ONLY")
	ffi.copy(p, ptr, self.size)
	self.buffer:Unmap()
end

function META:UpdateData(data, size, offset)
	offset = offset or 0
	self.buffer:SetSubData(offset, size, data)
end

function META:Bind(where)
	gl.BindBufferBase(self.type, where, self.buffer.id)
end

prototype.Register(META)