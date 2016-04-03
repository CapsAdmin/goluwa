local render = ... or _G.render
local gl = require("libopengl")
local ffi = require("ffi")

local META = prototype.CreateTemplate("shader_program")

function render.CreateShaderProgram()
	local self = prototype.CreateObject(META)
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

		self.gl_program:GetInfoLog(1024, nil, log)
		self.gl_program:Delete()

		error(ffi.string(log), 2)
	end

	for _, shader in pairs(self.shaders) do
		self.gl_program:DetachShader(shader.id)
		shader:Delete()
	end
end

function META:UploadBoolean(key, val)
	self.gl_program:Uniform1i(loc, val and 1 or 0)
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
	function META:UploadColor(key, val)
		self.gl_program:Uniform4f(key, math.linear2gamma(val.r), math.linear2gamma(val.g), math.linear2gamma(val.b), val.a)
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
	self.gl_program:UniformMatrix4fv(key, 1, 0, ffi.cast('const float *', val))
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
	self.gl_program:Delete()
end

META:Register()