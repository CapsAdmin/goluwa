surface.CreateFont("lol", {
	path = "Francois One", 
	size = 54,
})

event.AddListener("Draw2D", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetFont("lol")
	surface.SetTextPos(17, 0)
	surface.DrawText("empathize foolish self benefit start off preferred occasions")
end)                 