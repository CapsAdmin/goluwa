
local window = glw.OpenWindow() 
 
local texture = render.CreateTexture("textures/face1.png")
local font = Font(R"fonts/arial.ttf")
font:SetFaceSize(13, 0)
font:SetOutset(10, 1)
gl.ClearColor(0,0,0,0)

event.AddListener("OnDraw", 1, function()	
	render.Start(window)
		render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
		
		render.Start2D()
			surface.SetFont(font)
		render.SetTexture(texture)
			gl.Color4f(1,0.5,0, 1)
			surface.Scale(1,1)
			surface.DrawText("HIWWW")
			surface.DrawText("wIWWW")
	render.End()
end)