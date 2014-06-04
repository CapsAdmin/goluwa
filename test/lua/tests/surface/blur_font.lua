local font = surface.CreateFont("lol", {
	path = "Roboto",
	size = 50,
	blur = {
		size = 0.75,
		step_size = 0.6,
		alpha = 1,
		color = Color(0.5, 0.5, 0.5),
	},
})   
   
event.AddListener("DrawHUD", "lol", function()
	local w, h = surface.GetScreenSize()
	surface.Color(0.6,1,1,1)
	surface.SetWhiteTexture()
	surface.DrawRect(0,0,w*0.6,h*0.1)
	
	surface.Color(1,1,1,1)  

	surface.SetFont("lol")
	surface.SetTextPos(10, 10)
	surface.DrawText("no yes that2" .. math.random(50))
end)