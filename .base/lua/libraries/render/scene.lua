render.gbuffer_enabled = true

function render.EnableGBuffer(b)
	render.gbuffer_enabled = b
end

console.CreateVariable("render_accum", false)

function render.DrawScene(window, dt)
	render.delta = dt
	render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
	render.Start(window)	
		event.Call("PreDisplay", dt)
		
		if render.gbuffer_enabled then
			if render.gbuffer then
				render.gbuffer:Begin()
				render.gbuffer:Clear()
			end

			render.Start3D()
				event.Call("OnDraw3D", dt)
			render.End3D()	
	
			if render.gbuffer then
				render.gbuffer:End()
				render.DrawDeffered(window:GetSize():Unpack())			
			end
		end		
			
		render.Start2D()
			event.Call("OnDraw2D", dt)
			
			if render.debug then
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
			
			gl.Accum(e.GL_ACCUM, 1)
			gl.Accum(e.GL_RETURN, 1-blur_amt)
			gl.Accum(e.GL_MULT, blur_amt)
		end
			
	render.End()
end