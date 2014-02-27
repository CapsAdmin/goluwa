window.Open()

local font = surface.CreateFont("lol", {
	path = "Aladin",
	size = 50,
})  
   
event.AddListener("OnDraw2D", "lol", function()
	surface.Color(1,1,1,1)

	surface.SetFont(font)
	surface.SetTextPos(10, 10)
	surface.DrawText("Aladin ㅁ國國ㄴㅇ ㅁㅁㅇ >> 👾👾 << no aliens in unifont :(") 
end)        