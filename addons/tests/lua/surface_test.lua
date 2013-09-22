local window = glw.OpenWindow(500, 500)

event.AddListener("OnDraw2D", "lol", function()
	surface.Color(1,1,1,1)
	surface.SetWhiteTexture()

	surface.DrawRect(90, 50, 100, 100)
	
	for i =1, 50 do
		surface.SetTextPos(0,0)
		surface.DrawText("LOLASUIODHAS HduAHSDIuhASPudh ASDuASd")
	end
end)