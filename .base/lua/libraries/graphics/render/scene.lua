local gl = require("libraries.ffi.opengl") -- OpenGL
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
		render.SetViewport(0, 0, w, h)
	end

	function render.End()
		event.Call("PostDrawScene")
		if render.current_window:IsValid() then
			render.current_window:SwapBuffers()
		end

		render.frame = render.frame + 1
	end

	function system.GetFrameNumber()
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
		return Vec2(render.GetWidth(), render.GetHeight())
	end
end

console.CreateVariable("render_accum", 0)

function render.DrawScene(window, dt)
	render.delta = dt
	render.Clear(gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT)
	render.Start(window)
		
		render.SetCullMode("none")
		
		render.DrawGBuffer(dt, window:GetSize():Unpack())
		
		local blur_amt = console.GetVariable("render_accum") or 0
		if blur_amt ~= 0 then			
			gl.Accum(gl.e.GL_ACCUM, 1)
			gl.Accum(gl.e.GL_RETURN, 1-blur_amt)
			gl.Accum(gl.e.GL_MULT, blur_amt)
		end
	render.End()
end