window.Open()

local gif1 = Gif("textures/angrykid.gif")
local gif2 = Gif("textures/pug.gif")
local gif3 = Gif("textures/envy.gif")
local gif4 = Gif("textures/greenkid.gif")

event.AddListener("OnDraw2D", "gif", function()
	gif1:Draw(0, 0)	
	gif2:Draw(291, 0)
	gif3:Draw(291, 215)
	gif4:Draw(-70, 240)
end)