local wnd = utility.RemoveOldObject(system.CreateWindow(512, 512),"lol")

function wnd:OnUpdate(dt)
	render.PushWindow(self)
		render.GetScreenFrameBuffer():Clear()

		surface.SetWhiteTexture()
		surface.SetColor(Color():GetRandom())
		surface.DrawRect(0,0,50,50)

		render.SwapBuffers()
	render.PopWindow()
end