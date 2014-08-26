window.Open(500, 500)

surface.CreateFont("lol", {path = "fonts/NotoSans-Regular.ttf", size = 14})
surface.CreateFont("lol2", {path = "fonts/ariel", size = 14})
local str = [[あなたは醜い。]]  

event.AddListener("Draw2D", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetFont("lol")
	surface.SetTextPos(17,50)
	surface.DrawText(str .. "  ")
	
	surface.SetFont("lol2")
	surface.DrawText(str)
end)                 