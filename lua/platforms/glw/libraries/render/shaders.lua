local status = ffi.new("GLint[1]")
local shader_strings = ffi.new("const char * [1]")
local log = ffi.new("char[1024]")

function render.CreateShader(type, source)
	check(type, "number")
	check(source, "string")
	
	local shader = gl.CreateShader(type)
	
	shader_strings[0] = ffi.cast("const char *", source)
	gl.ShaderSource(shader, 1, shader_strings, nil)
	gl.CompileShader(shader)
	gl.GetShaderiv(shader, e.GL_COMPILE_STATUS, status)		

	if status[0] == 0 then			
	
		gl.GetShaderInfoLog(shader, 1024, nil, log)
		gl.DeleteShader(shader)
		
		return false, ffi.string(log)
	end

	return shader
end

_G.Shader = render.CreateShader

function render.CreateProgram(...)				
	local program = gl.CreateProgram()
		for _, shader_id in pairs({...}) do
			gl.AttachShader(program, shader_id)
		end
	gl.LinkProgram(program)

	gl.GetProgramiv(program, e.GL_LINK_STATUS, status)

	if status[0] == 0 then
	
		gl.GetProgramInfoLog(program, 1024, nil, log)
		gl.DeleteProgram(program)		
		
		return false, ffi.string(log)
	end
	
	return program
end

_G.Program = render.CreateProgram

function render.SetProgram(id)
	gl.UseProgram(id or 0)
	render.current_program = id
end