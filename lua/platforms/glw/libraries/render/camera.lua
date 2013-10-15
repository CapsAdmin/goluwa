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