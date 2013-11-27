function render.CreateMatrices()	
	render.projection_matrix = ffi.new("float[16]")
	render.world_matrix = ffi.new("float[16]")
	
	render.cam_pos = Vec3(0,0,0)
	render.cam_ang = Ang3(0,0,0)
	render.fov = 75 
	render.farz = 32000
	render.nearz = 0.1
end


function render.GetWorldMatrix()
	gl.GetFloatv(e.GL_MODELVIEW_MATRIX, render.world_matrix)
	return render.world_matrix
end

function render.UseWorldMatrix()
	gl.MatrixMode(e.GL_MODELVIEW)
end


function render.GetProjectionMatrix()
	gl.GetFloatv(e.GL_PROJECTION_MATRIX, render.projection_matrix)
	return render.projection_matrix
end

function render.UseProjectionMatrix()
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

function render.PushWorldMatrix(pos, ang, scale)
	gl.PushMatrix()
	
	if pos then
		render.Translate(-pos.y, -pos.x, -pos.z)	
		render.cam_pos = pos
	end
	
	if ang then
		render.Rotate(-ang.y, 0, 0, 1)
		render.Rotate(-ang.r, 0, 1, 0)
		render.Rotate(-ang.p, 1, 0, 0)
		render.cam_ang = ang
	end
	
	if scale then 
		render.Scale(scale.x, scale.y, scale.z) 
	end	
end

function render.PopWorldMatrix()
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
	local mode = "world_matrix"
	local stack = {}
	stack.projection_matrix = {}
	stack.world_matrix = {}

	for i = 1, 16 do
		table.insert(stack.projection_matrix, Matrix44())
		table.insert(stack.world_matrix, Matrix44())
	end

	function render.CreateMatrices()		
		render.UseProjectionMatrix()
		
		render.cam_pos = Vec3(0,0,0)
		render.cam_ang = Ang3(0,0,0)
		render.fov = 90 
		render.farz = 32000
		render.nearz = 0.1
		
		render.PushWorldMatrix()
	end

	function render.GetCurrentMatrix()
		return stack[mode][level]
	end

	function render.GetWorldMatrix()
		return stack.world_matrix[level].m
	end

	function render.UseWorldMatrix()
		mode = "world_matrix"
		level = 1
	end


	function render.GetProjectionMatrix()
		print(stack.projection_matrix[level])
		return stack.projection_matrix[level].m
	end

	function render.UseProjectionMatrix()
		mode = "projection_matrix"
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

	function render.PushWorldMatrix(p, a, s)
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

	function render.PopWorldMatrix()
		level = level - 1
	end

	function render.SetPerspective(fov, nearz, farz, ratio)
		fov = fov or render.fov
		nearz = nearz or render.nearz
		farz = farz or render.farz
		ratio = ratio or render.w/render.h
			
		stack[mode][level]:Perspective(fov, ratio, nearz, farz)
	end

	--[[function render.SetViewport(x, y, w, h)
		x = x or 0
		y = y or 0
		w = w or render.w
		h = h or render.h
		
		stack[mode][level]:Viewport(x, y, w, h)
	end]]
		
end

-- experimental..
function render.EnableFast2DMatrix()
	logn("enabling fast experimental 2d matrix")
		  
	local stack = {}
	 
	for i = 1, 8 do
		table.insert(stack, ffi.new("float[16]"))
	end

	local level = 1
	
	function render.GetProjectionMatrix()
		return self.projection_matrix
	end
	
	function render.GetWorldMatrix()
		return self.world_matrix
	end
	  
	function render.Translate(x, y)
		stack[level][12] = stack[level][12] + x
		stack[level][13] = stack[level][13] + y
	end
	  
	function render.Scale(w, h)	
		stack[level][0] = w
		stack[level][5] = h
	end

	function render.PushWorldMatrix()	
		level = level + 1
		
		render.world_matrix = stack[level]
		
		stack[level][12] = stack[level-1][12]
		stack[level][13] = stack[level-1][13]
		
		stack[level][15] = 1
	end   

	function render.PopWorldMatrix()
		level = level - 1
		render.world_matrix = stack[level]
	end

	function render.Rotate()	
	
	end  

	event.AddListener("PreDisplay", "matrix reset", function()
		render.PushWorldMatrix()
	end)

	event.AddListener("PostDisplay", "matrix reset", function()
		render.PopWorldMatrix()
	end)
	
	logn("to revert restart the renderer")
end