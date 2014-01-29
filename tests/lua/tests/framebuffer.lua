window.Open()

local fb = render.CreateFrameBuffer(512, 512, {
	attach = e.GL_COLOR_ATTACHMENT1,
	texture_format = {
		internal_format = e.GL_RGB32F,
	}
})

timer.Create("fb_update", 0.2, 0, function()
	fb:Begin()
		surface.SetWhiteTexture()
		surface.Color(math.randomf(), math.randomf(), math.randomf())
		surface.DrawRect(math.random(512), math.random(512), 100, 100)
	fb:End()
end)

event.AddListener("OnDraw2D", "fb", function()
	surface.SetTexture(fb:GetTexture())
	surface.Color(1,1,1,1)
	surface.DrawRect(100, 100, 100, 100, timer.clock()*100)
end)