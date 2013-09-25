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
		
		error(ffi.string(log), 2)
	end

	return shader
end

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
		
		error(ffi.string(log), 2)
	end
	
	return program
end

local last

function render.UseProgram(id)
	if last ~= id then
		gl.UseProgram(id)
		last = id
	end
end

local last

function render.BindArrayBuffer(id)
	if last ~= id then
		gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
		last = id
	end
end

local last
local last2 

function render.BindTexture(tex, location)
	if last ~= location or last2 ~= tex then
		gl.ActiveTexture(e.GL_TEXTURE0 + tex.Channel) 
		gl.BindTexture(tex.format.type, tex.id) 
		gl.Uniform1i(location, tex.Channel)
		last = location
		last2 = tex
	end
end