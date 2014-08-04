local fb = render.CreateFrameBuffer(512, 512)

local tex = fb:GetTexture()
 
event.AddListener("Draw2D", "lol", function()
	
	fb:Begin()		
		surface.SetColor(1, 0, 0, 1) 
		if wait(0.5) then
			fb:Clear(1,1,1,0)
		end
		
		surface.Start(0, 0, tex.w, tex.h)
			surface.SetWhiteTexture() 
			for i = 1, 10 do
				surface.SetColor(math.randomf(), 0, 0, 1)
				surface.DrawRect(math.random(tex.w), math.random(tex.h), 100, 100, math.random(360))
			end
		surface.End()
	fb:End() 

	surface.SetWhiteTexture()
	surface.SetColor(0, 0, 1, 1) 
	surface.DrawRect(0, 0, 100, 100)

	surface.Start(50, 50, tex.w, tex.h) 				
		surface.SetWhiteTexture()
		surface.SetColor(1, 0, 1, 1)
		surface.DrawRect(0, 0, tex.w, tex.h)
				
		surface.Start(0, 0, 100, 100)  
		--	surface.Translate(50, 50)  
			surface.Rotate(45)
			surface.SetWhiteTexture() 
			surface.SetColor(0, 1, 0, 1) 
			surface.DrawRect(0, 0, 100, 100)
		surface.End()
		
		surface.SetTexture(tex)
		surface.SetColor(1, 1, 1, 1)
		surface.DrawRect(0, 0, tex.w, tex.h)
	surface.End()
	



end) 