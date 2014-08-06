local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render

do -- current window
	render.current_window = NULL

	local last_w
	local last_h

	function render.Start(window)
		window:MakeContextCurrent()
			
		render.current_window = window
		local w, h = window:GetSize():Unpack()
		render.w = w
		render.h = h
		render.PushViewport(0, 0, w, h)
	end

	function render.End()
		if render.current_window:IsValid() then
			render.current_window:SwapBuffers()
		end

		render.frame = render.frame + 1	
		
		render.PopViewport()
	end

	function render.GetFrameNumber()
		return render.frame
	end
	
	function render.GetWidth()
		if render.current_window:IsValid() then
			return render.current_window:GetSize().w
		end
		
		return 0
	end

	function render.GetHeight()
		if render.current_window:IsValid() then
			return render.current_window:GetSize().h
		end
		
		return 0
	end
	
	function render.GetScreenSize()
		return render.GetWidth(), render.GetHeight()
	end
end

console.CreateVariable("render_accum", false)

function render.DrawScene(window, dt)
	render.delta = dt
	render.Clear(gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT)
	render.Start(window)	
		event.Call("PreDisplay", dt)		
			render.Start3D()
				event.Call("Draw3D", dt)
			render.End3D()	
				
			render.Start2D()
				event.Call("Draw2D", dt)
				
				if false and render.debug then
					local i = 0
					for name, matrix in pairs(render.matrices) do
						render.DrawMatrix(i*230 + 10, render.camera.h - 220, matrix, name)
						i = i + 1
					end
				end
				
			render.End2D()
		event.Call("PostDisplay", dt)
		
		if console.GetVariable("render_accum") then
			local blur_amt = 0.5		
			
			gl.Accum(gl.e.GL_ACCUM, 1)
			gl.Accum(gl.e.GL_RETURN, 1-blur_amt)
			gl.Accum(gl.e.GL_MULT, blur_amt)
		end
	render.End()
end