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

	render.UseProjectionMatrix()
		render.LoadIdentity()
		
		render.Ortho(x,w, y,h, -1,1)
		
		if render.top_left then
			render.Scale(1, -1 ,0)
			render.Translate(0, -h, 0)
		end
		
		gl.Disable(e.GL_DEPTH_TEST) 
	
	render.UseWorldMatrix()
		render.LoadIdentity()
end

render.view_matrix = ffi.new("float[16]", 0)

function render.GetViewMatrix()
	return render.view_matrix
end

function render.Start3D(pos, ang, fov, nearz, farz, ratio)
	render.UseProjectionMatrix()
		render.LoadIdentity()

		pos = pos or render.cam_pos
		ang = ang or render.cam_ang
		fov = fov or render.cam_fov
		
		gl.Enable(e.GL_DEPTH_TEST) 
		gl.Disable(e.GL_CULL_FACE)
		
		if fov then
			render.cam_fov = fov
		end
		
		render.SetPerspective(fov, nearz, farz, ratio)
						
		render.UseWorldMatrix()	
			render.LoadIdentity()				
				
				if ang then
					render.Rotate(ang.p+90, 1, 0, 0)
					render.Rotate(-ang.r, 0, 1, 0)
					render.Rotate(ang.y, 0, 0, 1)
					render.cam_ang = ang
				end

				if pos then
					render.Translate(pos.y, pos.x, pos.z)	
					render.cam_pos = pos
				end	
				
				
				gl.GetFloatv(e.GL_MODELVIEW_MATRIX, render.view_matrix)

			--render.PushWorldMatrix()
end 

function render.End3D()
	--render.PopWorldMatrix()		
end