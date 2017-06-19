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
poly.vertex_buffer:SetMode("triangle_strip")

function goluwa.PreDrawGUI()
	--render2d.DrawRect(0,0,tex:GetSize():Unpack())

	render2d.SetTexture()
	render2d.DrawRect(50,50,500,500)

	render2d.SetColor(1,1,1,1)
	render2d.SetTexture(tex)

	render2d.PushMatrix(50, 50, 500, 500)
		poly:Draw()
	render2d.PopMatrix()
end