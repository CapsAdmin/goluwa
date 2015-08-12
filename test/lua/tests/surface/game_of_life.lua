local start = 0.5
local tex = Texture(render.GetHeight(), render.GetWidth())
tex:SetMinFilter("nearest")
tex:SetMagFilter("nearest")
tex:Fill(function() 
	return math.random()> start and 255 or 0,math.random()> start and 255 or 0,math.random()> start and 255 or 0,math.random()> start and 255 or 0
end)

event.CreateTimer("update_cells", 0, 0,function()
--render.SetBlendMode("src_color", "src_color", "add")
render.SetBlendMode()
tex:Shade([[
	vec4 color = texture(self, uv);
	vec2 uv = gl_FragCoord.xy / size;
	vec2 uv_unit = 1.0 / size;	
	
	{
		int neighbours = 0;
		
		for (float y = -1; y <= 1; y++)
		{
			for (float x = -1; x <= 1; x++)
			{
				if (texture(self, uv + (uv_unit * vec2(x, y))).a > 0)
				{
					neighbours++;
				}
			}
		}
		
		if (color.a > 0 && (neighbours-1 < 2 || neighbours-1 > 3))
		{
			color.a = 0;
		}
		else if (neighbours == 3)
		{
			color.a = 1;
		}
	}
		
	return color;
]])

end)

event.AddListener("Draw2D", "fb", function()
	surface.SetWhiteTexture()
	surface.SetColor(0,0,0,1)
	surface.DrawRect(0, 0, tex.w, tex.h)
	
	surface.SetTexture(tex)
	surface.SetColor(1,1,1,1)
	surface.DrawRect(0, 0, tex.w, tex.h)
end)   