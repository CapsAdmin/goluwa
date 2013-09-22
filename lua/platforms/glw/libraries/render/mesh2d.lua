render.vbo_2d_program = nil

local vertex_shader_source = [[
	#version 330
	
	uniform mat4 camera_matrix;
	uniform mat4 model_matrix;
	uniform float add_color;
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
		
		gl_Position = camera_matrix * model_matrix * vec4(position, 0.0, 1.0);
	}
]]  

local fragment_shader_source = [[
	#version 330
	
	out vec4 frag_color;
	
	uniform float add_color;
	uniform vec4 global_color;
	uniform sampler2D texture;

	in vec2 _position;
	in vec2 _uv;
	in vec4 _color;

	vec4 texel = texture2D(texture, _uv);
	
	void main()
	{	
		if (add_color > 0.5)
		{
			frag_color = texel * _color;
			frag_color.xyz = frag_color.xyz + global_color.xyz;
			frag_color.w = frag_color.w * global_color.w;
		}
		else
		{	
			frag_color = texel * _color * global_color;
		}
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
			vertex_attributes.u = -vertex.uv.x
			vertex_attributes.v = vertex.uv.y
		end 
	end  

	local id = gl.GenBuffer()
	local size = ffi.sizeof(buffer[0]) * #data
	
	gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
	gl.BufferData(e.GL_ARRAY_BUFFER, size, buffer, e.GL_STATIC_DRAW)

	return {Type = "VertexBuffer", id = id, length = #data, size = size}
end

local float_size = ffi.sizeof("float")
local stride = ffi.sizeof("struct vertex_attributes_2d")

local pos_stride = ffi.cast("void*", 0)
local uv_stride = ffi.cast("void*", float_size * 2)
local color_stride = ffi.cast("void*", float_size * 4)

local proj_mat_location
local view_mat_location
local global_color_location
local add_color_location
local texture_location

function render.Draw2DVBO(vbo, additive)
	additive = additive or 0
	
	if not render.vbo_2d_program then			
		local prog, err = Program(assert(Shader(e.GL_VERTEX_SHADER, vertex_shader_source)), assert(Shader(e.GL_FRAGMENT_SHADER, fragment_shader_source)))
					
		if prog then
			gl.BindAttribLocation(prog, 0, "position")
			gl.BindAttribLocation(prog, 1, "uv")
			gl.BindAttribLocation(prog, 2, "color")
		
			render.vbo_2d_program = prog
			
			proj_mat_location = gl.GetUniformLocation(prog, "camera_matrix")
			view_mat_location = gl.GetUniformLocation(prog, "model_matrix")
			global_color_location = gl.GetUniformLocation(prog, "global_color")
			add_color_location = gl.GetUniformLocation(prog, "add_color")
			texture_location = gl.GetUniformLocation(prog, "texture")
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
			gl.Uniform1i(texture_location, 0)
		end
		
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
	
		if not render.use_own_matrices then
			gl.GetFloatv(e.GL_PROJECTION_MATRIX, render.camera_matrix)
		end
		
		gl.UniformMatrix4fv(proj_mat_location, 1, 0, render.camera_matrix)
		
		if not render.use_own_matrices then
			gl.GetFloatv(e.GL_MODELVIEW_MATRIX, render.model_matrix)
		end
		gl.UniformMatrix4fv(view_mat_location, 1, 0, render.model_matrix)
		
		gl.Uniform1f(add_color_location, additive)	
		gl.Uniform4f(global_color_location, render.r or 1, render.g or 1, render.b or 1, render.a or 1)	
		
		gl.EnableVertexAttribArray(0)
		gl.VertexAttribPointer(0, 2, e.GL_FLOAT, false, stride, pos_stride)

		gl.EnableVertexAttribArray(1)
		gl.VertexAttribPointer(1, 2, e.GL_FLOAT, false, stride, uv_stride)
		
		gl.EnableVertexAttribArray(2)
		gl.VertexAttribPointer(2, 4, e.GL_FLOAT, false, stride, color_stride)

		gl.DrawArrays(e.GL_TRIANGLES, 0, vbo.length)
		
	gl.UseProgram(0)
end	