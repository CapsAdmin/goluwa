local font = fonts.CreateFont({
	path = "fonts/Roboto-Regular.ttf",
	size = 100,
})

function goluwa.PreDrawGUI()
	local w, h = render2d.GetSize()
	render2d.SetColor(1, 1, 1, 1)
	gfx.SetFont(font)
	gfx.SetTextPosition(350, 350)
	gfx.DrawLine(350, 350, 350 + 100, 350)
	local str = "gyjq Q buik"
	local w, h = gfx.GetTextSize(str)
	gfx.DrawText(str)
	gfx.DrawRect(350, 350, w, h, render.GetWhiteTexture(), 1, 0, 0, 0.5)

	if font.texture_atlas then font.texture_atlas:DebugDraw() end
end