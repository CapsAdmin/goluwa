window.Open()

local font = surface.CreateFont("test", {
	path = "http://googlefontdirectory.googlecode.com/hg/ofl/aladin/Aladin-Regular.ttf",
	size = 50,
})
  
event.AddListener("OnDraw2D", "lol", function()
	surface.Color(1,1,1,1)

	surface.SetFont(font)
	surface.SetTextPos(100, 100)
	surface.DrawText("Aladin זר ורז רזרו")
end)    

     