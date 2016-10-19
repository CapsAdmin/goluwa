local tex = render.CreateBlankTexture(Vec2() + 64):Fill(function()
	return math.random(255), math.random(255), math.random(255), math.random(255)
end)

event.AddListener("PreDrawGUI", "lol", function()
	render2d.SetColor(1,1,1,1)
	render2d.SetTexture(tex)

	render2d.DrawRect(90, 50, 100, 100)
end)