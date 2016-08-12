local render = ... or _G.render
local gl = require("libopengl")
local ffi = require("ffi")

local META = prototype.CreateTemplate("shader_program")

function render.CreateShaderProgram()
	if not system.IsOpenGLExtensionSupported("GL_ARB_shader_objects") then
		local msg = "shaders not supported!"
		llog(msg)
		return nil, msg
	end

	local self = META:CreateObject()
	self.shaders = {}
	return self
end

function META:CompileShader(type, source)
	local shader = gl.CreateShader2("GL_" .. type:upper() .. "_SHADER")

	local shader_strings = ffi.new("const char * [1]", ffi.cast("const char *", source))
	shader:Source(1, shader_strings, nil)
	shader:Compile()

	local status = ffi.new("GLint[1]")
	shader:Getiv("GL_COMPILE_STATUS", status)

	if status[0] == 0 then
		local log = ffi.new("char[1024]")
		shader:GetInfoLog(1024, nil, log)
		shader:Delete()

		error(ffi.string(log), 2)
	end

	table.insert(self.shaders, shader)
end

function META:Link()
	self.gl_program = gl.CreateProgram2()

	for _, shader in pairs(self.shaders) do
		self.gl_program:AttachShader(shader.id)
	end

	self.gl_program:Link()

	local status = ffi.new("GLint[1]")
	self.gl_program:Getiv("GL_LINK_STATUS", status)

	if status[0] == 0 then
		local log = ffi.new("char[1024]")
		self.gl_program:GetInfoLog(1024, nil, log)
		self.gl_program:Delete()

		error(ffi.string(log), 2)
	end

	for _, shader in pairs(self.shaders) do
		self.gl_program:DetachShader(shader.id)
		shader:Delete()
	end
end

function META:GetUniformBlockInfo(index)
	local count = ffi.new("unsigned[1]")
	gl.GetActiveUniformBlockiv(self.gl_program.id, index, "GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS", count)
	count = count[0]
	local indices = ffi.new("unsigned[?]", count)
	gl.GetActiveUniformBlockiv(self.gl_program.id, 0, "GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES", indices)
	local types = ffi.new("unsigned[?]", count)
	gl.GetActiveUniformsiv(self.gl_program.id, count, indices, "GL_UNIFORM_TYPE", types)
	local offsets = ffi.new("unsigned[?]", count)
	gl.GetActiveUniformsiv(self.gl_program.id, count, indices, "GL_UNIFORM_OFFSET", offsets)
	local sizes = ffi.new("unsigned[?]", count)
	gl.GetActiveUniformsiv(self.gl_program.id, count, indices, "GL_UNIFORM_SIZE", sizes)

	local out = {}

	for i = 0, count - 1 do
		local name = ffi.new("char[256]")
		local len = ffi.new("unsigned[1]")
		gl.GetActiveUniformName(self.gl_program.id, indices[i], 256, len, name)
		out[i + 1] = {
			name = ffi.string(name, len[0]),
			type = types[i],
			index = indices[i],
			offset = offsets[i],
			length = sizes[i]
		}
	end

	return out
end

function META:GetUniformBlocks()
	local out = {}

	local count = ffi.new("unsigned[1]")
	gl.GetProgramiv(self.gl_program.id, "GL_ACTIVE_UNIFORM_BLOCKS", count)
	count = count[0]
	for i = 0, count - 1 do
		local len = ffi.new("unsigned[1]")
		gl.GetActiveUniformBlockiv(self.gl_program.id, i, "GL_UNIFORM_BLOCK_NAME_LENGTH", len)
		len = len[0]
		local str = ffi.new("char[?]", len)
		gl.GetActiveUniformBlockName(self.gl_program.id, i, len, nil, str)
		str = ffi.string(str)
		out[str] = self:GetUniformBlockInfo(i)
	end
	return out
end

function META:UploadBoolean(key, val)
	self.gl_program:Uniform1i(key, val and 1 or 0)
end

function META:UploadNumber(key, val)
	self.gl_program:Uniform1f(key, val)
end

function META:UploadInteger(key, val)
	self.gl_program:Uniform1i(key, val)
end

function META:UploadVec2(key, val)
	self.gl_program:Uniform2f(key, val.x, val.y)
end

function META:UploadVec3(key, val)
	self.gl_program:Uniform3f(key, val.x, val.y, val.z)
end

if SRGB then
	local linear2gamma = math.linear2gamma
	function META:UploadColor(key, val)
		self.gl_program:Uniform4f(key, linear2gamma(val.r), linear2gamma(val.g), linear2gamma(val.b), val.a)
	end
else
	function META:UploadColor(key, val)
		self.gl_program:Uniform4f(key, val.r, val.g, val.b, val.a)
	end
end

function META:UploadTexture(key, val, a,b)
	self.gl_program:Uniform1i(key, a)
	val:Bind(b)
end

function META:UploadMatrix44(key, val)
	self.gl_program:UniformMatrix4fv(key, 1, 0, val:GetFloatPointer())
end

function META:Bind()
	self.gl_program:Use()
end

function META:GetUniformLocation(key)
	return self.gl_program:GetUniformLocation(key)
end

function META:BindAttribLocation(i, name)
	self.gl_program:BindAttribLocation(i, name)
end

function META:OnRemove()
	if self.gl_program then
		self.gl_program:Delete()
	end
end

META:Register()