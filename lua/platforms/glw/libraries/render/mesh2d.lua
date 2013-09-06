render.vbo_2d_program = nil

local vertex_shader_source = [[
	#version 330
	
	uniform mat4 proj_mat;
	uniform mat4 view_mat;
	uniform vec4 global_color;

	in vec2 position;
	in vec2 uv;
	in vec4 color;

	out vec2 _position;
	out vec2 _uv;
	out vec4 _color;

	void main()
	{
		_position = position;
		_uv = uv;
		_color = color;
		
		gl_Position = proj_mat * view_mat * vec4(position, 0.0, 1.0);
	}
]]  

local fragment_shader_source = [[
	#version 330
	
	out vec4 frag_color;
	
	uniform vec4 global_color;
	uniform sampler2D texture;
	
	in vec2 _position;
	in vec2 _uv;
	in vec4 _color;

	vec4 texel = texture2D(texture, _uv);
	
	void main()
	{
		frag_color = texel * _color * global_color;
		frag_color.w = global_color.w;
	}
]]

	
ffi.cdef[[
	struct vertex_attributes_2d
	{
		float x, y;
		float u, v;
		float r, g, b, a;
	};
]]	
	
--[[
	
	the normal and uv fields are optional

	-- data format should be the following
	{
		{pos = Vec3(), normal = (), uv = Vec2()},
		...
	}
]]
function render.Create2DVBO(data)
	local buffer = ffi.new("struct vertex_attributes_2d[?]", #data)

	for i = 1, #data do
		local vertex = data[i]
		local vertex_attributes = buffer[i - 1]

		if vertex.pos then
			vertex_attributes.x = vertex.pos.x
			vertex_attributes.y = vertex.pos.y
		end

		if vertex.color then
			vertex_attributes.r = vertex.color.r
			vertex_attributes.g = vertex.color.g
			vertex_attributes.b = vertex.color.b
			vertex_attributes.a = vertex.color.a
		end

		if vertex.uv then
			vertex_attributes.u = vertex.uv.x
			vertex_attributes.v = vertex.uv.y
		end 
	end  

	local id = ffi.new("int [1]") gl.GenBuffers(1, id) id = id[0]

	gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
	gl.BufferData(e.GL_ARRAY_BUFFER, ffi.sizeof(buffer[0]) * #data, buffer, e.GL_STATIC_DRAW)

	return {Type = "VertexBuffer", id = id, length = #data}
end

local float_size = ffi.sizeof("float")
local stride = ffi.sizeof("struct vertex_attributes_2d")

local pos_stride = ffi.cast("void*", 0)
local uv_stride = ffi.cast("void*", float_size * 2)
local color_stride = ffi.cast("void*", float_size * 4)

local proj_mat_location
local view_mat_location
local global_color_location

function render.Draw2DVBO(vbo)
	if not render.vbo_2d_program then			
		local prog, err = Program(assert(Shader(e.GL_VERTEX_SHADER, vertex_shader_source)), assert(Shader(e.GL_FRAGMENT_SHADER, fragment_shader_source)))
					
		if prog then
			gl.BindAttribLocation(prog, 0, "position")
			gl.BindAttribLocation(prog, 1, "uv")
			gl.BindAttribLocation(prog, 2, "color")
		
			render.vbo_2d_program = prog
			
			proj_mat_location = gl.GetUniformLocation(prog, "proj_mat")
			view_mat_location = gl.GetUniformLocation(prog, "view_mat")
			global_color_location = gl.GetUniformLocation(prog, "global_color")
		else
			logn(err)
			render.vbo_shader_error = err
			return
		end		
	end		
	
	gl.UseProgram(render.vbo_2d_program)

		if render.active_texture then
			gl.ActiveTexture(e.GL_TEXTURE0) 
			render.active_texture:Bind()
			gl.Uniform1i(gl.GetUniformLocation(render.vbo_2d_program, "texture"), 0)
		end

		gl.GetFloatv(e.GL_PROJECTION_MATRIX, render.projection_matrix)
		gl.UniformMatrix4fv(proj_mat_location, 1, 0, render.projection_matrix)
		
		gl.GetFloatv(e.GL_MODELVIEW_MATRIX, render.view_matrix)
		gl.UniformMatrix4fv(view_mat_location, 1, 0, render.view_matrix)
		
		gl.Uniform4f(global_color_location, render.r, render.g, render.b, render.a)			
		
		gl.EnableVertexAttribArray(0)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(0, 2, e.GL_FLOAT, false, stride, pos_stride)

		gl.EnableVertexAttribArray(1)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(1, 2, e.GL_FLOAT, false, stride, uv_stride)
		
		gl.EnableVertexAttribArray(2)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(2, 4, e.GL_FLOAT, false, stride, color_stride)

		gl.DrawArrays(e.GL_TRIANGLES, 0, vbo.length)
		
	gl.UseProgram(0)
end	