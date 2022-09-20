local source = [[
	vec4 sum = vec4(0.0);

	vec2 blur = radius/size;

	sum += texture(self, vec2(uv.x - 4.0*blur.x*dir.x, uv.y - 4.0*blur.y*dir.y)) * 0.0162162162;
	sum += texture(self, vec2(uv.x - 3.0*blur.x*dir.x, uv.y - 3.0*blur.y*dir.y)) * 0.0540540541;
	sum += texture(self, vec2(uv.x - 2.0*blur.x*dir.x, uv.y - 2.0*blur.y*dir.y)) * 0.1216216216;
	sum += texture(self, vec2(uv.x - 1.0*blur.x*dir.x, uv.y - 1.0*blur.y*dir.y)) * 0.1945945946;

//	sum += texture(self, vec2(uv.x, uv.y)) * 0.2270270270;

	sum += texture(self, vec2(uv.x + 1.0*blur.x*dir.x, uv.y + 1.0*blur.y*dir.y)) * 0.1945945946;
	sum += texture(self, vec2(uv.x + 2.0*blur.x*dir.x, uv.y + 2.0*blur.y*dir.y)) * 0.1216216216;
	sum += texture(self, vec2(uv.x + 3.0*blur.x*dir.x, uv.y + 3.0*blur.y*dir.y)) * 0.0540540541;
	sum += texture(self, vec2(uv.x + 4.0*blur.x*dir.x, uv.y + 4.0*blur.y*dir.y)) * 0.0162162162;

	sum = pow(sum, vec4(0.5));
	sum -= texture(self, uv);

	return sum;
]]
local radius = 0.5
local font = fonts.CreateFont(
	{
		path = "Roboto",
		size = 20,
		padding = 8,
		shade = {
			{source = source, vars = {dir = Vec2(0, 1), radius = radius * 2}},
			{source = source, vars = {dir = Vec2(1, 0), radius = radius * 2}},
			{source = source, vars = {dir = Vec2(0, 1), radius = radius}},
			{source = source, vars = {dir = Vec2(1, 0), radius = radius}},
		},
	}
)

function goluwa.PreDrawGUI()
	local w, h = render2d.GetSize()
	render2d.SetColor(1, 1, 1, 1)
	gfx.SetFont(font)
	gfx.SetTextPosition(350, 350)
	gfx.DrawText("outline blur text")

	if font.texture_atlas then font.texture_atlas:DebugDraw() end

	do
		return
	end

	render2d.SetTexture()
	render2d.SetColor(1, 0, 0, 0.5)
	render2d.DrawRect(350, 350, gfx.GetTextSize("outline blur text"))
end