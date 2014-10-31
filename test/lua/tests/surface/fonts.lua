surface.CreateFont("lol", {
	path = "Francois One", 
	size = 54,
})

event.AddListener("Draw2D", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetFont("lol")
	surface.SetTextPos(17, 30)
	surface.DrawText("empathize foolish self benefit start off preferred occasions")
	
	local w, h = surface.GetTextSize("empathize foolish self benefit start off preferred occasions")
	surface.SetWhiteTexture()
	surface.SetColor(1,0,0,0.25)
	surface.DrawRect(17, 30, w, h)
end)