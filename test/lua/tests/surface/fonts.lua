surface.CreateFont("lol", {
	path = "Francois One", 
	size = 54,
})

surface.CreateFont("love", {
	path = "fonts/resource_imagefont1.png",
	glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"",
})
surface.CreateFont("love2", {
	path = "fonts/boldfont.png",
	glyphs = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!'-:*@<>+/_$&?",
})

event.AddListener("Draw2D", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetFont("lol")
	surface.SetTextPosition(17, 30)
	surface.DrawText("empathize foolish self benefit start off preferred occasions")
	
	local w, h = surface.GetTextSize("empathize foolish self benefit start off preferred occasions")
	surface.SetWhiteTexture()
	surface.SetColor(1,0,0,0.25)
	surface.DrawRect(17, 30, w, h)
	
	
	surface.SetColor(1,1,1,1)
	surface.SetFont("love")
	surface.SetTextPosition(17, 150)
	surface.DrawText("empathize foolish self benefit start off preferred occasions")

	surface.SetColor(1,1,1,1)
	surface.SetFont("love2")
	surface.SetTextPosition(17, 170)
	surface.DrawText("EMPATHIZE FOOLISH SELF BENEFIT START OFF PREFERRED OCCASIONS")	
	
	local w, h = surface.GetTextSize("empathize foolish self benefit start off preferred occasions")
	surface.SetWhiteTexture()
	surface.SetColor(1,0,0,0.25)
	surface.DrawRect(17, 30, w, h)
end)