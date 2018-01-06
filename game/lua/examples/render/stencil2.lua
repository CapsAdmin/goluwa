local screen_size = render.GetScreenSize()
local w,h = screen_size:Unpack()
local background = render.CreateTextureFromPath("https://image.freepik.com/free-vector/abstract-background-with-a-watercolor-texture_1048-2144.jpg")

function goluwa.PreDrawGUI()
	local max = 4

	render2d.SetTexture()

	render.SetStencil(true)
	render.GetFrameBuffer():ClearStencil(0) -- out = 0

	for i = 1, max do
		local d = 1 + (i/max)-0.1

		local x, y = math.sin(system.GetElapsedTime()+i)*150, math.cos(system.GetElapsedTime()+i)*150

		render2d.PushStencilRect(x+ (w/d), y + (h/d), w - (w/d) * 2, h - (h/d) * 2, i - 1)

		render2d.SetColor(ColorHSV(i/max,1,1):Unpack())
		render2d.DrawRect(0, 0, w,h)

		render2d.PopStencilRect()
	end

	render.SetStencil(false)
end