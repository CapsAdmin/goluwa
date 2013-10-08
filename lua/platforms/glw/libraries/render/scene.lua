function render.DrawScene(window)
	render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)

	render.Start(window)
		event.Call("PreDisplay", dt)
		
		if render.gbuffer then
			render.gbuffer:Begin()
		end

		render.Start3D()
		event.Call("OnDraw3D", dt)

		if render.gbuffer then
			render.gbuffer:End()
			render.DrawDeffered(window:GetSize():Unpack())			
		end
				
		render.Start2D()
		event.Call("OnDraw2D", dt)
		
		event.Call("PostDisplay", dt)
	render.End()
end