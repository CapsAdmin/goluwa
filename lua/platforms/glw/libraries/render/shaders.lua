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
	local shaders = {...}
	local program = gl.CreateProgram()
	
	for _, shader_id in pairs(shaders) do
		gl.AttachShader(program, shader_id)
	end

	gl.LinkProgram(program)

	gl.GetProgramiv(program, e.GL_LINK_STATUS, status)

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
		gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
		last = id
	end
end

local last_prog, last_loc, last_x, last_y, last_z, last_w

local function SETUP_CACHED_UNIFORM(name, func, arg_count)	
	local lua = [[
	local func = ...
	local last_program, __LAST_LOCALS__

	function render.__NAME__(__ARGUMENTS__)

		if 
			render.current_program == last_program and 
			__COMPARE__ 
		then return end
		
		func(__ARGUMENTS__)
		
		last_program = render.current_program
		__ASSIGN__
	end
	]]
		
	local last_locals = ""
	local arguments = ""
	local compare = ""
	local assign = ""
		
	for i = 1, arg_count do
		last_locals =  last_locals .. "last_" .. i
		arguments = arguments .. "_" .. i
		compare = compare .. "_" .. i .. " == last_" .. i
		assign = assign .. "last_" .. i .. " = _" .. i .. "\n"
		
		if i ~= arg_count then
			last_locals = last_locals .. ", "
			arguments = arguments .. ", "
			compare = compare .. " and \n"
		end
	end
	
	lua = lua:gsub("__LAST_LOCALS__", last_locals)
	lua = lua:gsub("__ARGUMENTS__", arguments)
	lua = lua:gsub("__COMPARE__", compare)
	lua = lua:gsub("__NAME__", name)
	lua = lua:gsub("__ASSIGN__", assign)
	
	assert(loadstring(lua))(func)
end

event.AddListener("RenderContextInitialized", "uniform_wrappers", function()
	SETUP_CACHED_UNIFORM("Uniform4f", gl.Uniform4f, 5)
	SETUP_CACHED_UNIFORM("Uniform3f", gl.Uniform3f, 4)
	SETUP_CACHED_UNIFORM("Uniform2f", gl.Uniform2f, 3)
	SETUP_CACHED_UNIFORM("Uniform1f", gl.Uniform1f, 2)
	SETUP_CACHED_UNIFORM("UniformMatrix4fv", gl.UniformMatrix4fv, 4)
end)

--render.Uniform4f = gl.Uniform4f
