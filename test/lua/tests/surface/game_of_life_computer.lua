local start = 0.5
local scale = 1
 
local tex = Texture({
	format = "rgba32f",
	width = render.GetWidth()/scale,
	height = render.GetHeight()/scale,
	mip_map_levels = 0,
	anisotropy = 0,
	min_filter = "nearest", 
	mag_filter = "nearest"
})

tex:Fill(function()
	local c = math.random(255) return 255,255,255,c
	--return math.random(255),math.random(255),math.random(255),math.random(255)
end)
 
event.CreateTimer("update_cells", 0, 0, function()
	render.SetBlendMode2("src_color", "src_color", "add")
	tex:Shade([[
		float pi = 3.14159265358979323846264338327950288419716939937510582097494459230781640;
		float pi2 = pi/2;
		
		vec4 color = texture(self, uv);
		
		vec4 neighbours = vec4(0);
		
		{
			float radius = 1 + (cos(color.a)/25); 
		
			float dx = radius/size.x; 
			float dy = radius/size.y;
						
			neighbours += texture(self, uv + vec2(+dx, 0.0));
			neighbours += texture(self, uv + vec2(-dx, 0.0));
			neighbours += texture(self, uv + vec2(0.0, +dy));
			neighbours += texture(self, uv + vec2(0.0, -dy));
			color.g = neighbours.a/2;
			
			neighbours += texture(self, uv + vec2(+dx, +dy));
			neighbours += texture(self, uv + vec2(-dx, +dy));
			neighbours += texture(self, uv + vec2(-dx, -dy));
			neighbours += texture(self, uv + vec2(+dx, -dy));
			color.r = neighbours.a/2;  
			
			neighbours /= 8;
			
			color.b = radius/2;
						
			color.a = pow(sin(pow(neighbours.a, pi2) * pi) / color.a, 0.2);
		}
			
		return color;
	]], nil, true)
end)

event.AddListener("Draw2D", "fb", function()
	surface.SetWhiteTexture()
	surface.SetColor(0,0,0,1)
	surface.DrawRect(0, 0, tex.w*scale, tex.h*scale)
	
	surface.SetTexture(tex)
	surface.SetColor(1,1,1,1)
	surface.DrawRect(0, 0, tex.w*scale, tex.h*scale)
end)   