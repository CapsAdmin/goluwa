window.Open(500, 500)

surface.CreateFont("lol", {path = "Permanent Marker", size = 14})
surface.CreateFont("lol2", {path = "fonts/ariel", size = 14})
local str = [[ASD ASDあなたは醜い。]]  

event.AddListener("Draw2D", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetFont("lol")
	surface.SetTextPos(17,50)
	surface.DrawText(str .. "  ")
	
	surface.SetTextPos(17,100)
	surface.SetFont("lol2")
	surface.DrawText(str)
end)