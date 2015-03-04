local gl = require("libraries.ffi.opengl") -- OpenGL
local wnd = utility.RemoveOldObject(render.CreateWindow(512, 512))

function wnd:OnUpdate(dt)
	--render.DrawScene(self, dt)
	--do return end
	render.Start(self)
		render.Clear(gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT)
		surface.Start()
			surface.SetWhiteTexture()
			surface.SetColor(Color():GetRandom())
			surface.DrawRect(0,0,50,50)
		surface.End()
	render.End()
end