local background = render.CreateTextureFromPath("https://image.freepik.com/free-vector/abstract-background-with-a-watercolor-texture_1048-2144.jpg")

local fb = render.CreateFrameBuffer()
fb:SetSize(Vec2()+512)
local tex = render.CreateTexture("2d")
tex:SetSize(Vec2(512, 512))
tex:SetInternalFormat("rgba8")
tex:SetupStorage()
tex:Clear()
fb:SetTexture(1, tex, "read_write")

function goluwa.PreDrawGUI()
	gfx.DrawRect(background)

	local time = os.clock()
	render.PushScissor(math.sin(time)*100 + 100,math.cos(time)*100 + 100,50,50)
	render2d.PushColor(1,0,1,1)
	gfx.DrawRect(background)
	render2d.PopColor()
	render.PopScissor()

	fb:Begin()
		local x,y = gfx.GetMousePosition()

		render.PushScissor(x,y,50,50)
		render2d.PushColor(1,0,1,1)
		gfx.DrawRect(background)
		render2d.PopColor()
		render.PopScissor()
	fb:End()

	gfx.DrawRect(0, 0, 512, 512, tex)

	fb:ClearColor(1,1,1,1)
end