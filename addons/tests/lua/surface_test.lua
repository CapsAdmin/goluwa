local window = glw.OpenWindow(1280, 720)
      
local font = surface.CreateFont("test", {
	size = 12,
	path = "fonts/unifont.ttf",
})	 
   
event.AddListener("OnDisplay", "gl", function(dt)		 
	surface.Start()	

	surface.SetFont(font)
	for i= 1, 1000  do
		local c = HSVToColor(glfw.GetTime(),1,1)
		surface.Color(c.r,c.g,c.b, 1)
		surface.SetTextPos(i,i)
		surface.DrawText("æøå|ops汉语/漢語")
	end
	
			
	surface.SetWhiteTexture()
	surface.Color(1,1,1, 1)
	surface.DrawRect(400 + math.sin(glfw.GetTime()) * 100, 400 + math.cos(glfw.GetTime()) * 100, 50, 50)
end) 