local fb = render.CreateFrameBuffer(256, 256, {
	attach = "color1",
	texture_format = {
		internal_format = "RGB32F",
		min_filter = "nearest",
	}
})

local tex = fb:GetTexture()
 
event.AddListener("Draw2D", "lol", function()
	local t = timer.GetSystemTime()
	
	fb:Begin()				
		surface.Start(0, 0, tex.w, tex.h)
			surface.Translate(math.sin(t) * 100, math.cos(t) * 100)
			surface.Rotate(t*100)
			
			surface.SetWhiteTexture() 
			local x, y = surface.GetMousePos(50, 50)
						
			surface.DrawRect(x,y,5,5) 
			surface.SetWhiteTexture(tex)
			render.SetBlendMode("additive")
			surface.SetColor(math.randomf(), math.randomf(), math.randomf(), 0.1)
			surface.DrawRect(math.random(tex.w), math.random(tex.h), 100, 100, math.random(360))
			render.SetBlendMode("alpha")
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
	surface.End()
		
	surface.SetTexture(tex)
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(50, 50, tex.w, tex.h)
	
	surface.SetTexture(tex)
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(tex.w, tex.h, 50, 50, t*100, 25, 25)
end) 