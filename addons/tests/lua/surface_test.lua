local window = glw.OpenWindow(1280, 720)

surface.InitFreetype()  

event.AddListener("OnDraw", "gl", function(dt)
	render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
	gl.ClearColor(0.5, 0.5, 0.5, 0.5)

	render.Start(window)			
		surface.Start()		
			surface.SetWhiteTexture()
			 
			surface.SetTextPos(5, 5)
			surface.Color(255, 255, 255)
			surface.DrawText("æøå|ops汉语/漢語")
		render.End() 
end)