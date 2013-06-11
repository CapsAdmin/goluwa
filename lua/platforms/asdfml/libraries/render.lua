local render = _G.render or {}

local tmp_color = sfml.Color()

render.farz = 1000
render.nearz = 0.1
render.fov = 75  

function render.Initialize(w, h)	
	check(w, "number")
	check(h, "number")
	
	render.w = w
	render.h = h
	
	gl.Enable(e.GL_BLEND)
	gl.Enable(e.GL_DEPTH_TEST) 
	gl.Enable(e.GL_CULL_FACE)

	gl.CullFace(e.GL_FRONT) 

	gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)
	gl.PolygonMode(e.GL_FRONT_AND_BACK, e.GL_FILL)
end

function render.Clear(flag, ...)
	flag = flag or e.GL_COLOR_BUFFER_BIT
	gl.Clear(bit.bor(flag, ...))
end

function render.SetTexture(tex)
	render.active_texture = tex
	tex:Bind()
	render.SetTextureFiltering()
end

function render.SetTextureFiltering(blah)
	gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_MIN_FILTER, e.GL_LINEAR)
	gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_MAG_FILTER, e.GL_LINEAR)
end

function render.Start(x, y, w, h)
	x = x or 0
	y = y or 0
	w = w or render.w
	h = h or render.h
	
	gl.Viewport(x, y, w, h)
end

function render.End()
	gl.Flush()
end

function render.SetPerspective(fov, nearz, farz, ratio)
	fov = fov or render.fov
	nearz = nearz or render.nearz
	farz = farz or render.farz
	ratio = ratio or render.w/render.h
	
	glu.Perspective(fov, ratio, nearz, farz)
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
		if a and s then

			gl.Rotatef(a.p, 1, 0, 0)
			gl.Rotatef(a.y, 0, 1, 0)
			gl.Rotatef(a.r, 0, 0, 1)
			gl.Translatef(p.x, p.y, p.z)
			gl.Scalef(s.x, s.y, s.z)
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
	function render.CreateShader(type, source)
		check(type, "number")
		check(source, "string")
		
		local shader = gl.CreateShader(type)

		local ffisource = ffi.new("char[?]", #source)
		ffi.copy(ffisource, source)

		local grr = ffi.new("const char*[1]")
		grr[0] = ffisource
		local blah = ffi.new("GLint[1]")
		blah[0] = #source
		gl.ShaderSource(shader, 1, grr, blah)

		gl.CompileShader(shader)

		local compile_status = ffi.new("GLint[1]")
		gl.GetShaderiv(shader, e.GL_COMPILE_STATUS, compile_status)
	
		if compile_status[0] == 0 then
			local asdsaad = ffi.new("GLsizei[1]")
			local log = ffi.new("char[1024]")
			gl.GetShaderInfoLog(shader, 1024, asdsaad, log)
			local str = ffi.string(log)
			gl.DeleteShader(shader)
			return false, str
		end

		return shader
	end

	function render.CreateProgram(vert_source, frag_source, LOL)
		check(vert_source, "string")
		check(frag_source, "string")
		
		local vertex, vertex_err = render.CreateShader(e.GL_VERTEX_SHADER, vert_source)	
		if vertex_err then return false, vertex_err end
		
		local fragment, frag_err = render.CreateShader(e.GL_FRAGMENT_SHADER, frag_source)
		if frag_err then return false, frag_err end
		
		local program = gl.CreateProgram()
		gl.AttachShader(program, vertex)
		gl.AttachShader(program, fragment)
		if LOL then LOL(program, vertex, fragment) end
		gl.LinkProgram(program)

		local link_status = ffi.new("GLint[1]")
		gl.GetProgramiv(program, e.GL_LINK_STATUS, link_status)

		if link_status[0] == 0 then
			local asdsaad = ffi.new("GLsizei[1]")
			local log = ffi.new("char[1024]")
			gl.GetProgramInfoLog(shader, 1024, asdsaad, log)
			local str = ffi.string(log)
			gl.DeleteProgram(program)		
			
			return false, str
		end
		
		return program
	end
end

do -- vbo	
	render.vbo_program = nil
	
	local vertex_shader_source = [[
		uniform float time;

		attribute vec3 position;
		attribute vec3 normal;
		attribute vec2 uv;

		varying vec3 color;
		varying vec2 texcoords;
		varying vec3 normal_;

		void main()
		{
			texcoords = uv;
			color = gl_Color;
			normal_ = normal;
			gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * vec4(position, 1.0);
		}
	]] 

	local fragment_shader_source = [[
		uniform float time;
		uniform sampler2D texture;

		varying vec3 color;
		varying vec2 texcoords;
		varying vec3 normal_;

		vec3 asdf()
		{
			return color * tex2D(texture, texcoords) * dot(normal_, vec3(0.0, 0.0, 1.0));
		}

		void main()
		{
			gl_FragColor = vec4(asdf(), 1.0);
		}
	]]
	
	--[[
		
		the normal and uv fields are optional
	
		-- data format should be the following
		{
			{pos = Vec3(), normal = (), uv = Vec2()},
			...
		}
	]]
	function render.CreateVBO(data)
		local buffer = ffi.new("struct vertex_attributes[?]", #data)

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
	
	ffi.cdef[[
		struct vertex_attributes
		{
			float pos_x, pos_y, pos_z;
			float norm_x, norm_y, norm_z;
			float u, v;
		};
	]]	
	
	local stride = ffi.sizeof("struct vertex_attributes")
	
	local pos_stride = ffi.cast("void*", 0)
	local normal_stride = ffi.cast("void*", 12)
	local uv_stride = ffi.cast("void*", 24)
	
	function render.DrawVBO(vbo)
		if not render.vbo_program then
			local prog, err = render.CreateProgram(vertex_shader_source, fragment_shader_source, function(program)
				gl.BindAttribLocation(program, 0, "position")
				gl.BindAttribLocation(program, 1, "normal")
				gl.BindAttribLocation(program, 2, "uv")
			end)
			
			if prog then
				render.vbo_program = prog
			else
				logn(err)
				return
			end			
		end		
		
		if render.active_texture then
			gl.ActiveTexture(e.GL_TEXTURE0) 
			render.active_texture:Bind()
			gl.Uniform1i(gl.GetUniformLocation(render.vbo_program, "texture"), 0)
		end

		gl.Uniform1f(gl.GetUniformLocation(render.vbo_program, "time"), os.clock())
		
		gl.UseProgram(render.vbo_program)

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

