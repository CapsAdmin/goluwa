render = render or {}

include("surface.lua")
include("mesh3d.lua")
include("mesh2d.lua")
include("texture.lua")

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
	render.frame = render.frame or 0
end

function render.End()
	if render.current_window:IsValid() then
		glfw.SwapBuffers(render.current_window.__ptr)
	end
	gl.Flush()
	render.frame = render.frame + 1
end

function render.SetPerspective(fov, nearz, farz, ratio)
	fov = fov or render.fov
	nearz = nearz or render.nearz
	farz = farz or render.farz
	ratio = ratio or render.w/render.h
	
	glu.Perspective(fov, ratio, nearz, farz)
end

local data = ffi.new("float[3]")

function render.ReadPixels(x, y, w, h)
	w = w or 1
	h = h or 1
	
	gl.ReadPixels(x, y, w, h, e.GL_RGBA, e.GL_FLOAT, data)
		
	return data[0], data[1], data[2], data[3]
end

	
function render.DrawScreenQuad()	

	gl.Begin(e.GL_TRIANGLES)
		gl.TexCoord2f(1, 1)
		gl.Vertex2f(0, 0)
		
		gl.TexCoord2f(1, 0)
		gl.Vertex2f(0, 1)
		
		gl.TexCoord2f(0, 0)
		gl.Vertex2f(1, 1) 

		
		gl.TexCoord2f(0, 0)
		gl.Vertex2f(1, 1)

		gl.TexCoord2f(0, 1)
		gl.Vertex2f(1, 0)
					
		gl.TexCoord2f(1, 1)
		gl.Vertex2f(0, 0) 			
	gl.End()
end

do -- textures
	include("texture.lua")
	
	function render.SetTexture(id, channel, location)
		channel = channel or 0		
	
		gl.ActiveTexture(e.GL_TEXTURE0 + channel) 
		gl.Enable(e.GL_TEXTURE_2D)
		gl.BindTexture(e.GL_TEXTURE_2D, id)
		
		if location and render.current_program then
			gl.Uniform1i(gl.GetUniformLocation(render.current_program, location), channel)
		end
	end
	
	function render.SetTextureFiltering()
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
			gl.Translatef(p.x, p.y, p.z)
			gl.Rotatef(a.p, 1, 0, 0)
			gl.Rotatef(a.y, 0, 1, 0)
			gl.Rotatef(a.r, 0, 0, 1)
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
end

do -- vbo 3d
	render.vbo_3d_program = nil
	
	-- load the shader sources
	local vertex_shader_source = vfs.Read("shaders/phong/vertex.c", "rb")  
	local fragment_shader_source = vfs.Read("shaders/phong/fragment.c", "rb")

	-- this will be used in the vertex array
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
		-- create the vertex array that is #data long
		local buffer = ffi.new("struct vertex_attributes_3d[?]", #data)

		-- translate the data table to the array
		-- maybe there should be a way to do this more directly..
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

		-- create 1 new buffer
		local id = ffi.new("int [1]") gl.GenBuffers(1, id) id = id[0]

		
		-- bind it and feed it the buffer array
		gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
			gl.BufferData(e.GL_ARRAY_BUFFER, ffi.sizeof(buffer[0]) * #data, buffer, e.GL_STATIC_DRAW)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, 0)
		
		return {Type = "VertexBuffer", id = id, length = #data}
	end

	-- these are used in gl.VertexAttribPointer
	
	-- x,y,z,nx,ny,nz,u,v | x,y,z,nx,ny,nz,u,v | ...
	
	-- where | is the stride
	local float_size = ffi.sizeof("float")
	local stride = ffi.sizeof("struct vertex_attributes_3d")
	
	local pos_stride = ffi.cast("void*", 0) -- > x,y,z < nx,ny,nz,u,v
	local normal_stride = ffi.cast("void*", float_size * 3) -- x,y,z, > nx,ny,nz < u,v
	local uv_stride = ffi.cast("void*", float_size * 3 * 2) -- x,y,z,nx,ny,nz > u,v <
	
	-- the steps are determined by float_size * position
	-- so float_size * 3 would be after x y z
	-- the length is determined by the second argument in VertexAttribPointer
	
	render.vbo_shader_error = nil
	
	function render.Draw3DVBO(vbo)
		if render.vbo_shader_error then return end
	
		if not render.vbo_3d_program then
			local prog, err = Program(assert(Shader(e.GL_VERTEX_SHADER, vertex_shader_source)), assert(Shader(e.GL_FRAGMENT_SHADER, fragment_shader_source)))
						
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
			
		local program = render.current_program or render.vbo_3d_program
		
		render.SetProgram(program)
			
		if render.active_texture then
			render.active_texture:Bind()
		end

		gl.UseProgram(program)
			
			gl.GetFloatv(e.GL_PROJECTION_MATRIX, render.projection_matrix)
			gl.UniformMatrix4fv(gl.GetUniformLocation(program, "proj_mat"), 1, 0, render.projection_matrix)
			
			gl.GetFloatv(e.GL_MODELVIEW_MATRIX, render.view_matrix)
			gl.UniformMatrix4fv(gl.GetUniformLocation(program, "view_mat"), 1, 0, render.view_matrix)
			
			gl.Uniform1f(gl.GetUniformLocation(program, "time"), render.frame / 60 / 4)
			gl.Uniform3f(gl.GetUniformLocation(program, "cam_pos"), render.cam_pos.x, render.cam_pos.y, render.cam_pos.z)

			gl.BindBuffer(e.GL_ARRAY_BUFFER, vbo.id)
			
				gl.EnableVertexAttribArray(0)
				gl.VertexAttribPointer(0, 3, e.GL_FLOAT, false, stride, pos_stride)

				gl.EnableVertexAttribArray(1)
				gl.VertexAttribPointer(1, 3, e.GL_FLOAT, false, stride, normal_stride)

				gl.EnableVertexAttribArray(2)
				gl.VertexAttribPointer(2, 2, e.GL_FLOAT, false, stride, uv_stride)

			gl.BindBuffer(e.GL_ARRAY_BUFFER, 0)
			
			gl.DrawArrays(e.GL_TRIANGLES, 0, vbo.length)
			
		gl.UseProgram(0)
	end	
end

