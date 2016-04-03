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

local font = surface.CreateFont({
	path = "Roboto",
	size = 20,
	padding = 8,
	shade = {
		{source = source, vars = {dir = Vec2(0,1), radius = radius*2}},
		{source = source, vars = {dir = Vec2(1,0), radius = radius*2}},
		{source = source, vars = {dir = Vec2(0,1), radius = radius}},
		{source = source, vars = {dir = Vec2(1,0), radius = radius}},
	},
})

event.AddListener("DrawHUD", "lol", function()
	local w, h = surface.GetSize()

	surface.SetColor(1,1,1,1)

	surface.SetFont(font)
	surface.SetTextPosition(350, 350)
	surface.DrawText("outline blur text")

	if font.texture_atlas then
		font.texture_atlas:DebugDraw()
	end

do return end
	surface.SetWhiteTexture()
	surface.SetColor(1,0,0,0.5)
	surface.DrawRect(350, 350, surface.GetTextSize("outline blur text"))
end)