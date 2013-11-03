window.Open(500, 500)
surface.debug = false
surface.CreateFont("lol", {path = "fonts/unifont.ttf", size = 14})
local str = "ᗢᖇᓮᘐᓰﬡᗩᒪ(강남스타일)Morshmelloweee333222🗽🗽🗽"
event.AddListener("OnDraw2D", "lol", function()
	surface.SetFont("lol")
	surface.SetTextPos(17,50)
	surface.DrawText(str)
end)                 