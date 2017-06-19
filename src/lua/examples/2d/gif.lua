local gif1 = gfx.CreateGif("https://dl.dropboxusercontent.com/u/244444/angrykid.gif")
local gif2 = gfx.CreateGif("https://dl.dropboxusercontent.com/u/244444/pug.gif")
local gif3 = gfx.CreateGif("https://dl.dropboxusercontent.com/u/244444/envy.gif")
local gif4 = gfx.CreateGif("https://dl.dropboxusercontent.com/u/244444/greenkid.gif")
local gif5 = gfx.CreateGif("https://dl.dropboxusercontent.com/u/244444/zzzzz.gif")

function goluwa.PreDrawGUI()
	render2d.SetColor(1, 1, 1, 1)
	gif1:Draw(0, 0)
	gif2:Draw(291, 0)
	gif3:Draw(291, 215)
	gif4:Draw(-70, 240)
	gif5:Draw(40, 450)
end