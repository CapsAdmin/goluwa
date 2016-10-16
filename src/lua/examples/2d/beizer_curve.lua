local tex = render.CreateTextureFromPath("http://bgfons.com/upload/rope_texture2073.jpg")

local curve = gfx.CreateQuadricBezierCurve()
--curve:Add(Vec2(114 , 90 ), Vec2(183 , 25))
--curve:Add(Vec2(278 , 104), Vec2(322 , 161))
--curve:Add(Vec2(287 , 241), Vec2(275 , 375))
--curve:Add(Vec2(445 , 350), Vec2(560 , 312))
--curve:Add(Vec2(621 , 416))

curve:Add(Vec2(0,0))
curve:Add(Vec2(1,0))
curve:Add(Vec2(1,1))
curve:Add(Vec2(0,1))


local poly = curve:ConstructPoly(Vec2(-0.1, 0), 4, 5)
poly.mesh:SetMode("triangle_strip")

event.AddListener("PostDrawGUI", "lol", function()
	--surface.DrawRect(0,0,tex:GetSize():Unpack())

	surface.SetWhiteTexture()
	surface.DrawRect(50,50,500,500)

	surface.SetColor(1,1,1,1)
	surface.SetTexture(tex)

	surface.PushMatrix(50, 50, 500, 500)
		poly:Draw()
	surface.PopMatrix()


	surface.SetWhiteTexture()
end)