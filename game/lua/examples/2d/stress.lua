window.Open(500, 500)

local cache = {}

function goluwa.PreDrawGUI()
	render2d.SetTexture()
	local time = system.GetElapsedTime()

	for x = 1, 512 do
	for y = 1, 512 do

		local h =  math.ceil((time + (x/y))* 100)
		local c = cache[h] or ColorHSV(h/100,1,1)
		cache[h] = c

		render2d.SetColor(c.r,c.g,c.b, 0.5)
		render2d.DrawRect(x, y, 1, 1)
	end
	end
end
