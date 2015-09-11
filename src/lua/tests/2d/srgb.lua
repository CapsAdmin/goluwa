--local tex = Texture(256, 1):Fill(function(x, y) x = x / 255 x = x ^ 2.2 x = x * 255 return x,x,x,255 end)
local tex = Texture(256, 1):Fill(function(x, y) return x,x,x,255 end)

event.AddListener("Draw2D", "test", function()
	surface.SetColor(1,1,1,1)
	surface.SetTexture(tex)
	surface.DrawRect(50,50, 256, 32)
end)