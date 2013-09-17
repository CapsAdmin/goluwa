render = render or {}

function render.Initialize(w, h)		
	check(w, "number")
	check(h, "number")
	
	render.cam_pos = Vec3(0,0,0)
	render.farz = 32000
	render.nearz = 0.1
	render.fov = 75  
	
	render.projection_matrix = ffi.new("float[16]")
	render.view_matrix = ffi.new("float[16]")
	
	render.r = r
	render.g = g
	render.b = b
	render.a = a
	
	render.w = w
	render.h = h
	
	gl.Enable(e.GL_BLEND)
	gl.Enable(e.GL_CULL_FACE)
	gl.Enable(e.GL_TEXTURE_2D)
	gl.Enable(e.GL_TEXTURE_3D)

	gl.CullFace(e.GL_FRONT) 

	gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)
	gl.PolygonMode(e.GL_FRONT_AND_BACK, e.GL_FILL)
	
	if surface then
		surface.Initialize()
	end
end


function render.GetScreenSize()
	return render.w, render.h
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
	function render.SetTexture(id, channel, location)
		channel = channel or 0		
	
		gl.ActiveTexture(e.GL_TEXTURE0 + channel) 
		gl.BindTexture(e.GL_TEXTURE_2D, id)
		
		if location and render.current_program then
			gl.Uniform1i(gl.GetUniformLocation(render.current_program, location), channel)
		end
	end
	
	function render.SetTextureFiltering()
		gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_WRAP_S, e.GL_REPEAT)
		gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_WRAP_T, e.GL_REPEAT)
		
		gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_MAG_FILTER, e.GL_NEAREST)
		gl.TexParameteri(e.GL_TEXTURE_2D, e.GL_TEXTURE_MIN_FILTER, e.GL_NEAREST)
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