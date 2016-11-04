local tex = render.CreateBlankTexture(Vec2() + 8)

for x,y,i,r,g,b,a in tex:IteratePixels() do
	assert(r == 0)
	assert(g == 0)
	assert(b == 0)
	assert(a == 0)
end

for x,y,i,r,g,b,a in tex:IteratePixels() do
	tex:SetPixelColor(x, y, 255, 255, 255, 255)
end

for x,y,i,r,g,b,a in tex:IteratePixels() do
	assert(r == 255)
	assert(g == 255)
	assert(b == 255)
	assert(a == 255)
end

for x,y,i,r,g,b,a in tex:IteratePixels() do
	tex:SetPixelColor(x, y, x, y, 255, 255)
end

for x,y,i,r,g,b,a in tex:IteratePixels() do
	assert(x == r)
	assert(y == g)
end

for x,y,i,r,g,b,a in tex:IteratePixels() do
	r,g = tex:GetPixelColor(x,y)
	assert(x == r)
	assert(y == g)
	tex:SetPixelColor(x,y, r,g,y,x)
end

for x,y,i,r,g,b,a in tex:IteratePixels() do
	assert(x == r)
	assert(y == g)
	assert(y == b)
	assert(x == a)
end