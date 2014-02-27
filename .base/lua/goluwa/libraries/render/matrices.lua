render.matrices = {
	projection_2d = Matrix44(),
	projection_3d = Matrix44(),
	view_2d = Matrix44(),
	view_3d = Matrix44(),
	world = Matrix44(),
}

render.camera = {
	x = 0,
	y = 0,
	w = 1000,
	h = 1000,
	
	pos = Vec3(0,0,0),
	ang = Ang3(0,0,0),
	
	pos2d = Vec2(0,0),
	ang2d = 0,
	zoom2d = 1,
	
	fov = 75,
	farz = 32000,
	nearz = 0.1,
	
	ratio = 1,
}

local cam = render.camera

-- useful for shaders
function render.GetCamPos()
	return cam.pos
end

function render.GetCamAng()
	return cam.ang
end

function render.GetCamFOV()
	return cam.fov
end

-- projection  
do
	-- this isn't really matrix related..
	function render.SetViewport(x, y, w, h)
		cam.x = x or cam.x
		cam.y = y or cam.y
		cam.w = w or cam.w
		cam.h = h or cam.h
		
		cam.ratio = cam.w / cam.h 
		
		gl.Viewport(x, y, w, h)
	end
	
	local last_x
	local last_y
	local last_w
	local last_h

	function render.Start2D(x, y, w, h)		
	
		if not x and not y and not w and not h then
			x = 0
			y = 0
			w, h = render.GetScreenSize()
		else
			render.PushWorldMatrix()
		end
	
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
	end
	
	function render.Reset2D()
		render.Start2D()
	end
	
	function render.End2D()
		render.PopWorldMatrix()
		render.Reset2D()
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
			render.SetupView3D(pos, ang, fov)
		end
				
		gl.Enable(e.GL_DEPTH_TEST) 
		gl.Disable(e.GL_CULL_FACE)
		
		render.PushWorldMatrix()
	end
	
	function render.End3D()
		render.PopWorldMatrix()
	end		
end

function render.SetupView3D(pos, ang, fov)
	cam.pos = pos or cam.pos
	cam.ang = ang or cam.ang
	cam.fov = fov or cam.fov
	
	local view = render.matrices.view_3d 
	view:LoadIdentity()		
	
	if ang then
		-- source engine style camera angles
		view:Rotate(ang.p + 90, 1, 0, 0)
		view:Rotate(ang.r, 0, 1, 0)
		view:Rotate(ang.y, 0, 0, 1)
	end
	
	if pos then
		view:Translate(pos.y, pos.x, pos.z)
	end
end

function render.SetupView2D(pos, ang, zoom)
	cam.pos2d = pos or cam.pos2d
	cam.ang2d = ang or cam.ang2d
	cam.zoom2d = zoom or cam.zoom2d
	
	local view = render.matrices.view_2d 
	view:LoadIdentity()		
	
	if pos then
		view:Translate(pos.x, pos.y, 0)
	end	
	if zoom then
		view:Scale(zoom, zoom, 1)
	end

	if ang then
		-- source engine style camera angles
		view:Rotate(ang, 0, 0, 1)
	end

end

-- world
do
	do -- push pop helper
		local stack = {}
		local i = 0
		
		function render.PushWorldMatrix(pos, ang, scale)
			stack[i] = render.matrices.world or Matrix44()
			render.matrices.world = Matrix44() * stack[i]
			
			-- source engine style world orientation
			if pos then
				render.Translate(-pos.y, -pos.x, -pos.z) -- Vec3(left/right, back/forth, down/up)	
			end
			
			if ang then
				render.Rotate(-ang.y, 0, 0, 1)
				render.Rotate(-ang.r, 0, 1, 0)
				render.Rotate(-ang.p, 1, 0, 0) 
			end
			
			if scale then 
				render.Scale(scale.x, scale.y, scale.z) 
			end	
	
			i = i + 1
			
			return render.matrices.world
		end
		
		function render.PushWorldMatrixEx(mat)
			stack[i] = render.matrices.world or Matrix44()
			render.matrices.world = stack[i] * mat
			
			i = i + 1
			
			return render.matrices.world
		end
		
		function render.PopWorldMatrix()
			i = i - 1
			
			if i < 0 then
				error("stack underflow", 2)
			end
			
			render.matrices.world = stack[i]
		end
	end
	
	-- world matrix helper functions
	function render.Translate(x, y, z)
		render.matrices.world:Translate(x, y, z)
	end
	
	function render.Rotate(a, x, y, z)
		render.matrices.world:Rotate(a, x, y, z)
	end
	
	function render.Scale(x, y, z)
		render.matrices.world:Scale(x, y, z)
	end
	
	function render.LoadIdentity()
		render.matrices.world:LoadIdentity()
	end	
end  
 
-- these are for shaders and they return the raw float[16] array
 
function render.GetProjectionMatrix3D()
	return render.matrices.projection_3d.m
end

function render.GetProjectionMatrix2D()
	return render.matrices.projection_2d.m
end

function render.GetViewMatrix3D()
	return render.matrices.view_3d.m
end

function render.GetViewMatrix2D()
	return render.matrices.view_2d.m
end

function render.GetWorldMatrix()
	return render.matrices.world.m
end

function render.GetPVWMatrix2D()
	return (render.matrices.world * render.matrices.view_2d * render.matrices.projection_2d).m
end

function render.GetPVWMatrix3D()
	return (render.matrices.world * render.matrices.view_3d * render.matrices.projection_3d).m
end