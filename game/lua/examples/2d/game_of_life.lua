local start = 0.5
local tex = render.CreateBlankTexture(Vec2(render.GetHeight(), render.GetWidth()))
tex:SetMinFilter("nearest")
tex:SetMagFilter("nearest")
tex:Fill(function()
	return 255, 255, 255, math.random() > start and 255 or 0
end)

event.Timer("update_cells", 0, 0,function()
	--render.SetBlendMode("src_color", "src_color", "add")
	render.SetPresetBlendMode("none")
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

function goluwa.PreDrawGUI()
	render2d.SetTexture()
	render2d.SetColor(0,0,0,1)
	render2d.DrawRect(0, 0, tex:GetSize().x, tex:GetSize().y)

	render2d.SetTexture(tex)
	render2d.SetColor(1,1,1,1)
	render2d.DrawRect(0, 0, tex:GetSize().x, tex:GetSize().y)
end