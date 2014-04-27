gl.logcalls = true
local fb = render.CreateFrameBuffer(512, 512, {
	attach = e.GL_COLOR_ATTACHMENT0,
	texture_format = {
		internal_format = e.GL_RGB32F,
	}
})

timer.Create("lol", 0.2, 0, function()
		
	fb:Begin()   
		fb:Clear(1, 1, 1)
			
		--surface.Start(0, 0, 512, 512) 
			surface.SetWhiteTexture()
			surface.Color(math.randomf(), math.randomf(), math.randomf(), 1)
			surface.DrawRect(math.random(512), math.random(512), 100, 100)
		--surface.End()
			
	fb:End()  
end)
event.AddListener("OnDraw2D", "fb", function()
	surface.SetTexture(fb:GetTexture())
	surface.Color(1,1,1,1)
	surface.DrawRect(128, 128, 128, 128, timer.clock()*100, 64, 64)
end)                    
gl.logcalls = false     