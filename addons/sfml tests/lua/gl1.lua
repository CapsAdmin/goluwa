local window = asdfml.OpenWindow()

gl.ClearColor(0, 1, 0, 1)

local params = Event()

event.AddListener("OnDraw", "test", function()		
	gl.Clear(e.GL_COLOR_BUFFER_BIT)		
	
	gl.Begin(e.GL_TRIANGLES)
		gl.Vertex3f( 0, 1, 0)
		gl.Vertex3f(-1, -1, 0)
		gl.Vertex3f( 1, -1, 0)
	gl.End()
end)