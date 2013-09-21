local window = glw.OpenWindow(1280, 720)
      
local font = surface.CreateFont("test", {
	size = 12,
	path = "fonts/unifont.ttf",
})	 
   
event.AddListener("OnDraw", "gl", function(dt)
	render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
	gl.ClearColor(0.5, 0.5, 0.5, 0.5)

	render.Start(window)			 
		surface.Start()	
		
		surface.SetWhiteTexture()
		 
		surface.SetFont(font)
		surface.SetTextPos(0,0)
		surface.Color(1, 1, 1, 1)
		surface.DrawText("æøå|ops汉语/漢語")
	render.End() 
end)