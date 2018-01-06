local render = ... or _G.render
local META = prototype.CreateTemplate("shader_storage_buffer")

local gl = system.GetFFIBuildLibrary("opengl", true)
local ffi = require("ffi")

local type_translate = {
	uniform = "GL_UNIFORM_BUFFER",
	shader_storage = "GL_SHADER_STORAGE_BUFFER",
}

function render.CreateShaderVariableBuffer(typ, size, persistent)
	size = size or 0

	typ = type_translate[typ]

	local self = META:CreateObject()

	local usage = gl.e.GL_DYNAMIC_STORAGE_BIT

	if persistent then
		usage = bit.bor(gl.e.GL_MAP_WRITE_BIT, gl.e.GL_MAP_PERSISTENT_BIT, gl.e.GL_MAP_COHERENT_BIT)
		self.real_size = size
		size = size * 3 -- tripple buffering
	end

	self.buffer = gl.CreateBuffer(typ)
	self.buffer:Storage(size, nil, usage)
	self.size = size
	self.type = typ

	if persistent then
		self.ptr = ffi.cast("uint8_t *", self.buffer:MapRange(0, size, usage))
		self.offset = 0
	end

	return self
end

function META:WaitForLockedRange()
	render.WaitForLockedRange(self.offset, self.real_size)
end

function META:LockRange()
	render.LockRange(self.offset, self.real_size)
	self.offset = (self.offset + self.real_size) % self.size
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
	if self.ptr then
		ffi.copy(self.ptr + self.offset + offset, data, size)
	else
		self.buffer:SetSubData(offset, size, data)
	end
end

function META:Bind(where, offset, size)
	if offset then
		gl.BindBufferRange(self.type, where, self.buffer.id)
	else
		gl.BindBufferBase(self.type, where, self.buffer.id)
	end
end

META:Register()
