local render = _G.render or {}

function render.Initialize(w, h)		
	render.cam_pos = Vec3(0,0,0)
	render.farz = 32000
	render.nearz = 0.1
	render.fov = 75  
	
	render.projection_matrix = ffi.new("float[16]")
	render.view_matrix = ffi.new("float[16]")

	check(w, "number")
	check(h, "number")
	
	render.w = w
	render.h = h
	
	gl.Enable(e.GL_BLEND)
	gl.Enable(e.GL_CULL_FACE)

	gl.CullFace(e.GL_FRONT) 

	gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)
	gl.PolygonMode(e.GL_FRONT_AND_BACK, e.GL_FILL)
end

event.AddListener("OnWindowResize", "render", function()
	render.Initialize(w, h)
end)

function render.Clear(flag, ...)
	flag = flag or e.GL_COLOR_BUFFER_BIT
	gl.Clear(bit.bor(flag, ...))
end

function render.SetViewport(x, y, w, h)
	x = x or 0
	y = y or 0
	w = w or render.w
	h = h or render.h
	
	gl.Viewport(x, y, w, h)
end
 
render.current_window = render.current_window or NULL

function render.Start(window)
	glfw.MakeContextCurrent(window.__ptr)
	render.current_window = window
	render.SetViewport(0, 0, window:GetSize():Unpack())
end

function render.End()
	if render.current_window:IsValid() then
		glfw.SwapBuffers(render.current_window.__ptr)
	end
	gl.Flush()
end

function render.SetPerspective(fov, nearz, farz, ratio)
	fov = fov or render.fov
	nearz = nearz or render.nearz
	farz = farz or render.farz
	ratio = ratio or render.w/render.h
	
	glu.Perspective(fov, ratio, nearz, farz)
end

do -- textures
	_E.TEX_CHANNEL_AUTO = 0
	_E.TEX_CHANNEL_L = 1
	_E.TEX_CHANNEL_LA = 2
	_E.TEX_CHANNEL_RGB = 3
	_E.TEX_CHANNEL_RGBA = 4

	_E.TEX_FLAG_POWER_OF_TWO = 1
	_E.TEX_FLAG_MIPMAPS = 2
	_E.TEX_FLAG_TEXTURE_REPEATS = 4
	_E.TEX_FLAG_MULTIPLY_ALPHA = 8
	_E.TEX_FLAG_INVERT_Y = 16
	_E.TEX_FLAG_COMPRESS_TO_DXT = 32
	_E.TEX_FLAG_DDS_LOAD_DIRECT = 64
	_E.TEX_FLAG_NTSC_SAFE_RGB = 128
	_E.TEX_FLAG_COCG_Y = 256
	_E.TEX_FLAG_TEXTURE_RECTANGLE = 512

	function render.CreateTexture(path, channel_flags, texture_flags, prev_tex_id)
		return freeimage.LoadImage(vfs.Read(path, "rb"), texture_flags, channel_flags, prev_tex_id)
	end
	
	function render.SetTexture(id)
		gl.BindTexture(e.GL_TEXTURE_2D, id)
	end
	
	function render.SetTextureFiltering(blah)
		gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_MIN_FILTER, e.GL_NEAREST)
		gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_MAG_FILTER, e.GL_NEAREST)
	end
end

do -- camera helpers
	function render.Start2D(x, y, w, h)
		x = x or 0
		y = y or 0
		w = w or render.w
		h = h or render.h
	
		render.SetMatrixMode(e.GL_PROJECTION)	
		
		gl.Ortho(x,w, y,h, -1,1)
		gl.Disable(e.GL_DEPTH_TEST)
		
		render.SetMatrixMode(e.GL_MODELVIEW)
		
		gl.Translatef(0.5, 0.5, 0)
	end
	
	function render.Start3D(pos, ang, fov, nearz, farz, ratio)
		render.SetMatrixMode(e.GL_PROJECTION)
		
		render.SetPerspective()
			
		gl.Rotatef(ang.p, 1, 0, 0)
		gl.Rotatef(ang.y, 0, 1, 0)
		gl.Rotatef(ang.r, 0, 0, 1)
		gl.Translatef(pos.x, pos.y, pos.z)	

		gl.Enable(e.GL_DEPTH_TEST)		
		
		render.cam_pos = pos
		
		render.SetMatrixMode(e.GL_MODELVIEW)	
	end
end

do -- render targets

	-- http://www.songho.ca/opengl/gl_fbo.html
	function render.CreateRenderTarget(w, h, type)
		w = w or render.w
		h = h or render.h
		type = type or e.GL_DEPTH24_STENCIL8

		-- create a texture object
		local tex_id = ffi.new("GLuint[1]") gl.GenTextures(1, tex_id) tex_id = tex_id[0]
		
		gl.BindTexture(e.GL_TEXTURE_2D, tex_id)
		gl.TexParameterf(e.GL_TEXTURE_2D, e.GL_TEXTURE_MAG_FILTER, e.GL_NEAREST)
		gl.TexParameterf(e.GL_TEXTURE_2D, e.GL_TEXTURE_MIN_FILTER, e.GL_NEAREST)
		gl.TexParameterf(e.GL_TEXTURE_2D, e.GL_TEXTURE_WRAP_S, e.GL_CLAMP_TO_EDGE)
		gl.TexParameterf(e.GL_TEXTURE_2D, e.GL_TEXTURE_WRAP_T, e.GL_CLAMP_TO_EDGE)
		--gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_GENERATE_MIPMAP, e.GL_TRUE) -- automatic mipmap
		gl.TexImage2D(e.GL_TEXTURE_2D, 0, e.GL_RGBA8, w, h, 0,	e.GL_RGBA, e.GL_UNSIGNED_BYTE, nil)
		--gl.BindTexture(e.GL_TEXTURE_2D, 0)

		-- create a renderbuffer object to store depth info
		local rbo_id = ffi.new("GLuint[1]") gl.GenRenderbuffers(1, rbo_id) rbo_id = rbo_id[0]
		gl.BindRenderbuffer(e.GL_RENDERBUFFER, rbo_id)
		gl.RenderbufferStorage(e.GL_RENDERBUFFER, type, w, h)
		gl.BindRenderbuffer(e.GL_RENDERBUFFER, 0)

		-- create a framebuffer object
		local fbo_id = ffi.new("GLuint[1]") gl.GenFramebuffers(1, fbo_id) fbo_id = fbo_id[0]
		gl.BindFramebuffer(e.GL_FRAMEBUFFER, fbo_id)

		-- attach the texture to FBO color attachment point
		gl.FramebufferTexture2D(e.GL_FRAMEBUFFER, e.GL_COLOR_ATTACHMENT0, e.GL_TEXTURE_2D, tex_id, 0)

		-- attach the renderbuffer to depth attachment point
		gl.FramebufferRenderbuffer(e.GL_FRAMEBUFFER, e.GL_DEPTH_ATTACHMENT, e.GL_RENDERBUFFER, rbo_id)

		-- check FBO status
		if(gl.CheckFramebufferStatus(e.GL_FRAMEBUFFER) ~= e.GL_FRAMEBUFFER_COMPLETE) then
			error"!!"
		end

		-- switch back to window-system-provided framebuffer
		gl.BindFramebuffer(e.GL_FRAMEBUFFER, 0)
		
		return fbo_id, tex_id, rbo_id
	end
	
	function render.SetRenderTarget(id)
		gl.BindFramebuffer(e.GL_FRAMEBUFFER, id or 0)
	end
end

-- matrix stuff
do
	local mode = -1

	function render.SetMatrixMode(type)
		gl.MatrixMode(type)
		gl.LoadIdentity()
		
		mode = type
	end

	function render.PushMatrix(p, a, s)
		gl.PushMatrix()
	
		-- temp / helper
		if a then
			gl.Rotatef(a.p, 1, 0, 0)
			gl.Rotatef(a.y, 0, 1, 0)
			gl.Rotatef(a.r, 0, 0, 1)
			gl.Translatef(p.x, p.y, p.z)
			if s then gl.Scalef(s.x, s.y, s.z) end
		else
			if typex(p) == "matrix44" then
				gl.LoadMatrix(ffi.cast("float *", p))
			end
		end
	end
	
	function render.PopMatrix()
		gl.PopMatrix()
	end
end

do -- shaders
	local status = ffi.new("GLint[1]")
	local shader_strings = ffi.new("const char * [1]")
	local log = ffi.new("char[1024]")
	
	local function create_shader(type, source)		
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

	function render.CreateShader(vert_source, frag_source, geom_source)
		check(vert_source, "string")
		check(frag_source, "string")
		check(geom_source, "nil", "string")
		
		local vertex, vertex_err = create_shader(e.GL_VERTEX_SHADER, vert_source)	
		if vertex_err then return false, vertex_err end
		
		local fragment, frag_err = create_shader(e.GL_FRAGMENT_SHADER, frag_source)
		if frag_err then return false, frag_err end
		
		
		local geom
		
		if geom_source then
			geom, geom_err = create_shader(e.GL_GEOMETRY_SHADER, geom_source)
			if geom_err then return false, geom_err end
		end
				
		local program = gl.CreateProgram()
			gl.AttachShader(program, vertex)
			gl.AttachShader(program, fragment)
			if geom then
				gl.AttachShader(program, geom)
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
	
	function render.SetShader(id)
		gl.UseProgram(id or 0)
	end
end

do -- vbo 3d
	render.vbo_3d_program = nil
	
	local vertex_shader_source = vfs.Read("shaders/phong/vertex.c", "rb")  
	local fragment_shader_source = vfs.Read("shaders/phong/fragment.c", "rb")

	ffi.cdef[[
		struct vertex_attributes_3d
		{
			float pos_x, pos_y, pos_z;
			float norm_x, norm_y, norm_z;
			float u, v;
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
	function render.Create3DVBO(data)
		local buffer = ffi.new("struct vertex_attributes_3d[?]", #data)

		for i = 1, #data do
			local vertex = data[i]
			local vertex_attributes = buffer[i - 1]

			if vertex.pos then
				vertex_attributes.pos_x = vertex.pos.x
				vertex_attributes.pos_y = vertex.pos.y
				vertex_attributes.pos_z = vertex.pos.z
			end

			if vertex.normal then
				vertex_attributes.norm_x = vertex.normal.x
				vertex_attributes.norm_y = vertex.normal.y
				vertex_attributes.norm_z = vertex.normal.z
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
	
	local stride = ffi.sizeof("struct vertex_attributes_3d")
	
	local pos_stride = ffi.cast("void*", 0)
	local normal_stride = ffi.cast("void*", 12)
	local uv_stride = ffi.cast("void*", 24)
	
	render.vbo_shader_error = nil
	render.frame = 0
	
	function render.Draw3DVBO(vbo)
		if render.vbo_shader_error then return end
	
		if not render.vbo_3d_program then
			local prog, err = render.CreateShader(vertex_shader_source, fragment_shader_source)
						
			if prog then
				gl.BindAttribLocation(prog, 0, "position")
				gl.BindAttribLocation(prog, 1, "normal")
				gl.BindAttribLocation(prog, 2, "uv")
			
				render.vbo_3d_program = prog
			else
				logn(err)
				render.vbo_shader_error = err
				return
			end			
		end		
		
		if render.active_texture then
			gl.ActiveTexture(e.GL_TEXTURE0) 
			render.active_texture:Bind()
			gl.Uniform1i(gl.GetUniformLocation(render.vbo_3d_program, "texture"), 0)
		end

		gl.UseProgram(render.vbo_3d_program)
		
		gl.GetFloatv(e.GL_PROJECTION_MATRIX, render.projection_matrix)
		gl.UniformMatrix4fv(gl.GetUniformLocation(render.vbo_3d_program, "proj_mat"), 1, 0, render.projection_matrix)
		
		gl.GetFloatv(e.GL_MODELVIEW_MATRIX, render.view_matrix)
		gl.UniformMatrix4fv(gl.GetUniformLocation(render.vbo_3d_program, "view_mat"), 1, 0, render.view_matrix)
		
		gl.Uniform1f(gl.GetUniformLocation(render.vbo_3d_program, "time"), render.frame / 60 / 4)
		gl.Uniform3f(gl.GetUniformLocation(render.vbo_3d_program, "cam_pos"), render.cam_pos.x, render.cam_pos.y, render.cam_pos.z)

		gl.EnableVertexAttribArray(0)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(0, 3, e.GL_FLOAT, false, stride, pos_stride)

		gl.EnableVertexAttribArray(1)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(1, 3, e.GL_FLOAT, false, stride, normal_stride)

		gl.EnableVertexAttribArray(2)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(2, 2, e.GL_FLOAT, false, stride, uv_stride)

		gl.DrawArrays(e.GL_TRIANGLES, 0, vbo.length)
		render.frame = render.frame + 1
	end	
end


do -- vbo 2d
	render.vbo_2d_program = nil
	
	local vertex_shader_source = [[
		uniform float time;

		attribute vec3 position;
		attribute vec3 normal;
		attribute vec2 uv;

		varying vec3 color;
		varying vec2 texcoords;
		varying vec3 vertex_normal;
		varying vec3 vertex_pos;

		void main()
		{
			texcoords = uv;
			color = gl_Color;
			vertex_normal = normal;
			gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * vec4(position, 1.0);
			vertex_pos = position;
		}
	]]  

	local fragment_shader_source = [[
		uniform float time;
		uniform sampler2D texture;
		uniform vec3 cam_pos;

		varying vec3 color;
		varying vec2 texcoords;
		varying vec3 vertex_normal;
		varying vec3 vertex_pos;

		vec3 light_direction = false ? vec3(0.0, 0.0, 1.0) : normalize(vec3(sin(time), 0.0, cos(time)));
		vec3 viewer_direction = normalize(cam_pos - vertex_pos);	
		vec3 texel = tex2D(texture, texcoords);
		
		vec3 get_specular()
		{		
			return clamp(pow(dot(reflect(light_direction, vertex_normal), viewer_direction), 8.0), 0.0, 1.0);
		}
		
		vec3 get_diffuse()
		{
			return texel * 0.1 + texel * clamp(dot(vertex_normal, light_direction), 0.0, 1.0) * vec3(0.0, 0.25, 0.5);
		}

		void main()
		{
			gl_FragColor = vec4(
				get_diffuse() + 
				get_specular()
			, 1);
		}
	]]
	
		
	ffi.cdef[[
		struct vertex_attributes_2d
		{
			float x, y, z;
			float u, v;
			unsigned char r, g, b, a;
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
		
		return {
			AddVertex = function(_, x,y, u,v, r,g,b,a)
				
			end
		}
	end
	
	local stride = ffi.sizeof("struct vertex_attributes_2d")
	
	local pos_stride = ffi.cast("void*", 0)
	local normal_stride = ffi.cast("void*", 12)
	local uv_stride = ffi.cast("void*", 24)
	
	function render.Draw2DVBO(vbo)
		if not render.vbo_3d_program then
			local prog, err = render.CreateProgram(vertex_shader_source, fragment_shader_source, function(program)
				gl.BindAttribLocation(program, 0, "position")
				gl.BindAttribLocation(program, 1, "normal")
				gl.BindAttribLocation(program, 2, "uv")
			end)
			
			if prog then
				render.vbo_3d_program = prog
			else
				logn(err)
				return
			end			
		end		
		
		if render.active_texture then
			gl.ActiveTexture(e.GL_TEXTURE0) 
			render.active_texture:Bind()
			gl.Uniform1i(gl.GetUniformLocation(render.vbo_3d_program, "texture"), 0)
		end

		gl.Uniform1f(gl.GetUniformLocation(render.vbo_3d_program, "time"), os.clock())
		gl.Uniform3f(gl.GetUniformLocation(render.vbo_3d_program, "cam_pos"), render.cam_pos.x, render.cam_pos.y, render.cam_pos.z)

		gl.UseProgram(render.vbo_3d_program)

		gl.EnableVertexAttribArray(0)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(0, 3, e.GL_FLOAT, false, stride, pos_stride)

		gl.EnableVertexAttribArray(1)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(1, 3, e.GL_FLOAT, false, stride, normal_stride)

		gl.EnableVertexAttribArray(2)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
		gl.VertexAttribPointer(2, 2, e.GL_FLOAT, false, stride, uv_stride)

		gl.DrawArrays(e.GL_TRIANGLES, 0, vbo.length)
	end	
end

return render

