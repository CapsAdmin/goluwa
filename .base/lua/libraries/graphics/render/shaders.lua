local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render

local status = ffi.new("GLint[1]")
local shader_strings = ffi.new("const char * [1]")
local log = ffi.new("char[1024]")

function render.CreateShader(type, source)
	check(type, "number")
	check(source, "string")
	
	if not render.CheckSupport("CreateShader") then return 0 end
	
	local shader = gl.CreateShader(type)
	
	shader_strings[0] = ffi.cast("const char *", source)
	gl.ShaderSource(shader, 1, shader_strings, nil)
	gl.CompileShader(shader)
	gl.GetShaderiv(shader, gl.e.GL_COMPILE_STATUS, status)		

	if status[0] == 0 then			
	
		gl.GetShaderInfoLog(shader, 1024, nil, log)
		gl.DeleteShader(shader)
		
		error(ffi.string(log), 2)
	end

	return shader
end

function render.CreateProgram(...)	

	if not render.CheckSupport("CreateProgram") then return 0 end

	local shaders = {...}
	local program = gl.CreateProgram()
	
	for _, shader_id in pairs(shaders) do
		gl.AttachShader(program, shader_id)
	end

	gl.LinkProgram(program)

	gl.GetProgramiv(program, gl.e.GL_LINK_STATUS, status)

	if status[0] == 0 then
	
		gl.GetProgramInfoLog(program, 1024, nil, log)
		gl.DeleteProgram(program)		
		
		error(ffi.string(log), 2)
	end
	
	for _, shader_id in pairs(shaders) do
		gl.DetachShader(program, shader_id)
		gl.DeleteShader(shader_id)
	end
	
	return program
end

local last

function render.UseProgram(id)
	if last ~= id then
		gl.UseProgram(id)
		last = id
		render.current_program = id
	end
end

local last

function render.BindArrayBuffer(id)
	if last ~= id then
		gl.BindBuffer(gl.e.GL_ARRAY_BUFFER, id)
		last = id
	end
end

local last

function render.BindVertexArray(id)
	if last ~= id then
		gl.BindVertexArray(id)
		last = id
		
		return true
	end
	
	return false
end