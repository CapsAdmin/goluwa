function render.CreateMatrices()	
	render.camera_matrix = ffi.new("float[16]")
	render.model_matrix = ffi.new("float[16]")
	
	render.cam_pos = Vec3(0,0,0)
	render.cam_ang = Ang3(0,0,0)
	render.fov = 75 
	render.farz = 32000
	render.nearz = 0.1
end


function render.GetModelMatrix()
	gl.GetFloatv(e.GL_MODELVIEW_MATRIX, render.model_matrix)
	return render.model_matrix
end

function render.UseModelMatrix()
	gl.MatrixMode(e.GL_MODELVIEW)
end


function render.GetCameraMatrix()
	gl.GetFloatv(e.GL_PROJECTION_MATRIX, render.camera_matrix)
	return render.camera_matrix
end

function render.UseCameraMatrix()
	gl.MatrixMode(e.GL_PROJECTION)
end

function render.Translate(x, y, z)
	if x == 0 and y == 0 and (z == 0 or not z) then return end
	gl.Translatef(x, y, z)
end

function render.Rotate(a, x, y, z)
	if a == 0 then return end
	gl.Rotatef(a, x, y, z)
end

function render.Scale(x, y, z)
	if x == 1 and y == 1 and z == 1 then return end
	gl.Scalef(x, y, z)
end
render.LoadIdentity = gl.LoadIdentity
render.Ortho = gl.Ortho

function render.PushMatrix(p, a, s)
	gl.PushMatrix()

	if p then
		render.Translate(p.x, p.y, p.z)
	end
	
	if a then
		render.Rotate(a.p, 1, 0, 0)
		render.Rotate(a.y, 0, 1, 0)
		render.Rotate(a.r, 0, 0, 1)
	end
	
	if s then 
		render.Scale(s.x, s.y, s.z) 
	end
end

function render.PopMatrix()
	gl.PopMatrix()
end

function render.SetPerspective(fov, nearz, farz, ratio)
	fov = fov or render.fov
	nearz = nearz or render.nearz
	farz = farz or render.farz
	ratio = ratio or render.w/render.h
		
	glu.Perspective(fov, ratio, nearz, farz)
end

function render.SetViewport(x, y, w, h)
	x = x or 0
	y = y or 0
	w = w or render.w
	h = h or render.h
	
	gl.Viewport(x, y, w, h)
end


do -- camera helpers
	
	function render.SetCam(pos, ang, fov)
		if pos then render.cam_pos = pos end
		if ang then render.cam_ang = ang end
		if fov then render.cam_fov = fov end
	end
	
	-- useful for shaders
	function render.GetCamPos()
		return render.cam_pos
	end
	
	function render.GetCamAng()
		return render.cam_ang
	end
	
	function render.GetCamFOV()
		return render.cam_fov
	end

	function render.Start2D(x, y, w, h)
		x = x or 0
		y = y or 0
		w = w or render.w
		h = h or render.h
	
		render.UseCameraMatrix()
			render.LoadIdentity()
			
			render.Ortho(x,w, y,h, -1,1)
			
			if render.top_left then
				render.Scale(1, -1 ,0)
				render.Translate(0, -h, 0)
			end
			
			gl.Disable(e.GL_DEPTH_TEST) 
		
		render.UseModelMatrix()
	end
	
	function render.Start3D(pos, ang, fov, nearz, farz, ratio)
		render.UseCameraMatrix()
			render.LoadIdentity()
			
			pos = pos or render.cam_pos
			ang = ang or render.cam_ang
			fov = fov or render.cam_fov
			
			render.SetPerspective(fov, nearz, farz, ratio)
				
			if fov then
				render.cam_fov = fov
			end
				
			if ang then
				render.Rotate(ang.p, 1, 0, 0)
				render.Rotate(ang.y, 0, 1, 0)
				render.Rotate(ang.r, 0, 0, 1)
				render.cam_ang = ang
			end
			
			if pos then
				render.Translate(pos.x, pos.y, pos.z)	
				render.cam_pos = pos
			end
			
			gl.Enable(e.GL_DEPTH_TEST) 

		render.UseModelMatrix()	
	end
end

-- experimental..
function render.EnableFast2DMatrix()
	logn("enabling fast experimental 2d matrix")
		  
	local stack = {}
	 
	for i = 1, 8 do
		table.insert(stack, ffi.new("float[16]"))
	end

	local level = 1
	
	function render.GetCameraMatrix()
		return self.camera_matrix
	end
	
	function render.GetModelMatrix()
		return self.model_matrix
	end
	  
	function render.Translate(x, y)
		stack[level][12] = stack[level][12] + x
		stack[level][13] = stack[level][13] + y
	end
	  
	function render.Scale(w, h)	
		stack[level][0] = w
		stack[level][5] = h
	end

	function render.PushMatrix()	
		level = level + 1
		
		render.model_matrix = stack[level]
		
		stack[level][12] = stack[level-1][12]
		stack[level][13] = stack[level-1][13]
		
		stack[level][15] = 1
	end   

	function render.PopMatrix()
		level = level - 1
		render.model_matrix = stack[level]
	end

	function render.Rotate()	
	
	end  

	event.AddListener("PreDisplay", "matrix reset", function()
		render.PushMatrix()
	end)

	event.AddListener("PostDisplay", "matrix reset", function()
		render.PopMatrix()
	end)
	
	logn("to revert restart the renderer")
end