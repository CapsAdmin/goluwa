local tex = render.CreateTextureFromPath("http://bgfons.com/upload/rope_texture2073.jpg")

local curve = surface.CreateQuadricBeizerCurve()
--curve:Add(Vec2(114 , 90 ), Vec2(183 , 25))
--curve:Add(Vec2(278 , 104), Vec2(322 , 161))
--curve:Add(Vec2(287 , 241), Vec2(275 , 375))
--curve:Add(Vec2(445 , 350), Vec2(560 , 312))
--curve:Add(Vec2(621 , 416))

curve:Add(Vec2(200,50))
curve:Add(Vec2(400,50))
curve:Add(Vec2(500,300))
curve:Add(Vec2(100,300))


local poly = curve:ConstructPoly(40, 1, 10)
poly.mesh:SetMode("triangle_strip")

event.AddListener("PostDrawGUI", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetTexture(tex)

	--surface.DrawRect(0,0,tex:GetSize():Unpack())

	poly:Draw()

	surface.SetWhiteTexture()
end)