local wnd = utility.RemoveOldObject(system.CreateWindow(512, 512),"lol")

function wnd:OnUpdate(dt)
	render.PushWindow(self)
		render.GetScreenFrameBuffer():Clear()

		render2d.SetTexture()
		render2d.SetColor(Color():GetRandom():Unpack())
		render2d.DrawRect(0,0,50,50)

		render.SwapBuffers()
	render.PopWindow()
end