local tex = render.CreateTextureFromPath("textures/gui/skins/dark.png")

function goluwa.PreDrawGUI()
	render2d.SetTexture(tex)
	render2d.SetColor(1, 1, 1, 1)
	render2d.DrawRect(0, 0, tex:GetSize():Unpack())

	local x,y = gfx.GetMousePosition()
	render2d.SetTexture()
	--render2d.SetColor(0,0,0,1)
	--render2d.DrawRect(x, y, 32, 32)

	render2d.SetColor(tex:GetPixelColor(x, y):Unpack())
	render2d.DrawRect(x+8, y+8, 16, 16)
end