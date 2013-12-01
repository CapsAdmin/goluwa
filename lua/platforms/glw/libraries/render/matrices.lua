render.matrices = {
	projection_2d = Matrix44(),
	projection_3d = Matrix44(),
	view = Matrix44(),
	world = Matrix44(),
}

render.camera = {
	x = 0,
	y = 0,
	w = 1000,
	h = 1000,
	
	pos = Vec3(0,0,0),
	ang = Ang3(0,0,0),
	
	fov = 75,
	farz = 32000,
	nearz = 0.1,
	
	ratio = 1,
}

local cam = render.camera

-- projection  
do
	-- this isn't really matrix related..
	function render.SetViewport(x, y, w, h)
		cam.x = x or cam.x
		cam.y = y or cam.y
		cam.w = w or cam.w
		cam.h = h or cam.h
		
		cam.ratio = cam.h / cam.w 
		
		gl.Viewport(x, y, w, h)
	end
	
	local last_x
	local last_y
	local last_w
	local last_h

	function render.Start2D(x, y, w, h)		
		cam.x = x or cam.x
		cam.y = y or cam.y
		cam.w = w or cam.w
		cam.h = h or cam.h
		
		if 
			last_x ~= cam.x or
			last_y ~= cam.y or
			last_w ~= cam.w or
			last_h ~= cam.h
		then
			render.SetViewport(cam.x, cam.y, cam.w, cam.h)
			
			local proj = render.matrices.projection_2d
		
			proj:LoadIdentity()
			proj:Ortho(cam.x,cam.w, cam.y,cam.h, -1,1)
		
			-- convert to top left
			proj:Scale(1, -1 ,0)
			proj:Translate(0, -cam.h, 0)
			
			last_x = cam.x
			last_y = cam.y
			last_w = cam.w
			last_h = cam.h
		end
		
		gl.Disable(e.GL_DEPTH_TEST)		
		
		render.PushWorldMatrix()
	end
	
	function render.End2D()
		render.PopWorldMatrix()
	end
		
	local last_farz
	local last_nearz
	local last_fov
	local last_ratio
		
	function render.Start3D(pos, ang, fov, nearz, farz)				
		cam.fov = fov or cam.fov
		cam.nearz = nearz or cam.nearz
		cam.farz = farz or cam.farz
				
		if 
			last_fov ~= cam.fov or
			last_nearz ~= cam.nearz or
			last_farz ~= cam.farz
		then
			local proj = render.matrices.projection_3d
		
			proj:LoadIdentity()
			proj:Perspective(cam.fov, cam.nearz, cam.farz, cam.ratio) 
			--proj:OpenGLFunc("Perspective", cam.fov, cam.nearz, cam.farz, cam.ratio)
			
			last_fov = cam.fov
			last_nearz = cam.nearz
			last_farz = cam.farz
		end
		
		if pos and ang then
			render.SetupView(pos, ang, fov)
		end
				
		gl.Enable(e.GL_DEPTH_TEST) 
		gl.Disable(e.GL_CULL_FACE)
		
		render.PushWorldMatrix()
	end
	
	function render.End3D()
		render.PopWorldMatrix()
	end		
end

-- view
do
	function render.SetupView(pos, ang, fov)
		cam.pos = pos or cam.pos
		cam.ang = ang or cam.ang
		cam.fov = fov or cam.fov
		
		local view = render.matrices.view 
		view:LoadIdentity()		
	
		if ang then
			-- source engine style camera angles
			view:Rotate(ang.p + 90, 1, 0, 0)
			view:Rotate(-ang.r, 0, 1, 0)
			view:Rotate(ang.y, 0, 0, 1)
		end
		
		if pos then
			view:Translate(pos.y, pos.x, pos.z)	
		end
		
	end
	
	-- useful for shaders
	function render.GetCamPos()
		return render.camera.pos
	end

	function render.GetCamAng()
		return render.camera.ang
	end

	function render.GetCamFOV()
		return render.camera.fov
	end
end

-- world
do
	do -- push pop helper
		local stack = {}
		local i = 0
		
		function render.PushWorldMatrix(pos, ang, scale)
			stack[i] = render.matrices.world	
			i = i + 1
			render.matrices.world = Matrix44() * stack[i-1]
			
			-- source engine style world orientation
			if pos then
				render.Translate(-pos.y, -pos.x, -pos.z)	
			end
			
			if ang then
				render.Rotate(-ang.y, 0, 0, 1)
				render.Rotate(-ang.r, 0, 1, 0)
				render.Rotate(-ang.p, 1, 0, 0)
			end
			
			if scale then 
				render.Scale(scale.x, scale.y, scale.z) 
			end	

		end
		
		function render.PopWorldMatrix()
			i = i - 1
			render.matrices.world = stack[i]
		end	
	end
	
	-- put the following list of functions in render.*
	-- render.Translate(0, 0, 0)
	local functions = 
	{
		"Translate",
		"Rotate",
		"Scale",
		"LoadIdentity",
	}
	
	local meta = getmetatable(render.matrices.world)
	
	for _, name in pairs(functions) do
		render[name] = function(...) 
			return render.matrices.world[name](render.matrices.world, ...) 
		end
	end
	
end  
 
-- these are for shaders and they return the raw float[16] array
 
function render.GetProjectionMatrix3D()
	return render.matrices.projection_3d.m
end

function render.GetProjectionMatrix2D()
	return render.matrices.projection_2d.m
end

function render.GetViewMatrix()
	return render.matrices.view.m
end

function render.GetWorldMatrix()
	return render.matrices.world.m
end

function render.GetPVWMatrix2D()
	return (render.matrices.world * render.matrices.projection_2d).m
end

function render.GetPVWMatrix3D()
	return (render.matrices.world * render.matrices.view * render.matrices.projection_3d).m
end