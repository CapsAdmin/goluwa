local start = 0.5
local scale = 1

local tex = render.CreateTexture("2d")
tex:SetSize(Vec2(render2d.GetSize()) / scale)
tex:SetInternalFormat("rgba32f")
tex:SetMipMapLevels(1)
--tex:SetAnisotropy(0)
tex:SetMinFilter("nearest")
tex:SetMagFilter("nearest")

tex:Fill(function()
	local c = math.random(255) return 255,255,255,c
	--return math.random(255),math.random(255),math.random(255),math.random(255)
end)

event.Timer("update_cells", 0, 0, function()
	--render.SetBlendMode("src_color", "src_color", "add")
	render.SetPresetBlendMode("none")

	tex:Shade([[
		vec4 color = texture(self, uv);

		vec4 neighbours = vec4(0);

		{
			float radius = cos(color.a)*4;

			float dx = radius/size.x;
			float dy = radius/size.y;

			neighbours += texture(self, uv + vec2(+dx, 0.0));
			neighbours += texture(self, uv + vec2(-dx, 0.0));
			neighbours += texture(self, uv + vec2(0.0, +dy));
			neighbours += texture(self, uv + vec2(0.0, -dy));

			neighbours += texture(self, uv + vec2(+dx, +dy));
			neighbours += texture(self, uv + vec2(-dx, +dy));
			neighbours += texture(self, uv + vec2(-dx, -dy));
			neighbours += texture(self, uv + vec2(+dx, -dy));

			neighbours /= 8;

			color.g = radius/4;
			color.r = 0.5;
			color.b = 0.5;

			color.a = pow(sin(pow(neighbours.a, HALF_PI) * PI) / color.a, 0.18);
		}

		return color;
	]])
end)

function goluwa.PreDrawGUI()
	render2d.SetTexture()
	render2d.SetColor(0,0,0,1)
	render2d.DrawRect(0, 0, tex:GetSize().x*scale, tex:GetSize().y*scale)

	render2d.SetTexture(tex)
	render2d.SetColor(1,1,1,1)
	render2d.DrawRect(0, 0, tex:GetSize().x*scale, tex:GetSize().y*scale)
end