local settings = ContextSettings()

	settings.depthBits = 24
	settings.stencilBits = 8
	settings.antialiasingLevel = 4
	settings.majorVersion = 3
	settings.minorVersion = 0

local window = RenderWindow(VideoMode(800, 600, 32), "SFML window", bit.bor(e.RESIZE, e.CLOSE), settings)

gl.ClearColor(0, 1, 0, 1)

local params = Event()

event.AddListener("OnUpdate", "test", function()
	if window:IsOpen() then
		if window:PollEvent(params) and params.type == e.EVT_CLOSED then
			window:Close()
			os.exit()
 		end
		
		gl.Clear(e.GL_COLOR_BUFFER_BIT)		
		
		gl.Begin(e.GL_TRIANGLES)
			gl.Vertex3f( 0, 1, 0)
			gl.Vertex3f(-1, -1, 0)
			gl.Vertex3f( 1, -1, 0)
		gl.End()

		window:Display()
	end
end)