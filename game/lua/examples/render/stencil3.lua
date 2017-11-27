local w, h = render.GetScreenSize():Unpack()
local background = render.CreateTextureFromPath("https://image.freepik.com/free-vector/abstract-background-with-a-watercolor-texture_1048-2144.jpg")
do
	local i = 0
	local X,Y,W,H

	function render2d.PushStencilRect2(x,y,w,h)
		i = i + 1

		render.StencilFunction("never", 0)
		render.StencilOperation("increase", "replace", "replace")

		render2d.PushTexture()
			render2d.PushColor(0,0,0,0)
			render2d.DrawRect(x,y,w,h)
			render2d.PopColor()
		render2d.PopTexture()

		render.StencilFunction("equal", i-1)

		X,Y,W,H = x,y,w,h
	end

	function render2d.PopStencilRect2()
		render.StencilFunction("never", 0)
		render.StencilOperation("decrease", "replace", "replace")

		render2d.PushTexture()
			render2d.PushColor(0,0,0,0.01)
			render2d.DrawRect(X,Y,W,H)
			render2d.PopColor()
		render2d.PopTexture()

		i = i - 1
	end
end

function goluwa.PostDrawGUI()
	local max = 6

	render2d.SetTexture()

	--render.SetStencil(true)
	render.GetFrameBuffer():ClearStencil(0) -- out = 0

	for i = 0, max - 1 do
		local f = (i/max)
		local f2 = -f+1

		render2d.SetColor(ColorHSV(f,1,1):Unpack())

		render2d.PushStencilRect2(
			(w/2)*f + math.sin(system.GetElapsedTime()+i)*200*f,
			(h/2)*f + math.cos(system.GetElapsedTime()+i)*200*f,
			f2*w,
			f2*h
		)

		render2d.DrawRect(0, 0, w,h)
	end

	for i = 1, max do
		render2d.PopStencilRect2()
	end

	render.SetStencil(false)
end