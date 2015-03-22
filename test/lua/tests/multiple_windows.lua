local gl = require("graphics.ffi.opengl") -- OpenGL
local wnd = utility.RemoveOldObject(render.CreateWindow(512, 512),"lol")

function wnd:OnUpdate(dt)	
	render.PushWindow(self)
		render.Clear(gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT)
		
		surface.SetWhiteTexture()
		surface.SetColor(Color():GetRandom())
		surface.DrawRect(0,0,50,50)
		
		render.SwapBuffers()
	render.PopWindow()
end