window.Open()

local gif1 = Gif("textures/angrykid.gif")
local gif2 = Gif("textures/pug.gif")

event.AddListener("OnDraw2D", "gif", function()
	gif1:Draw(30, 30)	
	gif2:Draw(320, 40)
end)