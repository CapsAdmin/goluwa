local tex = render.CreateTexture("2d")
tex:SetPath("textures/greendog.png")

local function blur_texture(dir)
	tex:Shade(
		[[
		//this will be our RGBA sum
		vec4 sum = vec4(0.0);

		//the amount to blur, i.e. how far off center to sample from
		//1.0 -> blur by one pixel
		//2.0 -> blur by two pixels, etc.
		float blur = radius/resolution.x;

		//the direction of our blur
		//(1.0, 0.0) -> x-axis blur
		//(0.0, 1.0) -> y-axis blur
		float hstep = dir.x;
		float vstep = dir.y;

		//apply blurring, using a 9-tap filter with predefined gaussian weights

		sum += texture(self, vec2(uv.x - 4.0*blur*hstep, uv.y - 4.0*blur*vstep)) * 0.0162162162;
		sum += texture(self, vec2(uv.x - 3.0*blur*hstep, uv.y - 3.0*blur*vstep)) * 0.0540540541;
		sum += texture(self, vec2(uv.x - 2.0*blur*hstep, uv.y - 2.0*blur*vstep)) * 0.1216216216;
		sum += texture(self, vec2(uv.x - 1.0*blur*hstep, uv.y - 1.0*blur*vstep)) * 0.1945945946;

		sum += texture(self, vec2(uv.x, uv.y)) * 0.2270270270;

		sum += texture(self, vec2(uv.x + 1.0*blur*hstep, uv.y + 1.0*blur*vstep)) * 0.1945945946;
		sum += texture(self, vec2(uv.x + 2.0*blur*hstep, uv.y + 2.0*blur*vstep)) * 0.1216216216;
		sum += texture(self, vec2(uv.x + 3.0*blur*hstep, uv.y + 3.0*blur*vstep)) * 0.0540540541;
		sum += texture(self, vec2(uv.x + 4.0*blur*hstep, uv.y + 4.0*blur*vstep)) * 0.0162162162;

		return sum;
	]],
		{
			radius = 1,
			resolution = render.GetScreenSize(),
			dir = dir,
		}
	)
end

blur_texture(Vec2(0, 5))
blur_texture(Vec2(5, 0))

function goluwa.PreDrawGUI()
	render2d.SetTexture(tex)
	render2d.SetColor(1, 1, 1, 1)
	render2d.DrawRect(50, 50, 128, 128)
end