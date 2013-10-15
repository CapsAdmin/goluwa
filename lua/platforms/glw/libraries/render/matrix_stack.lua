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

-- doesn't work yet
if false then
	local level = 1
	local mode = "model_matrix"
	local stack = {}
	stack.camera_matrix = {}
	stack.model_matrix = {}

	for i = 1, 8 do
		table.insert(stack.camera_matrix, Matrix44())
		table.insert(stack.model_matrix, Matrix44())
	end

	function render.CreateMatrices()		
		render.UseCameraMatrix()
		
		render.cam_pos = Vec3(0,0,0)
		render.cam_ang = Ang3(0,0,0)
		render.fov = 75 
		render.farz = 32000
		render.nearz = 0.1
	end

	function render.GetCurrentMatrix()
		return stack[mode][level]
	end

	function render.GetModelMatrix()
		return stack.model_matrix[level].m
	end

	function render.UseModelMatrix()
		mode = "model_matrix"
		level = 1
	end


	function render.GetCameraMatrix()
		return stack.camera_matrix[level].m
	end

	function render.UseCameraMatrix()
		mode = "camera_matrix"
		level = 1
	end

	function render.Translate(x, y, z)
		if x == 0 and y == 0 and z == 0 then return end
		stack[mode][level]:Translate(x, y, z)
	end

	function render.Rotate(a, x, y, z)
		if a == 0 then return end
		stack[mode][level]:Rotate(a, x, y, z)
	end

	function render.Scale(x, y, z)
		if x == 1 and y == 1 and z == 1 then return end
		stack[mode][level]:Scale(x, y, z)
	end

	function render.LoadIdentity()
		stack[mode][level]:Identity()
	end

	function render.Ortho(...)
		stack[mode][level]:Ortho(...)
	end

	function render.PushMatrix(p, a, s)
		level = level + 1
		
		stack[mode][level]:Identity()

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
		level = level - 1
	end

	function render.SetPerspective(fov, nearz, farz, ratio)
		fov = fov or render.fov
		nearz = nearz or render.nearz
		farz = farz or render.farz
		ratio = ratio or render.w/render.h
			
		stack[mode][level]:Perspective(fov, ratio, nearz, farz)
	end

	function render.SetViewport(x, y, w, h)
		x = x or 0
		y = y or 0
		w = w or render.w
		h = h or render.h
		
		gl.Viewport(x, y, w, h)
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