local tex = render.CreateTextureFromPath("textures/pac.png")

function goluwa.PreDrawGUI()
	render2d.SetColor(1,1,1,1)
	render2d.SetTexture(tex)

	render2d.SetRectUV(0, 0, 0.5, 0.5)
	render2d.DrawRect(50, 50, 100, 100)

	render2d.SetRectUV(0.5, 0.5, 0.5, 0.5)
	render2d.DrawRect(150, 150, 100, 100)

	render2d.SetRectUV(0, 0.5, 0.5, 0.5)
	render2d.DrawRect(50, 150, 100, 100)

	render2d.SetRectUV(0.5, 1, 0.5, 0.5)
	render2d.DrawRect(150, 50, 100, 100)

	render2d.SetRectUV()
end