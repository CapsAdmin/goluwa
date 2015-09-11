window.Open(500, 500)

local tex = Texture("textures/pac.png")

event.AddListener("Draw2D", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetTexture(tex)

	surface.SetRectUV(0, 0, 0.5, 0.5)
	surface.DrawRect(50, 50, 100, 100)
	
	surface.SetRectUV(0.5, 0.5, 0.5, 0.5)
	surface.DrawRect(150, 150, 100, 100)
	
	surface.SetRectUV(0, 0.5, 0.5, 0.5)
	surface.DrawRect(50, 150, 100, 100)
	
	surface.SetRectUV(0.5, 1, 0.5, 0.5)
	surface.DrawRect(150, 50, 100, 100)
	
	surface.SetRectUV()
end) 