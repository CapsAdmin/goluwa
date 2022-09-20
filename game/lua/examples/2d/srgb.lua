--local tex = render.CreateBlankTexture(Vec2(256, 1)):Fill(function(x, y) x = x / 255 x = x ^ 2.2 x = x * 255 return x,x,x,255 end)
local tex = render.CreateTexture("2d")
tex:SetSRGB(true)
tex:SetSize(Vec2(256, 1))
tex:SetupStorage()

tex:Fill(function(x, y)
	x = math.linear2gamma(x / 256) * 256
	return x, x, x, 255
end)

function goluwa.PreDrawGUI()
	render2d.SetColor(1, 1, 1, 1)
	render2d.SetTexture(tex)
	render2d.DrawRect(0, 0, render2d.GetSize())
end